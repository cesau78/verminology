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
                union() {
                    difference() {
                        reservoir_shell();
                        reservoir_cavity();
                        reservoir_valve_bore();
                    }
                    reservoir_struts();
                    reservoir_skirt();
                }
                reservoir_ant_tunnel_cutouts();
            }
            reservoir_tabs();
            reservoir_ant_tunnels();
            reservoir_bolt_lock_bosses();
        }
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

// ── Guide Tabs ────────────────────────────────────────────────────
module reservoir_tabs() {
    tab_h = skirt_z_start;
    for (i = [0 : tab_count - 1])
        rotate([0, 0, i * (360 / tab_count)])
            translate([reservoir_od / 2 - 0.01, -tab_w / 2, 0])
                cube([tab_d + 0.01, tab_w, tab_h]);
}

// ── Internal Struts ───────────────────────────────────────────────
module reservoir_struts() {
    render_if_needed()
        for (i = [0 : strut_count - 1]) {
            angle = i * (360 / strut_count);
            strut_length = reservoir_id / 2 - strut_gap;
            rotate([0, 0, angle])
                translate([strut_gap, -strut_thickness / 2, wall])
                    cube([strut_length + 0.01, strut_thickness, reservoir_cavity_h + 0.01]);
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

// ── Ant Tunnels ───────────────────────────────────────────────────
module reservoir_ant_tunnels() {
    for (i = [0 : ant_tunnel_count - 1]) {
        angle = i * (360 / ant_tunnel_count);
        rotate([0, 0, angle])
            translate([ant_tunnel_start, 0, 0.01])
                rotate([0, 90, 0])
                    difference() {
                        intersection() {
                            cylinder(h = ant_tunnel_length,
                                     r1 = 2, r2 = ant_tunnel_r_out);
                            translate([-ant_tunnel_r_out, -ant_tunnel_r_out, 0])
                                cube([ant_tunnel_r_out, ant_tunnel_r_out * 2,
                                      ant_tunnel_length]);
                        }
                        cylinder(h = ant_tunnel_length,
                                 r1 = 0, r2 = ant_tunnel_r_in);
                    }
    }
}

// ── Ant Tunnel Floor Cutouts ──────────────────────────────────────
module reservoir_ant_tunnel_cutouts() {
    for (i = [0 : ant_tunnel_count - 1]) {
        angle = i * (360 / ant_tunnel_count);
        rotate([0, 0, angle])
            translate([ant_tunnel_start, 0, -0.5])
                rotate([0, 90, 0])
                    cylinder(h = ant_tunnel_length,
                             r1 = 0, r2 = ant_tunnel_r_in);
    }
}

// ── Bolt Lock — Support Bosses ───────────────────────────────────
// Solid brackets at each captive-nut position.  Bridges the reservoir
// outer wall and floor so there is enough material around the hex
// pocket to hold the nut securely.
module reservoir_bolt_lock_bosses() {
    ext     = reservoir_outer_wall_extension_below_mm;
    nut_ac  = bolt_lock_nut_af / cos(30);
    r_inner = bolt_lock_r - nut_ac / 2 - 1.5;
    boss_w  = nut_ac + 3;
    z_bot   = -ext;
    h       = ext + skirt_z_start;

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
