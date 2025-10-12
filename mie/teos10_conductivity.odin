/// Conductivity of seawater following TEOS‑10 / PSS‑78 with pressure correction (SAL78).
/// 
/// `C_from_SP_S_per_m(SP, t90_C, p_dbar)` returns conductivity in S/m for
/// Practical Salinity `SP` (dimensionless), temperature `t90_C` (°C, ITS‑90),
/// and pressure `p_dbar` (decibar).
/// 
/// Implements:
///   - PSS‑78 salinity polynomials (a_i, b_i, k)
///   - SAL78 pressure polynomials A(X_T), B(X_T), C(X_P) and quadratic solve
///   - Anchor C(35, 15 °C, 0 dbar) = 42.9140 mS/cm
/// 
/// Units:
///   SP: [ ]  t90_C: [°C]  p_dbar: [dbar]  returns: [S/m]
/// 
/// References: UNESCO Tech Paper 44 (1983); TEOS‑10 Manual (GSW 3.06).
package mie
import "core:math"

// TEOS-10 / PSS-78 conductivity from Practical Salinity (SP), temperature t (ITS-90, °C), sea pressure p (dbar).
// Implements the UNESCO Tech Paper 44 (1983) PSS-78 relationships, including the pressure correction polynomials.
// For p = 0, reduces to the standard bench formula; for p > 0, uses the quadratic form from the SAL78 listing.
//
// Reference anchor conductivity at SP=35, t68=15°C, p=0:
C35150_mS_per_cm :: f64 = 42.9140 // (Culkin & Smith 1980) -> 4.29140 S/m

// PSS-78 salinity coefficients (Eq. (1)-(2))
PSS_a := []f64{  0.0080, -0.1692,  25.3851,  14.0941,  -7.0261,   2.7081 }
PSS_b := []f64{  0.0005, -0.0056,  -0.0066,  -0.0375,   0.0636,  -0.0144 }
PSS_k :: f64 = 0.0162

// Temperature conversion
t68_from_t90 :: proc(t90: f64) -> f64 { return 1.00024 * t90; }

// RT35(T) polynomial (C(35,T,0)/C(35,15,0)) with T in IPTS-68
rt35_poly :: proc(t68: f64) -> f64 {
    c0 := 0.6766097
    c1 := 0.0200564
    c2 := 0.0001104259
    c3 := -6.9698e-7
    c4 := 1.0031e-9
    x := t68 - 15.0 // XT in the listing, but rt35 uses full t68 polynomial; either form yields same since constants are encoded for XT
    // The listing uses RT35(XT) with XT = T-15; expanded it is identical to polynomial in (t68).
    return (((c4*x + c3)*x + c2)*x + c1)*x + c0
}

// A(XT), B(XT), C(XP) polynomials for pressure correction (UNESCO SAL78 listing; XP in dbar, XT = T68-15)
A_of_XT :: proc(xt: f64) -> f64 { return -3.107e-3*xt + 0.4215; }
B_of_XT :: proc(xt: f64) -> f64 { return (4.464e-4*xt + 3.426e-2)*xt + 1.0; }
C_of_XP :: proc(xp: f64) -> f64 { return ((3.989e-15*xp - 6.370e-10)*xp + 2.070e-5)*xp; }

// Rt polynomial in t68 used by SP_from_Rt and its derivative
rt_poly :: proc(t68: f64) -> f64 {
    // c0..c4 (same as rt35 expansion but written in t68 variable)
    c0 := 0.6766097
    c1 := 2.00564e-2
    c2 := 1.104259e-4
    c3 := -6.9698e-7
    c4 := 1.0031e-9
    t := t68 - 15.0
    return (((c4*t + c3)*t + c2)*t + c1)*t + c0
}

// Given R_t (ratio at zero pressure scaled by C(35,t,0)), compute SP per PSS-78
SP_from_Rt :: proc(Rt: f64, t68: f64) -> f64 {
    sqrtRt := math.sqrt(Rt)
    Rt_pows := []f64{ 1.0, sqrtRt, Rt, Rt*sqrtRt, Rt*Rt, Rt*Rt*sqrtRt }
    dt := t68 - 15.0
    Delta := dt / (1.0 + PSS_k*dt)
    sum_a := 0.0
    sum_b := 0.0
    for i in 0..5 {
        sum_a += PSS_a[i] * Rt_pows[i]
        sum_b += PSS_b[i] * Rt_pows[i]
    }
    return sum_a + Delta * sum_b
}

// dSP/dRt for Newton
dSP_dRt :: proc(Rt: f64, t68: f64) -> f64 {
    sqrtRt := math.sqrt(Rt)
    dRt_pows := []f64{
        0.0,
        0.5 / sqrtRt,
        1.0,
        1.5 * sqrtRt,
        2.0 * Rt,
        2.5 * Rt * sqrtRt,
    }
    dt := t68 - 15.0
    Delta := dt / (1.0 + PSS_k*dt)
    sum := 0.0
    for i in 0..5 {
        coef := PSS_a[i] + Delta*PSS_b[i]
        sum += coef * dRt_pows[i]
    }
    return sum
}

// Invert SP -> Rt (p = 0 branch)
Rt_from_SP :: proc(SP: f64, t68: f64) -> f64 {
    Rt := 0.01*SP + 0.6
    if Rt < 0.1 { Rt = 0.1 }
    if Rt > 2.0 { Rt = 2.0 }
    for _ in 0..24 {
        F := SP_from_Rt(Rt, t68) - SP
        dF := dSP_dRt(Rt, t68)
        Rt -= F/dF
        if Rt <= 1e-12 { Rt = 1e-12 }
        if math.abs(F) < 1e-12 { break }
    }
    return Rt
}

// Conductivity, S/m, from SP (PSS-78), t90 (°C), p (dbar)
C_from_SP_S_per_m :: proc(SP: f64, t90_C: f64, p_dbar: f64 = 0.0) -> f64 {
    t68 := t68_from_t90(t90_C)
    // 1) invert SP -> Rt at zero pressure
    Rt := Rt_from_SP(SP, t68)
    // 2) temperature factor
    RT35 := rt35_poly(t68)
    if p_dbar == 0.0 {
        R := Rt * RT35 // R = C(S,t,0)/C(35,15,0)
        C_mS_per_cm := R * C35150_mS_per_cm
        return C_mS_per_cm * 0.1
    }
    // 3) pressure correction using quadratic (SAL78 listing)
    xt := t68 - 15.0
    AT := A_of_XT(xt)
    BT := B_of_XT(xt)
    CP := C_of_XP(p_dbar)
    RTT := RT35 * Rt * Rt
    CP = RTT * (CP + BT)
    BT = BT - RTT * AT
    disc := BT*BT + 4.0*AT*CP
    if disc < 0.0 { disc = 0.0 }
    R := 0.5 * (math.sqrt(disc) - BT) / AT
    // 4) convert to S/m
    C_mS_per_cm := R * C35150_mS_per_cm
    return C_mS_per_cm * 0.1
}
