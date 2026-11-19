# Alterações nas tabelas e figuras (versão Kyklos)

**Limite.** A Kyklos pede de 15 a 25 páginas. O texto principal continua com **3 tabelas e 4 figuras**. As exibições novas substituem as atuais em vez de se somar a elas; o restante vai para o apêndice online.

**Onde estão os arquivos.** As exibições novas estão em `output/kyklos/tables/` e `output/kyklos/figures/`, com o nome gerado pelo código entre parênteses. As tabelas antigas regeneradas, com notas corrigidas, estão em `output/kyklos/tables/Table_*`. As figuras com a numeração Kyklos estão em `output/kyklos/figures/Figure_*`.

## Texto principal

| Exibição | Situação | Arquivo |
|---|---|---|
| Tabela 1 | Mantida (medidas da folha) | `Table_1_measures` |
| Tabela 2 | **Substituída** pela versão com uma só inferência (IC percentil e estrelas do mesmo bootstrap pareado). Nenhum coeficiente é significativo a 5%; o título muda conforme o resultado | `Tab2new_coverage` (a antiga `Table_2_coverage` sai) |
| Tabela 3 | Mantida (decomposição). O texto deve citar a Tabela S22: H2 sobrevive ao timing estrito | `Table_3_decomposition` |
| Figura 1 | **Substituída** pela grade quinquenal (medida × timing dos controles, mesma amostra, IC do bootstrap). A versão antiga vai para o apêndice como Figura A6 | `Fig1new_timing_grid` |
| Figura 2 | Mantida (instituições) | `Figure_2_institutions` |
| Figura 3 | **Substituída** pela projeção local com o choque datado em t − 1, com *leads*. A versão antiga (choque corrente e nível predeterminado) vai para o apêndice como Figura A7 | `Fig3new_lp_shock_a` |
| Figura 4 | Mantida (curva de especificações) | `Figure_4_specification_curve` |

**Alternativa.** Como a tese do "accounting" precisa ser reescrita (memorando, Bloco 6), a Figura S7 (simulação da hipótese nula) pode entrar no texto principal como Figura 4. Nesse caso, a curva de especificações vai para o apêndice como Figura A8, e o texto principal continua com 4 figuras.

## Apêndice online

| Exibição | Situação | Arquivo |
|---|---|---|
| Tabelas A1–A5 | Regeneradas, com notas corrigidas: nota do painel D da A3 (crescimento do PIB real), painel C com "Mollick and Vianna (2024)", arredondamento harmonizado entre A1, A2 e A5, e A5 citando a "Figure 4" | `Table_A1_timing` … `Table_A5_robustness_map` |
| Figura A6 | **Nova posição:** antiga Figura 1 (timing, versão anterior) | `Figure_1_timing` |
| Figura A7 | **Nova posição:** antiga Figura 3 (choque corrente e nível predeterminado) | `Figure_3_local_projections` |
| Figuras A1–A5, S1–S4 | Mantidas | `Figure_A1_*` … `Figure_S4_*` |
| Tabelas S1–S18 | Mantidas (regeneradas sem mudança de números) | `Table_S1_*` … `Table_S18_*` |
| Tabela S19 | **Nova:** réplica aproximada de Mollick e Cabral (2011) | `TabS19_mollick_cabral` |
| Tabela S20 | **Nova:** outras razões de gasto e condição de sinal | `TabS20_spending_items` |
| Tabela S21 | **Nova:** grade quinquenal e decomposição controle a controle | `TabS21_five_year_grid` |
| Tabela S22 | **Nova:** H2 com timing estrito | `TabS22_h2_strict` |
| Tabela S23 | **Nova:** projeções locais com três choques × três inferências e *leads* | `TabS23_lp_predetermined` |
| Tabela S24 | **Nova:** simulação sob a hipótese nula calibrada; o painel E é um diagnóstico pós-hoc, declarado | `TabS24_simulation` |
| Tabela S25 | **Nova:** equivalência, efeito mínimo detectável, influência e seleção | `TabS25_equivalence` |
| Tabela S26 | **Nova:** testes das diferenças em A3, mecanismo e índice × período | `TabS26_institutions_tests` |
| Tabela S27 | **Nova:** diferença em diferenças entre geral e central e divisão dos unitários | `TabS27_coverage` |
| Tabela S28 | **Nova:** verificações menores (recessões, antecipação, filtros, dinâmica, GFSM) | `TabS28_checks` |
| Figura S5 | **Nova:** Mollick e Cabral, coeficientes por medida | `FigS5_mollick_cabral` |
| Figura S6 | **Nova:** projeções locais com os três choques | `FigS6_lp_shocks` |
| Figura S7 | **Nova:** distribuições simuladas com o valor observado (ou Figura 4 do texto principal, na alternativa acima) | `FigS7_simulation` |
| Figura S8 | **Nova:** deixar um país ou um período de fora | `FigS8_influence` |

## Formatos

As tabelas estão em `.tex`, `.docx` e `.csv`. As figuras estão em PNG (4.488 px de largura), PDF vetorial e EPS, em tons de cinza. Os nomes das exibições novas devem seguir o padrão `Table_S19_…` e `Figure_S5_…` quando entrarem no manuscrito. O mapeamento está no `README.md` do pacote de replicação.
