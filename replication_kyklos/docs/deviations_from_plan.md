# Deviations from the registered analysis plan

The analysis plan is `analysis_plan.pdf`. It is an exact copy of the plan as committed on 17 October 2026 at 16:16 (UTC−3), commit `2182199cbd7a3a4c775c06f0d5ae01f22c215218`, annotated tag `analysis-plan-2026-10-17`. The plan fixed the specifications, the preferred specification of each hypothesis and the verdict rules before any of the estimates reported in the article were produced.

The hypothesis verdicts in Table S13 follow the plan. None of the analyses listed below enters those verdicts or the rule that classifies the overall result. Table numbers follow the Kyklos submission (Tables 1–3, A1–A5, S1–S18).

## 1. Exploratory analyses added after the plan

| Analysis | Where | Why it was added | Enters the Table S13 verdicts? |
|---|---|---|---|
| Replication of Mollick and Vianna (2024) with their published specification: total real GDP growth, log government consumption, WGI government effectiveness, control of corruption and rule of law, log investment, population growth, their 138 countries, White standard errors. The WGI estimates for 1997, 1999 and 2001, which WGI does not publish, are linearly interpolated, because the published number of observations implies that those years are included. | Table S17; panel D of Table A3; three rows of Figure 2 | The published text was not available when the plan was written, so the plan registered only an approximate replication (panel C of Table A3). The text became available afterwards. | No. The registered rule still uses the approximate replication. The same rule applied to this replication is reported only as a sensitivity check. |
| Oto-Peralías and Romero-Ávila (2013) with executive constraints (Polity5, xconst) as the institutional measure | Table S18 | Polity5 could not be downloaded automatically when the plan was written and was obtained later; the original article uses this measure in its robustness section. | No |
| Average of the wage bill over t − 5 to t − 1 as a single regressor | Table S4 (row of the lag average) | The registered sum of lags 1 to 5 is unstable because the lags are almost collinear. The single regressor was added as a descriptive check. The registered sum is still reported. | No |
| Health and education spending share measured with IMF GFS COFOG | Table S8, row 4b | The plan named the COFOG measure but declared a substitute (WDI health and education spending over GFS total expenditure) because COFOG could not be obtained. COFOG was obtained after the estimates of the plan were produced. It is reported next to the declared substitute (row 4a). The combined row of Table S8 keeps the substitute, as registered. | No |

## 2. Analyses in the plan that were not carried out

| Analysis | Reason | Enters the Table S13 verdicts? |
|---|---|---|
| Wage bill surprises from IMF programme conditionality (MONA) | The MONA database could not be exported (automated access blocked; manual export not obtained) | No (not estimated) |
| IMF programmes as a control in the structural checks (Table S8, row 9b) | Same reason (MONA) | No (not estimated) |
| Forecast errors of the wage bill from vintages of the OECD Economic Outlook | No public series of vintages of this variable was available to the project | No (not estimated) |
| Herbst and Johannsen (2024) small-sample correction of the local projections | No Stata implementation is available. The lag-augmented local projections and a half-panel jackknife bias correction are reported instead (Table S14) | No |
| Public employment from OECD Government at a Glance as an instrument | Not obtained; public employment from ILOSTAT is used | No |
| Years of transition between GFS manuals, by country | Country metadata on the change of manual not available | No (not estimated) |
| Staggered subnational elections in federations | No public subnational election calendar in the project data | No (not estimated) |

## 3. Additional estimates for the Kyklos submission (post-plan, pre-registered in addendum 3faa1ea)

These analyses were written in `plan_addendum_kyklos.md` and committed on 13 November 2026 (commit `3faa1ea65b7a1827107b30169962cf81732260ca`), before any of them was estimated. They are post-plan relative to the original plan and pre-registered in the addendum. None of them enters the verdicts of Table S13.

| Analysis | Where | Status |
|---|---|---|
| Approximate replication of Mollick and Cabral (2011) with same-year, placebo, trend-GDP and lagged government size, fixed effects and System GMM, 1986–2004 and 1986–2023 | Table S19, Figure S5 | post-plan, pre-registered in addendum 3faa1ea |
| Same-year bias and its sign for government consumption, total expenditure, social benefits and public investment, with the elasticity of each item to GDP | Table S20 | post-plan, pre-registered in addendum 3faa1ea |
| Five-year grid of wage bill timing × control timing on one sample, growth excluding the first year, trend-GDP version, control-by-control decomposition | Table S21; new version of Figure 1 | post-plan, pre-registered in addendum 3faa1ea |
| H2 with strict timing (WWBI pairs in t_p − 1 to t_p − 4), division-bias corrections, IV, premium, alternative Romano–Wolf family | Table S22 | post-plan, pre-registered in addendum 3faa1ea; the registered H2 verdict is unchanged |
| Local projections with a shock dated t − 1, a purged shock and a shock deflated by the deflator of t − 1; three inferences; merit regimes with Romano–Wolf | Table S23, Figure S6; new version of Figure 3 | post-plan, pre-registered in addendum 3faa1ea |
| Simulation of a zero-effect wage bill (calibrated null), placebo − same-year test, log decomposition | Table S24 (panels A–D), Figure S7 | post-plan, pre-registered in addendum 3faa1ea |
| Equivalence tests, minimum detectable effect, influence and coverage-selection diagnostics | Table S25, Figure S8 | post-plan, pre-registered in addendum 3faa1ea |
| Tests of the same-year − lagged/trend differences in Table A3, mechanism of the interaction, index versus period in the Oto-Peralías and Romero-Ávila replication | Table S26 | post-plan, pre-registered in addendum 3faa1ea |
| General versus central government: difference in differences, split of unitary countries, Table 2 with a single bootstrap inference | Table 2 (new version), Table S27 | post-plan, pre-registered in addendum 3faa1ea |
| Smaller checks: recessions by the sign of the output gap, anticipation, trend filters, dynamics | Table S28 | post-plan, pre-registered in addendum 3faa1ea |
| GFSM breaks | — | in the addendum, not done: the GFS files do not report the methodological basis |

## 4. Diagnostic added after seeing a registered result (not pre-registered)

| Analysis | Where | Reason |
|---|---|---|
| Simulation with the synthetic wage bill ratio anchored on the observed ratio of t − 1 | Table S24, panel E | The registered synthetic series is a random walk whose within-country variance is several times the observed one. The diagnostic keeps the same null without the drift. It was added after the registered result was seen and is not used in any decision. |

## 5. Final estimates for the Kyklos submission (post-plan, pre-registered in addendum 2 be45e06)

These analyses were written in `plan_addendum_kyklos_2.md` and committed on 16 November 2026 (commit `be45e06401f466d895f09826b28cfbe909ca2312`), before any of them was estimated, together with the decision rules for the manuscript. They are post-plan relative to the original plan and pre-registered in the second addendum. None of them enters the verdicts of Table A19 (formerly S13). Table numbers in this section follow version 4 of the article (main Tables 1–3, appendix Tables A1–A19).

| Analysis | Where | Status |
|---|---|---|
| Simulation of a zero-effect wage bill anchored on the observed ratio of t − 1 (recentred residuals, ε = 0, 0.25, 0.48, 0.75, 1), mean-reverting variant (ε = 0.48), registered random-walk design rerun on the same grid; slope on 1 − ε and sanity check; within-country SD, AR(1) and correlation with the placebo of the synthetic series | Table A5 (new version), panels A–C; Figure A3 (new version), panels (a) and (b) | post-plan, pre-registered in addendum 2 be45e06 |
| Direct decomposition of the same-year coefficient into ln s_t−1, Δln W and Δln Y; covariance of the numerator innovation with growth; response of the wage bill to real growth | Table A5, panel D | post-plan, pre-registered in addendum 2 be45e06 |
| Bias checks for the predetermined five-year estimate: output gap, growth of p − 1, negative-gap interaction, 2SLS with earlier ratios as instruments (effective F, Hansen J, Anderson-Rubin CI), Gelbach decomposition, γ × δ and the implied omitted-variable bias, annual version | Table A11, new panel | post-plan, pre-registered in addendum 2 be45e06 |
| Oto-Peralías and Romero-Ávila: test of the consumption × institutions × later-period interaction (FE with wild bootstrap and System GMM; two ways of assigning the 1996–2005 overlap; countries in both periods) | Table A15, panel E | post-plan, pre-registered in addendum 2 be45e06 |
| Mollick and Vianna, published specification: 95% CIs (White and clustered) of the lagged and trend-GDP interactions against the published interaction, equivalence at ±0.5 and ±1.0, for GE, CC and RL | Table A16, new rows | post-plan, pre-registered in addendum 2 be45e06 |
| Simulation of the institutional interaction under the null with an elasticity gradient and with no gradient (control), published and approximate specifications | Table A15, panel F; Figure A3, panel (c) | post-plan, pre-registered in addendum 2 be45e06 |
| Fiscal years: list of countries with non-calendar reporting years (IMF WEO metadata), Table 1 and T3 without them and with realigned fiscal years, stacked bootstrap tests | Table A6, new rows; `data/raw/fiscal_year/` | post-plan, pre-registered in addendum 2 be45e06 |
| H2 with reverse-denominator controls (growth of p − 1, output gap, GDP per worker of the year before the pair, wage bill held fixed) and Romano–Wolf with the added control | Table A17, new columns | post-plan, pre-registered in addendum 2 be45e06; the registered H2 verdict is unchanged |
| Cumulative local-projection effects: wage-bill response, Ramey–Zubairy integral multiplier (LP-IV) by horizon, average growth effect over five years per point of wage bill maintained, for three shocks | Table A18, new panel | post-plan, pre-registered in addendum 2 be45e06 |
| Reconciliation of counts and numbers; Table A2, panel B, recomputed on the exact Table 1 sample | Table A2 (panel B, harmonized); `conferencia_*.csv` | post-plan, pre-registered in addendum 2 be45e06 |

Two implementation details were fixed during the execution and are recorded in `docs/KYKLOS_FINAL_LOG.md`:
- **Simulation coefficients.** They are computed by Frisch–Waugh with a stored projection of the fixed controls and fixed effects. The results are numerically identical to `reghdfe`, and the code checks this in the first replication of each design.
- **Fiscal-year labels.** The convention for labelling fiscal years is assumed, because the sources do not report it.

## 6. Deviation in the design of the simulation under the null

The first addendum (3faa1ea) registered a simulation of a zero-effect wage bill in which the synthetic wage bill follows a random walk from each country's first observed year (registered design).
- **Registered result:** that design reproduced 5% of the same-year coefficient and did not respond to the elasticity ε, contrary to what the accounting argument predicts. Its synthetic ratio is not stationary.
- **Design added afterwards:** the anchored design, in which the synthetic ratio starts each year from the observed ratio of the previous year, and the sanity check that the simulated coefficient grows with 1 − ε and is near zero at ε = 1, were defined in the second addendum (be45e06), after the registered result had been seen.
- **Status:** the anchored design and its calibrated version (third addendum, c402c35) are therefore post-hoc relative to the first addendum, although each was registered before it was run.
- **Reporting:** the registered design is reported in Table A4, panel C, and is called the registered design in the text.

## 7. Analyses of the third addendum (post-plan, pre-registered in addendum 3 c402c35)

The analyses below were written in `plan_addendum_kyklos_3.md` and committed on 16 November 2026 (commit `c402c35c7a051094634c5f469ef08ee5539014c9`) before any of them was estimated. None enters the verdicts of Table A17 (final numbering).

| Analysis | Where (final numbering) |
|---|---|
| Size of the wage bill across samples (T3, from 1999, H2 registered and strict) and functional forms (level, log), with the decomposition of the difference between the H1 and H2 magnitudes | Table A15, new panel |
| Simulation calibrated to the observed within-country SD and AR(1); grid of ε including 0.52 and 0.71; range of the accounting share by design; institutional interaction with the calibrated design and ε_0 = 0.556 and 0.701 | Table A4, new panel; Table A13, panel F, new rows; Figure 1 (new version) |
| Table 1 with predetermined annual controls | Table A5, new rows |
| Distributed lags; panel D of Table A4 without Δln Y; deflator inflation in place of Δln Y; indexation and wage-pressure regressions | Table A4, new panel |
| Sensitivity of the predetermined estimate on a common sample, null-adjusted estimates, leave one period out | Table A8 (replaces the bias panel) |
| Shares of the institutional interaction under the null with CIs, against the replicated and the published interaction; count of significant triple-interaction cells | Table A13 |
| Growth and denominator from different sources (Penn World Table 11.0; IMF GFS and WEO) | Table A5, new rows |
| Consistency checks and regenerated tables with the final numbering | `output/kyklos3/final/` |

## 8. Analyses of the fourth addendum (post-plan, pre-registered in addendum 4 fb6c84b)

The analyses below were written in `plan_addendum_kyklos_4.md` and committed on 17 November 2026 (commit `fb6c84b1fa0293f197deeafe6735fe974004ebf1`, tag `kyklos-addendum-4`) before any of them was estimated, together with the decision rules for the manuscript. Their code was committed before its final run (commit `d28c3db55cf0653507fc84a759f5a8ba5410b825`). None enters the verdicts of Table A17.

| Analysis | Where (version 5 numbering) |
|---|---|
| Accounting share on a grid of k × ε with k chosen by a moment distance (within-country SD and AR(1) of the ratio, lagged and Hamilton coefficients); separate real and price elasticities; residual correlated with real growth (ψ); analytic decomposition | Table A4, panels K–M; Figure 1 (new version) |
| Country-periods behind the fall of the five-year estimate from −0.142 (355) to −0.019 (311): description, group interactions, influence blocks, bias checks on the full sample, null-adjusted estimates on both samples | Table A8, new part |
| Annual, dynamic and five-year estimates on a common scale; compatibility tests; Holm adjustment of the WWBI-sample coefficient | Table A9, new part; Figure A3 |
| Tested differences and linear timing trend in the five-year grid; predetermined five-year coefficient in the Mollick and Cabral replication | Tables A7 and A6, new rows |
| Full table of null shares for the institutional interaction, trend-GDP interaction against its null, WDI vintages of December 2022 and December 2023, Holm over the 24 triple-interaction cells | Tables A12, A13 and A14, new rows or parts |
| One computation per repeated statistic, label and note corrections | `output/kyklos4/final/` |

Choices made within the addendum and documented in `docs/KYKLOS_V5_LOG.md`:
- **Holm instead of Romano–Wolf** for the family of 38 wage-bill coefficients. Romano–Wolf would need the 38 models re-estimated on common bootstrap draws.
- **The ψ grid** uses 200 replications per cell; the chosen point is then run with 1,000.
- **Formatting changes after the final run.** Panel letters, titles, the layout of Figure 1 and two label fixes were changed after the final run (commit `4874e52`); no estimate changed.
