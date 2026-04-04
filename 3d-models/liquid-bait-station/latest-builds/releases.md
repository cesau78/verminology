# Liquid Bait Station — release notes

## Version

**2.4.0** (v2 clam-shell)

Stamp text follows `print-stamp-config.json` when not in production mode (e.g. `v2.4.0 Prototype` when `preview` is true).

## Summary

V2 open-tray **clam-shell** geometry: station, reservoir, **needle insert** with six flex posts on the **gasket land** (upper base step), **2 mm** top barb with **60°** ramp geometry, and pocket sizing capped so the **inner bait barrier** ring is not hollowed by the needle pocket. **TPU needle gasket** (torus) and **needle seal** for the reservoir floor; **rail filler** back plate between inner-barrier guide rails restored.

**Removed** obsolete `slit-valve.scad` and `shipping-plug.scad` (superseded by the needle seal path).

## Artifacts

STL paths in `print-stamp-config.json` use `{version_folder}`, expanded by the export scripts:

| Build | Output folder | Stamp |
|--------|----------------|--------|
| Local default; **Actions** *Liquid bait station — build* on push to `main` | `latest-builds/<product_version>-prototype/` | Adds ` Prototype` when `preview` is true |
| Production (`LBS_PRODUCTION=1`, e.g. **Liquid bait station — build** with production export enabled) | `latest-builds/<product_version>/` | Version only (no Prototype) |

Mesh quality for exported STLs uses `$fn = 128` when `mesh_preview=false` (see `v2-clam-shell/common.scad`).

| File | Part |
|------|------|
| `reservoir.stl` | Reservoir |
| `station.stl` | Station (bottom stamp when enabled in config) |
| `needle-insert.stl` | Needle insert |
| `needle-gasket.stl` | TPU ring for upper insert step |
| `needle-seal.stl` | TPU seal for reservoir floor / pin |

Regenerate: `scripts/Export-OpenScadStl.ps1` or `scripts/export-open-scad-stl.sh` from `3d-models/liquid-bait-station`. For a production folder locally: `LBS_PRODUCTION=1 ./scripts/export-open-scad-stl.sh` (bash) or `$env:LBS_PRODUCTION='1'; .\scripts\Export-OpenScadStl.ps1` (PowerShell).

**Production on GitHub:** Actions → *Liquid bait station — build* → *Run workflow*. Enable *production STL export*, set `ref` to your release tag or SHA, and optionally set `verify_product_version` to match `print-stamp-config.json`.

Legacy v1 double-torus STLs may sit in the same version folder if copied manually; they are not produced by the v2 export list.
