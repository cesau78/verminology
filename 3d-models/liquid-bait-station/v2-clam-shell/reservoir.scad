// V2 Reservoir — Rigid flat cylinder that drops into the bait station.
// TPU needle seal press-fits flush into the floor (flange collar on the underside).
// Tabs on the outer wall slide into vertical slots in the station bore.
// To fill: pop seal out from inside, fill through bore, press seal back in.

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
                reservoir_vertical_wall_slots();
            }
            reservoir_vertical_land_outward_rib();
            reservoir_tabs();
            reservoir_ant_tunnels();
            reservoir_bottom_outward_barbs();
        }
        reservoir_side_scallops();
        reservoir_top_fillet();
    }
}

// ── Shell ─────────────────────────────────────────────────────────
// Main cylinder plus optional lower annulus (outer wall only — no skirt).
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
// Through-hole in the center of the floor for the TPU needle seal disk.
// Snug sliding fit — disk slides in and the wider flange collar
// sits on the outside of the floor, preventing push-through.
module reservoir_valve_bore() {
    render_if_needed()
        translate([0, 0, -0.5])
            cylinder(h = wall + 1, d = valve_bore_id);
}

// ── Tabs ──────────────────────────────────────────────────────────
// Guide tabs on the outer wall slide into the station's vertical slots.
// Positioned near the bottom so they're inside the tray when seated.
module reservoir_tabs() {
    for (i = [0 : tab_count - 1]) {
        angle = i * (360 / tab_count);
        rotate([0, 0, angle])
            // -0.01 radially to overlap into shell wall
            translate([reservoir_od / 2 - 0.01, -tab_w / 2, tab_z])
                cube([tab_d + 0.01, tab_w, tab_h]);
    }
}

// ── Bottom outward barbs ────────────────────────────────────────
// On the vertical wall ribbon (same azimuth as reservoir_vertical_wall_slots),
// not on guide tabs. Hull: ramped bottom, flat lip on top.
module reservoir_bottom_outward_barbs() {
    w    = bottom_barb_w_mm;
    h    = bottom_barb_h_mm;
    d    = bottom_barb_d_mm;
    root = bottom_barb_root_mm;
    z0   = bottom_barb_z0_mm;
    lip  = max(0.5, h * 0.22);
    ro   = reservoir_od / 2 + reservoir_vertical_land_radial_extension_mm;

    for (k = [0 : tab_count - 1]) {
        i = floor((k + 0.5) * ant_tunnel_count / tab_count);
        a = i * (360 / ant_tunnel_count);
        rotate([0, 0, a])
            translate([ro - root - 0.02, -w / 2, z0])
                hull() {
                    cube([root + 0.02, w, 0.35]);
                    translate([0, 0, h - lip])
                        cube([root + d + 0.02, w, lip]);
                }
    }
}

// ── Internal Struts ───────────────────────────────────────────────
// Radial struts from inner wall toward center, stopping short of the
// valve bore. Supports ceiling bridging and reduces slosh.
module reservoir_struts() {
    render_if_needed()
        for (i = [0 : strut_count - 1]) {
            angle = i * (360 / strut_count);
            strut_length = reservoir_id / 2 - strut_gap;
            rotate([0, 0, angle])
                // +0.01 radially into wall and vertically into ceiling
                // to avoid coincident faces
                translate([strut_gap, -strut_thickness / 2, wall])
                    cube([strut_length + 0.01, strut_thickness, reservoir_cavity_h + 0.01]);
        }
}

// ── Skirt ─────────────────────────────────────────────────────────
// Outer cylinder that extends the reservoir to station OD above the
// station rim. When locked, the skirt sits flush with the station
// wall — one consistent diameter for the whole assembled unit.
module reservoir_skirt() {
    render_if_needed()
        translate([0, 0, skirt_z_start])
            difference() {
                cylinder(h = skirt_height, d = skirt_od);
                cylinder(h = skirt_height, d = skirt_id);
            }
}

// ── Ant Tunnels ───────────────────────────────────────────────────
// Half-cone ramps on the reservoir bottom, spanning radially from
// just outside the valve retainer to the reservoir inner wall.
// Full arch height at the wall (cone base), tapering to flush with
// the floor at the retainer end (cone tip). Ants walk up the ramp.
module reservoir_ant_tunnels() {
    for (i = [0 : ant_tunnel_count - 1]) {
        angle = i * (360 / ant_tunnel_count);
        rotate([0, 0, angle])
            translate([ant_tunnel_start, 0, 0.01])
                rotate([0, 90, 0])
                    difference() {
                        // Outer half-cone — full radius at wall, floor-thickness
                        // diameter at retainer end
                        intersection() {
                            cylinder(h = ant_tunnel_length,
                                     r1 = 2, r2 = ant_tunnel_r_out);
                            translate([-ant_tunnel_r_out, -ant_tunnel_r_out, 0])
                                cube([ant_tunnel_r_out, ant_tunnel_r_out * 2,
                                      ant_tunnel_length]);
                        }
                        // Inner cone cutout — passage for ants
                        cylinder(h = ant_tunnel_length,
                                 r1 = 0, r2 = ant_tunnel_r_in);
                    }
    }
}

// ── Ant Tunnel Floor Cutouts ──────────────────────────────────────
// Conical cuts through the reservoir floor matching the tunnel passage.
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

// ── Vertical wall slots (between guide tabs) ────────────────────
// Three sites: 0.2 mm cuts each side of tangential land; see reservoir_vertical_land_outward_rib (+Z).
// Angles bisect adjacent guide tabs (60° / 180° / 300° for 3× tabs, 12× tunnels).
module reservoir_vertical_wall_slots() {
    land = reservoir_vertical_slot_land_mm;
    g    = reservoir_vertical_slot_gap_mm;
    h    = land / 2;
    ext  = reservoir_outer_wall_extension_below_mm;
    z0   = -ext - 0.01;
    zh   = skirt_z_start - z0 + 0.01;
    xd   = (reservoir_od - reservoir_id) / 2 + 0.04;
    x0   = reservoir_id / 2 - 0.02;

    for (k = [0 : tab_count - 1]) {
        i = floor((k + 0.5) * ant_tunnel_count / tab_count);
        angle = i * (360 / ant_tunnel_count);
        rotate([0, 0, angle]) {
            translate([x0, -h - g, z0])
                cube([xd, g, zh]);
            translate([x0, h, z0])
                cube([xd, g, zh]);
        }
    }
}

// ── Vertical land outward rib ───────────────────────────────────
// 1 mm (param) past nominal OD on the land strip only — tangential span = land width.
module reservoir_vertical_land_outward_rib() {
    land = reservoir_vertical_slot_land_mm;
    dx   = reservoir_vertical_land_radial_extension_mm;
    ext  = reservoir_outer_wall_extension_below_mm;
    z0   = -ext - 0.01;
    zh   = skirt_z_start - z0 + 0.01;

    for (k = [0 : tab_count - 1]) {
        i = floor((k + 0.5) * ant_tunnel_count / tab_count);
        a = i * (360 / ant_tunnel_count);
        rotate([0, 0, a])
            translate([reservoir_od / 2 - 0.02, -land / 2, z0])
                cube([dx + 0.02, land, zh]);
    }
}

// ── Side Grip Scallops ───────────────────────────────────────────
// Oval indents on the skirt outer wall for grip.
// Ellipsoid centered at reservoir_scallop_z — natural taper stops
// smoothly before the top ceiling.
module reservoir_side_scallops() {
    for (i = [0 : scallop_count - 1])
        rotate([0, 0, scallop_offset + i * (360 / scallop_count)])
            translate([skirt_od / 2, 0, reservoir_scallop_z])
                scale([scallop_depth, scallop_width / 2, scallop_height / 2])
                    sphere(r = 1);
}

// ── Top Edge Fillet ──────────────────────────────────────────────
// 2mm quarter-round on the top outer edge.
module reservoir_top_fillet() {
    translate([0, 0, reservoir_height])
        mirror([0, 0, 1])
            edge_round(skirt_od, fillet_r);
}

// ── Render ────────────────────────────────────────────────────────
crosssection(skirt_od) reservoir();
