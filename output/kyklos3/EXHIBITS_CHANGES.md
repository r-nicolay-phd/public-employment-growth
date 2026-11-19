# Alterações nas exibições: versão final (parecer da versão final, Kyklos)

**Origem.**
- Gerado por `code/kyklos3/master_kyklos3.do` e por `code/kyklos3/numeracao_final.py`.
- Plano: terceiro adendo, `docs/plan_addendum_kyklos_3.md`, commit `c402c35`.

**Pastas.**
- **Painéis novos (arquivos separados):** `output/kyklos3/tables/` e `output/kyklos3/figures/`.
- **Exibições completas na numeração final:** `output/kyklos3/final/tables/` e `output/kyklos3/final/figures/`.
  - Cada tabela final já junta a tabela de base e todos os painéis, linhas ou colunas novos das duas rodadas (`kyklos2` e `kyklos3`).
  - Títulos e remissões estão renumerados.
  - Os rótulos internos foram trocados por descrições.

## Contagem

| | Versão final | Limite |
|---|---|---|
| Tabelas do texto principal | 2 (Tabelas 1 e 2) | — |
| Figuras do texto principal | 4 (Figuras 1–4) | — |
| Tabelas do apêndice | 17 (A1–A17) | 19 |
| Figuras do apêndice | 2 (A1–A2) | — |

Nenhuma tabela nova foi criada; o material novo entra como painéis, linhas ou colunas.

## Mapeamento completo para a numeração final

| Versão final | Arquivo final (`output/kyklos3/final/`) | Base | Acrescentado nesta rodada (`output/kyklos3/tables/`) | Acrescentado na rodada anterior (`output/kyklos2/tables/`) |
|---|---|---|---|---|
| Tabela 1 | `Table_1_measures` | `output/kyklos/tables/Table_1_measures` | — | — |
| Tabela 2 | `Table_2_employment_relative_pay` | `Table_3_decomposition` | — | — |
| A1 | `Table_A1_data_sources_cleaning` | `Table_S1_data_sources_cleaning` | — | — |
| A2 | `Table_A2_descriptives` | `Table_S2_descriptives` (painel B retirado) | — | `Table_A2_panel_B_harmonized` (substitui o painel B) |
| A3 | `Table_A3_spending_items` | `TabS20_spending_items` | — | — |
| A4 | `Table_A4_simulation` | `Table_A5_simulation` (kyklos2) | `Table_A4_panel_calibrated` (painéis E–G); `Table_A4_panel_lags_numerator` (painéis H–J) | — |
| A5 | `Table_A5_annual_checks` | `TabS28_checks` | `Table_A5_rows_controls_sources` (controles predeterminados; fontes diferentes) | `Table_A6_new_rows` (ano fiscal) |
| A6 | `Table_A6_mollick_cabral` | `TabS19_mollick_cabral` | — | — |
| A7 | `Table_A7_five_year_grid` | `TabS21_five_year_grid` | — | — |
| A8 | `Table_A8_preferred_bias_checks` | `Table_A2_baseline_composition` | `Table_A8_panel_bias_common` (substitui o painel de viés da rodada anterior, `Table_A11_panel_bias_checks`) | — |
| A9 | `Table_A9_equivalence_influence` | `TabS25_equivalence` | — | — |
| A10 | `Table_A10_robustness_map` | `Table_A5_robustness_map` | — | — |
| A11 | `Table_A11_general_central` | `Tab2new_coverage` | — | — |
| A12 | `Table_A12_institutions_replications` | `Table_A3_institutions_replications` | — | — |
| A13 | `Table_A13_institutions_tests` | `TabS26_institutions_tests` | `Table_A13_rows_calibrated` (linhas novas no painel F; contagem das células do painel E) | `Table_A15_new_panels` (painéis E e F) |
| A14 | `Table_A14_mollick_vianna_published` | `Table_S17_mollick_vianna_published` | — | `Table_A16_new_rows` |
| A15 | `Table_A15_h2_strict` | `TabS22_h2_strict` | `Table_A15_panel_size` ("Wage bill size across samples and functional forms") | `Table_A17_new_columns` |
| A16 | `Table_A16_local_projections` | `TabS23_lp_predetermined` | — | `Table_A18_new_panel` |
| A17 | `Table_A17_hypothesis_verdicts` | `Table_S13_hypothesis_tests` (com o F do calendário eleitoral acrescentado à nota) | — | — |
| Figura 1 | `Figure_1_simulation` | — | **nova versão**: desenho calibrado em preto, ancorado em cinza; painel (c) com o desenho calibrado | substitui `Figure_A3_simulation` |
| Figura 2 | `Figure_2_five_year_grid` | `Fig1new_timing_grid` | — | — |
| Figura 3 | `Figure_3_institutions` | `Figure_2_institutions` | — | — |
| Figura 4 | `Figure_4_lp_dated_shock` | `Fig3new_lp_shock_a` | — | — |
| A1 | `Figure_A1_coverage` | `Figure_S1_coverage` | — | — |
| A2 | `Figure_A2_influence` | regenerada em `10_tabelas_k3.do` com rótulos sem "T3" (mesmos números de `FigS8_influence`) | — | — |

**Tabelas que saem da versão final.** Ficam no pacote de replicação:
- tempo (antiga A1/A9);
- decomposição e placebo (S3);
- economia política (A4);
- S4–S12, S14–S16 e S18;
- simulação antiga (S24);
- federações × unitários (S27).

As remissões a elas, nas notas das tabelas que ficam, foram trocadas por "a supplementary table in the replication package".

## Correções de rótulos

**Textos visíveis de tabelas e notas.**
- Os rótulos "T1"–"T6", "B1 sample", "docs/AUDITORIA_DADOS.md" e os caminhos `data/raw/...` foram substituídos por descrições:
  - "preferred specification";
  - "growth excluding the first year";
  - "the source notes of the replication package";
  - e equivalentes.
- **Verificação automática** (`numeracao_final.py`): nenhum texto visível das 19 tabelas finais contém numeração antiga (S1–S28, A18–A19, Tabela 3+), rótulos internos, caminhos de arquivo, "draft", "revision" ou "review".

**Títulos que precisam ser revistos pelos autores.** São títulos de tabelas de base, gerados por rodadas anteriores, que conflitam com resultados novos:
- **A13:** "The annual amplification result is explained by timing", da rodada de 13/11. A rodada de 16/11 concluiu que o gradiente de elasticidade é pequeno demais. Sugestão: "Institutional tests: the annual amplification is consistent with timing".
- **A9:** "The data neither support nor rule out moderate wage bill effects". Continua correto.
