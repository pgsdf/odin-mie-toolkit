package mie
import "core:math"
// Requires: complex.odin (c_new, c_sub, complex_sqrt)

/// Approximate complex permittivity of pure ice at microwave frequencies.
/// eps' ~ 3.15 (weak T dependence), eps'' increases with f and T.
IceResult :: struct { eps_re: f64; eps_im: f64 }

c_new  :: proc(re, im: f64) -> Complex
c_sub  :: proc(a,b: Complex) -> Complex
complex_sqrt :: proc(z: Complex) -> Complex

_A_of_T :: proc(T_C:f64)->f64 { return 1.5e-3 * (1.0 + 0.01*(T_C + 15.0)) }
_B_of_T :: proc(T_C:f64)->f64 { return 1.0e-4 * (1.0 + 0.02*(T_C + 15.0)) }

ice_eps :: proc(freq_GHz, T_C: f64) -> IceResult {
    eps_re := 3.15 - 1.5e-3*(T_C + 15.0)
    if eps_re < 3.05 { eps_re = 3.05 }
    if eps_re > 3.18 { eps_re = 3.18 }
    f := freq_GHz
    eps_im := _A_of_T(T_C)*f + _B_of_T(T_C)*f*f
    return IceResult{eps_re, eps_im}
}

ice_m :: proc(freq_GHz, T_C: f64) -> Complex {
    e := ice_eps(freq_GHz, T_C)
    return complex_sqrt(c_sub(c_new(e.eps_re, 0.0), c_new(0.0, e.eps_im)))
}
