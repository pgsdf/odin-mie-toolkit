
# Odin-Mie: Electromagnetic Scattering and Attenuation Toolkit (Odin)

Author: Vester Thacker (Pacific Grove Software Distribution Foundation / Nantahala Systems)  
Language: Odin

## Summary

Odin-Mie provides a compact, physically grounded implementation of Mie scattering for homogeneous spheres,
together with dielectric models for water (pure and sea) and microphysical integration over drop size
distributions (DSD) to derive bulk radar observables such as the power-law attenuation relation
\(\gamma \approx k R^{\alpha}\) in dB/km.

The toolkit integrates:
1. **Electromagnetic properties** — Debye and MW2004 pure water, TEOS‑10 seawater conductivity.
2. **Exact Mie theory** — coefficients \(a_n, b_n\); \(Q_{\mathrm{ext}}, Q_{\mathrm{sca}}, Q_{\mathrm{back}}\).
3. **Microphysics** — Marshall–Palmer and Gamma DSD, numerical quadrature.
4. **Applications** — fit \((k,\alpha)\), export CSV grids, validation and CI.

## Install & Run

Requirements: Odin compiler, Unix-like shell. Optional: `make`.

Quick start:
```bash
make test      # sanity, TEOS-10 tests, validation, fit_k_alpha smoke tests
make export    # generate k_alpha_grid.csv (3–12 GHz, 0–30 °C)
make clean
```

Direct:
```bash
odin run examples/fit_k_alpha.odin -- --model MW2004_Sea_TEOS --sa 35.16504 --p 500
odin run examples/validate_teos10.odin
```

## Scientific Background

### Mie Theory (homogeneous sphere)
Let \(x = 2\pi r/\lambda\) be the size parameter and \(m=\sqrt{\varepsilon}\) the complex refractive index.
The extinction and scattering efficiencies are
\[
Q_{\mathrm{ext}} = \frac{2}{x^2}\sum_{n=1}^{\infty}(2n+1)\Re(a_n + b_n), \quad
Q_{\mathrm{sca}} = \frac{2}{x^2}\sum_{n=1}^{\infty}(2n+1)(|a_n|^2 + |b_n|^2).
\]
The backscatter efficiency is \(Q_{\mathrm{back}} = | \sum_{n}(2n+1)(-1)^n(a_n - b_n) |^2/x^2\).

### Dielectric Model
We model seawater as
\[
\varepsilon(f,T,S,p) = \varepsilon_{\mathrm{pw}}(f,T) - j\,\frac{\sigma(S,T,p)}{\varepsilon_0 \, \omega},
\quad \omega=2\pi f,
\]
where \(\varepsilon_{\mathrm{pw}}\) is from **MW2004**; conductivity \(\sigma\) from **TEOS‑10 / PSS‑78**
including the **SAL78** pressure polynomials.

### Debye and MW2004
- Single/Double‑Debye: convenient approximations for water’s dielectric response.
- MW2004 (Meissner & Wentz, 2004): widely used empirical model for microwave frequencies.

### TEOS‑10 Conductivity (PSS‑78 + SAL78 pressure)
We implement the PSS‑78 \(a_i,b_i,k\) polynomials and SAL78 pressure functions
\(A(X_T),B(X_T),C(X_P)\) with the quadratic solve for the conductivity ratio \(R\).
The anchor conductivity is \(C(35,15^\circ\mathrm{C},0) = 42.9140\ \mathrm{mS/cm}\).

## From Microphysics to Radar Attenuation

For a DSD \(N(D)\) and extinction cross section \(\sigma_{\mathrm{ext}}(D)\),
\[
\kappa = \int N(D)\sigma_{\mathrm{ext}}(D)\,dD, \qquad \gamma\,[\mathrm{dB/km}] = 4.343\times 10^3 \kappa.
\]
We provide Marshall–Palmer (and Gamma) DSDs and fit \(\gamma(R)\) with \(k, \alpha\).

## Repository Layout

```
mie/
  complex.odin, types.odin, bessel_spherical.odin, mie_sphere.odin
  dsd.odin, polar.odin
  water_perm_debye.odin, water_perm_teos10.odin
  teos10_conductivity.odin, teos10_pressure.odin, teos10_salinity.odin
examples/
  fit_k_alpha.odin, export_k_alpha_grid.odin, validate_teos10.odin
tests/
  mie_sanity_test.odin, test_teos10.odin
scripts/
  run_ci.sh
Makefile
```

## Usage Guide

### Fit \(k,\alpha\)
```bash
# Seawater with TEOS‑10 (Absolute Salinity and pressure)
odin run examples/fit_k_alpha.odin -- \
  --model MW2004_Sea_TEOS --sa 35.16504 --p 500 --freq 9.65 --temp 20
```

### Export CSV Grid
```bash
odin run examples/export_k_alpha_grid.odin -- \
  --out grid.csv --fmin 3 --fmax 12 --fstep 1 \
  --tmin 0 --tmax 30 --tstep 5 --sa 35.16504 --p 0
```

### Validate TEOS‑10
```bash
odin run examples/validate_teos10.odin
```

## Numerical Notes

- For large \(x\) (high frequency or large radii), use extended‑precision recursions or
log‑derivative stabilization if needed. The current implementation targets rain‑radar regimes.
- Integration limits for drop radius can be tuned per application; defaults cover drizzle to heavy rain.

## References

- Meissner, T., & Wentz, F. J. (2004). *The complex dielectric constant of pure and sea water from microwave satellite observations.* IEEE TGRS, 42(9), 1836–1849.
- UNESCO (1983). *Algorithms for computation of fundamental properties of seawater.* Technical Papers in Marine Science 44. (SAL78 listing.)
- TEOS‑10 Manual and GSW Toolbox (v3.06): practical salinity and conductivity relations.
- Marshall, J. S., & Palmer, W. McK. (1948). *The distribution of raindrops with size.* QJRMS.


## Snow and Ice Extensions
Added modules:
- mie/ice_perm.odin (approximate ice ε)
- mie/ice_perm_matzler.odin (Debye-style scaffold with band presets)
- mie/snow_em.odin (CRIM/MG effective medium)
- mie/snow_psd.odin and mie/snow_psd_fits.odin (snow PSD utilities and named fits)
- mie/gamma_snow.odin (snow attenuation integrator)
Examples:
- examples/snow_k_alpha.odin, examples/compare_snow_psd.odin, examples/validate_ice_models.odin
Tests:
- tests/test_ice.odin, tests/test_snow.odin, tests/test_ice_matzler.odin
