package main
import "core:fmt"
import "../mie"
main :: proc() {
    psd := mie.snow_psd_from_rate(1.0)
    g := mie.gamma_from_snow(9.65, -5.0, 200.0, 0.0, psd)
    fmt.println("gamma_snow ~", g, " dB/km at 9.65 GHz, -5C, rho=200 kg/m^3, dry, rate=1 mm/h WE")
}
