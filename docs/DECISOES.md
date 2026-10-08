# Registro de decisões

Cada entrada traz: o que foi decidido, por quê e qual era a alternativa. Ordem cronológica.

## Ambiente

**D01. Stata 17 MP como linguagem principal, no lugar de R.** O orientador pediu que tudo rode em Stata. A especificação previa R, com Stata só onde não houvesse equivalente. Mapeamento usado: `fixest` → `reghdfe`/`areg`/`xtscc`; `pdynmc`/`plm` → `xtabond2` (com conferência por `xtdpdgmm`); `xtdpdbc` (Breitung, Kripfganz e Hayakawa, 2022) para efeitos fixos com correção de viés; `xthenreg` (Seo e Shin, 2016) e `xthreg` (Hansen, 1999) para limiares; `interflex` (versão Stata de Hainmueller, Mummolo e Xu) para o diagnóstico de interação; `bma` (De Luca e Magnus, 2011) para média bayesiana de modelos; `xtdcce2` para CCE de grupo médio; `weakiv`/`ivreg2` para Anderson-Rubin; `esttab` (tabelas `.tex`) e `putdocx` (tabelas `.docx`). Alternativa descartada: rodar em R e só replicar em Stata, o que duplicaria o código.

**D02. Python só para baixar dados e ler o `.wf1`.** As APIs (Banco Mundial, FMI SDMX 3.0, ILOSTAT) devolvem JSON/CSV paginados que o Stata lê mal; o `.wf1` é binário. Python não faz nenhuma limpeza, construção de variável ou estimação: o script só grava arquivos brutos em `data/raw/`. Toda transformação está nos `.do`. Alternativa: `import delimited` com URL direto no Stata, viável para algumas fontes mas frágil para APIs paginadas.

**D03. Semente fixa** `20261007` (`set seed` e `set sortseed`) em `code/00_setup.do`. Pacotes de usuário e versões registrados em `docs/README.md`.

## Fase 0

**D04. Erro-padrão de referência da Fase 0.** O coeficiente −0,865 é reproduzido exatamente. O erro-padrão 0,269 é obtido com `areg ..., absorb(país) vce(cluster país)`, que conta os efeitos fixos de país nos graus de liberdade da correção de amostra pequena. Com `reghdfe`/`xtreg, fe` (que tratam o efeito fixo como aninhado no cluster) o erro-padrão é 0,261. A diferença é só a correção de graus de liberdade (fator √[(N−1)/(N−K)]). No artigo usamos `reghdfe`, que é o padrão atual e o mesmo de `fixest` com `ssc(fixef.K = "nested")`; registramos as duas versões no log da Fase 0.

## Fase 1: dados

**D05. Fonte da folha de governo geral.** FMI, GFS Statement of Operations (SDMX 3.0, `GFS_SOO`), indicador G21 (remuneração de empregados), setor S13 (governo geral), em % do PIB. O dataflow só publica % do PIB; a participação na despesa total é calculada como G21 / (G2 + G31), isto é, despesa mais investimento líquido em ativos não financeiros (conceito de *outlays* do GFSM 2014). Alternativa: WWBI (`BI.WAG.TOTL.GD.ZS`), que tem mais países (159), mas mistura governo central e geral conforme o país e não traz as demais categorias da despesa necessárias para A4.

**D06. Ponto de verificação da seção 6.** Na amostra principal (1996–2023, sem microestados) a folha de governo geral cobre 102 países e 1.891 observações anuais, acima dos limites (80 países, 1.200 observações). Por isso a variável principal é a de governo geral pura, sem misturar níveis. A série combinada (`wagebill_comb`: governo geral; onde faltar, governo central do GFS, na ordem S1321, S1311, S1311B, com `cov_central = 1`) cobre 153 países e entra só como robustez. Custo: países de renda baixa têm 260 observações (25 países) na série principal. Alternativa: usar a série combinada como principal, o que preservaria mais países pobres; descartada porque a especificação manda não misturar níveis de governo na variável principal quando a cobertura de governo geral é suficiente.

**D07. Duplicatas no GFS.** O mesmo valor aparece em mais de um grupo (`GFS_GRP` G2 e G2M). O script verifica que os valores são idênticos (diferença máxima < 1e-6) antes de manter um registro.

**D08. Grupo de renda em ano-base fixo.** Classificação analítica do Banco Mundial para os dados de 1996 (planilha OGHIST). Para países sem classificação em 1996, usa-se a primeira disponível depois. Alternativa: classificação atual, que é endógena ao crescimento do período.

**D09. Microestado.** População média de 1996–2023 abaixo de 500 mil (29 países). Usar a média, e não um ano, evita que um país entre e saia da amostra.

**D10. Territórios sem contas fiscais próprias (regra 1).** Excluídos 20 territórios dependentes cujas contas fiscais integram as de outro Estado: ABW, ASM, BMU, CHI, CUW, CYM, FRO, GIB, GRL, GUM, IMN, MAF, MNP, NCL, PRI, PYF, SXM, TCA, VGB, VIR. Mantidos Hong Kong, Macau, Kosovo e Cisjordânia e Gaza, que têm orçamento próprio.

**D11. Regra 3 aplicada a 18 observações.** Antes de tratá-las como ausentes, comparei com o WDI e o WWBI (lista em `output/logs/03_painel.log`): Irã 1986–1989 tem folha de 34% a 41% do PIB no GFS contra 9% a 12% no WDI (erro de fonte); Timor-Leste tem despesa acima do PIB financiada pelo fundo do petróleo, o que é real, mas a regra manda tratar como ausente; Nauru e Ilhas Marshall são microestados. O caso do Sudão citado na dissertação (257% e 308% do PIB) vem da série do WDI e não aparece no GFS.

**D12. Winsorização (regra 4).** Percentis calculados no painel anual sem microestados, 1980–2023 (período usado na construção das médias): crescimento em −17,6% e 16,3%; inflação em −4,3% e 709%. O p99 da inflação é alto porque o painel inclui as hiperinflações dos anos 1980 e 1990; essas observações também são marcadas (`hyperinf`). As versões originais ficam em `g_raw` e `infl_raw`. Alternativa: usar ln(1 + π) como controle; descartada para seguir a especificação.

**D13. Anos de guerra (regra 5).** UCDP/PRIO Armed Conflict Dataset v26.1, intensidade 2 (1.000 ou mais mortes em batalha no ano), atribuída ao país de localização (`gwno_loc`, convertido de Gleditsch-Ward para ISO3). Fonte acrescentada porque a especificação pede a marcação mas não indica a base.

**D14. Folha ajustada ao ciclo.** `wagebill_cyc = wagebill_gdp × Y / Y*`, onde Y* é o PIB real tendencial. HP com λ = 6,25 (Ravn e Uhlig, 2002, para dados anuais), aplicado ao log do PIB real de 1970–2023 de cada país. Alternativa: filtro de Hamilton (2018) com h = 2 e p = 2 (regressão de y_t em y_{t−2} e y_{t−3}, país a país), guardado em `wagebill_cyc_ham`.

**D15. Choque de folha.** `d_wagebill_real = wb_t × (Y_t / Y_{t−1}) − wb_{t−1}`, com Y o PIB real. É a variação da folha deflacionada pelo deflator do PIB, em % do PIB real do ano anterior, e não tem o PIB corrente no denominador.

**D16. Decomposição (H2).** `pubemp_share` = emprego público como % do emprego total (WWBI). `relwage` = folha (% do PIB, GFS) / `pubemp_share`, isto é, a remuneração média por servidor dividida pelo PIB por trabalhador. Com essas definições o produto reproduz a folha por construção (verificado: discrepância máxima de 8e-7). A verificação com fonte independente usa o ILOSTAT (salário médio dos empregados públicos × 12 × emprego público): a razão em relação à folha do GFS tem mediana 0,81, compatível com a exclusão das contribuições do empregador nas pesquisas domiciliares. O prêmio do WWBI (`BI.WAG.PREM.PB.GP`, contra todos os empregados privados) está em pontos log.

**D17. Choques de emprego e de salário (D2).** `d_wb_emp = wb_{t−1} × (N_t/N_{t−1} − 1) × Y_t/Y_{t−1}`, com N = emprego público (participação do WWBI × emprego total do PWT); `d_wb_wage = d_wagebill_real − d_wb_emp`. Sem interpolação do WWBI: só anos consecutivos observados. Alternativa: interpolar lacunas do WWBI, descartada porque criaria variação artificial no choque.

**D18. Eleições (H5).** DPI 2020. Eleição relevante: presidencial em sistemas presidencialistas, legislativa nos demais. `election_fixed` = eleição no ano em que o mandato constitucional expira (`yrcurnt = 0` no DPI); eleições com `yrcurnt > 0` são antecipadas. O DPI termina em 2020, portanto H5 usa 1996–2020. Alternativa: NELDA (no QoG), que não informa o calendário constitucional.

**D19. Federalismo.** Lista de federações do Forum of Federations (28 países, incluindo Espanha e África do Sul, federais na prática). O indicador `author` do DPI foi descartado: está ausente para 108 países e é positivo em países unitários como França, Itália e Colômbia. A descentralização do gasto do FMI (Fiscal Decentralization, 2010–2020) fica no painel como medida contínua.

**D20. OCDE.** Os 38 membros de 2023, fixos no tempo.

**D21. Painéis de médias.** Períodos de 5 anos alinhados para terminar em 2023 (1979–83, ..., 2019–23) e de 3 anos (1981–83, ..., 2021–23). Médias no período: crescimento, investimento, abertura, inflação, crescimento populacional, termos de troca e variáveis de resultado. Primeiro ano do período: folha, participações da despesa, despesa, receita, resultado, mérito, WGI, capital humano e dívida. Renda inicial: log do PIB per capita no ano anterior ao período. Variáveis do WWBI (painel irregular, baseado em pesquisas): primeiro ano disponível dentro do período. Crescimento do período exige ao menos 3 de 5 (ou 2 de 3) anos observados.

**D22. Fontes substitutas.** UNU-WIDER GRD via QoG (`ictd_*`), porque o site do UNU-WIDER exige registro; termos de troca de commodities do FMI (CTOT, índice líquido de preços de exportação ponderado pelo PIB, pesos fixos) no lugar do índice do WDI; PWT 11.0 (arquivo principal); V-Dem v16 Full+Others (o arquivo Core não traz `v2stcritrecadm`); ILOSTAT via SDMX (o endpoint rplumber devolvia arquivos vazios). Fiscal Rules Dataset do FMI: download manual pendente.

**D23. Parquet.** Os painéis são gravados em `.dta` pelo Stata e convertidos para `.parquet` por `code/03b_exporta_parquet.py` (só conversão de formato), porque a integração Python do Stata 17 falha nesta máquina e o Stata em modo batch ignora `shell`. O comando único `bash run_all.sh` faz coleta, Stata e conversão.
