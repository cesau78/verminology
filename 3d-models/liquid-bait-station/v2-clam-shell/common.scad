// V2 Slit-Valve Liquid Bait Station — Shared Parameters
// Rigid reservoir drops into an open tray bait station.
// A central push-pin spreads the TPU slit valve open when reservoir is seated.

// ── Performance Settings ──────────────────────────────────────────
preview = false; // true = faster preview; false = full detail render
crosssection_view = false;  // cut the model along a plane to inspect internals
crosssection_axis = "x";   // axis: "x", "y", or "z"
crosssection_pos  = 10;     // position (mm) along the chosen axis

$fn = preview ? 32 : 64;

// ── General ───────────────────────────────────────────────────────
wall      = 2;     // shell wall thickness (mm)
clearance = 0.2;   // general fit clearance for mating parts (mm)

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

// ── Needle Seal (slit-free variant — TPU interference fit around pin) ─
seal_hole_dia = pin_dia - 0.3;  // 5.7mm — 0.15mm interference per side in TPU

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

// ── Edge Fillet ──────────────────────────────────────────────────
fillet_r = 2;  // radius of rounded edge on exposed top/bottom faces (mm)

// ── Utility Modules ───────────────────────────────────────────────

module render_if_needed() {
    if (!preview) render() children();
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
