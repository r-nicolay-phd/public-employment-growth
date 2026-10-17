# Replication package: revision of "The public wage bill and growth" (draft 8)

This document covers the revision analyses in `code/revisao/`. The draft-7 pipeline (`run_all.do`, `code/00_*.do` to `code/12_*.do`) builds the panels in `data/final/` from `data/raw/` and is documented in `docs/README.md`.

## Software

- **Stata 17** (StataMP 17.0). All estimation, tables and figures are produced in Stata.
- **Community-contributed packages** are in `ado/plus`, installed once by `code/revisao/00_instala.do`. The list, with sources and distribution dates, is in `docs/PACOTES_STATA.md`.
- **Python 3.11** was used only to download external files (WDI API, Harvard Dataverse, ILOSTAT SDMX) and to compare `.docx` text in the audit. It was never used for estimation.

## Data sources added in the revision

Each folder in `data/raw/` has a `_SOURCE.txt` with the address and access date.

| Folder | Source | Accessed |
|---|---|---|
| `data/raw/afg/` | Alesina, Favero and Giavazzi (2019), fiscal adjustment plans 1978–2014, including Spending – Salaries. Public copy in the replication package of Gale, Berlin and Thorpe (2025), Harvard Dataverse doi:10.7910/DVN/J104NQ | 2026-10-17 |
| `data/raw/laeven_valencia/` | Laeven and Valencia (2018), systemic banking crises. Public copy on Harvard Dataverse (file id 11677773) | 2026-10-17 |
| `data/raw/wdi_rev/` | World Bank API: old-age dependency ratio, government health and education expenditure, real government consumption, real GDP | 2026-10-17 |
| `data/raw/ilostat_ud/` | ILOSTAT SDMX, trade union density (ILR_TUMT_NOC_RT) | 2026-10-17 |
| `data/raw/vdem/vdem_rev.csv` | Extracted from V-Dem v16 Full+Others: v2dlencmps, v2x_regime | 2026-10-17 (file from 2026-10-07) |
| `data/raw/qog/` | QoG Standard (Jan 2026): icrg_qog, p_polity2, bmr_dem, bmr_demdur | 2026-10-07 |
| `Consensus/oto_peralias_romero_avila_2012wp.pdf` | Oto-Peralías and Romero-Ávila, INFER Working Paper 2012/3 (text used for the replication) | 2026-10-17 |

Sources that could not be obtained are listed in `docs/DOWNLOADS_MANUAIS.md`. The analyses that depend on them are marked "not executed" in the tables.

## How to run

From the project folder (`Estimações`):

1. Install the packages once, with internet access:
   ```
   StataMP-64.exe /e do code/revisao/00_instala.do
   ```
2. **Optional, for the draft-7 comparison in the audit:** export the draft-7 tables from the baseline commit. In bash:
   ```
   for f in $(git ls-tree --name-only 781942e output/tables/ output/extensoes/tables/ | grep tex$); do
     git show 781942e:$f > data/interim/revisao/draft7_tex/$(basename $f); done
   ```
3. Run everything:
   ```
   StataMP-64.exe /e do code/revisao/master.do
   ```
   The total running time is reported at the end of `master.log`. The Romano-Wolf bootstrap in `12_inferencia.do` takes most of it.

Each do-file sets `version 17` and `set seed 20261017`, and writes a text log to `output/revisao/logs/`. Every number in the tables, figures, captions and reports is read from files written by the do-files, in particular `data/interim/revisao/kv.csv`.

## Do-files and outputs

| Do-file | Plan section | Outputs |
|---|---|---|
| `00_setup.do` | — | Paths, packages, graph scheme, table and figure routines, Hamilton and one-sided HP filters |
| `00_instala.do` | — | Package installation |
| `01_auditoria.do` | 4.0 | New sources; extended cleaning; revision panels (annual, 3- and 5-year); canonical samples; draft-7 inconsistencies; reproduction of the draft-7 tables; `docs/AUDITORIA_DRAFT7.md` |
| `02_timing.do` | 4.1 | Table 2, Figure 3 |
| `03_vies.do` | 4.2 | Table 1, Tables S3–S4, Figures 2 and 7 |
| `04_cobertura.do` | 4.3 | Table 4, Table S5 |
| `05_decomposicao.do` | 4.4 | Table 5, Table S6 |
| `06_instituicoes.do` | 4.5 | Table 6, Table S7, Figure 4 |
| `07_estrutural.do` | 4.6 | Table S8, Figure S2 |
| `08_merito.do` | 4.7 | Table S9, Figure 6, Figure S4 |
| `09_economia_politica.do` | 4.8 | Table 7 |
| `10_exogena.do` | 4.9 | Table S10, Figure S3 |
| `11_longo_prazo.do` | 4.10 | Table S11 |
| `12_inferencia.do` | 4.11 | H1b and H4 estimates, Romano-Wolf, specification curve (Figure 9), local-projection inference, BMA |
| `13_tabelas.do` | 5, 6 | Table 3, Table 8, Tables S2 and S12–S16, verdicts and scenario |
| `14_figuras.do` | 5 | Figures 1, 5 and 8, Figure S1 |
| `15_documentos.do` | 5 | Table S1, `output/revisao/captions.md`, `output/revisao/MAPA_NUMERACAO.md`, `docs/PACOTES_STATA.md` |
| `16_relatorio.do` | 7 | `docs/RESULTADOS_REVISAO.md`, `docs/RESPOSTA_PARECER.md`, `docs/TEXTO_SUGERIDO.md` |

Tables are written to `output/revisao/tables/` in two formats: `.tex` with booktabs, and editable `.docx`. Figures are written to `output/revisao/figures/` as vector PDF and as PNG at 600 dpi.

## Pre-registration

The analysis plan `docs/PLANO_REVISAO.md` was committed on its own, before any revision estimate: commit `2182199`, 17 October 2026, 16:16 (UTC−3). Analyses that are not in the plan are labelled exploratory.
