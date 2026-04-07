// V2 Bait Station — Open tray with push-pin, flat floor, ant access holes.
// The reservoir drops inside; tabs slide into vertical slots and seat onto the pin.
// Ants access bait through small holes in the outer wall into the tray cavity.
// Outer + inner bait barrier rings; inner ring has holes and vertical rails + filler between them.

include <needle-insert-lib.scad>

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
        // Rails extend into needle pocket region; union after pocket so they are not subtracted.
        station_inner_barrier_rails();
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

// ── Inner Bait Barrier Ring ───────────────────────────────────────
// Same Z span as outer; 1″ OD, 1 mm wall; pin channels + six wall holes.
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
        }
}

// Six radial holes through inner barrier wall (needle channel size), flush with tray floor top.
module station_inner_barrier_wall_holes() {
    for (i = [0 : inner_bait_barrier_hole_count - 1])
        rotate([0, 0, i * (360 / inner_bait_barrier_hole_count)])
            translate([inner_bait_barrier_hole_start_r, 0, inner_bait_barrier_hole_z])
                rotate([0, 90, 0])
                    cylinder(h = inner_bait_barrier_hole_length, d = inner_bait_barrier_hole_dia);
}

// Two 1 mm-wide rails per site (tangential ±Y), 2 mm inward from inner barrier ID.
// Filler back plate between rails: radial slab from gasket land OD to barrier ID (upper-step annulus);
// needle clips sit on the land OD and flex inward — they do not occupy this outer radial gap.
module station_inner_barrier_rails() {
    w = inner_barrier_rail_width_mm;
    rin = inner_barrier_rail_inward_mm;
    yo = inner_barrier_rail_y_offset_mm;
    id2 = inner_bait_barrier_id / 2;
    z_top = bait_barrier_top_z - inner_barrier_rail_height_trim_mm + inner_barrier_rail_z_offset_mm;
    z_bot = station_floor - inner_barrier_rail_extend_below_floor_mm + inner_barrier_rail_z_offset_mm;
    zh = z_top - z_bot;
    zc = z_bot + zh / 2;
    // +X local = outward; rail occupies x in [id2 - rin, id2], centered at id2 - rin/2
    xc = id2 - rin / 2;
    for (i = [0 : inner_bait_barrier_hole_count - 1])
        rotate([0, 0, inner_barrier_rail_phase_deg + i * (360 / inner_bait_barrier_hole_count)]) {
            for (sgn = [-1, 1])
                translate([xc, sgn * yo, zc])
                    cube([rin, w, zh], center = true);
            nw = inner_barrier_rail_fill_width_mm;
            rf = inner_barrier_rail_fill_inward_mm;
            translate([id2 - rf / 2, 0, zc])
                cube([rf, nw, zh], center = true);
        }
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
