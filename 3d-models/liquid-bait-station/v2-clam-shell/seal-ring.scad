// Seal Ring for V2 Liquid Bait Station — Print in TPU 90A
// Flat annular disk that press-fits into a groove on the reservoir
// bottom face.  When assembled, compresses against the outer bait
// barrier wall top edge to seal dry side from wet feeding area.
//
// Orientation: z = 0 at bottom face (barrier contact); top into groove.

include <common.scad>

module seal_ring() {
    difference() {
        cylinder(h = seal_ring_h, d = seal_ring_od);
        translate([0, 0, -0.01])
            cylinder(h = seal_ring_h + 0.02, d = seal_ring_id);
    }
}

// ── Render ────────────────────────────────────────────────────────
crosssection(seal_ring_od + 4) seal_ring();
