# v2.4.1 — Needle Seal and CI Fixes

**Date:** Apr 3 – 4, 2026

## Summary

Patch release fixing needle seal geometry and consolidating the CI pipeline.

## Changes from v2.4.0

- Needle seal flange inner bore aligned to match disk bore (`seal_hole_dia`)
  for a continuous internal diameter
- TPU gasket OD reduced by 0.2 mm (`needle_insert_disk_od_clearance_dia` → 0.4 mm)
- CI workflows merged into a single ordered build pipeline:
  prototype stamp + STL export → assembly validation → optional production export
- Moved stray v1 file out of v2 directory

## Artifacts

| File | Part |
|------|------|
| `reservoir.stl` | Reservoir |
| `station.stl` | Station (bottom stamp) |
| `needle-insert.stl` | Needle insert |
| `needle-gasket.stl` | TPU gasket |
| `needle-seal.stl` | TPU needle seal |
