// Substrate Cutter — Anvil
// Receiving base with registration pocket and relief channels.
// Substrate sits on the pocket floor; cutter presses rules through
// substrate into the channels.
//
// Print orientation: prints as oriented (pocket faces up).

include <common.scad>

// =====================================================================
// MODULES
// =====================================================================

// Annular relief channel centered on a rule's mean diameter.
module relief_channel(mean_r) {
    difference() {
        cylinder(h = channel_depth + 0.01,
                 r = mean_r + channel_width / 2);
        cylinder(h = channel_depth + 0.03,
                 r = mean_r - channel_width / 2);
    }
}

// Receiving anvil — pocket self-centers the cutter; channels accept
// rule tips during cutting.
module anvil() {
    difference() {
        cylinder(h = anvil_base_height, d = anvil_dia);
        // Registration pocket
        translate([0, 0, pocket_floor_z])
            cylinder(h = registration_depth + 0.01,
                     d = pocket_dia);
        // Relief channels cut into pocket floor
        translate([0, 0, pocket_floor_z - channel_depth])
            relief_channel(outer_channel_mean_r);
        translate([0, 0, pocket_floor_z - channel_depth])
            relief_channel(inner_channel_mean_r);
        // Round outer edges
        edge_round(anvil_dia, anvil_rounding);
        translate([0, 0, anvil_base_height])
            mirror([0, 0, 1])
                edge_round(anvil_dia, anvil_rounding);
    }
}

// =====================================================================
// RENDERING
// =====================================================================
crosssection(anvil_dia)
    anvil();
