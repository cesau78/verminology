// Substrate Cutter Tools — Shared Parameters & Utility Modules
// Two concentric steel-rule rings pressed through substrate material.
//
// Material: high-durability PLA

// ── Performance Settings ─────────────────────────────────────────
prototype = true;
crosssection_view = false;
crosssection_axis = "y";
crosssection_pos  = 0;

$fn = prototype ? 32 : 128;

// ── Steel Rule Dimensions ────────────────────────────────────────
// Outer ring
outer_rule_od = 50.9;   // outer diameter (mm)
outer_rule_id = 49.8;   // inner diameter (mm)
outer_rule_t  = 0.78;   // steel strip thickness (mm)
rule_height   = 23.8;   // height of both rules (mm)

// Inner ring
inner_rule_od = 25.8;
inner_rule_id = 24.4;
inner_rule_t  = 0.85;

// ── Slot Parameters ──────────────────────────────────────────────
slot_clearance = 0.12;  // radial clearance per side for snug PLA fit (mm)
slot_depth     = 10;    // embedding depth for rules (mm)
slot_chamfer   = 0.4;   // entry chamfer at slot opening (mm)

// ── Grip Parameters ──────────────────────────────────────────────
grip_height    = 35;    // height above slot base (mm)
grip_rounding  = 3;     // top-edge rounding radius on core (mm)
core_wall      = 3;     // material between outer slot and core surface (mm)

// ── Finger Ribs ──────────────────────────────────────────────────
rib_count    = 10;      // number of ribs around perimeter
rib_dia      = 12;      // diameter of each rib cylinder (mm)
rib_rounding = 2;       // edge rounding on each rib (mm)

// ── Anvil (Receiving Base) ───────────────────────────────────────
anvil_flange       = 10;    // radial overhang beyond pocket for stable base (mm)
anvil_base_height  = 10;    // total anvil body height (mm)
anvil_rounding     = 2;     // outer edge rounding radius (mm)
registration_depth = 3;     // centering pocket depth (mm)
registration_clearance = 0.3;  // radial clearance for grip fit (mm)
channel_width      = 2;     // relief channel width for rule travel (mm)
channel_depth      = 3;     // relief channel depth below pocket floor (mm)

// ── Derived ──────────────────────────────────────────────────────
total_height = slot_depth + grip_height;

outer_slot_or = outer_rule_od / 2 + slot_clearance;
outer_slot_ir = outer_rule_id / 2 - slot_clearance;
inner_slot_or = inner_rule_od / 2 + slot_clearance;
inner_slot_ir = inner_rule_id / 2 - slot_clearance;

core_dia = 2 * (outer_slot_or + core_wall);
rib_center_r = core_dia / 2;
grip_dia = core_dia + rib_dia;

pocket_dia = grip_dia + 2 * registration_clearance;
anvil_dia  = pocket_dia + 2 * anvil_flange;
pocket_floor_z = anvil_base_height - registration_depth;
outer_channel_mean_r = (outer_rule_od + outer_rule_id) / 4;
inner_channel_mean_r = (inner_rule_od + inner_rule_id) / 4;

echo(str("Core diameter: ", core_dia, " mm"));
echo(str("Grip diameter (envelope): ", grip_dia, " mm"));
echo(str("Core wall: ", core_wall, " mm"));
echo(str("Rule protrusion: ", rule_height - slot_depth, " mm"));
echo(str("Anvil diameter: ", anvil_dia, " mm"));
echo(str("Material below channels: ",
         pocket_floor_z - channel_depth, " mm"));

// =====================================================================
// UTILITY MODULES
// =====================================================================

// Subtractive torus for rounding an outer cylinder edge at z=0.
module edge_round(od, r) {
    rotate_extrude()
        translate([od / 2 - r, 0])
            difference() {
                square(r + 0.1);
                translate([0, r])
                    circle(r = r);
            }
}

// Cross-section viewer — intersects children with a half-space.
module crosssection(extent) {
    if (!crosssection_view) {
        children();
    } else {
        intersection() {
            children();
            hs = extent;
            if (crosssection_axis == "x")
                translate([crosssection_pos, -hs, -hs])
                    cube([hs * 2, hs * 2, hs * 2]);
            if (crosssection_axis == "y")
                translate([-hs, crosssection_pos, -hs])
                    cube([hs * 2, hs * 2, hs * 2]);
            if (crosssection_axis == "z")
                translate([-hs, -hs, crosssection_pos])
                    cube([hs * 2, hs * 2, hs * 2]);
        }
    }
}
