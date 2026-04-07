// V2 Bait Station — Open tray with push-pin, flat floor, ant access holes.
// The reservoir drops inside; tabs slide into vertical slots and seat onto the pin.
// Ants access bait through small holes in the outer wall into the tray cavity.
// Outer + inner bait barrier rings; inner ring has holes, rails, and a rail-height annular disk 2 mm inward on the bore.

needle_insert_as_library = true;
include <needle-insert.scad>

// ── Main Assembly ─────────────────────────────────────────────────
module bait_station() {
    union() {
        difference() {
            union() {
                difference() {
                    station_solid();
                    station_bore();
                    station_tab_slots();
                    station_bottom_barb_channel_and_catch();
                    station_guard_holes();
                }
                // Barriers after bore; needle is a separate printed insert (pocket subtracted below)
                station_bait_barrier_ring();
                station_inner_bait_barrier_ring();
            }
            needle_insert_pocket();
            station_side_scallops();
            part_bottom_info_stamp_deboss(station_stamp_bottom, station_od);
        }
        // Rails + inner rail disk + flex retention tabs: union after needle pocket so the pocket cylinder
        // does not hollow them (same reason rails sit here; pocket clears insert volume in the bore).
        // When red preview is on (F5), show only the colored copy so the disk is not drawn twice.
        if (!(mesh_preview && inner_barrier_inner_rail_disk_color_preview))
            station_inner_barrier_inner_rail_disk_cut();
        station_inner_barrier_rails();
        station_inner_barrier_retention_tabs();
        if (mesh_preview && inner_barrier_inner_rail_disk_color_preview)
            color("red", 0.82)
                station_inner_barrier_inner_rail_disk_cut();
    }
}

// ── Solid Body ────────────────────────────────────────────────────
module station_solid() {
    render_if_needed()
        cylinder(h = station_height, d = station_od);
}

// ── Bore ──────────────────────────────────────────────────────────
// Internal cavity where the reservoir sits. Starts at station_floor;
// the reservoir sits at reservoir_seat (tabs); tray_gap_below_reservoir under the bottom.
module station_bore() {
    render_if_needed()
        translate([0, 0, station_floor])
            cylinder(h = station_height - station_floor + 1, d = station_id);
}

// ── Bait Barrier Ring (outer) ────────────────────────────────────
// Solid annulus from tray floor to reservoir bottom.
module station_bait_barrier_ring() {
    render_if_needed()
        translate([0, 0, bait_barrier_bottom_z])
            difference() {
                cylinder(h = bait_barrier_h, d = bait_barrier_od);
                translate([0, 0, -0.01])
                    cylinder(h = bait_barrier_h + 0.02, d = bait_barrier_id);
            }
}

// Annulus inside the inner bore with tangential slots at each rail site (between the two rails) so the needle insert can slide in.
// Horizontal shelf = rin deep (2 mm): fine for PLA/PETG with chamfer or slower layers; reduce rin in common if bridging struggles.
module station_inner_barrier_inner_rail_disk() {
    z_bot = inner_barrier_rail_z_bot;
    zh = inner_barrier_rail_z_top - inner_barrier_rail_z_bot;
    r_outer = inner_barrier_inner_rail_disk_r_outer_mm;
    r_inner = inner_barrier_inner_rail_disk_r_inner_mm;
    gap_t = 2 * inner_barrier_rail_y_offset_mm - inner_barrier_rail_width_mm;
    slot_w = gap_t + 2 * inner_barrier_inner_rail_disk_slot_clearance_mm;
    extra_in = inner_barrier_inner_rail_disk_slot_bottom_inward_mm;
    // Slot cutter: from slightly outside disk OD down past inner ring face into bore (clears visible ring in slide path).
    r_cut_out = r_outer + 0.05;
    r_cut_in = max(0.5, r_inner - extra_in);
    slot_xc = (r_cut_in + r_cut_out) / 2;
    slot_xw = r_cut_out - r_cut_in;
    render_if_needed()
        translate([0, 0, z_bot])
            difference() {
                cylinder(h = zh, r = r_outer);
                translate([0, 0, -0.01])
                    cylinder(h = zh + 0.02, r = r_inner);
                for (i = [0 : inner_bait_barrier_hole_count - 1])
                    rotate([0, 0, inner_barrier_rail_phase_deg + i * (360 / inner_bait_barrier_hole_count)])
                        translate([slot_xc, 0, zh / 2])
                            cube([slot_xw, slot_w + 0.08, zh + 0.02], center = true);
            }
}

// ── Inner Bait Barrier Ring ───────────────────────────────────────
// Same Z span as outer; 1″ OD, 1 mm wall; pin channels + six wall holes + relief behind needle clips.
// Inner rail disk is not unioned here — needle_insert_pocket() would erase it; see station_inner_barrier_inner_rail_disk_cut() in bait_station().
module station_inner_bait_barrier_ring() {
    render_if_needed()
        difference() {
            translate([0, 0, bait_barrier_bottom_z])
                difference() {
                    cylinder(h = bait_barrier_h, d = inner_bait_barrier_od);
                    translate([0, 0, -0.01])
                        cylinder(h = bait_barrier_h + 0.02, d = inner_bait_barrier_id);
                }
            needle_insert_channels();
            station_inner_barrier_wall_holes();
            station_inner_barrier_post_wall_relief();
        }
}

// Cut annulus wall behind each needle clip slot (same phase as rails); tangential span = gap between rail inner faces.
module station_inner_barrier_post_wall_relief() {
    id2 = inner_bait_barrier_id / 2;
    od2 = inner_bait_barrier_od / 2;
    wall_r = od2 - id2;
    mid_r = (id2 + od2) / 2;
    gap_t = 2 * inner_barrier_rail_y_offset_mm - inner_barrier_rail_width_mm;
    zc = bait_barrier_bottom_z + bait_barrier_h / 2;
    for (i = [0 : inner_bait_barrier_hole_count - 1])
        rotate([0, 0, inner_barrier_rail_phase_deg + i * (360 / inner_bait_barrier_hole_count)])
            translate([mid_r, 0, zc])
                cube([wall_r + 0.25, gap_t + 0.2, bait_barrier_h + 0.02], center = true);
}

// Six radial holes through inner barrier wall (needle channel size), flush with tray floor top.
module station_inner_barrier_wall_holes() {
    for (i = [0 : inner_bait_barrier_hole_count - 1])
        rotate([0, 0, i * (360 / inner_bait_barrier_hole_count)])
            translate([inner_bait_barrier_hole_start_r, 0, inner_bait_barrier_hole_z])
                rotate([0, 90, 0])
                    cylinder(h = inner_bait_barrier_hole_length, d = inner_bait_barrier_hole_dia);
}

// Rail-height annulus inside the bore: union after needle_insert_pocket() in bait_station() so the pocket
// does not subtract it (pocket radius fills the bore for the insert). Same cutters as the ring wall.
module station_inner_barrier_inner_rail_disk_cut() {
    difference() {
        station_inner_barrier_inner_rail_disk();
        needle_insert_channels();
        station_inner_barrier_wall_holes();
    }
}

// Flex tab: floor foot in the rail gap; outer face vertical at inner-barrier OD; inner side V points toward -X (needle).
// Profile is XZ (2nd coord = station Z); rotate([90,0,0]) then linear_extrude → tangential tab_w.
module station_inner_barrier_retention_tabs() {
    gap_t = 2 * inner_barrier_rail_y_offset_mm - inner_barrier_rail_width_mm;
    tab_w = gap_t - 2 * inner_barrier_retention_tab_gap_clearance_mm;
    id2 = inner_bait_barrier_id / 2;
    od2 = inner_bait_barrier_od / 2;
    t = inner_barrier_retention_tab_radial_thickness_mm;
    z_floor = bait_barrier_bottom_z;
    z_foot_top = z_floor + inner_barrier_retention_tab_floor_foot_h_mm;
    z_barb_base_abs = needle_insert_clip_body_z_top - needle_insert_clip_top_barb_drop_mm;
    z_tab_top = bait_barrier_top_z;
    h_barb = needle_insert_clip_top_barb_h_mm;
    hm = h_barb / 2;
    v_depth = inner_barrier_retention_tab_v_depth_mm;
    v_ha = inner_barrier_retention_tab_v_half_angle_deg;
    // Inner tab wall (toward needle): x = id2 - t; V tip further inward for barb catch
    x_wall_in = id2 - t;
    x_v_tip = max(x_wall_in - v_depth, id2 / 2); // don't cross axis
    z_v_apex = z_barb_base_abs + hm;
    // Symmetric V arms so profile stays ordered (no self-intersection if foot clamp would cross z_v_top)
    dz_geo = (x_wall_in - x_v_tip) / tan(v_ha);
    dz_up = z_tab_top - 0.02 - z_v_apex;
    dz_dn = z_v_apex - (z_foot_top + 0.05);
    dz = min(dz_geo, dz_up, dz_dn);
    z_v_top = z_v_apex + dz;
    z_v_bot = z_v_apex - dz;

    for (i = [0 : inner_bait_barrier_hole_count - 1])
        rotate([0, 0, inner_barrier_rail_phase_deg + i * (360 / inner_bait_barrier_hole_count)])
            rotate([90, 0, 0])
                linear_extrude(height = tab_w, center = true)
                    polygon([
                        // CCW in (radial X, station Z): foot bottom, outer vertical, top, inner wall + V, foot top step, foot inner edge
                        [id2, z_floor],
                        [od2, z_floor],
                        [od2, z_tab_top],
                        [x_wall_in, z_tab_top],
                        [x_wall_in, z_v_top],
                        [x_v_tip, z_v_apex],
                        [x_wall_in, z_v_bot],
                        [x_wall_in, z_foot_top],
                        [id2, z_foot_top],
                    ]);
}

// Two rails per site (tangential ±Y), inward from inner barrier ID; radial width matches disk inner lip (rin + disk inner overlap).
// No filler slab behind the needle-retention clip slots — clips flex into open tray space past the rails.
module station_inner_barrier_rails() {
    w = inner_barrier_rail_width_mm;
    rin = inner_barrier_rail_inward_mm;
    eo = inner_barrier_inner_rail_disk_inner_overlap_mm;
    rail_x = rin + eo; // inner face at disk r_inner, outer face at bore ID (id2)
    yo = inner_barrier_rail_y_offset_mm;
    id2 = inner_bait_barrier_id / 2;
    z_top = bait_barrier_top_z - inner_barrier_rail_height_trim_mm + inner_barrier_rail_z_offset_mm;
    z_bot = station_floor - inner_barrier_rail_extend_below_floor_mm + inner_barrier_rail_z_offset_mm;
    zh = z_top - z_bot;
    zc = z_bot + zh / 2;
    // +X local = outward; rail occupies x in [id2 - rail_x, id2], flush inner edge with inner rail disk ID
    xc = id2 - rail_x / 2;
    for (i = [0 : inner_bait_barrier_hole_count - 1])
        rotate([0, 0, inner_barrier_rail_phase_deg + i * (360 / inner_bait_barrier_hole_count)])
            for (sgn = [-1, 1])
                translate([xc, sgn * yo, zc])
                    cube([rail_x, w, zh], center = true);
}

// ── Tab Slots ─────────────────────────────────────────────────────
// Straight vertical slots in the station bore wall. Guide tabs
// slide straight down — no twist required.
module station_tab_slots() {
    slot_w     = tab_w + clearance * 2;
    slot_depth = tab_d + clearance + 1;

    for (i = [0 : tab_count - 1]) {
        angle = i * (360 / tab_count);
        rotate([0, 0, angle])
            translate([station_id / 2 - 0.5, -slot_w / 2, tab_z_locked])
                cube([slot_depth, slot_w, station_height - tab_z_locked + 1]);
    }
}

// ── Bottom barb channel + catch ─────────────────────────────────
// 1 mm-deep vertical channel on bore ID for barb to slide (insert + tab travel).
// At seated (collapsed) height: rectangular cut through full wall for outward barb to engage.
module station_bottom_barb_channel_and_catch() {
    pw    = bottom_barb_w_mm + clearance * 2;
    r0    = station_id / 2 - 0.02;
    ch    = bottom_barb_channel_depth_mm;
    z_lo  = station_floor - 0.02;
    z_hi  = station_height + 0.5;
    zh    = z_hi - z_lo;

    z_c0  = reservoir_seat + bottom_barb_z0_mm - bottom_barb_catch_z_margin_mm - clearance;
    z_ch  = bottom_barb_h_mm + 2 * (bottom_barb_catch_z_margin_mm + clearance);
    r_thru = station_od / 2 - r0 + 0.6;

    for (k = [0 : tab_count - 1]) {
        i = floor((k + 0.5) * ant_tunnel_count / tab_count);
        angle = i * (360 / ant_tunnel_count);
        rotate([0, 0, angle]) {
            translate([r0, -pw / 2, z_lo])
                cube([ch + 0.02, pw, zh]);
            translate([r0, -pw / 2, z_c0])
                cube([r_thru, pw, z_ch]);
        }
    }
}

// ── Guard Holes ───────────────────────────────────────────────────
// Small holes through the outer wall into the tray cavity.
// Skip every tab_count-th hole from a fixed phase so three azimuths stay solid —
// same angles as the old reservoir skirt retention clips (no longer used).
module station_guard_holes() {
    hole_length = station_od / 2 - guard_hole_inner_r + 1;
    skip        = guard_hole_count / tab_count;
    skip_start  = round((360 / tab_count / 2) / (360 / guard_hole_count));

    for (i = [0 : guard_hole_count - 1])
        if ((i - skip_start) % skip != 0)
            rotate([0, 0, i * (360 / guard_hole_count)])
                translate([guard_hole_inner_r, 0, guard_hole_z])
                    rotate([0, 90, 0])
                        cylinder(h = hole_length, d = guard_hole_dia);
}

// ── Side Grip Scallops ───────────────────────────────────────────
// Oval indents on the outer wall for grip.
// Ellipsoid centered at station_scallop_z — natural taper stops
// smoothly before the bottom floor.
module station_side_scallops() {
    for (i = [0 : scallop_count - 1])
        rotate([0, 0, scallop_offset + i * (360 / scallop_count)])
            translate([station_od / 2, 0, station_scallop_z])
                scale([scallop_depth, scallop_width / 2, scallop_height / 2])
                    sphere(r = 1);
}

// ── Render ────────────────────────────────────────────────────────
crosssection(station_od) bait_station();
