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
station_height = 15;   // total height including floor
station_id     = reservoir_od + clearance * 2;  // 82.4mm bore for reservoir

// ── Push Pin (station center, spreads valve slits on lock) ────────
pin_dia         = 6;   // pin diameter (mm) — smaller than slit_length for proper spread
pin_cone_h      = 3;   // tapered tip height for smooth slit entry
pin_penetration = 2;   // mm past valve top when fully locked

// Computed pin heights (from station z=0)
pin_top     = station_floor + valve_disk_h + pin_penetration;  // 9mm
pin_cyl_top = pin_top - pin_cone_h;                            // 6mm

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
lug_z_locked   = station_floor + bayonet_lug_z;                // 7mm
lug_z_unlocked = station_floor + bayonet_drop + bayonet_lug_z; // 12mm
// When unlocked: pin tip (z=9) is 1mm below valve bottom (z=10). No contact.
// When locked:   pin tip (z=9) pushes 2mm past valve top (z=7). Full spread.

// ── Torus Groove (full-circle ring channel in tray floor) ─────────
torus_groove_dia = 6;  // cross-section diameter — semicircle profile in floor
torus_groove_r   = station_id / 2 - torus_groove_dia / 2;  // 38.2mm center radius
// Outer edge of groove touches the bore wall for direct ant access.

// ── Guard Holes (ant access through outer wall at groove level) ───
guard_hole_dia   = 2.5;  // hole diameter — ants only
guard_hole_count = 24;   // number around circumference
guard_hole_z     = station_floor - torus_groove_dia / 3;  // 3mm — lower groove zone

// ── Drain Channels (radial grooves from pin base to torus groove) ─
drain_count      = 4;   // channels at 90° intervals
drain_width      = 3;   // channel width (mm)
drain_depth      = 2;   // channel depth below floor surface (mm)
central_pocket_r = pin_dia / 2 + 3;  // 6mm — annular pool around pin base

// ── Internal Ribs (reservoir bridging + anti-slosh) ───────────────
rib_count     = 3;   // cross-diameter ribs
rib_thickness = 1;   // rib wall thickness (mm)

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
