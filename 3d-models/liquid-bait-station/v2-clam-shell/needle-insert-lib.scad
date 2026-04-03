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

// Six flex posts on upper base step (gasket land OD); top barb: two ramps at needle_insert_clip_top_barb_slope_deg, extruded across w.
module needle_insert_retention_clip_top_barb(L, w, h_barb, apex_r) {
    hm = h_barb / 2;
    translate([0, w / 2, 0])
        rotate([90, 0, 0])
            linear_extrude(height = w, convexity = 4)
                polygon([
                    [0, 0],
                    [L, 0],
                    [L + apex_r, hm],
                    [L, h_barb],
                    [0, h_barb],
                ]);
}

module needle_insert_retention_clips() {
    R = needle_insert_gasket_land_od / 2;
    w = needle_insert_clip_tangent_width_mm;
    ad = needle_insert_clip_anchor_depth_mm;
    stem = needle_insert_clip_stem_radial_mm;
    L = ad + stem;
    h_barb = needle_insert_clip_top_barb_h_mm;
    apex_r = needle_insert_clip_top_barb_apex_radial_mm;
    z_step = needle_insert_base_bottom_h;
    z0 = needle_insert_clip_z0_above_gasket_step_mm;
    z_body_top = needle_insert_clip_body_z_top - z_step;
    for (i = [0 : needle_insert_clip_count - 1])
        rotate([0, 0, needle_insert_clip_phase_deg + i * (360 / needle_insert_clip_count)])
            render_if_needed()
                translate([0, 0, z_step])
                    union() {
                        translate([R - L, -w / 2, z0])
                            cube([L, w, z_body_top - z0]);
                        translate([R - L, 0, z_body_top])
                            needle_insert_retention_clip_top_barb(L, w, h_barb, apex_r);
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

// Pocket: max of (bottom OD, land + barb) + clearance — not id2+c+apex as extra (that oversize erased inner barrier ring).
// Capped below inner barrier ring OD so the subtract cannot hollow the full annulus (watertight wall).
module needle_insert_pocket() {
    c = needle_insert_pocket_clearance;
    ze = needle_insert_pocket_z_extra;
    r_body = needle_insert_base_bottom_od / 2 + c;
    r_barb = needle_insert_retention_clips_enabled
        ? needle_insert_gasket_land_od / 2 + needle_insert_clip_top_barb_apex_radial_mm + c
        : 0;
    r_need = max(r_body, r_barb);
    r_cap = inner_bait_barrier_od / 2 - needle_insert_pocket_inner_barrier_min_wall_mm;
    r_clip = min(r_need, r_cap);
    assert(r_need <= r_cap + 0.02, "needle pocket exceeds inner barrier OD cap — reduce barb apex or slope");
    z_barb = needle_insert_retention_clips_enabled ? needle_insert_clip_top_barb_h_mm : 0;
    z_clip_top = max(
        inner_barrier_rail_z_top + 0.08,
        needle_insert_clip_body_z_top + z_barb + needle_insert_pocket_z_above_clip_post_mm);
    translate([0, 0, -0.02])
        union() {
            cylinder(h = z_clip_top + 0.02 + ze, r = r_clip);
            translate([0, 0, z_clip_top])
                cylinder(h = pin_top - z_clip_top + 0.5 + ze, d = pin_dia + 2 * c);
        }
}
