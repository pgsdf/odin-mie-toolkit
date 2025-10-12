package mie
import "core:math"

c_mul  :: proc(a,b: Complex) -> Complex
c_sub  :: proc(a,b: Complex) -> Complex
mie_sphere :: proc(m: Complex, x:f64) -> MieResult
snow_eps_eff :: proc(freq_GHz, T_C, rho_snow, LWC: f64, use_mg: bool = false) -> (eps_eff: Complex, m_eff: Complex)

SnowPSD :: struct { N0: f64; Lambda: f64 }

_simpson :: proc(f: proc(x:f64)->f64, a,b: f64, n:int)->f64 {
    if n%2!=0 { n+=1 }
    h := (b-a)/cast(f64)n
    s := f(a) + f(b)
    for i in 1..n-1 {
        x := a + cast(f64)i*h
        c := 4.0
        if (i%2)==0 { c = 2.0 }
        s += c * f(x)
    }
    return s*h/3.0
}

gamma_from_snow :: proc(freq_GHz, T_C, rho_snow, LWC: f64, psd: SnowPSD) -> f64 {
    c := 299_792_458.0
    _, m_eff := snow_eps_eff(freq_GHz, T_C, rho_snow, LWC, false)
    f := proc(D_mm: f64) -> f64 {
        if D_mm <= 0.0 { return 0.0 }
        N_D := psd.N0 * math.exp(-psd.Lambda * D_mm)
        r := (D_mm/1000.0)/2.0
        x := 2.0*math.pi*r/(c/(freq_GHz*1e9))
        res := mie_sphere(m_eff, x)
        sigma_ext := res.Q_ext * math.pi * r * r
        N_r := N_D * 2000.0
        return N_r * sigma_ext
    }
    kappa := _simpson(f, 0.1, 10.0, 800)
    return 4.343 * 1000.0 * kappa
}
