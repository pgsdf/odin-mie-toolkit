package main
import "core:fmt"
import "core:math"
import "../mie"

nearly_equal :: proc(a, b, rel: f64) -> bool {
    return math.abs(a-b) <= rel * math.max(1.0, math.abs(b));
}

main :: proc() {
    // Check anchor: SP=35, T=15 °C, p=0 dbar => 4.29140 S/m (42.914 mS/cm)
    C_anchor := mie.C_from_SP_S_per_m(35.0, 15.0, 0.0);
    ok_anchor := nearly_equal(C_anchor, 4.29140, 5e-4); // 0.05% tolerance
    fmt.println("TEOS anchor    :", C_anchor, " S/m  -> ", if ok_anchor {"PASS"} else {"FAIL"});

    // Monotonic checks
    C_lowT := mie.C_from_SP_S_per_m(35.0, 0.0, 0.0);
    C_hiT  := mie.C_from_SP_S_per_m(35.0, 30.0, 0.0);
    fmt.println("Monotone T (0→30°C):", C_lowT, "→", C_hiT, "  -> ", if (C_hiT > C_lowT) {"PASS"} else {"FAIL"});

    // Pressure effect should raise R (and C) modestly
    C_p0   := mie.C_from_SP_S_per_m(35.0, 15.0, 0.0);
    C_p5000:= mie.C_from_SP_S_per_m(35.0, 15.0, 5000.0);
    fmt.println("Pressure raise (0→5000 dbar):", C_p0, "→", C_p5000, "  -> ", if (C_p5000 > C_p0) {"PASS"} else {"FAIL"});

    // SA→SP bulk consistency around standard seawater
    SP_from_SA := mie.SA_to_SP_bulk(35.16504);
    C_from_SA := mie.C_from_SP_S_per_m(SP_from_SA, 15.0, 0.0);
    fmt.println("SA bulk conv. at 15°C:", C_from_SA, " S/m  (SP≈", SP_from_SA, ")");
}
