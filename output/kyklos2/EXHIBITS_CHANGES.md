# Alterações nas exibições da versão 4 (estimações finais para a Kyklos)

Gerado por `code/kyklos2/master_kyklos2.do`. Plano registrado no segundo adendo, `docs/plan_addendum_kyklos_2.md` (commit be45e06). Todos os arquivos estão em `output/kyklos2/tables/` (`.docx`, `.tex`, `.csv`) e em `output/kyklos2/figures/` (`.png` com 4.488 px de largura, `.pdf`, `.eps`, em tons de cinza).

## Contagem

| | Antes | Depois | Limite |
|---|---|---|---|
| Tabelas do texto principal | 3 | 3 | — |
| Figuras do texto principal | 4 | 4 | — |
| Tabelas do apêndice | 19 | 19 | 22 |
| Figuras do apêndice | 6 | 6 | — |

Nenhuma tabela ou figura nova foi criada. O material novo entra em exibições existentes como painéis, linhas ou colunas, e duas exibições (Tabela A5 e Figura A3) são substituídas.

## Exibições substituídas

| Versão 4 | Novo arquivo | Substitui | Conteúdo |
|---|---|---|---|
| Tabela A5 | `Table_A5_simulation` | `TabS24_simulation` (versão anterior da A5) | Painéis A (ancorada, grade de ε), B (estacionária), C (desenho registrado na mesma grade) e D (decomposição direta e correlações com o placebo). |
| Figura A3 | `Figure_A3_simulation` | `FigS7_simulation` (versão anterior da A3) | (a) média simulada × (1 − ε), coeficiente anual do mesmo ano; (b) o mesmo para T3; (c) distribuição da interação institucional simulada (Bloco 4). |

As versões anteriores (`TabS24_simulation`, `FigS7_simulation`) continuam em `output/kyklos/` e no pacote de replicação (`replication_kyklos/output/`, como `Table_S24_simulation` e `Figure_S7_simulation`).

## Painéis, linhas e colunas novos

| Versão 4 | Arquivo | O que entra | Onde inserir |
|---|---|---|---|
| Tabela A2 | `Table_A2_panel_B_harmonized` | Painel B recalculado na amostra exata da Tabela 1 (1.621 país-anos) | Substitui o painel B atual (1.593 país-anos) |
| Tabela A6 | `Table_A6_new_rows` | "Fiscal-year countries excluded" e "Fiscal years realigned" (medidas anuais, quinquenais e T3) e as diferenças testadas | Linhas novas no fim da tabela |
| Tabela A11 | `Table_A11_panel_bias_checks` | "Bias checks for the predetermined estimate": hiato, crescimento de p − 1, hiato negativo, 2SLS, Gelbach, γ × δ e as versões anuais | Painel novo |
| Tabela A15 | `Table_A15_new_panels` | Painel E: tripla interação de Oto-Peralías e Romero-Ávila. Painel F: interação institucional sob a hipótese nula | Dois painéis novos |
| Tabela A16 | `Table_A16_new_rows` | Painel C: IC White e agrupado das interações defasada e sobre o PIB tendencial (GE, CC, RL), contra a interação publicada, com equivalência a ±0,5 e ±1,0 | Linhas novas |
| Tabela A17 | `Table_A17_new_columns` | Colunas (1)–(4) com controles para o canal reverso do denominador, nas amostras registrada e estrita, e Romano-Wolf | Colunas novas |
| Tabela A18 | `Table_A18_new_panel` | Painel C: resposta da folha, multiplicador integral (LP-IV) por horizonte para os choques (a), (b) e (c), θ/5 e T3 | Painel novo |

## Tabelas que não mudam

Tabelas 1, 2 e 3; A1, A3, A4, A7, A8, A9, A10, A12, A13, A14 e A19.

A A19 (veredictos registrados) não muda: os Romano-Wolf recalculados no Bloco 6 aparecem só na A17, como robustez.

## Arquivos auxiliares (não são exibições)

- `output/kyklos2/tables/*.csv`: números de cada painel novo.
- `conferencia_bloco8.csv`: contagens do Bloco 8.
- `conferencia_manuscrito.csv` e `conferencia_manuscrito.md`: números do manuscrito confrontados com os `.csv`.
