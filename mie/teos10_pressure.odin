package mie
import "core:math"

// UNESCO/TEOS-10 pressure correction scaffold for conductivity ratio:
//   R = Rt * rt(T68) * Rp(p, T68)   with Rp ≈ 1 at p=0 dbar.
// This file provides the interface and a placeholder Rp until the official
// polynomial coefficients (d_i, e_i) are inserted.
//
// TODO: replace with published UNESCO polynomial for Rp(T68, p).

Rp_from_p_T68 :: proc(p_dbar: f64, t68: f64) -> f64 {
    // Placeholder: mild linearized correction ~O(1e-4 per dbar) around 15°C.
    // This is NOT for operational use. Replace with UNESCO coefficients.
    // Keep Rp≥0.98 and ≤1.02 to avoid nonsense in extreme cases.
    alpha := 1.5e-4; // ~0.015% per dbar (illustrative)
    rp := 1.0 + alpha * p_dbar * (1.0 + 0.01*(t68 - 15.0))
    if rp < 0.98 { rp = 0.98 }
    if rp > 1.02 { rp = 1.02 }
    return rp
}
