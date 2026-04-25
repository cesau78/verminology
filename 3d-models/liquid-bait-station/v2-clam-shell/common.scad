// V2 Liquid Bait Station (clam shell) — Shared Parameters
// Rigid reservoir drops into an open tray bait station.
// Central push-pin engages the TPU needle seal in the reservoir floor.

// ── Performance Settings ──────────────────────────────────────────
// prototype: true → fast preview ($fn=32); false → production mesh ($fn=128).
// Export scripts override via -D prototype=<true|false> from build-config.json.
prototype = true;
crosssection_view = true;  // cut the model along a plane to inspect internals
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
valve_disk_od  = 16;                        // disk outer diameter (mm)
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
bait_barrier_id_in    = 2;   // inner clear diameter (inches)
bait_barrier_id       = bait_barrier_id_in * 25.4;   // 50.8 mm
bait_barrier_radial_t = 1;   // radial wall thickness (mm)
bait_barrier_od       = bait_barrier_id + 2 * bait_barrier_radial_t;
bait_barrier_bottom_z = station_floor;   // top of station floor slab
bait_barrier_top_z    = reservoir_seat;    // flush with bottom of seated reservoir
bait_barrier_h        = bait_barrier_top_z - bait_barrier_bottom_z;  // = tray_gap_below_reservoir

// Inner bait barrier — concentric annulus, shorter than outer; thick wall creates compression seal against TPU flange
inner_bait_barrier_od_in    = 1;   // outer diameter of this ring (inches) — bait-annulus side
inner_bait_barrier_od       = inner_bait_barrier_od_in * 25.4;   // 1.0 inch = 25.4 mm
inner_bait_barrier_radial_t = 4;   // mm — 2× prior 2 mm; ID follows from fixed OD
inner_bait_barrier_id       = inner_bait_barrier_od - 2 * inner_bait_barrier_radial_t;   // 25.4 − 8 = 17.4
// Shorter than outer barrier; Z overlap with TPU flange = valve_flange_h − this = inner_bait_valve_squeeze_z
inner_bait_valve_squeeze_z    = 0.2;   // mm — axial contact / crush target (inner barrier top vs flange bottom)
inner_bait_barrier_h_reduction = valve_flange_h - inner_bait_valve_squeeze_z;   // 2.8 @ valve_flange_h=3, squeeze=0.2
inner_bait_barrier_h = bait_barrier_h - inner_bait_barrier_h_reduction;
valve_flange_od = inner_bait_barrier_od;  // bottom flange — same 1" OD as inner barrier

// Guard holes: through outer shell into tray, inset from bore ID
guard_hole_inner_r = station_id / 2 - 2;

// ── Push Pin / Straw (station center; engages TPU needle seal in reservoir floor) ─
pin_dia         = 6;   // pin outer diameter (mm)

// ── Needle Seal — TPU interference fit around pin ─
seal_hole_dia = pin_dia - 0.3;  // 5.7mm — 0.15mm interference per side in TPU

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
stopper_od         = 7;                       // outer diameter (mm)
stopper_h          = 10;                      // total height (mm)
stopper_bore_id    = 5;                       // spring bore — press-fit with barb (mm)
stopper_bore_depth = 8;                       // bore depth from top (mm)
stopper_clearance  = 0.3;                     // per-side sliding clearance in housing (mm)

// ── Flow Stopper — Spring Housing (reservoir ceiling) ──────────────
spring_housing_id   = stopper_od + stopper_clearance * 2;
spring_housing_wall = 1.5;
spring_housing_od   = spring_housing_id + spring_housing_wall * 2;
spring_housing_bottom_clearance = 3;  // mm gap between housing and floor
spring_housing_ceiling_h = 4;         // solid ceiling plug inside bore — spring pushes against this
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

// ── Ant Tunnels (half-cone ramps from wall to valve retainer) ────
ant_tunnel_count  = guard_hole_count;              // one tunnel per guard hole
// Cone base radius sized so adjacent cones touch at the reservoir wall
ant_tunnel_r_out  = reservoir_id / 2 * sin(180 / ant_tunnel_count);  // ~9.4mm
ant_tunnel_r_in   = ant_tunnel_r_out - wall;       // passage radius (2mm wall)
ant_tunnel_start  = valve_retainer_od / 2 + 1;     // inner end radius from center (just outside retainer)
ant_tunnel_length = reservoir_id / 2 - ant_tunnel_start; // radial span: retainer edge to reservoir inner wall

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

// ── Internal Struts (reservoir ceiling bridging + anti-slosh) ─────
strut_count     = ant_tunnel_count;  // one strut per tunnel, aligned
strut_thickness = 1;   // strut wall thickness (mm)
strut_gap       = valve_bore_id / 2 + 2;  // stop short of valve bore center

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
res_bottom_mark_size_secondary  = 4;    // lines 2–3 (product, version)
// Center-to-center spacing: lines 2–3 tight; lines 1–2 wider (rule sits halfway in that band).
res_bottom_mark_gap_2_3 =
    res_bottom_mark_size_secondary * 1.25;
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

include <../build-stamp.scad>

// Deboss up to three lines on exterior bottom (Z=0). part_od = flat OD; stamp shifted +Y toward mid-radius.
// Lines 1–3 from build-stamp.scad: brand, product, version (+ Prototype when preview).
module part_bottom_info_stamp_deboss(enable, part_od) {
    depth = reservoir_bottom_deboss_depth + 0.02;
    y1 = res_bottom_mark_gap_1_2;
    y2 = 0;
    y3 = -res_bottom_mark_gap_2_3;
    ys = [y1, y2, y3];
    stamp_shift_y = part_od * res_bottom_mark_radial_shift_fraction;
    has_any = info_stamp_line1 != "" || info_stamp_line2 != "" || info_stamp_line3 != "";
    if (enable && has_any) {
        rotate([0, 0, 90])
        translate([0, stamp_shift_y, -0.01])
            mirror([1, 0, 0]) {
                if (info_stamp_line1 != "")
                    linear_extrude(depth)
                        translate([0, ys[0], 0])
                            text(info_stamp_line1,
                                 size = res_bottom_mark_size,
                                 font = res_bottom_mark_font,
                                 halign = "center",
                                 valign = "center");
                if (info_stamp_line1 != "" && info_stamp_line2 != "")
                    linear_extrude(depth)
                        translate([0, y1 / 2, 0])
                            let (
                                nch = max(len(info_stamp_line1), 1),
                                adv = len(info_stamp_line1) * res_bottom_mark_size *
                                    res_bottom_mark_rule_adv_per_char,
                                cw = adv / nch,
                                rule_t = max(0.32, res_bottom_mark_size * res_bottom_mark_rule_stroke_scale),
                                x0 = -adv / 2,
                                x1 = adv / 2 - cw * res_bottom_mark_rule_right_inset
                            )
                                if (x1 > x0 + 1)
                                    translate([(x0 + x1) / 2, 0, 0])
                                        square([x1 - x0, rule_t], center = true);
                if (info_stamp_line2 != "")
                    linear_extrude(depth)
                        translate([0, ys[1], 0])
                            text(info_stamp_line2,
                                 size = res_bottom_mark_size_secondary,
                                 font = res_bottom_mark_font,
                                 halign = "center",
                                 valign = "center");
                if (info_stamp_line3 != "")
                    linear_extrude(depth)
                        translate([0, ys[2], 0])
                            text(info_stamp_line3,
                                 size = res_bottom_mark_size_secondary,
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
