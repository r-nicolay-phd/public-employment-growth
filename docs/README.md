# Replication package: Public wage bill, bureaucratic quality and economic growth

This package rebuilds every number, table and figure of the paper from the original public data sources. No result is typed by hand: tables (`.tex` and `.docx`), figures (`.pdf` and `.png`), the data audit and the results report are written by the code.

## 1. Software

| Software | Version used | Role |
|---|---|---|
| Stata/MP | 17.0 (revision 14 Jun 2021) | All cleaning, variable construction, estimation, tables and figures |
| Python | 3.11.9 | Only (i) downloading the raw data from public APIs, (ii) reading the original EViews file (`.wf1`) and (iii) converting the final `.dta` panels to `.parquet` |

User-written Stata packages are **vendored** in `code/ado/plus/`, and `code/00_setup.do` points Stata's `PLUS` directory there, so the exact versions below are used regardless of what is installed on the machine:

| Package | Version | Used for |
|---|---|---|
| reghdfe / ftools | 6.13.1 / 2.50.0 | Fixed-effects regressions |
| ivreghdfe, ivreg2, ranktest | 1.1.4, 4.1.12, 2.0.04 | IV with fixed effects |
| weakiv, avar | 2.4.07, 1.0.07 | Anderson-Rubin confidence sets |
| xtabond2 | 3.7.2 | System GMM (Blundell-Bond) |
| xtdpdgmm | 2.6.2 | Cross-check of GMM |
| xtdpdbc | 1.3.2 | Bias-corrected fixed effects (Breitung, Kripfganz and Hayakawa, 2022) |
| xtscc | 1.4 | Driscoll-Kraay standard errors; local projections |
| xthenreg (SJ 19-3, st0573) | 2019 | Dynamic panel threshold model (Seo and Shin, 2016) |
| xthreg (SJ 15-1, st0373) | 2014 | Fixed-effects threshold model (Hansen, 1999) |
| interflex (Stata) | GitHub version, Oct 2026 | Hainmueller, Mummolo and Xu (2019) diagnostics |
| bma (SJ 11-4, st0239) | 2011 | Bayesian model averaging (De Luca and Magnus, 2011) |
| xtdcce2 | 4.7 | CCE mean group |
| moremata | SSC, Oct 2026 | Required by xthenreg |
| kountry | 2.1.6 | Gleditsch-Ward to ISO3 codes |

Python packages are pinned in `requirements.txt` (`pip install -r requirements.txt`).

## 2. How to run

From the project folder, in a POSIX shell (Git Bash on Windows):

```
bash run_all.sh            # reuses raw downloads already in data/raw/
bash run_all.sh --force    # downloads every source again
```

`run_all.sh` runs, in order: `code/01_coleta_wf1.py`, `code/01_coleta_fontes.py`, Stata on `run_all.do` (all `.do` files below), and `code/03b_exporta_parquet.py`. Set the environment variable `STATA` if Stata is not at `C:/Program Files/Stata17/StataMP-64.exe`. The Stata part alone can be run with `StataMP-64.exe /e do run_all.do` from the project folder.

Random seed: `20261007` (`set seed` and `set sortseed`, in `code/00_setup.do`), used by the bootstrap of the threshold tests, the kernel estimator and the cross-validation of `interflex`.

## 3. Data sources

All sources are free. Access date for every automatic download: 7 October 2026. Each folder in `data/raw/` has a `_SOURCE.txt` with the exact URL and access date.

| Source | Folder | Access route |
|---|---|---|
| World Development Indicators | `data/raw/wdi/` | World Bank API v2 |
| Worldwide Governance Indicators | `data/raw/wgi/` | World Bank API v2, source 3 |
| Worldwide Bureaucracy Indicators | `data/raw/wwbi/` | World Bank API v2, source 64 |
| World Bank historical income classification | `data/raw/income_hist/` | OGHIST.xlsx |
| IMF Government Finance Statistics (Statement of Operations) | `data/raw/imf_gfs/` | IMF SDMX 3.0 API, `GFS_SOO` |
| IMF Investment and Capital Stock Dataset | `data/raw/imf_icsd/` | IMF SDMX 3.0 API, `ICSD` |
| IMF Global Debt Database | `data/raw/imf_gdd/` | IMF SDMX 3.0 API, `GDD` |
| IMF Commodity Terms of Trade | `data/raw/imf_ctot/` | IMF SDMX 3.0 API, `CTOT` |
| IMF Fiscal Decentralization | `data/raw/imf_fd/` | IMF SDMX 3.0 API, `FD` |
| IMF World Revenue Longitudinal Database; WEO | `data/raw/imf_world/`, `data/raw/imf_weo/` | IMF SDMX 3.0 API (downloaded, not used in the reported specifications) |
| Eurostat government finance (`gov_10a_main`) | `data/raw/eurostat/` | Eurostat SDMX API |
| ILOSTAT (public employment, total employment, public earnings) | `data/raw/ilostat/` | ILO SDMX API |
| Penn World Table 11.0 | `data/raw/pwt/` | GGDC Dataverse |
| V-Dem v16 (Full+Others) | `data/raw/vdem/` | v-dem.net |
| QoG Standard Dataset (Jan 2026), incl. ICTD/UNU-WIDER GRD; QoG Expert Survey 2020 | `data/raw/qog/` | qogdata.pol.gu.se |
| Database of Political Institutions 2020 | `data/raw/dpi/` | IDB open data portal |
| UCDP/PRIO Armed Conflict Dataset v26.1 | `data/raw/ucdp/` | ucdp.uu.se |
| Original dissertation panel (EViews) | `inputs/` | Provided by the author |
| IMF Fiscal Rules Dataset 1985-2021 | `data/raw/manual/` | **Manual download** (server blocks automated access); see `docs/DOWNLOADS_MANUAIS.md`. Not used in any reported specification. |

## 4. Scripts, in execution order, and outputs

| Script | What it does | Outputs |
|---|---|---|
| `code/00_setup.do` | Paths, seed, vendored packages, table/figure utilities (`00_tabelas.do`), variable labels (`00_rotulos.do`) | – |
| `code/00_lp.do` | Local projection routine with Driscoll-Kraay errors | – |
| `code/01_coleta_wf1.py` | Reads the original `.wf1` | `data/interim/wf1_original.csv` |
| `code/01_coleta_fontes.py` | Downloads all sources | `data/raw/*` |
| `code/02_limpeza_wf1_fase0.do` | Phase 0 control replication of the dissertation | `output/logs/02_limpeza_wf1_fase0.log` |
| `code/02_limpeza_wdi.do`, `_fmi.do`, `_trabalho.do`, `_instituicoes.do` | Source-by-source cleaning to ISO3-year | `data/interim/*.dta` |
| `code/03_painel.do` | Merge, cleaning rules 1-5, constructed variables, 3- and 5-year panels | `data/final/painel_{anual,3anos,5anos}.dta`, `dicionario.csv`, `output/logs/regras_limpeza.csv` |
| `code/03b_exporta_parquet.py` | Format conversion | `data/final/*.parquet` |
| `code/04_descritivas.do` | Descriptive statistics, appendix tables, data audit | Table 1, Tables A1-A3, Figures 1, 2, A1, `docs/AUDITORIA_DADOS.md` |
| `code/05_base.do` | Block A (H1) | Table 2, Tables A4, A5 |
| `code/06_decomposicao.do` | Block B (H2) | Table 3 |
| `code/07_moderacao.do` | Block C (H3) | Table 4, Table A6 |
| `code/07b_figura4.do` | Marginal-effect figures | Figure 4, Figure A2 |
| `code/08_dinamica.do` | Block D (local projections, denominator bias) | Figures 3, 5, 6, Table A7 |
| `code/09_mecanismos.do` | Block E (H4) | Table 5, Figure A3 |
| `code/10_economia_politica.do` | Block F (H5) | Table 6, Figure A4 |
| `code/11_robustez.do` | Block G (robustness) | Tables A8a-A8c, A9, Figures A5, A6 |
| `code/12_relatorio.do` | Numbers for the results report and captions | `docs/RESULTADOS.md` (numeric parts), `output/captions.md` |

## 5. Running time

Measured on the last full run (Windows 11, Stata/MP 17, 64 cores): about 7 minutes for `bash run_all.sh` with raw data already downloaded (417 s in Stata, of which 316 s in `07_moderacao.do`, mostly the 200-replication country bootstrap of the kernel estimator and the 500-replication threshold tests). Downloading all sources from scratch (`--force`) adds about 5 minutes, depending on the connection. Per-step times are printed at the end of `run_all.log`.
