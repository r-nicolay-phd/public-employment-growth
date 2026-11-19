# Alterações nas exibições: versão 5 (reestimações do parecer, Kyklos)

**Origem.**
- `code/kyklos4/master_kyklos4.do` gera as partes novas. As tabelas vão para `output/kyklos4/tables/` e as figuras para `output/kyklos4/figures/`.
- `code/kyklos4/final_v5.py` monta as exibições completas em `output/kyklos4/final/` (`.docx` e `.tex` para as tabelas; PNG de 4.488 px de largura, PDF e EPS em tons de cinza para as figuras).
  - Parte das mesmas bases de `code/kyklos3/numeracao_final.py` (`output/kyklos`, `kyklos2`, `kyklos3`, sem alterá-las) e acrescenta as partes do quarto adendo.
- Plano: quarto adendo, `docs/plan_addendum_kyklos_4.md`, commit `fb6c84b`.

## Contagem

| | Versão 5 | Limite |
|---|---|---|
| Tabelas do texto principal | 2 (Tabelas 1 e 2) | 2 |
| Figuras do texto principal | 4 (Figuras 1–4) | 4 |
| Tabelas do apêndice | 17 (A1–A17) | 18 |
| Figuras do apêndice | 3 (A1–A3) | 3 |

Nenhuma tabela nova foi criada: o material novo entra como partes ("continued") de tabelas existentes. A única figura nova é a A3.

## Mapeamento completo

| Versão 5 | Arquivo final (`output/kyklos4/final/`) | Partes herdadas (rodadas anteriores) | Parte nova desta rodada (`output/kyklos4/tables/`) |
|---|---|---|---|
| Tabela 1 | `tables/Table_1_measures` | `kyklos/Table_1_measures` | — (IC da diferença mesmo ano − defasada = valor registrado) |
| Tabela 2 | `tables/Table_2_employment_relative_pay` | `kyklos/Table_3_decomposition` | — (rótulo da linha de 1 DP corrigido) |
| A1 | `tables/Table_A1_data_sources_cleaning` | `Table_S1` | — |
| A2 | `tables/Table_A2_descriptives` | `Table_S2` (painel B retirado) + `kyklos2/Table_A2_panel_B_harmonized` | — |
| A3 | `tables/Table_A3_spending_items` | `TabS20_spending_items` | — (IC da diferença = valor registrado) |
| A4 | `tables/Table_A4_simulation` | `kyklos2/Table_A5_simulation` (painéis A–D; painel A retitulado, sem "main") + `kyklos3/Table_A4_panel_calibrated` (E–G) + `kyklos3/Table_A4_panel_lags_numerator` (H–J) | `Table_A4_part_moment_matched`, painéis K–M: "Moment-matched calibration" |
| A5 | `tables/Table_A5_annual_checks` | `TabS28_checks` + `kyklos3/Table_A5_rows_controls_sources` + `kyklos2/Table_A6_new_rows` | — (IC da diferença = valor registrado) |
| A6 | `tables/Table_A6_mollick_cabral` | `TabS19_mollick_cabral` | `Table_A6_rows_five_year_tests`: coeficiente quinquenal em t_p − 1 e diferença para a média do período (FE e GMM; 1986–2004 e 1986–2023) |
| A7 | `tables/Table_A7_five_year_grid` | `TabS21_five_year_grid` | `Table_A7_rows_grid_tests`: diferenças testadas e contraste de tendência |
| A8 | `tables/Table_A8_preferred_bias_checks` | `Table_A2_baseline_composition` + `kyklos3/Table_A8_panel_bias_common` | `Table_A8_part_drivers`: "Which country-periods drive the five-year estimate" |
| A9 | `tables/Table_A9_equivalence_influence` | `TabS25_equivalence` | `Table_A9_part_common_scale`: "Annual, dynamic and five-year estimates on a common scale", com testes de compatibilidade e Holm |
| A10 | `tables/Table_A10_robustness_map` | `Table_A5_robustness_map` | — (linhas agrupadas: preferida / alternativas / resumos; contagem e explicação dos unitários na nota) |
| A11 | `tables/Table_A11_general_central` | `Tab2new_coverage` | — (nota sobre os dois p = 0,066) |
| A12 | `tables/Table_A12_institutions_replications` | `Table_A3_institutions_replications` | `Table_A12_rows_trend_null`: interação sobre o PIB tendencial contra a nula |
| A13 | `tables/Table_A13_institutions_tests` | `TabS26` + `kyklos2/Table_A15_new_panels` + `kyklos3/Table_A13_rows_calibrated` | `Table_A13_part_null_shares`: quadro completo das frações e Holm nas 24 células |
| A14 | `tables/Table_A14_mollick_vianna_published` | `Table_S17` + `kyklos2/Table_A16_new_rows` | `Table_A14_rows_vintage`: safras 2022-12 e 2023-12 do WDI |
| A15 | `tables/Table_A15_h2_strict` | `TabS22_h2_strict` + `kyklos2/Table_A17_new_columns` + `kyklos3/Table_A15_panel_size` | — (p de T3 = 0,120; p do −1,858 = 0,063 nas duas partes; nota da coluna e) |
| A16 | `tables/Table_A16_local_projections` | `TabS23_lp_predetermined` + `kyklos2/Table_A18_new_panel` | — (nota: p de h = 2 e *lead* do *jackknife*) |
| A17 | `tables/Table_A17_hypothesis_verdicts` | `Table_S13_hypothesis_tests` | — (nota: F do calendário eleitoral) |
| Figura 1 | `figures/Figure_1_simulation` | — | **Refeita**, três painéis (`07_tabelas_k4.do`) |
| Figura 2 | `figures/Figure_2_five_year_grid` | `kyklos/Fig1new_timing_grid` | — |
| Figura 3 | `figures/Figure_3_institutions` | `kyklos/Figure_2_institutions` | — |
| Figura 4 | `figures/Figure_4_lp_dated_shock` | `kyklos/Fig3new_lp_shock_a` | — |
| Figura A1 | `figures/Figure_A1_coverage` | `kyklos/Figure_S1_coverage` | — |
| Figura A2 | `figures/Figure_A2_influence` | — | Regenerada sem nota embutida (mesmos números) |
| Figura A3 | `figures/Figure_A3_common_scale` | — | **Nova** (*forest plot* da escala comum) |

**Tabelas fora da versão 5.** Ficam no pacote de replicação (tempo, decomposição e placebo, economia política, S4–S12, S14–S16, S18, S24, S27). As remissões a elas apontam para `replication_kyklos/README.md`:
- "the replication package (README, list of tables and programs, row N)";
- ou "(README, additional estimates, row N)".

## Títulos das partes novas

- **A4 (continued):** Moment-matched calibration: at the central elasticity (ε = 0.48) no value of k reproduces both the lagged and the Hamilton coefficients, so the moments do not pin down the accounting share.
- **A6 (continued):** Mollick and Cabral: the predetermined five-year coefficient is negative and smaller in absolute value than the period-mean one.
- **A7 (continued):** The coefficient becomes significantly less negative as the wage bill moves out of the period.
- **A8 (continued):** The five-year estimate depends on the first reporting period of each country: dropping those periods explains 105% of the fall from −0.14 to −0.02.
- **A9 (continued):** On a common scale the annual evidence is imprecise and compatible with the five-year estimates.
- **A12 (continued):** The trend-GDP interaction in the registered specification remains negative and is not reproduced by a zero-effect consumption series.
- **A13 (continued):** Across designs, a zero-effect consumption series reproduces 5–39% of the replicated interaction in the registered specification and 36–73% in the published one.
- **A14 (continued):** Older WDI vintages do not close the gap with the published interaction.

As notas completas estão nos `.docx`/`.tex` e em `output/kyklos4/logs/captions/`. Todas terminam com "Exploratory (post-plan, pre-registered in the fourth addendum)".

## Notas das figuras (texto, para a legenda no manuscrito)

As figuras não têm notas embutidas.

**Figure 1. A zero-effect wage bill and the same-year coefficient.** Notes:
- **Panel (a).** Simulated mean of the same-year coefficient as a share of the observed one (−0.723), against the scale k of the drawn residuals, for four elasticities ε of the wage bill to nominal GDP. Anchored design: the synthetic ratio starts each year from the observed ratio of the previous year and moves with nominal GDP with elasticity ε, plus k times a residual drawn from the country's own values. The squares mark the k chosen by the moment distance of Table A4, panel K.
- **Panel (b).** Simulated mean and 2.5–97.5 percentiles of the coefficients of the lagged ratio and of the ratio over Hamilton trend GDP, at ε = 0.48. Horizontal lines: observed values (−0.001 and −0.016).
- **Panel (c).** Densities of the simulated same-year consumption × institutions interaction in the published specification of Mollick and Vianna (2024). Moment-matched and anchored designs, with and without an institutional gradient in the elasticity. Vertical lines: replicated interaction (dashed) and published interaction (−0.811, dotted).
- **Replications.** 1,000 per point; regressions as in Table 1 (panels a–b) and Table A13 (panel c).

**Figure 2. The wage bill coefficient by timing of the wage bill.** Notes:
- **Specification.** Five-year averages 1979–2023, no microstates. Coefficient on the general government wage bill (% of GDP) measured as the period mean, in the first year of the period (t_p), in the last year of the previous period (t_p − 1), and in t_p − 1 as a share of trend GDP. Country and period fixed effects.
- **Controls.** Period-mean controls (circles) or controls in t_p − 1 (diamonds).
- **Sample.** The common sample of the grid.
- **Inference.** 95% CIs from the wild cluster bootstrap by country (Webb weights, 9,999 replications).
- **Formal tests.** Differences and the linear timing contrast are in Table A7.

**Figure 3. Replications of the institutions literature.** Notes:
- **Estimates.** Interaction of government consumption with institutional quality, with 95% CIs, in the replications of Table A12:
  - Oto-Peralías and Romero-Ávila (ICRG from QoG, 1981–2005; WGI, 1996–2020), with System GMM and fixed effects;
  - Mollick and Vianna (approximate annual replication with the WGI mean, and the published specification with WGI government effectiveness).
- **Consumption measures.** Period mean or contemporaneous, first year t_p, t_p − 1, % of trend GDP, lagged.
- **Inference.** As in Table A12.

**Figure 4. Local projection of GDP on a predetermined wage bill shock.** Notes:
- **Panel.** Annual 1996–2023, no microstates.
- **Response.** 100 × log GDP per capita from t − 1 to t + h.
- **Shock.** (a): 100 × (W_{t−1}/P_{t−2} − W_{t−2}/P_{t−2}) / y_{t−2}, dated in t − 1 and deflated by the deflator of t − 2.
- **Specification.** Two lags of the shock and of growth; country and year fixed effects. h = −1 is zero by construction.
- **Inference.** 95% CIs from Driscoll-Kraay standard errors (maximum lag 3). Other shocks and inference methods are in Table A16.

**Figure A1. Data coverage.** Notes: Number of countries with data in each year, 1979–2023, for four series:
- general government wage bill (IMF GFS);
- central government wage bill (WDI);
- public employment (WWBI);
- meritocratic recruitment (V-Dem).

**Figure A2. Influence of countries and periods on the preferred estimate.** Notes:
- **Specification.** Preferred five-year specification (wage bill and controls in t_p − 1, country and period fixed effects, standard errors clustered by country), re-estimated:
  - leaving out one country at a time (panel a);
  - leaving out one period at a time (panel b).
- **Ordering.** Ranked by the estimate.
- **Reference lines.** Dashed line: full-sample estimate (−0.142).
- **Inference.** 95% CIs clustered by country.

**Figure A3. Annual, dynamic and five-year estimates on a common scale.** Notes:
- **Common object.** The effect on average annual growth of real GDP per capita over the five years from t_p of a wage bill one point of GDP higher, maintained from t_p − 1, with 95% CIs.
- **Annual estimates.** Table 1 model with the ratio in t − 1 to t − 5, or its five-year average; implied effect by the delta method; Driscoll-Kraay standard errors.
- **Harmonised annual.** The same, on the country-years of the common country-periods.
- **Five-year estimates.** The preferred specification on 355 and on the 311 country-periods of the bias checks.
- **WWBI estimates.** The wage bill in t_p − 1 on the registered (173 country-periods, 50 countries) and strict (148, 48) H2 samples.
- **Excluded.** The local-projection estimate is not shown because the dated shock does not identify it (first-stage F = 0.008).
- **Source.** Table A9.

## Correções de rótulos e de consistência (Bloco 6)

O detalhe está no memorando, seção "Conferência".

**Verificação automática** (`final_v5.py`, estendendo `numeracao_final.py`). Nenhum texto visível das 19 tabelas finais contém:
- numeração antiga;
- rótulos internos (T1–T6, B1);
- caminhos;
- "draft", "revision" ou "review";
- "plan addendum" genérico, "replaces", "earlier version/round/panel" ou "(main)".

**Correções feitas depois da rodada final** (commit `4874e52`; nenhuma estimativa muda):
- títulos dos painéis (b) e (c) da Figura 1 encurtados e legendas abaixo dos painéis;
- letras dos painéis novos da A4 passam a K–M (H–J já existiam);
- linha das elasticidades da A4 preenchida;
- título da A4 condicionado à regra lida por inteiro ("full range");
- p de Holm do −0,334 na A9;
- linha do teste LP − quinquenal marcada como não calculada;
- rótulos das diferenças da A7 completos;
- título da A6 ("smaller in absolute value").
