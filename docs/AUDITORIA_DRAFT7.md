# Auditoria e reprodução do draft 7

Gerado por `code/revisao/01_auditoria.do` em 13 Nov 2026. Todo número abaixo sai do código (registro `data/interim/revisao/kv.csv`).

## 1. Reprodução das tabelas

O pipeline do draft 7 (`run_all.do` e as extensões L1 e L2) foi rodado de novo a partir de `data/raw/`, e os números de cada `.tex` foram comparados, na ordem em que aparecem, com os do commit de base `781942e` (estado do draft 7). Foram comparados 1756 números em 21 tabelas; 0 diferem em mais de 0,001. As tabelas do texto principal (1 a 4) são transcrições das Tabelas S12, S1, S3 e S8a–c/S18, e por isso ficam cobertas pela comparação.

| Tabela (arquivo) | Números no draft 7 | Números reproduzidos | Diferenças > 0,001 | Maior diferença |
|---|---|---|---|---|
| table1_descriptives.tex | 193 | 193 | 0 | 0.000 |
| table2_baseline.tex | 200 | 200 | 0 | 0.000 |
| table3_decomposition.tex | 95 | 95 | 0 | 0.000 |
| table4_moderation.tex | 74 | 74 | 0 | 0.000 |
| table5_mechanisms.tex | 74 | 74 | 0 | 0.000 |
| table6_political_economy.tex | 74 | 74 | 0 | 0.000 |
| tablea10_fiscal_rules.tex | 160 | 160 | 0 | 0.000 |
| tablea1_definitions.tex | 25 | 25 | 0 | 0.000 |
| tablea2_countries.tex | 11 | 11 | 0 | 0.000 |
| tablea3_correlations.tex | 82 | 82 | 0 | 0.000 |
| tablea4_gmm_instruments.tex | 69 | 69 | 0 | 0.000 |
| tablea5_bond_check.tex | 46 | 46 | 0 | 0.000 |
| tablea6_threshold.tex | 71 | 71 | 0 | 0.000 |
| tablea7_denominator.tex | 56 | 56 | 0 | 0.000 |
| tablea8a_robustness_definitions.tex | 80 | 80 | 0 | 0.000 |
| tablea8b_robustness_subsamples.tex | 62 | 62 | 0 | 0.000 |
| tablea8c_robustness_cce.tex | 29 | 29 | 0 | 0.000 |
| tablea9_bma.tex | 42 | 42 | 0 | 0.000 |
| tablel1b_frequency_robustness.tex | 39 | 39 | 0 | 0.000 |
| tablel1_frequency_institutions.tex | 152 | 152 | 0 | 0.000 |
| tablel2_long_run.tex | 122 | 122 | 0 | 0.000 |

Os `.docx` refeitos têm texto idêntico ao do commit de base; mudam só os metadados de data. Diferenças entre implementações não ocorreram porque a reprodução usou o mesmo código e os mesmos pacotes do draft 7 (`code/ado/plus`).

## 2. Inconsistências apontadas pelo parecer

| Item | Causa | Situação |
|---|---|---|
| Folha defasada 0,040 na S12 (1.594 obs.) e na S1 (1.622 obs.) [P20] | São dois modelos distintos que arredondam para o mesmo valor: S12 col. 4 = 0.039796 (N = 1594); S1 col. 3 = 0.039525 (N = 1622). A S1 usa capital humano defasado e não exige as medidas HP/Hamilton, por isso tem mais observações. | Explicado; não houve cópia. As novas tabelas mostram 3 casas e N por linha. |
| Tabela S14 com 101 países sob o título de amostra de cinco anos (72) [P13] | A lista foi feita sobre os países com folha de governo geral em algum período (101), não sobre a amostra de estimação do A1 (72 países: 9 de renda baixa, 24 média-baixa, 12 média-alta e 27 alta). | Corrigida na revisão: a lista passa a ser a da amostra efetiva. |
| S-GMM e MQO com 87 países contra 72 nos EF [P22] | Singletons: antes do descarte, a amostra do A1 tem 380 obs. e 87 países; 15 países têm uma única observação e são descartados pelo `reghdfe` (EF), mas não pelo MQO nem pelo S-GMM. | Confirmado. A verificação de Bond é refeita na amostra comum S5_bond (bloco 4.10). |
| BMA com 370 obs. (base 365) [P22] | No draft 7 (`11_robustez.do`), o N da BMA foi contado depois de retirar só os ausentes (inclusive em dívida e mérito) e antes do descarte dos singletons pelo `reghdfe`; os resíduos dos singletons ficam ausentes, de modo que o 370 reportado não é o N efetivo da estimação. | Refeita na amostra correta no bloco 4.11. |
| Subamostras somam 358 (S8b) e 348 (S4) [P22] | Ao estimar cada grupo separadamente, o `reghdfe` descarta os singletons de cada grupo: os grupos de renda somam 365 obs. antes e 358 depois do descarte. Nenhuma observação da base está sem grupo de renda (0). | Explicado; as notas das novas tabelas dizem isso. |
| Períodos de três anos “1981–2023” [P32] | O painel de três anos do draft 7 começa em 1981; o último período começa em 2023 e tem um só ano. | Corrigido na revisão: os períodos de três anos começam em 1979 (15 períodos, 1979–2023). |
| Hansen e diferença-em-Hansen com o mesmo p-valor na S7, col. 1 [P22] | Não é cópia: com uma só defasagem por variável, o modelo sem os instrumentos de nível fica exatamente identificado (Hansen ≈ 0), de modo que a diferença coincide com o Hansen total (p = 0.1618 nos dois). | Explicado na nota da nova tabela. |
| Ponto de inflexão da S3 (29,5) não bate com os coeficientes arredondados (34,2) [P22] | Com os coeficientes sem arredondamento (b1 = -0.20502; b2 = 0.003473), −b1/(2 b2) = 29.5. A tabela mostrava b2 com três casas (0,003). | Explicado; o termo quadrático passa a ter quatro casas. |

## 3. Limpeza ampliada [P31]

As regras foram aplicadas ao painel anual (sem microestados, 1979–2023) antes de montar os painéis da revisão. Contagens em observações país-ano:

| Regra | Observações afetadas |
|---|---|
| Receita acima de 100% do PIB vira ausente | 9 |
| Saldo fiscal fora de ±50% do PIB vira ausente | 6 |
| Inflação acima de 1.000% vira ausente | 58 |
| Abertura igual a zero vira ausente | 21 |
| Participações na despesa fora de [0, 100] viram ausentes | 222 |

A winsorização de crescimento e inflação do draft 7 foi feita na amostra sem microestados de 1980–2023, e não na amostra de estimação (limites do crescimento: -17.63 e 16.33). A revisão mantém esses limites. Com a limpeza ampliada, a amostra de base de cinco anos continua com 365 observações e 72 países, e a amostra anual da Tabela 1 passa de 1.594 para 1593 observações. A amostra de base, portanto, não muda. As regressões de restrição orçamentária (H1) passam a usar a receita e as participações limpas.

## 4. Amostras canônicas

Gravadas em `data/interim/revisao/amostras5.dta` e `amostras1.dta`: S5_base (especificação de base do draft 7, 365 obs.), S1_base (painel anual da Tabela 1, 1593 obs.), S5_common_GC (interseção governo geral × central, definida no bloco 4.3) e S5_bond (amostra comum de MQO, EF, S-GMM e BC-FE, definida no bloco 4.10).
