# Memorando de resultados: estimações finais para a Kyklos (versão 4)

**Origem dos resultados**
- Execução de `PROMPT_Claude_Code_Kyklos_estimacoes_finais.md`.
- Código: `code/kyklos2/master_kyklos2.do`, Stata 17.
- Plano: segundo adendo, `docs/plan_addendum_kyklos_2.md`, commit `be45e06`, escrito e commitado antes de qualquer estimação.
- Todos os números abaixo vêm dos `.csv` de `output/kyklos2/tables/` e do registro `data/interim/kyklos2/kv.csv`.

**Estatuto das análises.** Tudo aqui é exploratório: "post-plan, pre-registered in addendum 2". Os veredictos registrados (Tabela A19) não mudam.

**Numeração.** A da versão 4: Tabelas 1–3, A1–A19; Figuras 1–4, A1–A6.

## Quadro-resumo

| Bloco | Resultado principal | Regra aplicada (adendo 2) | Decisão para o manuscrito |
|---|---|---|---|
| 1. Simulação sob a nula | A variante ancorada passa no teste de sanidade: inclinação −0,21 [−0,40; −0,03] sobre 1 − ε; média −0,003 em ε = 1. Com ε = 0,48 reproduz 29% do coeficiente do mesmo ano (−0,21 contra −0,72). | Sanidade aprovada e fração entre 20% e 50% | "The denominator accounts for a substantial part". O título com pergunta se mantém. |
| 2. Viés de β (T3) | As variantes vão de −0,18 a 0,00 (2SLS); nenhuma tem p de bootstrap < 0,05. O viés implícito do crescimento passado é −0,03 [−0,09; 0,03]. | A linha 1 não vale (o 2SLS fica fora de [−0,20; −0,08]); a linha 2 também não (nenhuma variante principal fica abaixo de −0,20 com p < 0,05); a linha 3 não vale (o IC de γ × δ contém zero) | O texto atual se mantém: o viés líquido não pode ser assinado. Reporta-se a faixa das variantes. |
| 3a. Oto-Peralías e Romero-Ávila | Tripla interação (FE, média do período, posterior = 2006–2020): −0,55 [−1,06; −0,10], p de bootstrap 0,015. | p < 0,05 | "The mitigation is specific to 1981–2005", com as ressalvas abaixo. |
| 3b. Mollick e Vianna | Interação defasada (GE): −0,11, IC agrupado [−1,17; 0,96], que contém a publicada (−0,81). | O IC não exclui o valor publicado | "The lagged interaction is imprecise and cannot be distinguished from the published one". |
| 4. Interação sob a nula | Com gradiente, a simulação reproduz 57% (−1,33 contra −2,33). O controle, sem gradiente, reproduz 49%; a fração líquida é de 8%. | Fração líquida < 20% (e o controle não fica perto de zero) | "The elasticity gradient is too small to explain the amplification; timing remains a candidate explanation". |
| 5. Ano fiscal | Sem os 9 países de ano fiscal não civil, as diferenças anuais continuam −0,70 (Hamilton) e −0,72 (defasada), com p < 0,001. T3 passa a −0,08. | Sinal mantido e p < 0,01 | A limitação do ano fiscal sai da conclusão, citando a verificação. Convém reportar a mudança de T3. |
| 6. H2 | O salário relativo fica entre −5,44 e −4,30, com p de bootstrap ≤ 0,008 nos modelos (1)–(3) da amostra registrada; Romano-Wolf ≤ 0,006. | p < 0,05 em (1), (2) e (3) | "Survives the reverse-denominator check". |
| 7. Projeções locais | θ/5 do choque (a) = 1,08 [−1,13; 3,30], com F do primeiro estágio 0,34. Os choques (a) e (c) quase não movem a folha depois do primeiro ano (≈0,17 ponto por ponto de choque). | O efeito médio cai fora do IC de 90% de T3 [−0,26; −0,02] | Reportar a discrepância e explicar que a tradução não é informativa (instrumento fraco); a frase "small and short-lived" se apoia nas projeções em forma reduzida. |
| 8. Conferência | Das contagens, 4 de 5 fecham; o DP 0,97 × 0,98 é diferença de amostra e foi harmonizado. Dos números do texto, 51 de 52 conferem; não confere "−0,12 (p = 0,146)". | — | Trocar o painel B da A2 e corrigir a frase do −0,12. |

---

## Bloco 1: simulação sob a hipótese nula e reconciliação com o placebo

**O que foi estimado**
- **Folha sintética.** Uma razão folha/PIB sem efeito sobre o crescimento, em três desenhos, mantendo PIB, crescimento e controles observados.
  - **Ancorado (principal):** a razão de t parte da razão observada de t − 1, cai com o PIB nominal na proporção (1 − ε) e recebe um choque sorteado dos resíduos do próprio país, recentrados em zero. ε ∈ {0; 0,25; 0,48; 0,75; 1}, 1.000 replicações cada.
  - **Estacionário:** reversão à média do país, ρ = 0,870 (AR(1) dentro do país do log da razão observada), ε = 0,48.
  - **Registrado:** o passeio aleatório da versão anterior da Tabela A5, rodado na mesma grade.
- **Regressões em cada replicação:** as anuais da Tabela 1 (mesmo ano, Hamilton, HP unilateral, defasada) e T3.
- **Decomposição direta e placebo.** Decomposição do coeficiente observado em ln s_{t−1}, Δln W e Δln Y, mais a correlação de cada série com o placebo.

**Números principais (Tabela A5, nova; Figura A3, nova)**

Desenho ancorado, coeficiente anual do mesmo ano (observado −0,723):

| ε | Média | Intervalo 2,5–97,5 | Fração do observado |
|---|---|---|---|
| 0 | −0,208 | [−0,400; −0,075] | 29% |
| 0,25 | −0,233 | [−0,391; −0,105] | 32% |
| 0,48 | −0,213 | [−0,334; −0,074] | 29% |
| 0,75 | −0,119 | [−0,261; 0,002] | 16% |
| 1 | −0,003 | [−0,145; 0,102] | 0% |

- **Teste de sanidade:** aprovado nas duas condições.
  - A inclinação da média sobre (1 − ε) é −0,211, intervalo [−0,399; −0,033].
  - Em ε = 1, |média| = 0,003 ≤ 0,072 (10% do observado), e o intervalo contém zero.
  - A média cresce até ε = 0,48 e se estabiliza abaixo disso; a relação não é linear.
- **Série sintética × observada (ε = 0,48):** DP dentro do país 1,30 contra 0,98; AR(1) 0,88 contra 0,97; correlação com o placebo 0,95 (a do placebo com a razão observada é 0,98).
- **Outras medidas (ε = 0,48):**
  - Hamilton: +0,13. Em todas as grades a média simulada tem sinal oposto ao da medida observada (−0,016); a fração não é informativa.
  - HP unilateral: −0,06 (14% de −0,42).
  - Defasada: −0,06 (observado −0,001).
  - T3: −0,037 (26% de −0,142), quase igual em todo ε. Isso vem da ancoragem na razão observada de t_p − 2, não do denominador.
- **Desenho estacionário (ε = 0,48):**
  - mesmo ano −0,180 [−0,356; −0,019], 25% do observado;
  - **T3 −0,094 [−0,166; −0,018], 66% do observado**, que fica dentro do intervalo;
  - é o desenho que mais se parece com a série observada: DP 1,10, AR(1) 0,964.
- **Desenho registrado:** 3–5% do coeficiente do mesmo ano em qualquer ε; inclinação −0,008 [−0,129; 0,092]. A série continua não estacionária: DP dentro do país de 2,7 a 48,7 e AR(1) acima de 1.
- **Decomposição direta (modelo anual da Tabela 1, Driscoll-Kraay).** Coeficientes por 1% de cada componente:
  - 100 × ln s_{t−1}: −0,024 [−0,034; −0,014];
  - 100 × Δln W: −0,062 [−0,101; −0,024], p = 0,003;
  - 100 × Δln Y nominal: +0,499. É mecânico, porque o crescimento real está dentro do nominal.
  - A inovação do numerador (Δln W − 0,48 Δln Y) tem covariância −1,58 com o crescimento (correlação −0,09), líquida de efeitos de país e ano.
- **Δln W sobre o crescimento real:**
  - sem o PIB nominal: 0,16 (t, p = 0,22), 0,16 (t − 1) e 0,39 (t − 2, p < 0,001);
  - mantido fixo o PIB nominal: −0,47 (t, p = 0,001), 0,16 e 0,33.
  - Leitura: o numerador responde ao ciclo real com defasagem e, no próprio ano, se move contra o crescimento real dado o nominal.

**Por que o placebo e a simulação dão frações diferentes**
- **Placebo.** Seu numerador é a folha real do ano anterior, crescida à taxa média do país. Ele não tem variação própria de ano a ano: toda a variação da razão placebo vem do PIB corrente, sobre um nível que é a razão observada de t − 1. Por isso a correlação com a razão observada é 0,98 e o coeficiente reproduz o observado (−0,734 contra −0,723). É o caso-limite em que o numerador é inerte.
- **Simulação ancorada.** Acrescenta ao numerador a variação de ano a ano que ele tem nos dados (os resíduos sorteados), independente do crescimento sob a nula. Essa variação é ruído do ponto de vista da regressão e atenua o coeficiente, como um erro de medida clássico: o DP dentro do país sobe de 0,98 para 1,30, e a correlação com o placebo cai para 0,95.
- **O que fica entre os dois.** O que separa 29% de 100% é a covariância observada entre a variação própria do numerador e o crescimento. A simulação a retira por construção (resíduos recentrados e sorteados independentemente); a decomposição mostra que ela é negativa: dado o PIB nominal, o numerador cresce menos nos anos de crescimento real alto. Essa parte do coeficiente não é contábil no sentido do denominador; vem do comportamento do numerador no próprio ano.

**Regra (adendo 2) e conclusão.** A variante ancorada passa no teste de sanidade e reproduz entre 20% e 50% (29%). O manuscrito diz que o denominador responde por uma parte substancial do coeficiente, e o título continua com a pergunta.

**Frases para a versão 4**
- **Summary:** "A simulation in which the wage bill has no effect on growth, anchored on each country's observed wage bill ratio and with the elasticity of the wage bill to nominal GDP estimated in the data, reproduces 29% of the same-year coefficient: the denominator accounts for a substantial part of it, but not for most of it."
- **Section 1 (contribuições):** "Third, we show how much of the same-year coefficient is accounting. A zero-effect wage bill reproduces 29% of it, and the share rises with the gap between the elasticity of the wage bill to GDP and one, as the accounting argument predicts."
- **Section 4.2:** "When the synthetic ratio starts from the observed ratio of the previous year and moves with nominal GDP with elasticity ε, the simulated same-year coefficient grows with 1 − ε, from −0.003 at ε = 1 to −0.21 at the estimated ε = 0.48 (95% simulation interval [−0.33; −0.07]), 29% of the observed −0.72 (Table A5, panel A; Figure A3). The placebo, whose numerator does not vary from year to year, reproduces the whole coefficient; the simulation adds the numerator's own year-to-year variation, which under the null is unrelated to growth and attenuates the coefficient. What separates the two is how the numerator moves within the year: for given nominal GDP, faster growth of the wage bill goes with slower real growth (−0.06 percentage points per 1% of wage-bill growth, 95% CI [−0.10; −0.02]; Table A5, panel D). The denominator therefore accounts for a substantial part of the same-year coefficient, and the behaviour of the numerator within the year for much of the rest."
- **Section 4.1 (ou nota da Tabela A9):** "A mean-reverting zero-effect wage bill, whose persistence and within-country variance are closest to the data, produces a five-year coefficient of −0.09 (95% simulation interval [−0.17; −0.02]), which contains the observed −0.14: even the predetermined estimate is within what accounting alone can generate."
- **Section 5:** substituir "the decomposition remains open" por "the denominator accounts for a substantial part of the same-year coefficient, about 30% in a calibrated simulation".

---

## Bloco 2: sinal e limites do viés da estimativa predeterminada

**O que foi estimado.** T3 (N = 355) com:
- o hiato de Hamilton em t_p − 1;
- o crescimento de p − 1, com e sem o hiato;
- um indicador de hiato negativo interagido com a folha;
- 2SLS com as razões de t_p − 2 e t_p − 3 como instrumentos;
- Gelbach;
- γ × δ;
- a versão anual com W_{t−1}/Y*_{t−1}.

**Números (Tabela A11, painel novo).** IC e p de bootstrap selvagem por país, Webb, 9.999 replicações.

| Variante | β | IC 95% (bootstrap) | p de bootstrap | Obs. |
|---|---|---|---|---|
| T3 (referência) | −0,142 | [−0,292; 0,037] | 0,124 | 355 |
| (1) + hiato em t_p − 1 | −0,143 | [−0,294; 0,047] | 0,142 | 355 |
| (2a) + crescimento de p − 1 | −0,108 | [−0,241; 0,044] | 0,154 | 342 |
| (2b) + crescimento de p − 1 + hiato | −0,105 | [−0,235; 0,037] | 0,132 | 342 |
| (3) hiato positivo / interação / depois de hiato negativo | −0,181 / 0,089 / −0,092 | [−0,323; 0,025] / [−0,038; 0,212] / [−0,240; 0,050] | 0,086 / 0,165 / 0,202 | 355 |
| (4) 2SLS | 0,002 | [−0,175; 0,158] | 0,974 | 324 |
| (7) anual, W_{t−1}/Y*_{t−1} sem / com hiato | −0,081 / −0,036 | [−0,283; 0,127] / [−0,263; 0,208] | 0,426 / 0,784 | 1.621 |

- **Diagnósticos do 2SLS:** F efetivo de Montiel Olea-Pflueger 461,7; p de Hansen J 0,893; IC de Anderson-Rubin [−0,186; 0,202].
- **Gelbach**, mudança de −0,035: −0,034 vem do crescimento de p − 1 e −0,000 do hiato.
- **Conta do viés:**
  - γ = 0,096 [−0,044; 0,219];
  - δ = −0,067 [−0,259; 0,082];
  - γ × δ = −0,006 [−0,040; 0,009];
  - viés de variável omitida na unidade de β (γ_longo × π): −0,032 [−0,086; 0,030], igual à diferença observada.
- **Nota:** o p de bootstrap de T3 aqui (0,124) difere do registrado (0,120) só pela semente.

**Regra e conclusão**
- **Primeira linha:** não vale, porque o 2SLS (0,002) fica fora de [−0,20; −0,08].
- **Segunda linha:** não vale. Nenhuma variante principal fica abaixo de −0,20; a menor é −0,18, no item 3, que não é principal e tem p = 0,086.
- **Terceira linha:** não vale, porque o IC de γ × δ contém zero.
- **Conclusão:** pelo adendo, o texto atual se mantém (o viés líquido não pode ser assinado) e a faixa das variantes é reportada. Nenhuma variante sugere custo moderado.

**Frase para a versão 4**
- **Section 4.1:** "We cannot sign the remaining bias, but we can bound it: controlling for growth in the previous period or for the output gap in t_p − 1 moves the predetermined estimate to between −0.18 and −0.10, instrumenting the ratio in t_p − 1 with the ratios two and three years earlier moves it to 0.00 (effective F = 462), and no variant has a wild-bootstrap p below 0.05 (Table A11). The bias implied by past growth is −0.03 (95% CI [−0.09; 0.03])."

---

## Bloco 3: testes formais nas réplicas institucionais

**O que foi estimado**
- **Oto-Peralías e Romero-Ávila.**
  - Painel quinquenal único, 1981–2020, com o índice ICRG/QoG. A tripla interação é consumo × instituições × período posterior.
  - Período posterior: 2006–2020 na versão principal; 1996–2020 na alternativa, com a sobreposição atribuída ao período posterior.
  - Três medidas de timing, FE com bootstrap e System GMM, também só com os países presentes nos dois períodos.
- **Mollick e Vianna.**
  - IC de 95% (White e agrupado) das interações defasada e sobre o PIB tendencial, na especificação publicada.
  - Indicadores GE, CC e RL, comparados com as interações publicadas: −0,811, −0,814 e −0,835.
  - Equivalência a ±0,5 e ±1,0, em relação ao valor publicado e a zero.

**Números (Tabela A15, painel E; Tabela A16, linhas novas)**
- **Oto-Peralías e Romero-Ávila, FE, média do período.**
  - A interação é 0,31 até 2005 e −0,24 depois.
  - Tripla interação: −0,553, IC de bootstrap [−1,064; −0,103], p = 0,015.
- **Mesma divisão, outras medidas e amostras:**
  - t_p: −0,512 (p = 0,019); t_p − 1: −0,442 (p = 0,029);
  - só países nos dois períodos: −0,529 (p = 0,031).
- **System GMM:** −1,34 (p = 0,12, média do período). É impreciso; só com os países dos dois períodos fica significativo em t_p.
- **Divisão alternativa (1996–2020 como posterior):** média do período −0,596 (p = 0,029), mas t_p −0,156 (p = 0,65) e t_p − 1 0,158 (p = 0,69).
- **Mollick e Vianna, GE.**
  - Interação defasada: −0,107; IC agrupado [−1,174; 0,961]; IC White [−1,255; 1,042]. Contém −0,811.
  - Sobre o PIB tendencial: −0,039 [−1,048; 0,970].
- **CC:** defasada 0,052 [−1,107; 1,211]; tendencial 0,191 [−0,994; 1,376].
- **RL:**
  - defasada −0,013 [−1,159; 1,132];
  - tendencial 0,272 [−0,831; 1,374]. Este IC exclui o −0,835 publicado por 0,004.
- **Equivalência:** nenhuma interação defasada ou tendencial é equivalente à publicada a ±0,5 ou a ±1,0. São equivalentes a zero a ±1,0 só a defasada de RL e a tendencial de GE.

**Regra e conclusão**
- **Oto-Peralías e Romero-Ávila:** a tripla interação tem p < 0,05, então "the mitigation is specific to 1981–2005". O resultado vale na divisão registrada e nas três medidas por FE. Não vale no System GMM, e só a média do período sobrevive na divisão alternativa. Convém dizer isso.
- **Mollick e Vianna:** o IC não exclui o valor publicado, então "the lagged interaction is imprecise and cannot be distinguished from the published one".

**Frases para a versão 4**
- **Section 4.5:**
  - "In a single five-year panel for 1981–2020, the mitigating interaction of Oto-Peralías and Romero-Ávila is 0.31 before 2006 and −0.24 afterwards; the difference is significant with fixed effects (−0.55, wild-bootstrap 95% CI [−1.06; −0.10]) for all three timings of consumption, but not with System GMM (Table A15, panel E). The mitigation is specific to 1981–2005."
  - "With the published specification of Mollick and Vianna, the interaction with lagged consumption is −0.11 (clustered 95% CI [−1.17; 0.96]), and the interaction with consumption over trend GDP −0.04 ([−1.05; 0.97]); both intervals contain the published −0.81. The lagged interaction is imprecise and cannot be distinguished from the published one (Table A16)."
  - Substituir "shrinks with lagged consumption" por "is imprecisely estimated with lagged consumption".

---

## Bloco 4: interação institucional sob a hipótese nula

**O que foi estimado**
- **Consumo sintético ancorado**, sem efeito sobre o crescimento, com elasticidade ao PIB nominal ε_it = ε_0 + ε_1 × WGI_{i,t−1}.
  - ε_0 = 0,556 e ε_1 = −0,180, reestimados com o mecanismo da Tabela A15, com o índice médio do WGI centrado.
  - Controle: ε_1 = 0.
  - 1.000 replicações cada.
- **Especificações estimadas em cada replicação:** a publicada (Tabela A14, painel D, GE, 3.108 observações) e a aproximada (painel C), com o consumo do mesmo ano, defasado e sobre o PIB tendencial.

**Números (Tabela A15, painel F; Figura A3, painel c)**

| Especificação | Observada | Com gradiente [2,5–97,5] | Fração | Sem gradiente [2,5–97,5] | Fração | Fração líquida |
|---|---|---|---|---|---|---|
| Publicada, mesmo ano | −2,326 | −1,328 [−1,780; −0,885] | 57% | −1,131 [−1,568; −0,666] | 49% | 8% |
| Aproximada, mesmo ano | −0,184 | −0,060 [−0,128; 0,006] | 33% | −0,034 [−0,095; 0,031] | 19% | 14% |

- As interações observadas ficam fora dos intervalos simulados.
- Com o consumo defasado ou sobre o PIB tendencial, os intervalos simulados da especificação publicada contêm zero e o valor observado, nos dois desenhos (Tabela A15, painel F).

**Regra e conclusão**
- A simulação com gradiente reproduz mais de 50%, mas o controle não fica perto de zero (49%). Pela definição do adendo, a decisão é lida na fração líquida, de 8% (< 20%).
- Decisão: "the elasticity gradient is too small to explain the amplification; timing remains a candidate explanation".
- **Achado não previsto na regra.** Sob a nula, só o timing do mesmo ano, mesmo com elasticidade constante, gera cerca de metade da interação publicada. Isso reforça o timing como candidato, mas não pela via do gradiente.

**Frase para a versão 4**
- **Section 4.5:** "A zero-effect consumption series whose elasticity to nominal GDP falls by 0.18 per unit of the WGI reproduces 57% of the same-year interaction of the published specification (−1.33 against −2.33), but the same series with a constant elasticity already reproduces 49% (Table A15, panel F; Figure A3c). The elasticity gradient is too small to explain the amplification; timing remains a candidate explanation, since same-year timing alone produces about half of the published interaction when consumption has no effect on growth."

---

## Bloco 5: ano fiscal diferente do ano civil

**O que foi estimado**
- **Lista.** Segundo o WEO (atributo "start/end months of reporting year" da despesa do governo geral), 32 países (22 não microestados) têm ano de referência não civil. Arquivo: `data/raw/fiscal_year/fiscal_year_by_country.csv`.
- **Países na amostra da Tabela 1:** EGY, HKG, IRN, LSO, MUS, NPL, RWA, SGP e THA.
- **Exclusão:** Tabela 1 (anual e quinquenal) e T3 sem esses países.
- **Realinhamento:** média ponderada dos dois anos fiscais nos países com início entre abril e setembro.
- **Teste:** diferenças em modelos empilhados com bootstrap.

**Números (Tabela A6, linhas novas)**
- **Sem os países:**
  - mesmo ano −0,701 [−0,974; −0,427]; Hamilton 0,001; defasada 0,023;
  - diferenças −0,701 (mesmo ano − Hamilton) e −0,724 (mesmo ano − defasada), p de bootstrap < 0,001.
- **Realinhado:** mesmo ano −0,726; diferenças −0,713 e −0,711, p < 0,001.
- **Diferenças em relação à amostra completa:**
  - mesmo ano 0,022 (p = 0,59);
  - T3 0,061 [−0,036; 0,178] (p = 0,48).
  - T3 passa a −0,081 [−0,222; 0,059] sem os países, e a −0,073 com o realinhamento.
  - A média quinquenal passa de −0,285 a −0,245 (sem os países) e a −0,268 (realinhado).

**Regra e conclusão.** As diferenças do mesmo ano para as medidas predeterminadas mantêm o sinal, com p < 0,01, sem os países. Pela regra, a limitação do ano fiscal sai da conclusão e a verificação é citada.
- Ressalva honesta: o T3 cai à metade sem esses 6 países (de 68), embora a diferença não seja significativa. Isso cabe numa frase na seção 4.1.
- Pendência: a conversão das GFS para ano civil não pôde ser verificada (ver Pendências).

**Frases para a versão 4**
- **Section 5 (limitações):** retirar a frase sobre o ano fiscal e pôr: "The same-year bias does not come from fiscal years: excluding the nine countries whose general government reports on a non-calendar fiscal year, or realigning the fiscal years that start between April and September, leaves the same-year coefficient at −0.70 and −0.73 and its differences from the predetermined measures significant (p < 0.001; Table A6)."
- **Section 4.1:** "Without these countries the predetermined five-year estimate is −0.08 (95% CI [−0.22; 0.06]); the change, 0.06, is not significant (p = 0.48)."

---

## Bloco 6: H2 com controle para o canal reverso do denominador

**O que foi estimado.** O modelo em log, nas amostras registrada (Tabela 3, col. 3) e estrita (Tabela A17), com:
- (1) crescimento de p − 1;
- (2) hiato em t_p − 1;
- (1) e (2) juntos;
- (3) salário relativo sobre o PIB real por trabalhador do ano anterior ao par;
- (4) salário relativo com a folha fixa, mais (1) e (2).

Romano-Wolf na família registrada, com H2 substituída pelos modelos (1) e (2).

**Números (Tabela A17, colunas novas)**

| Amostra | Log (ref.) | (1) | (2) | (1)+(2) | (3) | Folha fixa | (4) |
|---|---|---|---|---|---|---|---|
| Registrada: coeficiente | −5,393 | −5,201 | −5,321 | −5,438 | −4,303 | −1,680 | −1,737 |
| Registrada: p de bootstrap | < 0,001 | < 0,001 | 0,001 | < 0,001 | 0,008 | 0,016 | 0,014 |
| Estrita: coeficiente | −4,381 | −3,773 | −4,699 | −4,303 | −3,690 | −1,858 | −1,987 |
| Estrita: p de bootstrap | 0,006 | 0,015 | 0,014 | 0,009 | 0,022 | 0,064 | 0,070 |

- Romano-Wolf de H2: 0,002 (registrado), 0,006 com (1) e 0,004 com (2).
- Observações: 199 (57 países) na amostra registrada; 152 (49) na estrita.

**Regra e conclusão.** O coeficiente mantém p de bootstrap < 0,05 em (1), (2) e (3) na amostra registrada: "survives the reverse-denominator check". Com a folha fixa, o coeficiente continua significativo na amostra registrada, mas não na estrita (p de 0,064 e 0,070), como já era.

**Frase para a versão 4**
- **Section 4.4:** "The relative-wage result survives the reverse-denominator check: adding growth in the previous period or the output gap in t_p − 1, or dividing the public wage by GDP per worker of the year before the pair, leaves the coefficient between −5.44 and −4.30 in the registered sample (wild-bootstrap p ≤ 0.008; Romano–Wolf p ≤ 0.006) and between −4.70 and −3.69 in the strict-timing sample (p ≤ 0.022; Table A17)."

---

## Bloco 7: efeito acumulado das projeções locais

**O que foi estimado.** Com os choques (a), (b) e (c) da Tabela A18 (painel anual 1996–2023, efeitos fixos de país e ano, duas defasagens do choque e do crescimento):
- a resposta da própria folha;
- o multiplicador integral de Ramey-Zubairy, em LP-IV: soma da resposta do PIB per capita sobre a soma da resposta da folha, instrumentada pelo choque, com IC de Driscoll-Kraay e F de Kleibergen-Paap;
- θ, o efeito em nível em h = 5 por ponto de folha mantido, e θ/5, o efeito médio sobre o crescimento anual.

No choque (b), os IC são percentis de um bootstrap por blocos que refaz a purga (999 replicações).

**Números (Tabela A18, painel C)**
- **Resposta da folha ao choque (a)** (pontos do PIB, base t − 2): 0,19 [−0,06; 0,45] em h = 0 e entre 0,16 e 0,19 de h = 1 a h = 6, com p entre 0,03 e 0,08. Um choque de 1 ponto datado em t − 1 deixa a folha só cerca de 0,17 ponto acima nos anos seguintes: quase todo o choque se desfaz em um ano. O choque (c) se comporta igual (0,14–0,20). O choque (b) persiste: 1,04 em h = 0 e 0,71 em h = 6.
- **Multiplicador integral:**
  - choque (a): 0,59 [0,10; 1,09] em h = 0 (F = 2,3) e 0,77 [0,13; 1,41] em h = 1 (F = 1,1); a partir de h = 2, F < 0,3 e IC sem informação;
  - choque (b): F de 62, 55, 30 e 18 de h = 0 a 3, com multiplicador −0,30 [−0,58; 0,04], 0,56 [0,40; 0,71], 0,86 [0,51; 0,97] e 0,85 [0,34; 0,95]; F < 5 a partir de h = 4;
  - choque (c): F < 1,5 em todos os horizontes.
- **θ/5 (efeito médio sobre o crescimento anual em cinco anos, por ponto de folha mantido):**
  - (a): 1,08 [−1,13; 3,30], F = 0,34;
  - (b): −0,58 [−4,69; 7,61], F = 2,7;
  - (c): 0,67 [−0,83; 2,17], F = 0,80.
  - Dividindo por 6 (seis anos de crescimento entre t − 1 e t + 5), os valores ficam 5/6 do tamanho (0,90 no choque (a)).
- **Comparação:** T3 é −0,142, IC de 90% [−0,261; −0,024]. Os três IC de θ/5 contêm o T3 e o zero.

**Regra e conclusão.** θ/5 do choque (a) (1,08) cai fora do IC de 90% de T3. Pela regra, reporta-se a discrepância e discute-se a diferença de horizonte.
- A discrepância não é evidência contra T3: os primeiros estágios são fracos (F < 3 nos três choques em h = 5), e os IC contêm o T3.
- O problema de fundo é que os choques datados em t − 1 quase não movem a folha depois do primeiro ano. Por isso não há como traduzir a projeção local em "efeito por ponto de folha mantido".
- A frase da conclusão deve se apoiar nas respostas em forma reduzida da Tabela A18, que já estão no texto.

**Frase para a versão 4**
- **Section 5 (conclusão):** "The local projections cannot be put in the five-year metric: a wage-bill shock dated t − 1 leaves the wage bill only about 0.17 points of GDP higher after the first year, so the instrumented cumulative effect per point of wage bill maintained has a first-stage F below 3 and a confidence interval that contains both zero and the five-year estimate (Table A18, panel C). The reduced-form responses show a fall in GDP per capita in the two years after the shock (−0.21 and −0.34 points per point of GDP of shock), which fades afterwards; we read them as a small and short-lived response to a shock that is itself short-lived, not as an estimate of the effect of a permanently larger wage bill."
- **Section 4.6:** acrescentar "Translated into the metric of T3, the dynamic estimates are uninformative (average effect on annual growth over five years 1.08 per point of wage bill maintained, 95% CI [−1.13; 3.30], first-stage F = 0.34)."

---

## Conferência (Bloco 8)

**Contagens (itens 1–5, `conferencia_bloco8.csv`)**

1. **DP dentro do país da folha anual: 0,97 (A2) × 0,98 (A5).** É diferença de amostra, não de definição nem de arredondamento.
   - O painel B da Tabela A2 usa `S1_base` (1.593 país-anos), que tem 28 país-anos a menos que a amostra da Tabela 1 (1.621).
   - Na amostra da Tabela 1 o DP dentro é 0,976; em `S1_base`, 0,970.
   - **Harmonização:** `Table_A2_panel_B_harmonized` recalcula o painel B nos 1.621 país-anos. Basta trocar o painel B e usar 0,98 nas duas tabelas.
2. **Federações.**
   - Antes dos singletons, a amostra comum geral × central tem 13 federações, 66 unitários, 79 países e 351 observações.
   - Na estimação ficam 12 federações (72 observações) e 52 unitários (264 observações). Total: 64 países e 336 observações. **Confere.**
3. **Tabela A2.** A amostra de T3 tem 68 países: 6 de renda baixa, 23 de renda média-baixa, 12 de renda média-alta e 27 de renda alta (grupos 1–4). A folha em t_p − 1 tem média 9,548 (9,55%) e DP dentro de 1,324 (1,32). **Confere.**
4. **Mollick e Vianna.**
   - 3.113 é a amostra própria com GE (Tabela A16, painel B; interação −2,317).
   - 3.108 é a amostra comum às três medidas de consumo (Tabela A14, painel D; interação −2,326).
   - A amostra comum alimenta todos os números do painel D da A14, as diferenças da A15 (Bloco 8 do prompt anterior) e os Blocos 3 e 4 deste prompt. **Confere.**
5. **H2.** O coeficiente do log da folha na amostra da Tabela 3, coluna 3, é −5,227 (199 observações). **Confere.** O do salário relativo é −5,393.

**Números do manuscrito (item 6, `conferencia_manuscrito.csv`)**

| Tabela | Número no texto | Fonte | Valor no csv | Situação |
|---|---|---|---|---|
| Tabela 1 | −0,72 | TabS20 (wb, m1) = Tabela 1, mesmo ano: b | −0,72 | confere |
| Tabela 1 | [−1,01; −0,44] | idem: IC de 95% | −1,01; −0,44 | confere |
| Tabela 1 | −0,02 | TabS20 (wb, m3): Hamilton | −0,02 | confere |
| Tabela 1 | −0,001 | TabS20 (wb, m5): defasada | −0,001 | confere |
| Tabela 1 | −0,42 | TabS20 (wb, m4): HP unilateral | −0,42 | confere |
| Tabela 1 | 0,965 | kv revisao corr_lag_ham | 0,965 | confere |
| Tabela A6 | 0,86 | kv kyklos ver_corr_hp1 | 0,85 | confere |
| Tabela A6 | 0,08 | kv kyklos ver_corr_ham | 0,08 | confere |
| Tabela A6 | −0,40 | TabS28 rec_neg: b | −0,40 | confere |
| Tabela A6 | −0,89 | TabS28 rec_pos: b | −0,89 | confere |
| Tabela A6 | −0,13 | TabS28 antic: b | −0,13 | confere |
| Tabela A5 | −0,20 | kv kyklos sim_logdec_eff | −0,20 | confere |
| Tabela A5 | [−0,36; −0,04] | kv kyklos sim_logdec_lo/hi | −0,36; −0,04 | confere |
| Tabela A8 | −0,32 | TabS21 g, wb_mean, controles em t_p − 1 | −0,32 | confere |
| Tabela A8 | −0,22 | TabS21 g, wb_tp, controles em t_p − 1 | −0,22 | confere |
| Tabela A8 | −0,16 | TabS21 g, wb_m1, controles em t_p − 1 | −0,16 | confere |
| Tabela A8 | −0,15 | TabS21 g, wb_ham_m1, controles em t_p − 1 | −0,15 | confere |
| Tabela A8 | −0,18 | TabS21 g, wb_tp, controles da média | −0,18 | confere |
| Tabela A8 | −0,10 | TabS21 g, wb_m1, controles da média | −0,10 | confere |
| Tabela A8 | 29% | kv kyklos grid_red (×100) | 29 | confere |
| Tabela A8 | 45% | kv kyklos grid_red_meanctrl (×100) | 45 | confere |
| Tabela A8 | investimento −0,10 → −0,16 | TabS21 wb_m1 controles da média → troca do investimento | −0,10; −0,16 | confere |
| Tabelas A9/A10 | T3 −0,14 | TabS25_equivalence T3: b | −0,14 | confere |
| Tabelas A9/A10 | EP 0,071 | TabS25_equivalence T3: se | 0,071 | confere |
| Tabelas A9/A10 | p de bootstrap 0,120 | kv revisao T3_own_pboot | 0,120 | confere |
| Tabelas A9/A10 | Romano-Wolf 0,426 | kv revisao rw_H1 | 0,426 | confere |
| Tabelas A9/A10 | [−0,26; −0,02] (IC 90) | TabS25_equivalence T3: lo90/hi90 | −0,26; −0,02 | confere |
| Tabelas A9/A10 | MDE 0,20 | TabS25_equivalence T3: mde | 0,20 | confere |
| Tabelas A9/A10 | −0,08 (desde 1994) | TabS25_influence early (excl. 1979–1993): b | −0,08 | confere |
| Tabelas A9/A10 | 32 de 68 | TabS25_influence: amostras sem um país com p < 0,05 (de 68) | 32; 68 | confere |
| Tabelas 2/A13 | −0,14 | TabS27 b_all_gg: est | −0,14 | confere |
| Tabelas 2/A13 | [−0,29; 0,03] | TabS27 b_all_gg: lo/hi | −0,29; 0,03 | confere |
| Tabelas 2/A13 | 0,03 | TabS27 b_all_cg: est | 0,03 | confere |
| Tabelas 2/A13 | [−0,20; 0,26] | TabS27 b_all_cg: lo/hi | −0,20; 0,26 | confere |
| Tabelas 2/A13 | −0,17 (p = 0,066) | TabS27 d_all: est e p | −0,169; 0,066 | confere |
| Tabelas 2/A13 | 0,353 (p = 0,226) | TabS27 did: est e p | 0,353; 0,226 | confere |
| Tabelas A14/A15 | −2,33 | kv revisao mvf_ge_full_common_c_bX | −2,33 | confere |
| Tabelas A14/A15 | −0,04 | kv revisao mvf_ge_full_common_h_bX | −0,04 | confere |
| Tabelas A14/A15 | −0,11 | kv revisao mvf_ge_full_common_l_bX | −0,11 | confere |
| Tabelas A14/A15 | −0,20 (p = 0,011) | TabS26_inst_differences C, lag: d e p | −0,198; 0,011 | confere |
| Tabelas A14/A15 | −0,12 (p = 0,146) | TabS26_inst_differences C, trend: d e p (texto: −0,12) | −0,063; 0,146 | conferir: −0,063; 0,146 |
| Tabelas A14/A15 | elasticidade −0,18 | TabS26_inst_mechanism a, dlC, inst: b | −0,18 | confere |
| Tabelas A14/A15 | elasticidade −0,16 | TabS26_inst_mechanism a, dlW, inst: b | −0,16 | confere |
| Tabelas 3/A17 | −3,71 | TabS22 reg, lpe: b | −3,71 | confere |
| Tabelas 3/A17 | −5,39 | TabS22 reg, lrw: b | −5,39 | confere |
| Tabelas 3/A17 | −4,38 | TabS22 a, lrw: b | −4,38 | confere |
| Tabelas 3/A17 | −4,09 | TabS22 c, lrwh: b | −4,09 | confere |
| Tabelas 3/A17 | −1,86 (p = 0,063) | TabS22 bW, lrw: b e p de bootstrap | −1,858; 0,063 | confere |
| Tabelas 3/A17 | F 6,6 | TabS22 d: Feff | 6,6 | confere |
| Tabelas 3/A17 | prêmio −0,08 (p = 0,79) | TabS22 e, prem01: b e p de bootstrap | −0,08; 0,79 | confere |
| Tabela A18 | −0,21 (p = 0,028) | TabS23 sa, h = 1, dk: b e p | −0,212; 0,028 | confere |
| Tabela A18 | −0,34 (p = 0,010) | TabS23 sa, h = 2, dk: b e p | −0,339; 0,010 | confere |

**Observações sobre o que não confere**
- **"−0,12 (p = 0,146)".** Mistura dois números. −0,121 é a interação com o consumo sobre o PIB tendencial no painel C da Tabela A14. O p = 0,146 é o da diferença entre o mesmo ano e o PIB tendencial (−0,063). Sugestão: "−0.06 (p = 0.146)", se a frase fala da diferença, ou "−0.12" sem o p, se fala da interação.
- **"0,86".** Confere. A correlação exata do crescimento da tendência HP unilateral com o crescimento do PIB é 0,8554, que arredonda para 0,86. O registro antigo tinha só 3 casas (0,855).

---

## Pendências para os autores

1. **Lista de anos fiscais** (`data/raw/fiscal_year/fiscal_year_by_country.csv`):
   - Conferir os países marcados como "não verificado": CUB, PRK, PSE e XKX.
   - Verificar se as GFS convertem para ano civil a folha dos países de ano fiscal não civil. Não há esse metadado na API.
   - Verificar se a Austrália, a Nova Zelândia, o Reino Unido, os EUA, o Canadá e o Japão, que aparecem em ano civil no WEO, também estão em ano civil nas GFS.
   - Conferir a convenção de rótulo do ano fiscal usada no realinhamento.
2. **Valores publicados de Mollick e Vianna (2024)** usados no Bloco 3 (Tabela 2, período inteiro, interação e erro-padrão): GE −0,811 (0,169), CC −0,814 (0,156), RL −0,835 (0,153). Conferir no PDF.
3. **Reescrever as seções do manuscrito** conforme as frases acima (Summary, 1, 4.1, 4.2, 4.4, 4.5, 4.6 e 5). Trocar as Tabelas A5 e A2 (painel B) e a Figura A3. Inserir os painéis, linhas e colunas listados em `output/kyklos2/EXHIBITS_CHANGES.md`.
4. **Corrigir no texto** os números da Conferência que não conferem.
5. **Bloco 1:** decidir se o resultado do desenho estacionário para T3 (66% sob a nula) entra no texto principal ou só no apêndice.
