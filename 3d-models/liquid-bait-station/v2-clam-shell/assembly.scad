// V2 Assembly View — All parts in operating position.
// Toggle 'locked' to see pin engagement vs disengaged.
// Toggle 'exploded' to spread parts for inspection.

include <common.scad>
use <station.scad>
use <reservoir.scad>
use <needle-seal.scad>

// ── Settings ──────────────────────────────────────────────────────
exploded   = false;  // spread parts vertically for inspection
explode_gap = 25;    // mm gap in exploded view
show_valve = true;   // show the TPU slit valve disk
locked     = true;   // true = locked (pin engaged), false = unlocked (resting)

// ── Positions ─────────────────────────────────────────────────────
// Reservoir bottom z-position: drops straight through vertical slot.
// Locked = dropped + twisted CW onto pin. Unlocked = elevated, pin clear.
res_z = locked
    ? reservoir_seat                    // seated: bottom at top of hump
    : reservoir_seat + tab_drop;        // lifted: elevated, pin clear
res_z_final = res_z + (exploded ? explode_gap : 0);

// ── Valve position (shared by flange and disk) ──────────────────
valve_z = res_z_final - valve_flange_h - (exploded ? explode_gap / 2 : 0);

// ── Assembly ──────────────────────────────────────────────────────
crosssection(station_od * 2) {
    // Station (without pin) — at origin
    color("SlateGray", 0.8)
        bait_station();

    // Reservoir — drops straight into station bore
    color("SteelBlue", 0.8)
        translate([0, 0, res_z_final])
            reservoir();

    // Needle seal — flange, disk, and retention ring
    if (show_valve)
        color("LimeGreen", 0.9)
            translate([0, 0, valve_z])
                needle_seal();
}
