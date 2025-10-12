package main
import "core:fmt"
import "core:math"
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
    freq := 9.65; T := -5.0; rho := 200.0; lwc := 0.0
    rates := []f64{0.25, 0.5, 1, 2, 4}
    fits := []mie.SnowPSDFit{ .Generic, .SekhonSrivastava, .GunnMarshallRimed }
    names := []string{ "Generic", "SekhonSrivastava", "GunnMarshallRimed" }
    for fidx in 0..len(fits)-1 {
        G := make([]f64, len(rates))
        for i in 0..len(rates)-1 {
            psd := mie.snow_psd_fit(rates[i], fits[fidx])
            psd.N0 = psd.N0 * (rates[i]/1.0)
            G[i] = mie.gamma_from_snow(freq, T, rho, lwc, psd)
        }
        k, a := fit_power_law(rates, G)
        fmt.printf("%s: k=%.6g  alpha=%.3f\n", names[fidx], k, a)
    }
}
