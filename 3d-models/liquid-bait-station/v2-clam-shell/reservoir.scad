// V2 Reservoir — Rigid flat cylinder that drops into the bait station.
// TPU slit valve press-fits flush into the floor (no flange, no lip).
// Tabs on the outer wall slide into vertical slots in the station bore.
// To fill: pop valve out from inside, fill through bore, press valve back in.

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
            reservoir_retention_clips();
        }
        reservoir_side_scallops();
        reservoir_top_fillet();
    }
}


// ── Shell ─────────────────────────────────────────────────────────
module reservoir_shell() {
    render_if_needed()
        cylinder(h = reservoir_height, d = reservoir_od);
}

// ── Internal Cavity ───────────────────────────────────────────────
module reservoir_cavity() {
    render_if_needed()
        translate([0, 0, wall])
            cylinder(h = reservoir_cavity_h, d = reservoir_id);
}

// ── Valve Bore ────────────────────────────────────────────────────
// Through-hole in the center of the floor for the TPU slit valve.
// Snug sliding fit — valve disk slides in and the wider flange collar
// sits on the outside of the floor, preventing push-through.
module reservoir_valve_bore() {
    render_if_needed()
        translate([0, 0, -0.5])
            cylinder(h = wall + 1, d = valve_bore_id);
}

// ── Tabs ──────────────────────────────────────────────────────────
// Tabs on the outer wall that slide into the station's vertical slots.
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

// ── Retention Clips ──────────────────────────────────────────────
// Flexible arms hanging down from the skirt inner face. Each arm
// has an inward-facing barb at the bottom: ramped on the bottom
// edge (slides in easily) and flat on top (resists pull-out).
// Offset 60° from guide tabs so they don't share slots.
module reservoir_retention_clips() {
    tab_offset = 360 / tab_count / 2;  // 60° offset from guide tabs
    for (i = [0 : clip_count - 1]) {
        a = tab_offset + i * (360 / clip_count);
        rotate([0, 0, a])
            translate([0, 0, skirt_z_start - clip_length]) {
                // Curved arm — arc shell flush with skirt OD
                arc_shell(clip_r, clip_r - clip_t, clip_length, clip_angle);
                // Barb — pointed D-shape: ramps out at 30° to max
                // protrusion at midpoint, mirrors back to arm thickness
                rotate([0, 0, -clip_angle / 2])
                    rotate_extrude(angle = clip_angle)
                        polygon([
                            [clip_r - clip_t, 0],
                            [clip_r - clip_t - clip_barb_d, clip_barb_h / 2],
                            [clip_r - clip_t, clip_barb_h]
                        ]);
            }
    }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(skirt_od) reservoir();
