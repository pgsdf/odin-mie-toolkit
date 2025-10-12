package mie
// TEOS-10 distinguishes Absolute Salinity SA (g/kg) and Practical Salinity SP (unitless).
// A full SA→SP requires regional delta-S corrections (SRK/Delta_SA) and pressure.
// Here we provide:
//   - a simple bulk conversion for open ocean where SP ≈ SA / 1.004715
//   - a pass-through for advanced users supplying SP directly.
// Replace with a full GSW Delta_SA routine if you need high accuracy regionally.

SA_to_SP_bulk :: proc(SA_g_per_kg: f64) -> f64 {
    // Open-ocean average: SA ≈ (35.16504/35) * SP  →  SP ≈ SA / 1.004715
    if SA_g_per_kg < 0.0 { SA_g_per_kg = 0.0; }
    return SA_g_per_kg / 1.004715;
}
