# Memorando de resultados: reestimações do parecer da versão 5 (Kyklos)

**Origem.**
- Execução de `PROMPT_Claude_Code_Kyklos_reestimacoes_v5.md`.
- Código: `code/kyklos4/master_kyklos4.do`, Stata 17 (MP), semente 20261117. Rodada final de 8.927 s (2 h 29 min), sem erros.
- Plano: quarto adendo, `docs/plan_addendum_kyklos_4.md`, commit `fb6c84b1fa0293f197deeafe6735fe974004ebf1` (17/11/2026 13:23:55), com as regras do Bloco 7 transcritas literalmente.
  - O código foi commitado antes da rodada final: `d28c3db` (13:53:56).
  - Depois da rodada, só mudaram rótulos, títulos e o layout da Figura 1: commit `4874e52` (16:29:16). Nenhuma estimativa mudou; o estágio 07 foi rodado de novo, sozinho e sem erros.
- Números: vêm de `output/kyklos4/tables/*.csv` e de `data/interim/kyklos4/kv.csv`. A conferência é feita por `code/kyklos4/confere_memo4.py`.

**Estatuto.**
- Tudo é exploratório ("post-plan, pre-registered in the fourth addendum").
- Os veredictos registrados de H1–H5 (Tabela A17) não mudam.

**Numeração.** É a da versão 5:
- Tabelas 1–2 e A1–A17;
- Figuras 1–4 e A1–A3 (A3 é nova).

As exibições completas estão em `output/kyklos4/final/`.

## Quadro-resumo

| Bloco | Resultado principal | Regra aplicada (quarto adendo, Bloco 7) | Decisão para o manuscrito |
|---|---|---|---|
| 1. Fração contábil | Com ε = 0,48, a distância por momentos escolhe k* = 1 (fração de 29%). Nesse k, a nula prevê −0,057 [−0,160; 0,032] para a defasada e +0,133 [0,031; 0,223] para Hamilton; os dados mostram −0,001 e −0,016. Nenhum k reproduz os dois momentos com ε = 0,48. A faixa entre desenhos vai de 5% (registrado) a 102% (placebo). | "Não reproduz algum dos dois momentos em nenhum k" | Resumo: só a faixa completa entre desenhos, sem número central. Saem "mostly accounting" e "between a third and three-fifths". |
| 1. Resto (ψ) | ψ* = −0,3 (k = 1) reproduz os dois momentos, mas a fração sobe só a 45%. | Não chega a 80% | "The remainder is not identified as either a growth cost or a non-causal co-movement." |
| 1. Defasada | A nula da defasada em k* tem IC que contém zero ([−0,160; 0,032]). | O IC contém zero | Mantém "prefer lagged ratios". |
| 2. −0,14 × −0,02 | Retirar os primeiros períodos de reporte às GFS leva T3 de −0,142 a −0,013, explicando 105% da diferença de −0,123. O bloco "transição antes de 1999" explica −2%. | O primeiro período explica ≥ 2/3 | O texto diz que a estimativa quinquenal depende desses períodos. O resumo deixa de citar −0,14 sem essa ressalva. |
| 2. Viés nos 355 | As checagens viáveis movem T3 entre −0,002 e +0,030. | < 0,05 | "The bias checks that can be run on the full sample move the estimate by less than 0.05." |
| 3. Escala comum | Efeito anual implícito: −0,002 [−0,318; 0,314]. Contra −0,14, p = 0,481; contra −0,33, p = 0,094. A LP-IV não é identificada (F = 0,008). | Compatível com os dois | "The lagged ratio is imprecise and compatible with the five-year estimates." |
| 3. WWBI | Holm do −0,334 na família de 38 coeficientes: p = 0,876. | ≥ 0,05 | Sai do resumo e fica na seção 4.3, como heterogeneidade não significativa após o ajuste. |
| 4. Grade quinquenal | Tendência no *timing*: +0,082 por passo [0,018; 0,185], p = 0,005 (controles em t_p − 1); com controles médios, +0,097, p < 0,001. | p < 0,05 | "The coefficient becomes significantly less negative as the wage bill moves out of the period." |
| 4. Mollick-Cabral | Em t_p − 1, FE: −0,078 [−0,145; 0,011], p = 0,081 (1986–2004); −0,055 [−0,095; −0,005], p = 0,033 (1986–2023). | — (só reportar) | Mencionar no texto o coeficiente predeterminado negativo, menor em valor absoluto que o da média do período. |
| 5. Instituições | As safras 2022-12 e 2023-12 do WDI não fecham a distância: a razão replicado/publicado mínima é 2,03. | Não fica < 1,5 | O resumo deixa de citar frações institucionais. O texto dá a faixa completa como frações "of our replicated interaction": 5–39% (registrada) e 36–73% (publicada). |
| 5. Tendência | Interação sobre o PIB tendencial na especificação registrada: −0,121***. As médias da nula vão de −0,021 a +0,048. | — | Ressalva no "is not detected with predetermined measures". |
| 5. Holm | 1 das 24 células da tripla interação continua significativa a 5% (antes do ajuste eram 13). | — | Reportar na seção 4.4 e na Tabela A13. |
| 6. Consistência | Valores únicos, notas, rótulos e referências corrigidos (ver "Conferência"). | — | Atualizar os números indicados no texto. |

---

## Bloco 0: registro

| Documento | Commit | Data |
|---|---|---|
| Quarto adendo | `fb6c84b1fa0293f197deeafe6735fe974004ebf1` (tag `kyklos-addendum-4`) | 17/11/2026 13:23:55 |
| Código dos adendos 1–3 (`code/kyklos`, `kyklos2`, `kyklos3`) | `54e4ccf285ba952ef5a82f2ac43a850bcc4f691e` ("Add code of addenda 1-3 (committed after estimation; see timeline)") | 17/11/2026 13:23:55 |
| Código do quarto adendo (`code/kyklos4`) | `d28c3db55cf0653507fc84a759f5a8ba5410b825` | 17/11/2026 13:53:56 |
| Correção de rótulos e layout (sem mudar estimativas) | `4874e52680f3efbb68935179f11674ffb2e1b245` | 17/11/2026 16:29:16 |

**Arquivos atualizados.**
- `docs/registration_timeline.md` (seção 5 nova).
- `registration_osf/`:
  - `05_addendum4_2026-11-17.md/.pdf`;
  - `repo_until_addendum4.bundle` (verificado com `git bundle verify`);
  - README com "four addenda".
- **Não houve upload.**

**Frase para o A.8 (pronta para colar):**
> The code of the first three addenda was placed under version control on 17 November 2026, after the estimates it produces had been run; for those rounds the order between addendum and estimation is documented by file-system dates, not by git. The code of the fourth addendum was committed before its final run.

---

## Bloco 1: fração contábil robusta ao desenho

**O que foi estimado.**
- **Grade.** k ∈ {0; 0,05; …; 0,50; 0,75; 1} × ε ∈ {0,25; 0,48; 0,52; 0,71}, com 1.000 replicações por célula. As medidas são: mesmo ano, Hamilton, HP unilateral, HP bilateral, defasada, T3, DP dentro do país e AR(1).
- **Escolha de k.** Pela distância por momentos registrada: Σ |média simulada − observado| / DP simulado, sobre DP, AR(1), defasada e Hamilton. O mesmo ano não entra.
- **Elasticidades separadas.** Variante com elasticidade real e de preços.
- **Variante ψ.** Grade k × ψ com 200 replicações por célula, depois 1.000 no ponto escolhido.
- **Referência analítica.**

**Números** (Tabela A4, parte "Moment-matched calibration", painéis K–M; Figura 1):

| ε | k* | Fração em k* | k a menos de 10% do mínimo (frações) | Defasada em k* [2,5–97,5] | Hamilton em k* | Reproduz os dois |
|---|---|---|---|---|---|---|
| 0,25 | 1,00 | 33% | 1,00 | −0,049 [−0,143; 0,024] | 0,031 [−0,068; 0,126] | Sim |
| **0,48** | **1,00** | **29%** | 0,75–1,00 (29–40%) | −0,057 [−0,160; 0,032] | 0,133 [0,031; 0,223] | **Não** |
| 0,52 | 1,00 | 28% | 1,00 | −0,059 [−0,183; 0,032] | 0,152 [0,043; 0,243] | Não |
| 0,71 | 1,00 | 19% | 1,00 | −0,059 [−0,193; 0,033] | 0,249 [0,137; 0,342] | Não |
| Real e preços separados | 0,40 | 78% | 0,30–1,00 (51–81%) | −0,098 [−0,166; −0,046] | 0,099 [0,035; 0,155] | Não |

Observado: defasada −0,001, Hamilton −0,016.

**Leitura da grade.**
- Hamilton é o momento que falha: com ε = 0,48, nenhum k põe o observado dentro do intervalo simulado.
- Quanto menor k, maior a fração (63% em k = 0), mas pior o ajuste.
- **Variante ψ:**
  - com ε = 0,48: k = 1, ψ = −0,3, fração 45%, reproduz os dois momentos (defasada −0,066 [−0,176; 0,021]; Hamilton 0,028 [−0,082; 0,120]);
  - com ε = 0,71: k = 0,75, ψ = −0,5, fração 62%, não reproduz.
- **Referência analítica:**
  - ε = 0,48: λ = Var(A)/Var(Δln s) = 0,137, fração implícita 68%;
  - ε = 0,71: λ = 0,043, fração implícita 38%.
- **Elasticidades da folha nominal:** ao PIB real, 0,230 (EP 0,184); ao deflator, 0,754 (EP 0,071). A folha acompanha os preços muito mais que o produto real.

**Faixa entre desenhos (ε = 0,48).**

| Desenho | Fração |
|---|---|
| Registrado | 5% |
| Reversão à média | 25% |
| Ancorado sem escala (= escolhido por momentos) | 29% |
| ψ | 45% |
| Calibrado com k = 0,30 | 58% |
| Analítica | 68% |
| Real e preços separados | 78% |
| Placebo | 102% |

**Regras.**
- (i) Nenhum k reproduz os dois momentos com ε = 0,48: vale a linha 3, "faixa completa, sem número central".
- (ii) ψ não leva a fração a 80%: "remainder not identified".
- (iii) A nula da defasada contém zero: mantém "prefer lagged ratios".

**Frases (inglês).**

*Summary* (substitui "mostly accounting" e "between a third and three-fifths"):
> Depending on how the simulated wage bill is designed, a wage bill with no effect on growth reproduces between 5% and 102% of the same-year coefficient; no design reproduces at the same time the lagged and the trend-GDP coefficients observed in the data, so the accounting share is not pinned down.

*Section 1 (introduction):*
> A synthetic wage bill that has no effect on growth, but moves with nominal GDP as the observed one does, generates a sizeable negative same-year coefficient. How sizeable depends on the design: from 5% of the observed coefficient under a random walk to the full coefficient under a fixed-numerator placebo. Calibrating the design to the moments of the data does not narrow this range, because no calibration matches both the lagged and the trend-GDP coefficients.

*Section 3.2:*
> We choose the scale k of the simulated residuals by the distance between simulated and observed moments (within-country standard deviation and AR(1) of the ratio, and the coefficients of the lagged ratio and of the ratio over Hamilton trend GDP), leaving the same-year coefficient out. At ε = 0.48 the distance selects k = 1, which reproduces 29% of the same-year coefficient, but the simulated Hamilton coefficient (0.133 [0.031; 0.223]) does not cover the observed one (−0.016) at any k. Letting the numerator residual co-move with real growth (ψ = −0.3) reproduces both moments and 45% of the coefficient. The remainder is not identified as either a growth cost or a non-causal co-movement.
> The analytic decomposition gives a benchmark without simulation: the denominator term −(1 − ε)Δln Y accounts for 14% of the within-country variance of Δln s at ε = 0.48 (4% at ε = 0.71), which would reproduce 68% (38%) of the same-year coefficient. The nominal wage bill responds to the GDP deflator (elasticity 0.75, SE 0.07) much more than to real output (0.23, SE 0.18).
> Under the selected design the simulated null of the lagged coefficient is −0.057 [−0.160; 0.032], which contains zero; we therefore keep the recommendation to use lagged ratios.

*Notes and Appendix A.4 (Figure 1):* see the note in `EXHIBITS_CHANGES.md`. Remove any reference to the calibrated design as "main".

---

## Bloco 2: por que a estimativa quinquenal cai de −0,14 para −0,02

**O que foi estimado.**
- Descrição dos 44 país-períodos perdidos.
- Interações de grupo.
- Influência, um por um e por blocos.
- Checagens de viés nos 355.
- Nulas descontadas nos 355 e nos 311, com bootstrap de pares e a simulação refeita em cada sorteio (999 sorteios).

**Números** (Tabela A8, parte "Which country-periods drive the five-year estimate"):
- **Coeficientes.** β(355) = −0,142, β(311) = −0,019, diferença −0,123.
- **Perfil dos 44.**
  - 82% são o primeiro período de reporte do país às GFS (9% nos 311; p < 0,001).
  - 36% começam em 1979–1993 (10%).
  - Renda menor (log PIB per capita 8,86 contra 9,75).
  - Mérito e dívida menores.
  - O mesmo crescimento (2,04 contra 2,17; p = 0,748) e a mesma razão folha/PIB (9,25 contra 9,59; p = 0,511).
- **Interações.**
  - A inclinação nos primeiros períodos (−0,142) é a mesma dos demais (−0,150): interação 0,007, p de bootstrap 0,921.
  - Transição antes de 1999: interação 0,627, p = 0,387.
  - Logo, o efeito de retirar os primeiros períodos não vem de uma inclinação diferente nesses períodos. Vem da variação dentro do país que eles carregam: são o ponto inicial da série de cada país.
- **Blocos retirados dos 355.**

| Bloco | Coeficiente | Fração explicada |
|---|---|---|
| Primeiros períodos de reporte | −0,013 | 105% |
| Transição antes de 1999 | −0,144 | −2% |
| Períodos de 1979–1993 | −0,067 | 61% |
| Os 44 | −0,019 | 100% |

  Um a um, cada período explica de −6% a 55%.
- **Checagens nos 355.** O crescimento anterior foi completado com o crescimento anual dos cinco anos antes de t_p, o que recuperou 13 país-períodos.

| Variante | Coeficiente | Diferença | p de bootstrap |
|---|---|---|---|
| + hiato | −0,143 | −0,000 | 0,145 |
| + crescimento anterior | −0,117 | 0,025 | 0,110 |
| + ambos | −0,112 | 0,030 | 0,082 |
| Hiato negativo (efeito médio) | −0,145 | −0,002 | 0,099 |

- **Nulas** (observado − média da nula, IC de 95%):

| Desenho | Nula, 355 | Obs. − nula, 355 | Nula, 311 | Obs. − nula, 311 |
|---|---|---|---|---|
| Reversão à média | −0,093 | −0,050 [−0,228; 0,069] | +0,094 | −0,113 [−0,381; 0,081] |
| Ancorado sem escala | −0,039 | −0,104 [−0,232; 0,058] | −0,020 | 0,001 [−0,155; 0,126] |
| Escolhido por momentos | −0,039 | −0,103 [−0,224; 0,056] | −0,020 | 0,001 [−0,155; 0,136] |

  **O sinal foi verificado.** A nula com reversão à média é de fato positiva nos 311 (+0,094) e negativa nos 355 (−0,093). O −0,109 [−0,337; 0,097] da versão 5 (terceiro adendo, semente 20261116) e o −0,113 [−0,381; 0,081] do quarto adendo (semente 20261117) usam o mesmo procedimento: 1.000 simulações para a média da nula e 999 sorteios de pares com a simulação refeita em cada sorteio. A diferença é só de Monte Carlo: a média da nula nos 311 é +0,090 numa rodada e +0,094 na outra. O sinal da nula está confirmado.

**Regras.**
- O primeiro período de reporte explica 105% (≥ 2/3): o texto diz que a estimativa depende desses períodos.
- As checagens nos 355 movem menos de 0,05.

**Frases (inglês).**

*Summary:* substituir qualquer menção isolada a −0.14 por:
> a five-year coefficient of −0.14 that rests on the first period in which each country reports its wage bill.

*Section 4.3:*
> The preferred five-year estimate (−0.142, 355 country-periods) falls to −0.019 on the 311 country-periods for which the bias checks can be run. The 44 lost country-periods are mostly the first period in which a country reports its general government wage bill (82%, against 9% among the others); they do not differ in growth or in the wage bill ratio. Dropping only these first reporting periods moves the estimate to −0.013, which accounts for the whole difference (105%); the transition economies before 1999 account for none of it. The slope in those periods is the same as elsewhere (interaction 0.007, bootstrap p = 0.92): what they carry is the within-country variation that starts each country's series. The five-year estimate therefore depends on the first reporting periods. The bias checks that can be run on the full sample move the estimate by less than 0.05 (from −0.002 to +0.030). Net of the simulated nulls, the estimate is −0.10 [−0.22; 0.06] under the moment-matched design and −0.05 [−0.23; 0.07] under the mean-reverting one.

*Appendix A.5 or A.6 (bias checks):*
> On the common sample the mean-reverting null is positive (+0.094) whereas on the full sample it is negative (−0.093), so observed minus null is −0.113 [−0.381; 0.081] on the common sample.

---

## Bloco 3: escala comum

**Objeto.** O efeito sobre o crescimento médio de t_p a t_p + 4 de uma folha 1 ponto do PIB maior, mantida desde t_p − 1.

**Estimativas** (Tabela A9, parte "Annual, dynamic and five-year estimates on a common scale"; Figura A3):

| Estimativa | Efeito [IC 95%] | p | Obs. | Países |
|---|---|---|---|---|
| Anual, defasagens t − 1 a t − 5 | −0,002 [−0,318; 0,314] | 0,989 | 1.377 | 79 |
| Anual, média móvel de cinco anos | 0,030 [−0,176; 0,236] | 0,775 | 1.377 | 79 |
| LP-IV, choque (a) | não identificado (F = 0,008); IC de Anderson-Rubin = toda a reta | — | 1.264 | — |
| T3 (355) | −0,142 [−0,284; −0,001] | 0,049 | 355 | 68 |
| T3 na amostra comum (311) | −0,019 [−0,184; 0,146] | 0,817 | 311 | 64 |
| WWBI, amostra registrada | −0,334 [−0,599; −0,070] | 0,014 | 173 | 50 |
| WWBI, amostra estrita | −0,382 [−0,683; −0,081] | 0,014 | 148 | 48 |
| Harmonizado, quinquenal (= WWBI) | −0,334 | 0,014 | 173 | 50 |
| Harmonizado, anual | −0,216 [−0,489; 0,058] | 0,122 | 803 | 54 |

Os p de T3 e do WWBI nesta tabela são do erro agrupado. Os p de bootstrap continuam:
- 0,120 para T3 (Tabela A17);
- 0,030 e 0,036 para o WWBI (Tabela A15).

**Testes de compatibilidade** (999 pares de países, mesmos sorteios):

| Teste | Diferença [IC] | p |
|---|---|---|
| Anual − T3 | 0,140 [−0,239; 0,544] | 0,473 |
| Anual − WWBI | 0,332 [−0,104; 0,798] | 0,148 |
| T3 − WWBI | 0,192 [−0,056; 0,483] | 0,155 |
| Anual contra −0,14 | — | 0,481 |
| Anual contra −0,33 | — | 0,094 |

O teste LP × T3 não foi calculado, porque a projeção não é identificada.

**Holm** (família de 38 coeficientes da folha nas Tabelas A9, A10 e A15). Holm foi usado no lugar de Romano-Wolf, conforme registrado no adendo, porque Romano-Wolf exigiria reestimar os 38 modelos com sorteios comuns.

| Coeficiente | p não ajustado | p de Holm |
|---|---|---|
| −0,334 (nível) | 0,030 | 0,876 |
| −0,264 (log, registrada) | 0,076 | 1,000 |
| −0,294 (log, estrita) | 0,062 | 1,000 |

**Regras.**
- A evidência anual é compatível com −0,14 e com −0,33: troca "the lagged ratio none".
- O Holm do −0,334 é ≥ 0,05: sai do resumo.

**Frases (inglês).**

*Summary:* substituir "the lagged ratio has none" por:
> the lagged ratio is imprecise and compatible with the five-year estimates.

Retirar do Summary a estimativa da subamostra WWBI (−0.33).

*Section 4.1 or 4.2:*
> On a common scale — the effect on average growth over the next five years of a wage bill one point of GDP higher, maintained from t_p − 1 — the annual distributed-lag model gives −0.002 [−0.318; 0.314] and the five-year moving average 0.030 [−0.176; 0.236]. These intervals contain both the five-year estimate (p = 0.48 against −0.14) and the WWBI-sample estimate (p = 0.09 against −0.33): the annual evidence is imprecise, not contradictory. The dated wage bill shock moves the ratio too little to identify the same object by local projections (first-stage F = 0.008; the Anderson-Rubin set is unbounded).

*Section 4.3:*
> In the H2 samples the wage bill in t_p − 1 has a coefficient of −0.334 (wild bootstrap p = 0.030; strict sample −0.382, p = 0.036). This is one of 38 wage-bill coefficients we report across samples and specifications; after a Holm adjustment over that family its p-value is 0.88, so we treat it as heterogeneity that does not survive multiple testing.

---

## Bloco 4: grade quinquenal e Mollick-Cabral

**O que foi estimado.**
- Grade (349 país-períodos comuns): modelo empilhado, bootstrap selvagem de Webb com 9.999 replicações.
- Mollick-Cabral: FE com bootstrap e GMM de dois passos com correção de Windmeijer.

**Grade** (Tabela A7, linhas novas):

| Diferença | Controles em t_p − 1 | Controles médios |
|---|---|---|
| Média − t_p | −0,098 [−0,260; 0,005], p = 0,067 | −0,113 [−0,266; −0,016], p = 0,018 |
| t_p − (t_p − 1) | −0,065 [−0,130; −0,013], p = 0,013 | −0,080 [−0,157; −0,021], p = 0,005 |
| Média − (t_p − 1) | −0,163 [−0,370; −0,037], p = 0,005 | −0,193 [−0,395; −0,070], p < 0,001 |
| Tendência (por passo) | 0,082 [0,018; 0,185], p = 0,005 | 0,097 [0,035; 0,197], p < 0,001 |

**Mollick-Cabral** (Tabela A6, linhas novas):

| Período | Medida | FE | GMM |
|---|---|---|---|
| 1986–2004 | t_p − 1 | −0,078 [−0,145; 0,011], p = 0,081 (206 obs.) | −0,056, p = 0,319 |
| 1986–2004 | Média do período | −0,117 [−0,238; −0,026], p = 0,012 | — |
| 1986–2004 | Diferença | 0,039 [−0,074; 0,169], p = 0,491 | — |
| 1986–2023 | t_p − 1 | −0,055 [−0,095; −0,005], p = 0,033 (418 obs.) | −0,051, p = 0,087 |
| 1986–2023 | Média do período | −0,121, p = 0,006 | — |
| 1986–2023 | Diferença | 0,066 [−0,017; 0,149], p = 0,118 | — |

**Regra.** A tendência tem p < 0,05.

**Frases (inglês).**

*Section 4.1 (grid):*
> The coefficient becomes significantly less negative as the wage bill moves out of the period: −0.32, −0.22 and −0.16 for the period mean, the first year and the last year of the previous period; the linear contrast is 0.08 per step [0.02; 0.19] (p = 0.005) with controls in t_p − 1 and 0.10 [0.04; 0.20] (p < 0.001) with period-mean controls.

*Section 4.4 or Appendix (Mollick and Cabral):*
> In our replication of Mollick and Cabral (2011), government consumption measured in the last year of the previous block also has a negative fixed-effects coefficient (−0.078, p = 0.08 in 1986–2004; −0.055, p = 0.03 in 1986–2023), smaller in absolute value than with the block mean (−0.117 and −0.121); the differences are not significant (p = 0.49 and 0.12).

Os coeficientes −0,32, −0,22 e −0,16 são os da Figura 2 com controles em t_p − 1, a mesma versão do contraste de 0,08. Conferir no manuscrito se os números citados no texto são esses.

---

## Bloco 5: instituições

**O que foi estimado.**
- Quadro completo das frações da nula:
  - especificação registrada e publicada;
  - desenhos ancorado (k = 1), calibrado (k = 0,30) e escolhido por momentos (k = 1 para o consumo);
  - ε₀ = 0,556 e 0,701;
  - com e sem gradiente.
- Safras do WDI, baixadas da API, fonte 57, gratuita:
  - `data/raw/wdi_archives/wdi_202212.csv`;
  - `data/raw/wdi_archives/wdi_202312.csv`;
  - documentadas em `_SOURCE.txt`.
- Interação sobre o PIB tendencial contra a sua nula.
- Holm nas 24 células.

**Frações da nula** (Tabela A13, parte nova):
- **Especificação registrada:** 5–39% da interação replicada (−0,184).
  - Com gradiente: 32–39%.
  - Sem gradiente: 5–19%.
- **Especificação publicada:** 36–73% da interação replicada (−2,326).
  - Sem gradiente: 36–65%.
  - Com gradiente: 43–73%.
  - Em relação à interação publicada (−0,811): 102–208%.
- As faixas que o prompt manda corrigir conferem: sem gradiente, publicada 36–65%; com gradiente, registrada 33–39% (32% no desenho escolhido por momentos).

**Safra do WDI** (Tabela A14, linhas novas):

| Safra | Interação replicada | Replicado/publicado |
|---|---|---|
| Atual | −2,32 / −2,00 / −2,28 | 2,46–2,86 |
| 2022-12 | −1,97 / −1,66 / −2,02 | 2,03–2,43 |
| 2023-12 | −2,27 / −2,05 / −2,41 | 2,51–2,89 |

As interações seguem a ordem GE / CC / RL. O artigo de Mollick e Vianna não informa a data de acesso; por isso usamos as safras de dezembro de 2022 e de 2023. A razão mínima é 2,03, sem chegar a 1,5.

**Interação sobre o PIB tendencial** (Tabela A12, linha nova):
- Replicada: −0,121***.
- Médias da nula nos 12 desenhos: −0,021 a +0,048. O "cerca de −0,006" citado no parecer está dentro dessa faixa.

**Holm.** 1 das 24 células da tripla interação continua significativa a 5%. Sem ajuste eram 13.

**Regra.** A safra não reduz a razão abaixo de 1,5: "replicated only".

**Frases (inglês).**

*Summary:* retirar as frações institucionais (por exemplo, "two-fifths to three-quarters").

*Section 4.4:*
> Across simulation designs, a consumption series with no effect on growth reproduces 5–39% of our replicated interaction in the registered specification and 36–73% in the published specification. Our replicated interaction is 2.0–2.9 times the published one, and older WDI vintages (December 2022 and December 2023) do not close the gap, so these shares are fractions of our replicated interaction, not of the published coefficient. With consumption measured over Hamilton trend GDP, the interaction in the registered specification remains negative (−0.121, p < 0.01) and the simulated nulls (−0.02 to 0.05) do not reproduce it; the amplification is therefore weaker, not absent, with predetermined measures. After a Holm adjustment, 1 of the 24 triple-interaction cells remains significant at 5%.

*Section 5 (conclusion):* substituir qualquer fração institucional por:
> a substantial but design-dependent part of our replicated interaction.

---

## Bloco 6: consistência das exibições

Todas as tabelas foram regeneradas em `output/kyklos4/final/` por `code/kyklos4/final_v5.py`. A verificação automática não encontrou nenhuma ocorrência proibida: marcas de revisão, rótulos internos (T1–T6, B1), caminhos, numeração antiga, "plan addendum" genérico, "replaces", "earlier version/round/panel", "(main)".

### Conferência

| Item | Valor anterior | Valor corrigido | Fonte |
|---|---|---|---|
| Diferença mesmo ano − defasada, IC (Tabelas 1, A3, A5) | A3: [−1,168; −0,351]; A5: [−1,173; −0,353] | [−1,174; −0,351] nas três (cálculo registrado da Tabela 1, semente 20261017) | `data/interim/revisao/kv.csv` (dif_13_lo/hi) |
| p de bootstrap de T3 (Tabelas A8, A15, A17) | 0,125 na A15 | 0,120 nas três (Tabela A17) | `revisao/kv.csv` (T3_own_pboot) |
| A15, p do −1,858 (amostra estrita, folha fixa) | 0,063 (coluna d) e 0,064 (parte "reverse-denominator") | 0,063 e IC [−3,737; 0,111] nas duas partes (mesmo modelo, dois sorteios; vale o da coluna principal) | `Table_A15`, `kyklos2/Table_A17_new_columns` |
| A8, T3 menos a nula com reversão à média, amostra comum (311) | −0,109 [−0,337; 0,097] (parte da amostra comum) e −0,113 [−0,381; 0,081] (parte nova) | −0,113 [−0,381; 0,081] nas duas partes (mesmo procedimento; vale o cálculo do quarto adendo) | `Table_A8_part_null_adjusted.csv` |
| A9 (parte nova), p dos números quinquenais e do WWBI | p = 0,014 para −0,334 e −0,382, sem dizer a inferência | Nota: p e IC agrupados por país (distribuição t); *wild bootstrap* 0,120, 0,030 e 0,036 | `Table_A9_part_common_scale.csv` |
| A6, GMM de sistema | Painel B (−0,072) e continuação (−0,068) sem rótulo de etapa | Painel B: "System GMM, one-step"; continuação: "System GMM, two-step"; nota explica também a inferência dos efeitos fixos (agrupada × *wild bootstrap*) | `TabS19_mollick_cabral.csv`, `Table_A6_rows_five_year_tests.csv` |
| A8 × A9, transição antes de 1999 | −0,144 (N = 354) e −0,166 (N = 352) sem definição | Mesma definição; a A9 exclui os 3 períodos (BGR, HUN, SVN 1994), a A8 só o que está entre os 44 (SVN 1994); dito nas duas notas | `q5_base.dta`, `TabS25_influence.csv` |
| Tabela 2, nota da coluna 4 | "139 exactly in t_p − 1 (column 4)" | Acrescentado: 116 na estimação, depois de 8 sem controles e 15 *singletons* | rodada de conferência de `p5_rv.dta` |
| A4, painel K | 63% com k = 0 só na Figura 1a | Linha de referência ε = 0,48, k = 0: 63%, defasada −0,120, Hamilton 0,290 | `gk_sum.dta` |
| A3, rótulo | "Bias: same year − lagged" | "Same-year − lagged contrast" (linha, linha do sinal previsto e nota) | — |
| A1, choques | Só o choque convencional | Linha nova: choque (a), datado em t − 1 | — |
| A15, coluna (e) | "strict", com 220 obs. e 73 países | Rótulo explicado na nota: é o *timing* estrito do par do prêmio (t_p − 1 a t_p − 4), disponível para mais país-períodos que o par emprego/salário relativo (152 e 49). A estimativa não muda. | Nota da A15 |
| A16, h = 2 | ** | *** (p de Driscoll-Kraay = 0,0095 < 0,01) | Nota da A16 |
| A16, *lead* do *jackknife* | Ausente | h = −2: −0,078 (p = 0,070), significativo a 10%, reportado na nota | Nota da A16 |
| A10 | Linhas misturadas | Agrupada em preferida / alternativas / resumos; 6 das 22 especificações alternativas são significativas a 5% | `Table_A10` |
| A10 × A11, unitários | −0,193** (p = 0,029) × IC [−0,361; 0,055] | Nota da A10: o p da A10 é o agrupado convencional; a A11 dá IC de bootstrap percentil para o mesmo coeficiente, que contém zero | Notas da A10 e da A11 |
| A11, os dois p = 0,066 | Pareciam duplicados | São estatísticas diferentes (−0,169 diferença geral − central; −0,241 unitários), cada uma superada em valor absoluto por 66 dos 999 sorteios | Nota da A11 |
| Tabela 2, rótulo | "Price term: effect of 1 within-country SD" | "Effect of 1 within-country SD (price term in cols. 2–5; premium in col. 6; wage bill in col. 7)" | Tabela 2 |
| A4, "main" | Painel A "(main)"; Figura 1 com o calibrado como "main" | Painel A: "anchored on the observed ratio of t − 1, unscaled residuals"; nota "A (anchored design, unscaled residuals)"; Figura 1 refeita sem "main" | Tabela A4, Figura 1 |
| Mollick-Vianna, amostra comum de 3.108 obs. | Países não informados | 132 países (das 138 listadas no artigo, 137 estão nos dados; Porto Rico falta) | `kyklos3/tables/conferencia_bloco8_final.csv` |
| Países do −0,334 e do −0,382 | — | 50 (173 obs.) e 48 (148 obs.) | `Table_A9_part_common_scale.csv` |
| Marcas de revisão | "keeps three designs from earlier rounds", "design of the earlier version of this table", "Replaces the bias panel…", "the earlier panel B used…" | Removidas ou trocadas por descrições neutras ("the design registered in the first addendum") | `final_v5.py` (POST) |
| Adendos | "pre-registered in the plan addendum" | Adendo específico ("first/second/third/fourth addendum") em todas as notas | `final_v5.py` |
| Fontes não rastreáveis | "a supplementary table in the replication package", "Table S8, row 7" | "the replication package (README, list of tables and programs, row N)" ou "(README, additional estimates, row N)"; "structural-explanations table, line 7" | `replication_kyklos/README.md` |
| A17, F eleitoral | — | Nota: F efetivo de 2,33 nas democracias (5,31 em todos os país-anos) | Nota da A17 |
| Gelbach (2016) | Nas referências do apêndice | Não é usado em nenhuma tabela final (a decomposição de Gelbach saiu com as tabelas que foram para o pacote) | Busca em `output/kyklos4/final/` |

### Referências das bases (APA)

**Situação de cada base.**
- **[pacote]:** a base está em `replication_kyklos/docs/data_sources.csv`, com a data de acesso.
- **[conferir]:** os autores precisam completar ou confirmar.

**Referências.**
- **[pacote]** World Bank. (n.d.). *Worldwide Governance Indicators* [Data set]. Retrieved October 7, 2026, from https://www.worldbank.org/en/publication/worldwide-governance-indicators
  - [conferir] Acrescentar a versão (atualização de 2024 ou 2025) e, se desejado, o artigo metodológico: Kaufmann, D., & Kraay, A. (2024). *The Worldwide Governance Indicators: Methodology and 2024 update* (Policy Research Working Paper No. 10952). World Bank.
- **[pacote]** The Quality of Government Institute. (2026). *The QoG Standard Dataset, time-series* (Version Jan26) [Data set]. University of Gothenburg. https://www.gu.se/en/quality-government/qog-data
  - [conferir] O ICRG entra por meio do QoG. Citar também: PRS Group. (n.d.). *International Country Risk Guide* [Data set]. A data de acesso é a do QoG (7/10/2026).
- **[pacote]** Coppedge, M., Gerring, J., Knutsen, C. H., Lindberg, S. I., Teorell, J., et al. (2026). *V-Dem Country-Year Dataset v16* [Data set]. Varieties of Democracy (V-Dem) Project. https://doi.org/10.23696/vdemds26 (acesso: 7/10/2026)
  - [conferir] A lista completa de autores da v16.
- **[pacote]** Cruz, C., Keefer, P., & Scartascini, C. (2021). *Database of Political Institutions 2020* [Data set]. Inter-American Development Bank. https://data.iadb.org/dataset/the-database-of-political-institutions-dpi-2020 (acesso: 7/10/2026)
- **[pacote]** Marshall, M. G., & Gurr, T. R. (2020). *Polity5: Political regime characteristics and transitions, 1800–2018* [Data set]. Center for Systemic Peace. https://www.systemicpeace.org/inscrdata.html (acesso: 13/11/2026)
- **[pacote]** International Labour Organization. (n.d.). *ILOSTAT database* [Data set]. Retrieved October 7 and October 17, 2026, from https://ilostat.ilo.org
- **[pacote]** International Monetary Fund. (n.d.). *Investment and Capital Stock Dataset* [Data set]. Retrieved October 7, 2026, from https://data.imf.org
  - [conferir] Versão do ICSD (por exemplo, 2021).
- **[pacote]** International Monetary Fund. (n.d.). *Global Debt Database* [Data set]. Retrieved October 7, 2026, from https://data.imf.org. Metodologia: Mbaye, S., Moreno Badia, M., & Chae, K. (2018). *Global Debt Database: Methodology and sources* (IMF Working Paper No. 18/111). International Monetary Fund.
- **[pacote]** International Monetary Fund. (2026). *Government Finance Statistics: Government expenditures by function (COFOG)* (Version 11.0.0) [Data set]. https://data.imf.org/Datasets/GFS_COFOG (acesso: 13/11/2026)
- **[conferir]** Forum of Federations. (n.d.). *Countries* [Data set]. Retrieved [data], from https://forumfed.org/countries/
  - A lista de federações está fixa no código (`code/03_painel.do`, variável `federal`), sem data de acesso.
  - Não está em `data_sources.csv`.
  - Os autores devem confirmar a data e a lista.
- **[pacote]** Alesina, A., Favero, C., & Giavazzi, F. (2019). *Austerity: When it works and when it doesn't*. Princeton University Press.
  - Dados obtidos de: Gale, W., Berlin, I., & Thorpe, S. (2025). *Replication data for: Fiscal consolidation: Lessons for the U.S.* [Data set]. Harvard Dataverse. https://doi.org/10.7910/DVN/J104NQ (acesso: 17/10/2026)
- **[pacote]** World Bank. (2022, 2023). *World Development Indicators*, December 2022 and December 2023 vintages [Data set]. WDI Database Archives (API source 57). Retrieved November 17, 2026, from https://api.worldbank.org/v2/sources/57
  - Usada na Tabela A14 (linhas novas).
  - [conferir] Acrescentar a `data_sources.csv` do pacote; a fonte está documentada em `data/raw/wdi_archives/_SOURCE.txt`.
- **Gelbach, J. B. (2016).** When do covariates matter? And which ones, and how much? *Journal of Labor Economics, 34*(2), 509–543.
  - Não é usado em nenhuma tabela da versão 5: **recomenda-se retirá-lo** das referências do apêndice.

---

## Verificação

- `code/kyklos4/confere_memo4.py` confere os números deste memorando contra os `.csv` de `output/kyklos4/tables/` e o `kv.csv`. Resultado: ver `docs/KYKLOS_V5_LOG.md`.
- `code/kyklos4/final_v5.py` (que estende `numeracao_final.py`): 0 ocorrências proibidas nas 19 tabelas e 7 figuras finais.
- `master_kyklos4.do`: rodou do início ao fim numa sessão limpa (8.927 s, sem erros).
- Cada parte nova tem:
  - título com o resultado;
  - nota com amostra, efeitos fixos, controles, erro-padrão, replicações e "pre-registered in the fourth addendum".
