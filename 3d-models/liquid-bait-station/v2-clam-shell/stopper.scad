// Flow Stopper for V2 Liquid Bait Station
// Spring-loaded piston that blocks flow through the needle seal when
// the reservoir is removed from the station.  The station needle pushes
// the stopper back against the spring to open the flow path.
//
// Orientation: z = 0 at bottom face.

include <common.scad>

module stopper() {
    stopper_body_h = stopper_h - stopper_bottom_disk_h;
    difference() {
        union() {
            cylinder(h = stopper_bottom_disk_h, d = stopper_bottom_disk_od);
            translate([0, 0, stopper_bottom_disk_h])
                cylinder(h = stopper_body_h, d = stopper_od);
        }
        translate([0, 0, stopper_h - stopper_bore_depth])
            cylinder(h = stopper_bore_depth + 0.01, d = stopper_bore_id);
    }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(max(stopper_od, stopper_bottom_disk_od)) stopper();
