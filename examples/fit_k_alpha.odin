/// Fit γ(R) ≈ k·R^α and expose a CLI for model selection and oceanographic inputs.
/// 
/// Flags:
///   --model  ApproxSingle | ApproxDouble | MW2004_Pure | MW2004_Sea | MW2004_Sea_TEOS
///   --freq   GHz
///   --temp   °C
///   --sp     Practical Salinity (PSS‑78)
///   --sa     Absolute Salinity (g/kg)
///   --p      Pressure (dbar)
/// 
/// Output:
///   Prints fitted k [dB/km / (mm/h)^α] and α for a fixed set of rain rates.
package main
import "core:fmt"
import "core:math"
import "core:os"
import "../mie"

DielectricModel :: enum { ApproxSingle, ApproxDouble, MW2004_Pure, MW2004_Sea, MW2004_Sea_TEOS }

fit_power_law :: proc(R: []f64, G: []f64) -> (k: f64, alpha: f64) {
    n := len(R); sx, sy, sxx, sxy := 0.0, 0.0, 0.0, 0.0;
    for i in 0..n-1 { x := math.log(R[i]); y := math.log(G[i]); sx+=x; sy+=y; sxx+=x*x; sxy+=x*y; }
    denom := cast(f64)n*sxx - sx*sx; alpha = (cast(f64)n*sxy - sx*sy)/denom; ln_k := (sy - alpha*sx)/cast(f64)n; k := math.exp(ln_k); return k, alpha;
}

mp_gamma_with_model :: proc(freq_GHz, T_C: f64, R: f64, model: DielectricModel, SP: f64, SA: f64, p_dbar: f64) -> f64 {
    c := 299_792_458.0;
    switch model {
    case .ApproxSingle: return mie.gamma_from_Mie_MarshallPalmer(freq_GHz, T_C, R, false);
    case .ApproxDouble: return mie.gamma_from_Mie_MarshallPalmer(freq_GHz, T_C, R, true);
    case .MW2004_Pure, .MW2004_Sea, .MW2004_Sea_TEOS:
        f := proc(r: f64) -> f64 {
            if r<=0.0 { return 0.0; }
            D_mm := 2000.0*r; N_D := mie.mp_N0 * math.exp(-mie.mp_Lambda(R) * D_mm); N_r := N_D * 2000.0;
            x := 2.0*math.pi*r/(c/(freq_GHz*1e9));
            m_c := switch model {
                case .MW2004_Pure:      mie.water_m_from_MW2004(freq_GHz, T_C);
                case .MW2004_Sea:       mie.water_m_from_MW2004_seawater(freq_GHz, T_C, SP);
                case .MW2004_Sea_TEOS:  mie.water_m_from_MW2004_seawater_TEOS_SA(freq_GHz, T_C, SA, p_dbar);
                else: mie.water_m_from_MW2004(freq_GHz, T_C);
            };
            res := mie.mie_sphere(m_c, x); sigma := res.Q_ext * math.pi * r * r; return N_r * sigma;
        };
        simpson := proc(f: proc(r:f64)->f64, a,b:f64, n:int)->f64 { if n%2!=0{n+=1}; h:=(b-a)/cast(f64)n; s:=f(a)+f(b); for j in 1..n-1{ x:=a+cast(f64)j*h; c:=4.0; if j%2==0{c=2.0}; s+=c*f(x);} return s*h/3.0; };
        kappa := simpson(f, 0.00005, 0.00500, 800); return 4.343*1000.0*kappa;
    }
    return 0.0;
}

usage :: proc() {
    fmt.println("Usage: fit_k_alpha [--model NAME] [--freq GHz] [--temp C] [--sp SP] [--sa SA] [--p dbar]");
    fmt.println("  models: ApproxSingle | ApproxDouble | MW2004_Pure | MW2004_Sea | MW2004_Sea_TEOS");
    fmt.println("  examples:");
    fmt.println("    odin run examples/fit_k_alpha.odin -- --model MW2004_Sea --sp 35");
    fmt.println("    odin run examples/fit_k_alpha.odin -- --model MW2004_Sea_TEOS --sa 35.16504 --p 500");
}

parse_model :: proc(s: string) -> DielectricModel {
    if s == "ApproxSingle"    { return .ApproxSingle; }
    if s == "ApproxDouble"    { return .ApproxDouble; }
    if s == "MW2004_Pure"     { return .MW2004_Pure; }
    if s == "MW2004_Sea"      { return .MW2004_Sea; }
    if s == "MW2004_Sea_TEOS" { return .MW2004_Sea_TEOS; }
    return .MW2004_Pure;
}

main :: proc() {
    // Defaults
    model := DielectricModel.MW2004_Pure;
    freq_GHz := 9.65; T_C := 20.0; SP := 35.0; SA := 35.16504; p_dbar := 0.0;
    // Parse CLI args
    args := os.args;
    for i in 0..len(args)-1 {
        if args[i] == "--help" { usage(); return; }
        if args[i] == "--model" && i+1 < len(args) { model = parse_model(args[i+1]); }
        if args[i] == "--freq"  && i+1 < len(args) { freq_GHz = os.str_to_f64(args[i+1]); }
        if args[i] == "--temp"  && i+1 < len(args) { T_C = os.str_to_f64(args[i+1]); }
        if args[i] == "--sp"    && i+1 < len(args) { SP = os.str_to_f64(args[i+1]); }
        if args[i] == "--sa"    && i+1 < len(args) { SA = os.str_to_f64(args[i+1]); }
        if args[i] == "--p"     && i+1 < len(args) { p_dbar = os.str_to_f64(args[i+1]); }
    }
    R := []f64{0.5,1,2,3,5,10,15,20,30,40,50,60}; G := make([]f64, len(R));
    for i in 0..len(R)-1 { G[i] = mp_gamma_with_model(freq_GHz, T_C, R[i], model, SP, SA, p_dbar); }
    k, a := fit_power_law(R, G);
    fmt.println("Model:", model, " f=", freq_GHz, "GHz  T=", T_C, "°C  SP=", SP, " SA=", SA, " p=", p_dbar, " dbar");
    fmt.println("k:", k, "  α:", a);
}
