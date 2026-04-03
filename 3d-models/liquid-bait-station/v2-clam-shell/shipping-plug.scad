// Shipping Plug for V2 Liquid Bait Station — Print in TPU 90A
// Same dimensions as the slit valve but solid (no slits).
// Seals the reservoir for filling, transport, and storage.

include <common.scad>

module shipping_plug() {
    // Stop-collar flange
    difference() {
        cylinder(h = valve_flange_h, d = valve_flange_od);
        translate([0, 0, -0.5])
            cylinder(h = valve_flange_h + 1, d = pin_dia + 0.1);
    }

    // Solid disk — no slits
    translate([0, 0, valve_flange_h])
        cylinder(h = valve_disk_h, d = valve_disk_od);
}

// ── Render ────────────────────────────────────────────────────────
crosssection(valve_flange_od) shipping_plug();
