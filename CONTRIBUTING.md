# Contributing to Odin-Mie

Thank you for your interest in contributing to **Odin-Mie**, a physically grounded electromagnetic scattering toolkit written in Odin.
This guide explains how to set up your environment, run tests, document changes, and propose improvements.

## 1. Environment Setup

**Requirements**
- Odin compiler
- Unix-like shell (Linux, macOS, or WSL)
- `make` and `python3`
- For PDF documentation: LaTeX (`pdflatex`)

## 2. Repository Overview

```
mie/                         Core physics and models
examples/                    CLI tools and demonstrations
tests/                       Automated and scientific verification
scripts/                     CI runner and doc generator
docs/                        API reference (Markdown) + technical brief (LaTeX)
Makefile                     Common build tasks
README.md                    Scientific overview and usage
```

## 3. Build & Validation Workflow

```bash
make test      # Run full CI (sanity + TEOS tests + validation + smoke)
make export    # Export (k, α) grid across frequency/temperature
make docs      # Regenerate API reference (docs/api.md)
make pdf       # Build technical brief (docs/tech-brief.pdf)
make clean     # Remove generated outputs
```

## 4. Documentation Standards

Use `///` for public functions, constants, and structs. Include:
- Purpose
- Input/Output units
- Formula or reference
- Literature tag (e.g., [MW2004], [TEOS-10], [PSS-78])

Example:
```odin
/// Compute seawater conductivity (TEOS-10 PSS-78 + SAL78 pressure).
///
/// Args:
///   SP: Practical salinity [ ]
///   t90_C: Temperature [°C, ITS-90]
///   p_dbar: Pressure [dbar]
/// Returns:
///   Conductivity [S/m]
/// Reference: UNESCO TP-44 (1983)
C_from_SP_S_per_m :: proc(SP: f64, t90_C: f64, p_dbar: f64 = 0.0) -> f64
```

Generate documentation:
```bash
make docs   # Extracts /// comments into docs/api.md
make pdf    # Builds docs/tech-brief.pdf
```

## 5. Testing Conventions

All changes must include:
- Unit or regression tests in `tests/`
- Validation runs in `examples/`
- Adherence to reference values (e.g., TEOS anchor = 4.29140 S/m at SP=35, T=15 °C)

Run tests:
```bash
make test
```

## 6. Code Style Guidelines

- Descriptive variable names with units (`freq_GHz`, `T_C`, `p_dbar`)
- Keep functions pure; isolate I/O in examples
- Avoid heap allocations inside tight loops
- Maintain unit consistency:
  - Frequency — GHz
  - Temperature — °C
  - Pressure — dbar
  - Conductivity — S/m
  - Rain rate — mm/h
  - Attenuation — dB/km

## 7. Adding New Features

### Dielectric Model
1. Add `mie/water_perm_<model>.odin`
2. Implement `water_m_from_<model>()`
3. Add model to `examples/fit_k_alpha.odin`
4. Document and test

### DSD or Scattering Scheme
1. Add new integrator in `mie/dsd.odin`
2. Expose function `gamma_from_<method>()`
3. Include regression test and example run

## 8. Submitting Changes

1. Fork or branch from `main`
2. Implement and test (`make test`)
3. Update documentation (`///`, `README.md`, `tech-brief.tex`)
4. Commit with clear messages:
   ```
   feat(teos): extend pressure polynomial to 10 k dbar
   ```
5. Open a Pull Request summarizing:
   - Problem solved
   - Validation results
   - Tests and references
   - Limitations or assumptions

## 9. Versioning & Release Checklist

Before tagging:
- All tests pass (`make test`)
- Docs regenerated (`make docs`, `make pdf`)
- `README.md` updated
- Version header bumped
- CSV exports attached if relevant

## 10. References

- Meissner & Wentz (2004). *The complex dielectric constant of pure and sea water from microwave satellite observations.* IEEE TGRS 42(9)
- UNESCO (1983). *Algorithms for computation of fundamental properties of seawater.* Tech Papers in Marine Science 44
- TEOS-10 Manual (2010). *GSW Toolbox v3.06*
- Marshall & Palmer (1948). *The distribution of raindrops with size.* QJRMS
