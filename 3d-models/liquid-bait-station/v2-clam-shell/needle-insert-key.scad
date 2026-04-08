// Hex key tool for needle insert — print in PLA/PETG.
// The hex shaft engages the socket on the insert bottom face;
// the T-handle provides grip and torque.

include <common.scad>

key_hex_af       = needle_insert_hex_across_flats - 0.3;  // slight undersize for clearance
key_hex_length   = needle_insert_hex_depth - 0.2;         // don't bottom out
key_shaft_dia    = key_hex_af + 2;                        // round collar above hex
key_shaft_length = 4;                                     // grip transition
key_handle_dia   = 10;
key_handle_length = 30;
key_chamfer      = 0.4;

module needle_insert_key() {
    render_if_needed()
        union() {
            // Hex shaft (engages the insert socket)
            difference() {
                linear_extrude(height = key_hex_length)
                    circle(d = key_hex_af / cos(30), $fn = 6);
                // Lead-in chamfer on the tip
                translate([0, 0, -0.01])
                    cylinder(h = key_chamfer + 0.01,
                             d1 = key_hex_af / cos(30) + 1,
                             d2 = key_hex_af / cos(30) - 2 * key_chamfer);
            }
            // Round collar
            translate([0, 0, key_hex_length])
                cylinder(h = key_shaft_length, d = key_shaft_dia);
            // T-handle
            translate([0, 0, key_hex_length + key_shaft_length])
                union() {
                    // Cross-bar
                    translate([0, 0, key_handle_dia / 2])
                        rotate([0, 90, 0])
                            cylinder(h = key_handle_length, d = key_handle_dia, center = true);
                    // Fillet between shaft and cross-bar
                    cylinder(h = key_handle_dia / 2, d1 = key_shaft_dia, d2 = key_handle_dia);
                }
        }
}

crosssection(key_handle_length) needle_insert_key();
