# Odin Mie Toolkit Makefile

ODIN ?= odin

.PHONY: all test export clean

all: test

test:
	@echo "Running CI tests..."
	bash scripts/run_ci.sh

export:
	@echo "Exporting (k, α) grid to k_alpha_grid.csv..."
	$(ODIN) run examples/export_k_alpha_grid.odin -- -collection:.. --out k_alpha_grid.csv --fmin 3 --fmax 12 --fstep 1 --tmin 0 --tmax 30 --tstep 5 --sa 35.16504 --p 0

clean:
	@echo "Cleaning generated CSVs..."
	rm -f k_alpha_grid.csv

docs:
	@echo "Generating API docs (docs/api.md) ..."
	python3 scripts/gen_docs.py

pdf:
	@echo "Building technical brief PDF (docs/tech-brief.pdf) ..."
	pdflatex -halt-on-error -interaction=nonstopmode -output-directory docs docs/tech-brief.tex >/dev/null || (echo "pdflatex failed"; exit 1)


# --- Snow & Ice convenience targets ---
ODIN ?= odin
FREQ ?= 9.65
TEMP ?= -5
RHO  ?= 200
LWC  ?= 0
RATE ?= 1

.PHONY: snow validate-ice compare-snow-psd

snow:
	@echo "Running snow k,α fit at FREQ=$(FREQ) GHz, TEMP=$(TEMP) °C, RHO=$(RHO) kg/m^3, LWC=$(LWC) kg/m^3, RATE=$(RATE) mm/h (WE)"
	$(ODIN) run examples/snow_k_alpha.odin -- --freq $(FREQ) --temp $(TEMP) --rho $(RHO) --lwc $(LWC) --rate $(RATE)

validate-ice:
	@echo "Validating ice models across bands and temperatures..."
	$(ODIN) run examples/validate_ice_models.odin

compare-snow-psd:
	@echo "Comparing snow PSD fits and k,α outcomes..."
	$(ODIN) run examples/compare_snow_psd.odin
