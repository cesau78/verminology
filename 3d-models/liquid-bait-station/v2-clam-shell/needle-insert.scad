// Needle insert + gasket ring modules. Include this (not `use`) so common.scad loads.
// F5 / STL: open this file directly — draws needle_insert() unless needle_insert_as_library is true before include.
// Base: threaded bottom cylinder (2 mm) + smooth gasket land (1 mm).
// Hex socket on the bottom face requires a printed key to install/remove.

include <common.scad>

// TPU torus: relaxed inner R < upper step R, outer R > upper step R. Centered on z=0; mate with translate(…, needle_gasket_assembly_z).
module needle_gasket_ring() {
    ri = needle_gasket_relaxed_inner_r;
    ro = needle_gasket_relaxed_outer_r;
    hz = needle_gasket_relaxed_z_half;
    render_if_needed()
        rotate_extrude(angle = 360, convexity = 4)
            polygon([
                [ri, -hz],
                [ro, -hz],
                [ro, hz],
                [ri, hz],
            ]);
}

// Lower base step — thread root cylinder (thread teeth added separately).
module needle_insert_base_bottom_cylinder() {
    r_minor = needle_insert_base_bottom_od / 2 - needle_insert_thread_depth;
    cylinder(h = needle_insert_base_bottom_h, d = 2 * r_minor);
}

// External thread on the bottom base cylinder.
module needle_insert_external_thread() {
    r_minor = needle_insert_base_bottom_od / 2 - needle_insert_thread_depth;
    thread_helix(r_minor, needle_insert_thread_depth,
                 needle_insert_thread_pitch, needle_insert_base_bottom_h);
}

// Upper base step — second cylinder only (stacked on bottom).
module needle_insert_base_upper_cylinder() {
    translate([0, 0, needle_insert_base_bottom_h])
        cylinder(h = needle_insert_base_gasket_step_h, d = needle_insert_gasket_land_od);
}

// Hex socket subtracted from the bottom face (z=0).
module needle_insert_hex_socket() {
    af = needle_insert_hex_across_flats;
    dp = needle_insert_hex_depth;
    translate([0, 0, -0.01])
        linear_extrude(height = dp + 0.01)
            circle(d = af / cos(30), $fn = 6);
}

module needle_insert_channels() {
    // Vertical: from bottom of lateral port up (not through z=0 below lateral).
    vb = max(0, pin_channel_z_bottom);
    vh = pin_top + 0.5 - vb;
    translate([0, 0, vb])
        cylinder(h = vh, d = pin_channel_dia);
    translate([pin_tunnel_x_center, 0, pin_tunnel_z])
        rotate([0, 90, 0])
            cylinder(h = pin_tunnel_reach, d = pin_channel_dia, center = true);
}

// Solid: union(threaded base, gasket land, pin); channels + hex socket subtracted.
module needle_insert() {
    sh = pin_top - pin_tip_taper_h - needle_insert_disk_h;
    render_if_needed()
        difference() {
            union() {
                needle_insert_base_bottom_cylinder();
                needle_insert_external_thread();
                needle_insert_base_upper_cylinder();
                translate([0, 0, needle_insert_disk_h]) {
                    cylinder(h = sh, d = pin_dia);
                    translate([0, 0, sh])
                        cylinder(h = pin_tip_taper_h, d1 = pin_dia, d2 = pin_tip_od);
                }
            }
            needle_insert_channels();
            needle_insert_hex_socket();
        }
}

// Pocket subtracted from station floor: threaded bore + smooth gasket bore + pin bore.
// The threaded bore uses the same helix profile shifted outward by thread clearance;
// subtracting it from the station body creates matching internal threads.
module needle_insert_pocket() {
    c = needle_insert_pocket_clearance;
    ze = needle_insert_pocket_z_extra;
    tc = needle_insert_thread_clearance;
    r_minor_ext = needle_insert_base_bottom_od / 2 - needle_insert_thread_depth;
    depth = needle_insert_thread_depth;
    pitch = needle_insert_thread_pitch;
    h_thread = needle_insert_base_bottom_h;
    n_turns = h_thread / pitch;
    segs = max(32, ceil(n_turns * (mesh_preview ? 32 : 96)));

    translate([0, 0, -0.02])
        union() {
            // Threaded bore (z=0 to base_bottom_h): internal thread via subtraction
            render_if_needed()
                linear_extrude(height = h_thread + 0.02,
                               twist = -360 * n_turns,
                               slices = segs, convexity = 6)
                    thread_helix_2d(r_minor_ext + tc, depth);
            // Smooth bore for gasket land (base_bottom_h to station_floor)
            translate([0, 0, h_thread])
                cylinder(h = needle_insert_base_gasket_step_h + 0.02 + ze,
                         d = needle_insert_base_bottom_od + 2 * c);
            // Pin clearance bore (station_floor upward)
            translate([0, 0, needle_insert_disk_h])
                cylinder(h = pin_top - needle_insert_disk_h + 0.5 + ze,
                         d = pin_dia + 2 * c);
        }
}

if (is_undef(needle_insert_as_library) || !needle_insert_as_library)
    needle_insert();
