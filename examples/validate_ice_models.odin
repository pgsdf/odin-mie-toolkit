package main
import "core:fmt"
import "../mie"
main :: proc() {
    bands := []string{"default","xband","kuband","kaband","wband"}
    freqs := []f64{5.3, 9.65, 13.6, 35.6, 94.0}
    Ts := []f64{-30.0, -10.0, 0.0}
    for b in 0..len(bands)-1 {
        fmt.println("Band:", bands[b])
        for i in 0..len(freqs)-1 {
            for j in 0..len(Ts)-1 {
                m := mie.ice_m_matzler(freqs[i], Ts[j], bands[b])
                fmt.printf(" f=%.2f GHz  T=%5.1f C  m≈(%g, %g)\n", freqs[i], Ts[j], m.re, m.im)
            }
        }
        fmt.println("")
    }
}
