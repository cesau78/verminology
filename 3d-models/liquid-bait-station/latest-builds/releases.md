# Liquid Bait Station — release notes

## Version

**2.4.0** (v2 clam-shell)

Stamp text in exported STLs follows `print-stamp-config.json` (e.g. `v2.4.0 Prototype` when `preview` is true).

## Summary

V2 open-tray **clam-shell** geometry: station, reservoir, **needle insert** with six flex posts on the **gasket land** (upper base step), **2 mm** top barb with **60°** ramp geometry, and pocket sizing capped so the **inner bait barrier** ring is not hollowed by the needle pocket. **TPU needle gasket** (torus) and **needle seal** for the reservoir floor; **rail filler** back plate between inner-barrier guide rails restored.

**Removed** obsolete `slit-valve.scad` and `shipping-plug.scad` (superseded by the needle seal path).

## Artifacts

Exports go under **`latest-builds/<product_version>/`** (e.g. `latest-builds/v2.4.0/`), where `<product_version>` is `product_version` from `print-stamp-config.json` (each `stl` path uses the `{product_version}` placeholder; scripts substitute it).

| File | Part |
|------|------|
| `reservoir.stl` | Reservoir |
| `station.stl` | Station (bottom stamp when enabled in config) |
| `needle-insert.stl` | Needle insert |
| `needle-gasket.stl` | TPU ring for upper insert step |
| `needle-seal.stl` | TPU seal for reservoir floor / pin |

Regenerate with `scripts/Export-OpenScadStl.ps1` or `scripts/export-open-scad-stl.sh` from `3d-models/liquid-bait-station`.

Legacy v1 double-torus STLs may sit in the same version folder if copied manually; they are not produced by the v2 export list.
