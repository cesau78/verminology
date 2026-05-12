// Reservoir QR Code Inlay — per-unit multi-color QR code for the
// reservoir top face.  Build scripts set `qr_url` and `qr_half`
// in build-stamp.scad before each render.
//
//   qr_half = "background"  →  fills around QR modules (same color as reservoir body)
//   qr_half = "contrast"    →  QR data modules (contrasting color, e.g. white)
//
// Quick manual generation (PowerShell):
//   .\scripts\Export-OpenScadStl.ps1 -QrTag
//   .\scripts\Export-OpenScadStl.ps1 -QrTag -QrTagCount 10

include <common.scad>
use <../lib/qr.scad>

// qr_half MUST come only from ../build-stamp.scad (via common.scad).
// Do not assign qr_half here — it would overwrite the exporter's value so
// both background and contrast STLs exported the same geometry.

preview_url = "https://verminology.com/items?id=00000000-0000-0000-0000-000000000000";
active_url  = (qr_url == "") ? preview_url : qr_url;

size  = qr_tag_size;
depth = qr_tag_depth;

module qr_background() {
    difference() {
        cube([size, size, depth]);
        translate([size / 2, size / 2, -0.01])
            qr(active_url,
               error_correction = "M",
               width      = size,
               height     = size,
               thickness  = depth + 0.02,
               center     = true);
    }
}

module qr_contrast() {
    translate([size / 2, size / 2, 0])
        qr(active_url,
           error_correction = "M",
           width      = size,
           height     = size,
           thickness  = depth,
           center     = true);
}

// Position on the reservoir top face, matching the pocket location.
translate([0, 0, reservoir_height - depth])
    rotate([0, 0, 90])
        translate([-size / 2, qr_tag_pocket_y - size / 2, 0])
            if (qr_half == "background")
                qr_background();
            else
                qr_contrast();
