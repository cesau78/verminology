// Needle insert library — include this (not `use`) so common.scad loads.
// F5 preview / STL: open needle-insert.scad or needle-insert-export.scad.
// Base: union of two cylinders — bottom 1 mm @ inner_bait_barrier_id, upper 2 mm @ bottom OD − 2 mm (diametric).

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

// Six flexible tabs: stem outer face flush with disk OD (R); only barb extends past R — enables insert + flex past bore.
module needle_insert_retention_clips() {
    R = needle_insert_base_bottom_od / 2;
    w = needle_insert_clip_tangent_width_mm;
    ad = needle_insert_clip_anchor_depth_mm;
    stem = needle_insert_clip_stem_radial_mm;
    br = needle_insert_clip_barb_radial_mm;
    bz = needle_insert_clip_barb_axial_mm;
    z0 = needle_insert_clip_z0;
    z_body_top = needle_insert_clip_body_z_top;
    z_barb_top = needle_insert_clip_barb_z_top;
    z_barb_bot = z_body_top - bz;
    for (i = [0 : needle_insert_clip_count - 1])
        rotate([0, 0, needle_insert_clip_phase_deg + i * (360 / needle_insert_clip_count)])
            render_if_needed()
                union() {
                    translate([R - ad - stem, -w / 2, z0])
                        cube([ad + stem, w, z_body_top - z0]);
                    translate([R, -w / 2, z_barb_bot])
                        cube([br, w, z_barb_top - z_barb_bot]);
                }
}

// Lower base step — plain cylinder only (no groove, no difference).
module needle_insert_base_bottom_cylinder() {
    cylinder(h = needle_insert_base_bottom_h, d = needle_insert_base_bottom_od);
}

// Upper base step — second cylinder only (stacked on bottom).
module needle_insert_base_upper_cylinder() {
    translate([0, 0, needle_insert_base_bottom_h])
        cylinder(h = needle_insert_base_gasket_step_h, d = needle_insert_gasket_land_od);
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

// Solid: union(two base cylinders, pin…); channels subtract through the stack.
module needle_insert() {
    sh = pin_top - pin_tip_taper_h - needle_insert_disk_h;
    render_if_needed()
        difference() {
            union() {
                needle_insert_base_bottom_cylinder();
                needle_insert_base_upper_cylinder();
                translate([0, 0, needle_insert_disk_h]) {
                    cylinder(h = sh, d = pin_dia);
                    translate([0, 0, sh])
                        cylinder(h = pin_tip_taper_h, d1 = pin_dia, d2 = pin_tip_od);
                }
                if (needle_insert_retention_clips_enabled)
                    needle_insert_retention_clips();
            }
            needle_insert_channels();
        }
}

// Pocket: disk OD + clearance; extra radial margin only when retention clips enabled.
module needle_insert_pocket() {
    c = needle_insert_pocket_clearance;
    ze = needle_insert_pocket_z_extra;
    r_extra = needle_insert_retention_clips_enabled ? needle_insert_clip_pocket_radial_extra_mm : 0;
    r_clip = needle_insert_base_bottom_od / 2 + c + r_extra;
    z_clip_top = inner_barrier_rail_z_top + 0.08;
    translate([0, 0, -0.02])
        union() {
            cylinder(h = z_clip_top + 0.02 + ze, r = r_clip);
            translate([0, 0, z_clip_top])
                cylinder(h = pin_top - z_clip_top + 0.5 + ze, d = pin_dia + 2 * c);
        }
}
