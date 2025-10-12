/// Bulk attenuation from Mie + DSD integration.
/// 
/// `gamma_from_Mie_MarshallPalmer(f_GHz, T_C, R_mm_per_h, use_double)`
/// computes γ in dB/km by integrating extinction over the Marshall–Palmer DSD.
/// 
/// Units:
///   f_GHz: [GHz], T_C: [°C], R_mm_per_h: [mm/h], returns γ: [dB/km]
/// 
/// Notes:
///   - Uses Simpson’s rule over drop radius; limits cover drizzle–heavy rain.
///   - For spheres, H/V polarizations are identical (see `polar.odin`).
package mie
import "core:math"
mp_N0 :: f64 = 8000.0
mp_Lambda :: proc(R:f64)->f64 { if R<0.01{R=0.01}; return 4.1*math.pow(R,-0.21); }
_simpson :: proc(f: proc(r:f64)->f64, a,b:f64, n:int)->f64 { if n%2!=0{n+=1}; h:=(b-a)/cast(f64)n; s:=f(a)+f(b); for i in 1..n-1{ x:=a+cast(f64)i*h; c:=4.0; if i%2==0{c=2.0}; s+=c*f(x);} return s*h/3.0; }
gamma_from_Mie_MarshallPalmer :: proc(freq_GHz, T_C, R:f64, use_double: bool=true)->f64 {
    c := 299_792_458.0
    m := when use_double do water_m_from_MW2004(freq_GHz, T_C) else water_m_from_single_debye(freq_GHz, T_C)
    f := proc(r:f64)->f64 { if r<=0{return 0}; D:=2000.0*r; N:=mp_N0*math.exp(-mp_Lambda(R)*D); Nr:=N*2000.0; x:=2.0*math.pi*r/(c/(freq_GHz*1e9)); res:=mie_sphere(m,x); sigma:=res.Q_ext*math.pi*r*r; return Nr*sigma; }
    kappa := _simpson(f, 0.00005, 0.00500, 800); return 4.343*1000.0*kappa;
}
gamma_from_Mie_GammaDSD :: proc(freq_GHz, T_C, N0, mu, Lam: f64, use_double: bool=true)->f64 {
    c := 299_792_458.0
    m := when use_double do water_m_from_MW2004(freq_GHz, T_C) else water_m_from_single_debye(freq_GHz, T_C)
    f := proc(r:f64)->f64 { if r<=0{return 0}; D:=2000.0*r; N:=N0*math.pow(D,mu)*math.exp(-Lam*D); Nr:=N*2000.0; x:=2.0*math.pi*r/(c/(freq_GHz*1e9)); res:=mie_sphere(m,x); sigma:=res.Q_ext*math.pi*r*r; return Nr*sigma; }
    kappa := _simpson(f, 0.00005, 0.00600, 900); return 4.343*1000.0*kappa;
}
