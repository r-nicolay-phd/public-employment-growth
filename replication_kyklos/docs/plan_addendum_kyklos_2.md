# Second plan addendum: final estimates for the Kyklos submission (pre-estimation)

Written on 16 November 2026, before any of the estimates below was run. It extends the analysis plan and the first Kyklos addendum (`docs/plan_addendum_kyklos.md`, commit 3faa1ea).

**Status of the analyses.** Nothing here changes the registered results:
- the preferred specifications of H1–H5 are unchanged;
- the verdicts of Table A19 (formerly Table S13) are unchanged.

Every analysis below is exploratory. It is labelled "post-plan, pre-registered in addendum 2" in the tables and in `docs/deviations_from_plan.md`.

**Code and outputs**
- Code: `code/kyklos2/`, run by `code/kyklos2/master_kyklos2.do`.
- Settings: Stata 17 (`version 17`), seed 20261115 in every do-file.
- Outputs: `output/kyklos2/tables` (.docx, .tex, .csv) and `output/kyklos2/figures` (PNG 4,488 px wide, PDF, EPS, greyscale).

**Numbering**
- Exhibits use the version-4 numbering: main Tables 1–3, appendix Tables A1–A19, main Figures 1–4, appendix Figures A1–A6.
- New material enters existing exhibits as panels, rows or columns. The appendix stays at 19 tables, within the limit of 22.

## Common definitions

- **Panels and samples.** The annual and five-year panels are those of `data/interim/revisao` (microstates excluded).
- **Annual Table 1 model.**
  - Growth of real GDP per capita (%) on the wage-bill measure.
  - Controls: lagged growth, lagged log GDP per capita, human capital, investment, openness, inflation, population growth and growth of commodity terms of trade.
  - Country and year fixed effects, 1996–2023, in the common sample of Table 1 (N = 1,621, 87 countries).
  - Standard errors: Driscoll-Kraay (maximum lag 3).
- **T3.**
  - Five-year averages; wage bill in t_p − 1; controls in t_p − 1 (log GDP per capita, human capital, investment, openness, inflation, population growth, terms-of-trade growth).
  - Country and period fixed effects; standard errors clustered by country.
  - Sample of the registered estimate (N = 355, 68 countries).
- **Output gap in t_p − 1 (or t − 1).** gap = 100 × (log real GDP − Hamilton trend), Hamilton filter with H = 2 and k = 2. The variable in the panels is `lgap_ham`, which is trend minus actual, so gap = −100 × `lgap_ham`.
- **Growth of period p − 1.** The lagged five-year average growth rate (`L.g` in the five-year panel).
- **Wild cluster bootstrap.** By country, Webb weights, 9,999 replications (`boottest`), seed 20261115.
  - For 2SLS: the WRE bootstrap of `boottest` after `ivregress` with country dummies.
  - Tables report the coefficient with its 95% CI and bootstrap p from the same procedure. Where the bootstrap CI cannot be computed, the cluster CI is shown and labelled as such.
- **Simulations.** 1,000 replications per design point. In each replication, coefficients are point estimates of the same regressions as the observed ones (`reghdfe`; the point estimates are identical to `xtscc`).
- **Time limit.** If a block runs more than three hours, bootstrap replications fall to 999 and the change is logged.

## Block 1: null simulation and reconciliation with the placebo

**Data.** Annual panel 1970–2023 (`sim_base.dta`).
- s = wage bill / GDP (fraction).
- Δln Y = growth of nominal GDP in local currency.
- Synthetic series are computed for every country-year with the needed inputs; regressions use the observed samples (Table 1 sample for the annual rows, the T3 sample for T3).

**1. Anchored (main).**
- ln s^sim_it = ln s^obs_i,t−1 − (1 − ε) Δln Y_it + u_it.
- u_it is drawn with replacement, independently across country-years, from the country's own values of e_it = Δln s^obs_it + (1 − ε) Δln Y_it, after subtracting the country mean of e_it.
- ε ∈ {0, 0.25, 0.48, 0.75, 1.0}; 1,000 replications per ε.

**2. Stationary.**
- ln s^sim_it = μ_i + ρ (ln s^sim_i,t−1 − μ_i) − (1 − ε) Δln Y_it + u_it, with ε = 0.48.
- ρ: coefficient of a within-country (country fixed effects) regression of ln s^obs_it on ln s^obs_i,t−1, all available years. The value is recorded.
- μ_i: country mean of ln s^obs over the same observations.
- The recursion starts at the observed value in the country's first year and restarts at the observed value after a missing input.
- u: drawn from the country's e_it = ln s^obs_it − μ_i − ρ (ln s^obs_i,t−1 − μ_i) + (1 − ε) Δln Y_it, recentred within country.

**3. Registered.** The design of the old Table A5 (random walk in ln W from the first observed year, u drawn from Δln W − ε Δln Y, not recentred), rerun on the same ε grid.

**4. Regressions per replication.**
- Annual Table 1: same-year ratio; ratio over Hamilton trend GDP (s^sim × exp(ln Y − ln Y^Ham)); ratio over one-sided HP trend GDP; ratio lagged one year.
- T3: synthetic ratio in t_p − 1.

**5. Statistics.**
- By variant, ε and measure: mean, 2.5 and 97.5 percentiles, and share of observed = mean / observed coefficient.
- **Slope of the simulated mean on (1 − ε):** the OLS slope through the five means. Its 95% interval is the 2.5–97.5 percentiles of the slope computed replication by replication (replication r at each ε).
- **Sanity test** (anchored variant, same-year annual coefficient). It passes only if both hold:
  - (i) the slope is negative and its 95% interval excludes zero;
  - (ii) at ε = 1 the simulated mean is near zero: |mean| ≤ 0.10 × |observed coefficient| **and** the 2.5–97.5 interval contains zero.
- **Share for the rule:** the anchored same-year annual share at ε = 0.48.
- **Within-country SD and AR(1)** of the synthetic ratio (% of GDP), averaged over replications at ε = 0.48, for each variant, beside the observed ones. Both are computed in the Table 1 sample; AR(1) is the pooled OLS coefficient on the lag, as in the old table.

**6. Direct decomposition** (annual Table 1 model, Driscoll-Kraay).
- The same-year ratio is replaced by 100 × ln s_t−1, 100 × Δln W_t and 100 × Δln Y_t (nominal), estimated jointly.
- Covariance and correlation of the numerator innovation (Δln W − 0.48 Δln Y) with real per-capita growth, both net of country and year fixed effects, in the Table 1 sample.
- Regression of 100 × Δln W on current real growth and two lags, country and year fixed effects, Driscoll-Kraay. A second column adds nominal GDP growth.

**7. Placebo reconciliation.**
- Correlation of the placebo ratio with the observed ratio in the Table 1 sample.
- Correlation of the placebo ratio with each synthetic ratio (ε = 0.48), averaged over replications.

**8. Output.**
- New Table A5 with panels: anchored, stationary, registered, direct decomposition.
- New Figure A3:
  - simulated mean against (1 − ε) by variant, with 95% bands;
  - a dashed horizontal line at the observed coefficient;
  - a dotted ray from the origin through the observed coefficient at 1 − ε = 0.52 (the "full accounting" benchmark, the 45° line of the prompt).
- The old Table A5 and Figure A3 stay in the replication package.

## Block 2: sign and bound of the bias in the predetermined estimate

Sample: T3 (N = 355). Variants that need a lagged period lose observations. Each is reported with its N and with T3 re-estimated on the same observations.

1. T3 + gap in t_p − 1.
2. T3 + growth of p − 1 (LSDV). Separately, T3 + growth of p − 1 + gap in t_p − 1.
3. T3 + indicator (gap in t_p − 1 < 0) + its interaction with the wage bill in t_p − 1. Both the wage-bill coefficient and the interaction are reported.
4. **2SLS with country and period fixed effects.**
   - The ratio in t_p − 1 is instrumented by the annual ratios in t_p − 2 and t_p − 3, with T3 controls.
   - Reported: effective F of Montiel Olea and Pflueger (`weakivtest`), Hansen J, Anderson-Rubin 95% CI (`weakiv`) and WRE bootstrap p.
5. **Gelbach (2016) decomposition** (`b1x2`, clustered by country) of the change in β between T3 and T3 + growth of p − 1 + gap, on their common sample.
6. **γ × δ.**
   - γ: g_p on g_p−1. δ: ratio in t_p − 1 on g_p−1. Both with country and period fixed effects and no other controls.
   - The product γ × δ is reported as asked, with a 95% CI from a country-pairs cluster bootstrap (999 draws, both regressions in each draw).
   - Because γ × δ is not in units of β, the dimensionally consistent omitted-variable bias is also reported: γ_long × π. Here γ_long is the coefficient on g_p−1 in T3 + g_p−1, and π is the coefficient of g_p−1 on the wage bill and T3 controls. It is compared with the observed difference β(T3) − β(item 2).
   - The rule reads the **sign** from the CI of the literal product γ × δ (same sign as γ × π) and the **magnitude** from γ_long × π.
7. **Annual.** Table 1 model with W_t−1 / Y*_t−1 (Hamilton), with and without the gap in t − 1. Driscoll-Kraay CI, plus wild cluster bootstrap p by country from the same model estimated with clustered errors.
8. **Output.** New panel in Table A11, "Bias checks for the predetermined estimate", and an English sentence on the sign of the net bias.

**Variant sets for the rule**
- "All variants": the wage-bill coefficient of items 1, 2 (both), 3 (main coefficient) and 4.
- "Main variants": items 1, 2 (both) and 4.
- If neither of the first two rows of the rule holds, the current text stays and the range is reported.

## Block 3: formal tests in the institutional replications

**1. Oto-Peralías and Romero-Ávila.**
- Panel: five-year averages aligned to 1981 (1981–85 … 2016–20), with the ICRG/QoG index.
- Overlap: the two windows overlap in 1996–2005. Each period enters once. Late = 1 for 2006–2020 (main, matching the text's "after 2005"). Robustness: overlap assigned to the later window (Late = 1 for 1996–2020).
- Model: growth on G, G × I, G × Late, G × I × Late, I, I × Late, initial log income, enrolment, investment, period effects and country fixed effects.
- Measures G: period mean, t_p, t_p − 1.
- Estimators:
  - FE with clustered errors and wild bootstrap of the triple interaction;
  - System GMM in the specification of Table A14, panel A, with the new interactions instrumented like G × I.
- Repeated on the countries with at least one observation in each window.
- **Rule input:** the bootstrap p of the triple interaction, FE, period-mean measure, main split.

**2–3. Mollick and Vianna, published specification (Table A14, panel D).**
- Indicators: GE, CC, RL, each on its common sample.
- For the lagged and the trend-GDP interaction: 95% CIs with White and with country-clustered errors.
- **Published interactions** (their Table 2, full period): GE −0.811 (0.169), CC −0.814 (0.156), RL −0.835 (0.153).
- Test: does the 95% CI exclude the published interaction?
- **Equivalence (TOST with the 90% CI),** at Δ = 0.5 and 1.0:
  - (a) to the published value, |b − b_pub| < Δ;
  - (b) to zero, |b| < Δ.
- **Rule input:** clustered 95% CI of the lagged interaction, GE (the more conservative error). It must exclude the published value with b above it (closer to zero).

**Output.** New panel in Table A15 and new rows in Table A16.

## Block 4: institutional interaction under the null

**Elasticity.**
- ε_it = ε_0 + ε_1 × WGI_i,t−1, where WGI is the mean of the six indicators centred as in the mechanism of Table A15.
- ε_0 (coefficient on nominal GDP growth) and ε_1 (interaction) come from the Table A15 regression of consumption growth on nominal GDP growth × institutions (country and year fixed effects, 1996–2023). They are re-estimated in the code and logged.
- WGI gaps (1997, 1999, 2001 and other interior years) are linearly interpolated within country. The 1995 value takes the 1996 value.

**Simulation.**
- Anchored as in Block 1 for government consumption / GDP:
  - Table A14, panel D: WDI series of Mollick and Vianna, log;
  - panel C: project series, % of GDP.
- ln c^sim_it = ln c^obs_i,t−1 − (1 − ε_it) Δln Y_it + u_it, with u from the country's recentred values of Δln c^obs + (1 − ε_it) Δln Y.
- 1,000 replications with the gradient, and 1,000 with ε_1 = 0 (control).

**Regressions per replication.**
- Panel D: published specification (GE, common sample) with synthetic consumption same year, lagged, and over Hamilton trend GDP.
- Panel C: approximate specification with the same three measures.

**Statistics.** Mean, 2.5–97.5 percentiles, share of observed, and whether the observed value is inside the interval.

**Rule input:** panel D, same-year interaction.
- **Control near zero:** |mean_control| ≤ 0.10 × |observed| and its 2.5–97.5 interval contains zero.
- **First row:** share = mean_gradient / observed ≥ 0.50 and the control near zero.
- **Second and third rows:** read from the share net of the control, (mean_gradient − mean_control) / observed.

**Output.** New panel in Table A15 and panel (c) of Figure A3.

## Block 5: fiscal year different from the calendar year

**1. List.**
- Source: IMF World Economic Outlook database (SDMX API, dataflow IMF.RES/WEO, attribute START_END_MONTHS_OF_REPORTING_YEAR of general government expenditure, GGX_NGDP).
- A country is non-calendar if the reporting year does not start in January. Countries absent from WEO are "não verificado".
- Whether the GFS wage bill is converted to the calendar year is not in the GFS metadata, so it is recorded as "não verificado" for every country.
- File: `data/raw/fiscal_year/fiscal_year_by_country.csv`, with `_SOURCE.txt`.

**2. Exclusion.** Table 1 (six annual measures and four five-year measures) and T3 re-estimated without non-calendar countries.

**3. Realignment** (start months April–September).
- Label convention, not verifiable in the sources: fiscal year labelled by the calendar year that contains most of its months. Starts in April–June are labelled by the starting year; starts in July–September by the ending year.
- With start month m, the calendar-year ratio is:
  - for labels by the starting year: ((m − 1)/12) FY_t−1 + ((13 − m)/12) FY_t;
  - for labels by the ending year: ((m − 1)/12) FY_t + ((13 − m)/12) FY_t+1.
- Measures over trend GDP and the five-year measures are recomputed from the realigned ratio.

**4. Test.**
- Full and restricted samples are stacked (sample × measure fixed effects). The difference of each coefficient is tested by wild cluster bootstrap by country.
- **Rule input:** in the restricted sample, the stacked differences "same year − Hamilton" and "same year − lagged" (Table 1 definition) keep the negative sign with bootstrap p < 0.01.

**5. Output.** Rows in Table A6.

## Block 6: H2 with reverse-denominator controls

**Samples.**
- Registered sample of Table 3, column 3 (log employment and log relative wage, N harmonised).
- Strict sample of Table A17 (pairs in t_p − 1 to t_p − 4).

**Models.**
1. Log model + growth of p − 1.
2. Log model + gap in t_p − 1.
3. Relative wage over real GDP per worker of the year before the pair: log relative wage + Δln(real GDP / total employment) between the year before the pair and the pair year.
4. Relative wage with log wage bill held fixed, plus the controls of 1 and 2.

**Inference and robustness.**
- Bootstrap p for all models.
- Romano-Wolf p of the registered family, with H2 replaced by models 1 and 2 (same 999 country draws). Robustness only.

**Rule input.** Bootstrap p of the log relative wage in models 1, 2 and 3, registered sample. All three must be < 0.05.

**Output.** Columns in Table A17.

## Block 7: cumulative local-projection effect in a common metric

**Shock (a)** of Table A18: dated t − 1, LP controls (two lags of the shock and of growth), country and year fixed effects, 1996–2023, Driscoll-Kraay.

**Wage-bill response.**
- (a): dw_h = W/Y_t+h − W/Y_t−2, h = 0–6 (base before the shock dated t − 1).
- (b) and (c): base t − 1.

**Integral multiplier.**
- For each h: Σ_j≤h dy_j on Σ_j≤h dw_j, instrumented by the shock (`ivreghdfe`, Driscoll-Kraay with bandwidth 4).
- Effective F: Kleibergen-Paap robust F (one instrument).

**Translation.**
- θ = coefficient of dy_5 on the mean of dw_0 … dw_5, instrumented by the shock. This is the level effect at h = 5 per point of GDP of wage bill maintained.
- θ / 5 is the average effect on annual growth (as specified), with a delta-method CI (linear: CI / 5).
- θ / 6 (six growth years from t − 1 to t + 5) is reported as a note.
- Compared with T3 β (−0.142) and the T3 90% CI.

**Shocks (b) and (c).** Same procedure. For (b), the generated-regressor inference is a country block bootstrap that redoes the purge (999).

**Rule input.** Shock (a): is θ / 5 inside the T3 90% CI?

## Block 8: reconciliation of counts and numbers

These are counts and arithmetic, not estimation. Results go to the "Conferência" section of the memo.

## Block 9: decision rules (verbatim from the prompt, operationalised above)

| Item | Se… | Então o manuscrito… |
|---|---|---|
| Simulação e título (Bloco 1) | a variante ancorada passa no teste de sanidade (média simulada cresce com 1 − ε e fica perto de zero em ε = 1) **e** reproduz pelo menos 50% do coeficiente do mesmo ano com ε = 0,48 | volta a dizer que o denominador explica a maior parte do coeficiente; título passa a "Accounting, Not Averaging Out: Public Wage Bills and Economic Growth" |
| | passa no teste de sanidade e reproduz entre 20% e 50% | "the denominator accounts for a substantial part"; mantém o título com pergunta |
| | passa no teste de sanidade e reproduz menos de 20% | mantém a tese de *timing* e diz que a parte contábil é pequena |
| | não passa no teste de sanidade | mantém o texto atual ("the decomposition remains open") e explica por que a simulação não é informativa |
| Viés de β (Bloco 2) | todas as variantes ficam entre −0,08 e −0,20 e nenhuma tem p de bootstrap < 0,05 | "the null result does not depend on the sign of the remaining bias" |
| | alguma variante principal (itens 1, 2 ou 4) fica abaixo de −0,20 com p de bootstrap < 0,05 | reporta "a moderate cost cannot be excluded once [canal] is controlled" e revê a frase de política |
| | o sinal do viés líquido sai do item 6 com IC que exclui zero | diz o sinal no texto principal |
| Oto-Peralías e Romero-Ávila (Bloco 3) | a tripla interação tem p < 0,05 | "the mitigation is specific to 1981–2005" |
| | caso contrário | "the mitigation does not differ significantly between periods; it is estimated imprecisely after 2005" |
| Mollick e Vianna (Bloco 3) | o IC da interação defasada exclui a interação publicada | "the lagged interaction is significantly smaller than the published one" |
| | caso contrário | "the lagged interaction is imprecise and cannot be distinguished from the published one" |
| Interação institucional (Bloco 4) | a simulação com gradiente reproduz pelo menos 50% da interação observada e a de controle (ε_1 = 0) fica perto de zero | "timing explains the annual amplification" |
| | entre 20% e 50% | "timing explains part of the annual amplification" |
| | menos de 20% | "the elasticity gradient is too small to explain the amplification; timing remains a candidate explanation" |
| Ano fiscal (Bloco 5) | as diferenças do mesmo ano para as medidas predeterminadas mantêm sinal e p < 0,01 sem os países de ano fiscal não civil | retira a limitação do ano fiscal da conclusão e cita a verificação |
| | caso contrário | reporta a mudança no texto principal |
| H2 (Bloco 6) | o coeficiente do salário relativo mantém p de bootstrap < 0,05 com os controles | "survives the reverse-denominator check" |
| | caso contrário | rebaixa H2 a "sensitive to the reverse denominator channel" |
| Projeções locais (Bloco 7) | o efeito médio sobre o crescimento em cinco anos cai dentro do IC de 90% de T3 | "the dynamic and five-year estimates agree" |
| | caso contrário | reporta a discrepância e discute a diferença de horizonte |

**Operational definitions of the rules**

- **Block 1.**
  - "Cresce com 1 − ε": the slope of the simulated mean on (1 − ε) is negative (larger in absolute value) with its 95% interval excluding zero.
  - "Perto de zero em ε = 1": |mean| ≤ 0.10 × |observed| and the 2.5–97.5 interval contains zero.
  - "Reproduz": the anchored same-year share at ε = 0.48.
- **Block 2.**
  - Variant sets as defined in Block 2.
  - "Abaixo de −0,20" refers to the point estimate. "[canal]" is the control of the variant (output gap, past growth, or instrumenting).
  - The three rows are checked independently; the third can hold together with the first or the second.
- **Block 3 (Oto-Peralías and Romero-Ávila):** FE bootstrap p, period-mean measure, main split. The other cells are reported.
- **Block 3 (Mollick and Vianna):** GE, clustered 95% CI of the lagged interaction.
- **Block 4:** panel D, same-year interaction; shares and "near zero" as defined in Block 4.
- **Block 5:** restricted-sample differences, sign negative and bootstrap p < 0.01, for both differences.
- **Block 6:** models 1–3 in the registered sample, all with bootstrap p < 0.05.
- **Block 7:** the point estimate of θ / 5 for shock (a) inside the T3 90% CI.
