#!/usr/bin/env bash
set -euo pipefail

echo "== Odin Mie CI =="
echo "[1/4] Running sanity test..."
odin run tests/mie_sanity_test.odin -collection:..

echo "[2/4] Running TEOS-10 unit tests..."
odin run tests/test_teos10.odin -collection:..

echo "[3/4] Running TEOS-10 validation (p=0 and pressure sweeps)..."
odin run examples/validate_teos10.odin -collection:..

echo "[4/4] Smoke test for fit_k_alpha CLI..."
odin run examples/fit_k_alpha.odin -collection:.. -- --model MW2004_Sea --sp 35 --freq 9.65 --temp 20
odin run examples/fit_k_alpha.odin -collection:.. -- --model MW2004_Sea_TEOS --sa 35.16504 --p 500 --freq 9.65 --temp 20

echo "All good ✅"
