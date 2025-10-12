package main
import "core:fmt"
import "../mie"

main :: proc() {
    // Temperature/salinity grid at p=0
    cases_SP := []f64{0.0, 5.0, 20.0, 35.0, 40.0}
    T_C := []f64{0.0, 10.0, 15.0, 20.0, 30.0}
    fmt.println("Validate TEOS-10 conductivity (p=0 dbar):")
    for i in 0..len(cases_SP)-1 {
        for j in 0..len(T_C)-1 {
            C := mie.C_from_SP_S_per_m(cases_SP[i], T_C[j], 0.0)
            fmt.printf("SP=%5.1f  T=%5.1f°C  ->  C=%7.4f S/m\n", cases_SP[i], T_C[j], C)
        }
    }
    // Pressure sweep at SP=35 across T={0,15,30} and p={0,1000,3000,5000}
    ps := []f64{0.0, 1000.0, 3000.0, 5000.0}
    Ts := []f64{0.0, 15.0, 30.0}
    fmt.println("\nPressure sweep (SP=35):")
    for j in 0..len(Ts)-1 {
        for k in 0..len(ps)-1 {
            C := mie.C_from_SP_S_per_m(35.0, Ts[j], ps[k])
            fmt.printf("T=%5.1f°C p=%6.0f dbar -> C=%7.4f S/m\n", Ts[j], ps[k], C)
        }
    }
    // SA bulk conversion round-trip at 15°C
    SA := 35.16504
    SP_bulk := mie.SA_to_SP_bulk(SA)
    C_SA := mie.C_from_SP_S_per_m(SP_bulk, 15.0, 0.0)
    fmt.printf("\nFrom SA (bulk conv.): SA=%.5f g/kg -> SP≈%.5f => C(15°C)≈%.4f S/m\n", SA, SP_bulk, C_SA)
}
