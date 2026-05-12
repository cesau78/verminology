// V2 Liquid Bait Station (clam shell) — Shared Parameters
// Rigid reservoir drops into an open tray bait station.
// Central push-pin engages the TPU needle seal in the reservoir floor.

// ── Performance Settings ──────────────────────────────────────────
// prototype: true → fast preview ($fn=32); false → production mesh ($fn=128).
// Export scripts override via -D prototype=<true|false> from build-config.json.
prototype = true;
crosssection_view = false;  // cut the model along a plane to inspect internals
crosssection_axis = "x";   // axis: "x", "y", or "z"
crosssection_pos  = 0;     // position (mm) along the chosen axis

$fn = prototype ? 32 : 128;

// ── General ───────────────────────────────────────────────────────
wall      = 2;     // shell wall thickness (mm)
clearance = 0.2;   // general fit clearance for mating parts (mm)

// ── Target print profile (layer-aligned deboss on bed-contact faces) ─
// Match your slicer: initial layer vs normal layers. Deboss depth is one
// nominal first-layer stack plus N full layers above — reads cleanly in
// preview layers without eating too much floor (keep < wall).
print_initial_layer_h = 0.2;   // first layer height (mm)
print_layer_h         = 0.16;  // layer height after first (mm)
print_deboss_layers_after_first = 3;  // full layers of depth past the first
reservoir_bottom_deboss_depth =
    print_initial_layer_h + print_deboss_layers_after_first * print_layer_h;
// e.g. 0.2 + 3×0.16 = 0.68 mm

// ── Reservoir ─────────────────────────────────────────────────────
// Base ODs below; `unit_od_reduction` shrinks reservoir + station together (skirt stays flush).
unit_od_reduction  = 13;   // mm off former 77 / 85 mm footprint (~½″ dia); set 0 for full-size
reservoir_od       = 77 - unit_od_reduction;      // mm — was 77 at reduction 0
reservoir_height   = 30;                          // total height (mm)
reservoir_id       = reservoir_od - wall * 2;     // 73mm internal diameter
reservoir_top_wall = 3;   // ceiling thickness (mm) — thicker than shell wall for puncture resistance
reservoir_cavity_h = reservoir_height - wall - reservoir_top_wall;
// Extra side-wall sleeve below z = 0 only (annulus OD–ID); skirt / cavity / floor unchanged.
reservoir_outer_wall_extension_below_mm = 3;
// Volume: π × 36.5² × cavity_h (slightly less with dome / features)

// ── Reservoir floor bore + TPU needle seal stack (valve_* shared with needle-seal.scad) ──
valve_disk_od  = 17;                        // disk outer diameter (mm)
valve_bore_id  = valve_disk_od;             // snug sliding fit — FDM shrinkage holds it
valve_disk_h   = wall;                      // same as floor thickness — flush inside
valve_flange_h  = 3;                        // flange height (mm) — extends past inner barrier for compression seal
valve_retainer_od = valve_disk_od + 1;       // top retention disk OD — just past bore edge
valve_retainer_id = valve_disk_od - 4;       // top retention disk ID — 2mm lip inward
valve_retainer_h  = valve_flange_h;          // same thickness as bottom flange

// ── Station ───────────────────────────────────────────────────────
station_od     = 85 - unit_od_reduction;   // mm — was 85 at reduction 0; keeps rim margin vs reservoir_od
station_floor  = 3;    // bottom plate thickness (mm)
station_id     = reservoir_od + clearance * 2;  // bore for reservoir

// Vertical gap: top of station floor slab (tray) to bottom of seated reservoir
tray_gap_below_reservoir = 11;  // mm — sized so M3×20 bolt tip is flush with nut pocket top
reservoir_seat           = station_floor + tray_gap_below_reservoir;
station_height   = 23;   // total station height (mm)

// ── Bait barrier ring (annulus in tray) ────────────────────────────
// difference( outer_cyl, inner_cyl ) — wall from tray floor up to reservoir bottom.
bait_barrier_radial_t = 3;   // radial wall thickness (mm) — matches inner barrier
bait_barrier_id       = 42.6;   // mm — inset so seal ring OD clears labyrinth outer tube by 1 mm
bait_barrier_od       = bait_barrier_id + 2 * bait_barrier_radial_t;
bait_barrier_bottom_z = station_floor;   // top of station floor slab
bait_barrier_top_z    = reservoir_seat;    // flush with bottom of seated reservoir
bait_barrier_squeeze  = 0.2;              // mm — axial compression target for TPU seals
bait_barrier_h        = (bait_barrier_top_z - bait_barrier_bottom_z)
                        - (valve_flange_h - bait_barrier_squeeze);  // shortened for seal compression

// Inner bait barrier — concentric annulus, same height as outer
inner_bait_barrier_od_in    = 1;   // outer diameter of this ring (inches) — bait-annulus side
inner_bait_barrier_od       = inner_bait_barrier_od_in * 25.4;   // 1.0 inch = 25.4 mm
inner_bait_barrier_radial_t = 3;   // mm — matches outer barrier
inner_bait_barrier_id       = inner_bait_barrier_od - 2 * inner_bait_barrier_radial_t;   // 25.4 − 6 = 19.4
inner_bait_valve_squeeze_z  = bait_barrier_squeeze;   // shared compression target
inner_bait_barrier_h        = bait_barrier_h;          // same height as outer barrier
valve_flange_od = inner_bait_barrier_od;  // bottom flange — same 1" OD as inner barrier

// Guard holes: through outer shell into tray, inset from bore ID
guard_hole_inner_r = station_id / 2 - 2;

// ── Push Pin / Straw (station center; engages TPU needle seal in reservoir floor) ─
pin_dia         = 6;   // pin outer diameter (mm)

// ── Needle Seal — TPU interference fit around pin ─
seal_hole_dia = pin_dia - 0;  // 6.0mm @ pin 6 — 0.0mm diametral, 0.00mm/side in TPU

pin_channel_dia = 3;   // internal fluid channel diameter (mm)
// Foil-piercing tip: frustum on outer surface only; bore stays straight. ~50–60° included angle is
// aggressive enough for foil yet printable; tiny land at apex (pin_tip_od > channel) avoids a zero-thickness point.
pin_tip_taper_h = 3;   // mm — length of outer taper from full pin_dia
pin_tip_od      = pin_channel_dia + 0.6;   // mm at apex (~0.3 mm wall each side for FDM)
// Lateral bore Z: prefer top tangent at seal flange; cap keeps tunnel from slicing down through base top (z = disk_h).
pin_tunnel_z_seal_align = reservoir_seat - valve_flange_h - pin_channel_dia / 2;
// Center height so bottom tangent ≈ station floor top — lateral sits in pin shank, not through floor.
pin_tunnel_z_max_center = station_floor + pin_channel_dia / 2;
pin_tunnel_z            = min(pin_tunnel_z_seal_align, pin_tunnel_z_max_center);
// Lateral bore: start past far side of pin OD; end inside inner bait barrier *center hole* ID (not outer bait ring).
pin_tunnel_face_inset    = 0.25;   // mm past outer pin surface (clean boolean)
pin_tunnel_barrier_inset = 1.2;    // mm inside inner barrier hole radius (shorten +X cut vs wall)
pin_tunnel_x_start       = -pin_dia / 2 - pin_tunnel_face_inset;
pin_tunnel_x_end         = inner_bait_barrier_id / 2 - pin_tunnel_barrier_inset;
pin_tunnel_reach         = pin_tunnel_x_end - pin_tunnel_x_start;
pin_tunnel_x_center      = (pin_tunnel_x_start + pin_tunnel_x_end) / 2;
// Axial channel: lowest z = bottom tangent of lateral (no bore below that through insert bed).
pin_channel_z_bottom     = pin_tunnel_z - pin_channel_dia / 2;

// Inner barrier — radial ports (same dia as needle / pin channel), flush with tray floor top
inner_bait_barrier_hole_count   = 6;
inner_bait_barrier_hole_dia     = pin_channel_dia;
inner_bait_barrier_hole_z       = station_floor + inner_bait_barrier_hole_dia / 2;  // lower tangent at z = station_floor
inner_bait_barrier_hole_start_r = inner_bait_barrier_id / 2 - 0.5;   // start slightly inside bore
inner_bait_barrier_hole_length  = inner_bait_barrier_radial_t + 1.0;  // through wall + margin

// ── Needle — Perpendicular Flow Hole ──────────────────────────────
// Side port replaces the open-top axial channel.  Bottom tangent of
// the hole aligns to the bottom of the 3rd seal ring (retention barb).
needle_flow_hole_dia      = pin_channel_dia;
needle_flow_hole_z_bottom = reservoir_seat + valve_disk_h;
needle_flow_hole_z_center = needle_flow_hole_z_bottom + needle_flow_hole_dia / 2;
needle_above_flow_hole    = 4;   // mm of solid pin above hole top — pushes stopper clear
pin_top = needle_flow_hole_z_bottom + needle_flow_hole_dia + needle_above_flow_hole;

// ── Flow Stopper — Compression Spring ──────────────────────────────
spring_od              = 4.4;    // outer diameter (mm)
spring_height          = 20;     // free length (mm)

// ── Flow Stopper — Stopper Piston ──────────────────────────────────
// Shank (`stopper_od`) sets spring housing ID; bottom sealing disk is wider.
stopper_od               = 7;                 // shank OD — slides in spring housing (mm)
stopper_bottom_disk_od   = 10;                // bottom face disk OD — wider than shank (mm)
stopper_bottom_disk_h    = 2;                 // solid disk height; spring bore only in shank (mm)
stopper_h                = 15;                // total height incl. bottom disk (mm)
stopper_bore_id          = 5;                 // spring bore — press-fit with barb (mm)
stopper_bore_depth       = 13;                // bore depth from top (mm)
stopper_clearance        = 0.3;               // per-side sliding clearance in housing (mm)

// ── Flow Stopper — Spring Housing (reservoir ceiling) ──────────────
spring_housing_id   = stopper_od + stopper_clearance * 2;
spring_housing_wall = 1.5;
spring_housing_od   = spring_housing_id + spring_housing_wall * 2;
// Locked: stopper bottom = (pin_top − reservoir_seat); housing lower rim is flush with that plane
// so the 10 mm collar sits in the opening and overlaps the housing wall (OD > collar > bore ID).
spring_housing_collar_axial_clearance_mm = 0;
spring_housing_bottom_clearance =
    (pin_top - reservoir_seat) - wall - spring_housing_collar_axial_clearance_mm;
spring_housing_ceiling_h = 4;         // solid ceiling plug inside bore — spring pushes against this
spring_socket_h  = 2;                 // twist-in spring retention socket depth (mm)
spring_socket_id = spring_od;         // socket bore matches spring OD for friction fit
spring_housing_h    = reservoir_cavity_h - spring_housing_bottom_clearance;
spring_housing_bore_h = spring_housing_h - spring_housing_ceiling_h;  // open bore height

// ── Guide Tabs (reservoir slides straight into station bore) ──────
// Three tabs on the reservoir outer wall drop into three vertical slots
// in the station bore.  No twist — reservoir drops straight in.
tab_count     = 2;     // one on each side (180° apart)
tab_w         = 3;     // tangential width (mm)
tab_d         = 1.5;   // radial protrusion beyond reservoir OD (mm)
tab_clearance = 0.2;   // per-side clearance in slot (mm)

// ── Guard Holes (ant access through outer wall into tray) ───────────
guard_hole_dia   = 3.2;  // hole diameter — ants only
guard_hole_count = 12;   // number around circumference
guard_hole_z     = station_floor + 1.5;  // just above flat floor, opens into tray cavity

// ── Seal Ring (TPU — snaps into reservoir floor, seals bait barrier top) ─
// Annular ring press-fits into a groove on the reservoir bottom face.
// When assembled, compresses against the outer bait barrier wall top edge,
// sealing dry side (ant access) from wet side (feeding area).
seal_ring_radial_w     = bait_barrier_radial_t;                         // wall thickness = barrier wall (3 mm)
seal_ring_center_d     = (bait_barrier_od + bait_barrier_id) / 2;     // barrier wall center line
seal_ring_od           = seal_ring_center_d + seal_ring_radial_w;
seal_ring_id           = seal_ring_center_d - seal_ring_radial_w;
seal_ring_groove_depth = wall / 2;                                     // half the reservoir floor thickness
seal_ring_h            = valve_flange_h + seal_ring_groove_depth;      // flange height + groove
seal_ring_protrusion   = seal_ring_h - seal_ring_groove_depth;         // = valve_flange_h below reservoir face

// ── Spill Reservoir (anti-spill catchment around spring housing) ─────
// Hollow cylinder surrounding the stopper chamber, divided into wedge
// compartments by radial walls.  Hangs from the cavity ceiling; catches
// liquid that would otherwise leak out when the station is inverted.
spill_reservoir_h        = spring_housing_h;                // flush with spring housing bottom (mm)
spill_reservoir_od       = 25;                             // outer diameter — clears labyrinth crossover (mm)
spill_reservoir_wall     = 1.5;                            // outer wall + divider thickness (mm)
spill_reservoir_sections = 6;                              // number of wedge compartments
spill_reservoir_floor   = 1;                               // bottom closure disk thickness (mm)

// ── Labyrinth Tubes (R-shaped sealed passages through reservoir) ─────
// Each tube bridges the outer bait barrier: entry on dry side (outside
// barrier), up through the reservoir cavity, across near the ceiling,
// back down to the wet side (inside barrier).  Liquid must flow uphill
// to escape — gravity prevents leaks at tilt angles.
labyrinth_count       = 6;
labyrinth_id          = guard_hole_dia;                               // passage diameter (mm)
labyrinth_wall_t      = 1.0;                                          // tube wall thickness (mm)
labyrinth_od          = labyrinth_id + 2 * labyrinth_wall_t;
labyrinth_outer_r     = reservoir_id / 2 - labyrinth_od / 2;          // flush with cavity wall
labyrinth_inner_r     = 13 + labyrinth_od / 2;                          // inner wall at 13mm from center
labyrinth_bend_z      = wall + reservoir_cavity_h;                          // V starts at cavity ceiling
labyrinth_angle_start = 0;                                             // first tube at 0°

// ── Floor Ribs (bridge support for upside-down printing) ─────────
// Full-height radial fins from floor to ceiling.  Thin (1 mm) for
// most of the height, flaring to a wider base at the floor for
// maximum bridge support.  Self-supporting when printed ceiling-down.
floor_rib_count       = 12;                                          // total ribs (every 30°)
floor_rib_t           = 1;                                           // shaft thickness for most of height (mm)
floor_rib_base_t      = 3;                                           // flared width at floor (mm)
floor_rib_flare_h     = 4;                                           // height of flare transition (mm)
floor_rib_r_inner     = valve_retainer_od / 2 + 1;                   // 10 mm — clears needle seal retainer
floor_rib_r_outer     = reservoir_id / 2;                            // end at cavity wall
floor_rib_angle_start = 360 / floor_rib_count / 2;                   // offset 15° to interleave with labyrinth tubes at 0°

// ── Reservoir Skirt (flush outer shell when assembled) ───────────
// Extends the reservoir OD to match station OD above the station rim.
// In reservoir-local coords, starts where the station wall ends.
skirt_od       = station_od;                                    // flush with station OD
skirt_id       = reservoir_id;                                  // 73mm — overlaps into reservoir wall to avoid gaps
skirt_z_start  = station_height - reservoir_seat;               // 9.8mm from reservoir bottom
skirt_height   = reservoir_height - skirt_z_start;              // 20.2mm — up to reservoir top

// ── Bolt Lock (M3 cap head + captive nut; prevents reservoir removal) ─
// Two captive-nut pockets on the reservoir underside at 90° and 270°
// (halfway between the two guide tabs).  Vertical M3x20 cap-head bolts
// come up through the station floor and thread into the captive nuts.
bolt_lock_count       = 2;     // pockets, 180° apart
bolt_lock_angle       = 90;    // first pocket angle (degrees); next at +180°
bolt_lock_r           = 29;    // hex pocket center radius from axis (mm)
bolt_lock_screw_dia   = 3.2;   // clearance hole — 1/8″, file-friendly (mm)
bolt_lock_head_dia    = 6.0;   // M3 cap-head OD + clearance (mm)
bolt_lock_nut_af      = 5.6;   // hex nut pocket across-flats + clearance (mm)
bolt_lock_nut_h       = 2.6;   // nut pocket height (Z) with clearance (mm)

// ── Strut Thickness (retained for bolt-lock seal prism taper) ────
strut_thickness = 1;   // mm — prism taper target width

// ── Side Grip Scallops (oval indents on outer wall) ──────────────
scallop_count   = 12;    // number around circumference
scallop_height  = 28;    // vertical span of each oval indent (mm)
scallop_width   = 8;     // tangential span — skinny egg shape (mm)
scallop_depth   = 1.5;   // radial depth of indent into wall (mm)
// Scallop center in assembled coordinates (z from station bottom)
scallop_center_z = (reservoir_seat + reservoir_height) / 2;  // midpoint of assembled height
// Per-part scallop center z
station_scallop_z   = scallop_center_z;                      // station starts at z=0
reservoir_scallop_z = scallop_center_z - reservoir_seat;      // reservoir-local coords
scallop_offset      = 360 / guard_hole_count / 2;            // half-step from ant holes

// ── Edge Fillet ──────────────────────────────────────────────────
fillet_r = 2;  // radius of rounded edge on exposed top/bottom faces (mm)

// ── Info stamp (bottom / bed face) ────────────────────────────────
// Lines and per-part flags: ../build-stamp.scad (product-level; export script writes it).
res_bottom_mark_size            = 6;    // line 1 (brand)
res_bottom_mark_size_secondary  = 4;    // line 2 (product)
res_bottom_mark_size_tertiary   = 3;    // line 3 (version) — matches orientation label
// Center-to-center spacing: lines 2–3 tight; lines 1–2 wider (rule sits halfway in that band).
res_bottom_mark_gap_2_3 =
    res_bottom_mark_size_secondary * 1.5;
res_bottom_mark_gap_extra_brand_to_product = 2.5; // extra mm between line 1 and line 2 vs 2–3
res_bottom_mark_gap_1_2 = res_bottom_mark_gap_2_3 + res_bottom_mark_gap_extra_brand_to_product;
// Rule under line 1: thickness tracks brand size (≈ bold "Y" stem); length from left edge of word to near final "y" tail.
// OpenSCAD 2021 has no textmetrics — advance is estimated from len × size × factor (tune for font/string).
res_bottom_mark_rule_adv_per_char   = 0.78;   // × line1 size → total width scale (Liberation Sans Bold)
res_bottom_mark_rule_stroke_scale   = 0.132;  // rule thickness = line1 size × this (match stem weight)
res_bottom_mark_rule_right_inset    = 0.40;   // × (adv/n_chars): shorten from right to meet "y" descender
// Shift whole stamp along +Y: fraction × part_od = distance from disc center toward rim (0.25 → mid-radius).
res_bottom_mark_radial_shift_fraction = 0;
res_bottom_mark_font     = "Liberation Sans:style=Bold";
// Oversized brand initial — Tektonology-style split where "V" is larger.
// V spans from the underline up to the "l" ascender.
res_bottom_mark_brand_initial  = "V";
res_bottom_mark_brand_rest     = "erminology";
res_bottom_mark_initial_size   = 8.6;            // oversized V em size (tune visually)
res_bottom_mark_initial_adv    = 0.8;           // advance factor for V (narrower than average char)
res_bottom_mark_cap_h_ratio    = 0.83;         // cap-height ÷ em-size (Liberation Sans Bold)
res_bottom_mark_descent_ratio  = 0.22;         // descender depth ÷ em-size
// Shift product stamp block upward so line 3 bottom sits at disc center.
res_bottom_mark_block_y_offset = 7;            // mm upward
// Orientation label — separate from the product stamp block.
res_bottom_mark_orient_text    = "DEPLOY THIS SIDE DOWN";
res_bottom_mark_orient_size    = 3;            // font size (mm)
res_bottom_mark_orient_y_frac  = -0.2;        // Y position as fraction of part_od (negative = toward bottom)

// ── QR Tag (per-unit inlay on reservoir top) ─────────────────────
// Square pocket on the reservoir top face accepts a press-fit QR tag
// printed in a contrasting color.  Tag is rendered separately per unit
// with a unique URL baked in (see qr-tag.scad + build scripts).
qr_tag_size      = 20;                              // outer dimension of tag square (mm)
qr_tag_depth     = reservoir_bottom_deboss_depth;   // pocket depth = deboss depth
qr_tag_clearance = 0.15;                            // per-side press-fit clearance (mm)
// Reservoir-specific: DEPLOY label top edge at disc center (Y=0).
// valign="center" puts glyph middle at orient_y; shift down by half the font size.
qr_tag_orient_y  = -(res_bottom_mark_orient_size / 2);
// Pocket center Y: below the DEPLOY label with a 1mm gap.
// Negated vs stamp frame because the pocket doesn't pass through
// the reservoir's mirror([1,0,0]) transform.
qr_tag_pocket_y  = -(qr_tag_orient_y
                    - res_bottom_mark_orient_size / 2   // bottom of DEPLOY text
                    - 4                                 // gap
                    - qr_tag_size / 2);                 // half the tag

include <../build-stamp.scad>

// Deboss up to three lines on exterior bottom (Z=0). part_od = flat OD; stamp shifted +Y toward mid-radius.
// Lines 1–3 from build-stamp.scad: brand, product, version (+ Prototype when preview).
module part_bottom_info_stamp_deboss(enable, part_od, orient_text_override=undef, show_version=true, orient_y_override=undef) {
    depth = reservoir_bottom_deboss_depth + 0.02;
    y1 = res_bottom_mark_gap_1_2;
    y2 = 0;
    y3 = -res_bottom_mark_gap_2_3;
    ys = [y1, y2, y3];
    stamp_shift_y = part_od * res_bottom_mark_radial_shift_fraction;
    has_any = info_stamp_line1 != "" || info_stamp_line2 != "" || info_stamp_line3 != "";
    actual_orient = is_undef(orient_text_override) ? res_bottom_mark_orient_text : orient_text_override;

    init_sz  = res_bottom_mark_initial_size;
    rest_sz  = res_bottom_mark_size;
    adv      = res_bottom_mark_rule_adv_per_char;
    cap_r    = res_bottom_mark_cap_h_ratio;
    desc_r   = res_bottom_mark_descent_ratio;

    // Drop V center below erminology center (tune so V bottom ≈ underline bottom)
    init_drop = -0.2;

    // Estimated advance widths for horizontal centering
    init_w   = len(res_bottom_mark_brand_initial) * init_sz * res_bottom_mark_initial_adv;
    rest_w   = len(res_bottom_mark_brand_rest)    * rest_sz * adv;
    brand_w  = init_w + rest_w;
    brand_x0 = -brand_w / 2 + 1.5;

    rule_t   = max(0.32, rest_sz * res_bottom_mark_rule_stroke_scale) + 0.05;

    // Underline bottom flush with "y" descender:
    // With valign="center" the baseline sits ≈ cap_r/2 below center,
    // then descender extends desc_r * size further.
    rule_bottom_y = ys[0] - (cap_r / 2 + desc_r) * rest_sz;
    rule_y        = rule_bottom_y + rule_t / 2;

    block_y = res_bottom_mark_block_y_offset;
    orient_y = is_undef(orient_y_override) ? part_od * res_bottom_mark_orient_y_frac : orient_y_override;

    if (enable && has_any) {
        rotate([0, 0, 90])
        translate([0, stamp_shift_y, -0.01])
            mirror([1, 0, 0]) {
                // ── Product stamp block (shifted up by block_y) ──
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
                if (show_version && info_stamp_line3 != "")
                    linear_extrude(depth)
                        translate([0, ys[2] + block_y, 0])
                            text(info_stamp_line3,
                                 size = res_bottom_mark_size_tertiary,
                                 font = res_bottom_mark_font,
                                 halign = "center",
                                 valign = "center");

                // ── Orientation label (independent position) ──
                if (actual_orient != "")
                    linear_extrude(depth)
                        translate([0, orient_y, 0])
                            text(actual_orient,
                                 size = res_bottom_mark_orient_size,
                                 font = res_bottom_mark_font,
                                 halign = "center",
                                 valign = "center");
            }
    }
}

// ── Utility Modules ───────────────────────────────────────────────

module render_if_needed() {
    if (!prototype) render() children();
    else children();
}

// Subtractive ring that rounds an outer cylinder edge.
// Place at z=0 for a bottom edge; mirror([0,0,1]) or translate
// to the top face for a top edge.
module edge_round(od, r) {
    render_if_needed()
        rotate_extrude()
            translate([od / 2 - r, 0])
                difference() {
                    square(r + 0.1);
                    translate([0, r])
                        circle(r = r);
                }
}

// Arc-shaped shell segment via rotate_extrude — lightweight CSG.
// Sweeps a rectangular cross-section (r_inner to r_outer) through
// ang degrees. Starts at +X, sweeps toward +Y.
// Rotate the result to center it or place at any angle.
module arc_shell(r_outer, r_inner, h, ang) {
    rotate([0, 0, -ang / 2])
        rotate_extrude(angle = ang)
            translate([r_inner, 0])
                square([r_outer - r_inner, h]);
}

// ── Thread Helix (shared by needle insert + station pocket) ───────
// 2D cross-section for a single-start square thread: polygon with one
// radial bump spanning half the circumference.  linear_extrude with
// twist traces the bump into a right-hand helix.
module thread_helix_2d(r_minor, depth) {
    r_major = r_minor + depth;
    n = max(64, $fn * 2);
    polygon([for (i = [0 : n - 1])
        let (a = i * 360 / n,
             in_tooth = (a <= 90 || a >= 270),
             r = in_tooth ? r_major : r_minor)
        [r * cos(a), r * sin(a)]
    ]);
}

module thread_helix(r_minor, depth, pitch, height) {
    n_turns = height / pitch;
    segs = max(32, ceil(n_turns * (prototype ? 32 : 96)));
    render_if_needed()
        linear_extrude(height = height, twist = -360 * n_turns,
                       slices = segs, convexity = 6)
            thread_helix_2d(r_minor, depth);
}

module crosssection(extent) {
    if (!crosssection_view) {
        children();
    } else {
        intersection() {
            children();
            hs = extent;
            if (crosssection_axis == "x")
                translate([crosssection_pos, -hs, -hs]) cube([hs*2, hs*2, hs*2]);
            if (crosssection_axis == "y")
                translate([-hs, crosssection_pos, -hs]) cube([hs*2, hs*2, hs*2]);
            if (crosssection_axis == "z")
                translate([-hs, -hs, crosssection_pos]) cube([hs*2, hs*2, hs*2]);
        }
    }
}
