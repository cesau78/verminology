// V2 Reservoir — Rigid flat cylinder that drops into the bait station.
// TPU slit valve press-fits flush into the floor (no flange, no lip).
// Bayonet lugs on the outer wall engage ramp-slots in the station bore.
// To fill: pop valve out from inside, fill through bore, press valve back in.

include <common.scad>

// ── Main Assembly ─────────────────────────────────────────────────
module reservoir() {
    difference() {
        reservoir_shell();
        reservoir_cavity();
        reservoir_valve_bore();
        reservoir_ant_tunnel_cutouts();
    }
    reservoir_bayonet_lugs();
    reservoir_struts();
    reservoir_ant_tunnels();
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
// Tight press-fit (0.6mm interference) — no flange, sits flush on both sides.
// The valve is pushed in from outside and held by friction alone.
module reservoir_valve_bore() {
    render_if_needed()
        translate([0, 0, -0.5])
            cylinder(h = wall + 1, d = valve_bore_id);
}

// ── Bayonet Lugs ──────────────────────────────────────────────────
// Tabs on the outer wall that engage the station's ramp-slots.
// Positioned near the bottom so they're inside the tray when seated.
module reservoir_bayonet_lugs() {
    for (i = [0 : bayonet_count - 1]) {
        angle = i * (360 / bayonet_count);
        rotate([0, 0, angle])
            translate([reservoir_od / 2, -bayonet_lug_w / 2, bayonet_lug_z])
                cube([bayonet_lug_d, bayonet_lug_w, bayonet_lug_h]);
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
                translate([strut_gap, -strut_thickness / 2, wall])
                    cube([strut_length, strut_thickness, reservoir_cavity_h]);
        }
}

// ── Ant Tunnels ───────────────────────────────────────────────────
// Half-pipe arches flush with the reservoir bottom, spanning radially
// from the outer groove to the inner groove over the hump.
// Flat face at z=0 (reservoir bottom), arch extends downward.
// Open at both ends so ants walk straight through.
module reservoir_ant_tunnels() {
    for (i = [0 : ant_tunnel_count - 1]) {
        angle = i * (360 / ant_tunnel_count);
        rotate([0, 0, angle])
            translate([torus_inner_r - torus_groove_dia / 2, 0, 0])
                rotate([0, 90, 0])
                    union() {
                        difference() {
                            // Outer half-cylinder — keep -X half, which
                            // after rotation becomes arch curving up into reservoir
                            intersection() {
                                cylinder(h = ant_tunnel_length, r = ant_tunnel_r_out);
                                translate([-ant_tunnel_r_out, -ant_tunnel_r_out, 0])
                                    cube([ant_tunnel_r_out, ant_tunnel_r_out * 2, ant_tunnel_length]);
                            }
                            // Inner cutout — passage for ants
                            cylinder(h = ant_tunnel_length, r = ant_tunnel_r_in);
                        }
                        // Half-disk cap on inner end to retain fluid
                        intersection() {
                            cylinder(h = wall, r = ant_tunnel_r_out);
                            translate([-ant_tunnel_r_out, -ant_tunnel_r_out, 0])
                                cube([ant_tunnel_r_out, ant_tunnel_r_out * 2, wall]);
                        }
                    }
    }
}

// ── Ant Tunnel Floor Cutouts ──────────────────────────────────────
// Cut the reservoir floor only where the tunnel is inside the cavity
// (up to the inner wall), so the outer wall stays solid.
module reservoir_ant_tunnel_cutouts() {
    cutout_length = reservoir_id / 2 - (torus_inner_r - torus_groove_dia / 2);
    for (i = [0 : ant_tunnel_count - 1]) {
        angle = i * (360 / ant_tunnel_count);
        rotate([0, 0, angle])
            translate([torus_inner_r - torus_groove_dia / 2, 0, -0.5])
                rotate([0, 90, 0])
                    cylinder(h = cutout_length, r = ant_tunnel_r_in);
    }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(reservoir_od) reservoir();
