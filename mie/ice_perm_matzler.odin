package mie
import "core:math"

// Debye-style scaffold for pure ice; replace band presets with literature values as needed.

c_new  :: proc(re, im: f64) -> Complex
c_sub  :: proc(a,b: Complex) -> Complex
c_div  :: proc(a,b: Complex) -> Complex
c_mul  :: proc(a,b: Complex) -> Complex
complex_sqrt :: proc(z: Complex) -> Complex

IceDebyeParams :: struct {
    eps_inf: f64
    eps_s0:  f64
    d_eps_s_dT: f64
    tau0_ps: f64
    Ea_over_R: f64
    T_ref_C: f64
}

ICE_DEBYE_BANDS := map[string]IceDebyeParams{
    "default" = IceDebyeParams{ eps_inf=3.05, eps_s0=3.19, d_eps_s_dT=-1.2e-3, tau0_ps=5.0e4, Ea_over_R=6200.0, T_ref_C=-10.0 },
    "xband"   = IceDebyeParams{ eps_inf=3.05, eps_s0=3.18, d_eps_s_dT=-1.5e-3, tau0_ps=4.0e4, Ea_over_R=6000.0, T_ref_C=-15.0 },
    "kuband"  = IceDebyeParams{ eps_inf=3.05, eps_s0=3.17, d_eps_s_dT=-1.4e-3, tau0_ps=3.0e4, Ea_over_R=6000.0, T_ref_C=-15.0 },
    "kaband"  = IceDebyeParams{ eps_inf=3.05, eps_s0=3.16, d_eps_s_dT=-1.3e-3, tau0_ps=2.0e4, Ea_over_R=5800.0, T_ref_C=-15.0 },
    "wband"   = IceDebyeParams{ eps_inf=3.05, eps_s0=3.15, d_eps_s_dT=-1.2e-3, tau0_ps=1.0e4, Ea_over_R=5600.0, T_ref_C=-15.0 },
}

_eps_s_of_T :: proc(p: IceDebyeParams, T_C: f64) -> f64 { return p.eps_s0 + p.d_eps_s_dT*(T_C - p.T_ref_C) }
_tau_ps_of_T :: proc(p: IceDebyeParams, T_C: f64) -> f64 {
    T_K := T_C + 273.15; Tref_K := p.T_ref_C + 273.15
    return p.tau0_ps * math.exp(p.Ea_over_R * (1.0/T_K - 1.0/Tref_K))
}

ice_eps_matzler :: proc(freq_GHz, T_C: f64, band: string = "default") -> (eps_re: f64, eps_im: f64) {
    p, ok := ICE_DEBYE_BANDS[band]; if !ok { p = ICE_DEBYE_BANDS["default"] }
    w := 2.0*math.pi*freq_GHz*1.0e9; tau := _tau_ps_of_T(p, T_C)*1e-12
    delta := _eps_s_of_T(p, T_C) - p.eps_inf; denom := 1.0 + (w*tau)*(w*tau)
    return p.eps_inf + delta/denom, delta*(w*tau)/denom
}
ice_m_matzler :: proc(freq_GHz, T_C: f64, band: string = "default") -> Complex {
    er, ei := ice_eps_matzler(freq_GHz, T_C, band)
    return complex_sqrt(c_sub(c_new(er,0), c_new(0,ei)))
}
