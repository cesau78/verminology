// V2 Assembly View — All parts in operating position.
// Toggle 'locked' to see seated vs raised.
// Toggle 'exploded' to spread parts for inspection.

use <station.scad>
use <reservoir.scad>
use <needle-seal.scad>
include <common.scad>

// ── Settings ──────────────────────────────────────────────────────
exploded   = true;  // spread parts vertically for inspection
explode_gap = 0;    // mm gap in exploded view
show_valve  = true;   // show the TPU needle seal (reservoir floor)
show_batting = true;  // show bait ring in tray (assembly preview only)
locked     = true;   // true = locked (pin engaged), false = unlocked (resting)

// Bait / batting — assembly depiction only (not a printed part)
batting_od_in = 2;
batting_id_in = 1;
batting_h_in  = 1 / 4;
batting_od    = batting_od_in * 25.4;
batting_id    = batting_id_in * 25.4;
batting_h     = batting_h_in * 25.4;

// ── Positions ─────────────────────────────────────────────────────
// Reservoir slides straight down; locked = fully seated, unlocked = raised.
res_z = locked
    ? reservoir_seat
    : reservoir_seat + 15;
res_z_final = res_z + (exploded ? explode_gap : 0);

// ── Valve position (shared by flange and disk) ──────────────────
valve_z = res_z_final - valve_flange_h - (exploded ? explode_gap / 2 : 0);

// ── Assembly ──────────────────────────────────────────────────────
crosssection(station_od * 2) {
    // Station shell with integrated needle pin
    color("SlateGray", 0.8)
        bait_station();

    // Bait ring on tray floor (visualization)
    if (show_batting)
        color("Peru", 0.9)
            translate([0, 0, station_floor])
                difference() {
                    cylinder(h = batting_h, d = batting_od);
                    translate([0, 0, -0.02])
                        cylinder(h = batting_h + 0.04, d = batting_id);
                }

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
