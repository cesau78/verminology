// V2 Slit-Valve Liquid Bait Station — Shared Parameters
// Rigid reservoir drops into an open tray bait station.
// A central push-pin spreads the TPU slit valve open on bayonet lock.

// ── Performance Settings ──────────────────────────────────────────
preview = false; // true = faster preview; false = full detail render
crosssection_view = true;  // cut the model along a plane to inspect internals
crosssection_axis = "x";   // axis: "x", "y", or "z"
crosssection_pos  = 0;     // position (mm) along the chosen axis

$fn = preview ? 32 : 64;

// ── General ───────────────────────────────────────────────────────
wall      = 2;     // shell wall thickness (mm)
clearance = 0.2;   // general fit clearance for mating parts (mm)

// ── Reservoir ─────────────────────────────────────────────────────
reservoir_od       = 82;                          // outer diameter (mm)
reservoir_height   = 30;                          // total height (mm)
reservoir_id       = reservoir_od - wall * 2;     // 78mm internal diameter
reservoir_cavity_h = reservoir_height - wall * 2; // 26mm internal height
// Volume: π × 39² × 26 ≈ 124ml ≈ 4.2oz

// ── TPU Slit Valve ────────────────────────────────────────────────
valve_disk_od = 16;                        // disk outer diameter (mm)
valve_bore_id = valve_disk_od - 0.6;       // tight press-fit bore (0.6mm interference)
valve_disk_h  = wall;                      // same as floor thickness — flush both sides
slit_width    = 0.2;  // effectively touching — prints closed, pin forces open
slit_length   = 10;   // each arm of the X-slit (mm)

// ── Station ───────────────────────────────────────────────────────
station_od     = 90;   // outer diameter (mm)
station_floor  = 5;    // floor thickness — deep enough for torus groove
station_id     = reservoir_od + clearance * 2;  // 82.4mm bore for reservoir

// ── Torus Groove (full-circle ring channel in tray floor) ─────────
torus_groove_dia = 6;  // cross-section diameter — semicircle profile in floor
torus_groove_r   = station_id / 2 - torus_groove_dia / 2;  // 38.2mm center radius
// Outer edge of groove touches the bore wall for direct ant access.
torus_hump_r     = torus_groove_r - torus_groove_dia;      // 32.2mm — hump ring just inside groove
torus_inner_r    = torus_hump_r - torus_groove_dia;        // 26.2mm — inner groove just inside hump

// Reservoir sits on top of the hump torus
reservoir_seat   = station_floor + torus_groove_dia / 2 + clearance;  // 8.2mm — just above hump top
station_height   = 18;   // total height — raised 3mm for higher reservoir seat

// ── Push Pin (station center, spreads valve slits on lock) ────────
pin_dia         = 6;   // pin diameter (mm) — smaller than slit_length for proper spread
pin_cone_h      = 3;   // tapered tip height for smooth slit entry
pin_blunt_dia   = 2;   // flat cap diameter at cone tip to blunt the point
pin_penetration = 2;   // mm past valve top when fully locked

// Computed pin heights (from station z=0)
pin_top     = reservoir_seat + valve_disk_h + pin_penetration;  // 12mm
pin_cyl_top = pin_top - pin_cone_h;                             // 9mm

// ── Bayonet Twist-Lock ────────────────────────────────────────────
// Lugs on reservoir outer wall; ramped L-slots in station bore wall.
// Twisting the reservoir drives it down onto the push pin.
bayonet_count    = 3;    // number of lugs, evenly spaced
bayonet_lug_w    = 3;    // lug circumferential width (mm)
bayonet_lug_h    = 2;    // lug height (mm)
bayonet_lug_d    = 1.5;  // lug radial protrusion from reservoir wall (mm)
bayonet_rotation = 30;   // degrees to twist for lock
bayonet_drop     = 5;    // mm the reservoir descends on lock (pin engagement travel)
bayonet_lug_z    = 2;    // lug bottom position from reservoir bottom (mm)

// Computed lug z-positions in station coordinates
lug_z_locked   = reservoir_seat + bayonet_lug_z;                // 10mm
lug_z_unlocked = reservoir_seat + bayonet_drop + bayonet_lug_z; // 15mm
// When unlocked: pin tip (z=12) is 1mm below valve bottom (z=13). No contact.
// When locked:   pin tip (z=12) pushes 2mm past valve top (z=10). Full spread.

// ── Guard Holes (ant access through outer wall at groove level) ───
guard_hole_dia   = 3;    // hole diameter — ants only
guard_hole_count = 12;   // number around circumference
guard_hole_z     = station_floor - torus_groove_dia / 3;  // 3mm — lower groove zone

// ── Drain Channels (radial grooves from pin base to torus groove) ─
drain_count      = 4;   // channels at 90° intervals
drain_width      = 3;   // channel width (mm)
drain_depth      = 2;   // channel depth below floor surface (mm)
central_pocket_r = pin_dia / 2 + 3;  // 6mm — annular pool around pin base

// ── Ant Tunnels (half-pipe arches over hump, flush with reservoir bottom) ──
ant_tunnel_count  = guard_hole_count;              // one tunnel per guard hole
ant_tunnel_r_out  = 6;                             // outer half-cylinder radius
ant_tunnel_r_in   = 4;                             // inner cutout radius (passage)
ant_tunnel_length = reservoir_od / 2 - (torus_inner_r - torus_groove_dia / 2); // radial span: inner edge of inner groove into reservoir wall

// ── Internal Struts (reservoir ceiling bridging + anti-slosh) ─────
strut_count     = 6;   // radial struts evenly spaced
strut_thickness = 1;   // strut wall thickness (mm)
strut_gap       = valve_bore_id / 2 + 2;  // stop short of valve bore center

// ── Utility Modules ───────────────────────────────────────────────

module render_if_needed() {
    if (!preview) render() children();
    else children();
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
