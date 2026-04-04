// Needle Seal for V2 Liquid Bait Station — Print in TPU 90A (or 80A for easier flex)
// Center hole is undersized vs the pin for a water-tight interference fit; TPU stretches over the pin.

include <common.scad>

module needle_seal() {
    needle_seal_flange();
    needle_seal_disk();
    needle_seal_barb();
}

// Stop-collar flange — wider cylinder that sits on the reservoir floor
// and prevents the seal from being pushed into the reservoir.
// Clearance hole here — sealing happens at the disk.
module needle_seal_flange() {
    difference() {
        cylinder(h = valve_flange_h, d = valve_flange_od);
        translate([0, 0, -0.5])
            cylinder(h = valve_flange_h + 1, d = pin_dia + 0.1);
    }
}

// Main disk — slides snugly into the reservoir bore.
// Center hole provides the water-tight seal around the pin.
module needle_seal_disk() {
    difference() {
        translate([0, 0, valve_flange_h])
            cylinder(h = valve_disk_h, d = valve_disk_od);

        // Seal hole — undersized for interference fit in TPU
        translate([0, 0, valve_flange_h - 0.5])
            cylinder(h = valve_disk_h + 1, d = seal_hole_dia);
    }
}

// ── Top Retention Disk ────────────────────────────────────────────
// Thin ring catches on the inside of the reservoir floor to prevent pull-out.
module needle_seal_barb() {
    taper_inset = valve_retainer_h * tan(30) * 2;
    translate([0, 0, valve_flange_h + valve_disk_h])
        difference() {
            cylinder(h = valve_retainer_h,
                     d1 = valve_retainer_od,
                     d2 = valve_retainer_od - taper_inset);
            translate([0, 0, -0.5])
                cylinder(h = valve_retainer_h + 1, d = valve_retainer_id);
            // Flow slots for fluid passage
            for (i = [0 : 3])
                rotate([0, 0, i * 90 + 45])
                    translate([-1, -valve_retainer_od / 2, -0.5])
                        cube([2, valve_retainer_od, valve_retainer_h + 1]);
        }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(valve_flange_od) needle_seal();
