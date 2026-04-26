# v2.7.1 Prototype — Needle seal fit (TPU gasket)

**Date:** Apr 25, 2026

## Summary

Prototype build with a slightly larger center bore on the TPU needle seal (elastomer “gasket”) for easier pin removal while keeping light interference on the station needle.

## Changes from v2.7.0

- **Needle seal bore:** Diametral interference vs. the 6 mm pin reduced from **0.3 mm** to **0.2 mm** (`seal_hole_dia = pin_dia - 0.2` → 5.8 mm bore, 0.10 mm/side radial) in `v2-clam-shell/common.scad`.

## Artifacts

Export order starts with the seal (TPU print first).

| File | Part |
|------|------|
| `needle-seal.stl` | TPU needle seal (print first) |
| `reservoir.stl` | Reservoir |
| `station.stl` | Station (bottom stamp: v2.7.1 Prototype) |
| `stopper.stl` | Spring stopper |
| `grip.stl` | Grip tool |
| `anvil.stl` | Anvil tool |
