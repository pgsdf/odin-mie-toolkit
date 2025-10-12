package mie
import "core:math"

SnowPSDFit :: enum { Generic, SekhonSrivastava, GunnMarshallRimed }
SnowPSD :: struct { N0: f64; Lambda: f64 }

snow_psd_fit :: proc(rate_we_mmph: f64, fit: SnowPSDFit = .Generic) -> SnowPSD {
    if rate_we_mmph < 0.05 { rate_we_mmph = 0.05 }
    when fit {
    case .SekhonSrivastava:  return SnowPSD{N0=6.0e3, Lambda=2.2*math.pow(rate_we_mmph, -0.25)}
    case .GunnMarshallRimed: return SnowPSD{N0=8.0e3, Lambda=1.8*math.pow(rate_we_mmph, -0.28)}
    case .Generic:           return SnowPSD{N0=4.0e3, Lambda=2.0*math.pow(rate_we_mmph, -0.25)}
    }
    return SnowPSD{0,0}
}

snow_psd_from_moments :: proc(M0_m3: f64, M1_mm_m3: f64) -> SnowPSD {
    if M0_m3 <= 0 || M1_mm_m3 <= 0 { return SnowPSD{0,0} }
    Lam := M0_m3 / M1_mm_m3
    N0 := M0_m3 * Lam
    return SnowPSD{N0, Lam}
}
