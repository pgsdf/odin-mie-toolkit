package main
import "core:fmt"
import "core:math"
import "core:os"
import "../mie"

fit_power_law :: proc(R: []f64, G: []f64) -> (k: f64, alpha: f64) {
    n := len(R); sx, sy, sxx, sxy := 0.0, 0.0, 0.0, 0.0
    for i in 0..n-1 { x := math.log(R[i]); y := math.log(G[i]); sx+=x; sy+=y; sxx+=x*x; sxy+=x*y }
    denom := cast(f64)n*sxx - sx*sx
    alpha := (cast(f64)n*sxy - sx*sy)/denom
    ln_k := (sy - alpha*sx)/cast(f64)n
    return math.exp(ln_k), alpha
}

main :: proc() {
    freq_GHz := 9.65; T_C := -5.0; rho := 200.0; lwc := 0.0; rate := 1.0
    args := os.args
    for i in 0..len(args)-1 {
        if args[i] == "--freq" && i+1 < len(args) { freq_GHz = os.str_to_f64(args[i+1]) }
        if args[i] == "--temp" && i+1 < len(args) { T_C = os.str_to_f64(args[i+1]) }
        if args[i] == "--rho"  && i+1 < len(args) { rho = os.str_to_f64(args[i+1]) }
        if args[i] == "--lwc"  && i+1 < len(args) { lwc = os.str_to_f64(args[i+1]) }
        if args[i] == "--rate" && i+1 < len(args) { rate = os.str_to_f64(args[i+1]) }
    }
    base := mie.snow_psd_from_rate(rate)
    rates := []f64{ max(0.1, 0.25*rate), 0.5*rate, rate, 2*rate, 4*rate }
    G := make([]f64, len(rates))
    for i in 0..len(rates)-1 {
        psd := base; psd.N0 = base.N0 * (rates[i]/rate)
        G[i] = mie.gamma_from_snow(freq_GHz, T_C, rho, lwc, psd)
    }
    k, a := fit_power_law(rates, G)
    fmt.println("Snow fit at f=", freq_GHz, " GHz; T=", T_C, " °C; rho=", rho, " kg/m^3; LWC=", lwc, " kg/m^3")
    fmt.println("k=", k, "  alpha=", a)
}
max :: proc(a,b:f64)->f64 { if a>b { return a } else { return b } }
