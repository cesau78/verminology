// V2 Bait Station — Open tray with push-pin, torus groove, ant access holes.
// The reservoir drops inside; bayonet ramp-lock pushes it onto the pin.
// Fluid drains through radial channels to a full-circle torus groove.
// Ants access bait through small holes in the outer wall at groove level.

include <common.scad>

// ── Main Assembly ─────────────────────────────────────────────────
module bait_station() {
    union() {
        difference() {
            station_solid();
            station_bore();
            station_torus_groove();
            station_drain_channels();
            station_central_pocket();
            station_bayonet_slots();
            station_guard_holes();
        }
        // Pin added after cuts so the bore subtraction doesn't remove it
        station_push_pin();
    }
}

// ── Solid Body ────────────────────────────────────────────────────
module station_solid() {
    render_if_needed()
        cylinder(h = station_height, d = station_od);
}

// ── Bore ──────────────────────────────────────────────────────────
// Internal cavity where the reservoir sits.
module station_bore() {
    render_if_needed()
        translate([0, 0, station_floor])
            cylinder(h = station_height - station_floor + 1, d = station_id);
}

// ── Torus Groove ──────────────────────────────────────────────────
// Full-circle ring channel in the tray floor. A torus centered at
// floor level gives a semicircular profile below the floor surface.
// Outer edge touches the bore wall for direct ant access.
module station_torus_groove() {
    render_if_needed()
        translate([0, 0, station_floor])
            rotate_extrude()
                translate([torus_groove_r, 0])
                    circle(d = torus_groove_dia);
}

// ── Drain Channels ────────────────────────────────────────────────
// Radial grooves from the center to the torus groove, cut into the
// tray floor. Fluid flows from the pin base outward to the groove.
module station_drain_channels() {
    render_if_needed()
        for (i = [0 : drain_count - 1])
            rotate([0, 0, i * (360 / drain_count)])
                translate([0, -drain_width / 2, station_floor - drain_depth])
                    cube([torus_groove_r + torus_groove_dia / 2,
                          drain_width,
                          drain_depth + 0.5]);
}

// ── Central Pocket ────────────────────────────────────────────────
// Shallow annular pool around the pin base where fluid collects
// before draining into the radial channels.
module station_central_pocket() {
    render_if_needed()
        translate([0, 0, station_floor - drain_depth])
            cylinder(h = drain_depth + 0.5, r = central_pocket_r);
}

// ── Push Pin ──────────────────────────────────────────────────────
// Central post that spreads the slit valve open when the reservoir
// is locked down. Cylinder base with a conical tip for smooth entry.
// When unlocked: tip is 1mm below valve. When locked: 2mm past valve.
module station_push_pin() {
    render_if_needed() {
        // Cylindrical base (from station base up to cone start)
        cylinder(h = pin_cyl_top, d = pin_dia);

        // Conical tip
        translate([0, 0, pin_cyl_top])
            cylinder(h = pin_cone_h, d1 = pin_dia, d2 = 0);
    }
}

// ── Bayonet Ramp-Slots ────────────────────────────────────────────
// L-shaped slots in the bore wall: vertical entry + ramped lock channel.
// The reservoir lugs drop through the vertical slot, then twist to lock.
// The ramp descends bayonet_drop mm over bayonet_rotation degrees,
// pulling the reservoir down onto the push pin.
module station_bayonet_slots() {
    slot_w     = bayonet_lug_w + clearance * 2;  // width with clearance
    slot_h     = bayonet_lug_h + clearance * 2;  // height with clearance
    slot_depth = bayonet_lug_d + clearance + 1;  // radial depth (through inner wall)
    ramp_step  = 5;  // degrees per hull segment

    for (i = [0 : bayonet_count - 1]) {
        angle = i * (360 / bayonet_count);

        // Vertical entry slot — open at top for reservoir insertion
        rotate([0, 0, angle])
            translate([station_id / 2 - 0.5, -slot_w / 2, lug_z_unlocked])
                cube([slot_depth, slot_w, station_height - lug_z_unlocked + 1]);

        // Ramped lock channel — descends from entry height to locked height
        // hull() between consecutive angular steps creates a smooth ramp
        for (s = [0 : ramp_step : bayonet_rotation - ramp_step]) {
            hull() {
                rotate([0, 0, angle + s])
                translate([station_id / 2 - 0.5, -slot_w / 2,
                           lug_z_unlocked - (s / bayonet_rotation) * bayonet_drop])
                    cube([slot_depth, slot_w, slot_h]);

                rotate([0, 0, angle + s + ramp_step])
                translate([station_id / 2 - 0.5, -slot_w / 2,
                           lug_z_unlocked - ((s + ramp_step) / bayonet_rotation) * bayonet_drop])
                    cube([slot_depth, slot_w, slot_h]);
            }
        }
    }
}

// ── Guard Holes ───────────────────────────────────────────────────
// Small holes through the outer wall for ant access to the torus groove.
// Positioned at the lower part of the groove where liquid collects.
module station_guard_holes() {
    hole_length = (station_od - station_id) / 2 + 2;

    for (i = [0 : guard_hole_count - 1])
        rotate([0, 0, i * (360 / guard_hole_count)])
        translate([station_id / 2 - 1, 0, guard_hole_z])
        rotate([0, 90, 0])
            cylinder(h = hole_length, d = guard_hole_dia);
}

// ── Render ────────────────────────────────────────────────────────
crosssection(station_od) bait_station();
