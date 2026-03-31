// Slit Valve for V2 Liquid Bait Station — Print in TPU 90A (or 80A for easier flex)
// Press-fits flush into the reservoir floor. No flange — sits flush for shipping.
// Slits are touching at rest; the station's push-pin spreads them open.
// After printing, slits can be deepened with a razor blade if needed.

include <common.scad>

module slit_valve() {
    difference() {
        // Solid disk — no flange, no lip
        cylinder(h = valve_disk_h, d = valve_disk_od);

        // X-shaped cross-slit through full thickness
        // Prints effectively closed at 0.2mm — pin forces petals apart
        for (angle = [0, 90])
            rotate([0, 0, angle])
                translate([-slit_length / 2, -slit_width / 2, -0.5])
                    cube([slit_length, slit_width, valve_disk_h + 1]);
    }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(valve_disk_od) slit_valve();
