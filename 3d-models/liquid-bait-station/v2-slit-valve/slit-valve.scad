// Slit Valve for V2 Liquid Bait Station — Print in TPU 90A (or 80A for easier flex)
// Slides into the reservoir bore; flange collar sits on the outside of the floor
// and prevents the valve from being pushed into the reservoir.
// Slits are touching at rest; the station's push-pin spreads them open.
// After printing, slits can be deepened with a razor blade if needed.

include <common.scad>

module slit_valve() {
    slit_valve_flange();
    slit_valve_disk();
}

// Stop-collar flange — wider cylinder that sits on the reservoir floor
// and prevents the valve from being pushed into the reservoir
module slit_valve_flange() {
    difference() {
        cylinder(h = valve_flange_h, d = valve_flange_od);
        // Pin clearance hole — 0.2mm larger radius than pin
        translate([0, 0, -0.5])
            cylinder(h = valve_flange_h + 1, d = pin_dia + 0.1);
    }
}

// Main disk — slides snugly into the reservoir bore
module slit_valve_disk() {
    difference() {
        translate([0, 0, valve_flange_h])
            cylinder(h = valve_disk_h, d = valve_disk_od);

        // X-shaped cross-slit through full disk thickness
        // Prints effectively closed at 0.2mm — pin forces petals apart
        for (angle = [0, 90])
            rotate([0, 0, angle])
                translate([-slit_length / 2, -slit_width / 2, valve_flange_h - 0.5])
                    cube([slit_length, slit_width, valve_disk_h + 1]);
    }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(valve_flange_od) slit_valve();
