# API Reference


## mie


### `mie/dsd.odin`


```odin
package mie
```

Bulk attenuation from Mie + DSD integration.

`gamma_from_Mie_MarshallPalmer(f_GHz, T_C, R_mm_per_h, use_double)`
computes γ in dB/km by integrating extinction over the Marshall–Palmer DSD.

Units:
f_GHz: [GHz], T_C: [°C], R_mm_per_h: [mm/h], returns γ: [dB/km]

Notes:
- Uses Simpson’s rule over drop radius; limits cover drizzle–heavy rain.
- For spheres, H/V polarizations are identical (see `polar.odin`).


### `mie/mie_sphere.odin`


```odin
package mie
```

Mie scattering for a homogeneous sphere.

Computes efficiency factors Q_ext, Q_sca, Q_back from complex refractive index `m`
and size parameter `x = 2π r / λ`.

Args:
m: Complex refractive index (dimensionless)
x: Size parameter (dimensionless)
Returns:
MieResult{Q_ext, Q_sca, Q_back} (dimensionless efficiencies)
References: Bohren & Huffman (1983), Wiscombe (1980).


### `mie/teos10_conductivity.odin`


```odin
package mie
```

Conductivity of seawater following TEOS‑10 / PSS‑78 with pressure correction (SAL78).

`C_from_SP_S_per_m(SP, t90_C, p_dbar)` returns conductivity in S/m for
Practical Salinity `SP` (dimensionless), temperature `t90_C` (°C, ITS‑90),
and pressure `p_dbar` (decibar).

Implements:
- PSS‑78 salinity polynomials (a_i, b_i, k)
- SAL78 pressure polynomials A(X_T), B(X_T), C(X_P) and quadratic solve
- Anchor C(35, 15 °C, 0 dbar) = 42.9140 mS/cm

Units:
SP: [ ]  t90_C: [°C]  p_dbar: [dbar]  returns: [S/m]

References: UNESCO Tech Paper 44 (1983); TEOS‑10 Manual (GSW 3.06).


### `mie/water_perm_teos10.odin`


```odin
package mie
```

Seawater refractive index using MW2004 pure‑water ε and TEOS‑10 conductivity.

Functions:
- `water_m_from_MW2004_seawater_TEOS(f_GHz, T_C, SP, p_dbar)`
- `water_m_from_MW2004_seawater_TEOS_SA(f_GHz, T_C, SA_g_per_kg, p_dbar)`

Returns complex refractive index `m = sqrt(ε)` where
ε = ε_pw(MW2004) − j σ(TEOS‑10)/(ε0 ω), ω=2πf.

Units:
f_GHz: [GHz], T_C: [°C], SP: [ ], SA: [g/kg], p_dbar: [dbar]

References: Meissner & Wentz (2004); UNESCO TP‑44; TEOS‑10.


## examples


### `examples/fit_k_alpha.odin`


```odin
package main
```

Fit γ(R) ≈ k·R^α and expose a CLI for model selection and oceanographic inputs.

Flags:
--model  ApproxSingle | ApproxDouble | MW2004_Pure | MW2004_Sea | MW2004_Sea_TEOS
--freq   GHz
--temp   °C
--sp     Practical Salinity (PSS‑78)
--sa     Absolute Salinity (g/kg)
--p      Pressure (dbar)

Output:
Prints fitted k [dB/km / (mm/h)^α] and α for a fixed set of rain rates.


## tests
