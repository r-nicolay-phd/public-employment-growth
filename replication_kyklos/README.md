# Replication package for "Accounting, Not Averaging Out: Public Wage Bills and Economic Growth"

Rodolfo Tomás da Fonseca Nicolay, [AUTHOR 2], [AUTHOR 3]. Submitted to *Kyklos*.

## Overview

The code in this package builds annual, three-year and five-year country panels from publicly available sources and produces every table and figure of the article and the online appendix: Tables 1–3, A1–A5 and S1–S18, and Figures 1–4, A1–A5 and S1–S4.

- The code is in Stata 17. Two short Python scripts only download or convert source files.
- `code/master.do` runs everything in a single pass. `code/kyklos_numbering.py` then copies the outputs to the numbering of the article.
- A full run takes about 31 minutes on a desktop computer.
- The analysis plan registered before the estimates were produced is in `docs/analysis_plan.pdf`, and the deviations from it are listed in `docs/deviations_from_plan.md`.

## Data Availability and Provenance Statements

### Statement about rights

- [x] I certify that the author(s) of the manuscript have legitimate access to and permission to use the data used in this manuscript.
- [x] I certify that the author(s) of the manuscript have documented permission to redistribute/publish the data contained within this replication package. Appropriate permission are documented in the [LICENSE.txt](LICENSE.txt) file and in `docs/data_sources.csv`.

All data come from public sources. The authors have permission to use every source for academic research. They redistribute only the sources whose terms allow it, listed in the table below with "yes". The other sources must be downloaded by the replicator, following the instructions in each `data/raw/<folder>/SOURCE.txt`.

### License for Data

The data constructed by the authors and the documentation are licensed under CC BY 4.0; the code under the BSD 3-Clause licence (see [LICENSE.txt](LICENSE.txt)). Third-party data keep the terms of their providers.

### Summary of Availability

- [ ] All data **are** publicly available.
- [x] Some data **cannot be made** publicly available.
- [ ] **No data can be made** publicly available.

Every source is public, but five of them cannot be redistributed or have uncertain terms, so they are not in the package: QoG (two files), Polity5, the Alesina–Favero–Giavazzi fiscal plans and UCDP/PRIO. Each can be downloaded free of charge.

### Details on each data source

| Data source | Files (in `data/raw/`) | Provided | Licence or terms | Access date |
|---|---|---|---|---|
| IMF Government Finance Statistics, Statement of Operations | `imf_gfs/gfs_soo.csv` | Yes | IMF Copyright and Usage | 2026-10-07 |
| IMF GFS, Expenditure by Functions of Government (COFOG) | `imf_cofog/gfs_cofog_saude_educ.csv` (subset) | Yes | IMF Copyright and Usage | 2026-11-13 |
| IMF Investment and Capital Stock Dataset | `imf_icsd/icsd.csv` | Yes | IMF Copyright and Usage | 2026-10-07 |
| IMF Global Debt Database | `imf_gdd/gdd.csv` | Yes | IMF Copyright and Usage | 2026-10-07 |
| IMF Commodity Terms of Trade (Gruss and Kebhaj) | `imf_ctot/ctot.csv` | Yes | IMF Copyright and Usage | 2026-10-07 |
| IMF Fiscal Decentralization Dataset | `imf_fd/fd.csv` | Yes | IMF Copyright and Usage | 2026-10-07 |
| IMF Fiscal Rules Dataset 1985–2024 | `manual/Publication - IMF FAD Fiscal Rules Dataset 1985-2024 Update.xlsx` | Yes | IMF Copyright and Usage | 2026-10-14 |
| Laeven and Valencia (2018), systemic banking crises | `laeven_valencia/SYSTEMIC_BANKING_CRISES_DATABASE_2018.xlsx` | Yes | IMF Copyright and Usage | 2026-10-17 |
| World Development Indicators | `wdi/`, `wdi_rev/` | Yes | CC BY 4.0 | 2026-10-07, 10-17, 11-13 |
| Worldwide Governance Indicators | `wgi/wgi.csv` | Yes | CC BY 4.0 | 2026-10-07 |
| Worldwide Bureaucracy Indicators | `wwbi/wwbi.csv` | Yes | CC BY 4.0 | 2026-10-07 |
| World Bank historical income classification | `income_hist/` | Yes | CC BY 4.0 | 2026-10-07 |
| Penn World Table 11.0 | `pwt/pwt110.dta` | Yes | CC BY 4.0 | 2026-10-07 |
| ILOSTAT | `ilostat/`, `ilostat_ud/ud.csv` | Yes | CC BY 4.0 | 2026-10-07, 10-17 |
| V-Dem v16 (variable extracts) | `vdem/vdem_subset.csv`, `vdem/vdem_rev.csv` | Yes | CC BY-SA 4.0 | 2026-10-07 |
| Database of Political Institutions 2020 | `dpi/DPI2020_stata13.dta` | Yes (unmodified) | CC BY-NC-ND 3.0 IGO | 2026-10-07 |
| Eurostat gov_10a_main | `eurostat/gov_10a_main.csv` | Yes | CC BY 4.0 | 2026-10-07 |
| QoG Standard Dataset, time series, Jan 2026 (includes the ICRG indicator of quality of government) | `qog/qog_std_ts_jan26.csv` | **No** | QoG terms (no redistribution; ICRG proprietary) | 2026-10-07 |
| QoG Expert Survey 2020, aggregate | `qog/qog_exp_agg_20.csv` | **No** | QoG terms | 2026-10-07 |
| Polity5 | `polity/p5v2018.xls` | **No** | Center for Systemic Peace (no redistribution) | 2026-11-13 |
| Alesina, Favero and Giavazzi (2019), fiscal adjustment plans | `afg/NewComponents1978-2014_final.xlsx` | **No** | Terms of the original dataset not stated | 2026-10-17 |
| UCDP/PRIO Armed Conflict Dataset v26.1 | `ucdp/UcdpPrioConflict_v26_1.csv` | **No** | No explicit licence found | 2026-10-07 |

Full citations, URLs and terms are in `docs/data_sources.csv`. Each `data/raw/<folder>/SOURCE.txt` repeats them and, for the five sources that are not provided, says where to download the file and under which name to save it.

## Dataset list

| File | Description | Provided |
|---|---|---|
| `data/raw/*` | Source files, as downloaded (see table above) | Yes, except the five sources above |
| `data/analysis/` | Panels constructed by `code/build/` and intermediate results of `code/` | No: rebuilt by `code/master.do`; they combine sources that cannot be redistributed |
| `output/generated/` | Tables (`.tex`, `.docx`) and figures (`.png`, `.pdf`, `.eps`) as written by the Stata code | Rebuilt by `code/master.do` |
| `output/tables/`, `output/figures/` | The same files with the numbering of the article | Yes (and rebuilt by `code/kyklos_numbering.py`) |

## Computational requirements

### Software requirements

- Stata 17 (MP or SE; the results were produced with StataMP 17.0). The code sets `version 17`.
- Community-contributed packages, shipped in `code/ado/plus` and loaded by `code/config.do`; no installation is needed. The packages used, with the distribution date of the copy in the package:

| Package | Distribution date | Source |
|---|---|---|
| reghdfe | 2026-01-11 | SSC |
| ftools | 2026-01-11 | SSC |
| ivreghdfe | 2026-01-11 | SSC |
| ivreg2 | 2024-08-14 | SSC |
| ranktest | 2020-09-29 | SSC |
| avar | 2015-07-30 | SSC |
| xtscc | 2018-04-03 | SSC |
| xtabond2 | 2025-02-09 | SSC |
| xtdpdgmm | 2022-08-05 | SSC |
| xtdpdbc | 2024-07-11 | kripfganz.de/stata |
| boottest | 2026-06-09 | SSC |
| rwolf, rwolf2 | 2020-07-08, 2021-07-09 | SSC |
| weakivtest, weakiv, twostepweakiv | 2026-07-22, 2016-10-18, 2019-01-12 | SSC |
| xtpmg | 2026-07-06 | SSC |
| xtdcce2, xtcd2, xtcsd | 2024-06-06, 2023-05-15, 2007-04-10 | SSC |
| xthenreg (Seo, Kim and Kim) | version 1.0 | author's distribution |
| xthreg (Wang) | 2014-01-09 | author's distribution |
| bma, wals (De Luca and Magnus) | version 1.0 | author's distribution |
| interflex | 2017-02-01 | github.com/xuyiqing/interflex_stata |
| locproj | 2026-02-19 | SSC |
| specurve | 2025-02-06 | github.com/mgao6767/specurve |
| kountry | 2013-08-16 | SSC |
| estout, coefplot, blindschemes, moremata, require | 2026-04-13, 2025-08-22, 2020-08-07, 2026-01-11, 2023-09-21 | SSC |

`code/00_instala.do` reinstalls the packages from their sources, if a replicator prefers fresh copies; the results were produced with the versions above.

- Python 3 (only for `code/kyklos_numbering.py`, which needs `python-docx`, for `code/kyklos2/conferencia_manuscrito.py`, which needs `pandas`, and for the optional scripts `code/dl_wdi_mv.py`, `code/conv_cofog.py` and `code/build/01_coleta_fontes.py`, which download or convert source files).

### Controlled randomness

Random seeds are set in `code/build/00_setup.do` (20261007), `code/00_setup.do` (20261017), `code/kyklos/00_setup_k.do` (20261113), `code/kyklos2/00_setup_k2.do` (20261115) `code/kyklos3/00_setup_k3.do` (20261116) and `code/kyklos4/00_setup_k4.do` (20261117), which every do-file runs first. The bootstrap procedures (wild cluster bootstrap, Romano–Wolf, pairs bootstrap, kernel bootstrap) use these seeds.

### Memory, runtime and storage requirements

- Run time: 1,859 seconds (about 31 minutes) for `code/master.do`, measured on a clean copy of the package (13 November 2026), on a desktop computer with Windows 11 Pro and StataMP 17. Most of it is the Romano–Wolf bootstrap in `code/12_inferencia.do`.
- The Kyklos steps 4–7 below take about 69, 44, 61 and 149 minutes (step 7: 8,927 seconds on the run of 17 November 2026).
- Storage: about 250 MB, including the downloaded data and the outputs.

## Description of programs

- `code/config.do`: the only file to edit. It sets the root folder of the package and the path of the Stata packages.
- `code/master.do`: runs the build and the analysis in order and reports the time of each step.
- **Panel construction (`code/build/`):**
  - `00_setup.do`, `00_tabelas.do` and `00_rotulos.do`: paths, seed, labels;
  - `02_limpeza_wdi.do`, `02_limpeza_fmi.do`, `02_limpeza_trabalho.do` and `02_limpeza_instituicoes.do`: import and clean each group of sources;
  - `03_painel.do`: builds the annual, three-year and five-year panels in `data/analysis/`;
  - `01_coleta_fontes.py`: optional, downloads the sources available through APIs.
- **Analysis (`code/`):**
  - `00_setup.do`: paths, seeds, graph style and the routines that write tables and figures;
  - `01_auditoria.do`: data cleaning rules and the panels of the analysis;
  - `02_timing.do` to `12_inferencia.do`: one block of estimates each (see the list below);
  - `13_tabelas.do`: summary tables and hypothesis verdicts;
  - `14_figuras.do`: descriptive figures;
  - `15_documentos.do`: Table S1 and the list of packages;
  - `00_instala.do`: optional reinstallation of the packages;
  - `dl_wdi_mv.py` and `conv_cofog.py`: download and conversion of the World Bank series of Table S17 and of the IMF COFOG export.
- `code/kyklos_numbering.py`: copies the tables and figures to the numbering of the article. It renumbers the table titles and the cross-references in the notes, and changes no estimate.

## Instructions to replicators

1. Download the five files that are not provided (see the table above and each `data/raw/<folder>/SOURCE.txt`) and save them in `data/raw/<folder>/` with the names given there.
2. Optionally, edit `code/config.do` to set the full path of this folder. Otherwise start Stata in this folder.
3. Run `do code/master.do` in Stata 17. The log `master.log` reports the time of each step.
4. Run `do code/kyklos/master_kyklos.do` for the additional estimates of the Kyklos submission (Tables S19–S28, Figures S5–S8 and the proposed single-inference Table 2 and new Figures 1 and 3). They were registered in `docs/plan_addendum_kyklos.md` (commit `3faa1ea`) before being estimated. This step takes about 69 minutes (4,116 seconds on the run of 13 November 2026), mostly the simulation in `06_simulacao.do` and the bootstraps in `05_lp_predeterminado.do`.
5. Run `do code/kyklos2/master_kyklos2.do` for the final estimates of the Kyklos submission (new Table A5 and Figure A3, and new panels, rows or columns of Tables A2, A6, A11, A15, A16, A17 and A18 in the numbering of version 4). They were registered in `docs/plan_addendum_kyklos_2.md` (commit `be45e06`) before being estimated. This step takes about 44 minutes (2,624 seconds on the run of 16 November 2026), mostly the block bootstrap of shock (b) in `07_lp_acumulado.do` and the simulations in `01_simulacao.do`.
6. Run `do code/kyklos3/master_kyklos3.do` for the estimates requested for the final version (registered in `docs/plan_addendum_kyklos_3.md`, commit `c402c35`, before being estimated; see `docs/registration_timeline.md`). It reads the intermediate files of steps 3–5 and the series in `data/raw/imf_gfs_xdc/` and `data/raw/imf_weo_ngdp/` (downloaded by `code/kyklos3/dl_fontes.py`). This step takes about 61 minutes (3,633 seconds on the run of 16 November 2026), mostly the calibrated simulation and the pairs bootstrap with re-simulated nulls.
7. Run `do code/kyklos4/master_kyklos4.do` for the re-estimates requested on version 5 (registered in `docs/plan_addendum_kyklos_4.md`, commit `fb6c84b`, before being estimated; the code was committed before its final run, commit `d28c3db`; see `docs/registration_timeline.md`). It reads the intermediate files of steps 3–6 and the WDI vintages in `data/raw/wdi_archives/` (December 2022 and December 2023, downloaded by `code/kyklos4/dl_wdi_vintage.py` from the WDI Database Archives, World Bank API source 57). Seed 20261117. This step takes about 149 minutes (8,927 seconds on the run of 17 November 2026), mostly the simulation grids in `01_grade_k.do` and `01b_psi.do` and the pairs bootstrap with re-simulated nulls in `02b_nula.do`.
   The tables and figures with the numbering of version 5 of the article are in `output/final/` (Tables 1–2 and A1–A17, Figures 1–4 and A1–A3). They were assembled by `code/kyklos4/final_v5.py` (which extends `code/kyklos3/numeracao_final.py`): it merges each base table with its added parts, renumbers titles and cross-references, replaces internal labels and points references to tables outside the article to rows of this README; the script expects the folder layout of the project (it is included for documentation) and changes no estimate. `code/kyklos4/confere_memo4.py` checks the numbers of the results memorandum against the tables.
8. Run `python code/kyklos_numbering.py output/generated output` to write the tables and figures with the numbering of the article in `output/tables/` and `output/figures/` (the final estimates are copied with the suffix `_v4`).


The intermediate files written by the code (under `data/analysis/` and `output/logs/`) keep the file names of the original project, some of them in Portuguese.

## List of tables and programs

All tables are written as `.tex` and `.docx`, and all figures as `.png` (600 dpi), `.pdf` and `.eps`.

| Kyklos number | Content | File in `output/tables/` or `output/figures/` | File written by the code (`output/generated/`) | Program |
|---|---|---|---|---|
| Table 1 | Wage bill coefficient under different measures | `Table_1_measures` | `tables/Tab1_measures` | `code/03_vies.do` |
| Table 2 | General versus central government wage bill | `Table_2_coverage` | `tables/Tab4_coverage` | `code/04_cobertura.do` |
| Table 3 | Employment or relative pay: decomposition | `Table_3_decomposition` | `tables/Tab5_decomposition` | `code/05_decomposicao.do` |
| Table A1 | Timing of the initial wage bill | `Table_A1_timing` | `tables/Tab2_timing` | `code/02_timing.do` |
| Table A2 | Baseline estimates and composition of spending | `Table_A2_baseline_composition` | `tables/Tab3_baseline_composition` | `code/13_tabelas.do` (estimates from `code/12_inferencia.do`) |
| Table A3 | Institutions and government size: replications | `Table_A3_institutions_replications` | `tables/Tab6_replications` | `code/06_instituicoes.do` |
| Table A4 | Political economy of the wage bill | `Table_A4_political_economy` | `tables/Tab7_political_economy` | `code/09_economia_politica.do` |
| Table A5 | Robustness map | `Table_A5_robustness_map` | `tables/Tab8_robustness_map` | `code/13_tabelas.do` |
| Table S1 | Data sources, definitions and cleaning rules | `Table_S1_data_sources_cleaning` | `tables/TabS1_data_cleaning` | `code/15_documentos.do` |
| Table S2 | Descriptive statistics | `Table_S2_descriptives` | `tables/TabS2_descriptives` | `code/13_tabelas.do` |
| Table S3 | Decomposition of the contemporaneous-ratio bias | `Table_S3_bias_decomposition` | `tables/TabS_bias_decomposition` | `code/03_vies.do` |
| Table S4 | Distributed lags and leads | `Table_S4_lags_leads` | `tables/TabS_lags_leads` | `code/03_vies.do` |
| Table S5 | General and central government wage bill by country | `Table_S5_general_central_ratio` | `tables/TabS_gg_cg_ratio` | `code/04_cobertura.do` |
| Table S6 | Decomposition: division-bias corrections | `Table_S6_decomposition_bias` | `tables/TabS_decomposition_bias` | `code/05_decomposicao.do` |
| Table S7 | Institutions and fiscal cyclicality | `Table_S7_cyclicality` | `tables/TabS_cyclicality` | `code/06_instituicoes.do` |
| Table S8 | Structural and crisis explanations | `Table_S8_structural` | `tables/TabS_structural` | `code/07_estrutural.do` |
| Table S9 | Meritocratic recruitment as moderator | `Table_S9_merit_moderation` | `tables/TabS_moderation` | `code/08_merito.do` |
| Table S10 | Narrative wage-bill consolidations | `Table_S10_narrative_consolidations` | `tables/TabS_exogenous` | `code/10_exogena.do` |
| Table S11 | Bond check and long-run estimators | `Table_S11_bond_longrun` | `tables/TabS_bond_longrun` | `code/11_longo_prazo.do` |
| Table S12 | Mechanisms | `Table_S12_mechanisms` | `tables/TabS_mechanisms` | `code/13_tabelas.do` |
| Table S13 | Hypothesis tests | `Table_S13_hypothesis_tests` | `tables/TabS_inference_summary` | `code/13_tabelas.do` (bootstrap in `code/12_inferencia.do`) |
| Table S14 | Local projections by horizon | `Table_S14_lp_horizons` | `tables/TabS_lp_horizons` | `code/13_tabelas.do` |
| Table S15 | Bayesian model averaging | `Table_S15_bma` | `tables/TabS_bma` | `code/13_tabelas.do` |
| Table S16 | Countries in the estimation sample | `Table_S16_countries` | `tables/TabS16_countries` | `code/13_tabelas.do` |
| Table S17 | Mollick and Vianna (2024) with the published specification | `Table_S17_mollick_vianna_published` | `tables/TabS_mv_faithful` | `code/06_instituicoes.do` |
| Table S18 | Oto-Peralías and Romero-Ávila (2013) with Polity5 | `Table_S18_oto_peralias_polity5` | `tables/TabS_opra_xconst` | `code/06_instituicoes.do` |
| Figure 1 | Timing of the initial wage bill | `Figure_1_timing` | `figures/Fig3_timing` | `code/02_timing.do` |
| Figure 2 | Institutions and government size | `Figure_2_institutions` | `figures/Fig4_reconciliation` | `code/06_instituicoes.do` |
| Figure 3 | Local projections | `Figure_3_local_projections` | `figures/Fig7_lp_level_leads` | `code/03_vies.do` |
| Figure 4 | Specification curve | `Figure_4_specification_curve` | `figures/Fig9_specification_curve` | `code/12_inferencia.do` |
| Figure A1 | Wage bill by income group | `Figure_A1_wagebill_income` | `figures/Fig1_wagebill_income` | `code/14_figuras.do` |
| Figure A2 | Coefficient under different measures | `Figure_A2_measures` | `figures/Fig2_measures` | `code/03_vies.do` |
| Figure A3 | Public employment and relative pay | `Figure_A3_employment_relative_pay` | `figures/Fig5_employment_relwage` | `code/14_figuras.do` |
| Figure A4 | Marginal effect across merit | `Figure_A4_marginal_effect_merit` | `figures/Fig6_marginal_merit` | `code/08_merito.do` |
| Figure A5 | Local projections by merit regime | `Figure_A5_lp_merit` | `figures/Fig8_lp_merit` | `code/14_figuras.do` |
| Figure S1 | Data coverage | `Figure_S1_coverage` | `figures/FigS1_coverage` | `code/14_figuras.do` |
| Figure S2 | Structural and crisis explanations | `Figure_S2_structural` | `figures/FigS_structural` | `code/07_estrutural.do` |
| Figure S3 | Binning estimator (interflex) | `Figure_S3_interflex_binning` | `figures/FigS_interflex_binning` | `code/08_merito.do` |
| Figure S4 | Narrative wage-bill consolidations | `Figure_S4_narrative_consolidations` | `figures/FigS_exogenous` | `code/10_exogena.do` |


**Additional estimates (code/kyklos/).** All of them are post-plan analyses pre-registered in the addendum, and none enters the verdicts of Table S13.

| Kyklos number | Content | File in `output/tables/` or `output/figures/` | File written by the code (`output/generated/kyklos/`) | Program |
|---|---|---|---|---|
| Table 2 (proposed) | Table 2 with a single bootstrap inference | `Table_2_coverage_single_inference_proposed` | `tables/Tab2new_coverage` | `code/kyklos/09_cobertura_k.do` |
| Table S19 | Approximate replication of Mollick and Cabral (2011) | `Table_S19_mollick_cabral` | `tables/TabS19_mollick_cabral` | `code/kyklos/01_mollick_cabral.do` |
| Table S20 | Other spending ratios and the sign condition | `Table_S20_spending_items` | `tables/TabS20_spending_items` | `code/kyklos/02_outras_razoes.do` |
| Table S21 | Five-year grid of measure × control timing | `Table_S21_five_year_grid` | `tables/TabS21_five_year_grid` | `code/kyklos/03_grade_quinquenal.do` |
| Table S22 | H2 with strict timing | `Table_S22_h2_strict_timing` | `tables/TabS22_h2_strict` | `code/kyklos/04_h2_estrito.do` |
| Table S23 | Local projections with predetermined shocks | `Table_S23_lp_predetermined_shocks` | `tables/TabS23_lp_predetermined` | `code/kyklos/05_lp_predeterminado.do` |
| Table S24 | Simulation under a calibrated null (panel E: post-hoc diagnostic) | `Table_S24_simulation` | `tables/TabS24_simulation` | `code/kyklos/06_simulacao.do`, `06b_simulacao_ar.do`, `06c_tabela_simulacao.do` |
| Table S25 | Equivalence, influence and selection | `Table_S25_equivalence_influence` | `tables/TabS25_equivalence` | `code/kyklos/07_equivalencia.do` |
| Table S26 | Institutions: tests of differences, mechanism, index × period | `Table_S26_institutions_tests` | `tables/TabS26_institutions_tests` | `code/kyklos/08_instituicoes_k.do` |
| Table S27 | General versus central government: difference in differences | `Table_S27_coverage_did` | `tables/TabS27_coverage` | `code/kyklos/09_cobertura_k.do` |
| Table S28 | Smaller checks | `Table_S28_checks` | `tables/TabS28_checks` | `code/kyklos/10_verificacoes.do` |
| Figure 1 (proposed) | Five-year grid | `Figure_1_timing_grid_proposed` | `figures/Fig1new_timing_grid` | `code/kyklos/03_grade_quinquenal.do` |
| Figure 3 (proposed) | Local projections with the shock dated t − 1 | `Figure_3_lp_shock_dated_t-1_proposed` | `figures/Fig3new_lp_shock_a` | `code/kyklos/05_lp_predeterminado.do` |
| Figure S5 | Mollick and Cabral: coefficients by measure | `Figure_S5_mollick_cabral` | `figures/FigS5_mollick_cabral` | `code/kyklos/01_mollick_cabral.do` |
| Figure S6 | Local projections with three shocks | `Figure_S6_lp_shocks` | `figures/FigS6_lp_shocks` | `code/kyklos/05_lp_predeterminado.do` |
| Figure S7 | Simulated distributions | `Figure_S7_simulation` | `figures/FigS7_simulation` | `code/kyklos/06c_tabela_simulacao.do` |
| Figure S8 | Leave one country or period out | `Figure_S8_influence` | `figures/FigS8_influence` | `code/kyklos/07_equivalencia.do` |

**Final estimates (code/kyklos2/).** Post-plan analyses pre-registered in the second addendum (`docs/plan_addendum_kyklos_2.md`, commit `be45e06`); none enters the verdicts of Table A19. The files are written with the numbering of version 4 (next section).

| Version 4 | Content | File in `output/tables/` or `output/figures/` | File written by the code (`output/generated/kyklos2/`) | Program |
|---|---|---|---|---|
| Table A5 (new version) | Simulation under the null: anchored, mean-reverting and registered designs on a grid of ε; direct decomposition | `Table_A5_simulation_v4` | `tables/Table_A5_simulation` | `code/kyklos2/01_simulacao.do`, `01b_decomposicao.do`, `09_tabelas_k2.do` |
| Figure A3 (new version) | Simulated coefficient against 1 − ε; institutional interaction under the null | `Figure_A3_simulation_v4` | `figures/Figure_A3_simulation` | `code/kyklos2/09_tabelas_k2.do` |
| Table A2, panel B | Descriptive statistics on the exact Table 1 sample | `Table_A2_panel_B_harmonized_v4` | `tables/Table_A2_panel_B_harmonized` | `code/kyklos2/09_tabelas_k2.do` |
| Table A6, new rows | Fiscal years: countries excluded and fiscal years realigned | `Table_A6_new_rows_v4` | `tables/Table_A6_new_rows` | `code/kyklos2/05_ano_fiscal.do` |
| Table A11, new panel | Bias checks for the predetermined estimate | `Table_A11_panel_bias_checks_v4` | `tables/Table_A11_panel_bias_checks` | `code/kyklos2/02_vies.do` |
| Table A15, new panels | Institutions × later period; institutional interaction under the null | `Table_A15_new_panels_v4` | `tables/Table_A15_new_panels` | `code/kyklos2/03_instituicoes_testes.do`, `04_simulacao_inst.do` |
| Table A16, new rows | Mollick and Vianna: CIs against the published interaction, equivalence | `Table_A16_new_rows_v4` | `tables/Table_A16_new_rows` | `code/kyklos2/03_instituicoes_testes.do` |
| Table A17, new columns | H2 with reverse-denominator controls | `Table_A17_new_columns_v4` | `tables/Table_A17_new_columns` | `code/kyklos2/06_h2_reverso.do` |
| Table A18, new panel | Cumulative local-projection effects (LP-IV) | `Table_A18_new_panel_v4` | `tables/Table_A18_new_panel` | `code/kyklos2/07_lp_acumulado.do` |

`code/kyklos2/08_conferencia.do` and `code/kyklos2/conferencia_manuscrito.py` write the reconciliation of counts and of the numbers quoted in the text (`conferencia_bloco8.csv`, `conferencia_manuscrito.csv`). The list of fiscal years used in `05_ano_fiscal.do` is in `data/raw/fiscal_year/` (IMF World Economic Outlook metadata, accessed 16 November 2026).

## Numbering of version 5 of the article

Version 5 of the manuscript uses the numbering of `output/final/`, as in the final version below, with one more appendix figure, Figure A3 (annual, dynamic and five-year estimates on a common scale). The re-estimates of the fourth addendum enter as added parts of existing tables:

| Version 5 | Added part (file written by `code/kyklos4/`, in `output/generated/kyklos4/tables/`) | Program |
|---|---|---|
| Table A4, panels K–M | `Table_A4_part_moment_matched` (moment-matched calibration, ψ variant, analytic reference) | `01_grade_k.do`, `01b_psi.do`, `01c_resumo_k.do` |
| Table A6, new rows | `Table_A6_rows_five_year_tests` (Mollick and Cabral, predetermined five-year coefficient) | `04_grade_mc.do` |
| Table A7, new rows | `Table_A7_rows_grid_tests` (tested differences and timing trend) | `04_grade_mc.do` |
| Table A8, new part | `Table_A8_part_drivers` (country-periods behind the five-year estimate; full-sample checks; null-adjusted estimates) | `02_quinquenal.do`, `02b_nula.do` |
| Table A9, new part | `Table_A9_part_common_scale` (common scale, compatibility tests, Holm) | `03_escala.do`, `03b_holm.do` |
| Table A12, new row | `Table_A12_rows_trend_null` | `05_inst.do` |
| Table A13, new part | `Table_A13_part_null_shares` (full table of null shares; Holm over 24 cells) | `05_inst.do` |
| Table A14, new rows | `Table_A14_rows_vintage` (WDI vintages) | `05_inst.do` |
| Figure 1 (new version) | `Figure_1_simulation` (three panels) | `07_tabelas_k4.do` |
| Figure A2 | `Figure_A2_influence` (regenerated without embedded note) | `07_tabelas_k4.do` |
| Figure A3 (new) | `Figure_A3_common_scale` | `07_tabelas_k4.do` |

The mapping from each version-5 exhibit to all its parts is in `code/kyklos4/final_v5.py` (list `FINAL` of `numeracao_final.py` plus `EXTRA` and `FIGS`).

## Numbering of the final version of the article

The final version of the manuscript uses the numbering of `output/final/`: Tables 1 (measures) and 2 (employment and relative pay); appendix Tables A1 data and cleaning, A2 descriptive statistics, A3 other spending items, A4 simulation under the null, A5 checks of the annual panel, A6 Mollick and Cabral, A7 five-year grid, A8 preferred estimate and bias checks, A9 equivalence, influence and selection, A10 robustness map, A11 general versus central government, A12 institutional replications, A13 institutional tests, A14 Mollick and Vianna (published specification), A15 H2 with strict timing, A16 local projections, A17 hypothesis verdicts; Figures 1 simulation, 2 five-year grid, 3 institutions, 4 local projection with the dated shock, A1 coverage, A2 influence. The mapping from each final exhibit to the files written by the code is in `code/kyklos3/numeracao_final.py` (list `FINAL`). The tables of earlier versions that are not in the final version remain in `output/tables/` and are cited in the final notes as supplementary tables of the replication package.

## Numbering of version 4 of the article

Version 4 of the manuscript uses a single appendix series. The table below maps it to the files of the package. Earlier versions of the package numbered the supplementary tables S1–S28; those file names are kept.

| Version 4 | File in `output/tables/` | Content |
|---|---|---|
| Table 1 | `Table_1_measures` | Measures of the wage bill |
| Table 2 | `Table_2_coverage_single_inference_proposed` | General versus central government |
| Table 3 | `Table_3_decomposition` | Employment versus relative pay |
| Table A1 | `Table_S1_data_sources_cleaning` | Data and cleaning |
| Table A2 | `Table_S2_descriptives` (panel B: `Table_A2_panel_B_harmonized_v4`) | Descriptive statistics |
| Table A3 | `Table_S3_bias_decomposition` | Decomposition and placebo |
| Table A4 | `Table_S20_spending_items` | Other spending items |
| Table A5 | `Table_A5_simulation_v4` (earlier version: `Table_S24_simulation`) | Simulation under the null |
| Table A6 | `Table_S28_checks` and `Table_A6_new_rows_v4` | Smaller checks |
| Table A7 | `Table_S19_mollick_cabral` | Replication of Mollick and Cabral |
| Table A8 | `Table_S21_five_year_grid` | Five-year grid |
| Table A9 | `Table_A1_timing` | Timing (preferred specification T3) |
| Table A10 | `Table_S25_equivalence_influence` | Equivalence, influence and selection |
| Table A11 | `Table_A2_baseline_composition` and `Table_A11_panel_bias_checks_v4` | GMM and composition; bias checks |
| Table A12 | `Table_A5_robustness_map` | Robustness map |
| Table A13 | `Table_S27_coverage_did` | Federations versus unitary countries |
| Table A14 | `Table_A3_institutions_replications` | Institutional replications |
| Table A15 | `Table_S26_institutions_tests` and `Table_A15_new_panels_v4` | Institutional tests |
| Table A16 | `Table_S17_mollick_vianna_published` and `Table_A16_new_rows_v4` | Mollick and Vianna, published specification |
| Table A17 | `Table_S22_h2_strict_timing` and `Table_A17_new_columns_v4` | H2 with strict timing |
| Table A18 | `Table_S23_lp_predetermined_shocks` and `Table_A18_new_panel_v4` | Local projections |
| Table A19 | `Table_S13_hypothesis_tests` | Hypothesis verdicts |
| Figure 1 | `Figure_1_timing_grid_proposed` | Five-year grid |
| Figure 2 | `Figure_4_specification_curve` | Specification curve |
| Figure 3 | `Figure_2_institutions` | Institutions |
| Figure 4 | `Figure_3_lp_shock_dated_t-1_proposed` | Local projection with the dated shock |
| Figure A1 | `Figure_A1_wagebill_income` | Wage bill by income group |
| Figure A2 | `Figure_S1_coverage` | Coverage |
| Figure A3 | `Figure_A3_simulation_v4` (earlier version: `Figure_S7_simulation`) | Simulation |
| Figure A4 | `Figure_S8_influence` | Influence |
| Figure A5 | `Figure_A3_employment_relative_pay` | Employment and relative pay |
| Figure A6 | `Figure_S6_lp_shocks` | Three shocks |

The titles and notes inside the files listed with their earlier names keep the earlier numbering; the manuscript uses the numbering of the first column.

The files written by the code carry the numbering of the project's working version: the main-text tables 2–8 and the figures. `code/kyklos_numbering.py` renumbers their titles and cross-references to the numbering above. References to tables of other works, such as the tables of Mollick and Vianna (2024), keep their own numbers.

## References

The full citation of each dataset, in APA 7 format, is in `docs/data_sources.csv`. The main ones are:

- Coppedge, M., Gerring, J., Knutsen, C. H., Lindberg, S. I., Teorell, J., et al. (2026). *V-Dem Country-Year Dataset v16* [Data set]. Varieties of Democracy (V-Dem) Project. https://doi.org/10.23696/vdemds26
- Cruz, C., Keefer, P., & Scartascini, C. (2021). *Database of Political Institutions 2020* [Data set]. Inter-American Development Bank.
- Feenstra, R. C., Inklaar, R., & Timmer, M. P. (2025). *Penn World Table version 11.0* [Data set]. Groningen Growth and Development Centre. https://doi.org/10.34894/FABVLR
- Gruss, B., & Kebhaj, S. (2019). *Commodity terms of trade: A new database* (IMF Working Paper No. 19/21). International Monetary Fund.
- Laeven, L., & Valencia, F. (2018). *Systemic banking crises revisited* (IMF Working Paper No. 18/206). International Monetary Fund.
- Marshall, M. G., & Gurr, T. R. (2020). *Polity5: Political regime characteristics and transitions, 1800–2018* [Data set]. Center for Systemic Peace.
- The Quality of Government Institute. (2026). *The QoG Standard Dataset, time-series* (Version Jan26) [Data set]. University of Gothenburg.
- World Bank. (n.d.). *World Development Indicators*; *Worldwide Governance Indicators*; *Worldwide Bureaucracy Indicators* [Data sets].
- International Monetary Fund. (n.d.). *Government Finance Statistics*; *Investment and Capital Stock Dataset*; *Global Debt Database*; *Fiscal Decentralization Dataset*; (2025) *Fiscal Rules Dataset 1985–2024*; (2026) *GFS COFOG* [Data sets].
- Alesina, A., Favero, C., & Giavazzi, F. (2019). *Austerity: When it works and when it doesn't*. Princeton University Press.
- International Labour Organization. (n.d.). *ILOSTAT* [Data set]. Eurostat. (n.d.). *gov_10a_main* [Data set]. Uppsala Conflict Data Program. (2026). *UCDP/PRIO Armed Conflict Dataset v26.1* [Data set].
