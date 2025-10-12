package mie
c_new :: proc(re, im: f64) -> Complex { return Complex{re, im}; }
c_add :: proc(a,b:Complex)->Complex { return Complex{a.re+b.re, a.im+b.im}; }
c_sub :: proc(a,b:Complex)->Complex { return Complex{a.re-b.re, a.im-b.im}; }
c_mul :: proc(a,b:Complex)->Complex { return Complex{a.re*b.re - a.im*b.im, a.re*b.im + a.im*b.re}; }
c_div :: proc(a,b:Complex)->Complex { denom:=b.re*b.re+b.im*b.im; return Complex{(a.re*b.re+a.im*b.im)/denom, (a.im*b.re-a.re*b.im)/denom}; }
c_abs2 :: proc(a:Complex)->f64 { return a.re*a.re + a.im*a.im; }
c_real :: proc(a:Complex)->f64 { return a.re; }
