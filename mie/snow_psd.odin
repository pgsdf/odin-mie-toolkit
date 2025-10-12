package mie
import "core:math"

SnowPSD :: struct { N0: f64; Lambda: f64 }

snow_psd_from_rate :: proc(S_we_mm_per_h: f64) -> SnowPSD {
    if S_we_mm_per_h < 0.05 { S_we_mm_per_h = 0.05 }
    N0 := 4.0e3
    Lambda := 2.0 * math.pow(S_we_mm_per_h, -0.25)
    return SnowPSD{N0, Lambda}
}
