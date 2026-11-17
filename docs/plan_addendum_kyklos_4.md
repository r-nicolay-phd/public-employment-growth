# Fourth plan addendum: re-estimates requested on version 5 of the Kyklos submission (pre-estimation)

Written on 17 November 2026, before any of the estimates below was run. It extends the analysis plan (commit 2182199) and the three Kyklos addenda (3faa1ea, be45e06, c402c35). Nothing here changes the registered results: the preferred specifications of H1–H5 and the verdicts (Table A17) are unchanged. Every analysis below is exploratory and is labelled "post-plan, pre-registered in the fourth addendum".

**Code and settings.**
- Code: `code/kyklos4/`, run by `code/kyklos4/master_kyklos4.do`.
- Settings: Stata 17, seed 20261117 in every do-file.
- Version control: the code is committed to git after this addendum and before it is run.
- Outputs: new parts in `output/kyklos4/tables` and `output/kyklos4/figures`; complete exhibits with the version-5 numbering in `output/kyklos4/final/`, built from `output/kyklos3/final/`.
- Earlier code and outputs are read, never changed.

**Numbering and figures.**
- Numbering: Tables 1–2 and A1–A17, Figures 1–4 and A1–A2.
- New material enters existing tables. One new appendix figure (A3) is added; the appendix stays within 18 tables.
- Figures carry only panel titles, axes and legends; their notes go to the exhibits file.

## Common definitions

The samples and models are those of the earlier addenda:

| Name | Definition |
|---|---|
| Table 1 annual model | 1,621 country-years, 87 countries; country and year fixed effects; Driscoll-Kraay standard errors (lag 3) |
| T3 | Five-year averages; wage bill in t_p − 1; controls in t_p − 1; country and period fixed effects; clustered by country; 355 country-periods |
| Common bias sample | 311 country-periods |
| WWBI samples | Registered H2 sample with the GFS wage bill in t_p − 1 (173); strict sample (148) |

**Inference.**
- Wild cluster bootstrap: by country, Webb weights, 9,999 replications.
- Country pairs bootstrap: 999 draws.
- Simulations: 1,000 replications per design point, unless stated otherwise.

**One computation per statistic.** A statistic that appears in several tables is computed once and reused. For the statistics shown in more than one exhibit, the canonical value is the registered computation:
- the same-year − lagged difference of Table 1 (seed 20261017);
- the bootstrap p of T3 in Table A17 (0.120).

Other tables display those values.

## Block 1: accounting share robust to the simulation design

**1. Extended grid.**
- Design: anchored design of the second addendum, with the drawn residuals multiplied by k.
- Grid: k ∈ {0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.40, 0.50, 0.75, 1.0}; ε ∈ {0.25, 0.48, 0.52, 0.71}; 1,000 replications per cell.
- Reported per replication:
  - coefficients of the same-year ratio, the ratio over Hamilton trend GDP, over one-sided HP trend GDP, over two-sided HP trend GDP, the ratio lagged one year, and T3;
  - within-country SD and AR(1) of the synthetic ratio.
- Reported per cell: means, 2.5–97.5 percentiles, and the share of the observed same-year coefficient (−0.723).

**2. Moment-matching distance.** For each (k, ε):

> D(k, ε) = Σ_m |mean_sim,m − obs_m| / sd_sim,m

- m runs over four moments: (a) within-country SD of the ratio; (b) its AR(1); (c) the coefficient of the lagged ratio; (d) the coefficient of the ratio over Hamilton trend GDP.
- sd_sim,m is the standard deviation of moment m across replications in that cell.
- Equal weights. The same-year coefficient does not enter the distance.
- **Reported for each ε:**
  - the minimising k* and the share at k*;
  - the set of k with D ≤ 1.10 × min D, and its range of shares.
- **"Reproduces the lagged and Hamilton coefficients":** the observed coefficient lies inside the 2.5–97.5 percentiles of its simulated distribution at k*.
- **Main ε for the rule:** 0.48.

**3. Residual correlated with the real cycle.**
- Pool: e_ψ = Δln s_obs + (1 − ε) Δln Y − ψ g / 100, recentred within country, where g is real per-capita growth (%).
- Synthetic ratio: ln s_t = ln s_obs,t−1 − (1 − ε) Δln Y_t + k u_t + ψ g_t / 100, with u_t drawn from the country's e_ψ.
- Grid: ψ ∈ {−0.5, −0.4, …, 0.5} × the k grid of item 1, for ε = 0.48 and 0.71, with 200 replications per cell (to contain the run time).
- (k, ψ) is chosen by the distance of item 2, and 1,000 replications are then run at the chosen point.
- **Rule input:** the chosen ψ ≠ 0 reproduces the lagged and Hamilton coefficients (as defined in item 2), and its same-year share is ≥ 80%.

**4. Analytic reference.**
- Within-country and within-year variation (country and year effects removed), Table 1 sample.
- Var(Δln s) is split into the part of A = −(1 − ε) Δln Y and the part of u = Δln s − A (variances and covariance).
- Reported: the attenuation factor λ = Var(A) / Var(Δln s), and the implied share cov(g, A) / cov(g, Δln s), at ε = 0.48 and 0.71.

**5. Relevant elasticity.**
- Regression: 100 × Δln W on 100 × Δln real GDP and deflator inflation, country and year fixed effects, Driscoll-Kraay, Table 1 sample.
- The anchored k-grid is rerun with the two elasticities separately: Δln s = (ε_r − 1) Δln Y_real + (ε_p − 1) π + k u.

**Output.**
- A new part of Table A4 and a new Figure 1: (a) share against k by ε, with k* marked; (b) predicted lagged and Hamilton coefficients against k, with the observed values; (c) the institutional panel.
- The unscaled anchored part of Table A4 is retitled, without "main".

## Block 2: why the five-year estimate falls from −0.14 to −0.02

1. **The 44 lost country-periods.** They are the country-periods in the T3 sample but not in the common bias sample. They are listed and described against the 311:
   - first GFS reporting period of the country;
   - transition economy before 1999;
   - period in 1979–1993;
   - income, merit, debt, period growth and wage bill.
2. **Group contributions.** T3 on the 355 with the wage bill interacted with:
   - (i) a first-reporting-period indicator;
   - (ii) separately, transition before 1999.
   - Reported: the coefficient in each group, and the interaction with its wild-bootstrap p.
3. **Influence.**
   - T3 on the 355 dropping each of the 44 one at a time.
   - Dropping blocks: first reporting period; transition before 1999; periods starting in 1979–1993; all 44.
   - Share of the difference explained by block B: [β(355) − β(355 \ B)] / [β(355) − β(311)].
   - **Rule input:** the first-reporting block, or the transition block, explains ≥ 2/3 of the difference.
4. **Bias checks on the full sample.** On as many of the 355 as possible:
   - + output gap in t_p − 1;
   - + growth of p − 1;
   - negative-gap interaction (average effect).
   - When period p − 1 is missing, its growth is replaced by the mean annual growth available in the five years before t_p (the number of recovered observations is reported).
   - 2SLS stays on its instrument sample.
   - **Rule input:** |variant − T3| < 0.05 for every feasible full-sample variant, each compared with T3 on the same observations.
5. **Null-adjusted estimates on the 355 and the 311.**
   - Null designs: mean-reverting; anchored unscaled (k = 1); moment-matched calibrated (k* of Block 1 at ε = 0.48).
   - Method: as in the third addendum. The point estimate is observed minus the mean of 1,000 simulations. The CI comes from 999 country pairs-bootstrap draws, each re-estimating the observed coefficient and re-running one simulation on the resampled countries.
   - The sign of the mean-reverting null on the 311 is verified explicitly.

## Block 3: annual, dynamic, five-year and WWBI estimates on a common scale

**Object.** The effect on average annual growth of real GDP per capita over the five years t_p … t_p + 4 of a wage bill 1 point of GDP higher, maintained from t_p − 1.

**1. Annual.**
- Table 1 model with the ratio in t − 1 … t − 5 (sample with five lags).
- Implied effect: (1/5) Σ_{h=0}^{4} e_h, with e_h = Σ_{j=1}^{min(h+1, 5)} β_j + ρ e_{h−1}, where ρ is the coefficient on lagged growth and e_{−1} = 0.
- Second version: the five-year moving average of the lagged ratio as a single regressor, implied effect computed the same way.
- CI by the delta method (`nlcom`, Driscoll-Kraay) and by a 999-draw country pairs bootstrap.

**2. Local projections.**
- Shock (a) of Table A16.
- Responses of the wage bill ratio (W/Y, base t − 2) and of 100 × log GDP per capita (base t − 1), h = 0–5.
- LP-IV for the object: 100 × (log y_{t+4} − log y_{t−1}) / 5 on the mean ratio response over h = 0–4, instrumented by the shock (Driscoll-Kraay, bandwidth 4).
- If the effective F is below 10: the Anderson-Rubin 95% CI (`weakiv`, standard errors clustered by country) is reported, and the object is declared not identified with this shock.

**3. Five-year and WWBI estimates.**
- T3 (355) and T3 on the 311.
- WWBI: the wage bill in t_p − 1 in levels, in the registered H2 sample (173) and the strict sample (148), with country counts.

**4. Harmonised version.** On the intersection, defined as the country-periods of the registered H2 sample with the wage bill in t_p − 1 that are also in the T3 sample, and the annual country-years t_p … t_p + 4 of those periods:
- the annual implied effect;
- T3, which on these observations is the WWBI estimate.

**5. Compatibility tests.**
- Pairs: annual × T3, annual × WWBI, T3 × WWBI, LP × T3.
- Tests use the bootstrap distribution of each difference from the same 999 country draws.
- The annual effect is also tested against the fixed values −0.14 and −0.33, with its bootstrap SE.
- **Rule input:** p < 0.05 for either fixed value.

**6. Multiple testing in the WWBI subsample.**
- Holm adjustment over the family of wage-bill coefficients reported in Tables A9 (subsample and influence rows except leave-one-out), A10 (specification rows, excluding the preferred row and the summary rows) and A15 (size panel, level and log rows).
- p-values: bootstrap p where the table reports one, otherwise the reported p.
- Romano-Wolf is not used, because the family mixes samples and estimators that cannot be resampled jointly.
- **Rule input:** the Holm-adjusted p of −0.334.

**Output.**
- A new part of Table A9 ("Annual, dynamic and five-year estimates on a common scale").
- A forest plot, Figure A3.

## Block 4: formal tests of the five-year grid and of Mollick and Cabral

1. **Grid differences.** On the common grid sample (349), the three measures (period mean, t_p, t_p − 1) are stacked with measure-specific controls and fixed effects, for each control version. The differences mean − t_p, t_p − t_p − 1 and mean − t_p − 1 are tested by wild bootstrap.
2. **Linear trend in timing.** The contrast with weights (−1, 0, +1) on (mean, t_p, t_p − 1), that is, the slope per step of overlap.
   - **Rule input:** its bootstrap p with controls in t_p − 1.
3. **Mollick and Cabral, five-year panel.**
   - The t_p − 1 coefficient, FE with wild-bootstrap CI and System GMM with its Windmeijer CI, for 1986–2004 and 1986–2023.
   - Its difference from the period-mean coefficient, FE in a stacked model with wild bootstrap.

## Block 5: institutions, published scale and data vintage

1. **Full table of null shares.**
   - Dimensions: registered and published specification; anchored unscaled, moment-matched calibrated, and the earlier calibrated design (k = 0.30); ε_0 = 0.556 and 0.701; with and without gradient.
   - Shares are reported relative to the replicated interaction and, for the published specification, to the published one (−0.811).
   - The moment-matched k for consumption uses the distance of Block 1 on the consumption ratio in the published-specification sample: SD, AR(1), and the interactions with lagged consumption and with consumption over Hamilton trend GDP, with 200 replications per k (gradient, ε_0 = 0.556).
   - 1,000 replications at the chosen k per design.
2. **WDI vintage.**
   - The published specification is re-estimated with the WDI vintage closest to the authors' data, from the WDI Database Archives (free). If the article gives no access date, the 2022 and 2023 vintages are used.
   - **Rule input:** whether the replicated/published ratio of the interaction falls below 1.5. If the archive cannot be accessed, this is logged and the rule reads "otherwise".
3. **Trend-GDP interaction.** In the registered specification, the trend-GDP interaction (−0.121) is reported next to its null mean.
4. **Holm adjustment** over the 24 triple-interaction cells of Table A13, panel E.

## Block 6: consistency and cleaning of the exhibits

This block contains no new estimates: duplicated statistics, sample labels, stars, row grouping, counts, removal of revision marks, specific addenda in notes, traceable references to the replication package, and references. The results are reported in the "Conferência" section of the memo.

## Block 7: decision rules (verbatim from the prompt)

| Item | Se… | Então o manuscrito… |
|---|---|---|
| Fração contábil (Bloco 1) | o desenho escolhido por momentos reproduz os coeficientes da defasada e de Hamilton dentro dos intervalos simulados **e** dá fração ≥ 50% com ε = 0,48 | resumo: "at least half of the same-year coefficient can be reproduced by a zero-effect wage bill whose simulated moments match the data" |
| | reproduz os dois momentos e dá fração entre 25% e 50% | resumo: "a quarter to a half", com a faixa por desenho no texto |
| | não reproduz algum dos dois momentos em nenhum k | resumo: a faixa completa entre desenhos (do registrado ao placebo), sem número central; retira "mostly accounting" e "between a third and three-fifths" |
| Resto do coeficiente (Bloco 1, item 3) | algum ψ ≠ 0 reproduz os momentos e eleva a fração para ≥ 80% | diz que o resto é compatível com co-movimento do numerador com o ciclo real sem efeito sobre o crescimento |
| | caso contrário | "the remainder is not identified as either a growth cost or a non-causal co-movement" |
| Recomendação da defasada (Bloco 1) | sob o desenho escolhido, a nula da defasada tem IC que contém zero | mantém "prefer lagged ratios" |
| | não contém | troca por "report lagged ratios together with their simulated null" |
| −0,14 × −0,02 (Bloco 2) | o primeiro período de reporte (ou a transição) explica pelo menos dois terços da diferença | o texto diz que a estimativa quinquenal depende desses períodos e o resumo deixa de citar −0,14 sem essa ressalva |
| | caso contrário | reporta a dependência como fragilidade geral |
| Viés na amostra completa (Bloco 2) | as checagens viáveis nos 355 movem T3 menos de 0,05 | "the bias checks that can be run on the full sample move the estimate by less than 0.05" |
| | movem 0,05 ou mais | reporta o movimento e a direção no texto principal |
| Escala comum (Bloco 3) | a evidência anual é incompatível (p < 0,05) com −0,14 ou com −0,33 | diz qual e trata a diferença como questão de horizonte ou amostra |
| | é compatível com os dois | troca "the lagged ratio none" por "the lagged ratio is imprecise and compatible with the five-year estimates" |
| Subamostra WWBI (Bloco 3) | o p ajustado de −0,334 é < 0,05 | pode ficar no resumo, como exploratório, com o resultado em log |
| | ≥ 0,05 | sai do resumo e fica na seção 4.3 como heterogeneidade não significativa após ajuste |
| Grade quinquenal (Bloco 4) | o contraste de tendência no *timing* tem p < 0,05 | "the coefficient becomes significantly less negative as the wage bill moves out of the period" |
| | caso contrário | "the point estimates become less negative…, although the differences are not significant" |
| Instituições (Bloco 5) | a safra antiga do WDI reduz a razão replicado/publicado para menos de 1,5 | as frações podem ser apresentadas como frações do resultado de Mollick e Vianna |
| | caso contrário | o resumo deixa de citar frações institucionais; o texto apresenta a faixa completa como frações "of our replicated interaction" |

**Operational definitions** (as stated in the blocks above):
- **"Desenho escolhido por momentos":** k* at ε = 0.48.
- **"Nula da defasada":** the simulated distribution of the lagged coefficient at k*; "contains zero" refers to its 2.5–97.5 percentiles.
- **"Explica dois terços":** the block-removal share of Block 2, item 3.
- **"Checagens viáveis":** Block 2, item 4.
- **Bloco 3:** evidence on the full samples (annual DL effect, T3 on 355, WWBI −0.334).
- **Grade:** the linear-trend contrast with controls in t_p − 1.
- **Safra:** if no archive vintage can be obtained, the "caso contrário" row applies.
