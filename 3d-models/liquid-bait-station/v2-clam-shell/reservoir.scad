// V2 Reservoir — Rigid flat cylinder that drops into the bait station.
// Three guide tabs on the outer wall slide into vertical slots in the
// station bore.  Two captive M3 nuts on the underside (at 90° and 270°)
// accept vertical bolts through the station floor to lock it in place.
// TPU needle seal press-fits flush into the floor (flange collar on underside).

include <common.scad>

// ── Main Assembly ─────────────────────────────────────────────────
module reservoir() {
    difference() {
        union() {
            difference() {
                reservoir_shell();
                reservoir_cavity();
                reservoir_valve_bore();
            }
            reservoir_labyrinth_tubes();
            reservoir_skirt();
            reservoir_spring_housing();
            reservoir_spill_reservoir();
            reservoir_tabs();
            reservoir_bolt_lock_bosses();
            reservoir_bolt_lock_seal_prism();
        }
        reservoir_labyrinth_bores();
        reservoir_labyrinth_hull_clip();
        reservoir_seal_ring_groove();
        reservoir_bolt_lock_pocket();
        reservoir_side_scallops();
        reservoir_top_fillet();
    }
}

// ── Shell ─────────────────────────────────────────────────────────
module reservoir_shell() {
    ext = reservoir_outer_wall_extension_below_mm;
    render_if_needed()
        union() {
            cylinder(h = reservoir_height, d = reservoir_od);
            if (ext > 0)
                translate([0, 0, -ext])
                    difference() {
                        cylinder(h = ext, d = reservoir_od);
                        translate([0, 0, -0.01])
                            cylinder(h = ext + 0.02, d = reservoir_id);
                    }
        }
}

// ── Internal Cavity ───────────────────────────────────────────────
module reservoir_cavity() {
    render_if_needed()
        translate([0, 0, wall])
            cylinder(h = reservoir_cavity_h, d = reservoir_id);
}

// ── Valve Bore ────────────────────────────────────────────────────
module reservoir_valve_bore() {
    render_if_needed()
        translate([0, 0, -0.5])
            cylinder(h = wall + 1, d = valve_bore_id);
}

// ── Spring Housing ───────────────────────────────────────────────
// Hollow cylinder hanging from the reservoir ceiling.  The flow-stop
// spring and stopper piston ride inside.
module reservoir_spring_housing() {
    render_if_needed()
        translate([0, 0, wall + spring_housing_bottom_clearance])
            difference() {
                cylinder(h = spring_housing_h, d = spring_housing_od);
                translate([0, 0, -0.01])
                    cylinder(h = spring_housing_bore_h + 0.01, d = spring_housing_id);
            }
}

// ── Spill Reservoir ─────────────────────────────────────────────
// Pizza-wedge compartments around the spring housing, hanging from
// the cavity ceiling.  Outer cylinder wall + radial divider walls;
// the spring housing itself serves as the inner wall.
module reservoir_spill_reservoir() {
    z_bottom = wall + reservoir_cavity_h - spill_reservoir_h;
    r_outer  = spill_reservoir_od / 2;
    r_inner  = spring_housing_od / 2;
    render_if_needed()
        translate([0, 0, z_bottom]) {
            // Bottom floor disk
            difference() {
                cylinder(h = spill_reservoir_floor, d = spill_reservoir_od);
                translate([0, 0, -0.01])
                    cylinder(h = spill_reservoir_floor + 0.02, d = spring_housing_od);
            }
            // Outer cylindrical wall
            difference() {
                cylinder(h = spill_reservoir_h, d = spill_reservoir_od);
                translate([0, 0, -0.01])
                    cylinder(h = spill_reservoir_h + 0.02,
                             d = spill_reservoir_od - 2 * spill_reservoir_wall);
            }
            // Radial divider walls (staggered half-section from labyrinth tubes)
            for (i = [0 : spill_reservoir_sections - 1])
                rotate([0, 0, (360 / spill_reservoir_sections) / 2
                             + i * (360 / spill_reservoir_sections)])
                    translate([r_inner, -spill_reservoir_wall / 2, 0])
                        cube([r_outer - r_inner, spill_reservoir_wall,
                              spill_reservoir_h]);
        }
}

// ── Guide Tabs ────────────────────────────────────────────────────
module reservoir_tabs() {
    tab_h = skirt_z_start;
    for (i = [0 : tab_count - 1])
        rotate([0, 0, i * (360 / tab_count)])
            translate([reservoir_od / 2 - 0.01, -tab_w / 2, 0])
                cube([tab_d + 0.01, tab_w, tab_h]);
}

// ── Labyrinth Tube Shape (shared by shell and bore) ─────────────
// Outer leg → V leg 1 (down) → V leg 2 (into spill reservoir wall).
// Separate straight tube from feeding area to spill reservoir floor.
// Both passages meet inside the spill reservoir compartment.
// Parameter `d` selects OD (solid shell) or ID (passage bore).
module _labyrinth_tube_shape(d) {
    spill_r      = (spring_housing_od / 2
                    + spill_reservoir_od / 2 - spill_reservoir_wall) / 2;
    spill_z_bot  = wall + reservoir_cavity_h - spill_reservoir_h;
    spill_wall_r = spill_reservoir_od / 2 - spill_reservoir_wall / 2;
    vertex_r     = labyrinth_inner_r + labyrinth_od - labyrinth_wall_t;
    vertex_z     = wall + labyrinth_od / 2 - 0.5;
    v2_z         = vertex_z + (spill_wall_r - vertex_r) * spill_z_bot
                   / (spill_r - labyrinth_inner_r);

    // Outer vertical leg (full height to cavity ceiling)
    translate([labyrinth_outer_r, 0, -0.01])
        cylinder(h = labyrinth_bend_z + 0.01, d = d);

    // V leg 1: ceiling → vertex (flat cap keeps bore out of ceiling)
    hull() {
        translate([labyrinth_outer_r, 0, labyrinth_bend_z - d / 2])
            cylinder(h = d / 2, d = d);
        translate([vertex_r, 0, vertex_z])
            sphere(d = d);
    }
    // V leg 2: vertex → spill reservoir wall (parallel to straight tube)
    hull() {
        translate([vertex_r, 0, vertex_z])
            sphere(d = d);
        translate([spill_wall_r, 0, v2_z])
            sphere(d = d);
    }

    // Straight tube: feeding area (bottom face) → spill reservoir floor
    hull() {
        translate([labyrinth_inner_r + 2, 0, 0])
            sphere(d = d);
        translate([spill_r + 2, 0, spill_z_bot])
            sphere(d = d);
    }
}

// ── Labyrinth Tubes — Solid Outer Shells ─────────────────────────
module reservoir_labyrinth_tubes() {
    render_if_needed()
        for (i = [0 : labyrinth_count - 1])
            rotate([0, 0, labyrinth_angle_start + i * (360 / labyrinth_count)])
                _labyrinth_tube_shape(labyrinth_od);
}

// ── Labyrinth Tubes — Inner Bore Subtraction ─────────────────────
module reservoir_labyrinth_bores() {
    spill_r     = (spring_housing_od / 2
                   + spill_reservoir_od / 2 - spill_reservoir_wall) / 2;
    spill_z_bot = wall + reservoir_cavity_h - spill_reservoir_h;
    for (i = [0 : labyrinth_count - 1])
        rotate([0, 0, labyrinth_angle_start + i * (360 / labyrinth_count)]) {
            _labyrinth_tube_shape(labyrinth_id);
            // Bore punch-through: cut passage through spill reservoir floor
            translate([spill_r + 2, 0, spill_z_bot - 0.01])
                cylinder(h = spill_reservoir_floor + 0.02, d = labyrinth_id);
        }
}

// ── Labyrinth Hull Clip — trim sphere extensions at boundaries ────
// Hull-sphere endpoints on tube shells protrude past the reservoir
// floor (into the feeding area) and into the spill reservoir
// compartment interiors.  This subtraction clips both zones.
module reservoir_labyrinth_hull_clip() {
    // Below-floor clip: clear any solid within cavity ID below z = 0
    translate([0, 0, -reservoir_od])
        cylinder(h = reservoir_od, d = reservoir_id);

    // Spill reservoir compartment clip: annular void minus divider walls
    z_bottom  = wall + reservoir_cavity_h - spill_reservoir_h;
    r_wall_in = spill_reservoir_od / 2 - spill_reservoir_wall;
    r_inner   = spring_housing_od / 2;
    h_comp    = spill_reservoir_h - spill_reservoir_floor;

    translate([0, 0, z_bottom + spill_reservoir_floor])
        difference() {
            difference() {
                cylinder(h = h_comp, d = 2 * r_wall_in);
                translate([0, 0, -0.01])
                    cylinder(h = h_comp + 0.02, d = spring_housing_od + 0.2);
            }
            for (i = [0 : spill_reservoir_sections - 1])
                rotate([0, 0, (360 / spill_reservoir_sections) / 2
                             + i * (360 / spill_reservoir_sections)])
                    translate([r_inner - 0.01,
                               -(spill_reservoir_wall + 0.2) / 2,
                               -0.01])
                        cube([r_wall_in - r_inner + 0.02,
                              spill_reservoir_wall + 0.2,
                              h_comp + 0.02]);
        }
}

// ── Skirt ─────────────────────────────────────────────────────────
module reservoir_skirt() {
    render_if_needed()
        translate([0, 0, skirt_z_start])
            difference() {
                cylinder(h = skirt_height, d = skirt_od);
                cylinder(h = skirt_height, d = skirt_id);
            }
}

// ── Seal Ring Groove (annular press-fit channel on bottom face) ───
module reservoir_seal_ring_groove() {
    groove_od = seal_ring_od;
    groove_id = seal_ring_id;
    render_if_needed()
        translate([0, 0, -0.01])
            difference() {
                cylinder(h = seal_ring_groove_depth + 0.01, d = groove_od);
                translate([0, 0, -0.01])
                    cylinder(h = seal_ring_groove_depth + 0.03, d = groove_id);
            }
}

// ── Bolt Lock — Support Bosses ───────────────────────────────────
// Solid brackets at each captive-nut position.  Bridges the reservoir
// outer wall and floor so there is enough material around the hex
// pocket to hold the nut securely.
module reservoir_bolt_lock_bosses() {
    nut_ac  = bolt_lock_nut_af / cos(30);
    r_inner = bolt_lock_r - nut_ac / 2 - 1.5;
    boss_w  = nut_ac + 3;
    z_bot   = 0;
    h       = skirt_z_start;

    for (i = [0 : bolt_lock_count - 1]) {
        angle = bolt_lock_angle + i * (360 / bolt_lock_count);
        rotate([0, 0, angle])
            intersection() {
                translate([0, 0, z_bot])
                    difference() {
                        cylinder(h = h, d = reservoir_od);
                        cylinder(h = h, d = r_inner * 2);
                    }
                translate([0, -boss_w / 2, z_bot])
                    cube([reservoir_od, boss_w, h]);
            }
    }
}

// ── Bolt Lock — Nut Pocket Seal Prism ────────────────────────────
// Wedge atop each bolt-lock boss that seals the nut pocket ceiling
// from the fluid cavity.  Sides slope at 45° from the boss edges
// inward to the strut centerline — a printable overhang when the
// reservoir is printed upside-down.
module reservoir_bolt_lock_seal_prism() {
    nut_ac  = bolt_lock_nut_af / cos(30);
    r_inner = bolt_lock_r - nut_ac / 2 - 1.5;
    boss_w  = nut_ac + 3;
    prism_h = (boss_w - strut_thickness) / 2;
    span    = reservoir_od / 2 - r_inner;

    for (i = [0 : bolt_lock_count - 1]) {
        angle = bolt_lock_angle + i * (360 / bolt_lock_count);
        rotate([0, 0, angle])
            intersection() {
                cylinder(h = skirt_z_start + prism_h + 1, d = reservoir_od);
                hull() {
                    translate([r_inner, -boss_w / 2, skirt_z_start])
                        cube([span, boss_w, 0.01]);
                    translate([r_inner, -strut_thickness / 2, skirt_z_start + prism_h])
                        cube([span, strut_thickness, 0.01]);
                }
            }
    }
}

// ── Bolt Lock — Nut Pocket + Slide Slot ──────────────────────────
// Hex pocket captures the M3 nut and prevents spinning.  A rectangular
// slide slot from the reservoir OD surface lets the nut be pushed in
// radially; hex corners extend past the slot walls to retain the nut.
// A vertical clearance hole for the bolt shaft runs through the boss.
module reservoir_bolt_lock_pocket() {
    ext    = reservoir_outer_wall_extension_below_mm;
    nut_ac = bolt_lock_nut_af / cos(30);
    z_bot  = -ext;
    h      = ext + skirt_z_start;
    nut_z  = skirt_z_start - bolt_lock_nut_h;

    for (i = [0 : bolt_lock_count - 1]) {
        angle = bolt_lock_angle + i * (360 / bolt_lock_count);
        rotate([0, 0, angle]) {
            translate([bolt_lock_r, 0, 0]) {
                // Hex nut pocket — flat faces radially for captive fit
                translate([0, 0, nut_z])
                    rotate([0, 0, 30])
                        cylinder(h = bolt_lock_nut_h, d = nut_ac, $fn = 6);
                // Vertical bolt clearance hole (through boss only)
                translate([0, 0, z_bot - 0.01])
                    cylinder(h = h + 0.02, d = bolt_lock_screw_dia);
            }
            // Slide slot — nut enters from reservoir OD surface
            translate([bolt_lock_r, -bolt_lock_nut_af / 2, nut_z])
                cube([reservoir_od / 2 - bolt_lock_r + 0.5,
                      bolt_lock_nut_af,
                      bolt_lock_nut_h]);
        }
    }
}

// ── Side Grip Scallops ───────────────────────────────────────────
module reservoir_side_scallops() {
    for (i = [0 : scallop_count - 1])
        rotate([0, 0, scallop_offset + i * (360 / scallop_count)])
            translate([skirt_od / 2, 0, reservoir_scallop_z])
                scale([scallop_depth, scallop_width / 2, scallop_height / 2])
                    sphere(r = 1);
}

// ── Top Edge Fillet ──────────────────────────────────────────────
module reservoir_top_fillet() {
    translate([0, 0, reservoir_height])
        mirror([0, 0, 1])
            edge_round(skirt_od, fillet_r);
}

// ── Render ────────────────────────────────────────────────────────
crosssection(skirt_od) reservoir();
