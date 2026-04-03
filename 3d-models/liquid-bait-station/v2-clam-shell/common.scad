// V2 Slit-Valve Liquid Bait Station — Shared Parameters
// Rigid reservoir drops into an open tray bait station.
// A central push-pin spreads the TPU slit valve open when reservoir is seated.

// ── Performance Settings ──────────────────────────────────────────
// mesh_preview: fast low-$fn for interactive editing (export scripts pass mesh_preview=false for STLs).
mesh_preview = true;
crosssection_view = true;  // cut the model along a plane to inspect internals
crosssection_axis = "y";   // axis: "x", "y", or "z"
crosssection_pos  = 0;     // position (mm) along the chosen axis

$fn = mesh_preview ? 32 : 64;

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
// Volume: π × 36.5² × cavity_h (slightly less with dome / features)

// ── TPU Slit Valve ────────────────────────────────────────────────
valve_disk_od  = 16;                        // disk outer diameter (mm)
valve_bore_id  = valve_disk_od;             // snug sliding fit — FDM shrinkage holds it
valve_disk_h   = wall;                      // same as floor thickness — flush inside
valve_flange_od = valve_disk_od + 4;        // flange: 2mm larger radius — stop collar
valve_flange_h  = 2;                        // flange height (mm) — prevents push-through
valve_retainer_od = valve_disk_od + 1;       // top retention disk OD — just past bore edge
valve_retainer_id = valve_disk_od - 4;       // top retention disk ID — 2mm lip inward
valve_retainer_h  = valve_flange_h;          // same thickness as bottom flange
// Needle insert base: bottom ring at inner barrier hole ID; upper step OD = bottom OD − 2 mm (diametric).
slit_width    = 0.2;  // effectively touching — prints closed, pin forces open
slit_length   = 10;   // each arm of the X-slit (mm)

// ── Station ───────────────────────────────────────────────────────
station_od     = 85 - unit_od_reduction;   // mm — was 85 at reduction 0; keeps rim margin vs reservoir_od
station_floor  = 3;    // bottom plate thickness (mm)
// Needle base: bottom segment = central hole ID; upper segment = gasket land OD (must sum to station_floor).
needle_insert_base_bottom_h      = 1;   // mm — coaxial with inner barrier center hole ID
needle_insert_base_gasket_step_h = 2;   // mm — upper base step (smaller OD); TPU ring sits here
needle_insert_disk_h = needle_insert_base_bottom_h + needle_insert_base_gasket_step_h;
assert(needle_insert_disk_h == station_floor, "needle base segment heights must sum to station_floor");
needle_insert_pocket_clearance = 0.25;       // radial/press fit vs station pocket
needle_insert_pocket_z_extra   = 0.1;        // extend pocket subtractor in +Z (boolean margin)
needle_insert_retention_clips_enabled = false; // true: union clips + widen pocket for barbs
station_id     = reservoir_od + clearance * 2;  // bore for reservoir

// Vertical gap: top of station floor slab (tray) to bottom of seated reservoir
tray_gap_below_reservoir = 6;   // mm (~0.236 in)
reservoir_seat           = station_floor + tray_gap_below_reservoir;
station_height   = 18;   // total station height (mm)

// ── Bait barrier ring (annulus in tray) ────────────────────────────
// difference( outer_cyl, inner_cyl ) — wall from tray floor up to reservoir bottom.
bait_barrier_id_in    = 2;   // inner clear diameter (inches)
bait_barrier_id       = bait_barrier_id_in * 25.4;   // 50.8 mm
bait_barrier_radial_t = 1;   // radial wall thickness (mm)
bait_barrier_od       = bait_barrier_id + 2 * bait_barrier_radial_t;
bait_barrier_bottom_z = station_floor;   // top of station floor slab
bait_barrier_top_z    = reservoir_seat;    // flush with bottom of seated reservoir
bait_barrier_h        = bait_barrier_top_z - bait_barrier_bottom_z;  // = tray_gap_below_reservoir

// Inner bait barrier — concentric annulus, same height as outer; pin channels cut through (lateral bore crosses wall)
inner_bait_barrier_od_in    = 1;   // outer diameter (inches)
inner_bait_barrier_od       = inner_bait_barrier_od_in * 25.4;
inner_bait_barrier_radial_t = 1;   // wall thickness (mm)
inner_bait_barrier_id       = inner_bait_barrier_od - 2 * inner_bait_barrier_radial_t;
needle_insert_disk_od_clearance_dia = 0.2;   // reference for TPU relaxed outer R vs hole ID (diametric mm)
needle_insert_base_bottom_od = inner_bait_barrier_id;   // bottom 1 mm — matches station central hole ID
needle_insert_top_vs_bottom_od_delta_dia = 2;   // upper step OD = bottom OD − this (mm, diameter)
needle_insert_gasket_land_od = needle_insert_base_bottom_od - needle_insert_top_vs_bottom_od_delta_dia;
// Legacy name: upper-step OD (gasket land); used by TPU ring math and older includes.
needle_insert_disk_od        = needle_insert_gasket_land_od;

// Guard holes: through outer shell into tray, inset from bore ID
guard_hole_inner_r = station_id / 2 - 2;

// ── Push Pin / Straw (station center, spreads slit valve / engages needle seal) ─
pin_dia         = 6;   // pin outer diameter (mm) — smaller than slit_length for proper spread

// ── Needle Seal (slit-free variant — TPU interference fit around pin) ─
seal_hole_dia = pin_dia - 0.3;  // 5.7mm — 0.15mm interference per side in TPU

pin_channel_dia = 3;   // internal fluid channel diameter (mm)
// Foil-piercing tip: frustum on outer surface only; bore stays straight. ~50–60° included angle is
// aggressive enough for foil yet printable; tiny land at apex (pin_tip_od > channel) avoids a zero-thickness point.
pin_tip_taper_h = 3;   // mm — length of outer taper from full pin_dia
pin_tip_od      = pin_channel_dia + 0.6;   // mm at apex (~0.3 mm wall each side for FDM)
// Lateral bore Z: prefer top tangent at seal flange; cap keeps tunnel from slicing down through base top (z = disk_h).
pin_tunnel_z_seal_align = reservoir_seat - valve_flange_h - pin_channel_dia / 2;
// Center height so bottom tangent ≈ disk top — lateral sits mostly in pin shank, not through upper base slab.
pin_tunnel_z_max_center = needle_insert_disk_h + pin_channel_dia / 2;
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

// ── Needle base TPU ring (90A) — no groove on insert; torus stretches over upper step OD ──
needle_gasket_radial_inner_undersize_mm = 0.12;  // baseline: relaxed inner R < upper step R (mm)
needle_gasket_radial_outer_oversize_mm  = 0.28; // used only to define held OD below (mm)
needle_gasket_axial_clear_mm            = 0.06; // torus z half-height slack vs upper step (mm, each end)
// Relaxed inner opening ID reduced by this (diametric mm) vs land_R − undersize → radial wall thicker by ~half this.
needle_gasket_ring_inner_id_reduction_dia_mm = 0.5;   // diametric shrink of relaxed inner vs land − undersize
// Relaxed outer R: reference hole ID − small offset + oversize (independent of upper-step OD).
needle_gasket_relaxed_outer_r =
    (needle_insert_base_bottom_od - needle_insert_disk_od_clearance_dia) / 2 + needle_gasket_radial_outer_oversize_mm;
needle_gasket_relaxed_inner_r =
    needle_insert_gasket_land_od / 2
    - needle_gasket_radial_inner_undersize_mm
    - needle_gasket_ring_inner_id_reduction_dia_mm / 2;
needle_gasket_relaxed_z_half = needle_insert_base_gasket_step_h / 2 - needle_gasket_axial_clear_mm;
needle_gasket_assembly_z = needle_insert_base_bottom_h + needle_insert_base_gasket_step_h / 2;

// Inner barrier — radial ports (same dia as needle / pin channel), flush with tray floor top
inner_bait_barrier_hole_count   = 6;
inner_bait_barrier_hole_dia     = pin_channel_dia;
inner_bait_barrier_hole_z       = station_floor + inner_bait_barrier_hole_dia / 2;  // lower tangent at z = station_floor
inner_bait_barrier_hole_start_r = inner_bait_barrier_id / 2 - 0.35;   // start just inside inner opening
inner_bait_barrier_hole_length  = inner_bait_barrier_radial_t + 0.8; // through 1 mm wall with margin
// Rails + gap filler: angularly between the six wall holes (holes at 0°, 60°, …).
inner_barrier_rail_phase_deg   = 30;    // deg offset vs hole at i=0 (midway between holes)
inner_barrier_rail_width_mm   = 1;
inner_barrier_rail_inward_mm  = 2;
inner_barrier_rail_y_offset_mm = 2;     // tangential center from axis (±)
inner_barrier_rail_fill_width_mm = 3;   // tangential span of filler between rails (mm)
inner_barrier_rail_fill_inward_mm = 1; // filler depth toward center (mm)
inner_barrier_rail_height_trim_mm = 3; // shorten rails + filler from top (mm); clears inner wall top lip
inner_barrier_rail_extend_below_floor_mm = 1; // grow downward from tray floor toward needle pocket (mm)
inner_barrier_rail_z_offset_mm  = 1;   // shift whole rail + filler stack +Z (mm)
inner_barrier_rail_z_top = bait_barrier_top_z - inner_barrier_rail_height_trim_mm + inner_barrier_rail_z_offset_mm;
inner_barrier_rail_z_bot = station_floor - inner_barrier_rail_extend_below_floor_mm + inner_barrier_rail_z_offset_mm;

// Needle insert retention clips — 6×, same phase as inner barrier rails; outward barb hooks rail top ledge.
// Insertion: align each clip with the vertical slot between the two rails at that site (6-fold symmetry).
// Stem outer face stays flush with disk OD; only the barb protrudes — must flex inward (~PETG) to pass the hole + rails.
needle_insert_clip_count = inner_bait_barrier_hole_count;
needle_insert_clip_phase_deg = inner_barrier_rail_phase_deg;
needle_insert_clip_z0 = 0.35;
needle_insert_clip_anchor_depth_mm = 0.4;    // root into disk, inside nominal OD
needle_insert_clip_stem_radial_mm    = 0.7;   // flex leg: inner extent from OD toward axis (mm)
needle_insert_clip_tangent_width_mm  = 2.1;   // fits between paired rails at each site
needle_insert_clip_barb_radial_mm    = 0.18;  // small outward hook; keep ≤ ring gap + pocket c for snap
needle_insert_clip_barb_axial_mm     = 0.85;
needle_insert_clip_shelf_clear_below_rail_top_mm = 0.4;
needle_insert_clip_overhang_past_rail_top_mm     = 0.22;
needle_insert_clip_body_z_top = inner_barrier_rail_z_top - needle_insert_clip_shelf_clear_below_rail_top_mm;
needle_insert_clip_barb_z_top = inner_barrier_rail_z_top + needle_insert_clip_overhang_past_rail_top_mm;
needle_insert_clip_pocket_radial_extra_mm = 0.35;  // beyond disk OD + needle_insert_pocket_clearance for barb + flex

// Computed pin height (from station z=0) — apex flush with top of needle seal disk (not retention barb)
// Needle insert: base OD = inner barrier center hole ID; coaxial pocket; pin apex at pin_top.
// Assembly: valve_z = reservoir_seat − valve_flange_h → disk top = reservoir_seat + valve_disk_h
pin_top          = reservoir_seat + valve_disk_h;

// ── Tab Slide-Lock ────────────────────────────────────────────────
// Tabs on reservoir outer wall slide straight down into vertical slots
// in the station bore. No twist — reservoir drops in and seats on tabs.
tab_count    = 3;    // number of tabs, evenly spaced
tab_w        = 3;    // tab circumferential width (mm)
tab_h        = 2;    // tab height (mm)
tab_d        = 1.5;  // tab radial protrusion from reservoir wall (mm)
tab_drop     = 5;    // mm the reservoir drops through slot (pin engagement travel)
tab_z        = 2;    // tab bottom position from reservoir bottom (mm)

// Computed tab z-positions in station coordinates
tab_z_locked   = reservoir_seat + tab_z;                // seated
tab_z_unlocked = reservoir_seat + tab_drop + tab_z;     // elevated, pin clear

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

// ── Retention Clips (snap-fit lock between skirt and station) ────
// Flexible arms hang down from the skirt inner face into grooves
// in the station bore wall. Angled barb snaps into a notch when
// seated — easy to push in, very difficult to pull apart.
clip_count      = 3;     // same as tab_count, offset 60° from tabs
clip_w          = 4;     // circumferential width (mm)
clip_t          = 1.5;   // radial thickness of the arm (mm)
clip_length     = station_height;  // arm extends to station floor (mm)
clip_barb_d     = 0.4;   // barb protrusion beyond arm thickness (mm) — PETG flex limit
clip_ramp_angle = 30;    // ramp angle from arm surface (degrees) — printable slope
clip_barb_h     = 2 * clip_barb_d / tan(clip_ramp_angle);  // diamond height from angle
// Clip outer face is flush with skirt OD (= station OD).
// Channels cut into the station's outer wall surface.
clip_r          = station_od / 2;  // outer face radius of clip arm
clip_angle      = clip_w / (PI * station_od) * 360;  // angular span (degrees)
// Notch z in station coords: clips are fully seated when reservoir is at reservoir_seat.
// Clip bottom in station coords = reservoir_seat + skirt_z_start - clip_length
clip_bottom_z   = reservoir_seat + skirt_z_start - clip_length;  // 6mm
clip_notch_z    = clip_bottom_z;  // notch at the barb's seated position

// ── Edge Fillet ──────────────────────────────────────────────────
fillet_r = 2;  // radius of rounded edge on exposed top/bottom faces (mm)

// ── Info stamp (bottom / bed face) ────────────────────────────────
// Lines and per-part flags: ../stamp_generated.scad (product-level; export script writes it).
res_bottom_mark_size            = 5;    // line 1 (brand)
res_bottom_mark_size_secondary  = 3;    // lines 2–3 (product, version)
// Center-to-center spacing: lines 2–3 tight; lines 1–2 wider (rule sits halfway in that band).
res_bottom_mark_gap_2_3 =
    res_bottom_mark_size_secondary * 1.25;
res_bottom_mark_gap_extra_brand_to_product = 2.5; // extra mm between line 1 and line 2 vs 2–3
res_bottom_mark_gap_1_2 = res_bottom_mark_gap_2_3 + res_bottom_mark_gap_extra_brand_to_product;
// Rule under line 1: thickness tracks brand size (≈ bold “Y” stem); length from left edge of word to near final “y” tail.
// OpenSCAD 2021 has no textmetrics — advance is estimated from len × size × factor (tune for font/string).
res_bottom_mark_rule_adv_per_char   = 0.78;   // × line1 size → total width scale (Liberation Sans Bold)
res_bottom_mark_rule_stroke_scale   = 0.132;  // rule thickness = line1 size × this (match stem weight)
res_bottom_mark_rule_right_inset    = 0.40;   // × (adv/n_chars): shorten from right to meet “y” descender
// Shift whole stamp along +Y: fraction × part_od = distance from disc center toward rim (0.25 → mid-radius).
res_bottom_mark_radial_shift_fraction = 0.25;
res_bottom_mark_font     = "Liberation Sans:style=Bold";

include <../stamp_generated.scad>

// Deboss up to three lines on exterior bottom (Z=0). part_od = flat OD; stamp shifted +Y toward mid-radius.
// Lines 1–3 from stamp_generated.scad: brand, product, version (+ Prototype when preview).
module part_bottom_info_stamp_deboss(enable, part_od) {
    depth = reservoir_bottom_deboss_depth + 0.02;
    y1 = res_bottom_mark_gap_1_2;
    y2 = 0;
    y3 = -res_bottom_mark_gap_2_3;
    ys = [y1, y2, y3];
    stamp_shift_y = part_od * res_bottom_mark_radial_shift_fraction;
    has_any = info_stamp_line1 != "" || info_stamp_line2 != "" || info_stamp_line3 != "";
    if (enable && has_any) {
        // Text is authored in +Z-down convention; exterior bottom is read from below (−Z) → mirror X.
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
    if (!mesh_preview) render() children();
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
