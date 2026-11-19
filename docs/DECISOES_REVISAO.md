# Decisões da revisão (draft 7 → draft 8)

Cada decisão registra o que foi feito, a alternativa descartada e o motivo. Os números citados vêm de `data/interim/revisao/kv.csv`, gerado pelos do-files.

## Estrutura e ferramentas

**R1. Pasta da revisão.** O repositório já tinha um pipeline numerado em `code/` (00 a 12), que reproduz o draft 7. A revisão ficou em `code/revisao/`, e as saídas foram para `output/revisao/{tables,figures,logs}`.
- Descartado: sobrescrever `code/` e `output/`.
- Motivo: o pipeline do draft 7 continua reproduzível e é a base da auditoria.
- O mapa entre as numerações está em `output/revisao/MAPA_NUMERACAO.md`.

**R2. Pacotes.** Os pacotes comunitários foram instalados em `ado/plus` por `code/revisao/00_instala.do`.
- Pacotes fora do SSC cuja instalação pela fonte do autor falhou foram copiados da pasta do draft 7 (`code/ado/plus`): `xthenreg`, `xthreg`, `bma` e `wals`.
- O `reghdfe` atual exige o pacote `require`, que foi acrescentado à lista.

**R3. Python.** O `python` do Git Bash aponta para uma instalação sem pandas. Os downloads usaram o `python3` (3.11).
- Python só baixou ou converteu arquivos. Também comparou textos de `.docx` na auditoria, o que não é estimação.

**R4. Wild cluster bootstrap.** O `boottest` não funciona depois de `reghdfe` com dois conjuntos de efeitos fixos absorvidos.
- Os efeitos de período e de ano entram como dummies (`i.period`, `i.year`), com `absorb(id)`. Os coeficientes são idênticos.
- Descartado: absorver os dois efeitos e abrir mão do bootstrap.

**R5. Romano-Wolf.** O `rwolf2` não aceita equações em bases distintas, porque a família de H1–H5 mistura o painel de cinco anos com o anual. Ele também não troca o identificador dos efeitos fixos nas reamostras.
- A implementação própria segue Romano e Wolf (2005, 2016):
  - 999 reamostras de países, comuns a todos os testes;
  - t* = (b* − b)/se*, com efeitos fixos no identificador da cópia de cada país;
  - p ajustado pelo máximo de |t*| entre os testes restantes.
- Reamostras que falham, que são raras, entram com t* = 0.
- Nas famílias de projeções locais, o t* usa erros agrupados por país, e não Driscoll-Kraay, para tornar viáveis as cerca de 14 mil regressões.

**R6. Kernel de Hainmueller, Mummolo e Xu.** O kernel do `interflex` falha com efeitos fixos: o bootstrap devolve intervalos ausentes e a rotina gráfica quebra. Com as dummies de país como covariáveis, ele não converge.
- Implementação própria: regressão local-linear com núcleo gaussiano e largura de banda escolhida pela validação cruzada do próprio `interflex` (0,4897).
- Efeitos fixos de país e período, 25 pontos de avaliação e bootstrap por país com 200 replicações.
- O estimador por faixas do `interflex` funcionou. O seu teste de Wald (p = 0,57) foi reportado junto com o teste de Wald próprio.

## Dados

**D1. Limpeza ampliada e a inflação da Bulgária em 1997.** A regra pedida torna ausente a inflação acima de 1.000%. Uma única observação, a Bulgária em 1997 (bruta acima de 1.000%, winsorizada em 709% no draft 7), muda dois resultados.
- A média de inflação do período 1994–1998 da Bulgária cai de 202% para 75%.
- O coeficiente de base do draft 7 vai de −0,182 para −0,167 (p = 0,024).
- No painel anual, a folha defasada vai de 0,040 para −0,001, pela perda dessa observação.

Pela regra 4.0.3, a base passa a ser a dos dados limpos. Com as variáveis originais, a construção da revisão reproduz exatamente −0,182, o que mostra que a diferença vem só da limpeza.

**D2. Painel de três anos.** O draft 7 começava os períodos em 1981, e o último período tinha um ano só. A revisão começa em 1979: 15 períodos, de 1979–1981 a 2021–2023.

**D3. Crises bancárias.** O site do FMI bloqueia download automático (403). Foi usada a cópia da base de Laeven e Valencia (2018) depositada no Harvard Dataverse.
- A base termina em 2017. Os anos de 2018–2023 ficam ausentes, e não zerados, o que reduz a amostra das especificações com controle de crise.
- Descartado: preencher com zero sem fonte.
- Cinco nomes de país foram casados à mão.

**D4. Consolidações narrativas.** O download da base de Devries et al. (2011) foi bloqueado. Foi usada a de Alesina, Favero e Giavazzi (2019), que segue a mesma abordagem por ações e separa o componente "Spending – Salaries".
- A cópia pública veio do pacote de replicação de Gale, Berlin e Thorpe (2025), no Harvard Dataverse.
- O choque é a soma das medidas não antecipadas e das anunciadas implementadas no ano.

**D5. Qualidade da burocracia na réplica de Oto-Peralías e Romero-Ávila.** O ICRG Bureaucracy Quality é pago. Foram usados dois substitutos:
- o WGI Government Effectiveness, como pede o roteiro. Ele só começa em 1996, então a réplica com WGI usa os períodos de 1996–2020;
- o índice ICRG de qualidade de governo distribuído pela QoG (`icrg_qog`, desde 1984), que preserva a janela original de 1981–2005.

A origem legal, um dos instrumentos excluídos deles, não está disponível e saiu. O Polity5, usado como robustez por eles, teve o download bloqueado (406).

**D6. Mollick e Vianna (2023).** O texto não foi obtido em fonte aberta. A réplica segue a especificação descrita no draft 7 e é rotulada "aproximada".

**D7. Saúde e educação.** O COFOG/GFS não foi obtido. A participação de saúde e educação na despesa usa o gasto público em saúde e em educação do WDI, dividido pela despesa total do GFS. Essa série só começa por volta de 2000, o que encolhe a amostra (190 observações).

**D8. Democracias novas.** Definidas como democracias (V-Dem polyarchy ≥ 0,5) com até 16 anos de democracia contínua, uma aproximação das quatro primeiras eleições de Brender e Drazen (2005).
- Descartado: usar a contagem de eleições do DPI, que é incompleta antes de 1975.

**D9. WWBI e timing comum.** Para cada período, folha e emprego público vêm do mesmo ano.
- A busca segue a ordem t_p − 1, t_p − 2, t_p − 3, t_p − 4, depois t_p, t_p + 1, t_p + 2 e t_p + 3.
- O prêmio salarial usa a mesma regra, aplicada só a ele.

## Especificações

**E1. Defasagens distribuídas (exploratório).** A soma das defasagens 1 a 5, pré-registrada, é instável: muda de sinal conforme o denominador, porque as defasagens e as razões com denominadores diferentes são quase colineares (correlação de 0,98 a 0,998).
- Foi acrescentado, como **exploratório**, o regressor único "média da folha de t − 5 a t − 1".
- A soma pré-registrada continua reportada e é a que entra na regra do cenário A.

**E2. Verificação de Bond.** Feita na interseção das amostras dos quatro estimadores. A diferença de países entre o S-GMM e os efeitos fixos vem dos 15 singletons.

**E3. Limiar de Seo e Shin.** A janela 2000–2019 viola a regra de proliferação de instrumentos (momentos > N/2). Só a janela 2015–2019 é interpretada.

**E4. Extensões de economia política.** Cada característica entra numa interação separada com a folha em t_p − 1, centrada na média da amostra. São sete testes, sem correção para comparações múltiplas no plano; o relatório trata esses testes como exploratórios quanto à significância conjunta.

**E5. Leitura de H5.** O plano define a hipótese pelo primeiro estágio e pela diferença das projeções locais em h = 4. O veredito formal usa o primeiro estágio em democracias, como manda a seção 2.1 do plano. A diferença em h = 4 é reportada ao lado.

## Não executado (dado indisponível)

- **Condicionalidades do FMI (MONA):** download bloqueado.
- **Erros de previsão da folha** em safras do OECD Economic Outlook.
- **Emprego público do Government at a Glance** (OCDE) como instrumento: o ILOSTAT foi usado no lugar.
- **Anos de transição do GFSM** por país.
- **Eleições subnacionais escalonadas.**
- **Programas do FMI como controle.**

## Dados obtidos depois da rodada inicial (13/11/2026)

O autor baixou à mão três fontes que estavam pendentes: o texto de Mollick e Vianna, a Polity5 e o COFOG do FMI.

**D10. COFOG.** A linha 4 da Tabela S8 era a análise prevista no plano com o COFOG, e o WDI era o substituto declarado.
- A exportação completa do portal do FMI (cerca de 530 MB) é reduzida por `code/revisao/conv_cofog.py`, só conversão de formato, ao governo geral (S13): saúde (GF07), educação (GF09) e desembolso total.
- A medida é a soma de saúde e educação em % do desembolso total.
- Entra como linha 4b, ao lado do substituto (4a). A linha "todas juntas" mantém o substituto, como estava registrada.

**D11. Polity5.** As restrições ao executivo (xconst, de 1 a 7) foram usadas na robustez de Oto-Peralías e Romero-Ávila.
- Os códigos −66, −77 e −88 viram missing.
- A chave é o código COW da QoG, com correspondência explícita para Etiópia, Vietnã, Sérvia, Montenegro, Sudão do Sul, Alemanha Ocidental e Iêmen do Norte. URSS e Iugoslavia (até 1991) ficam fora.
- **Exploratória** (Tabela S18): o plano não previa essa medida.

**D12. Mollick e Vianna com a especificação publicada.** O plano previa só a réplica aproximada, porque o texto não tinha sido obtido. Essa réplica continua sendo a que entra na regra do cenário.
- Com o texto, a especificação publicada foi estimada como **exploratória** (Tabela S17 e painel D da Tabela 6): equação (1) e Tabela 2 do artigo, os 138 países da nota da Tabela 1, séries do WDI baixadas pela API (`code/revisao/dl_wdi_mv.py`).
- O WGI não tem 1997, 1999 e 2001. Esses anos foram interpolados linearmente, porque o N publicado (3.141) implica que estão na amostra.
- Os efeitos de ano entram como regressores, para que o R² within seja comparável ao publicado.
- A mesma regra de nitidez do cenário é aplicada a ela como sensibilidade (`nit_mvf`), sem mudar o cenário.
