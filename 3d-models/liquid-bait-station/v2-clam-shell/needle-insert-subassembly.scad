// Station shell + needle insert + TPU ring — sub-assembly preview (F5). Ring on upper base step OD; crosssection_view for torus.
// Default: mated. Set exploded = true to separate insert and gasket from the pocket.

include <needle-insert-lib.scad>
use <station.scad>

crosssection_view = true;
exploded          = false;
explode_gap       = 14;

gasket_z_seated = needle_gasket_assembly_z;
insert_z_exploded = -explode_gap * 0.35;
gasket_z_exploded = gasket_z_seated + explode_gap * 0.65;

crosssection(station_od * 2) {
    color("SlateGray", 0.8)
        bait_station();
    color("DimGray", 0.95)
        translate([0, 0, exploded ? insert_z_exploded : 0])
            needle_insert();
    color("MediumSeaGreen", 0.85)
        translate([0, 0, exploded ? gasket_z_exploded : gasket_z_seated])
            needle_gasket_ring();
}
