# v2.5.1 — Bolt Boss Fix, Needle Seal Flange Fit

**Date:** Apr 9, 2026

## Summary

Patch release fixing two assembly interference issues and improving the version stamp.

## Changes from v2.5.0

- **Bolt lock boss raised:** Bottom of reservoir screw boss moved from `z = −3` to
  `z = 0` (flush with reservoir floor) to eliminate interference with the outer bait
  barrier ring. Station bolt boss extended upward to meet the new reservoir boss bottom.

- **Needle seal flange widened:** Bottom flange OD increased from 20 mm to 23.4 mm
  (`inner_bait_barrier_id`) so the TPU flange nests snugly inside the inner barrier
  ring. Disk and barb layers unchanged.

- **Version stamp centered:** Radial offset removed; stamp now centered on station
  bottom. Brand font increased to 6 mm (was 5), product/version to 4 mm (was 3).

- **Build config renamed:** `print-stamp-config.json` → `build-config.json`;
  `mesh_preview` → `draft_mesh` for clarity.

## Artifacts

| File | Part |
|------|------|
| `reservoir.stl` | Reservoir with raised bolt bosses |
| `station.stl` | Station (centered bottom stamp: v2.5.1 Prototype) |
| `needle-seal.stl` | TPU needle seal with wider flange |
