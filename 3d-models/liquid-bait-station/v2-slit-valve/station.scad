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
            station_inner_groove();
            station_drain_channels();
            station_central_pocket();
            station_bayonet_slots();
            station_guard_holes();
            station_scallops();
        }
        // Pin and hump added after cuts so the bore subtraction doesn't remove them
        station_push_pin();
        station_torus_hump();
    }
}

// ── Solid Body ────────────────────────────────────────────────────
module station_solid() {
    render_if_needed()
        cylinder(h = station_height, d = station_od);
}

// ── Bore ──────────────────────────────────────────────────────────
// Internal cavity where the reservoir sits. Starts at station_floor;
// the reservoir floats at reservoir_seat held by bayonet lugs,
// leaving space below for bait to flow to the torus grooves.
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

// ── Inner Groove ─────────────────────────────────────────────────
// Second torus groove just inside the hump, same profile as the outer groove.
module station_inner_groove() {
    render_if_needed()
        translate([0, 0, station_floor])
            rotate_extrude()
                translate([torus_inner_r, 0])
                    circle(d = torus_groove_dia);
}

// ── Torus Hump ───────────────────────────────────────────────────
// Raised ring just inside the torus groove, same cross-section size.
// Creates a hump that ants climb over to reach the bait in the groove.
module station_torus_hump() {
    render_if_needed()
        translate([0, 0, station_floor])
            rotate_extrude()
                translate([torus_hump_r, 0])
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
                    cube([torus_inner_r,
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
// Tip is blunted with a small flat cap for safety.
module station_push_pin() {
    render_if_needed() difference() {
        union() {
            station_push_pin_shaft();
            station_push_pin_cone();
        }
        station_push_pin_channels();
    }
}

// Cylindrical shaft from base to cone start
module station_push_pin_shaft() {
    cylinder(h = pin_cyl_top, d = pin_dia);
}

// Conical tip with blunted flat cap
module station_push_pin_cone() {
    // Tapered cone
    translate([0, 0, pin_cyl_top])
        cylinder(h = pin_cone_h, d1 = pin_dia, d2 = pin_blunt_dia);
    // Flat cap to blunt the tip
    translate([0, 0, pin_cyl_top + pin_cone_h])
        cylinder(h = 0.5, d = pin_blunt_dia);
}

// Internal fluid channels — subtracted from the assembled pin
module station_push_pin_channels() {
    // Vertical channel down center (z-axis)
    translate([0, 0, -0.5])
        cylinder(h = pin_top + 1, d = pin_channel_dia);
    // Perpendicular channels (x and y axes) flush with drain channel bottom
    for (angle = [0, 90])
        rotate([0, 0, angle])
            rotate([0, 90, 0])
                translate([-(station_floor - drain_depth), 0, -pin_dia / 2 - 0.5])
                    cylinder(h = pin_dia + 1, d = pin_channel_dia);
}

// ── Bayonet Twist-Lock Slots ──────────────────────────────────────
// Straight vertical entry slots + horizontal lock channel.
// Reservoir drops in, then twists clockwise (righty-tighty) to lock.
// Negative rotation in OpenSCAD = clockwise when viewed from above.
module station_bayonet_slots() {
    slot_w     = bayonet_lug_w + clearance * 2;  // width with clearance
    slot_h     = bayonet_lug_h + clearance * 2;  // height with clearance
    slot_depth = bayonet_lug_d + clearance + 1;  // radial depth (through inner wall)
    lock_step  = 5;  // degrees per hull segment

    for (i = [0 : bayonet_count - 1]) {
        angle = i * (360 / bayonet_count);

        // Vertical entry slot — open at top, drops straight to locked height
        rotate([0, 0, angle])
            translate([station_id / 2 - 0.5, -slot_w / 2, lug_z_locked])
                cube([slot_depth, slot_w, station_height - lug_z_locked + 1]);

        // Horizontal lock channel — extends clockwise (negative angle)
        // at locked height. hull() between angular steps for smooth arc.
        for (s = [0 : lock_step : bayonet_rotation - lock_step]) {
            hull() {
                rotate([0, 0, angle - s])
                translate([station_id / 2 - 0.5, -slot_w / 2, lug_z_locked])
                    cube([slot_depth, slot_w, slot_h]);

                rotate([0, 0, angle - s - lock_step])
                translate([station_id / 2 - 0.5, -slot_w / 2, lug_z_locked])
                    cube([slot_depth, slot_w, slot_h]);
            }
        }
    }
}

// ── Guard Holes ───────────────────────────────────────────────────
// Small holes through the outer wall for ant access to the torus groove.
// Positioned at the lower part of the groove where liquid collects.
module station_guard_holes() {
    hole_length = station_od / 2 - torus_groove_r + 1;

    for (i = [0 : guard_hole_count - 1])
        rotate([0, 0, i * (360 / guard_hole_count)])
        translate([torus_groove_r, 0, guard_hole_z])
        rotate([0, 90, 0])
            cylinder(h = hole_length, d = guard_hole_dia);
}

// ── Grip Scallops ────────────────────────────────────────────────
// Radial spoke cylinders from center, angled up 15° (mirrored from
// reservoir). Cuts scallop_cut mm into the bottom face at the rim.
module station_scallops() {
    spoke_len = station_od / 2 + scallop_r;
    // Position so cylinder top = scallop_cut at rim
    z_start = scallop_cut - scallop_r
              - (station_od / 2) * tan(scallop_pitch);
    for (i = [0 : scallop_count - 1])
        rotate([0, 0, i * (360 / scallop_count)])
            translate([0, 0, z_start])
                rotate([0, -scallop_pitch, 0])
                    rotate([0, 90, 0])
                        cylinder(h = spoke_len, r = scallop_r);
}

// ── Render ────────────────────────────────────────────────────────
crosssection(station_od) bait_station();
