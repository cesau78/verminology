// V2 Bait Station — Open tray with push-pin, torus groove, ant access holes.
// The reservoir drops inside; tabs slide into vertical slots and seat onto the pin.
// Fluid drains through radial channels to a full-circle torus groove.
// Ants access bait through small holes in the outer wall at groove level.

include <common.scad>

// ── Main Assembly ─────────────────────────────────────────────────
module bait_station() {
    difference() {
        union() {
            difference() {
                station_solid();
                station_bore();
                station_torus_groove();
                station_inner_groove();
                station_drain_channels();
                station_central_pocket();
                station_tab_slots();
                station_clip_grooves();
                station_guard_holes();
            }
            // Pin and hump added after cuts so the bore subtraction doesn't remove them
            station_push_pin();
            station_torus_hump();
        }
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
// Internal cavity where the reservoir sits. Starts at station_floor;
// the reservoir floats at reservoir_seat held by tabs,
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

// ── Push Pin / Straw ─────────────────────────────────────────────
// Central hollow straw that spreads the slit valve open when the
// reservoir is locked down. Open top allows fluid to flow down
// through the bore and out cross-tunnels at the base.
module station_push_pin() {
    render_if_needed() difference() {
        // Straight cylinder — no cone
        cylinder(h = pin_top, d = pin_dia);
        station_push_pin_channels();
    }
}

// Internal fluid channels — subtracted from the pin
module station_push_pin_channels() {
    // Vertical bore down center — open at top (straw)
    translate([0, 0, -0.5])
        cylinder(h = pin_top + 1, d = pin_channel_dia);
    // Cross-tunnels at base, evenly spaced, flush with drain channel bottom
    for (i = [0 : pin_tunnel_count - 1])
        rotate([0, 0, i * (360 / pin_tunnel_count)])
            rotate([0, 90, 0])
                translate([-(station_floor - drain_depth), 0, -pin_dia / 2 - 0.5])
                    cylinder(h = pin_dia + 1, d = pin_channel_dia);
}

// ── Tab Slots ─────────────────────────────────────────────────────
// Straight vertical slots in the station bore wall. Reservoir tabs
// slide straight down — no twist required.
module station_tab_slots() {
    slot_w     = tab_w + clearance * 2;  // width with clearance
    slot_depth = tab_d + clearance + 1;  // radial depth (through inner wall)

    for (i = [0 : tab_count - 1]) {
        angle = i * (360 / tab_count);

        // Vertical slot — open at top, drops straight to seated height
        rotate([0, 0, angle])
            translate([station_id / 2 - 0.5, -slot_w / 2, tab_z_locked])
                cube([slot_depth, slot_w, station_height - tab_z_locked + 1]);
    }
}

// ── Retention Clip Grooves ────────────────────────────────────────
// Curved channels cut into the station's outer wall for the
// reservoir's retention clips to slide into. A deeper notch at the
// seated position lets the barb snap in. Offset 60° from tab slots.
module station_clip_grooves() {
    tab_offset = 360 / tab_count / 2;  // 60° from guide tabs
    groove_d   = clip_t + clearance;    // radial depth into outer wall
    groove_ang = (clip_w + clearance * 2) / (PI * station_od) * 360;
    // Notch: deeper pocket for the barb to snap into
    notch_d    = clip_t + clip_barb_d + clearance;
    notch_h    = clip_barb_h + clearance * 2;

    for (i = [0 : clip_count - 1]) {
        a = tab_offset + i * (360 / clip_count);
        rotate([0, 0, a]) {
            // Vertical groove — open at top, arc channel into outer wall
            translate([0, 0, clip_notch_z + notch_h])
                arc_shell(clip_r + 1, clip_r - groove_d,
                          station_height - clip_notch_z - notch_h + 1, groove_ang);
            // Snap notch — deeper arc pocket at the bottom for barb
            translate([0, 0, clip_notch_z])
                arc_shell(clip_r + 1, clip_r - notch_d,
                          notch_h, groove_ang);
        }
    }
}

// ── Guard Holes ───────────────────────────────────────────────────
// Small holes through the outer wall for ant access to the torus groove.
// Positioned at the lower part of the groove where liquid collects.
module station_guard_holes() {
    hole_length = station_od / 2 - torus_groove_r + 1;
    // Indices to skip: clip grooves at 60°, 180°, 300°
    // = indices 2, 6, 10 at 30° spacing (360/12)
    skip = guard_hole_count / clip_count;  // every 4th hole
    skip_start = round((360 / tab_count / 2) / (360 / guard_hole_count));  // index 2

    for (i = [0 : guard_hole_count - 1])
        if ((i - skip_start) % skip != 0)
            rotate([0, 0, i * (360 / guard_hole_count)])
                translate([torus_groove_r, 0, guard_hole_z])
                    rotate([0, 90, 0])
                        cylinder(h = hole_length, d = guard_hole_dia);
}

// ── Side Grip Scallops ───────────────────────────────────────────
// Oval indents on the outer wall for grip.
// Ellipsoid centered at station_scallop_z — natural taper stops
// smoothly before the bottom floor.
module station_side_scallops() {
    for (i = [0 : scallop_count - 1])
        rotate([0, 0, scallop_offset + i * (360 / scallop_count)])
            translate([station_od / 2, 0, station_scallop_z])
                scale([scallop_depth, scallop_width / 2, scallop_height / 2])
                    sphere(r = 1);
}

// ── Render ────────────────────────────────────────────────────────
crosssection(station_od) bait_station();
