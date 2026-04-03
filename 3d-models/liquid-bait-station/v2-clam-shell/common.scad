// V2 Slit-Valve Liquid Bait Station — Shared Parameters
// Rigid reservoir drops into an open tray bait station.
// A central push-pin spreads the TPU slit valve open when reservoir is seated.

// ── Performance Settings ──────────────────────────────────────────
// mesh_preview: fast low-$fn for interactive editing (export scripts pass mesh_preview=false for STLs).
mesh_preview = true;
crosssection_view = false;  // cut the model along a plane to inspect internals
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
reservoir_od       = 77;                          // outer diameter (mm) — 3×3 on 256mm plate
reservoir_height   = 30;                          // total height (mm)
reservoir_id       = reservoir_od - wall * 2;     // 73mm internal diameter
reservoir_cavity_h = reservoir_height - wall * 2; // 26mm internal height
// Volume: π × 36.5² × 26 ≈ 109ml ≈ 3.7oz (slightly less with dome)

// ── TPU Slit Valve ────────────────────────────────────────────────
valve_disk_od  = 16;                        // disk outer diameter (mm)
valve_bore_id  = valve_disk_od;             // snug sliding fit — FDM shrinkage holds it
valve_disk_h   = wall;                      // same as floor thickness — flush inside
valve_flange_od = valve_disk_od + 4;        // flange: 2mm larger radius — stop collar
valve_flange_h  = 2;                        // flange height (mm) — prevents push-through
valve_retainer_od = valve_disk_od + 1;       // top retention disk OD — just past bore edge
valve_retainer_id = valve_disk_od - 4;       // top retention disk ID — 2mm lip inward
valve_retainer_h  = valve_flange_h;          // same thickness as bottom flange
slit_width    = 0.2;  // effectively touching — prints closed, pin forces open
slit_length   = 10;   // each arm of the X-slit (mm)

// ── Station ───────────────────────────────────────────────────────
station_od     = 85;   // outer diameter (mm) — 3×3 on 256mm plate (3×85=255)
station_floor  = 5;    // floor thickness — deep enough for torus groove
station_id     = reservoir_od + clearance * 2;  // 77.4mm bore for reservoir

// ── Torus Groove (full-circle ring channel in tray floor) ─────────
torus_groove_dia = 6;  // cross-section diameter — semicircle profile in floor
torus_groove_r   = station_id / 2 - torus_groove_dia / 2;  // 35.7mm center radius
// Outer edge of groove touches the bore wall for direct ant access.
torus_hump_r     = torus_groove_r - torus_groove_dia;      // 29.7mm — hump ring just inside groove
torus_inner_r    = torus_hump_r - torus_groove_dia;        // 23.7mm — inner groove just inside hump

// Reservoir sits on top of the hump torus
reservoir_seat   = station_floor + torus_groove_dia / 2 + clearance;  // 8.2mm — just above hump top
station_height   = 18;   // total height — raised 3mm for higher reservoir seat

// ── Push Pin / Straw (station center, spreads valve slits on lock) ─
pin_dia         = 6;   // pin outer diameter (mm) — smaller than slit_length for proper spread
pin_penetration = 3;   // mm past valve top when fully locked — enough to clear valve reliably

// ── Needle Seal (slit-free variant — TPU interference fit around pin) ─
seal_hole_dia = pin_dia - 0.3;  // 5.7mm — 0.15mm interference per side in TPU

pin_channel_dia = 3;   // internal fluid channel diameter (mm)
pin_tunnel_count = 3;  // cross-tunnels at base for fluid drainage (120° apart)

// Computed pin height (from station z=0)
// Straight straw — no cone, open top for fluid flow
pin_top     = reservoir_seat + valve_disk_h + pin_penetration;  // top of straw

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

// ── Guard Holes (ant access through outer wall at groove level) ───
guard_hole_dia   = 3.2;  // hole diameter — ants only
guard_hole_count = 12;   // number around circumference
guard_hole_z     = station_floor - torus_groove_dia / 3;  // 3mm — lower groove zone

// ── Drain Channels (radial grooves from pin base to torus groove) ─
drain_count      = 4;   // channels at 90° intervals
drain_width      = 3;   // channel width (mm)
drain_depth      = 2;   // channel depth below floor surface (mm)
central_pocket_r = pin_dia / 2 + 3;  // 6mm — annular pool around pin base

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
skirt_od       = station_od;                                    // 85mm — flush with station
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
