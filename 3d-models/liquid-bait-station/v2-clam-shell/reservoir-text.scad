// Reservoir Text Inlay — contrasting-color insert for the debossed
// text pockets on the reservoir top face.  Matches the geometry
// subtracted by part_bottom_info_stamp_deboss in reservoir.scad.
// No version line; orientation reads "DEPLOY THIS SIDE UP".

include <common.scad>

module reservoir_text_inlay() {
    depth = reservoir_bottom_deboss_depth;
    y1 = res_bottom_mark_gap_1_2;
    y2 = 0;
    y3 = -res_bottom_mark_gap_2_3;
    ys = [y1, y2, y3];
    stamp_shift_y = reservoir_od * res_bottom_mark_radial_shift_fraction;

    init_sz  = res_bottom_mark_initial_size;
    rest_sz  = res_bottom_mark_size;
    adv      = res_bottom_mark_rule_adv_per_char;

    init_drop = -0.2;

    init_w   = len(res_bottom_mark_brand_initial) * init_sz * res_bottom_mark_initial_adv;
    rest_w   = len(res_bottom_mark_brand_rest)    * rest_sz * adv;
    brand_w  = init_w + rest_w;
    brand_x0 = -brand_w / 2 + 1.5;

    rule_t   = max(0.32, rest_sz * res_bottom_mark_rule_stroke_scale) + 0.05;
    cap_r    = res_bottom_mark_cap_h_ratio;
    desc_r   = res_bottom_mark_descent_ratio;
    rule_bottom_y = ys[0] - (cap_r / 2 + desc_r) * rest_sz;
    rule_y        = rule_bottom_y + rule_t / 2;

    block_y  = res_bottom_mark_block_y_offset;
    orient_y = qr_tag_orient_y;

    translate([0, 0, reservoir_height])
        mirror([0, 0, 1])
            mirror([1, 0, 0])
                rotate([0, 0, 90])
                translate([0, stamp_shift_y, 0])
                    mirror([1, 0, 0]) {
                        if (info_stamp_line1 != "") {
                            linear_extrude(depth)
                                translate([brand_x0, ys[0] - init_drop + block_y, 0])
                                    text(res_bottom_mark_brand_initial,
                                         size = init_sz,
                                         font = res_bottom_mark_font,
                                         halign = "left",
                                         valign = "center");
                            linear_extrude(depth)
                                translate([brand_x0 + init_w, ys[0] + block_y, 0])
                                    text(res_bottom_mark_brand_rest,
                                         size = rest_sz,
                                         font = res_bottom_mark_font,
                                         halign = "left",
                                         valign = "center");
                        }
                        if (info_stamp_line1 != "" && info_stamp_line2 != "")
                            linear_extrude(depth) {
                                right_inset = rest_sz * adv * res_bottom_mark_rule_right_inset;
                                rule_left = brand_x0 + init_w;
                                rule_right = brand_x0 + brand_w - right_inset;
                                rule_w = (rule_right - rule_left) * 0.90;
                                translate([rule_left + rule_w / 2, rule_y + block_y, 0])
                                    square([rule_w, rule_t], center = true);
                            }
                        if (info_stamp_line2 != "")
                            linear_extrude(depth)
                                translate([0, ys[1] + block_y, 0])
                                    text(info_stamp_line2,
                                         size = res_bottom_mark_size_secondary,
                                         font = res_bottom_mark_font,
                                         halign = "center",
                                         valign = "center");
                        linear_extrude(depth)
                                translate([0, orient_y, 0])
                                    text("DEPLOY THIS SIDE UP",
                                         size = res_bottom_mark_orient_size,
                                         font = res_bottom_mark_font,
                                         halign = "center",
                                         valign = "center");
                    }
}

reservoir_text_inlay();
