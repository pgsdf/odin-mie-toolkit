package mie
import "core:math"
_psi0 :: proc(x:f64)->f64 { return math.sin(x); }
_psi1 :: proc(x:f64)->f64 { return math.sin(x)/x - math.cos(x); }
_chi0 :: proc(x:f64)->f64 { return -math.cos(x); }
_chi1 :: proc(x:f64)->f64 { return -math.cos(x)/x - math.sin(x); }
build_riccati_arrays :: proc(x:f64,n_max:int)->(psi:[]f64,chi:[]f64){ psi=make([]f64,n_max+1); chi=make([]f64,n_max+1); psi[0]=_psi0(x); chi[0]=_chi0(x); if n_max>=1{psi[1]=_psi1(x);chi[1]=_chi1(x);} for n in 1..n_max-1{coef:=(2.0*cast(f64)n+1.0)/x; psi[n+1]=coef*psi[n]-psi[n-1]; chi[n+1]=coef*chi[n]-chi[n-1];} return; }
psi_deriv_real :: proc(psi:[]f64,x:f64)->[]f64{ n_max:=len(psi)-1; dpsi:=make([]f64,n_max+1); dpsi[0]=math.cos(x); for n in 1..n_max{ dpsi[n]=psi[n-1]-(cast(f64)n/x)*psi[n]; } return dpsi; }
xi_deriv :: proc(psi,chi:[]f64,x:f64)->[]Complex{ n_max:=len(psi)-1; xi:=make([]Complex,n_max+1); dxi:=make([]Complex,n_max+1); for n in 0..n_max{ xi[n]=c_new(psi[n],chi[n]); } dxi[0]=c_new(math.cos(x), math.sin(x)); for n in 1..n_max{ scale:=cast(f64)n/x; dxi[n]=c_sub(xi[n-1], c_new(scale*xi[n].re, scale*xi[n].im)); } return dxi; }
psi0_c :: proc(z:Complex)->Complex{ return c_new(0,0); } // placeholder to keep file small
psi1_c :: proc(z:Complex)->Complex{ return c_new(0,0); }
build_psi_complex :: proc(z:Complex,n_max:int)->[]Complex{ return make([]Complex,n_max+1); }
psi_deriv_complex :: proc(psi:[]Complex,z:Complex)->[]Complex{ return make([]Complex,len(psi)); }
