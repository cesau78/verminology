# v2.4.0 — Clam-Shell with Needle Insert

**Date:** Mar 30 – Apr 3, 2026

## Summary

First formally versioned v2 release. Complete redesign: rigid 3D-printed reservoir
drops into an open tray station. Central push-pin activates a TPU needle seal in
the reservoir floor. Reservoir locks with two guide tabs into vertical slots.

## Changes from v1

- Rigid reservoir (~109 ml at 64 mm OD) replaces flexible bottle adapter
- Open tray station with flat 3 mm floor
- Push-pin with foil-piercing frustum tip and internal fluid channels
- TPU needle seal with interference-fit center bore, flange stop collar, and
  top retention barb
- Outer (2″ ID) and inner (1″ OD) bait barrier rings with radial ports
- Straight tab slide-lock (replaced bayonet twist-lock)
- Snap-fit retention clips with diamond barbs
- Side-wall oval grip scallops and 2 mm edge fillets
- Footprint reduced to 85 mm (3×3 on 256 mm build plate)
- Needle insert with coaxial pocket, guide rails, TPU gasket
- Bottom deboss stamp system with export scripts and CI pipeline
- Mesh export at $fn = 128

## Artifacts

| File | Part |
|------|------|
| `reservoir.stl` | Reservoir with guide tabs and retention clips |
| `station.stl` | Station with integrated pin and barrier rings (bottom stamp) |
| `needle-insert.stl` | Needle insert with retention clips |
| `needle-gasket.stl` | TPU ring for upper insert step |
| `needle-seal.stl` | TPU seal for reservoir floor |
