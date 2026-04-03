// Needle insert library — include this (not `use`) so common.scad loads.
// F5 preview / STL: open needle-insert.scad or needle-insert-export.scad.
// Base OD = inner_bait_barrier_id − clearance; disk height = station_floor; OD groove via rotate_extrude.

include <common.scad>

// Side-facing circumferential groove (rectangular profile in r–z).
module needle_insert_gasket_groove_cutout() {
    zc = needle_gasket_groove_z_center;
    zw = needle_gasket_groove_width_z_mm;
    R = needle_insert_disk_od / 2;
    d = needle_gasket_groove_depth_mm;
    b = needle_gasket_groove_od_bleed_mm;
    render_if_needed()
        rotate_extrude(angle = 360, convexity = 4)
            polygon([
                [R - d, zc - zw / 2],
                [R + b, zc - zw / 2],
                [R + b, zc + zw / 2],
                [R - d, zc + zw / 2],
            ]);
}

// TPU torus: relaxed inner R < groove floor, outer R > base R. Centered on z=0; mate with translate(…, needle_gasket_assembly_z).
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

module needle_insert_channels() {
    translate([0, 0, -0.5])
        cylinder(h = pin_top + 1, d = pin_channel_dia);
    translate([pin_tunnel_x_center, 0, pin_tunnel_z])
        rotate([0, 90, 0])
            cylinder(h = pin_tunnel_reach, d = pin_channel_dia, center = true);
}

// Solid: base disk + hollow pin through pin_top (no bayonet tabs).
module needle_insert() {
    sh = pin_top - pin_tip_taper_h - needle_insert_disk_h;
    render_if_needed()
        difference() {
            union() {
                cylinder(h = needle_insert_disk_h, d = needle_insert_disk_od);
                translate([0, 0, needle_insert_disk_h]) {
                    cylinder(h = sh, d = pin_dia);
                    translate([0, 0, sh])
                        cylinder(h = pin_tip_taper_h, d1 = pin_dia, d2 = pin_tip_od);
                }
            }
            needle_insert_channels();
            needle_insert_gasket_groove_cutout();
        }
}

// Pocket: coaxial cylinder for base + pin bore (hole ID > insert OD by clearance).
module needle_insert_pocket() {
    c = needle_insert_pocket_clearance;
    dh = needle_insert_disk_h;
    ze = needle_insert_pocket_z_extra;
    r_disk = needle_insert_disk_od / 2 + c;
    translate([0, 0, -0.02])
        union() {
            cylinder(h = dh + 0.02 + ze, r = r_disk);
            translate([0, 0, dh])
                cylinder(h = pin_top - dh + 0.5 + ze, d = pin_dia + 2 * c);
        }
}
