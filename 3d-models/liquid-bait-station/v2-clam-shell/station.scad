// V2 Bait Station — Open tray with push-pin, flat floor, ant access holes.
// The reservoir drops straight into the bore (guide tabs into vertical
// slots).  Vertical M3 bolts through the station floor clamp the
// reservoir via captive nuts.  Outer + inner bait barrier rings; needle
// pin is integrated directly into the station floor.

include <common.scad>

// ── Helper: test whether an angle matches a bolt-lock position ────
function _is_bolt_lock_pos(a, tol = 1) =
    len([for (j = [0 : bolt_lock_count - 1])
         let(la = (bolt_lock_angle + j * (360 / bolt_lock_count)) % 360)
         if (abs(a - la) < tol) j]) > 0;

// ── Main Assembly ─────────────────────────────────────────────────
module bait_station() {
    difference() {
        union() {
            difference() {
                station_solid();
                station_bore();
                station_tab_slots();
                station_guard_holes();
            }
            station_bait_barrier_ring();
            station_inner_bait_barrier_ring();
            station_bolt_lock_bosses();
            station_needle();
        }
        station_needle_channels();
        station_bolt_lock();
        station_side_scallops();
        part_bottom_info_stamp_deboss(station_stamp_bottom, station_od);
    }
}

// ── Solid Body ────────────────────────────────────────────────────
module station_solid() {
    render_if_needed()
        cylinder(h = station_height, d = station_od);
}

// ── Bore ──────────────────────────────────────────────────────────
module station_bore() {
    render_if_needed()
        translate([0, 0, station_floor])
            cylinder(h = station_height - station_floor + 1, d = station_id);
}

// ── Tab Slots ─────────────────────────────────────────────────────
module station_tab_slots() {
    sw = tab_w + tab_clearance * 2;
    sd = tab_d + tab_clearance;
    for (i = [0 : tab_count - 1])
        rotate([0, 0, i * (360 / tab_count)])
            translate([station_id / 2 - 1, -sw / 2, station_floor])
                cube([sd + 1.01, sw, station_height - station_floor + 0.01]);
}

// ── Bait Barrier Ring (outer) ────────────────────────────────────
module station_bait_barrier_ring() {
    render_if_needed()
        translate([0, 0, bait_barrier_bottom_z])
            difference() {
                cylinder(h = bait_barrier_h, d = bait_barrier_od);
                translate([0, 0, -0.01])
                    cylinder(h = bait_barrier_h + 0.02, d = bait_barrier_id);
            }
}

// ── Inner Bait Barrier Ring ───────────────────────────────────────
module station_inner_bait_barrier_ring() {
    render_if_needed()
        difference() {
            translate([0, 0, bait_barrier_bottom_z])
                difference() {
                    cylinder(h = inner_bait_barrier_h, d = inner_bait_barrier_od);
                    translate([0, 0, -0.01])
                        cylinder(h = inner_bait_barrier_h + 0.02, d = inner_bait_barrier_id);
                }
            station_needle_channels();
            station_inner_barrier_wall_holes();
        }
}

// ── Integrated Needle Pin ────────────────────────────────────────
module station_needle() {
    sh = pin_top - pin_tip_taper_h - station_floor;
    translate([0, 0, station_floor]) {
        cylinder(h = sh, d = pin_dia);
        translate([0, 0, sh])
            cylinder(h = pin_tip_taper_h, d1 = pin_dia, d2 = pin_tip_od);
    }
}

module station_needle_channels() {
    vb = max(0, pin_channel_z_bottom);
    vh = pin_top + 0.5 - vb;
    translate([0, 0, vb])
        cylinder(h = vh, d = pin_channel_dia);
    translate([pin_tunnel_x_center, 0, pin_tunnel_z])
        rotate([0, 90, 0])
            cylinder(h = pin_tunnel_reach, d = pin_channel_dia, center = true);
}

module station_inner_barrier_wall_holes() {
    for (i = [0 : inner_bait_barrier_hole_count - 1])
        rotate([0, 0, i * (360 / inner_bait_barrier_hole_count)])
            translate([inner_bait_barrier_hole_start_r, 0, inner_bait_barrier_hole_z])
                rotate([0, 90, 0])
                    cylinder(h = inner_bait_barrier_hole_length, d = inner_bait_barrier_hole_dia);
}

// ── Guard Holes ───────────────────────────────────────────────────
// Skip guard holes at bolt-lock positions (blocked by boss).
module station_guard_holes() {
    hole_length = station_od / 2 - guard_hole_inner_r + 1;
    for (i = [0 : guard_hole_count - 1]) {
        a = i * (360 / guard_hole_count);
        if (!_is_bolt_lock_pos(a))
            rotate([0, 0, a])
                translate([guard_hole_inner_r, 0, guard_hole_z])
                    rotate([0, 90, 0])
                        cylinder(h = hole_length, d = guard_hole_dia);
    }
}

// ── Bolt Lock — Station Bosses ───────────────────────────────────
// Vertical cylinder at each bolt position, from the station floor up
// to the bottom of the reservoir boss extension.
module station_bolt_lock_bosses() {
    boss_dia = bolt_lock_screw_dia + 4;
    h = reservoir_seat - station_floor - reservoir_outer_wall_extension_below_mm;

    for (i = [0 : bolt_lock_count - 1]) {
        angle = bolt_lock_angle + i * (360 / bolt_lock_count);
        rotate([0, 0, angle])
            translate([bolt_lock_r, 0, station_floor])
                cylinder(h = h, d = boss_dia);
    }
}

// ── Bolt Lock — Holes ────────────────────────────────────────────
// Cap-head counterbore through the station floor + clearance hole
// through the boss.
module station_bolt_lock() {
    for (i = [0 : bolt_lock_count - 1]) {
        angle = bolt_lock_angle + i * (360 / bolt_lock_count);
        rotate([0, 0, angle])
            translate([bolt_lock_r, 0, 0]) {
                // Cap-head counterbore — through the full floor
                translate([0, 0, -0.01])
                    cylinder(h = station_floor + 0.02, d = bolt_lock_head_dia);
                // Clearance hole through boss
                translate([0, 0, station_floor])
                    cylinder(h = reservoir_seat - station_floor + 0.5,
                             d = bolt_lock_screw_dia);
            }
    }
}

// ── Side Grip Scallops ───────────────────────────────────────────
module station_side_scallops() {
    for (i = [0 : scallop_count - 1])
        rotate([0, 0, scallop_offset + i * (360 / scallop_count)])
            translate([station_od / 2, 0, station_scallop_z])
                scale([scallop_depth, scallop_width / 2, scallop_height / 2])
                    sphere(r = 1);
}

// ── Render ────────────────────────────────────────────────────────
crosssection(station_od) bait_station();
