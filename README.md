# Odin-Mie: Electromagnetic Scattering and Attenuation Toolkit

**Author:** Vester Thacker (Pacific Grove Software Distribution Foundation / Nantahala Systems)  
**Language:** Odin  
**Version:** 1.0 | **Status:** Production

A compact, physically grounded implementation of Mie scattering for homogeneous spheres with comprehensive dielectric models and radar observable calculations.

---

## Overview

Odin-Mie provides a complete toolkit for electromagnetic scattering calculations in atmospheric and oceanic applications. The package integrates exact Mie theory with state-of-the-art dielectric models to compute radar observables and attenuation coefficients.

### Key Capabilities

- Exact Mie theory implementation for homogeneous spheres
- Dielectric models: Debye, MW2004 pure water, TEOS-10 seawater
- Ice and snow permittivity models (Mätzler, CRIM/MG effective medium)
- Drop and particle size distribution integration (Marshall-Palmer, Gamma)
- Power-law attenuation coefficient fitting (γ ≈ k R^α)
- Comprehensive validation suite with TEOS-10 reference comparisons

---

## Installation and Quick Start

### Requirements

- Odin compiler
- Unix-like shell environment
- Optional: GNU Make

### Build and Test

```bash
# Run complete test suite
make test

# Generate k-alpha coefficient grid (3-12 GHz, 0-30°C)
make export

# Clean build artifacts
make clean
```

### Direct Execution

```bash
# Fit k-alpha for seawater using TEOS-10
odin run examples/fit_k_alpha.odin -- \
  --model MW2004_Sea_TEOS --sa 35.16504 --p 500

# Validate TEOS-10 conductivity implementation
odin run examples/validate_teos10.odin
```

---

## Scientific Background

### Mie Theory for Homogeneous Spheres

For a sphere with size parameter x = 2πr/λ and complex refractive index m = √ε, the extinction, scattering, and backscatter efficiencies are computed from the Mie coefficients aₙ and bₙ:

**Extinction efficiency:**
```
Qₑₓₜ = (2/x²) Σ(2n+1) Re(aₙ + bₙ)
```

**Scattering efficiency:**
```
Qₛcₐ = (2/x²) Σ(2n+1) (|aₙ|² + |bₙ|²)
```

**Backscatter efficiency:**
```
Qbₐcₖ = |Σ(2n+1)(-1)ⁿ(aₙ - bₙ)|² / x²
```

### Dielectric Models

#### Seawater Permittivity

The complex permittivity of seawater is modeled as:

```
ε(f,T,S,p) = εₚw(f,T) - j σ(S,T,p)/(ε₀ω)
```

where εₚw is the pure water permittivity from MW2004, σ is the conductivity from TEOS-10/PSS-78, and ω = 2πf.

#### Model Selection

| Model | Description | Primary Application |
|-------|-------------|---------------------|
| **Single/Double-Debye** | Analytical approximations for water | Rapid prototyping |
| **MW2004** | Meissner & Wentz (2004) empirical model | Microwave remote sensing |
| **TEOS-10** | PSS-78 + SAL78 pressure corrections | High-precision oceanographic work |

**Reference Conductivity:** C(35 PSU, 15°C, 0 dbar) = 42.9140 mS/cm

### Bulk Radar Observables

The volumetric extinction coefficient κ is obtained by integrating over the drop size distribution N(D):

```
κ = ∫ N(D) σₑₓₜ(D) dD
```

The specific attenuation in dB/km is:

```
γ = 4.343 × 10³ κ
```

For rainfall, the relationship between attenuation and rain rate R is typically expressed as a power law:

```
γ(R) ≈ k R^α
```

The toolkit supports Marshall-Palmer and Gamma drop size distributions for computing these coefficients.

---

## Usage Guide

### Fitting k-alpha Coefficients

**Example: Seawater attenuation with TEOS-10**

```bash
odin run examples/fit_k_alpha.odin -- \
  --model MW2004_Sea_TEOS \
  --sa 35.16504 \       # Absolute Salinity (g/kg)
  --p 500 \             # Pressure (dbar)
  --freq 9.65 \         # Frequency (GHz)
  --temp 20             # Temperature (°C)
```

### Generating Parameter Grids

**Export k-alpha coefficients over frequency and temperature ranges:**

```bash
odin run examples/export_k_alpha_grid.odin -- \
  --out grid.csv \
  --fmin 3 --fmax 12 --fstep 1 \    # Frequency: 3-12 GHz, 1 GHz steps
  --tmin 0 --tmax 30 --tstep 5 \    # Temperature: 0-30°C, 5°C steps
  --sa 35.16504 --p 0               # Salinity and pressure
```

### Validation

**Verify TEOS-10 implementation against reference values:**

```bash
odin run examples/validate_teos10.odin
```

---

## Repository Structure

```
mie/
├── Core Mie Theory
│   ├── complex.odin              # Complex number utilities
│   ├── types.odin                # Common type definitions
│   ├── bessel_spherical.odin     # Spherical Bessel functions
│   └── mie_sphere.odin           # Mie coefficients and efficiencies
│
├── Microphysics
│   ├── dsd.odin                  # Drop size distributions
│   └── polar.odin                # Polarization utilities
│
├── Water Dielectric Models
│   ├── water_perm_debye.odin     # Single and double-Debye models
│   ├── water_perm_teos10.odin    # MW2004 with TEOS-10 integration
│   ├── teos10_conductivity.odin  # PSS-78 conductivity algorithms
│   ├── teos10_pressure.odin      # SAL78 pressure corrections
│   └── teos10_salinity.odin      # Salinity conversion utilities
│
└── Ice and Snow Models
    ├── ice_perm.odin             # Basic ice permittivity
    ├── ice_perm_matzler.odin     # Mätzler Debye-style model
    ├── snow_em.odin              # CRIM/Maxwell-Garnett effective medium
    ├── snow_psd.odin             # Snow particle size distributions
    ├── snow_psd_fits.odin        # Parameterized PSD fits
    └── gamma_snow.odin           # Snow attenuation integration

examples/
├── fit_k_alpha.odin              # Rain attenuation coefficient fitting
├── export_k_alpha_grid.odin      # Batch parameter grid generation
├── validate_teos10.odin          # TEOS-10 validation tests
├── snow_k_alpha.odin             # Snow attenuation calculations
├── compare_snow_psd.odin         # Snow PSD comparison utility
└── validate_ice_models.odin      # Ice permittivity validation

tests/
├── mie_sanity_test.odin          # Basic Mie theory verification
├── test_teos10.odin              # TEOS-10 numerical accuracy tests
├── test_ice.odin                 # Ice model validation
├── test_snow.odin                # Snow model verification
└── test_ice_matzler.odin         # Mätzler model specific tests

scripts/
└── run_ci.sh                     # Continuous integration script

Makefile                          # Build automation
```

---

## Snow and Ice Extensions

### Ice Permittivity

The toolkit includes two ice permittivity implementations:

- **Basic model** (`ice_perm.odin`) — Simple approximate formulation for ice permittivity
- **Mätzler model** (`ice_perm_matzler.odin`) — Debye-type relaxation model with frequency band presets

### Snow Scattering

Snow scattering calculations are supported through:

- **Effective medium theory** (`snow_em.odin`) — CRIM and Maxwell-Garnett mixing formulas for snow-air mixtures
- **Particle size distributions** (`snow_psd.odin`, `snow_psd_fits.odin`) — PSD utilities with common parameterizations
- **Bulk attenuation** (`gamma_snow.odin`) — Numerical integration for snow-specific attenuation

### Example Usage

```bash
# Calculate snow attenuation coefficients
odin run examples/snow_k_alpha.odin

# Compare different snow PSD parameterizations
odin run examples/compare_snow_psd.odin

# Validate ice permittivity models
odin run examples/validate_ice_models.odin
```

---

## Numerical Considerations

### Convergence and Stability

For large size parameters (high frequency or large particle radii):

- Extended-precision arithmetic may be required for Bessel function recursions
- Log-derivative stabilization techniques can prevent overflow in extreme cases
- Current implementation is optimized for rain-radar frequency regimes (1-100 GHz)

### Integration Parameters

- Drop radius integration limits are configurable per application
- Default limits span drizzle (0.1 mm) to heavy rain (8 mm) regimes
- Quadrature accuracy can be adjusted for specific precision requirements

---

## References

1. **Meissner, T., & Wentz, F. J. (2004)**  
   The complex dielectric constant of pure and sea water from microwave satellite observations.  
   *IEEE Transactions on Geoscience and Remote Sensing*, 42(9), 1836-1849.  
   doi: 10.1109/TGRS.2004.831888

2. **UNESCO (1983)**  
   Algorithms for computation of fundamental properties of seawater.  
   *UNESCO Technical Papers in Marine Science*, No. 44.  
   (Contains SAL78 algorithm listing)

3. **IOC, SCOR, and IAPSO (2010)**  
   The international thermodynamic equation of seawater – 2010: Calculation and use of thermodynamic properties.  
   *Intergovernmental Oceanographic Commission, Manuals and Guides*, No. 56.  
   (TEOS-10 Manual)

4. **Marshall, J. S., & Palmer, W. McK. (1948)**  
   The distribution of raindrops with size.  
   *Quarterly Journal of the Royal Meteorological Society*, 5(3), 165-166.  
   doi: 10.1175/1520-0469(1948)005<0165:TDORWS>2.0.CO;2

---

## Contributing

Contributions are welcome. Please ensure all tests pass before submitting pull requests:

```bash
make test
```

For bug reports or feature requests, please open an issue with:

- Detailed description of the problem or proposed enhancement
- Minimal reproducible example (if applicable)
- System configuration (OS, Odin version)

---

## License

MIT License

---

## Contact

Vester Thacker  
Pacific Grove Software Distribution Foundation / Nantahala Systems

For technical questions or collaboration inquiries, please use the issue tracker.
