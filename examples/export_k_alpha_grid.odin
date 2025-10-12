package main
import "core:fmt"
import "core:math"
import "core:os"
import "../mie"

// Reuse fit logic from fit_k_alpha (copy to keep this self-contained)
fit_power_law :: proc(R: []f64, G: []f64) -> (k: f64, alpha: f64) {
    n := len(R); sx, sy, sxx, sxy := 0.0, 0.0, 0.0, 0.0;
    for i in 0..n-1 { x := math.log(R[i]); y := math.log(G[i]); sx+=x; sy+=y; sxx+=x*x; sxy+=x*y; }
    denom := cast(f64)n*sxx - sx*sx; alpha = (cast(f64)n*sxy - sx*sy)/denom; ln_k := (sy - alpha*sx)/cast(f64)n; k := math.exp(ln_k); return k, alpha;
}

DielectricModel :: enum { MW2004_Pure, MW2004_Sea_TEOS }

mp_gamma_TEOS :: proc(freq_GHz, T_C, R, SP, SA, p_dbar: f64, model: DielectricModel) -> f64 {
    c := 299_792_458.0;
    f := proc(r: f64) -> f64 {
        if r<=0.0 { return 0.0; }
        D_mm := 2000.0*r; N_D := mie.mp_N0 * math.exp(-mie.mp_Lambda(R) * D_mm); N_r := N_D * 2000.0;
        x := 2.0*math.pi*r/(c/(freq_GHz*1e9));
        m_c := switch model {
            case .MW2004_Pure:     mie.water_m_from_MW2004(freq_GHz, T_C);
            case .MW2004_Sea_TEOS: mie.water_m_from_MW2004_seawater_TEOS_SA(freq_GHz, T_C, SA, p_dbar);
            else: mie.water_m_from_MW2004(freq_GHz, T_C);
        };
        res := mie.mie_sphere(m_c, x); sigma := res.Q_ext * math.pi * r * r; return N_r * sigma;
    };
    // Simple Simpson
    simpson := proc(f: proc(r:f64)->f64, a,b:f64, n:int)->f64 { if n%2!=0{n+=1}; h:=(b-a)/cast(f64)n; s:=f(a)+f(b); for j in 1..n-1{ x:=a+cast(f64)j*h; c:=4.0; if j%2==0{c=2.0}; s+=c*f(x);} return s*h/3.0; };
    kappa := simpson(f, 0.00005, 0.00500, 800);
    return 4.343*1000.0*kappa;
}

usage :: proc() {
    fmt.println("Usage: export_k_alpha_grid --out path.csv [--fmin GHz] [--fmax GHz] [--fstep GHz] [--tmin C] [--tmax C] [--tstep C] [--p dbar] [--sa g/kg]");
    fmt.println("Example:");
    fmt.println("  odin run examples/export_k_alpha_grid.odin -- --out out.csv --fmin 3 --fmax 12 --fstep 1 --tmin 0 --tmax 30 --tstep 5 --sa 35.16504 --p 0");
}

main :: proc() {
    // Defaults
    out := "k_alpha_grid.csv";
    fmin, fmax, fstep := 3.0, 12.0, 1.0;
    tmin, tmax, tstep := 0.0, 30.0, 5.0;
    p_dbar := 0.0; SA := 35.16504;
    SP := 35.0; // for pure-water column we ignore salinity; kept for completeness
    args := os.args;
    for i in 0..len(args)-1 {
        if args[i] == "--help" { usage(); return; }
        if args[i] == "--out"   && i+1 < len(args) { out   = args[i+1]; }
        if args[i] == "--fmin"  && i+1 < len(args) { fmin  = os.str_to_f64(args[i+1]); }
        if args[i] == "--fmax"  && i+1 < len(args) { fmax  = os.str_to_f64(args[i+1]); }
        if args[i] == "--fstep" && i+1 < len(args) { fstep = os.str_to_f64(args[i+1]); }
        if args[i] == "--tmin"  && i+1 < len(args) { tmin  = os.str_to_f64(args[i+1]); }
        if args[i] == "--tmax"  && i+1 < len(args) { tmax  = os.str_to_f64(args[i+1]); }
        if args[i] == "--tstep" && i+1 < len(args) { tstep = os.str_to_f64(args[i+1]); }
        if args[i] == "--p"     && i+1 < len(args) { p_dbar= os.str_to_f64(args[i+1]); }
        if args[i] == "--sa"    && i+1 < len(args) { SA    = os.str_to_f64(args[i+1]); }
    }
    // Prepare rainfall rates
    R := []f64{0.5,1,2,3,5,10,15,20,30,40,50,60};
    // Open CSV
    file, err := os.open_file(out, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0o644);
    if err != nil { fmt.println("Failed to open output:", out); return; }
    defer os.close(file);
    // Header
    os.write_string(file, "freq_GHz,temp_C,model,k,alpha\n");
    // Sweep
    for f := fmin; f <= fmax+1e-9; f += fstep {
        for T := tmin; T <= tmax+1e-9; T += tstep {
            // Pure water
            G := make([]f64, len(R));
            for i in 0..len(R)-1 { G[i] = mp_gamma_TEOS(f, T, R[i], SP, SA, p_dbar, .MW2004_Pure); }
            k, a := fit_power_law(R, G);
            os.write_string(file, fmt.tprintf("%.3f,%.3f,MW2004_Pure,%.8g,%.8g\n", f, T, k, a));
            // Sea water (TEOS)
            for i in 0..len(R)-1 { G[i] = mp_gamma_TEOS(f, T, R[i], SP, SA, p_dbar, .MW2004_Sea_TEOS); }
            k2, a2 := fit_power_law(R, G);
            os.write_string(file, fmt.tprintf("%.3f,%.3f,MW2004_Sea_TEOS,%.8g,%.8g\n", f, T, k2, a2));
        }
    }
    fmt.println("Wrote:", out);
}
