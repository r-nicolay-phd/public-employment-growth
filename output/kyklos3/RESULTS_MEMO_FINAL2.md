# Memorando de resultados: estimações do parecer da versão final (Kyklos)

**Origem.**
- Execução de `PROMPT_Claude_Code_Kyklos_estimacoes_parecer_final.md`.
- Código: `code/kyklos3/master_kyklos3.do`, Stata 17, rodada final de 3.633 s, sem erros.
- Plano: terceiro adendo, `docs/plan_addendum_kyklos_3.md`, commit `c402c35`, escrito e commitado antes de qualquer estimação.
- Números: vêm dos `.csv` de `output/kyklos3/tables/` e de `data/interim/kyklos3/kv.csv`. A conferência é feita por `code/kyklos3/confere_memo3.py`.

**Estatuto.**
- Tudo é exploratório ("post-plan, pre-registered in addendum 3").
- Os veredictos registrados (Tabela A17) não mudam.

**Numeração.** É a da versão final: Tabelas 1–2 e A1–A17; Figuras 1–4 e A1–A2. As exibições completas estão em `output/kyklos3/final/`.

## Quadro-resumo

| Bloco | Resultado principal | Regra aplicada | Decisão |
|---|---|---|---|
| 0. Registro | O plano é anterior a todos os do-files e logs dos blocos registrados. Especificações anteriores de H1, H2, H3, H5, H4 (L1), do longo prazo e do contraste mesmo ano × medidas predeterminadas, porém, foram estimadas em 7 e 17/10, antes do plano. | Há exceções | Segunda redação da seção 3.2 e da nota 2, com as exceções listadas em A.8. Também em A.8: o desenho ancorado é posterior ao resultado de 5% do desenho registrado. |
| 1. H1 × H2 | Na amostra do H2, a folha GFS em t_p − 1 tem −0,334 por ponto do PIB, p de bootstrap 0,030 (estrita: −0,382, p = 0,036). Na amostra de T3, o log convertido dá −0,042. Da diferença total (−0,42), 71% vêm do *timing* do par do WWBI. | Linha 1 não (o log convertido da amostra H2 fica em −0,26, não perto de −0,5). Linha 2 sim. Linha 3 sim. | Sai "averaging does not conceal a cost" e o custo na amostra do H2 é reportado. Dizer que o tamanho em H2 depende de pares medidos perto do período. |
| 2. Fração contábil | No desenho calibrado (DP dentro do país 0,971 contra 0,976 observado): 58% com ε = 0,48 e 33% com ε = 0,71. Faixa com ε = 0,48: registrado 5%, ancorado 29%, calibrado 58%, placebo 102%. | > 50% com ε = 0,48, mas não com ε = 0,71 | Resumo: "at least half of the same-year coefficient is accounting". O título continua com pergunta. |
| 3. Controles predeterminados | Mesmo ano − defasada: −0,635, −0,642 e −0,628 nas três versões, todas com p < 0,001. | p < 0,01 nas três | A verificação é citada no texto principal. |
| 4a. Defasagens | Soma de t − 1 a t − 3: −0,054 [−0,325; 0,218]. | O IC contém zero | "The lagged wage bill has no significant association, with a CI of ±0.27", conciliando com as projeções locais. |
| 4b. Numerador | Sem Δln Y no lado direito, Δln W vira +0,026 (p = 0,16); com a inflação do deflator, +0,022 (p = 0,26) e −0,069 (2SLS, p = 0,32). | Muda de sinal e perde significância | A leitura de indexação sai do texto principal. |
| 5. Viés (amostra comum) | Com 311 observações, todas as variantes ficam entre −0,019 e −0,001, a menos de 0,02 de T3, e nenhuma tem p < 0,05. T3 menos a nula com reversão à média: −0,109 [−0,337; 0,097]. | Linhas 1 e 3 | "A sensitivity range of [−0.02; 0.00] on a common sample". A estimativa quinquenal não se distingue do que a contabilidade sozinha produz. Ressalva: na amostra comum, o próprio T3 cai de −0,14 para −0,02. |
| 6. Instituições | Na especificação registrada, a nula reproduz 39% [24%; 53%] (calibrado, com gradiente). Na publicada, 49–73%, conforme o desenho. Tripla interação significativa em 13 de 24 células. | ≥ 33% | Mantém "about half", com o IC. Corrigir a frase sobre o System GMM. |
| 7. Erro de medida | Com o crescimento da PWT, o coeficiente do mesmo ano vai a −0,794 (+10%). Com o PIB do WEO, −0,731 (+1%, mas não é um teste independente). | Mudança < 20% | Citar a verificação: o erro de medida comum não explica o coeficiente. |
| 8. Conferências | Todos os itens foram explicados (ver "Conferência"). Tabelas regeneradas na numeração final, sem rótulos internos. | — | Corrigir os números indicados no texto. |

---

## Bloco 0: registro do plano

**Linha do tempo** (`docs/registration_timeline.md`, também em `registration_osf/`)

| Documento | Commit | Data |
|---|---|---|
| Plano | `2182199cbd7a3a4c775c06f0d5ae01f22c215218` | 17/10/2026 16:16:00 |
| Primeiro adendo | `3faa1ea65b7a1827107b30169962cf81732260ca` | 13/11/2026 17:55:25 |
| Segundo adendo | `be45e06401f466d895f09826b28cfbe909ca2312` | 16/11/2026 13:45:23 |
| Terceiro adendo | `c402c35c7a051094634c5f469ef08ee5539014c9` | 16/11/2026 19:26:08 |

**Do-files da revisão (`code/revisao/`).**
- Os de estimação registrada (02–16) foram commitados entre 16:19:36 e 20:56:59 de 17/10, todos depois do plano.
- Os logs commitados desses blocos foram abertos a partir de 16:19:26.
- A exceção é o `01_auditoria.do`, commitado às 16:14:10. Ele só reproduz as estimativas anteriores, sem estimar nenhuma especificação registrada.

**Código dos adendos 1 e 2 (`code/kyklos/`, `code/kyklos2/`).** Não estão no git. Pelas datas do sistema de arquivos, o primeiro resultado de cada rodada é posterior ao commit do adendo correspondente:
- adendo 1: 17:57:16, contra o commit de 17:55:25;
- adendo 2: 13:47:07, contra o commit de 13:45:23.

Essas datas não são verificáveis pelo git.

**Exceções.** Os commits `dc8cd8f` (7/10) e `781942e` (17/10, 15:57) já traziam especificações anteriores de:
- H1: média quinquenal com a folha no primeiro ano;
- a comparação mesmo ano × medidas predeterminadas, com −0,686 no mesmo ano contra 0,03–0,04 nas predeterminadas;
- H2: decomposição em níveis;
- H3;
- H5;
- H4: L1, tamanho do governo × instituições;
- longo prazo: L2.

As especificações preferidas registradas são outras, mas a primeira redação do prompt ("nenhum resultado registrado anterior ao commit") não é verdadeira.

**Frases para o manuscrito**
- **Section 3.2 e nota 2:** "The hypotheses, preferred specifications and decision rule were written in an analysis plan and committed before any of the estimates reported here (17 October 2026); three dated addenda, each committed before the analyses it covers, specify the replications, simulations and diagnostics. The plan and addenda are deposited at [OSF link]. The exceptions, listed in Section A.8, are earlier specifications of the baseline five-year model, of the comparison between same-year and predetermined measures, of the employment and relative-pay decomposition, of merit moderation, of the political economy of the wage bill, of the interaction between government size and institutions and of the long-run estimators, which had been estimated before the plan; the plan registered different preferred specifications for each."
- **Appendix A.8 (acrescentar):** "The registered simulation of the first addendum, in which the synthetic wage bill follows a random walk from each country's first year, reproduced 5% of the same-year coefficient and did not respond to the elasticity ε. The anchored design and its sanity check were defined in the second addendum after this result had been seen, and the calibrated design in the third; each was registered before it was run. Table A4, panel C, reports the registered design, which the text calls the registered design."

**Depósito na OSF (feito pelos autores; não foi enviado).** O pacote está em `registration_osf/`: PDFs e `.md` do plano e dos adendos, linha do tempo, bundle e README. Passos:
1. Entrar em osf.io e criar um projeto ("Accounting or Averaging Out? Public Wage Bills and Economic Growth – analysis plan").
2. Enviar todos os arquivos de `registration_osf/` para o armazenamento do projeto (OSF Storage).
3. Em "Registrations", escolher o modelo "Open-Ended Registration" (ou "Preregistration", descrevendo o plano como registrado antes das estimações e os adendos como posteriores) e registrar o projeto. Se for o caso, definir o embargo até a publicação.
4. Copiar o DOI gerado para a nota 2 e para a seção 3.2, no lugar de "[OSF link]".
5. Atenção: o bundle traz o nome e o e-mail do autor dos commits. A Kyklos é *single-anonymized*, então isso não fere o anonimato, mas fica público.

---

## Bloco 1: H1, H2 e o tamanho da folha

**O que foi estimado.**
- A folha em t_p − 1, em nível e em log, com os controles e efeitos fixos de T3, em quatro amostras: (a) T3; (b) T3 a partir de 1999; (c) H2 registrada; (d) H2 estrita.
- Em (c) e (d), também a folha do ano do par do WWBI.
- O log foi convertido por ponto do PIB na média da amostra.
- Testes e decomposição por bootstrap de pares (999).

**Números (Tabela A15, painel novo).** Pontos de crescimento por ponto do PIB; IC de 95% agrupado; p de bootstrap selvagem.

| Amostra | Folha em t_p − 1, nível | Folha em t_p − 1, log convertido | Folha do par, nível | Folha do par, log convertido |
|---|---|---|---|---|
| (a) T3 (355) | −0,142 [−0,284; −0,001], p = 0,125 | −0,042 [−0,155; 0,071] | — | — |
| (b) T3 desde 1999 (282) | −0,218 [−0,490; 0,055], p = 0,156 | −0,175 [−0,428; 0,078] | — | — |
| (c) H2 registrada (173 / 199) | **−0,334 [−0,599; −0,070], p = 0,030** | −0,264 [−0,522; −0,005] (p do log 0,076) | −0,646 [−0,902; −0,390], p < 0,001 | −0,565 [−0,828; −0,301] (log −5,227, p = 0,001) |
| (d) H2 estrita (148 / 152) | **−0,382 [−0,683; −0,081], p = 0,036** | −0,294 [−0,571; −0,018] (p do log 0,062) | −0,497 [−0,788; −0,206], p = 0,008 | −0,423 [−0,697; −0,149] (p = 0,010) |

**Decomposição da diferença** entre −0,142 (T3, nível) e −0,565 (H2, par, log convertido). Total: −0,422 [−0,779; −0,095].

| Passo | Variação | Fração do total |
|---|---|---|
| Forma funcional (log − nível, amostra a) | +0,100 [−0,016; 0,171] | −24% |
| Período (desde 1999) | −0,133 [−0,346; 0,127] | 31% |
| Países WWBI (folha em t_p − 1) | −0,089 [−0,380; 0,157] | 21% |
| ***Timing* do par** | −0,301 [−0,614; −0,032] | 71% |

Os testes (a) − (c) dão 0,192 [−0,091; 0,467] em nível e 0,221 [−0,118; 0,509] em log convertido.

**Regras.**
- **Linha 1 não vale.** O log convertido de (a) está dentro do IC de 90% de T3, mas o de (c) com a folha em t_p − 1 (−0,264) não está perto de −0,5.
- **Linha 2 vale.** O *timing* do par responde por 71% da diferença.
- **Linha 3 vale.** Em (c) e (d), a folha em t_p − 1 custa −0,33 e −0,38 ponto por ponto do PIB, com p de bootstrap < 0,05.

**Conclusão.**
- O tamanho em H2 (−0,5) vem sobretudo de medir a folha no ano do par.
- Mesmo com a folha predeterminada em t_p − 1, porém, os países e anos da amostra WWBI mostram um custo de cerca de um terço de ponto.
- A frase "averaging does not conceal a cost" deve sair.

**Frases**
- **Summary:** "In the full five-year sample the predetermined wage bill is not significantly related to growth (−0.14 points per point of GDP); in the countries and years with public employment data, from 1999 on, it is (−0.33, wild-bootstrap p = 0.03), so a moderate cost cannot be excluded."
- **Section 4.3 (H2):** "The size of the wage-bill coefficient in the H2 sample (−5.2 in logs, about −0.57 points per point of GDP) depends on measuring the wage bill in the year of the WWBI pair: with the wage bill in t_p − 1 it is −0.26 per point of GDP in logs and −0.33 in levels, and the timing of the pair accounts for 71% of the difference from the preferred estimate (Table A15)."
- **Section 5:** substituir "averaging does not conceal a cost" por "averaging conceals no cost in the full sample, but the period and countries with public employment data show one of about a third of a point of growth per point of GDP".

---

## Bloco 2: simulação calibrada à persistência observada; sensibilidade a ε

**Origem dos valores de ε.** É uma diferença de amostra, não de especificação.
- **Folha.**
  - 0,48 (`code/revisao/03_vies.do`): Δln da folha nominal sobre Δln do PIB nominal, efeitos fixos de país e ano, 1997–2023 (o primeiro ano se perde ao diferenciar depois de cortar em 1996), 1.774 país-anos: 0,4839.
  - 0,520 (Tabela A3, `code/kyklos/02_outras_razoes.do`): a mesma regressão incluindo 1996, 1.814 país-anos.
- **Consumo.**
  - 0,556: elasticidade na média das instituições na regressão do mecanismo, com a interação com o WGI, 3.708 país-anos com WGI.
  - 0,701 (Tabela A3): sem a interação e sem exigir o WGI, 4.131 país-anos.
- **Frase para as notas da Tabela A4 e da Tabela A13:** "ε = 0.48 is the elasticity of the nominal wage bill to nominal GDP on 1997–2023; the 0.52 of Table A3 is the same regression including 1996. ε_0 = 0.556 is the elasticity of government consumption at mean institutions in the regression with the WGI interaction; the 0.70 of Table A3 omits the interaction and does not require WGI data."

**Desenho calibrado.** Os resíduos sorteados são multiplicados por k.
- Os dois critérios escolhem o menor valor da grade registrada, k = 0,30. O DP dentro do país fica em 0,971, contra 0,976 observado; o AR(1) fica em 0,962, contra 0,970, fora do alcance da grade.
- Por isso os dois desenhos calibrados são praticamente iguais.

**Números (Tabela A4, painéis E–G; Figura 1, nova versão).**

| ε | 0 | 0,25 | 0,48 | 0,52 | 0,71 | 0,75 | 1 |
|---|---|---|---|---|---|---|---|
| Calibrado (DP), mesmo ano | −0,713 | −0,577 | **−0,419 [−0,481; −0,343]** | −0,388 | −0,238 [−0,300; −0,161] | −0,204 | 0,000 [−0,052; 0,055] |
| Fração do observado (−0,723) | 99% | 80% | **58%** | 54% | 33% | 28% | 0% |
| Ancorado (fração) | 29% | 32% | 29% | 28% | 19% | 17% | 0% |
| Registrado (fração) | 4% | 5% | 5% | 5% | 4% | 4% | 3% |

- **Faixa por desenho.**
  - Com ε = 0,48: registrado 5%, ancorado 29%, calibrado 58%, com reversão à média 25%, placebo 102%.
  - Com ε = 0,71: 4%, 19%, 33% e 102%.
- **T3 sob a nula:**
  - calibrado: −0,056 [−0,084; −0,024], 39% do −0,142;
  - com reversão à média: −0,094 (66%).

**Regra.** O calibrado passa de 50% com ε = 0,48 e fica em 33% com ε = 0,71. Resumo: "at least half of the same-year coefficient is accounting". O título continua com pergunta, porque a fração não passa de 50% com ε = 0,71.

**Frases**
- **Summary:** "A zero-effect wage bill calibrated to the observed persistence of the ratio reproduces 58% of the same-year coefficient at the estimated elasticity (33% at 0.71, the elasticity of the wage bill to prices); across simulation designs the share ranges from 5% to 100%, and at least half of the same-year coefficient is accounting at the elasticity estimated in the data."
- **Section 4.2:** "The anchored design is noisier than the data (within-country SD 1.30 against 0.98), which attenuates the simulated coefficient. Scaling its residuals so that the within-country SD of the synthetic ratio matches the observed one, the simulated coefficient is −0.42 (95% simulation interval [−0.48; −0.34]) at ε = 0.48, falls steadily with ε and is zero at ε = 1 (Table A4, panel E; Figure 1)."
- **Section 4.2, corrigir:** a frase que diz que a curva cresce com 1 − ε em todo o intervalo vale para o calibrado. No ancorado, a curva é plana para ε ≤ 0,48.

**Interação institucional (item 5).** Ver Bloco 6.

---

## Bloco 3: Tabela 1 com controles anuais predeterminados

**Números (Tabela A5, linhas novas).** Amostra comum de 1.617 país-anos.

| Versão | Mesmo ano | Defasada | Mesmo ano − defasada [IC bootstrap] | Mesmo ano − Hamilton |
|---|---|---|---|---|
| Controles da Tabela 1 | −0,716 | 0,016 | −0,733 [−1,188; −0,360] | −0,710 |
| (a) Todos em t − 1 | −0,633 | 0,003 | −0,635 [−0,987; −0,318] | −0,744 |
| (b) (a) sem inflação | −0,559 | 0,083 | −0,642 [−0,983; −0,335] | −0,733 |
| (c) (a) sem investimento | −0,629 | −0,001 | −0,628 [−0,987; −0,311] | −0,741 |

Todos os p de bootstrap são < 0,001.

**Regra.** p < 0,01 nas três versões: a verificação é citada no texto principal.

**Frase (Section 4.1):** "With every annual control measured in t − 1, and dropping inflation or investment, the same-year coefficient stays between −0.56 and −0.63 and its difference from the lagged ratio between −0.63 and −0.64 (wild-bootstrap p < 0.001; Table A5)."

---

## Bloco 4: defasagens distribuídas e decomposição sem o resultado no lado direito

**Números (Tabela A4, painéis H–J).**
- **Defasagens:**
  - t − 1: 0,159;
  - t − 2: −0,212;
  - t − 3: −0,001;
  - soma: −0,054 [−0,325; 0,218];
  - efeito de longo prazo: −0,067 [−0,409; 0,275].
- **Painel D publicado:**
  - ln s_{t−1}: −0,024 (p < 0,001);
  - Δln W: −0,062 (p = 0,003).
- **Sem Δln Y:**
  - ln s_{t−1}: +0,004 (p = 0,46);
  - Δln W: +0,026 (p = 0,16).
- **Com a inflação do deflator em t − 1:** Δln W +0,022 (p = 0,26).
- **2SLS:** Δln W −0,069 (p = 0,32), com F efetivo de 4,2.
- **Indexação:** Δln W sobre a inflação de t − 1, 0,353 [0,221; 0,485].
- **Pressão salarial:** a inflação sobre Δln W de t − 1, 0,022 [−0,030; 0,074].

**Por que o nível defasado é significativo no painel D e não na Tabela 1.**
- ln s_{t−1} + Δln W − Δln Y é ln s_t. Com os três termos no lado direito, o painel D reproduz a razão do mesmo ano.
- O coeficiente de ln s_{t−1} (−0,024 por 1%) é o efeito do nível da razão de t que passa por ln s_{t−1}, e não um efeito defasado.
- Sem Δln Y (que contém o crescimento real, a variável dependente), ele desaparece (+0,004). É o mesmo resultado da Tabela 1, onde a razão defasada em nível tem coeficiente −0,001.

**Regras.**
- **Defasagens:** a soma tem IC que contém zero, então "no significant association, CI ±0.27".
- **Numerador:** Δln W muda de sinal e perde significância nas três versões sem Δln Y, então a leitura de indexação sai do texto principal.

**Frases**
- **Section 5:** "The lagged wage bill has no significant association with growth: the sum of three annual lags is −0.05, with a 95% CI of ±0.27 (Table A4). This is consistent with the local projections, whose responses to a wage-bill shock are negative in the first two years and then fade: a shock is a change in the wage bill, not a sustained level, and its cumulative effect cannot be distinguished from zero."
- **Section 4.2:** retirar a frase de indexação. Usar: "The numerator's association with growth in the decomposition depends on having nominal GDP growth, which contains the dependent variable, on the right-hand side; without it the coefficient is positive and insignificant. The wage bill does move with lagged inflation (0.35 per point), but we do not find that it predicts inflation."

---

## Bloco 5: faixa de sensibilidade do viés numa amostra comum

**Números (Tabela A8, painel que substitui o de viés).** Amostra comum de 311 país-períodos.

| Variante | β | p de bootstrap | Diferença de T3 [IC pares] | Observado − nula com reversão | Observado − nula calibrada |
|---|---|---|---|---|---|
| T3 | −0,019 | 0,832 | — | −0,109 [−0,337; 0,097] | 0,010 [−0,074; 0,113] |
| + hiato | −0,001 | 0,993 | 0,018 [−0,009; 0,066] | −0,097 | 0,014 |
| + crescimento de p − 1 | −0,013 | 0,884 | 0,006 [−0,040; 0,054] | −0,117 | −0,011 |
| + ambos | −0,014 | 0,874 | 0,005 [−0,044; 0,059] | −0,118 | −0,012 |
| Hiato negativo (efeito médio, 40% de hiatos negativos) | −0,018 | 0,856 | 0,001 [−0,048; 0,038] | −0,113 | 0,018 |
| 2SLS | −0,002 | 0,981 | 0,017 [−0,068; 0,083] | −0,130 | −0,041 |

- **Deixar um período de fora** (amostra completa de T3): em 2 de 9 períodos o p fica < 0,05.

**Regras.**
- **Primeira linha vale:** todas as variantes ficam a menos de 0,05 de T3 e nenhuma tem p < 0,05.
- **Terceira linha vale:** T3 menos a nula com reversão contém zero.

**Ressalva importante.**
- A amostra comum exige o período anterior e as razões de t_p − 2 e t_p − 3, e perde os primeiros períodos de cada país (311 contra 355). Nela, o próprio T3 é −0,02, não −0,14.
- A faixa [−0,02; 0,00] descreve a sensibilidade às variantes, não a estimativa da amostra completa. O texto deve dizer as duas coisas.

**Frases**
- **Summary e Section 4.3:** "On a common sample of 311 country-periods, controlling for past growth, for the output gap or for both, allowing a different slope after recessions, or instrumenting the wage bill with its earlier values moves the predetermined estimate by less than 0.02 (a sensitivity range of [−0.02; 0.00] on a common sample; Table A8). In that sample the preferred estimate itself is −0.02, against −0.14 in the full sample, and in neither sample can it be distinguished from what a zero-effect wage bill produces through the denominator (observed minus simulated null −0.11, 95% CI [−0.34; 0.10])."
- **Section 4.3, acrescentar:** "Dropping one five-year period at a time, the estimate is significant at 5% in 2 of 9 cases."

---

## Bloco 6: instituições, especificação registrada, GMM e incerteza

**Frações da interação do mesmo ano reproduzidas pela nula** (Tabela A13, linhas novas no painel F). Percentis 2,5–97,5 da fração entre colchetes.

| Desenho | Registrada (aproximada, −0,184) | Publicada (−2,326) | Publicada, em relação ao valor publicado (−0,811) |
|---|---|---|---|
| Ancorado, ε_0 = 0,556, com gradiente | 33% [−3%; 69%] | 57% [38%; 77%] | 164% |
| Ancorado, ε_0 = 0,556, sem gradiente | 19% [−17%; 51%] | 49% [29%; 67%] | 139% |
| Ancorado, ε_0 = 0,701, com gradiente | 34% [1%; 65%] | 43% [24%; 63%] | 123% |
| **Calibrado, ε_0 = 0,556, com gradiente** | **39% [24%; 53%]** | 73% [66%; 79%] | 208% |
| Calibrado, ε_0 = 0,556, sem gradiente | 10% [−6%; 25%] | 65% [58%; 71%] | 186% |
| Calibrado, ε_0 = 0,701, com gradiente | 37% [24%; 52%] | 55% [48%; 62%] | 157% |
| Calibrado, ε_0 = 0,701, sem gradiente | 5% [−9%; 19%] | 47% [39%; 55%] | 135% |

**Leitura.**
- Na especificação publicada, a interação simulada sob a nula é maior que a interação publicada por Mollick e Vianna (−0,811) em todos os desenhos.
- Na registrada, a nula sem gradiente reproduz 5–19%, e com gradiente 33–39%.

**Painel E (tripla interação).**
- 13 das 24 células têm p < 0,05.
- Divisão principal (posterior = 2006–2020): FE 6 de 6; System GMM 1 de 6.
- Divisão alternativa (1996–2020): FE 1 de 6; System GMM 5 de 6.
- A frase "não é significativo com System GMM" está errada: depende da divisão.

**Linhas repetidas.** As linhas "ICRG/QoG 1996–2020" e "common sample" da parte inferior da Tabela A13 são idênticas por construção: todo país-período com ICRG/QoG tem WGI (480 = 480). Não é erro de cópia. Recomenda-se fundir as duas.

**Regra.** A fração registrada (calibrado, com gradiente, ε_0 = 0,556) é 39% ≥ 33%, então "about half" se mantém, com o IC. Observação para os autores: 39% [24%; 53%] fica no limite. A regra mantém a frase, mas "about two fifths" seria mais exato, e a decisão é de vocês.

**Frases**
- **Summary e Section 4.4:** "Under the null of no effect, the elasticity gradient and the timing of consumption reproduce about half of the institutional amplification in the registered specification (39%, 95% simulation interval 24–53%) and between 43% and 73% of it in the published specification, depending on the simulation design; in that specification the simulated interaction exceeds the interaction published by Mollick and Vianna (Table A13, panel F)."
- **Section 4.4, corrigir:** "The difference between periods is significant at 5% in 13 of 24 specifications: in all fixed-effects specifications with the later period starting in 2006 and in most System GMM specifications when the overlapping years are assigned to the later period."

---

## Bloco 7: erro de medida do PIB como terceiro canal mecânico

**Números (Tabela A5, linhas novas).**
- **Crescimento da PWT 11.0, razão original** (1.621 país-anos):
  - mesmo ano −0,794 [−1,111; −0,477], contra −0,723 com o WDI (+9,8%);
  - defasada 0,009; Hamilton −0,033;
  - diferenças −0,803 e −0,761, com p < 0,001.
- **Razão com o PIB do WEO** (compensação das GFS em moeda nacional / NGDP do WEO; 1.611 país-anos): mesmo ano −0,731, contra −0,723 (+1%). As GFS já calculam a razão com o PIB do WEO (mediana da razão entre as duas = 1,000). Este teste é quase tautológico; o informativo é o da PWT.

**Regra.** A mudança é menor que 20% nas duas versões: o erro de medida comum não explica o coeficiente.

**Frase (Section 4.2):** "Measuring growth with the Penn World Table instead of the World Development Indicators, so that growth and the denominator of the ratio come from different sources, changes the same-year coefficient by 10% (−0.79; Table A5): measurement error common to growth and GDP does not explain it."

---

## Bloco 8: conferências e consistência

| Item | No texto | Valor correto | Fonte |
|---|---|---|---|
| Mollick e Cabral: economias | 54 | 54 listadas; **51** no painel anual estimado. CHN, URY e VEN saem porque não têm consumo real do governo, necessário para o placebo. | `conferencia_bloco8_final.csv`, item 1 |
| Mollick e Vianna: países | 137 / 138 / 132 | 138 nomes na lista da Tabela 1 deles; 137 nas regressões publicadas (Tabela 2); 137 encontrados nos dados do projeto (Porto Rico não está); **132** na réplica (dados completos), igual nas três medidas e nos três indicadores. Usar "their 138 listed countries (137 in their estimates)" e "132 in our replication". | item 2 |
| Razão replicado/publicado | 2,5–2,9 | **2,46–2,86** no período inteiro (três indicadores); **2,35–3,15** com os subperíodos. Usar "2.5 to 2.9 for the full period (2.4 to 3.2 including the subperiods)". | item 3 |
| H2 estrita: p com a folha fixa | 0,063 × 0,064 | É a mesma estimativa com sementes de bootstrap diferentes: 0,063 na rodada de 13/11 e 0,064 na de 16/11. Usar 0,063 (Tabela A15). | item 4 |
| H2 estrita: pares | 243 − 63 = 180 × 168 | 180 pares estritos; 12 não têm algum controle, o que dá 168 antes dos *singletons* e 152 na estimação. | item 4 |
| Prêmio salarial | +0,246 / −0,075 | Amostra registrada: +0,246 [−0,075; 0,567], p de bootstrap 0,236 (199 obs.). Estrita: −0,075 [−0,482; 0,331], p = 0,797 (220 obs.). O texto deve dizer a amostra; os dois são nulos. | item 5 |
| F do calendário eleitoral | 2,3 | 2,33 nas democracias (5,31 em todos os país-anos; 3,13 nas democracias antigas; 0,69 nas novas). Acrescentado à nota da Tabela A17. | item 6 |
| θ/5 positivo (1,08) | — | Na amostra de θ, a forma reduzida é negativa (−0,31, p = 0,26) e o primeiro estágio também (−0,058, p = 0,56). A razão de dois negativos é positiva, mas o primeiro estágio é nulo, então θ não tem conteúdo. | item 7 |
| Anos de crescimento negativo | −0,244 | Confere: −0,244 (1.307 obs., Tabela A5). | item 8 |
| Federações (Tabela A11) | — | Geral − central: unitários −0,241 [−0,398; 0,023], p = 0,066; federações +0,112 [−0,348; 1,763], p = 0,665; diferença das diferenças 0,353 (p = 0,226). | `TabS27_coverage.csv` |
| Tabela A10: linhas significativas a 5% | — | 6 de 25: preferida (−0,142, p = 0,049); *timing* convencional (−0,167, p = 0,024); unitários (−0,193, p = 0,029); região × período (−0,152, p = 0,035); PMG anual com a folha defasada (−0,444, p < 0,001); CS-ARDL anual com a folha defasada (+0,997, sinal oposto, p = 0,001). | `Table_A10_robustness_map` |
| Rótulos internos | T2, T3, B1, caminhos | Trocados por descrições em todas as tabelas finais (`output/kyklos3/final/`). A verificação automática encontra 0 ocorrências. | `numeracao_final.py` |

**Frases**
- **Anos de crescimento negativo (Section 4.1 ou nota da A5):** "Excluding years of negative growth reduces the same-year coefficient to −0.24, but this selects on the outcome: dropping recessions truncates the dependent variable precisely where the denominator effect is largest, so the smaller coefficient is not evidence against it."
- **Federações (Section 4.3):** "The difference between the general and the central government wage bill comes from unitary countries (−0.24, p = 0.07); in federations it has the opposite sign and is imprecise (+0.11, 95% CI [−0.35; 1.76]), so we do not attribute it to subnational spending."

**Referências que faltam** (APA 7; conferir volume e páginas no original antes de usar)
- Alesina, A., Favero, C., & Giavazzi, F. (2019). *Austerity: When it works and when it doesn't*. Princeton University Press.
- Breitung, J., Kripfganz, S., & Hayakawa, K. (2022). Bias-corrected method of moments estimators for dynamic panel data models. *Econometrics and Statistics, 24*, 116–132.
- Forum of Federations. (s.d.). *Federal countries*. https://forumfed.org/countries/ (data de acesso a confirmar pelos autores: não está registrada nos arquivos do projeto).
- Gelbach, J. B. (2016). When do covariates matter? And which ones, and how much? *Journal of Labor Economics, 34*(2), 509–543.
- Herbst, E. P., & Johannsen, B. K. (2024). Bias in local projections. *Journal of Econometrics, 240*(1), 105655.
- Montiel Olea, J. L., & Pflueger, C. (2013). A robust test for weak instruments. *Journal of Business & Economic Statistics, 31*(3), 358–369.
- Montiel Olea, J. L., & Plagborg-Møller, M. (2021). Local projection inference is simpler and more robust than you think. *Econometrica, 89*(4), 1789–1823.
- Ramey, V. A., & Zubairy, S. (2018). Government spending multipliers in good times and in bad: Evidence from US historical data. *Journal of Political Economy, 126*(2), 850–901.
- Webb, M. D. (2023). Reworking wild bootstrap-based inference for clustered errors. *Canadian Journal of Economics, 56*(3), 839–858.
- **Bases de dados.** As citações APA, com versão e data de acesso, estão em `replication_kyklos/docs/data_sources.csv`: WDI, GFS, WEO, WWBI, V-Dem, WGI, QoG/ICRG, ICSD, DPI, Polity5 (p5v2018) e PWT 11.0.
  - Acessos: PWT 11.0 em 7/10/2026; GFS e WEO via API em 7/10/2026 e 16/11/2026 (`data/raw/*/_SOURCE.txt`).
  - Estas referências foram escritas de memória e precisam ser conferidas nos originais antes de entrar no manuscrito.

---

## Pendências para os autores

1. **Depositar `registration_osf/` na OSF Registries** (passos no Bloco 0) e copiar o DOI para a nota 2 e para a seção 3.2.
2. **Reescrever as seções** conforme as frases acima: Summary, 1, 3.2, 4.1–4.4, 5, notas 2 e 3, A.8.
   - Decidir entre "about half" (regra) e "about two fifths" (39%) nas instituições.
   - Corrigir a frase do System GMM.
   - Rever o título da Tabela A13 ("explained by timing"), que vem da rodada de 13/11 e conflita com os resultados novos.
3. **Ressalva do Bloco 5:** reportar que na amostra comum o próprio T3 é −0,02, e não só a faixa.
4. **Conferir as referências** da lista acima e a data de acesso do Forum of Federations.
5. **Pendências de rodadas anteriores que seguem abertas:**
   - anos fiscais "não verificado" (CUB, PRK, PSE, XKX);
   - conversão das GFS para ano civil;
   - valores publicados de Mollick e Vianna.
6. **Versionamento do código.** O código das rodadas Kyklos (`code/kyklos*`) não está no git. Se quiserem que o bundle cubra esse código, ele precisa ser commitado. Neste caso, a data do commit será posterior às estimações, e isso deve ser dito.
