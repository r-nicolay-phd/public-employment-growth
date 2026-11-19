# Addendum to the analysis plan: additional estimates for the Kyklos submission

Written and committed before any of the estimates below were produced. It complements the analysis plan committed on 17 October 2026 (commit `2182199cbd7a3a4c775c06f0d5ae01f22c215218`, tag `analysis-plan-2026-10-17`).

- **Status of the original plan.** The preferred specifications of H1–H5 and the verdicts of Table S13 do not change.
- **Status of the new analyses.** Everything below is exploratory or robustness and is reported in new tables (S19–S27) and new figures (S5–S8). The only exceptions are the regenerated Table 2, whose coefficients are unchanged but whose inference changes (Block 9), and new versions of Figures 1 and 3, if adopted.
- **Common rules.**
  - Seed `set seed 20261113` and `version 17` in every do-file; code in `code/kyklos/`.
  - Standard errors clustered by country in five-year panels, Driscoll-Kraay (maximum lag 3) in annual panels.
  - Wild cluster bootstrap with Webb weights and 9,999 replications (`boottest`) for main coefficients and tested differences. Country bootstraps use 999 replications.
  - 95% confidence intervals are always reported, and each table takes its stars from a single inference, stated in the note.
- **Numbering.** Table 1, Table 2 (old 4), Table 3 (old 5), A1–A5 (old 2, 3, 6, 7, 8), S1–S18 unchanged; new tables from S19; new figures from S5.
- **Notation.**
  - *Annual Table 1 model:* growth of real GDP per capita on the measure, lagged growth, lagged log GDP per capita, human capital, investment, openness, inflation, population growth and commodity terms-of-trade growth, with country and year fixed effects, 1996–2023, no microstates.
  - *T3:* five-year averages 1979–2023, wage bill in t_p − 1, predetermined controls in t_p − 1, country and period fixed effects.
  - *Significant* means p < 0.05 unless stated.

## Block 1. Mollick and Cabral (2011)

- **Source.** The article is available (`Consensus/mollick2011.pdf`, Kyklos 64(1): 122–137).
- **Published specification.**
  - **Sample:** 54 economies (22 industrial and 32 emerging, their Table 1), 1986–2004.
  - **Model:** dependent y_it = log real GDP per capita, on y_i,t−1, population growth n, ln(I/Y), openness and ln(G/Y), where G/Y is general government final consumption from the WDI.
  - **Estimator:** one-step System GMM (Blundell–Bond) with robust errors. All regressors are endogenous except n. Instruments are lags 2–4 of y and all available lags (2 and deeper) of the other endogenous variables, without collapsing. There are no time effects.
  - **Annual and five-year versions:** one lag of y for the full sample. The five-year panel uses blocks 1986–1990, 1991–1995, 1996–2000 and 2001–2004, with y at the last year of the block and the other variables averaged.
  - **Published coefficients on ln(G/Y), full sample:** −0.032 (0.008) annual (Table 2, col. 1); −0.086 (0.060) five-year (Table 3, col. 1). The five-year coefficient is not smaller in absolute value; it loses significance.
  - **Columns replicated:** column 1 (no openness) and column 4 (trade openness), full sample.
- **Data.** Current WDI vintage (GDP per capita in constant 2015 USD, NE.CON.GOVT.ZS, gross capital formation NE.GDI.TOTL.ZS, trade, population). Their foreign-asset measures (IFI, GEQ) are not used. The table is labelled "approximate replication" because of data vintages and these omissions.
- **Measures**, each in logs, with the same sample, controls and estimator:
  - (a) same-year G/Y;
  - (b) placebo numerator: L.(G/Y) × (L.real GDP / real GDP) × exp(mean real growth of government consumption of the country), as for the wage bill placebo;
  - (c) G over Hamilton trend GDP (H = 2, k = 2);
  - (d) G/Y lagged one year;
  - (e) five-year panel: period mean, first year t_p, last year of the previous block t_p − 1.
- **Estimators.** Fixed effects (country FE, no time effects, as in their model, errors clustered by country) and their System GMM.
- **Tests.** Differences (a) − (c), (a) − (d) and (a) − (b) by wild cluster bootstrap in the stacked FE model (country × measure fixed effects). For the GMM, the confidence intervals are compared.
- **Extension.** 1986–2023, same 54 countries.
- **Decision rule (Block 11).** The pattern is reproduced if the annual same-year FE coefficient and the annual same-year GMM coefficient are negative with p < 0.05. The "collapse" condition holds if, with the lagged measure (d) or the Hamilton measure (c), the annual GMM coefficient falls by at least 50% in absolute value and has p ≥ 0.05. The rule is evaluated with column 1, 1986–2004, GMM, and repeated for FE as information.

## Block 2. Other spending ratios

- **Sample.** Annual Table 1 model and sample definition (1996–2023, controls of Table 1). A common sample within each item, across its measures.
- **Items:**
  - (i) general government final consumption (WDI);
  - (ii) total general government expenditure (GFS);
  - (iii) social benefits and transfers (GFS share of expense × total expenditure);
  - (iv) gross public investment (IMF ICSD, P51G_S13).
- **Measures:** same year, placebo (as above, with the item's real growth deflated by the GDP deflator), Hamilton, one-sided HP and lagged one year.
- **Elasticities.** Nominal–nominal elasticity of each item to GDP, from the regression of 100 Δln(nominal item) on 100 Δln(nominal GDP) with country and year FE and Driscoll-Kraay errors (as in panel C of Table S3, |growth| < 200). The real–real version deflates the item by the GDP deflator.
- **Bias.** Bias = b(same year) − b(lagged one year), tested in a stacked model by wild cluster bootstrap.
- **Sign condition (operational).**
  - If the 95% CI of the nominal elasticity lies below 1, the bias must be negative with a 95% bootstrap CI below zero.
  - If it lies above 1, the bias must be positive with a CI above zero.
  - If it contains 1, the bias CI must contain zero.
  - The condition is confirmed item by item.
- **Decision rule.** Confirmed in at least 3 of the 4 items → "spending ratios" with the elasticity caveat; otherwise restrict to wage bill and consumption.

## Block 3. Five-year sequence with predetermined controls

- **Grid.** One common sample (intersection of all cells) for a 3 × 2 grid:
  - wage bill measure: period mean / t_p / t_p − 1;
  - controls: period means (log initial income, human capital in t_p, investment, openness, inflation, population growth and terms-of-trade growth as period means) / t_p − 1 (T3 controls).
- **Additional cells:**
  - growth from t_p + 1 to t_p + 4 for each of the six cells;
  - t_p − 1 over Hamilton trend GDP with both control sets, with average growth and with growth excluding the first year.
- **Decomposition.** Starting from T1 (t_p − 1, period-mean controls), each control is switched, one at a time, to its t_p − 1 value (investment, openness, inflation, population growth, terms of trade, log GDP per capita, human capital).
- **Inference.** Cluster SE, 95% CI and wild cluster bootstrap p for every cell.
- **Decision rule.** With predetermined controls, compute the reduction 1 − b(t_p − 1)/b(t_p). If it is at least 0.40, keep "Timing, not averaging, drives the five-year coefficient"; otherwise rewrite.

## Block 4. H2 with strict timing

- **Strict sample.** Wage bill and WWBI public employment pairs measured in t_p − 1 to t_p − 4 only (same-year pair rule of Table 3, excluding pairs from t_p onwards). The premium uses the same restriction on its own year.
- **Estimates:**
  - (a) logs of both components;
  - (b) each component with the log total wage bill as control;
  - (c) relative wage over trend GDP per worker, with log employment;
  - (d) log employment instrumented with log ILOSTAT public employment, with the effective F of Montiel Olea–Pflueger and the Anderson–Rubin CI;
  - (e) the adjusted WWBI premium.
- **Inference.**
  - Wild cluster bootstrap p for every coefficient.
  - Romano–Wolf with the registered family of Table S13 (unchanged) and an alternative family in which H2 uses the strict sample, with the same 999 country draws. The alternative family does not change the registered verdict.
  - The wild bootstrap p of the −1.68 coefficient of Table S6 is also reported.
- **Magnitudes.** Effect of one within-country SD of each regressor, compared with the within-country SD of five-year growth.
- **Decision rule.** In the strict sample, if the relative-wage coefficient in (a) has bootstrap p < 0.05, H2 stays in the main text; otherwise it is downgraded to suggestive and the policy recommendation is removed.

## Block 5. Local projections with predetermined shocks

- **Shocks:**
  - (a) dated in t − 1: 100 × (W_{t−1}/P_{t−2} − W_{t−2}/P_{t−2}) / y_{t−2}, computed as L.wb × L.nominal GDP / L2.nominal GDP − L2.wb (in % of GDP);
  - (b) purged: residual of the real wage bill change (current definition) on current growth and two lags, with country-specific slopes and country and year fixed effects. It is a generated regressor; its standard errors come from a country block bootstrap that re-estimates the purging regression in every replication (999 replications);
  - (c) the current definition deflated by the deflator of t − 1: wb × nominal GDP / L.nominal GDP − L.wb.
- **Responses.** y100_{t+h} − y100_{t−1}, h = −3, …, 6 (h = −1 is zero by construction), with two lags of the shock and of growth, and country and year FE, 1996–2023.
- **Inference.**
  - Driscoll-Kraay;
  - lag-augmented (one extra lag of the shock and of growth, heteroskedasticity-robust errors);
  - half-panel jackknife bias correction (1996–2009 and 2010–2023), with the full-sample Driscoll-Kraay SE as its standard error.
  - Leads h = −3 and −2 are tabulated.
- **Merit regimes.** Merit above the median in t − 2, for shock (a). The difference high − low is adjusted by Romano–Wolf over h = 0, …, 6 with 999 country draws.
- **Decision rule.** With shock (a): if no response at h = 3, …, 6 is significant at 5% in at least two of the three inferences → "no robust evidence of a delayed cost"; otherwise report the estimated cost and discuss its magnitude.

## Block 6. Simulation under a calibrated null

- **Data-generating process.** Observed GDP, growth and controls are kept. Only the wage bill is replaced, in nominal terms:
  - ln W_sim_t = ln W_sim_{t−1} + ε Δln Ynom_t + u_t;
  - u_t is drawn with replacement from the country's own values of Δln W − ε Δln Ynom;
  - the initial level is the observed wage bill in the country's first year with data;
  - ε = 0.48, with variants 0.30 and 0.70;
  - 1,000 replications for each ε.
- **Regressions in each replication:**
  - the six annual measures of Table 1 (same year, two-sided HP, one-sided HP, Hamilton, lagged, lagged over Hamilton), in the Table 1 sample;
  - five-year period mean, t_p and t_p − 1, with period-mean and with t_p − 1 controls, in their own samples.
  - Point estimates come from the same fixed-effects models; the coefficients are identical to those of the reported models.
- **Reported:** mean and 2.5–97.5 percentiles; share of the observed coefficient explained by the simulated mean; whether T3 (−0.142) lies inside the simulated 95% interval.
- **Placebo test.** The placebo − same-year difference in the stacked model, with wild cluster bootstrap, and the correlation of the two regressors.
- **Log decomposition.** The coefficient on log(W/Y*) divided by the sample mean of W/Y* (effect per point of trend GDP), with delta-method CI, compared with T3.
- **Decision rule.** Explained share of the annual same-year coefficient (ε = 0.48): ≥ 80% → "essentially all"; 50–80% → "most"; < 50% → rewrite the thesis.

## Block 7. Equivalence and influence

- **Equivalence.** TOST at 5% (90% CI) for the lagged wage bill in the annual Table 1 model (Driscoll-Kraay) and for T3 (clustered), with bounds ±0.05, ±0.10 and ±0.20. Also reported: the smallest symmetric bound at which equivalence is established (max |90% CI limit|) and the minimum detectable effect at 80% power ((1.96 + 0.84) × SE).
- **Economic translation.** The T3 95% CI limits × (−3) give the annual growth effect of a 3-point cut in the wage bill.
- **Influence on T3:**
  - leave one country out; leave one period out;
  - exclude transition economies (former USSR, Central and Eastern Europe, Balkans) in periods starting before 1999;
  - exclude 2019–2023; exclude 1979–1993;
  - restrict to countries with GFS wage bill data by 2000.
- **Selection.** Mean log GDP per capita, merit and debt in t_p − 1 of early (data by 2000) and late GFS entrants, compared in the T3 sample.
- **Decision rule.** Equivalence established at ±0.10 for T3 → "the data rule out effects larger than 0.1 points per point of GDP"; otherwise "neither support nor rule out moderate effects".

## Block 8. Institutions

- **Tests of differences.** Same-year − lagged and same-year − trend-GDP interactions in panels C and D of Table A3, by wild cluster bootstrap in stacked FE models (country × measure fixed effects).
- **Mechanism conditions**, each "verified" if significant at 5%:
  - (a) the interaction between nominal GDP growth and institutions (WGI mean, centred; and the ICRG/QoG index) in the regressions of nominal growth of government consumption and of the wage bill on nominal GDP growth, with country and year FE and Driscoll-Kraay errors;
  - (b) the cross-country correlation between the variance of the Hamilton output gap and mean institutions;
  - (c) the cross-country correlation between the SD of the cyclical part of consumption/GDP (fitted values of a country regression of the ratio on the Hamilton gap) and mean institutions.
- **Index versus period** in the Oto-Peralías and Romero-Ávila replication:
  - (a) ICRG/QoG in the five-year periods 1996–2020;
  - (b) WGI in 1996–2005;
  - (c) ICRG/QoG and WGI on the same countries and periods.
  - FE and System GMM for each.
- **Note correction in Table A3.** Panels A–C use growth of real GDP per capita; panel D uses real GDP growth.
- **Decision rule.** The contemporaneous − lagged difference significant at 5% in panel D **and** at least one mechanism condition verified → "explained by timing". Only the difference → "consistent with a timing artifact". Neither → "timing explains part of the published result".

## Block 9. General versus central government

- **Difference-in-differences.** (general − central) in federations minus (general − central) in unitary countries, by paired country bootstrap (999).
- **Split of unitary countries.** By the general/central ratio in 2010–2019 (above or below 1.5), with the same comparison.
- **Table 2 re-estimated** with one inference: percentile CI and stars from the same country bootstrap (999).
- **Median general/central ratio** of the federations in the estimation sample.

## Block 10. Smaller checks

1. Recessions: same-year ratio estimated separately for country-years with a positive and a negative Hamilton gap in t − 1, instead of truncating the dependent variable.
2. Anticipation: wage bill at t_{p+1} − 1 on growth in period p, controlling for the wage bill in t_p − 1, country and period FE.
3. Correlation of the growth of the one-sided HP trend and of the Hamilton trend with current GDP growth.
4. T3 with lagged growth (LSDV) and with bias correction.
5. GFSM breaks: only if the GFS files report the methodological basis.
6. Regenerated tables with corrected notes (A5, A1–A2 rounding, A3).

## Block 11. Decision rules

| Item | If… | Then the manuscript… |
|---|---|---|
| Title and framing (Block 1) | in the Mollick–Cabral replication the annual same-year coefficient is negative and significant and, with the lagged or trend-GDP measure, falls by at least 50% and is not significant at 5% | keeps the title and the "inversion" thesis |
| | the pattern does not reproduce, or the lagged coefficient remains significant | changes the title to a restricted version and presents the reinterpretation as a hypothesis supported by the wage bill |
| Scope (Block 2) | the sign condition holds in at least three of the four items | may speak of "spending ratios" with the elasticity caveat |
| | otherwise | restricts the claim to the wage bill and consumption |
| "Timing, not averaging" (Block 3) | with predetermined controls, moving from t_p to t_p − 1 reduces the coefficient by at least 40% | keeps the sentence |
| | otherwise | rewrites: "averaging dilutes the accounting component; with predetermined controls, first-year timing matters little" |
| H2 (Block 4) | in the strict sample the relative-wage coefficient has bootstrap p < 0.05 | keeps H2 in the main text, with the IV and the adjusted premium as caveats |
| | otherwise | downgrades H2 to suggestive and removes the policy recommendation on relative pay |
| Local projections (Block 5) | with shock (a), no response at h = 3–6 is significant in two of the three inferences | "no robust evidence of a delayed cost" |
| | otherwise | reports the estimated cost and discusses the magnitude |
| "Accounting" (Block 6) | the simulated mean explains at least 80% of the annual same-year coefficient | "the denominator can account for essentially all of the coefficient" |
| | between 50% and 80% | "most of the coefficient" |
| | below 50% | rewrites the thesis |
| Policy (Block 7) | equivalence is established at ±0.10 | "the data rule out effects larger than 0.1 points per point of GDP" |
| | otherwise | "the data neither support nor rule out moderate effects", and the sentence on wage bill targets is removed |
| Institutions (Block 8) | the same-year − lagged difference is significant at 5% **and** a mechanism condition holds | "explained by timing" |
| | only the difference | "consistent with a timing artifact" |
| | neither | "timing explains part of the published result" |
