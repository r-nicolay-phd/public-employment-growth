# Resultados da revisão empírica (draft 7 → draft 8)

Gerado por `code/revisao/16_relatorio.do` em 13 Nov 2026. Todo número abaixo é lido de `data/interim/revisao/kv.csv` e das bases de resultados gravadas pelos do-files.

- **Plano de análise:** `docs/PLANO_REVISAO.md`, commit `2182199` de 17/10/2026, 16h16 (UTC−3), feito antes de qualquer estimação da revisão.
- **Rotulagem:** as análises fora do plano estão marcadas como exploratórias.
- **Auditoria:** `docs/AUDITORIA_DRAFT7.md` reproduz os 1.756 números das tabelas do draft 7, com 0 diferenças acima de 0,001.

## Conclusão

A correção do timing enfraquece o resultado principal, e o artigo deve virar uma nota metodológica (cenário **B**).

1. **Timing.** Com a folha medida no último ano do período anterior e todos os controles predeterminados, o coeficiente de médio prazo é −0,142. O p-valor por cluster é 0,049, mas o wild cluster bootstrap dá 0,120 e o Romano-Wolf 0,426. Pela regra registrada, H1 é não sustentada.
2. **Viés da razão contemporânea.** É nítido e quantificável. Um numerador placebo, que só varia pelo denominador, dá −0,734, praticamente o coeficiente da razão contemporânea (−0,723). A diferença entre a razão contemporânea e a razão sobre a tendência de Hamilton é −0,707 (p < 0,001, bootstrap).
3. **Componente de preço (H2).** É o único resultado entre as hipóteses que sobrevive ao wild bootstrap e ao Romano-Wolf: no modelo em logs, −5,393 (Romano-Wolf 0,002). O componente de emprego também é negativo, e o prêmio ajustado não confirma.
4. **Cobertura e instituições.** As duas mensagens do draft 7 não se sustentam na forma em que estavam escritas.
   - Na amostra comum, a diferença entre governo geral e central está nos países unitários, e não nas federações.
   - A mitigação de Oto-Peralías e Romero-Ávila (2013) não depende do timing.

## Veredito de cada hipótese

Especificação preferida registrada no plano. IC de 95% normal com o EP por cluster.

| Hipótese | Sinal previsto | Coeficiente | IC 95% | p (cluster) | p (wild bootstrap) | p (Romano-Wolf) | Veredito |
|---|---|---|---|---|---|---|---|
| H1: Wage bill (t_p − 1), five-year growth (T3) | − | −0,142 | [−0,282; −0,003] | 0,049 | 0,120 | 0,426 | **Não sustentada** |
| H1b: Wage bill share of spending, transfers omitted | − | −0,073 | [−0,160; 0,015] | 0,109 | 0,311 | 0,541 | **Não sustentada** |
| H2: log relative public wage (log model) | − | −5,393 | [−7,447; −3,339] | < 0,001 | < 0,001 | 0,002 | **Sustentada** |
| H3: Wage bill × merit (mitigation predicted) | + | 0,066 | [−0,028; 0,159] | 0,173 | 0,382 | 0,541 | **Não sustentada** |
| H4inv: Wage bill (t_p − 1) on private investment | − | −0,352 | [−0,694; −0,010] | 0,048 | 0,076 | 0,426 | **Inconclusiva** |
| H4tfp: Wage bill (t_p − 1) on TFP growth | − | −0,033 | [−0,152; 0,086] | 0,587 | 0,689 | 0,673 | **Não sustentada** |
| H5: Predetermined election on wage bill change (democracies) | + | 0,054 | [−0,015; 0,124] | 0,131 | 0,131 | 0,541 | **Não sustentada** |

Observações sobre as hipóteses:

- **H2:** no mesmo modelo, o log do emprego público também é negativo (−3,713, p 0,004). A parte do enunciado “e o de quantidade não” não se confirma.
   - Controlando pela folha total, o salário relativo é −1,68 log mais negativo que o emprego (p 0,014).
   - Por desvio-padrão dentro do país, os efeitos são −0,81 (salário relativo) e −0,47 (emprego) ponto de crescimento.
   - Com o emprego instrumentado pelo ILOSTAT, o instrumento é fraco (F efetivo 5,93) e o salário relativo perde significância.
   - O prêmio ajustado tem coeficiente 0,246 por 0,1 log (p bootstrap 0,241).
- **H3:** o efeito mínimo detectável da interação é 0,133, contra uma magnitude economicamente relevante de 0,029. O teste não tem poder para detectar uma moderação relevante, e o nulo é um nulo mal medido.
- **H5:** a resposta do PIB em h = 4 é mais **favorável** a expansões em ano eleitoral (diferença 1,191, p 0,396), sinal oposto ao previsto.

## Cenário escolhido (seção 6.2): **B**

| Condição | Valor | Atendida |
|---|---|---|
| A: H1 sustentada em T3 | veredito: não sustentada | não |
| A: soma das defasagens 1–5 negativa (p bootstrap < 0,05) | 1,465 (p 0,174) | não |
| B: decomposição nítida (placebo negativo e significativo; contemporânea − Hamilton significativa) | placebo −0,734 (p < 0,001); diferença −0,707 (p < 0,001) | sim |
| B: réplica de Oto-Peralías e Romero-Ávila nítida (S-GMM) | contemporânea 1,035 (p 0,200); t_p − 1 0,927 (p 0,215) | não |
| B: réplica (aproximada) de Mollick e Vianna nítida | contemporânea −0,184 (p 0,017); defasada 0,013 (p 0,758) | sim |
| Sensibilidade, fora da regra (exploratória): réplica de Mollick e Vianna com a especificação publicada nítida (GE) | contemporânea −2,326 (p < 0,001); defasada −0,107 (p 0,856) | sim |
| C: primeiro estágio narrativo com F efetivo ≥ 10 | F = 8,30 | não |
| C: resposta do PIB ao corte narrativo de folha em h = 4 significativa | 0,859 (p 0,762) | não |

**Por que o cenário B:**

- H1 não sobrevive ao timing correto combinado com a inferência por bootstrap.
- A decomposição do viés atende ao critério registrado de nitidez.
- Das réplicas, só a aproximada de Mollick e Vianna é nítida. A de Oto-Peralías e Romero-Ávila não depende do timing, de modo que o viés não explica a mitigação.
- Com o texto de Mollick e Vianna obtido depois do plano, a réplica com a especificação publicada também é nítida pela mesma regra. Ela não entra na regra registrada e é reportada como sensibilidade exploratória.

O artigo passa a ser uma nota metodológica sobre o viés de razões fiscais contemporâneas e seus efeitos em resultados publicados. O coeficiente de médio prazo sai do resumo.

## O que mudou em relação ao draft 7 (ênfase no que enfraqueceu)

**Coeficiente de base.**

- O coeficiente de base do draft 7 (−0,182 com os dados originais) passa a −0,167 só pela limpeza ampliada pedida pelo parecer. A causa é uma única observação, a inflação da Bulgária em 1997 (decisão D1).
- Com a folha em t_p − 1, o coeficiente cai a −0,062 (p 0,396).
- Excluindo o primeiro ano do crescimento, cai a −0,058 (p 0,445).
- Só volta a −0,142 com os controles predeterminados, que tiram o investimento e a inflação contemporâneos. Mesmo assim, o wild bootstrap dá p = 0,120.

**Fragilidade de T3.**

- Pós-1994: −0,081.
- Painel balanceado: 0,006.
- Tendências por país: p 0,128.
- Controle de crises: p 0,142.
- Participação de saúde e educação: com o substituto do WDI, −0,431 (p < 0,001, N = 190); com o COFOG do FMI, a medida prevista no plano, −0,228 (p 0,138, N = 233).
- Todas as alterações juntas: −0,190 (p 0,586).
- S-GMM: 0,169. BC-FE: −0,099 (p 0,181).

**Frequências.** O zero anual e o coeficiente de cinco anos não se reconciliam.

- A soma das defasagens 1 a 5 é instável, por colinearidade (1,465 em % do PIB; −1,254 sobre a tendência).
- A média das defasagens como regressor único é 0,009 (p 0,962; exploratório).
- A projeção local com a folha em nível nunca é significativa.
- A projeção local do choque tem leads positivos e significativos (h = −3: 0,198, p 0,012; h = −2: 0,133, p 0,037): as expansões da folha vêm depois de quedas do PIB. No painel de cinco anos, os leads são nulos (p 0,942).

**Cobertura.**

- Na amostra comum, governo geral −0,138 (p 0,058) contra central 0,031. A diferença, −0,169 (p 0,057), vem dos países unitários (−0,241, p 0,017).
- Nas federações, a série central é a mais negativa (−0,178), o oposto do mecanismo de cobertura.

**Instituições.**

- A mitigação de Oto-Peralías e Romero-Ávila com o ICRG (efeitos fixos: 0,542, p 0,071) não muda com o consumo em t_p − 1 (0,541, p 0,051).
- A amplificação anual (réplica aproximada) some com o consumo defasado, mas sobrevive à tendência de Hamilton (−0,121, p 0,008).
- Réplica com a especificação publicada de Mollick e Vianna (exploratória, Tabela S17): com GE, a interação é −2,326 (p < 0,001) com o consumo do mesmo ano, −0,039 (p 0,950) sobre a tendência de Hamilton e −0,107 (p 0,856) com o consumo defasado. O mesmo padrão aparece com CC e RL. Aqui a amplificação some também com a correção do denominador.
   - A amostra fica perto da publicada (3.113 contra 3.141 observações), com o mesmo sinal e significância no período inteiro, mas as interações são de 2,46 a 2,86 vezes as publicadas (com GE, −2,317 contra −0,811). Sem o código dos autores, a diferença não pode ser rastreada.
   - Antes de 2008, a interação contemporânea não é significativa (−1,775, p 0,129); o artigo publicado reporta −0,755 (p 0,010).
- Oto-Peralías e Romero-Ávila com restrições ao executivo da Polity5 (exploratória, Tabela S18): a interação é nula em todos os timings (S-GMM: 0,050, p 0,426, com o consumo médio; −0,014, p 0,875, em t_p − 1). A mitigação, que o artigo original diz valer também com essa medida, não aparece nesses dados.
- A ciclicidade pré-1996 absorve só parte da interação (de −0,114 para −0,092).
- A diferença entre consumo e despesa total é de composição da amostra: na amostra comum, consumo 0,008 e despesa −0,030.

**Mérito alto nas projeções locais.**

- O coeficiente do regime de mérito alto em h = 5 (−3,624, com 647 episódios em 36 países) sobrevive sem o euro e com região × ano, mas some com todas as alterações (−0,874).
- A diferença alto − baixo em h = 5 tem p bootstrap por país 0,159 e Romano-Wolf 0,334. O p de Driscoll-Kraay (0,003) superestima a precisão.

**Longo prazo.** PMG −0,444 contra CS-ARDL 0,997 (folha defasada); sobre a tendência, PMG −0,174 e CS-ARDL −0,578. A verificação de Bond falha na amostra comum (S-GMM 0,276 > MQO 0,222).

**Composição e mecanismos.**

- Restrição orçamentária com participações em t_p − 1: transferências omitidas −0,073 (p bootstrap 0,311); investimento omitido −0,087.
- Investimento privado: −0,352 (p bootstrap 0,076); PTF: −0,033.

**O que se manteve.**

- A comparação de medidas no painel anual.
- O componente de preço no modelo em logs.
- Na curva de especificações, 210 de 216 coeficientes são negativos, mas só 94 (44%) têm IC abaixo de zero, e nenhum é positivo e significativo (mediana −0,139).

## Ledger de afirmações (seção 6.3)

| Afirmação do draft 7 | Veredito | Redação sugerida | Número que a sustenta |
|---|---|---|---|
| “explica a maior parte” | Rebaixada | “Com a folha medida no mesmo ano, o coeficiente é −0,723; um numerador placebo que só varia pelo denominador reproduz −0,734. Com a tendência de Hamilton o coeficiente é −0,016, e com o HP unilateral resta −0,423 (59% do original).” | Tabela 1; Tabela S3 |
| “perto de zero com o PIB tendencial” | Rebaixada | “perto de zero com a tendência de Hamilton (−0,016) ou com a folha defasada (−0,001); com o HP, uni ou bilateral, o coeficiente fica entre −0,423 e −0,466” | Tabela 1 |
| “uma ordem de grandeza” | Retirada | “o coeficiente contemporâneo é 1,7 vezes o obtido com o HP unilateral e 5,1 vezes o de médio prazo com o timing corrigido” | Tabelas 1 e 2 |
| “o mesmo viés explica” (instituições) | Retirada | “a amplificação encontrada com o consumo anual contemporâneo desaparece com o consumo defasado; na réplica com a especificação publicada, desaparece também com o consumo sobre o PIB tendencial; a mitigação de Oto-Peralías e Romero-Ávila não depende do timing” | Tabela 6; Tabela S17; Figura 4 |
| “concentrado no salário relativo” | Rebaixada | “no modelo em logs, o salário relativo (−5,393) e o emprego público (−3,713) estão associados a menor crescimento; o componente de preço é mais negativo (diferença −1,68), e o prêmio ajustado não confirma” | Tabela 5 |
| “o canal é o preço” | Rebaixada | “a associação é mais forte no componente de preço” | Tabela 5; Tabela S6 |
| “confirma entre países” | Rebaixada | “é compatível com a regularidade documentada em estudos nacionais” | Tabela 5 |
| “a cobertura muda a conclusão” | Rebaixada | “na mesma amostra, a série de governo central dá 0,031 contra −0,138 com a de governo geral, mas a diferença se concentra nos países unitários, e nas federações a série central é a mais negativa” | Tabela 4 |
| “vale sobretudo para renda média e alta” | Retirada | descrever a amostra (“a amostra é composta sobretudo por países de renda média e alta”) sem atribuir ao resultado | Tabela S16 |
| “reconcilia” | Retirada | “as réplicas mostram que o resultado anual de amplificação depende do timing e que o de mitigação não” | Tabela 6 |
| “o desenho foi fixado antes da estimação” | Substituída | declaração de pré-especificação baseada no commit `2182199` (ver `docs/TEXTO_SUGERIDO.md`) | `docs/PLANO_REVISAO.md` |
| Comparação de magnitude com Cavalcanti e Santos (2021) | Retirada | sem substituto: objetos não comparáveis | — |
| “custo” e “efeito” | Rebaixada | “associação” e “coeficiente” em todo o texto, inclusive no título e nos objetivos | — |
| Afirmações de prioridade (“nenhum estudo...”) | A verificar pelos autores | manter só depois de checar a literatura citada pelo parecer (Fölster e Henrekson, 2001; Lane, 2003; Afonso e Furceri, 2010; Frankel, Végh e Vuletin, 2013) | — |

## Limitações que ainda vão aparecer num parecer

- **Identificação:** não há identificação causal. O primeiro estágio narrativo (16 países da OCDE) tem F efetivo 8,30, e o eleitoral 2,33 em democracias. MONA e safras de previsão não foram obtidas.
- **Réplica de Mollick e Vianna:** a registrada no plano é aproximada. A feita com a especificação publicada (exploratória) chega perto da amostra, mas não dos coeficientes publicados: as interações replicadas são de 2,46 a 2,86 vezes as publicadas.
- **Réplica de Oto-Peralías e Romero-Ávila:** usa substitutos públicos do ICRG Bureaucracy Quality, que é pago, e não tem a origem legal como instrumento. Com as restrições ao executivo da Polity5, a mitigação não aparece.
- **Viés com o HP:** o viés medido depende do filtro. Com Hamilton, a correção é quase completa; com o HP unilateral, resta 59% do coeficiente contemporâneo.
- **Defasagem e Hamilton:** não são evidências independentes (correlação 0,96).
- **H3 sem poder:** o teste não tem poder estatístico, e H5 tem instrumento fraco.
- **Decomposição:** depende do WWBI, de cobertura irregular desde 2000, e de um instrumento fraco.
- **Projeções locais:** com bootstrap por país, as de mérito alto não são significativas após o ajuste para testes múltiplos.
- **Exploratórios:** as análises fora do plano são exploratórias: média das defasagens; ciclicidade 1996–2023; réplica de Mollick e Vianna com a especificação publicada (Tabela S17); Oto-Peralías e Romero-Ávila com a Polity5 (Tabela S18).

## Pendências

- **Downloads manuais** (`docs/DOWNLOADS_MANUAIS.md`):
   - MONA;
   - OECD EO em safras;
   - Devries et al. (2011), hoje substituída por Alesina, Favero e Giavazzi;
   - ICRG Bureaucracy Quality (pago);
   - atualização de Laeven e Valencia até 2025;
   - OCDE, Government at a Glance.
- **Obtidos em 13/11/2026:** texto de Mollick e Vianna (Tabela S17), Polity5 (Tabela S18) e COFOG do FMI (Tabela S8, linha 4b).
- **Texto:** reescrever o artigo no cenário B, com as sugestões de `docs/TEXTO_SUGERIDO.md`, e fazer as correções de redação do parecer (itens 15 e 32–42 de `docs/RESPOSTA_PARECER.md`).
- **Literatura:** acrescentar as referências omitidas (item 28).
