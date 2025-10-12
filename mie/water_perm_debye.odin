package mie
import "core:math"
EPS0 :: f64 = 8.854187817e-12
c_new :: proc(re, im: f64) -> Complex
c_add :: proc(a,b:Complex)->Complex
c_sub :: proc(a,b:Complex)->Complex
c_div :: proc(a,b:Complex)->Complex
complex_sqrt :: proc(z:Complex)->Complex{ r:=math.hypot(z.re,z.im); t:=0.5*math.atan2(z.im,z.re); mag:=math.sqrt(r); return c_new(mag*math.cos(t),mag*math.sin(t)); }
water_eps_single_debye :: proc(freq_GHz, eps_s, eps_inf, tau_s: f64) -> Complex { w:=2.0*math.pi*freq_GHz*1e9; return c_add(c_new(eps_inf,0), c_div(c_new(eps_s-eps_inf,0), c_new(1, w*tau_s))); }
water_m_from_single_debye :: proc(freq_GHz, T_C: f64) -> Complex { _=T_C; return complex_sqrt(water_eps_single_debye(freq_GHz,80,4.9,8.5e-12)); }
MW2004_A := []f64{5.7230, 2.2379e-2, -7.1237e-4, 5.0478, -7.0315e-2, 6.0059e-4, 3.6143, 2.8841e-2, 1.3652e-1, 1.4825e-3, 2.4166e-4}
mw2004_eps_s :: proc(T_C: f64) -> f64 { return (3.70886e4 - 8.2168e1*T_C) / (4.21854e2 + T_C); }
mw2004_params :: proc(T_C: f64) -> (eps1, eps_inf, nu1, nu2: f64) { a:=MW2004_A; return a[0]+a[1]*T_C+a[2]*T_C*T_C, a[6]+a[7]*T_C, (45+T_C)/(a[3]+a[4]*T_C+a[5]*T_C*T_C), (45+T_C)/(a[8]+a[9]*T_C+a[10]*T_C*T_C); }
water_eps_MW2004 :: proc(freq_GHz, T_C: f64) -> Complex { es:=mw2004_eps_s(T_C); e1, ei, n1, n2 := mw2004_params(T_C); t1:=c_div(c_new(es-e1,0), c_add(c_new(1,0), c_new(0, freq_GHz/n1))); t2:=c_div(c_new(e1-ei,0), c_add(c_new(1,0), c_new(0, freq_GHz/n2))); return c_add(c_new(ei,0), c_add(t1,t2)); }
water_m_from_MW2004 :: proc(freq_GHz, T_C: f64) -> Complex { return complex_sqrt(water_eps_MW2004(freq_GHz, T_C)); }
sw_conductivity_placeholder :: proc(S_ppt: f64, T_C: f64) -> f64 { sigma_ref:=4.2914; beta:=0.021; s_scale:=S_ppt/35.0; t_scale:=1.0+beta*(T_C-15.0); sig:=sigma_ref*s_scale*t_scale; if sig<0.05{sig=0.05}; return sig; }
water_m_from_MW2004_seawater :: proc(freq_GHz, T_C, S_ppt: f64) -> Complex { eps_pw:=water_eps_MW2004(freq_GHz, T_C); w:=2.0*math.pi*freq_GHz*1e9; sig:=sw_conductivity_placeholder(S_ppt,T_C); eps_sea:=c_sub(eps_pw, c_new(0, sig/(EPS0*w))); return complex_sqrt(eps_sea); }
