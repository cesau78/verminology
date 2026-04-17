// Substrate Cutter — Assembly View
// Toggle `exploded` to switch between seated and exploded views.

include <common.scad>
use <grip.scad>
use <anvil.scad>

// ── Assembly Parameters ──────────────────────────────────────────
exploded            = true; // true = exploded view, false = assembled
substrate_thickness = 1;     // representative substrate gap (mm)
explode_gap         = 20;    // vertical spacing between parts in exploded view (mm)

// Grip slot face sits above the pocket floor by the substrate thickness.
rule_protrusion = rule_height - slot_depth;

// Z positions — assembled vs exploded
anvil_z = 0;
grip_z = exploded
    ? anvil_base_height + explode_gap * 2
    : pocket_floor_z + substrate_thickness;
rules_z = exploded
    ? grip_z - rule_protrusion
    : pocket_floor_z + substrate_thickness - rule_protrusion;

// ── Steel Rule Phantom ───────────────────────────────────────────
module steel_rule(od, id, h) {
    color("Silver", 0.5)
        difference() {
            cylinder(h = h, d = od);
            translate([0, 0, -0.01])
                cylinder(h = h + 0.02, d = id);
        }
}

// =====================================================================
// RENDERING
// =====================================================================
crosssection(anvil_dia) {
    // Anvil
    color("SteelBlue", 0.85)
        translate([0, 0, anvil_z])
            anvil();

    // Grip with both steel rules
    translate([0, 0, grip_z]) {
        color("CornflowerBlue", 0.85)
            substrate_cutter();
        translate([0, 0, -rule_protrusion]) {
            steel_rule(outer_rule_od, outer_rule_id, rule_height);
            steel_rule(inner_rule_od, inner_rule_id, rule_height);
        }
    }
}
