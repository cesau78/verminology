// Needle insert base gasket — print TPU ~90A (torus for OD groove).
// Inner R < groove floor, outer R > base OD; stretch over end and roll into side groove.

include <needle-insert-lib.scad>

crosssection(needle_insert_disk_od) needle_gasket_ring();
