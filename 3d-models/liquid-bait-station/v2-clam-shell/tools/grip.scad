// Substrate Cutter — Grip
// Finger-ribbed cylindrical grip with two concentric annular slots
// for press-fitting steel rule rings.
//
// Print orientation: slot face UP, grip base on build plate.

include <common.scad>

// =====================================================================
// MODULES
// =====================================================================

// Annular groove for one steel rule, opening at z=0 into +z.
module rule_slot(slot_or, slot_ir) {
    translate([0, 0, -0.01])
        difference() {
            cylinder(h = slot_depth + 0.01, r = slot_or);
            cylinder(h = slot_depth + 0.03, r = slot_ir);
        }
    // Entry chamfer — tapered mouth eases rule insertion
    translate([0, 0, -0.01])
        difference() {
            cylinder(h = slot_chamfer + 0.01,
                     r1 = slot_or + slot_chamfer,
                     r2 = slot_or);
            cylinder(h = slot_chamfer + 0.03,
                     r1 = slot_ir - slot_chamfer,
                     r2 = slot_ir);
        }
}

// Central core with rounded top edge.
module grip_core() {
    difference() {
        cylinder(h = total_height, d = core_dia);
        translate([0, 0, total_height])
            mirror([0, 0, 1])
                edge_round(core_dia, grip_rounding);
    }
}

// Rounded finger ribs — Minkowski-smoothed cylinders around the core.
module grip_ribs() {
    for (i = [0 : rib_count - 1]) {
        angle = i * 360 / rib_count;
        translate([rib_center_r * cos(angle),
                   rib_center_r * sin(angle),
                   rib_rounding])
            minkowski() {
                cylinder(h = total_height - 2 * rib_rounding,
                         d = rib_dia - 2 * rib_rounding);
                sphere(r = rib_rounding);
            }
    }
}

// Grip body — core plus rounded ribs.
module grip_body() {
    union() {
        grip_core();
        grip_ribs();
    }
}

// Full cutter assembly.
module substrate_cutter() {
    difference() {
        grip_body();
        rule_slot(outer_slot_or, outer_slot_ir);
        rule_slot(inner_slot_or, inner_slot_ir);
    }
}

// =====================================================================
// RENDERING
// =====================================================================
// Slot face at z=0; flipped so grip base is on build plate.
crosssection(grip_dia)
    translate([0, 0, total_height])
        rotate([180, 0, 0])
            substrate_cutter();
