# v2.5.0 — Integrated Needle Pin, Bolt Lock, Simplified Parts

**Date:** Apr 6 – 8, 2026

## Summary

Major simplification: the separate needle insert, gasket, and hex socket are replaced
by a needle pin integrated directly into the station floor. Snap-fit retention clips
are replaced with M3 vertical bolt locks. The station grows taller to accommodate the
bolt hardware and larger tray gap.

## Changes from v2.4.1

### Retention system overhaul (Apr 6–7)
- Retention clips beefed up, then replaced with wall slots and bottom barbs
- Barb channel/catch geometry on bore wall with land ribs
- Guard holes suppressed at former clip azimuths
- Retention tab foot anchored to tray floor with inward-facing V groove

### Needle insert consolidation (Apr 7)
- Needle insert merged into single SCAD file (library pattern removed)
- Inner rail disk moved after needle pocket to prevent erasure

### Bolt lock and integrated pin (Apr 8)
- Threaded needle insert replaced with M3×20 vertical bolt lock:
  two captive hex-pocket nuts on reservoir underside at 90°/270°,
  station bosses with cap-head counterbore from below
- Needle pin merged directly into station body — no separate insert,
  threads, hex socket, or TPU gasket
- Removed: `needle-insert.scad`, `needle-insert-key.scad`,
  `needle-gasket.scad`, `needle-gasket-export.scad`,
  `needle-insert-subassembly.scad`
- Station height raised to 23 mm (tray gap 11 mm) so bolt tip sits
  flush with nut pocket top
- Product stamp rotated 90°; tab slot extended inward for clean bore
  intersection

## Artifacts

| File | Part |
|------|------|
| `reservoir.stl` | Reservoir with bolt lock bosses and captive nut pockets |
| `station.stl` | Station with integrated needle pin and bolt bosses (bottom stamp) |
| `needle-seal.stl` | TPU needle seal for reservoir floor |
