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
    }
    reservoir_bayonet_lugs();
    reservoir_internal_ribs();
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

// ── Internal Ribs ─────────────────────────────────────────────────
// Cross-diameter ribs for print bridging support and anti-slosh.
module reservoir_internal_ribs() {
    render_if_needed()
        for (i = [0 : rib_count - 1]) {
            angle = i * (360 / rib_count);
            rotate([0, 0, angle])
                translate([-reservoir_id / 2, -rib_thickness / 2, wall])
                    cube([reservoir_id, rib_thickness, reservoir_cavity_h]);
        }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(reservoir_od) reservoir();
