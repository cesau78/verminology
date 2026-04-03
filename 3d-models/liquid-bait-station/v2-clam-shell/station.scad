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
                    station_clip_grooves();
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
        // Rails + floor ring extend into needle pocket region; union after pocket so they are not subtracted.
        station_inner_barrier_rails();
        color("red")
            station_center_hole_floor_ring();
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
// Filler between rails: same vertical span. Top fixed below barrier top; bottom extends to needle-insert lip.
module station_inner_barrier_rails() {
    w = inner_barrier_rail_width_mm;
    rin = inner_barrier_rail_inward_mm;
    yo = inner_barrier_rail_y_offset_mm;
    id2 = inner_bait_barrier_id / 2;
    z_top = bait_barrier_top_z - inner_barrier_rail_height_trim_mm;
    z_bot = station_floor - inner_barrier_rail_extend_below_floor_mm;
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

// One notch per site between rails: hole-side only — 1 mm into ring solid; box reaches inward past ri for clean arc cut.
module station_center_hole_lip_guide_notches() {
    h = center_hole_floor_ring_h_mm;
    rin = center_hole_floor_ring_inward_mm;
    zb = station_floor - center_hole_floor_ring_below_floor_mm;
    ro = inner_bait_barrier_id / 2;
    ri = ro - rin;
    lip_in = center_hole_lip_notch_into_lip_mm;
    d_void = center_hole_lip_notch_into_void_mm;
    ov = center_hole_lip_notch_inner_overlap_mm;
    // Local +X outward: inner face of box at ri - d_void - ov (only ri..ri+lip_in overlaps ring solid).
    dr = lip_in + d_void + ov;
    xc = ri + (lip_in - d_void - ov) / 2;
    dz = h + center_hole_lip_notch_z_overshoot_mm;
    w = inner_barrier_rail_fill_width_mm + center_hole_lip_notch_tangent_extra_mm;
    zc = zb + h / 2;
    for (i = [0 : inner_bait_barrier_hole_count - 1])
        rotate([0, 0, inner_barrier_rail_phase_deg + i * (360 / inner_bait_barrier_hole_count)])
            translate([xc, 0, zc])
                cube([dr, w, dz], center = true);
}

// Annulus in floor: OD = inner barrier hole ID, inward 1 mm, 1 mm tall; one notch between rails per site on hole side.
module station_center_hole_floor_ring() {
    h = center_hole_floor_ring_h_mm;
    rin = center_hole_floor_ring_inward_mm;
    zb = station_floor - center_hole_floor_ring_below_floor_mm;
    ro = inner_bait_barrier_id / 2;
    ri = ro - rin;
    render_if_needed()
        difference() {
            translate([0, 0, zb])
                difference() {
                    cylinder(h = h, r = ro);
                    translate([0, 0, -0.01])
                        cylinder(h = h + 0.02, r = ri);
                }
            station_center_hole_lip_guide_notches();
        }
}

// ── Tab Slots ─────────────────────────────────────────────────────
// Straight vertical slots in the station bore wall. Reservoir tabs
// slide straight down — no twist required.
module station_tab_slots() {
    slot_w     = tab_w + clearance * 2;  // width with clearance
    slot_depth = tab_d + clearance + 1;  // radial depth (through inner wall)

    for (i = [0 : tab_count - 1]) {
        angle = i * (360 / tab_count);

        // Vertical slot — open at top, drops straight to seated height
        rotate([0, 0, angle])
            translate([station_id / 2 - 0.5, -slot_w / 2, tab_z_locked])
                cube([slot_depth, slot_w, station_height - tab_z_locked + 1]);
    }
}

// ── Retention Clip Grooves ────────────────────────────────────────
// Curved channels cut into the station's outer wall for the
// reservoir's retention clips to slide into. A deeper notch at the
// seated position lets the barb snap in. Offset 60° from tab slots.
module station_clip_grooves() {
    tab_offset = 360 / tab_count / 2;  // 60° from guide tabs
    groove_d   = clip_t + clearance;    // radial depth into outer wall
    groove_ang = (clip_w + clearance * 2) / (PI * station_od) * 360;
    // Notch: deeper pocket for the barb to snap into
    notch_d    = clip_t + clip_barb_d + clearance;
    notch_h    = clip_barb_h + clearance * 2;

    for (i = [0 : clip_count - 1]) {
        a = tab_offset + i * (360 / clip_count);
        rotate([0, 0, a]) {
            // Vertical groove — open at top, arc channel into outer wall
            translate([0, 0, clip_notch_z + notch_h])
                arc_shell(clip_r + 1, clip_r - groove_d,
                          station_height - clip_notch_z - notch_h + 1, groove_ang);
            // Snap notch — deeper arc pocket at the bottom for barb
            translate([0, 0, clip_notch_z])
                arc_shell(clip_r + 1, clip_r - notch_d,
                          notch_h, groove_ang);
        }
    }
}

// ── Guard Holes ───────────────────────────────────────────────────
// Small holes through the outer wall into the tray cavity.
module station_guard_holes() {
    hole_length = station_od / 2 - guard_hole_inner_r + 1;
    // Indices to skip: clip grooves at 60°, 180°, 300°
    // = indices 2, 6, 10 at 30° spacing (360/12)
    skip = guard_hole_count / clip_count;  // every 4th hole
    skip_start = round((360 / tab_count / 2) / (360 / guard_hole_count));  // index 2

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
