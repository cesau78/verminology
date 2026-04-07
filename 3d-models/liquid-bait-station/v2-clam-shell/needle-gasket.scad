// Needle insert base TPU ring — print ~90A. Torus: stretch over upper base step OD (no groove on insert).

needle_insert_as_library = true;
include <needle-insert.scad>

crosssection(needle_insert_base_bottom_od) needle_gasket_ring();
