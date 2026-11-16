# Third plan addendum: estimates requested for the final version of the Kyklos submission (pre-estimation)

Written on 16 November 2026, before any of the estimates below was run. It extends the analysis plan (commit 2182199, 17 October 2026) and the two Kyklos addenda (3faa1ea, 13 November 2026; be45e06, 16 November 2026).

**Status of the analyses.**
- Nothing here changes the registered results. The preferred specifications of H1–H5 and the verdicts (Table A17 in the final numbering) are unchanged.
- Every analysis below is exploratory and is labelled "post-plan, pre-registered in addendum 3".

**Code and outputs.**
- Code in `code/kyklos3/`, run by `code/kyklos3/master_kyklos3.do`.
- Stata 17 (`version 17`), seed 20261116 in every do-file.
- Outputs in `output/kyklos3/tables` and `output/kyklos3/figures`.
- Earlier code and outputs (`code/kyklos/`, `code/kyklos2/`, `output/kyklos/`, `output/kyklos2/`) are read, never changed.

**Numbering.** The final version numbers the exhibits as follows:
- main text: Tables 1–2 and Figures 1–4;
- appendix: Tables A1–A17 and Figures A1–A2.

New material enters existing tables as panels, rows or columns. The appendix stays within 19 tables.

## Common definitions

- **Samples and models** are those of the second addendum:
  - Table 1 annual model and sample (1,621 country-years, 87 countries);
  - preferred five-year specification ("T3": wage bill in t_p − 1, controls in t_p − 1, country and period fixed effects, 355 observations, 68 countries);
  - H2 registered sample (Table 2, column 3; 199 country-periods);
  - H2 strict sample (152).
- **Output gap:** 100 × (log real GDP − Hamilton trend).
- **Wild cluster bootstrap:** by country, Webb weights, 9,999 replications, seed 20261116. Simulations: 1,000 replications.
- **Pairs bootstrap:** country pairs bootstrap, 999 draws; 199 where stated.
- **Simulated coefficients:** Frisch–Waugh with stored projections (`code/kyklos2/sim2_mata.do`), checked against `reghdfe` in the first replication of each design.

## Block 1: H1, H2 and the size of the wage bill

**1. Regressions.**
- Specification: growth on the wage bill in t_p − 1, in level (% of GDP) and in log, with T3 controls and fixed effects, clustered errors, wild bootstrap p.
- Samples:
  - (a) the T3 sample;
  - (b) the T3 sample restricted to periods starting in 1999 or later, the first period that contains a WWBI pair;
  - (c) the H2 registered sample;
  - (d) the H2 strict sample.
- In (c) and (d), three wage-bill measures:
  - the GFS ratio in t_p − 1 (as in T3);
  - the GFS ratio in the year of the WWBI pair (as in Table 2, column 7);
  - the log of each.

**2. Conversion.** Log coefficients are converted to points of growth per point of GDP: β_log / mean of the wage bill in the sample. The CI is by the delta method, with the mean treated as fixed.

**3. Tests (pairs bootstrap, 999 draws).**
- (a) minus (c), for the same regressor (level; log converted);
- level minus log converted, within each sample.

**4. Decomposition of the difference between T3 (−0.14) and the log wage bill in the H2 sample (about −0.5).** The difference is split into a path of steps:

| Step | Change |
|---|---|
| (i) | T3, level, sample (a) |
| (ii) | log converted, sample (a): functional form |
| (iii) | log converted, sample (b): period |
| (iv) | log converted, sample (c), GFS ratio in t_p − 1: WWBI countries |
| (v) | log converted, sample (c), pair-year ratio: timing of the pair |

Each step's contribution is reported in points and in % of the total. The order of the steps is fixed here.

**Rule inputs.**
- **"Inside the T3 90% CI":** the point estimate of the log-converted coefficient in sample (a) lies in [−0.261; −0.024].
- **"Near −0.5":** the log-converted coefficient of the GFS ratio in t_p − 1 in sample (c) has a 95% CI that contains −0.5 and a point estimate at or below −0.35.
- **"Mainly from the timing of the pair":** step (v) accounts for more than 50% of the total change from (i) to (v).
- **"Cost of at least 0.3 in a main sample":** in sample (a), (b), (c) or (d), with the wage bill in t_p − 1 (GFS ratio), the level coefficient or the log-converted coefficient is ≤ −0.30 with wild-bootstrap p < 0.05. For the log-converted coefficient, the p of the log coefficient is used.

## Block 2: simulation calibrated to the observed persistence; sensitivity to ε

**1. Origin of ε = 0.48 (wage bill) and ε_0 = 0.556 (consumption).** The code is traced, and the differences from the 0.520 and 0.701 of Table A3 are explained. This is documentation, with no new estimate.

**2. Calibrated anchored design.** Same as the anchored design of the second addendum, but the drawn residuals are multiplied by k.
- k is searched on the grid 0.30, 0.35, …, 1.00, with ε = 0.48 and 200 replications per k.
- **By SD:** the k whose mean within-country SD of the synthetic ratio is closest to the observed 0.976.
- **By AR(1):** the k whose mean AR(1) is closest to the observed 0.970.
- Both calibrated designs are run on the full grid.

**3. Grid.** ε = 0, 0.25, 0.48, 0.52, 0.71, 0.75 and 1.0, with 1,000 replications per value, for both calibrated designs. The anchored and registered designs are also run at ε = 0.52 and 0.71, to complete the range.
- **Regressions per replication:** as in the second addendum (Table 1 annual measures and T3).

**4. Range of the accounting share at ε = 0.48 and 0.71** (simulated mean of the same-year coefficient over the observed −0.723), for:
- the registered design;
- the anchored design;
- the calibrated designs (by SD and by AR(1));
- the fixed-numerator placebo (its coefficient over the observed one; it does not depend on ε).

**5. Institutional interaction under the null.**
- The anchored consumption simulation of the second addendum is rerun with the calibrated design: k calibrated by SD on the consumption ratio itself, same grid and criterion, in the sample of the published specification.
- Values of ε_0: 0.556 (as before) and 0.701 (Table A3); ε_1 = −0.180.
- Each with the gradient and with ε_1 = 0.
- **Reported:** the share of the observed interaction in the published and the approximate (registered) specifications, with the 2.5–97.5 percentiles of the replication-level share, and the share of the published interaction (−0.811).

**6. Main rule input.** The share of the same-year coefficient at ε = 0.48 in the calibrated design. The SD calibration is the main one, because SD is the moment the anchored design missed most; the AR(1) calibration is reported.

## Block 3: Table 1 with predetermined annual controls

**Versions.** Table 1 (six annual measures) is re-estimated on one common sample: the Table 1 sample with all lagged controls available.
- (a) all controls in t − 1;
- (b) (a) without inflation;
- (c) (a) without investment.
- The original Table 1 controls are also reported on the same sample.

**Tests.** For each version, the stacked differences "same year − lagged" and "same year − Hamilton", with wild bootstrap.

**Rule input.** Both differences keep p < 0.01 in all three versions.

## Block 4: distributed lags; decomposition without the outcome on the right-hand side

**1. Distributed lags** (Table 1 model, its sample restricted to available lags).
- **Version A:** the ratio in t − 1, t − 2 and t − 3 jointly.
- **Version B:** the ratio in t − 1 with Δratio in t − 1 and t − 2.
- **Reported:** each coefficient, and the sum in A with a Driscoll-Kraay CI. The implied long-run effect is sum / (1 − coefficient on lagged growth), with a delta-method CI.
- **Rule input:** the 95% CI of the sum in A excludes zero.

**2. Panel D of Table A4 without Δln Y_t.** The regressors are 100 × ln s_{t−1} and 100 × Δln W_t only.

**3. Δln Y_t replaced by:**
- (i) deflator inflation in t − 1;
- (ii) deflator inflation in t, instrumented by its values in t − 1 and t − 2 (2SLS with country and year fixed effects, Driscoll-Kraay with bandwidth 4, Montiel Olea–Pflueger effective F).

Deflator inflation is 100 × Δln(nominal GDP / real GDP).

**4. Two readings of the numerator**, reported side by side without causal attribution:
- **indexation:** 100 × Δln W_t on deflator inflation in t − 1, with country and year fixed effects;
- **wage pressure:** deflator inflation in t on 100 × Δln W_{t−1}, with country and year fixed effects and the Table 1 controls.

Both use Driscoll-Kraay errors.

**Rule input (numerator).** The indexation reading is withdrawn from the main text if the coefficient on Δln W_t changes sign or has p ≥ 0.05 in any of the three versions without Δln Y_t (items 2, 3i and 3ii).

## Block 5: sensitivity range of the predetermined estimate on a common sample

**1. Common sample.** The intersection of the observations used by T3 and by the variants of the bias panel:
- + gap;
- + growth of p − 1;
- + both;
- negative-gap interaction;
- 2SLS.

**2. Differences from T3.** On the common sample, T3 and each variant are estimated, with:
- the variant's wild-bootstrap p;
- its difference from T3, with a CI from a country pairs bootstrap (999 draws, the same draws for all variants).

**3. Interaction model.** The average effect is the wage-bill coefficient plus the interaction times the sample share of negative gaps.

**4. Null-adjusted estimates.** Observed minus the mean of the simulated null, for T3 and each variant, under two designs:
- the mean-reverting design of the second addendum;
- the SD-calibrated anchored design of Block 2.

In the simulations, the instruments of the 2SLS variant are the synthetic ratios in t_p − 2 and t_p − 3.

- **Point estimate:** observed minus the mean of 1,000 simulations.
- **CI:** 2.5–97.5 percentiles over 999 pairs-bootstrap draws. Each draw resamples countries, re-estimates the observed coefficient and runs one new simulation of the null on the resampled countries; the CI therefore combines sampling and simulation error. If the run is too long, 199 draws are used and logged.

**5. Leave one period out.** T3 is estimated dropping each period in turn; reported is the number of periods whose omission leaves p < 0.05.

**Rule inputs.**
- **"Within 0.05 of T3":** |variant − T3| < 0.05 for every variant (the interaction model by its average effect), and no variant has a wild-bootstrap p < 0.05.
- **Null-adjusted T3:** the CI of "T3 minus the mean-reverting null" includes zero.

## Block 6: institutions, registered specification, GMM and uncertainty

**1. Shares of the institutional interaction under the null** (from Block 2, item 5), with percentile CIs, in both specifications and for both values of ε_0. They are also reported against the published interaction (−0.811).

**2. Count of significant triple-interaction cells.** In panel E of Table A13: how many of the 24 cells have p < 0.05, by estimator (FE or System GMM) and by period split.

**3. Possible copy error.** It is checked whether the rows "ICRG/QoG, 1996–2020" and "ICRG/QoG, common sample" of Table A13 are identical by a copy error. The common sample is re-estimated by recounting the observations with WGI available.

**Rule input.** The share in the registered (approximate) specification under the SD-calibrated design, with gradient and ε_0 = 0.556. If it is below 33%, the summary cites the range of both specifications and marks the published specification as exploratory.

## Block 7: GDP measurement error as a third mechanical channel

**1. Different source for the dependent variable.** Table 1 is re-estimated with growth of real GDP per capita from the Penn World Table 11.0 (100 × Δln(rgdpna / pop)), keeping the ratio built with the IMF GDP.

**2. Different source for the denominator.** Table 1 is re-estimated with WDI growth and the ratio built with WEO nominal GDP:
- ratio = 100 × general government compensation of employees in national currency (IMF GFS, G21, S13) / nominal GDP (IMF WEO, NGDP);
- both series are freely downloaded and documented in `data/raw/`.

**3. Reporting.** Each version is estimated on its own common sample, and the original Table 1 is also estimated on that sample. Reported are the same-year coefficient and its differences from the lagged and the Hamilton measures (stacked, wild bootstrap).

**Rule input.** |change of the same-year coefficient| / |same-year coefficient on the same sample| < 20% in both versions.

## Block 8: consistency checks

These are recounts and documentation, with no new estimates:
- Mollick and Cabral countries (54 versus 51);
- Mollick and Vianna country counts;
- the replicated/published ratio;
- H2 strict counts and p-values;
- the premium in both samples;
- the electoral-calendar F;
- the sign of θ/5;
- the exclusion of negative-growth years;
- federations;
- robustness rows significant at 5%;
- removal of internal labels from visible table text;
- references.

Corrected tables are regenerated into `output/kyklos3/final/`, with the final numbering, by text substitution in copies. Estimates do not change.

## Block 9: decision rules (verbatim from the prompt, operationalised above)

| Item | Se… | Então o manuscrito… |
|---|---|---|
| H1 × H2 (Bloco 1) | na amostra de T3, a folha em log, convertida por ponto do PIB, fica dentro do IC de 90% de T3, **e** na amostra WWBI a folha GFS em t_p − 1 fica perto do −0,5 | atribui a diferença à amostra (2000 em diante, países WWBI) e diz isso no resumo e na conclusão |
| | a diferença vem principalmente do *timing* do par do WWBI | diz que o resultado de tamanho em H2 depende de pares medidos perto do período |
| | a folha em t_p − 1 tem custo de pelo menos 0,3 ponto por ponto do PIB, com p de bootstrap < 0,05, em alguma amostra principal | retira "averaging does not conceal a cost" e reporta o custo nessa amostra |
| Fração contábil (Bloco 2) | o desenho calibrado dá fração entre 25% e 50% com ε = 0,48 | resumo: "between a quarter and a half, depending on the design" |
| | dá mais de 50% | resumo: "at least half of the same-year coefficient is accounting"; título passa a "Accounting, Not Averaging Out?" só se também valer para ε = 0,71 |
| | dá menos de 25% | resumo: "a minority of the same-year coefficient" e a faixa por desenho |
| Controles predeterminados (Bloco 3) | as diferenças mesmo ano − defasada mantêm p < 0,01 nas três versões | cita a verificação no texto principal |
| | caso contrário | reporta a mudança no texto principal e revê a frase sobre o painel anual |
| Defasagens (Bloco 4) | a soma das defasagens tem IC que exclui zero | troca "lagged one year, no association" por uma frase com a soma e o IC |
| | caso contrário | "the lagged wage bill has no significant association, with a CI of ±[x]" e concilia com as projeções locais |
| Numerador (Bloco 4) | o coeficiente de Δln W_t muda de sinal ou perde significância sem Δln Y_t no lado direito | retira a leitura de indexação do texto principal |
| | não muda | mantém como co-movimento de direção indeterminada, citando os dois testes do item 4 |
| Viés (Bloco 5) | na amostra comum, todas as variantes ficam a menos de 0,05 de T3 e nenhuma tem p de bootstrap < 0,05 | "a sensitivity range of [a; b] on a common sample" no lugar do "bound" |
| | alguma variante se afasta mais de 0,05 de T3 | reporta a variante e a direção no resumo |
| | T3 menos a nula com reversão à média tem IC que inclui zero | diz que a estimativa quinquenal não se distingue do que a contabilidade sozinha produz |
| Instituições (Bloco 6) | a fração na especificação registrada fica abaixo de 33% | o resumo cita a faixa das duas especificações e marca a publicada como exploratória |
| | caso contrário | mantém "about half", com o IC |
| Erro de medida (Bloco 7) | o coeficiente do mesmo ano muda menos de 20% com fontes diferentes | cita a verificação e diz que erro de medida comum não explica o coeficiente |
| | muda 20% ou mais | trata o erro de medida como terceiro canal no texto principal |

**Operational definitions** (as stated in each block above). Every row of the table is checked independently; within a block, rows that do not exclude each other can hold together. When no row of an item holds, the current text stays and the numbers are reported.

**Additional definitions.**
- **Bloco 2.** The share is the calibrated-by-SD share at ε = 0.48. The bands are [0.25, 0.50], > 0.50 and < 0.25. The title change also requires a share above 0.50 at ε = 0.71.
- **Bloco 3.** "Mantêm p < 0,01" applies to the "same year − lagged" difference, as in the rule; the "same year − Hamilton" difference is reported.
- **Bloco 6.** "Fração na especificação registrada" is defined in Block 6.
