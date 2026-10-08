# Resultados: folha de pagamento do setor público, burocracia e crescimento

Relatório para o orientador. Gerado por `code/12_relatorio.do` em  7 Oct 2026; todos os números vêm das estimativas gravadas pelo pipeline. Coeficientes em pontos percentuais de crescimento anual do PIB per capita por ponto percentual do PIB na folha, salvo indicação. IC = intervalo de confiança de 95%.

Regra dos vereditos, fixada antes da leitura dos números: *sustentada* = especificação preferida com o sinal previsto e p < 0,05; *rejeitada* = sinal oposto e p < 0,05; *inconclusiva* nos demais casos.

## 1. Conclusão por hipótese

**Resultado de base (folha em % do PIB).** Com médias de cinco anos, efeitos fixos de país e período e a folha do governo geral medida no primeiro ano do período (A1, Tabela 2, coluna 1), o coeficiente de um ponto percentual do PIB a mais de folha sobre o crescimento anual é -0,182 p.p. (IC [-0,326; -0,037]; p = 0,014). O sinal se repete com médias de três anos (-0,233; IC [-0,416; -0,051]) e no estimador com correção de viés para painel dinâmico (-0,184; IC [-0,364; -0,004]), mas não no System GMM (-0,280; IC [-0,834; 0,274]; 25 instrumentos para 87 países; AR(2) p = 0,621; Hansen p = 0,080), cujo intervalo é largo, nem no painel anual com a folha defasada um ano (0,040; IC [-0,226; 0,305]). O coeficiente do crescimento defasado no GMM fica entre os limites de MQO agrupado e de efeitos fixos (verificação de Bond, Tabela A5).

**H1 (composição) — inconclusiva quando a categoria omitida é investimento; sustentada quando é transferências.** Mantida a despesa total, a participação da folha na despesa tem coeficiente -0,027 (IC [-0,064; 0,010]; p = 0,151). Na restrição orçamentária completa, realocar 1 p.p. da despesa do investimento público para a folha tem coeficiente -0,039 (IC [-0,101; 0,023]); realocar das transferências para a folha, -0,067 (IC [-0,128; -0,006]; p = 0,033). A especificação preferida para H1 é a da restrição orçamentária (A4); o sinal é o previsto nas três versões, mas só é estatisticamente distinto de zero quando a folha substitui transferências. A amostra de A4 é menor (exige todas as categorias da despesa).

**H2 (preço versus quantidade) — componente de preço: inconclusiva (evidência fraca, p < 0,10); não linearidade do emprego: não encontrada.** O salário relativo (remuneração por servidor sobre PIB por trabalhador) tem coeficiente -0,940 (IC [-2,045; 0,164]; p = 0,094) em B1 e -1,595 (IC [-3,141; -0,049]) em B2. O emprego público tem coeficiente -0,006 (IC [-0,089; 0,076]) e, com o termo quadrático (B2), a forma estimada é de U (mínimo), com ponto de inflexão em 29,5% do emprego total (IC [18,7; 40,4]) e teste conjunto p = 0,274; o U invertido de Baerlocher (2021) não aparece. O prêmio salarial ajustado do WWBI (B3) tem coeficiente 1,644 (IC [-0,757; 4,045]), sem sinal negativo. Ou seja, a associação negativa vem do componente de preço medido como salário relativo, mas não se confirma com a medida de prêmio baseada em pesquisas domiciliares; a amostra de B é pequena (WWBI desde 2000).

**H3 (moderação institucional) — inconclusiva.** Na interação linear (C1), o coeficiente da interação folha × mérito é 0,041 (IC [-0,060; 0,142]; p = 0,423). O efeito marginal da folha é -0,231 (IC [-0,405; -0,056]) no percentil 10 do mérito (-0,16) e -0,129 (IC [-0,316; 0,059]) no percentil 90 (2,34): o custo da folha é um pouco menor onde o recrutamento é meritocrático, direção da previsão (a), mas a diferença não é estatisticamente significativa. A divisão na mediana dá -0,314 (abaixo) e -0,172 (acima); nos tercis, -0,369, -0,246 e -0,175. No modelo de limiar dinâmico de Seo e Shin (2016) na janela em que o número de condições de momento fica abaixo de N/2 (2015–2019, 72 países), o teste de linearidade por bootstrap tem p = 0,920 (limiar estimado em 0,701, sem significância); no modelo de efeitos fixos de Hansen (1999), p = 0,304. Nenhum dos dois encontra limiar. A versão de Seo e Shin em 2000–2019 tem 207 condições de momento para 35 países, isto é, a mesma proliferação de instrumentos que invalidou o GMM da dissertação, e produz estatísticas t de até 15 e linearidade rejeitada com p = 0; está na Tabela A6 só por transparência e não é interpretada. Com o WGI (C5), a interação é -0,062 (IC [-0,274; 0,151]). Nas projeções locais com o mérito medido antes do choque (D3), a trajetória vai na direção oposta: em países de mérito alto, uma expansão real da folha de 1% do PIB é seguida de variação de -2,373% no PIB per capita em quatro anos (IC [-5,075; 0,328]), contra -0,246% (IC [-1,382; 0,890]) em países de mérito baixo (p da diferença = 0,032), o que se aproxima da previsão (b) de Mollick et al. (2023). As duas evidências medem coisas diferentes (nível inicial da folha no médio prazo contra expansões da folha), e nenhuma é robusta o bastante para escolher entre (a) e (b).

**H4 (mecanismo) — investimento privado: sustentada; PTF: sustentada; emprego privado: inconclusiva.** Em A1, o coeficiente da folha inicial é -0,375 sobre o investimento privado (p.p. do PIB; IC [-0,737; -0,014]) e -0,115 sobre o crescimento da PTF (p.p.; IC [-0,223; -0,007]). Para o emprego privado o coeficiente é 0,329 (IC [-0,157; 0,815]), com amostra pequena (ILOSTAT, mesma pesquisa para emprego total e público). Nas projeções locais, uma expansão real da folha de 1% do PIB é seguida de variação de -1,086 p.p. do PIB no investimento privado em quatro anos (IC [-1,778; -0,394]).

**H5 (economia política) — inconclusiva, com sinal oposto ao previsto; o instrumento é fraco.** A folha cresce em anos de eleição com calendário predeterminado (0,084 p.p. do PIB; IC [0,012; 0,156]); o F do primeiro estágio é 5,31.  Nas projeções locais, expansões da folha em anos eleitorais não são seguidas de crescimento pior: em quatro anos, 1,663% após choques em ano eleitoral contra -1,301% nos demais anos (p da diferença = 0,058); em países de mérito alto, 2,122% contra -1,682% (p = 0,009). Pela regra fixada, o veredito usa a diferença em h = 4 na amostra toda.

**O viés do denominador (resultado central, D4; Figura 3 e Tabela A7).** Na mesma amostra anual e com o mesmo modelo, o coeficiente da folha é -0,686 (IC [-1,026; -0,345]) com a razão contemporânea, -0,432 (IC [-0,721; -0,142]) com a folha sobre o PIB tendencial do filtro HP, 0,034 (IC [-0,267; 0,336]) com o filtro de Hamilton e 0,040 (IC [-0,235; 0,314]) com a folha defasada um ano. Nas médias de cinco anos, -0,300 com a média do período contra -0,182 com o valor inicial. A associação negativa forte da dissertação é, em grande parte, contemporânea e mecânica; o que sobra com a folha medida antes do crescimento é um efeito de médio prazo menor, visível nas médias de cinco anos e ausente na frequência anual.

## 2. Tamanho do efeito

O desvio-padrão da folha (% do PIB) dentro dos países é 1,28 p.p. no painel de cinco anos (valor inicial do período) e 1,03 p.p. no painel anual (Tabela 1). Pela especificação A1, uma folha um desvio-padrão (dentro do país) mais alta no início do período está associada a uma variação de -0,232 p.p. no crescimento anual dos cinco anos seguintes, ou cerca de -1,16% de PIB per capita acumulado no período. É uma ordem de grandeza abaixo dos coeficientes da dissertação (−2 a −3 p.p. por ponto do PIB), como o diagnóstico antecipava.

## 3. O que é robusto e o que não é

Especificação de referência: A1 (coeficiente -0,182; p = 0,014). Verificações do Bloco G (Tabelas A8a–A8c, A9; Figuras A5 e A6):

| Verificação | Coeficiente | EP | p | Obs. | Situação |
|---|---|---|---|---|---|
| Governo central (WDI, série da dissertação) | 0,035 | 0,076 | 0,642 | 596 | **muda de sinal (não significativo)** |
| Governo geral ou central (série combinada) | -0,061 | 0,051 | 0,235 | 679 | **perde significância** |
| Com microestados | -0,172 | 0,071 | 0,017 | 377 | mantém sinal e significância |
| Sem países ricos em recursos naturais | -0,150 | 0,066 | 0,026 | 342 | mantém sinal e significância |
| Sem 2008–2009 e 2020–2021 | -0,144 | 0,083 | 0,087 | 365 | mantém sinal; p entre 0,05 e 0,10 |
| Sem winsorização | -0,181 | 0,073 | 0,015 | 365 | mantém sinal e significância |
| Controle de dívida pública | -0,224 | 0,065 | 0,001 | 360 | mantém sinal e significância |
| Renda baixa (1996) | -1,721 | 0,865 | 0,082 | 26 | mantém sinal; p entre 0,05 e 0,10 |
| Renda média-baixa | -0,116 | 0,118 | 0,339 | 86 | **perde significância** |
| Renda média-alta | -0,174 | 0,197 | 0,397 | 56 | **perde significância** |
| Renda alta | -0,151 | 0,088 | 0,098 | 190 | mantém sinal; p entre 0,05 e 0,10 |
| OCDE | -0,107 | 0,072 | 0,144 | 235 | **perde significância** |
| Fora da OCDE | -0,250 | 0,126 | 0,055 | 130 | mantém sinal; p entre 0,05 e 0,10 |
| Federais | -0,083 | 0,084 | 0,343 | 76 | **perde significância** |
| Unitários | -0,226 | 0,086 | 0,011 | 289 | mantém sinal e significância |
| CCE de grupo médio (anual, folha defasada) | 1,103 | 0,301 | 0,000 | 1285 | **muda de sinal (significativo)** |

- Exclusão de um país por vez: coeficiente entre -0,225 e -0,134; IC abaixo de zero em 71 das 72 reestimações (Figura A5).
- Média bayesiana de modelos: probabilidade posterior de inclusão da folha = 0,999 (Tabela A9, Figura A6).
- Em 2 verificações o coeficiente muda de sinal e em 5 perde significância (p ≥ 0,10). As mais importantes:
  - **Série de governo central da dissertação**: com a variável original, o efeito desaparece (sinal positivo, não significativo). O resultado depende de medir a folha do governo geral.
  - **Série combinada GG/GC**: ao acrescentar países só com governo central (sobretudo de renda baixa), o coeficiente encolhe e perde significância.
  - **CCE de grupo médio**: na frequência anual, com coeficientes heterogêneos por país, o sinal se inverte. Os coeficientes por país são muito dispersos (mediana 0,721, desvio-padrão 2,13), e os maiores aparecem em países europeus cuja folha sobe no ano de recessão e cujo PIB se recupera no ano seguinte: em séries anuais curtas, a folha defasada capta esse rebote, que é o viés do denominador com o sinal trocado. Não é evidência de efeito positivo de longo prazo, mas mostra que o resultado não sobrevive a estimadores país a país em frequência anual.
  - **Subamostras**: o sinal negativo se mantém em quase todas, mas a significância depende do tamanho da amostra; o grupo de renda baixa tem só 9 países e coeficiente instável.
- Também não é robusto: o System GMM (sinal negativo, intervalo largo) e a especificação anual com a folha defasada (efeito nulo). O efeito de base aparece em médias de 3 e 5 anos com efeitos fixos e no estimador com correção de viés.

## 4. Limitações que um parecerista vai apontar

1. **Identificação.** As estimativas de A, B, C e E são associações condicionais em painel com efeitos fixos. A folha inicial é predeterminada em relação ao crescimento do período, mas não exógena: choques persistentes e expectativas de crescimento podem afetar a decisão de contratar e reajustar. O System GMM, única estratégia com instrumentos, tem intervalo largo e Hansen no limite (p = 0,080). A tentativa de variação exógena (calendário eleitoral) tem instrumento fraco (F = 5,31).
2. **Cobertura da folha de governo geral.** 102 países no painel anual e 72 na especificação A1, com sub-representação de países de renda baixa (ver `docs/AUDITORIA_DADOS.md`). A série combinada amplia a amostra, mas mistura níveis de governo e muda o resultado.
3. **Decomposição.** O emprego público do WWBI vem de pesquisas domiciliares, começa em 2000 e é irregular; o salário relativo é construído como folha/participação do emprego, de modo que erro de medida no emprego entra com sinal oposto nos dois componentes. Isso pode explicar parte da diferença entre B1 (salário relativo) e B3 (prêmio ajustado).
4. **Moderador.** O índice de mérito do V-Dem varia pouco dentro dos países; com efeitos fixos de país, a moderação é identificada por mudanças pequenas. Os modelos de limiar exigem painel estritamente balanceado: 35 países em 2000–2019 e 72 em 2015–2019, uma janela curta para dinâmica de crescimento.
5. **Projeções locais.** No impacto (h = 0), parte da resposta positiva do PIB é contábil: nas contas nacionais, o valor adicionado do governo é medido pelo custo, de modo que a folha entra diretamente no PIB. As respostas em horizontes longos têm intervalos largos e a amostra encolhe com o horizonte.
6. **Eleições.** O DPI termina em 2020; a definição de calendário predeterminado (anos restantes do mandato = 0) segue o DPI e pode classificar mal eleições antecipadas em sistemas parlamentares.
7. **Período e choques comuns.** O período de 2019–2023 contém a pandemia; a exclusão de 2008–2009 e 2020–2021 reduz o coeficiente e o deixa no limite da significância a 10%.

## 5. Pendências

- **Download manual**: FMI Fiscal Rules Dataset (o servidor do FMI bloqueia acesso automatizado). Não entra em nenhuma especificação fixada; colocar em `data/raw/manual/` (instruções em `docs/DOWNLOADS_MANUAIS.md`).
- **Estimadores substituídos**: nenhum por falta de Stata (o Stata 17 estava disponível, e `xthenreg` e `xtdpdbc` foram usados). O estimador por kernel de Hainmueller, Mummolo e Xu foi implementado no próprio código, porque o modo kernel do `interflex` para Stata, com efeitos fixos e bootstrap, termina com erro interno; os tercis e o teste de Wald vêm do `interflex` (decisão D28).
- **Fontes substituídas por rota oficial alternativa**: UNU-WIDER GRD via QoG; ILOSTAT via SDMX (detalhes em `docs/DECISOES.md`, D22).
- **Etapas não incluídas** por não constarem da lista fixada na seção 7: PMG/CS-ARDL de longo prazo e heterogeneidade por regras fiscais (esta depende do download manual).

## 6. Onde está cada tabela e figura

Tabelas em `output/tables/` (`.tex` e `.docx`); figuras em `output/figures/` (`.pdf` e `.png` a 600 dpi); legendas e notas em `output/captions.md`.

| Item | Arquivo | Conteúdo |
|---|---|---|
| Table 1 | `output/tables/Table1_descriptives.{tex,docx}` | Estatísticas descritivas |
| Table 2 | `output/tables/Table2_baseline.{tex,docx}` | Base, A1–A5 e A7 |
| Table 3 | `output/tables/Table3_decomposition.{tex,docx}` | Decomposição, B1–B3 |
| Table 4 | `output/tables/Table4_moderation.{tex,docx}` | Moderação, C1, C3, C5 |
| Table 5 | `output/tables/Table5_mechanisms.{tex,docx}` | Mecanismos, E1–E3 |
| Table 6 | `output/tables/Table6_political_economy.{tex,docx}` | Economia política, F1–F3 |
| Table A1 | `output/tables/TableA1_definitions.{tex,docx}` | Definições e fontes |
| Table A2 | `output/tables/TableA2_countries.{tex,docx}` | Países por grupo de renda |
| Table A3 | `output/tables/TableA3_correlations.{tex,docx}` | Matriz de correlação |
| Table A4 | `output/tables/TableA4_gmm_instruments.{tex,docx}` | Sensibilidade de instrumentos (A5) |
| Table A5 | `output/tables/TableA5_bond_check.{tex,docx}` | Verificação de Bond (A6) |
| Table A6 | `output/tables/TableA6_threshold.{tex,docx}` | Limiares (C4) |
| Table A7 | `output/tables/TableA7_denominator.{tex,docx}` | Viés do denominador (D4) |
| Table A8a | `output/tables/TableA8a_robustness_definitions.{tex,docx}` | Robustez: medida, amostra, outliers |
| Table A8b | `output/tables/TableA8b_robustness_subsamples.{tex,docx}` | Robustez: subamostras |
| Table A8c | `output/tables/TableA8c_robustness_cce.{tex,docx}` | Robustez: CCE de grupo médio |
| Table A9 | `output/tables/TableA9_bma.{tex,docx}` | Média bayesiana de modelos |
| Figure 1 | `output/figures/Figure1_wagebill_income.{pdf,png}` | Folha por grupo de renda |
| Figure 2 | `output/figures/Figure2_employment_vs_wage.{pdf,png}` | Emprego público x salário relativo |
| Figure 3 | `output/figures/Figure3_denominator.{pdf,png}` | Viés do denominador (D4) |
| Figure 4 | `output/figures/Figure4_marginal_effect_merit.{pdf,png}` | Efeito marginal ao longo do mérito (C1, C2) |
| Figure 5 | `output/figures/Figure5_local_projections.{pdf,png}` | Projeções locais (D1, D2) |
| Figure 6 | `output/figures/Figure6_lp_merit.{pdf,png}` | Projeções locais por regime de mérito (D3) |
| Figure A1 | `output/figures/FigureA1_coverage.{pdf,png}` | Cobertura dos dados |
| Figure A2 | `output/figures/FigureA2_marginal_effect_wgi.{pdf,png}` | Efeito marginal ao longo do WGI (C5) |
| Figure A3 | `output/figures/FigureA3_lp_mechanisms.{pdf,png}` | Projeções locais dos mecanismos (E) |
| Figure A4 | `output/figures/FigureA4_lp_elections.{pdf,png}` | Projeções locais por ano eleitoral (F3) |
| Figure A5 | `output/figures/FigureA5_leave_one_out.{pdf,png}` | Exclusão de um país por vez |
| Figure A6 | `output/figures/FigureA6_bma_pip.{pdf,png}` | Probabilidades de inclusão (BMA) |
