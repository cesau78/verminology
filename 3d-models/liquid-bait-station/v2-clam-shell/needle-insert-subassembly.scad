// Needle insert + TPU gasket — sub-assembly preview (F5).
// Side groove on base OD (2 mm tall × 1 mm deep); crosssection_view helps inspect the torus.
// Default: mated. Set exploded = true to separate.

include <needle-insert-lib.scad>

crosssection_view = true;
exploded          = false;
explode_gap       = 14;

gasket_z_seated = needle_gasket_assembly_z;
insert_z_exploded = -explode_gap * 0.35;
gasket_z_exploded = gasket_z_seated + explode_gap * 0.65;

crosssection(needle_insert_disk_od * 2) {
    color("DimGray", 0.95)
        translate([0, 0, exploded ? insert_z_exploded : 0])
            needle_insert();
    color("MediumSeaGreen", 0.85)
        translate([0, 0, exploded ? gasket_z_exploded : gasket_z_seated])
            needle_gasket_ring();
}
