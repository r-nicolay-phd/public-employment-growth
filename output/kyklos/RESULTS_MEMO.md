# Memorando de resultados: novas estimações para a Kyklos

**Fonte dos números.** Todos os números saem dos `.csv` de `output/kyklos/tables/` e do registro `data/interim/kyklos/kv.csv`, gerados pela rodada completa de `code/kyklos/master_kyklos.do` em 13/11/2026 (6.409 s, incluindo o `master` da revisão).

**Regras de decisão.** Foram registradas antes de estimar, no adendo `docs/plan_addendum_kyklos.md` (commit `3faa1ea`), e aplicadas sem ajuste.

**Inferência.** IC de 95% entre colchetes; "p boot" é o p do wild cluster bootstrap (Webb, 9.999 replicações).

## Quadro-resumo

| Item crítico | Resultado-chave | Regra aplicada | Decisão para o manuscrito |
|---|---|---|---|
| 1. Mollick e Cabral (2011) | Anual, mesmo ano, 1986–2004: FE −0,023 (p = 0,093), GMM −0,015 (p = 0,017). Sobre o PIB tendencial: GMM 0,000 (p = 0,981). Defasado: GMM −0,014 (p = 0,017) | O padrão não se reproduz no FE, e o coeficiente defasado continua significativo no GMM | **Trocar o título** para uma versão restrita; a reinterpretação vira hipótese apoiada na folha |
| 2. Outras razões de gasto | Condição de sinal confirmada em 3 de 4 itens (despesa total, transferências, investimento); não no consumo | ≥ 3 de 4 | Pode falar de **"spending ratios", com a ressalva da elasticidade** |
| 3. Timing × médias | Com controles em t_p − 1: t_p −0,224 → t_p − 1 −0,159, redução de 29% | < 40% | **Reescrever** "Timing, not averaging…" |
| 4. H2 estrito | Salário relativo −4,381, p boot 0,006 [−7,143; −1,642] | p < 0,05 | **Mantém H2** no texto principal, com o IV (fraco) e o prêmio (nulo) como ressalvas |
| 5. Projeções locais | Choque (a): nenhuma resposta de h = 3–6 significativa em 2 de 3 inferências | Condição de "custo" não atendida | **"No robust evidence of a delayed cost"** |
| 6. Contabilidade (simulação) | Folha de efeito zero reproduz **4,7%** do coeficiente anual do mesmo ano | < 50% | **Reescrever a tese** do "accounting" |
| 7. Equivalência | T3: menor limite de equivalência 0,261; não há equivalência a ±0,10 | Não rejeita | **"Neither support nor rule out moderate effects"**; retirar a frase sobre metas de folha/PIB |
| 8. Instituições | Diferença mesmo ano − defasada, painel D: −2,219, p boot < 0,001. Mecanismo (a) verificado (−0,180, p = 0,003) | Diferença e mecanismo | **"Explained by timing"** |

## Bloco 1. Réplica de Mollick e Cabral (2011) — Tabela S19, Figura S5

**O que foi estimado.**
- A especificação publicada, lida no PDF (`Consensus/mollick2011.pdf`): 54 economias, 1986–2004, log do PIB per capita sobre o próprio lag, crescimento populacional, ln(I/Y) e ln(G/Y). Estimadores: System GMM de um passo, com instrumentos sem colapsar, e efeitos fixos.
- Medidas de tamanho do governo: (a) mesmo ano, (b) placebo, (c) PIB tendencial de Hamilton e (d) defasada, além das versões quinquenais.
- Extensão para 1986–2023.
- A réplica é aproximada: safra atual do WDI e sem as medidas de ativos externos.

**Números principais (1986–2004, coluna 1).**
- **Publicado:** anual −0,032 (0,008); quinquenal −0,086 (0,060), não significativo.
- **(a) Mesmo ano:** FE −0,023 [−0,050; 0,004], p = 0,093; GMM −0,015 [−0,028; −0,003], p = 0,017.
- **(b) Placebo:** FE −0,054, GMM −0,025, ambos p < 0,001.
- **(c) Hamilton:** FE 0,031 (p = 0,158); GMM 0,000 (p = 0,981).
- **(d) Defasada:** FE −0,014 (p = 0,243); GMM −0,014 [−0,025; −0,002], p = 0,017.
- **Diferenças no FE empilhado:** (a) − (c) = −0,062, p boot < 0,001; (a) − (d) = −0,017, p boot = 0,073.
- **Quinquenal, sem encolher:** média do período, FE −0,117 (p = 0,017) e GMM −0,108 (p = 0,020); t_p − 1, FE −0,078 (p = 0,006) e GMM −0,053 (p = 0,230).
- **1986–2023:**
  - mesmo ano: FE −0,044 e GMM −0,017, ambos p ≤ 0,001;
  - Hamilton: GMM −0,005 (p = 0,300);
  - defasada: GMM −0,008 (p = 0,079), queda de 53% em relação ao mesmo ano;
  - (a) − (d) no FE: −0,045, p boot < 0,001.

**Regra e conclusão.**
- O padrão não se reproduz por inteiro: o mesmo ano não é significativo no FE.
- A correção pelo PIB tendencial elimina o coeficiente, mas a medida defasada continua significativa no GMM em 1986–2004.
- Pela regra, **o título muda para uma versão restrita**. Na amostra estendida, o padrão fica mais próximo da tese: a defasada perde significância a 5%, mas isso não entra na regra registrada.
- Na nossa réplica, a média quinquenal não emudece o coeficiente: ele continua negativo e significativo com a média do período.

**Texto a mudar e redação proposta.**
- **Título:**
  > Accounting or Averaging Out? Public Wage Bills and Economic Growth
- **Frase sobre Mollick e Cabral, a substituir:**
  > In an approximate replication of Mollick and Cabral (2011), their annual coefficient on government consumption disappears when consumption is measured over trend GDP, but not when it is lagged one year in their System GMM estimator (−0.014, p = 0.017); in the longer sample to 2023 the lagged coefficient is smaller and not significant at 5%. We therefore present the reinterpretation of their annual result as a hypothesis that our wage bill evidence supports, not as a demonstrated reversal.

## Bloco 2. Outras razões de gasto — Tabela S20

**O que foi estimado.** As medidas da Tabela 1 (mesmo ano, placebo, Hamilton, HP unilateral, defasada) para consumo, despesa total, transferências e investimento público (ICSD), com as elasticidades ao PIB e o viés (mesmo ano − defasada) testado por bootstrap.

**Números principais.**

| Item | Elasticidade nominal | Viés (bootstrap) | Sinal previsto | Confirma? |
|---|---|---|---|---|
| Folha (referência) | 0,520 [0,269; 0,770] | −0,722 [−1,168; −0,351] | negativo | sim |
| Consumo | 0,701 [0,596; 0,806] | −0,127 [−0,266; 0,012] | negativo | **não** |
| Despesa total | 0,506 [0,231; 0,781] | −0,200 [−0,298; −0,117] | negativo | sim |
| Transferências | 0,368 [0,041; 0,695] | −0,270 [−0,382; −0,155] | negativo | sim |
| Investimento público | 0,844 [0,570; 1,119] | 0,126 [−0,034; 0,274] | zero | sim |

**Regra e conclusão.**
- São 3 confirmações em 4, e o manuscrito pode falar de "spending ratios" com a ressalva.
- Duas cautelas:
  - a confirmação do investimento vem de não se prever viés e não se encontrar nenhum. Ela não testa o caso de viés positivo; a elasticidade real é 1,632, acima de 1;
  - o consumo, a medida das réplicas da literatura, não confirma a 5%.

**Redação proposta.**
> The same-year bias is not specific to the wage bill. For total expenditure and social benefits, whose elasticity to GDP is below one, the same-year coefficient is more negative than the lagged one; for public investment, whose nominal elasticity is close to one, there is no bias. For government consumption the difference has the predicted sign but is not significant. The argument therefore applies to spending ratios whose numerator responds less than one-for-one to GDP.

## Bloco 3. Grade quinquenal — Tabela S21, nova Figura 1

**O que foi estimado.** Grade 3 × 2 (medida × timing dos controles) na mesma amostra (349 obs.), com crescimento médio e sem o primeiro ano, a versão Hamilton e a troca de um controle por vez.

**Números principais (p e IC do bootstrap).**
- **Controles em t_p − 1:**
  - média do período −0,322 (p = 0,004);
  - t_p −0,224 (p = 0,018);
  - t_p − 1 −0,159 (p = 0,084) [−0,308; 0,020];
  - t_p − 1 sobre o PIB tendencial −0,154 (p = 0,111).
- **Controles da média do período:** t_p −0,176 (p = 0,058); t_p − 1 −0,096 (p = 0,337).
- **Redução de t_p para t_p − 1:** 29% com controles predeterminados; 45% com controles da média.
- **Troca de um controle por vez** (partindo de t_p − 1 com controles da média, −0,096): o investimento em t_p − 1 leva o coeficiente a −0,160. É o investimento do período que absorve a associação.

**Regra e conclusão.** Redução de 29%, abaixo de 40%: **reescrever**.

**Redação proposta.**
> Averaging dilutes the accounting component; with predetermined controls, first-year timing matters little (−0.224 with the wage bill in t_p and −0.159 in t_p − 1). Most of the difference between the conventional and the predetermined specifications comes from the period-mean investment control, which absorbs part of the association.

## Bloco 4. H2 com timing estrito — Tabela S22

**O que foi estimado.**
- **Amostra estrita:** pares do WWBI em t_p − 1 a t_p − 4. Saem 63 dos 243 pares; 104 não estão em t_p − 1. Ficam 168 país-períodos, 152 na regressão.
- **Especificações:** modelo em log, componentes com a folha total, salário sobre o PIB tendencial, IV e prêmio.
- **Inferência:** p de bootstrap e Romano-Wolf.

**Números principais.**
- **Salário relativo, estrito:** −4,381, p boot 0,006 [−7,143; −1,642].
- **Emprego, estrito:** −2,523, p boot 0,058.
- **Com a folha total como controle:** −1,858, p boot 0,063.
- **Sobre o PIB tendencial:** −4,086, p boot 0,021.
- **IV:** F efetivo 6,57; IC de Anderson-Rubin igual à reta inteira.
- **Prêmio ajustado:** −0,075 (p boot 0,789).
- **Romano-Wolf de H2:** registrado 0,002 (o mesmo da S13); família com a amostra estrita, 0,036.
- **Atribuição.** O p de 0,002 é do −5,393 do modelo em log. O −1,68 da Tabela S6 (salário relativo com a folha total como controle) tem p boot de 0,017.
- **Magnitudes (efeito de 1 DP dentro do país):**
  - registrado: −0,81 ponto de crescimento, contra 2,02 de DP do crescimento;
  - estrito: −0,56, contra 1,81.

**Regra e conclusão.** p boot 0,006 < 0,05: **H2 fica no texto principal**, com duas ressalvas: o IV fraco e o prêmio nulo.

**Redação proposta.**
> The association with relative pay survives when public employment and the wage bill are measured strictly before the period (−4.381, wild bootstrap p = 0.006; Romano–Wolf p = 0.036 in the family with the strict sample). One within-country standard deviation of relative pay corresponds to 0.56 points of five-year growth, against a within-country standard deviation of growth of 1.81. The instrumented version is weak (effective F = 6.6) and the adjusted wage premium shows no association, so the result is about the measured relative wage, not about a premium over comparable private workers.

## Bloco 5. Projeções locais com choque predeterminado — Tabela S23, Figura S6, nova Figura 3

**O que foi estimado.**
- Três choques: (a) datado em t − 1; (b) purgado, com bootstrap por blocos de 999 replicações; (c) deflator de t − 1.
- Três inferências: Driscoll-Kraay, defasagens aumentadas e jackknife de meio painel.
- *Leads* e regime de mérito com Romano-Wolf.

**Números principais.**
- **Choque (a), Driscoll-Kraay:**
  - h = −3: 0,063 (p = 0,243); h = −2: 0,029 (p = 0,499), ou seja, sem antecipação;
  - h = 1: −0,212 (p = 0,028); h = 2: −0,339 (p = 0,010);
  - h = 3: −0,434 (p = 0,077); h = 4: −0,403 [−0,998; 0,193]; h = 5: −0,339; h = 6: −0,230, todos não significativos.
  - Nenhum horizonte de 3 a 6 é significativo em duas das três inferências.
- **Choque (b), purgado:** h = 3: −1,278 (p = 0,043); h = 4: −1,715 (p = 0,015), com bootstrap por blocos.
- **Choque (c):** negativo e significativo de h = 3 a 6, com Driscoll-Kraay e defasagens aumentadas.
- **Diferença alto − baixo mérito (choque a):** de −0,58 a −3,81, com Romano-Wolf entre 0,083 e 0,113.

**Regra e conclusão.** **"No robust evidence of a delayed cost"** com o choque (a). Mas os choques (b) e (c), que mantêm o numerador corrente, mostram respostas negativas tardias. A conclusão depende da definição do choque, e o texto deve dizer isso.

**Comparação de magnitudes.** A resposta acumulada em h = 4 com o choque (a) é −0,403 pontos de log do PIB per capita por ponto do PIB. A escolha dos multiplicadores de referência fica com os autores.

**Redação proposta.**
> With a shock dated before the output window (shock (a)), output falls in the first two years after the shock (−0.21 and −0.34 log points per point of GDP) but there is no robust evidence of a delayed cost: no response between h = 3 and h = 6 is significant under two of the three inferences. Shocks that keep the current wage bill in the numerator show larger and later declines, so the delayed responses reported with the conventional shock should not be read as evidence of a cost.

## Bloco 6. Simulação sob a hipótese nula calibrada — Tabela S24, Figura S7

**O que foi estimado.**
- Folha sintética sem efeito sobre o crescimento, com ε = 0,48, 0,30 e 0,70 e 1.000 replicações cada.
- Regressões da Tabela 1 refeitas em cada replicação.
- Teste placebo × mesmo ano e decomposição em log.

**Números principais (ε = 0,48).**
- **Coeficiente anual do mesmo ano:** observado −0,723; média simulada −0,034 [−0,134; 0,033], ou **4,7%** do observado. Com ε = 0,30 e 0,70, também cerca de 5%.
- **T3:** observado −0,142; simulado −0,011 [−0,085; 0,065]. O observado fica fora do intervalo simulado.
- **Coluna "share of observed":** não tem sentido quando o coeficiente observado é quase zero (por exemplo, na medida defasada).
- **Placebo − mesmo ano:** −0,012, p boot 0,975. A correlação entre o placebo e a razão do mesmo ano é **0,978**: o placebo é quase o mesmo regressor e, por isso, não separa o denominador do resto.
- **Log(W/Y\*) por ponto do PIB tendencial:** −0,199 [−0,357; −0,040], próximo de T3 (−0,142).
- **Diagnóstico da série registrada.** Ela é um passeio aleatório: DP dentro do país de 4,03 (observado: 0,98) e AR(1) de 1,013 (observado: 0,970). Isso dilui mecanicamente a covariância contemporânea.
- **Diagnóstico pós-hoc, não registrado e fora da regra:** com a série ancorada na razão observada de t − 1 (DP dentro do país 1,38; AR 0,87), a folha de efeito zero reproduz **26%** do coeficiente do mesmo ano e 25% de T3.

**Regra e conclusão.** 4,7% < 50%: **reescrever a tese**. Mesmo o diagnóstico pós-hoc fica abaixo de 50%. O mecanismo contábil, com a elasticidade estimada, não reproduz sozinho o coeficiente do mesmo ano.

**Redação proposta.**
> A synthetic wage bill with no effect on growth, calibrated to the observed elasticity of the wage bill to GDP, reproduces only a small share of the same-year coefficient (about 5%; about a quarter when the synthetic ratio is anchored on the observed ratio of the previous year). The denominator mechanism therefore cannot by itself account for the negative same-year coefficient. The placebo numerator reproduces the coefficient, but it is almost collinear with the same-year ratio (correlation 0.98) and does not separate the denominator from other sources of the same-year correlation. We present the timing result — the coefficient vanishes with predetermined measures — as the robust finding, and the accounting mechanism as one candidate explanation.

## Bloco 7. Equivalência e influência — Tabela S25, Figura S8

**Números principais.**
- **Folha defasada, painel anual:** −0,001; IC de 90% [−0,235; 0,233]; menor limite de equivalência 0,235; efeito mínimo detectável 0,384.
- **T3:** −0,142; IC de 90% [−0,261; −0,024]; menor limite 0,261; efeito mínimo detectável 0,199. Não há equivalência a ±0,05, ±0,10 ou ±0,20.
- **Corte de 3 pontos do PIB:** efeito anual sobre o crescimento entre 0,002 e 0,853 ponto (limites do IC de 95% de T3).
- **Influência sobre T3:**
  - sem economias em transição antes de 1999: −0,166 (p = 0,019);
  - sem 2019–2023: −0,119 (p = 0,114);
  - sem 1979–1993: −0,081 (p = 0,406);
  - só países com GFS até 2000: −0,132 (p = 0,095);
  - deixando um país de fora: p < 0,05 em 32 de 68 casos.
- **Seleção.** Quem entra cedo nas GFS é mais rico (diferença de 1,31 em log do PIB per capita), tem mais recrutamento por mérito (+1,11) e mais dívida (+12,1 pontos, p = 0,072).

**Regra e conclusão.** Não há equivalência a ±0,10. Vale "the data neither support nor rule out moderate effects", e a frase sobre metas de folha/PIB sai.

**Redação proposta.**
> The data neither support nor rule out moderate effects: the 90% confidence interval of the preferred coefficient excludes zero only marginally and includes effects as large as 0.26 points of growth per point of GDP. Half of the leave-one-country-out estimates lose significance, and the coefficient falls to −0.08 without the 1979–1993 periods.

## Bloco 8. Instituições — Tabela S26

**Números principais.**
- **Diferenças mesmo ano − defasada:**
  - painel C: −0,198, p boot 0,011;
  - painel D: −2,219, p boot < 0,001;
  - mesmo ano − PIB tendencial: painel C −0,063 (p = 0,146); painel D −2,286 (p < 0,001).
- **Mecanismo:**
  - **(a) Elasticidade do consumo nominal ao PIB.** Cai com as instituições pelo WGI (−0,180, p = 0,003); o mesmo vale para a folha (−0,155, p = 0,020). Não é significativa com o ICRG/QoG.
  - **(b) Variância do hiato.** Menor com melhores instituições: WGI −0,257 (p = 0,001); ICRG −0,339 (p < 0,001).
  - **(c) Parte cíclica do consumo/PIB.** WGI −0,181 (p = 0,024); ICRG −0,046 (p = 0,613).
- **Oto-Peralías e Romero-Ávila, índice × período:**
  - ICRG/QoG em 1996–2020: FE −0,168 (média do período) e 0,478 (t_p − 1), nenhum significativo;
  - WGI em 1996–2005: FE 0,086 (média do período) e 0,231 (t_p − 1, p = 0,035).
  - A mitigação de 1981–2005 não aparece com o ICRG em 1996–2020. A diferença com o resultado original vem do **período**, não do índice.

**Regra e conclusão.** A diferença e o mecanismo se verificam: **"explained by timing"**. Uma ressalva: o mecanismo (a) só aparece com o WGI.

**Redação proposta.**
> The amplification found with annual data is explained by timing: the difference between the same-year and the lagged interaction is significant in both replications (wild bootstrap p = 0.011 and p < 0.001), and the condition that generates a spurious interaction holds — the elasticity of government consumption to GDP falls with institutional quality (WGI). The mitigation result of Oto-Peralías and Romero-Ávila does not depend on timing, but it does not appear in 1996–2020 with either index.

## Bloco 9. Governo geral × central — nova Tabela 2, Tabela S27

**Números principais (uma só inferência: bootstrap pareado, 999).**
- **Governo geral, amostra comum:** −0,138 [−0,290; 0,029], p = 0,106.
- **Governo central:** 0,031 [−0,198; 0,264].
- **Diferença geral − central:** −0,169, p = 0,066.
- **Diferença em diferenças, federações − unitários:** 0,353 [−0,163; 1,843], p = 0,226.
- **Divisão dos unitários** pela razão de 1,5: diferença −0,069 (p = 0,895).
- **Federações:** razão mediana geral/central 4,08 nas 12 federações da amostra de estimação.

**Conclusão.** Com uma inferência coerente, **nenhum coeficiente da Tabela 2 é significativo a 5%**, e a heterogeneidade entre federações e unitários não é significativa.

**Redação proposta.**
> On a common sample and with a single bootstrap inference, neither the general nor the central government coefficient is significant at 5%, and the gap between them does not differ significantly between federations and unitary countries. Coverage matters for which countries enter the sample more than for the coefficient.

## Bloco 10. Verificações menores — Tabela S28 e tabelas regeneradas

**Resultados.**
- **Mesmo ano por sinal do hiato em t − 1:** −0,398 com hiato negativo e −0,891 com hiato positivo, ambos p < 0,001. Antes, sem os anos de crescimento negativo, era −0,244.
- **Antecipação:** a folha em t_{p+1} − 1 cai com o crescimento do período (−0,132, p = 0,003), como o denominador prevê.
- **Correlação com o crescimento do PIB corrente:** tendência HP unilateral 0,855; tendência de Hamilton 0,078.
- **T3 com dinâmica:** com crescimento defasado (LSDV), −0,108 (p = 0,094); BC-FE −0,099.
- **GFSM:** sem metadados de base metodológica nas GFS; não feito.

**Tabelas regeneradas.**
- A3: nota do painel D corrigida; painel C passa a citar "Mollick and Vianna (2024)".
- A1, A2 e A5: arredondamento harmonizado (0,169; −0,058).
- A5: remissão "Figure 4".
- Arquivos em `output/kyklos/tables/Table_*`.

**Redação proposta (recessões).**
> The same-year coefficient is negative both after negative and after positive output gaps (−0.40 and −0.89), so it is not an artefact of recession years.

## Pendências para os autores

- **Mollick e Cabral.** O PDF estava disponível e a especificação foi seguida. Conferir as diferenças de dados (safra do WDI, ausência de IFI/GEQ) e se o modelo deles tinha efeitos de tempo; o texto não os menciona.
- **Magnitudes do Bloco 5.** Escolher os multiplicadores fiscais de referência.
- **Reescrita.** Reescrever título, resumo, introdução e seções de resultados conforme o quadro-resumo, em especial a tese do "accounting" (Bloco 6) e a frase "Timing, not averaging" (Bloco 3).
- **Simulação.** Decidir como apresentar o diagnóstico pós-hoc: reportado no painel E da Tabela S24 e declarado como tal.
