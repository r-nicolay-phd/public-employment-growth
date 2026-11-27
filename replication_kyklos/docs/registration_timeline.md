# Registration timeline of the analysis plan and its addenda

The plan and the four addenda are deposited at the Open Science Framework: https://doi.org/10.17605/OSF.IO/EF7K3.

This file reconstructs, from the git history of the project repository, when the analysis plan and its addenda were committed and when the analyses they govern were first run. The commit hashes, author dates and commit dates can be verified with the git bundle deposited with this file:
- `git bundle verify repo_until_addendum4.bundle` (or `repo_until_addendum3.bundle` for the state at the third addendum);
- `git log --format="%H %ad %cd %s" --date=iso`, after cloning the bundle.

Times are local (UTC−3). Commit and author dates coincide for every commit listed.

The plan and the addenda are the only files whose registration this timeline documents. No commit was rewritten and no date was changed.

## 1. Plan and addenda

| Document | File | Commit (full hash) | Date |
|---|---|---|---|
| Analysis plan (hypotheses H1–H5, preferred specifications, decision rule) | `docs/PLANO_REVISAO.md` | `2182199cbd7a3a4c775c06f0d5ae01f22c215218` | 2026-10-17 16:16:00 |
| First addendum (additional estimates for the Kyklos submission) | `docs/plan_addendum_kyklos.md` | `3faa1ea65b7a1827107b30169962cf81732260ca` | 2026-11-13 17:55:25 |
| Second addendum (final estimates, version 4) | `docs/plan_addendum_kyklos_2.md` | `be45e06401f466d895f09826b28cfbe909ca2312` | 2026-11-16 13:45:23 |
| Third addendum (estimates requested for the final version) | `docs/plan_addendum_kyklos_3.md` | `c402c35c7a051094634c5f469ef08ee5539014c9` | 2026-11-16 19:26:08 |
| Fourth addendum (re-estimates requested on version 5) | `docs/plan_addendum_kyklos_4.md` | `fb6c84b1fa0293f197deeafe6735fe974004ebf1` | 2026-11-17 13:23:55 |

## 2. Estimation code governed by the plan (`code/revisao/`, under version control)

The table gives the first commit of each do-file. The last column is the time at which the do-file's committed log was opened: the Stata log header ("opened on") of the run whose output was committed with it.

| Do-file | Governed by | First commit | First-commit date | Committed run started |
|---|---|---|---|---|
| `00_instala.do`, `00_setup.do` | (setup, no estimation) | `abd544b` | 2026-10-17 16:14:10 | — |
| `01_auditoria.do` | (audit and reproduction of the specifications estimated before the plan; see section 4) | `abd544b` | 2026-10-17 16:14:10 | 16:13:40 |
| `02_timing.do` | plan, block 4.1 | `94f6b53` | 2026-10-17 16:19:36 | 16:19:26 |
| `03_vies.do` | plan, block 4.2 | `158d20b` | 2026-10-17 16:25:42 | 16:25:08 |
| `04_cobertura.do` | plan, block 4.3 | `49aa2f7` | 2026-10-17 16:30:47 | 16:27:09 |
| `05_decomposicao.do` | plan, block 4.4 | `6c62a22` | 2026-10-17 16:32:21 | 16:31:58 |
| `06_instituicoes.do` | plan, block 4.5 | `72b0d09` | 2026-10-17 16:34:41 | 16:34:12 |
| `07_estrutural.do` | plan, block 4.6 | `81d3dbb` | 2026-10-17 16:37:04 | 16:35:48 |
| `08_merito.do` | plan, block 4.7 | `9163c2b` | 2026-10-17 16:55:10 | 16:50:56 |
| `09_economia_politica.do` | plan, block 4.8 | `efc5bae` | 2026-10-17 16:56:34 | 16:56:14 |
| `10_exogena.do` | plan, block 4.9 | `13a2652` | 2026-10-17 16:57:32 | 16:57:15 |
| `11_longo_prazo.do` | plan, block 4.10 | `6d55a45` | 2026-10-17 17:04:14 | 17:01:04 |
| `12_inferencia.do` to `16_relatorio.do`, `master.do` | plan, block 4.11 and outputs | `b06e7bc` | 2026-10-17 20:56:59 | 17:06:14 (12_inferencia) |

The outputs of `code/revisao/` are under version control. The earliest is `output/revisao/logs/01_auditoria.log`, first committed in `abd544b` (16:14:10). The earliest output of a registered block is `output/revisao/logs/02_timing.log` and `output/revisao/figures/Fig3_timing.*`, first committed in `94f6b53` (16:19:36). Every log of a registered block was opened after the plan commit (16:16:00). Test runs that were not committed cannot be dated by git.

## 3. Code governed by the addenda (`code/kyklos/`, `code/kyklos2/`, not under version control)

The do-files and outputs of the two Kyklos rounds were not committed. Their dates come from the file system (creation time of the earliest file in each folder) and **cannot be verified by git**.

| Folder | Governed by | Addendum commit | Earliest file creation (file system) |
|---|---|---|---|
| `code/kyklos/` | first addendum | 2026-11-13 17:55:25 | do-files from 18:01:55; first intermediate result (`data/interim/kyklos/kv.csv`) 17:57:16; first table (`output/kyklos/tables/TabS19_mollick_cabral.csv`) 18:10:21 |
| `code/kyklos2/` | second addendum | 2026-11-16 13:45:23 | do-files from 13:45:58; first intermediate result (`data/interim/kyklos2/kv.csv`) 13:47:07; first table 13:53:14 |
| `code/kyklos3/` | third addendum | 2026-11-16 19:26:08 | see `docs/KYKLOS_FINAL2_LOG.md` |

On these dates, no result of an analysis covered by an addendum precedes the commit of that addendum.

## 4. Results that precede the commit that registered them

The analysis plan of 17 October 2026 was written for a revision of a study whose earlier versions had already been estimated. The repository holds those estimates:
- commit `dc8cd8f`, 2026-10-07 23:28:29;
- commit `781942e`, 2026-10-17 15:57:03.

The plan registered new hypotheses and preferred specifications. Earlier specifications of the following analyses, however, had been estimated before it:

| Analysis registered in the plan | Earlier specification estimated before the plan | First commit of the earlier result |
|---|---|---|
| H1, wage bill and growth (preferred: wage bill in t_p − 1, controls in t_p − 1) | Five-year averages with the wage bill in the first year of the period and period-mean controls (`output/tables/Table2_baseline`) | `dc8cd8f`, 2026-10-07 |
| Same-year versus predetermined measures (Table 1) | Annual and five-year comparison of the same-year ratio with trend-GDP and lagged ratios (`output/tables/TableA7_denominator`: −0.686 same year, 0.03–0.04 with predetermined measures) | `dc8cd8f`, 2026-10-07 |
| H2, employment versus relative pay (preferred: logs, WWBI pair nearest t_p − 1) | Levels of public employment and relative wage in the first year (`output/tables/Table3_decomposition`) | `dc8cd8f`, 2026-10-07 |
| H3, merit moderation | `output/tables/Table4_moderation` | `dc8cd8f`, 2026-10-07 |
| H5, political economy of the wage bill | `output/tables/Table6_political_economy` | `dc8cd8f`, 2026-10-07 |
| H4, institutions and government size (replications) | Annual and five-year interaction of government size with institutions (`output/extensoes/tables/TableL1_frequency_institutions`) | `781942e`, 2026-10-17 15:57:03 |
| Long-run estimators | `output/extensoes/tables/TableL2_long_run` | `781942e`, 2026-10-17 15:57:03 |

The audit do-file (`01_auditoria.do`), committed two minutes before the plan, reproduces these earlier estimates and does not estimate any registered specification.

Second addendum: the anchored design of the simulation and its sanity check were defined after the registered design of the first addendum (a random walk in the wage bill) had been run and had reproduced 5% of the same-year coefficient. The registered design is still reported (Table A4, panel C).

## 5. Code of the addenda under version control

| Commit | Date | Content | Relation to the estimates |
|---|---|---|---|
| `54e4ccf285ba952ef5a82f2ac43a850bcc4f691e` | 2026-11-17 13:23:55 | `code/kyklos/`, `code/kyklos2/`, `code/kyklos3/` (code of addenda 1–3) | Committed **after** the estimates of those rounds (13 and 16 November 2026); before this commit their dates rest on the file system only (section 3) |
| `d28c3db55cf0653507fc84a759f5a8ba5410b825` | 2026-11-17 13:53:56 | `code/kyklos4/` (code of the fourth addendum) | Committed after the fourth addendum and before the final run of `master_kyklos4.do`; earlier test runs with reduced replications are not dated by git |

Proposed sentence for Appendix A.8: "The code of the first three addenda was placed under version control on 17 November 2026, after the estimates it produces had been run; for those rounds the order between addendum and estimation is documented by file-system dates, not by git. The code of the fourth addendum was committed before its final run."
