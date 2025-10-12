package mie
import "core:math"

// Effective medium mixing for snow: CRIM (dry) and Maxwell-Garnett (wet).

c_new  :: proc(re, im: f64) -> Complex
c_add  :: proc(a,b: Complex) -> Complex
c_sub  :: proc(a,b: Complex) -> Complex
c_mul  :: proc(a,b: Complex) -> Complex
c_div  :: proc(a,b: Complex) -> Complex
complex_sqrt :: proc(z: Complex) -> Complex

ice_m     :: proc(freq_GHz, T_C: f64) -> Complex
water_m_from_MW2004 :: proc(freq_GHz, T_C: f64) -> Complex

eps_from_m :: proc(m: Complex) -> Complex { return c_mul(m, m) }

CRIM_dry_snow_eps :: proc(freq_GHz, T_C, rho_snow: f64) -> Complex {
    rho_ice := 917.0
    phi_i := rho_snow / rho_ice
    if phi_i < 0.0 { phi_i = 0.0 } ; if phi_i > 0.7 { phi_i = 0.7 }
    eps_air := c_new(1.0, 0.0)
    eps_ice := eps_from_m(ice_m(freq_GHz, T_C))
    s_air := complex_sqrt(eps_air)
    s_ice := complex_sqrt(eps_ice)
    s_eff := c_add(c_mul(c_new(1.0 - phi_i, 0.0), s_air), c_mul(c_new(phi_i, 0.0), s_ice))
    return c_mul(s_eff, s_eff)
}

MG_eps :: proc(eps_host: Complex, eps_incl: Complex, phi_incl: f64) -> Complex {
    num  := c_add(eps_incl, c_mul(c_new(2.0,0.0), eps_host))
    num  = c_add(num, c_mul(c_new(2.0*phi_incl,0.0), c_sub(eps_incl, eps_host)))
    den  := c_add(eps_incl, c_mul(c_new(2.0,0.0), eps_host))
    den  = c_sub(den, c_mul(c_new(phi_incl,0.0), c_sub(eps_incl, eps_host)))
    return c_mul(eps_host, c_div(num, den))
}

snow_eps_eff :: proc(freq_GHz, T_C, rho_snow, LWC: f64, use_mg: bool = false) -> (eps_eff: Complex, m_eff: Complex) {
    if LWC <= 0.0 && !use_mg {
        eps := CRIM_dry_snow_eps(freq_GHz, T_C, rho_snow)
        return eps, complex_sqrt(eps)
    }
    mi := ice_m(freq_GHz, T_C)
    mw := water_m_from_MW2004(freq_GHz, T_C)
    eps_i := eps_from_m(mi)
    eps_w := eps_from_m(mw)
    phi_w := LWC / 1000.0
    if phi_w < 0 { phi_w = 0 } ; if phi_w > 0.4 { phi_w = 0.4 }
    eps_eff := MG_eps(eps_i, eps_w, phi_w)
    return eps_eff, complex_sqrt(eps_eff)
}
