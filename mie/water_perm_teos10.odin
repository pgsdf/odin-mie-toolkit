/// Seawater refractive index using MW2004 pure‑water ε and TEOS‑10 conductivity.
/// 
/// Functions:
///   - `water_m_from_MW2004_seawater_TEOS(f_GHz, T_C, SP, p_dbar)`
///   - `water_m_from_MW2004_seawater_TEOS_SA(f_GHz, T_C, SA_g_per_kg, p_dbar)`
/// 
/// Returns complex refractive index `m = sqrt(ε)` where
///   ε = ε_pw(MW2004) − j σ(TEOS‑10)/(ε0 ω), ω=2πf.
/// 
/// Units:
///   f_GHz: [GHz], T_C: [°C], SP: [ ], SA: [g/kg], p_dbar: [dbar]
/// 
/// References: Meissner & Wentz (2004); UNESCO TP‑44; TEOS‑10.
package mie
import "core:math"

EPS0 :: f64 = 8.854187817e-12

// Forward declarations from other modules
c_new :: proc(re, im: f64) -> Complex
c_add :: proc(a,b:Complex)->Complex
c_sub :: proc(a,b:Complex)->Complex
c_div :: proc(a,b:Complex)->Complex

// sqrt for complex
complex_sqrt :: proc(z:Complex)->Complex{
    r:=math.hypot(z.re,z.im); t:=0.5*math.atan2(z.im,z.re); mag:=math.sqrt(r); return c_new(mag*math.cos(t),mag*math.sin(t));
}

// --- Pure water models (as before, compact) ---
water_eps_single_debye :: proc(freq_GHz, eps_s, eps_inf, tau_s: f64) -> Complex {
    w:=2.0*math.pi*freq_GHz*1e9; return c_add(c_new(eps_inf,0), c_div(c_new(eps_s-eps_inf,0), c_new(1, w*tau_s)));
}
water_m_from_single_debye :: proc(freq_GHz, T_C: f64) -> Complex { _=T_C; return complex_sqrt(water_eps_single_debye(freq_GHz,80,4.9,8.5e-12)); }

MW2004_A := []f64{5.7230, 2.2379e-2, -7.1237e-4, 5.0478, -7.0315e-2, 6.0059e-4, 3.6143, 2.8841e-2, 1.3652e-1, 1.4825e-3, 2.4166e-4}
mw2004_eps_s :: proc(T_C: f64) -> f64 { return (3.70886e4 - 8.2168e1*T_C) / (4.21854e2 + T_C); }
mw2004_params :: proc(T_C: f64) -> (eps1, eps_inf, nu1, nu2: f64) { a:=MW2004_A; return a[0]+a[1]*T_C+a[2]*T_C*T_C, a[6]+a[7]*T_C, (45+T_C)/(a[3]+a[4]*T_C+a[5]*T_C*T_C), (45+T_C)/(a[8]+a[9]*T_C+a[10]*T_C*T_C); }
water_eps_MW2004 :: proc(freq_GHz, T_C: f64) -> Complex {
    es:=mw2004_eps_s(T_C); e1, ei, n1, n2 := mw2004_params(T_C)
    t1:=c_div(c_new(es-e1,0), c_add(c_new(1,0), c_new(0, freq_GHz/n1)))
    t2:=c_div(c_new(e1-ei,0), c_add(c_new(1,0), c_new(0, freq_GHz/n2)))
    return c_add(c_new(ei,0), c_add(t1,t2))
}
water_m_from_MW2004 :: proc(freq_GHz, T_C: f64) -> Complex { return complex_sqrt(water_eps_MW2004(freq_GHz, T_C)); }

// --- TEOS-10 seawater conductivity (calls teos10_conductivity.odin) ---
C_from_SP_S_per_m :: proc(SP: f64, t90_C: f64, p_dbar: f64 = 0.0) -> f64  // to be provided by teos10_conductivity.odin
water_m_from_MW2004_seawater_TEOS :: proc(freq_GHz, T_C, SP: f64, p_dbar: f64 = 0.0) -> Complex {
    // Compute pure-water epsilon, then subtract j*sigma/(eps0*omega)
    eps_pw := water_eps_MW2004(freq_GHz, T_C)
    w := 2.0*math.pi*freq_GHz*1.0e9
    sigma := C_from_SP_S_per_m(SP, T_C, p_dbar) // practical salinity SP (PSS-78), S/m
    eps_sea := c_sub(eps_pw, c_new(0, sigma/(EPS0*w)))
    return complex_sqrt(eps_sea)
}

// Convenience wrapper: accept Absolute Salinity SA (g/kg) and sea pressure p (dbar).
SA_to_SP_bulk :: proc(SA_g_per_kg: f64) -> f64  // from teos10_salinity.odin
Rp_from_p_T68 :: proc(p_dbar: f64, t68: f64) -> f64  // from teos10_pressure.odin
t68_from_t90 :: proc(t90: f64) -> f64  // from teos10_conductivity.odin

water_m_from_MW2004_seawater_TEOS_SA :: proc(freq_GHz, T_C, SA_g_per_kg: f64, p_dbar: f64 = 0.0) -> Complex {
    SP := SA_to_SP_bulk(SA_g_per_kg)
    // Compute pure-water epsilon at (f, T)
    eps_pw := water_eps_MW2004(freq_GHz, T_C)
    w := 2.0*math.pi*freq_GHz*1.0e9
    // Conductivity using TEOS-10, with pressure correction scaffold
    t68 := t68_from_t90(T_C)
    // Base conductivity at p=0
    sigma0 := C_from_SP_S_per_m(SP, T_C, 0.0)
    // Apply Rp(T68, p) scaling to R → C; here we scale sigma by Rp as a first-order effect
    Rp := Rp_from_p_T68(p_dbar, t68)
    sigma := sigma0 * Rp
    eps_sea := c_sub(eps_pw, c_new(0, sigma/(EPS0*w)))
    return complex_sqrt(eps_sea)
}
