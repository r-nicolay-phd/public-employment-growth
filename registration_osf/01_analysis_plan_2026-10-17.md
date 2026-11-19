# Plano de análise da revisão (draft 7 → draft 8)

Este plano foi escrito e commitado antes de qualquer estimação nova da revisão. Ele lista todas as especificações, a especificação preferida e o sinal previsto de cada hipótese, e as regras de decisão. Tudo o que for estimado depois deste commit e não estiver listado aqui será reportado como **exploratório**. As análises anteriores (dissertação e drafts 1 a 7) são tratadas como exploratórias.

**Já feito antes deste plano** (commit `abd544b`, bloco 4.0):
- a auditoria e a reprodução do draft 7;
- a limpeza ampliada;
- a construção dos painéis da revisão;
- as amostras S5_base (365 obs., 72 países) e S1_base (1.593 obs.).

Nenhum coeficiente novo foi estimado na auditoria, exceto as regressões do draft 7 refeitas para diagnosticar inconsistências. Os resultados dessas regressões estão em `docs/AUDITORIA_DRAFT7.md`.

## 0. Convenções

### Painéis

- Painel de cinco anos: períodos não sobrepostos de 1979–1983 a 2019–2023. t_p é o primeiro ano do período p, e t_p − 1 é o último ano do período anterior.
- Painel de três anos: períodos de 1979–1981 a 2021–2023.
- Painel anual: 1996–2023. Os microestados ficam fora em todas as amostras principais.

### Variáveis

- **Crescimento:** média aritmética das taxas anuais do PIB per capita real (WDI, winsorizadas). O período só é aceito com pelo menos 3 de 5 anos (2 de 3 no painel de três anos).
- **Folha:** remuneração de empregados do governo geral (FMI GFS), em % do PIB.
- **Filtros de tendência do log do PIB real:**
  - Hamilton com (H, k) = (2, 2), estimado por país. É a medida de referência para o denominador porque é predeterminado.
  - HP unilateral com λ = 6,25, recursivo.
  - HP bilateral com λ = 6,25, só como robustez.

### Controles

| Conjunto | Composição |
|---|---|
| Predeterminados (T3) | log do PIB per capita em t_p − 1 (*InitialGDP*); capital humano, investimento, abertura, inflação, crescimento populacional e crescimento dos termos de troca, todos em t_p − 1 |
| Contemporâneos (draft 7) | renda inicial; capital humano em t_p; médias do período de investimento, abertura, inflação, população e termos de troca |
| Painel anual | os mesmos controles defasados um ano, mais o crescimento defasado |

### Erros-padrão

- **Cinco e três anos:** agrupados por país. A distribuição de referência é t com G − 1 graus de liberdade.
- **Painel anual:** Driscoll-Kraay com defasagem máxima 3. A distribuição de referência é t com T − 1 graus de liberdade.
- **Wild cluster bootstrap:** por país, com pesos de Webb, 9.999 replicações e semente 20261017.
- **Romano-Wolf:** com `rwolf2` e 999 replicações (bootstrap por país).

### Comparações e resultados ausentes

- Toda comparação entre medidas ou estimadores é feita na amostra própria de cada um e numa amostra comum.
- Se uma especificação falhar por falta de dado ou por erro de estimação sem solução, ela é reportada como "não executada", com o motivo.

## 1. Hipóteses, sinal previsto e especificação preferida

| Hipótese | Enunciado e sinal previsto | Especificação preferida | Coeficiente avaliado |
|---|---|---|---|
| H1 | A folha predeterminada está associada a menor crescimento de médio prazo (β < 0). | **T3**: folha em t_p − 1, controles predeterminados, efeitos fixos de país e período, médias de cinco anos | β da folha em t_p − 1 |
| H1b (composição) | Realocar despesa de outra categoria para a folha está associado a menor crescimento (β < 0). | Restrição orçamentária com participações em t_p − 1 e controles predeterminados; categoria omitida: transferências (versão principal) e investimento | β da participação da folha |
| H2 | O componente de preço (salário relativo) está associado a menor crescimento (β < 0), e o de quantidade (emprego) não. | Modelo em logs, crescimento sobre log *PubEmp* e log *RelWage* no mesmo ano (o mais próximo de t_p − 1), amostra harmonizada com o prêmio, controles de T3 | β de log *RelWage* |
| H3 | O recrutamento meritocrático atenua a associação entre folha e crescimento (interação > 0). A previsão concorrente (interação < 0) é testada no mesmo modelo, bilateralmente. | Interação folha (t_p − 1) × mérito (t_p − 1) centrado na média da amostra, controles de T3 | β da interação |
| H4 | A folha predeterminada está associada a menor investimento privado e menor crescimento da PTF (β < 0). | T3 com investimento privado (média do período, % do PIB) e crescimento da PTF (PWT) como dependentes. O investimento sai dos controles nas duas. | β da folha em t_p − 1 em cada equação |
| H5 | A folha cresce em anos de eleição com calendário predeterminado (β > 0), e expansões em ano eleitoral têm resposta do PIB mais negativa que as demais. | Primeiro estágio (variação real da folha sobre eleição predeterminada) e projeção local por tipo de choque, só em democracias (V-Dem polyarchy ≥ 0,5) | β do primeiro estágio; diferença das respostas em h = 4 |

## 2. Regras de decisão

### 2.1 Vereditos

O veredito de cada hipótese usa a especificação preferida:

- **Sustentada:** coeficiente com o sinal previsto e p < 0,05 pelo wild cluster bootstrap, e o resultado sobrevive ao Romano-Wolf na família de testes principais.
- **Inconclusiva:** sinal previsto com 0,05 ≤ p < 0,10, ou p < 0,05 que não sobrevive ao Romano-Wolf.
- **Não sustentada:** nos demais casos.

Regras particulares:

- **H3:** o veredito usa o sinal previsto (interação > 0). Se a interação for negativa com p < 0,05, o relatório diz que a previsão concorrente tem apoio.
- **H4:** a hipótese é sustentada para cada variável dependente separadamente.
- **H5:** exige o primeiro estágio com o sinal previsto e p < 0,05. O uso do calendário como instrumento exige F efetivo de Montiel Olea–Pflueger ≥ 10.

As famílias do Romano-Wolf são duas:

1. Os testes principais de H1, H1b, H2, H3, H4 (investimento), H4 (PTF) e H5 (primeiro estágio).
2. Os sete horizontes (h = 0 a 6) de cada projeção local por regime de mérito e por tipo de choque.

### 2.2 Enquadramento (seção 6.2 do pedido)

| Cenário | Condição | Enquadramento |
|---|---|---|
| A | H1 sustentada em T3 **e** soma das defasagens 1 a 5 da folha no painel anual (especificação 4.2.6, folha em % do PIB) negativa com p < 0,05 (wild bootstrap) e IC de 95% que contém o coeficiente de T3 | Viés de medida e associação residual, com o timing corrigido |
| B | H1 não sustentada ou inconclusiva em T3, mas a decomposição do viés (4.2) e as réplicas (4.5) são nítidas | Nota metodológica sobre o viés de razões fiscais contemporâneas; o −0,18 sai do resumo |
| C | O instrumento narrativo ou outra fonte de variação exógena (4.9) tem F efetivo ≥ 10 no primeiro estágio, ou a resposta acumulada do PIB per capita ao choque narrativo de folha em h = 4 é significativa a 5% (Driscoll-Kraay) | Economia política da folha, com a variação exógena no centro |
| Combinações | Se A e C ocorrerem, prevalece C. Se B e C ocorrerem, usa-se C com a decomposição do viés como seção de medida. | |

Uma decomposição é **nítida** se cumprir dois critérios:

- o coeficiente do numerador placebo for negativo com p < 0,05;
- a diferença "contemporânea − Hamilton" for significativa a 5% (wild bootstrap).

As réplicas (4.5) são nítidas se, na réplica, a interação com a medida contemporânea tiver o sinal publicado e p < 0,10 e, com a medida predeterminada, perder a significância.

## 3. Lista de especificações

Os códigos [Pn] remetem aos itens prioritários do parecer.

### 3.1 Timing da medida inicial e controles predeterminados (bloco 4.1) [P7, P25]

Todas as variantes usam médias de cinco anos, efeitos fixos de país e período e erros agrupados por país. Cada uma é estimada na amostra própria e em S5_base.

| Variante | Medida da folha | Crescimento | Controles |
|---|---|---|---|
| T1 | t_p − 1 | média do período | do draft 7 |
| T2 | t_p | média de t_p + 1 a t_p + 4 | do draft 7 |
| T3 (preferida de H1) | t_p − 1 | média do período | predeterminados |
| T4 | t_p − 1 | média do período | predeterminados, sem investimento |
| T5 | t_p − 1, sobre o PIB tendencial de Hamilton | média do período | predeterminados |
| T6 (draft 7) | t_p | média do período | do draft 7 |

Também se estimam:

- o painel de três anos com T3 e T6;
- o painel anual com a folha defasada e todos os controles defasados um ano.

Saídas: tabela "Timing" e figura de coeficientes.

### 3.2 Decomposição do viés contemporâneo (bloco 4.2) [P3–P6, P8, P10, P12]

Todas as especificações usam o painel anual da Tabela 1 (S1_base), com efeitos fixos de país e ano, crescimento e renda defasados e os controles do draft 7, e erros de Driscoll-Kraay.

1. **Numerador placebo.** A razão W̃/Y é a folha real do ano anterior crescendo à taxa média do país, dividida pelo PIB corrente.
2. **Decomposição multiplicativa.** Regressores separados: log(W/Y*) e log(Y*/Y), com Y* de Hamilton.
3. **Medidas da Tabela 1 acrescidas do HP unilateral.** As medidas são: contemporânea, HP bilateral, HP unilateral, Hamilton, defasada e defasada sobre Hamilton. No painel de cinco anos: média do período, t_p, t_p − 1 e t_p − 1 sobre Hamilton.
4. **Rebote.**
   - No painel anual: a folha defasada sobre o PIB tendencial de Hamilton.
   - No painel de cinco anos: a folha em t_p − 1 sobre o PIB tendencial.
5. **Diferenças entre medidas.** O modelo é empilhado em formato longo, com um indicador de medida, os coeficientes da folha por medida e efeitos fixos de país × medida e ano × medida. O wild cluster bootstrap por país (Webb, 9.999 replicações) testa quatro diferenças:
   - contemporânea − Hamilton;
   - contemporânea − defasada;
   - contemporânea − HP unilateral;
   - defasada − Hamilton.

   Reporta-se também a correlação entre a folha defasada e a folha sobre Hamilton.
6. **Defasagens distribuídas.** Folha nas defasagens 1 a 5:
   - em % do PIB;
   - separadamente, sobre o PIB tendencial de Hamilton.

   Reporta-se cada coeficiente e a soma de 1 a 5, com IC pelo método delta (Driscoll-Kraay) e pelo wild cluster bootstrap por país, na mesma especificação com efeitos fixos e erros agrupados.
7. **Projeção local com a folha em nível.** A folha entra em t − 1, sobre o PIB tendencial de Hamilton, para h = 0 a 6, com efeitos fixos de país e ano, duas defasagens do crescimento e Driscoll-Kraay.
8. **Antecipação.**
   - No painel de cinco anos: crescimento de p sobre a folha em t_{p+1} (equivalente a crescimento de p − 1 sobre a folha em t_p) e crescimento de p sobre a folha em t_{p+1} − 1. Ambos com os controles de T3.
   - No painel anual: projeção local da variação acumulada do PIB de t − 1 a t + h, para h = −3 a −1, sobre o choque de folha.
9. **Rigidez da folha.**
   - Elasticidade da folha nominal ao PIB nominal, no painel anual com efeitos fixos de país e ano.
   - O coeficiente contemporâneo da Tabela 1 excluindo os anos de recessão (crescimento do PIB per capita < 0).

Saídas: tabelas "Decomposição do viés", "Diferenças entre medidas" e "Defasagens distribuídas e leads"; figura de projeções locais com nível e leads.

### 3.3 Cobertura: governo geral × central (bloco 4.3) [P9]

- **Amostra:** a especificação preferida de H1 (T3) é estimada com a folha de governo geral e com a de governo central (WDI), em t_p − 1, em S5_common_GC (países-períodos com as duas séries).
- **Grupos:** repete-se separadamente para federações e para países unitários, dentro de S5_common_GC.
- **Igualdade dos coeficientes:** testada por bootstrap pareado por país (999 replicações), estimando as duas equações em cada reamostra.
- **Razão geral/central:** reportada por país (média 2010–2019) e por grupo, com o número de federações em cada amostra.
- **Federações:**
  - Definição única: a lista do Forum of Federations usada no draft 7 (28 países).
  - Contagens a reconciliar: 15 (federações com as duas séries em 2010–2019) e 12 (federações na amostra de base).
- **Heterogeneidade nas federações:** interação folha × federação, e exclusão de uma federação por vez.

Saída: tabela "Cobertura na amostra comum".

### 3.4 Decomposição emprego × salário (bloco 4.4) [P2, P19, P26]

1. **Timing comum.** Folha e emprego público vêm do mesmo ano, o mais próximo de t_p − 1, com prioridade para anos anteriores (até t_p − 4) e depois t_p a t_p + 3. Reporta-se quantos pares precisam de um ano diferente de t_p − 1, e reestima-se só com os pares em t_p − 1 exato.
2. **Logs.** O crescimento é regredido sobre log *PubEmp* e log *RelWage*, com os controles de T3. Essa é a preferida de H2.
3. **Escala.** Todas as magnitudes são convertidas pelo desvio-padrão dentro do país na amostra de estimação.
4. **Viés de divisão.**
   - (a) log *PubEmp* do WWBI é instrumentado com o emprego público do ILOSTAT (mesmo ano), com F efetivo de Montiel Olea–Pflueger. Para a OCDE, *Government at a Glance* fica como não executado se o dado não for obtido.
   - (b) Modelos separados de emprego e de salário relativo, cada um controlando pela folha total.
   - (c) *RelWage* calculado sobre o PIB por trabalhador tendencial (Hamilton).
5. **Prêmio.** O prêmio ajustado do WWBI é reescalado para 0,1 ponto log e para 1 DP dentro do país. *RelWage* e *Premium* são estimados na mesma amostra. O prêmio contra os assalariados privados formais entra como alternativa.
6. **Folha total.** Estimada na mesma amostra do modelo B1.

Saída: tabela "Decomposição emprego × salário (revisada)".

### 3.5 Instituições e tamanho do governo: réplicas e mecanismo (bloco 4.5) [P1, P3]

**Réplica de Oto-Peralías e Romero-Ávila (2013).** O texto foi obtido: working paper INFER 2012/3, em `Consensus/oto_peralias_romero_avila_2012wp.pdf`. A especificação deles é:

- painel de médias de cinco anos de 1981–1985 a 2001–2005;
- crescimento sobre consumo do governo (% do PIB, WDI, média do período), qualidade da burocracia e interação;
- controles: renda inicial, matrícula secundária e investimento;
- efeitos de período;
- System GMM com consumo, interação e investimento endógenos, e a razão de dependência e a origem legal como instrumentos excluídos.

A réplica faz quatro substituições:

- o ICRG Bureaucracy Quality, que é pago, é trocado por dois substitutos públicos, ambos declarados: o WGI Government Effectiveness, como pede o roteiro, disponível a partir de 1996; e o índice ICRG de qualidade de governo via QoG (`icrg_qog`, 0–1, desde 1984);
- a origem legal não está disponível e sai dos instrumentos;
- o S-GMM é estimado em dois passos, com instrumentos colapsados.

Primeiro reproduz-se o modelo com o consumo médio do período (contemporâneo). Depois troca-se **apenas** a medida do consumo pelo valor em t_p e em t_p − 1. As mesmas trocas são feitas com efeitos fixos (MQO com efeitos de país e período).

**Réplica de Mollick e Vianna (2023).** O texto não foi obtido em fonte aberta. A réplica segue a especificação descrita no draft 7 (painel anual de 1996 a 2019, consumo do governo × qualidade institucional do WGI, efeitos fixos e Driscoll-Kraay) e é rotulada **réplica aproximada**. O artigo não afirmará que o resultado deles "é explicado".

**Mecanismo de ciclicidade fiscal.**

- A ciclicidade do consumo real do governo é estimada por país em 1970–1995: coeficiente da variação do log do consumo real sobre o hiato do produto (HP).
- No painel anual de 1996–2023, o consumo contemporâneo é interagido com instituições e com a ciclicidade, e verifica-se se a ciclicidade absorve a interação com instituições.
- O mesmo é feito com a ciclicidade estimada em 1996–2023, como robustez exploratória do mecanismo.

**Despesa total.** O consumo (WDI) e a despesa total (GFS) são estimados na mesma amostra de países-anos. A diferença entre as interações se decompõe em composição da amostra e conceito de gasto.

Saídas: tabelas "Réplicas" e "Instituições e ciclicidade fiscal"; figura de reconciliação.

### 3.6 Explicações estruturais e de crise (bloco 4.6) [P11]

T3 e as projeções locais por regime de mérito são reestimadas com cada alteração abaixo, uma de cada vez e depois todas juntas:

1. tendências lineares por país;
2. efeitos fixos de região (Banco Mundial) × período;
3. razão de dependência de idosos (WDI, em t_p − 1);
4. participação de saúde e educação na despesa total. O COFOG/GFS não foi obtido; o substituto, declarado, é o gasto público em saúde e educação do WDI dividido pela despesa total do GFS, em t_p − 1;
5. exclusão da zona do euro em 2008–2013. Nos cinco anos, sai o período 2009–2013 dos membros do euro; no anual, os anos 2008–2013 dos membros;
6. amostra a partir de 1994: no painel de cinco anos, os períodos de 1994–1998 em diante (rótulo "pós-1994"); no painel anual, a amostra já começa em 1996;
7. anos de transição do GFSM: os metadados de mudança de manual por país não estão nos dados baixados, então o item fica "não executado". O item 6 cobre a quebra de 1986;
8. painel balanceado (países presentes desde o primeiro período da amostra própria) e indicador dos dois primeiros períodos de cada país;
9. crises bancárias (Laeven e Valencia, 2018: indicador de crise no período) e programas do FMI. O MONA não foi obtido (download bloqueado), então programas do FMI ficam "não executado".

Nas projeções locais por regime, reportam-se o número de episódios distintos (país-anos com choque diferente de zero) e de países que sustentam a estimativa em h = 5.

Saídas: tabela "Robustez estrutural" e figura de coeficientes.

### 3.7 Moderação pela burocracia (H3, bloco 4.7) [P29]

- **Centragem:** o mérito em t_p − 1 é centrado na média da amostra de estimação, e o ponto de avaliação é declarado.
- **Efeito mínimo detectável** da interação, com poder de 80% e α = 5%, igual a 2,8 × EP. É comparado com metade do coeficiente de base de T3 dividida pela distância entre os percentis 10 e 90 do mérito.
- **Diagnóstico HMX** com `interflex`: estimador por faixas (tercis) e por kernel, teste de Wald de linearidade e histograma do moderador.
- **Tercis:** explica-se a diferença entre os tercis do HMX (um modelo com interações por faixa) e a divisão da amostra (modelos separados).
- **Limiares:**
  - Seo e Shin (2016) via `xthenreg`, no painel anual balanceado, com teste de linearidade por bootstrap (500 replicações) e defasagens colapsadas;
  - Hansen (1999) via `xthreg`, com 500 replicações;
  - divisão de amostra na mediana.

### 3.8 Economia política (H5 e extensões, bloco 4.8) [P29, P30]

**Ciclo eleitoral.**

- **Amostras:** democracias (V-Dem polyarchy ≥ 0,5), e democracias novas (até 16 anos de democracia contínua, aproximação das primeiras quatro eleições de Brender e Drazen) e antigas.
- **Primeiro estágio:** com F efetivo de Montiel Olea–Pflueger e Kleibergen-Paap.
- **Segundo estágio:** IC de Anderson-Rubin.
- **Instrumentos alternativos:** eleição predeterminada. As eleições subnacionais escalonadas ficam "não executado", porque os dados públicos subnacionais não estão disponíveis no projeto.
- **Interação** do choque eleitoral com o mérito.

**Extensões**, todas reportadas. Cada uma é uma interação da folha em t_p − 1 com a característica em t_p − 1, nos controles de T3:

- ideologia do executivo (DPI `execrlc`, executivo de esquerda);
- competitividade (maioria do governo, `maj`, e fracionamento, `frac`, do DPI);
- idade da democracia;
- densidade sindical (ILOSTAT);
- clientelismo (V-Dem `v2dlencmps`, maior = mais programático);
- administração imparcial (`v2clrspct`).

Saída: tabela "Economia política da folha".

### 3.9 Variação exógena (bloco 4.9) [P1]

**Consolidações narrativas.** A base usada é a de Alesina, Favero e Giavazzi (2019), com o componente "Spending – Salaries" dos planos de ajuste em 16 países da OCDE, 1978–2014. Ela substitui a de Devries et al. (2011), cujo download foi bloqueado; as duas compartilham a abordagem por ações. O choque de folha é a soma das medidas não antecipadas e das anunciadas implementadas no ano, em % do PIB de t − 1, com valor positivo para corte.

- **Projeção local** do PIB per capita (100 × log) e do investimento privado (% do PIB), h = 0 a 6, com efeitos fixos de país e ano, duas defasagens do crescimento e Driscoll-Kraay. Controle pelas medidas narrativas de gasto não salarial e de tributos no mesmo ano.
- **Primeiro estágio:** a variação real da folha (GFS) é instrumentada pelo choque narrativo, com F efetivo.

**Condicionalidades do FMI (MONA).** Não executado: download bloqueado. Registrado em `DOWNLOADS_MANUAIS.md`.

**Erros de previsão (OECD Economic Outlook em safras).** Não executado: não há série pública de previsão da remuneração de empregados por safra acessível ao projeto.

Saídas: tabela e figura "Variação exógena".

### 3.10 Longo prazo, Bond e GMM (bloco 4.10) [P22, P23]

- **Verificação de Bond** em S5_bond, a interseção das amostras de estimação de MQO, efeitos fixos, S-GMM e BC-FE: com a folha em t_p e com a de T3 em t_p − 1. Explica-se a diferença de países entre o S-GMM e os efeitos fixos (singletons).
- **Longo prazo:** PMG, MG, DFE, CCE-MG e CS-ARDL(1,1) com a folha defasada e com a folha defasada sobre o PIB tendencial de Hamilton, no painel anual (países com 20 anos ou mais).
- **Teste CD de Pesaran** nos resíduos dos modelos anuais: Tabela 1, contemporânea e defasada.

### 3.11 Inferência (bloco 4.11) [P30]

- **Wild cluster bootstrap** por país (Webb, 9.999 replicações) para o coeficiente principal de cada hipótese.
- **Romano-Wolf** nas duas famílias da seção 2.1.
- **Curva de especificações** para o coeficiente da folha, cruzando:
  - medida: t_p, t_p − 1 e t_p − 1 sobre Hamilton;
  - controles: contemporâneos, predeterminados e predeterminados sem investimento;
  - frequência: 3 e 5 anos;
  - amostra: completa, com microestados, sem períodos com crise bancária e pós-1994;
  - efeitos fixos: país + período; + tendências por país; + região × período.

  São 3 × 3 × 2 × 4 × 3 = 216 especificações. A figura ordena os coeficientes, com IC de 95% e o painel de escolhas.
- **Projeções locais:** inferência com defasagens aumentadas (uma defasagem extra do choque e erros robustos à heteroscedasticidade, Montiel Olea e Plagborg-Møller). Correção do viés de efeitos fixos com T curto por jackknife de meio painel (metades temporais 1996–2009 e 2010–2023; estimador corrigido 2β − média das metades). Não há pacote Stata para Herbst e Johannsen (2024), e isso é declarado.
- **Driscoll-Kraay:** todas as tabelas informam a defasagem máxima (3) e a distribuição de referência.
- **BMA:** refeita na amostra efetiva de T3 (após o descarte dos singletons), com `bma` e `wals`. A probabilidade de inclusão mede robustez à escolha de controles, não endogeneidade.

## 4. Tabelas e figuras

O formato segue o padrão EJPE/Elsevier da seção 5 do pedido: inglês, sinal de menos U+2212, três casas, estrelas padronizadas, N e países por coluna, efeitos fixos e tipo de EP em linhas padronizadas. A numeração segue a seção 5.2 do pedido. As figuras saem em PDF vetorial e PNG a 600 dpi, com 90 ou 190 mm, legíveis em preto e branco.

## 5. Ledger de afirmações (seção 6.3 do pedido)

As afirmações do draft 7 contestadas pelo parecer recebem veredito (mantida, rebaixada ou retirada) com o número que o sustenta. As afirmações de prioridade ("nenhum estudo…") ficam marcadas como "a verificar pelos autores".
