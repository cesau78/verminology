// Seal Ring for V2 Liquid Bait Station — Print in TPU 90A
// Flat annular disk that press-fits into a groove on the reservoir
// bottom face.  When assembled, compresses against the outer bait
// barrier wall top edge to seal dry side from wet feeding area.
// Notched at each labyrinth tube position so the tubes pass through.
//
// Orientation: z = 0 at bottom face (barrier contact); top into groove.

include <common.scad>

module seal_ring() {
    difference() {
        // Flat annular disk
        difference() {
            cylinder(h = seal_ring_h, d = seal_ring_od);
            translate([0, 0, -0.01])
                cylinder(h = seal_ring_h + 0.02, d = seal_ring_id);
        }
        // Notches for labyrinth tubes (hull spans both legs of each tube)
        for (i = [0 : labyrinth_count - 1])
            rotate([0, 0, labyrinth_angle_start + i * (360 / labyrinth_count)])
                hull() {
                    translate([labyrinth_outer_r, 0, -1])
                        cylinder(h = seal_ring_h + 2,
                                 d = labyrinth_od + 2 * clearance);
                    translate([labyrinth_inner_r, 0, -1])
                        cylinder(h = seal_ring_h + 2,
                                 d = labyrinth_od + 2 * clearance);
                }
    }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(seal_ring_od + 4) seal_ring();
