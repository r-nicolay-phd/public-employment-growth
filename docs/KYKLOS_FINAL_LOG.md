# Log das estimações finais para a Kyklos (versão 4)

Execução de `PROMPT_Claude_Code_Kyklos_estimacoes_finais.md` a partir de 16/11/2026, com Stata 17 (StataMP, `C:\Program Files\Stata17\StataMP-64.exe`, modo batch), na pasta `Estimações`.

## Registro antes de estimar

- **Arquivo e commit.** O segundo adendo, `docs/plan_addendum_kyklos_2.md`, foi escrito antes de qualquer estimação deste prompt e commitado sozinho, com a mensagem pedida.
  - Hash: `be45e06401f466d895f09826b28cfbe909ca2312`
  - Data: 16/11/2026, 13:45:23 (−0300)
  - Branch: `revisao-ejpe`
- **Antes do commit**, só foram feitas consultas de dados que não envolvem estimação:
  - metadados do WEO para o ano fiscal (Bloco 5);
  - nomes de variáveis dos painéis;
  - instalação do pacote `weakivtest` (SSC).

## Definições conservadoras registradas no adendo

**Bloco 1.**
- O teste de sanidade exige as duas condições abaixo; a regra usa a fração do coeficiente anual do mesmo ano com ε = 0,48 na variante ancorada.
  - **Inclinação:** a da média simulada sobre (1 − ε) é negativa e seu intervalo de 95% exclui zero. O intervalo vem das inclinações replicação a replicação.
  - **Média em ε = 1:** |média| ≤ 10% do observado, e o intervalo 2,5–97,5 contém zero.
- **Reta de 45°.** "A reta de 45° do coeficiente observado" foi interpretada como o raio que sai da origem e passa pelo coeficiente observado em 1 − ε = 0,52 (referência de "contabilidade total"), mais uma linha horizontal no valor observado.

**Bloco 2.**
- **Conjuntos de variantes:**
  - "todas as variantes" são os itens 1, 2a, 2b, 3 (coeficiente principal) e 4;
  - "variantes principais" são os itens 1, 2a, 2b e 4.
- **γ × δ.** Mantido literal, como pedido. Como não está na unidade de β, reporta-se também o viés de variável omitida dimensionalmente correto (γ_longo × π). O sinal sai do produto literal; a magnitude, de γ_longo × π.

**Bloco 3.**
- **Sobreposição de 1996–2005.** Cada período entra uma vez. Na principal, o indicador "posterior" vale 1 em 2006–2020; na robustez, vale 1 em 1996–2020.
- **Regra de Oto-Peralías e Romero-Ávila:** p de bootstrap do FE com a média do período.
- **Regra de Mollick e Vianna:** IC de 95% agrupado (mais largo que o White), com GE.
- **Equivalência:** TOST com IC de 90%, tanto em relação ao valor publicado quanto em relação a zero.

**Bloco 4.**
- **Regra:** usa o painel D, mesmo ano.
- **"Controle perto de zero":** |média| ≤ 10% do observado, e o intervalo do controle contém zero.
- **Faixas de 20–50% e < 20%:** lidas na fração líquida do controle.
- **WGI:** índice médio dos seis indicadores, interpolado entre anos dentro do país.

**Bloco 5.**
- **Lista de anos fiscais:** vem do atributo START_END_MONTHS_OF_REPORTING_YEAR do WEO.
- **Conversão das GFS para ano civil:** "não verificado" em todos os países, porque os metadados das GFS não informam isso.
- **Rótulo do ano fiscal:** é o ano civil com a maioria dos meses. A convenção não pode ser verificada nas fontes.
- **Regra:** as diferenças "mesmo ano − Hamilton" e "mesmo ano − defasada", com sinal negativo e p < 0,01, na amostra sem os países.

**Bloco 6.**
- **Regra:** modelos 1, 2 e 3 na amostra registrada, todos com p de bootstrap < 0,05.
- **Denominador alternativo:** PIB real por trabalhador do ano anterior ao par (PIB real / emprego total).

**Bloco 7.**
- **h = 5:** θ é o efeito em nível em h = 5 por ponto de folha mantido (média de dw_0…dw_5), via LP-IV. θ/5 é o número pedido; θ/6 vai em nota.
- **Regra:** usa a estimativa pontual de θ/5 do choque (a).

## Decisões durante a execução

**Velocidade das simulações (Blocos 1 e 4).**
- Na primeira versão, cada replicação rodava `reghdfe`. Isso levava ~30 min por ponto da grade (≈5 h só no Bloco 1, acima do limite de 3 h).
- Como só a folha sintética muda entre replicações, os coeficientes passaram a ser calculados por Frisch-Waugh, com a projeção dos controles e dos efeitos fixos calculada uma vez (`_fwlb` em `code/kyklos2/sim2_mata.do`).
- O resultado é numericamente idêntico ao `reghdfe`. Na primeira replicação de cada desenho o código compara os dois e interrompe se diferirem mais que 1e−6; todas as comparações bateram até a 8ª casa.
- As replicações continuam em 1.000; não foi preciso reduzi-las.
- A rodada lenta foi interrompida antes de terminar e não foi usada.

**Bloco 1, variante estacionária.** A recursão começa no valor observado do primeiro ano do país e recomeça no valor observado depois de um insumo faltante. Nesses poucos anos, a razão "sintética" é a observada.

**Bloco 2.**
- **Pacote `b1x2`** (Gelbach) instalado do SSC na pasta de pacotes do projeto (`ado/plus`), ao lado do `weakivtest`.
- **Efeitos fixos no Gelbach:** entram como dummies, porque `b1x2` não aceita variáveis de fator.
- **Teste de bootstrap:** o `boottest` não roda depois de `reghdfe` com dois efeitos absorvidos. Nas linhas anuais, o modelo usado para o bootstrap absorve o país e põe o ano como dummies; o coeficiente é o mesmo.

**Bloco 3.**
- **Valores publicados de Mollick e Vianna (2024, Tabela 2, período inteiro), interação × erro-padrão:**
  - GE: −0,811 (0,169)
  - CC: −0,814 (0,156)
  - RL: −0,835 (0,153)
  - São os mesmos já usados no painel A da Tabela A16 (`code/revisao/06_instituicoes.do`).
- **Amostra comum de 3.108 observações** (GE), a mesma do painel D da Tabela A14.

**Bloco 4.**
- **ε_0 e ε_1** foram reestimados com o código do mecanismo da Tabela A15: ε_0 = 0,556 e ε_1 = −0,180 por unidade do índice médio do WGI (centrado na média de 1996–2023, −0,174).
- **Índice médio do WGI:** interpolado entre anos dentro do país. Para t − 1 ≤ 1995 usa-se o valor de 1996; o adendo citava só 1995, e o primeiro ano defasado (1994) recebeu o mesmo tratamento.
- **Regra, caso não previsto no adendo.** Se a fração com gradiente passar de 50% sem que o controle fique perto de zero, a primeira linha não vale e a decisão é lida na fração líquida do controle.

**Bloco 5.**
- **Fonte.** Os metadados das GFS (`IMF.STA/GFS_SOO`, consulta com `attributes=all`) não trazem o ano de referência. O WEO traz o atributo START_END_MONTHS_OF_REPORTING_YEAR por país e indicador.
- **Países com ano fiscal não civil.** Pelo WEO, 32 países (22 entre os não microestados) têm ano de referência do governo geral diferente do civil. Na amostra da Tabela 1 entram 9: EGY, HKG, IRN, LSO, MUS, NPL, RWA, SGP e THA.
- **Países com ano civil no WEO.** Austrália, Nova Zelândia, Reino Unido, EUA, Canadá e Japão aparecem em ano civil nas séries de governo geral do WEO. Se a folha das GFS desses países estiver em ano fiscal, a lista subestima o problema. Pendência para os autores.
- **"Não verificado"** (fora do WEO ou sem o atributo): CUB, PRK, PSE e XKX (não microestados). Na exclusão, ficam na amostra.

**Bloco 6.** O denominador alternativo usa o PIB real dividido pelo emprego total (`gdp_real / emp`) do ano anterior ao par. O salário relativo resultante é ln(salário relativo) + Δln(PIB real por trabalhador) entre o ano anterior e o ano do par.

**Bloco 7.**
- **Integral de Ramey-Zubairy.** A soma do PIB vai de h = 0 a h (base t − 1). A soma da folha usa base t − 2 no choque (a), datado em t − 1, e base t − 1 nos choques (b) e (c).
- **Erros de Driscoll-Kraay.** O LP-IV usa `ivreghdfe` com `dkraay(4)`, banda equivalente à defasagem máxima 3 do `xtscc`.
- **Bootstrap do choque (b).** A forma exatamente identificada permite calcular o coeficiente como forma reduzida ÷ primeiro estágio em cada replicação.

**Bloco 8.**
- **Desvio-padrão 0,97 × 0,98.** A diferença vem da amostra: o painel B da Tabela A2 usa `S1_base` (1.593 país-anos), que difere da amostra da Tabela 1 (1.621) em 28 país-anos. Gerou-se o painel B harmonizado na amostra exata da Tabela 1.
- **Correlação 0,86.** A correlação do crescimento da tendência HP unilateral foi recalculada com todas as casas, porque o registro só tinha 3 (0,855).

**Bloco 7, correção depois da primeira rodada completa.**
- **Primeiro defeito: rótulo truncado.** A primeira rodada completa do `master_kyklos2.do` (2.563 s, sem erros) mostrou dois defeitos no pós-processamento do Bloco 7. O rótulo "theta" estava truncado para "thet" (variável `str4`), de modo que o bootstrap do choque (b) não substituía a inferência de θ.
- **Segundo defeito: EP do bootstrap inflado.** O EP do bootstrap do choque (b) era o desvio-padrão das replicações, inflado por replicações com primeiro estágio quase nulo (razão forma reduzida ÷ primeiro estágio explosiva). No h = 3, por exemplo, o EP dava 281 com IC percentil [0,34; 0,95].
- **Correções:**
  - variável `str5`;
  - o EP do bootstrap passou a ser o intervalo interquartil das replicações ÷ 1,349, robusto a valores extremos;
  - o IC continua sendo o percentil 2,5–97,5.
- **Rodada definitiva.** O `master_kyklos2.do` foi rodado de novo do início ao fim numa sessão limpa (tempo abaixo). Os Blocos 1–6 e 8 não mudam, porque as sementes são fixas.

## Rodada definitiva e verificação

**Rodada.** `code/kyklos2/master_kyklos2.do`, numa sessão limpa do Stata, em 16/11/2026, sem nenhum erro. Tempo total: 2.624 s (≈44 min).

| Etapa | Tempo |
|---|---|
| 01_simulacao | 799 s |
| 01b_decomposicao | 3 s |
| 02_vies | 349 s |
| 03_instituicoes_testes | 11 s |
| 04_simulacao_inst | 118 s |
| 05_ano_fiscal | 12 s |
| 06_h2_reverso | 74 s |
| 07_lp_acumulado | 1.244 s |
| 08_conferencia | 2 s |
| 09_tabelas_k2 | 12 s |

Antes do master houve testes isolados por bloco e uma primeira rodada completa (2.563 s). Os resultados dos Blocos 1–6 e 8 são idênticos entre as rodadas.

**Verificação.**
- **Números do memorando:** `code/kyklos2/confere_memo.py` confronta 89 números do memorando com os `.csv` e o `kv.csv`. Nenhuma divergência. Os números do Bloco 7 foram conferidos à mão contra `Table_A18_panel_cumulative.csv`.
- **Rótulos:** nenhum rótulo visível das tabelas novas (`.docx` e `.tex`) nem da Figura A3 (PDF) contém "draft", "revision", "review" ou numeração antiga (S1–S28).
- **Títulos e notas:** cada tabela nova tem título com o resultado e nota com amostra, efeitos fixos, controles, tipo de erro-padrão e replicações. Todas foram renderizadas e conferidas visualmente.
- **Pacote de replicação:**
  - `replication_kyklos/code/kyklos2/` (caminhos do pacote), `data/raw/fiscal_year/`, `docs/plan_addendum_kyklos_2.md`;
  - README com a seção "Numbering of version 4", o passo 5 e a semente 20261115;
  - `kyklos_numbering.py` copiando as exibições finais com o sufixo `_v4`;
  - `docs/deviations_from_plan.md`, seção 5.
  - Como no prompt anterior, a versão do pacote não foi rodada dentro dele; só os caminhos mudaram.
- **Commits:** nenhum além do commit do adendo (`be45e06`).
