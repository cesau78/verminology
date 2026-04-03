// Needle insert library — include this (not `use`) so common.scad loads.
// F5 preview / STL: open needle-insert.scad or needle-insert-export.scad.
// Base disk OD = inner_bait_barrier_id (center tray hole); disk height = station floor.

include <common.scad>

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
        }
}

// Pocket: coaxial cylinder for base + pin bore; inner barrier hole ID = needle_insert_disk_od.
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
