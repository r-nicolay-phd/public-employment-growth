# Log das estimações do parecer da versão final (Kyklos)

Execução de `PROMPT_Claude_Code_Kyklos_estimacoes_parecer_final.md` a partir de 16/11/2026. Stata 17 (StataMP, modo batch), na pasta `Estimações`.

## Registro antes de estimar

- **Terceiro adendo:** `docs/plan_addendum_kyklos_3.md`, commitado sozinho com a mensagem pedida.
  - Hash: `c402c35c7a051094634c5f469ef08ee5539014c9`
  - Data: 16/11/2026, 19:26:08 (−0300)
  - Branch: `revisao-ejpe`
- **Antes do commit, nenhuma estimação.** Só houve:
  - consultas ao git (linha do tempo);
  - leitura de datas de arquivos;
  - um teste da API das GFS para saber se a compensação de empregados em moeda nacional (G21, XDC) está disponível.
- **Linha do tempo:** `docs/registration_timeline.md`.

## Linha do tempo: o que o git mostra

**O plano.** O plano (2182199, 17/10 16:16:00) foi commitado antes de todos os do-files de estimação registrados (02–16, a partir de 16:19:36). Os logs commitados desses blocos foram abertos depois de 16:16. A exceção é o `01_auditoria.do` (16:14:10), que só reproduz as estimativas anteriores.

**Exceções: especificações anteriores estimadas antes do plano.** Os commits dc8cd8f (7/10) e 781942e (17/10 15:57) trazem especificações anteriores de:
- H1: média quinquenal com a folha no primeiro ano;
- a comparação mesmo ano × medidas predeterminadas (TableA7_denominator: −0,686 contra 0,03–0,04);
- H2: decomposição em níveis;
- H3: moderação pelo mérito;
- H5: economia política;
- H4: tamanho do governo × instituições (L1);
- longo prazo (L2).

As especificações preferidas registradas são outras. Mesmo assim, a primeira forma da frase ("nenhum resultado anterior") não é verdadeira, e usa-se a segunda forma, com as exceções.

**Os adendos 1 e 2.** O código e as saídas dos adendos 1 e 2 (`code/kyklos`, `code/kyklos2`) não estão no git. As datas do sistema de arquivos são todas posteriores aos commits dos adendos:
- primeiro resultado intermediário: 17:57:16, contra o commit de 17:55:25 (13/11);
- primeiro resultado intermediário: 13:47:07, contra o commit de 13:45:23 (16/11).

Essas datas, porém, não são verificáveis pelo git.

**Commits.** Nenhum commit foi alterado, e só o terceiro adendo foi commitado.

## Decisões durante a execução

**Bloco 0 (registro).**
- **Pacote de depósito.** `registration_osf/` contém:
  - o plano e os três adendos como cópias exatas (`git show <hash>:<arquivo>`, conferidas com `cmp`) e em PDF;
  - a linha do tempo;
  - `repo_until_addendum3.bundle` (verificado com `git bundle verify`);
  - `README_OSF.md`.
- **PDFs.** A conversão pelo Word travou (o processo iniciado pelo script foi encerrado pelo PID). Os PDFs foram gerados de HTML (pandoc) com PyMuPDF; o texto exato está nos `.md`.
- **O que o bundle contém.** Só arquivos versionados: código, documentos, logs e saídas da revisão de outubro. Não traz dados brutos (apenas os `_SOURCE.txt`), mas inclui o nome e o e-mail do autor dos commits. Os autores devem saber disso antes de depositar.
- **Desvios.** A seção 6 de `docs/deviations_from_plan.md` declara que o desenho ancorado é posterior ao resultado do desenho registrado. A seção 7 lista as análises do adendo 3.

**Bloco 1.**
- **Amostra (b).** O primeiro período com par WWBI na amostra do H2 começa em 1999, por isso a amostra (b) usa períodos com início em 1999 ou depois. O período "2000–2004" do prompt não coincide com a grade quinquenal (1979 + 5p).
- **Amostra (c).** A folha GFS em t_p − 1 falta em parte da amostra do H2: 173 de 199 país-períodos têm a folha em t_p − 1.

**Bloco 2, origem dos valores de ε.**
- **0,48 (folha).** Vem de `code/revisao/03_vies.do` (painel C da antiga tabela de decomposição): 100 × Δln da folha nominal sobre 100 × Δln do PIB nominal, efeitos fixos de país e ano, Driscoll-Kraay, |variações| < 200. A diferença em log é calculada depois de restringir a 1996–2023, então o primeiro ano útil é 1997: 1.774 país-anos, coeficiente 0,4839.
  - O 0,520 da Tabela A3 (`code/kyklos/02_outras_razoes.do`) é a mesma regressão com as diferenças calculadas antes do corte, de modo que 1996 entra: 1.814 país-anos, 0,5198. A diferença é só o ano de 1996.
- **0,556 (consumo).** É ε_0 do mecanismo da Tabela A13: elasticidade do consumo na média das instituições numa regressão com a interação com o WGI, 1996–2023, só país-anos com WGI (3.708).
  - O 0,701 da Tabela A3 é a elasticidade do consumo sem a interação, sem exigir o WGI (4.131 país-anos).
- **Calibração.** Os dois critérios de calibração (DP dentro do país e AR(1)) escolhem o menor valor da grade registrada, k = 0,30.
  - Com k = 0,30 o DP dentro do país fica em 0,971, contra 0,976 observado. O AR(1) fica em 0,961, contra 0,970: o alvo do AR(1) não é atingido dentro da grade.
  - Os dois desenhos calibrados têm o mesmo k e diferem só pelos sorteios.
- **Consumo.** Também k = 0,30, nas duas séries (painel D e painel C).

**Bloco 4.** O F efetivo do 2SLS com a inflação do deflator instrumentada vem do `weakivtest` depois de `ivreg2` com erros agrupados por país; a inferência do coeficiente usa Driscoll-Kraay (`ivreghdfe`, banda 4).

**Bloco 5.**
- **Amostra comum.** Exige o crescimento de p − 1 e as razões de t_p − 2 e t_p − 3: 311 país-períodos. Nela, o próprio T3 é muito menor que na amostra completa (−0,02 contra −0,14).
- **Bootstrap.** Cada sorteio de países reestima os observados e roda uma nova simulação de cada desenho da nula nos países sorteados (999 sorteios). A média da nula vem de 1.000 simulações na amostra inteira.

**Bloco 6.** As linhas "ICRG/QoG 1996–2020" e "common sample" da parte inferior da Tabela A13 são iguais porque todo país-período com o índice ICRG/QoG também tem WGI (480 = 480 observações). São a mesma estimativa, não um erro de cópia. Recomenda-se fundir as duas linhas.

**Bloco 7.**
- **Série nova.** A compensação de empregados das GFS em moeda nacional (G21, S13, XDC) e o PIB nominal do WEO (NGDP) foram baixados da API do FMI (`code/kyklos3/dl_fontes.py`, `data/raw/imf_gfs_xdc/`, `data/raw/imf_weo_ngdp/`).
- **A razão com o PIB do WEO não é um teste independente.** Ela coincide com a das GFS em quase todos os país-anos (mediana da razão entre as duas = 1,000; quartis 1,000): as GFS já usam o PIB do WEO. A verificação com fonte realmente diferente é a da Penn World Table.
- **Crescimento da PWT.** A própria defasagem do crescimento da PWT substitui a do WDI entre os controles.

**Bloco 8.**
- **Figura A2 (influência).** Os rótulos traziam "T3", então ela foi regenerada em `10_tabelas_k3.do` a partir do mesmo arquivo de resultados (`data/interim/kyklos/influencia.dta`), com os mesmos números.
- **Tabelas na numeração final.** `code/kyklos3/numeracao_final.py` gera as tabelas com a numeração final em `output/kyklos3/final/` a partir de cópias. Os arquivos de `output/kyklos` e `output/kyklos2` não são alterados.

## Rodada final e verificação

**Rodada.** `code/kyklos3/master_kyklos3.do`, numa sessão limpa do Stata, em 16/11/2026, sem nenhum erro. Tempo total: 3.633 s (≈61 min).

| Etapa | Tempo |
|---|---|
| 01_tamanho | 455 s |
| 02_simulacao_calibrada | 1.339 s |
| 03_inst_calibrada | 352 s |
| 04_controles_pred | 11 s |
| 05_defasagens | 8 s |
| 06_vies_comum | 1.439 s |
| 07_inst_celulas | 1 s |
| 08_fontes | 9 s |
| 09_conferencia | 4 s |
| 10_tabelas_k3 | 12–15 s |

Depois do master, só uma frase da nota da Tabela A4 foi corrigida (a descrição de ε = 0,71), e o `10_tabelas_k3.do` foi rodado de novo; nenhum número mudou.

**Rodada isolada do Bloco 2.** Uma execução isolada anterior (a mesma semente) terminou antes de o master chegar ao Bloco 2. Os resultados usados são os do master.

**Verificação.**
- **Números do memorando:** `code/kyklos3/confere_memo3.py` confere 94 números de `output/kyklos3/RESULTS_MEMO_FINAL2.md` contra os `.csv` e o `kv.csv`. Nenhuma divergência; uma, 54% contra 53,5%, foi corrigida no memorando antes da conferência final.
- **Rótulos:** `code/kyklos3/numeracao_final.py` gera as 19 tabelas e as 6 figuras com a numeração final em `output/kyklos3/final/`. A verificação automática não encontra nos textos visíveis numeração antiga, rótulos internos (T1–T6, B1), caminhos de arquivo, "draft", "revision" ou "review".
- **Títulos e notas:** as tabelas novas e as finais mais alteradas (A2, A8, A15, A10) foram renderizadas e conferidas visualmente.
- **Caracteres de controle:** uma edição feita pelo shell gravou caracteres de controle no lugar de `\b` e `\1` em `numeracao_final.py`. Foi corrigida, e uma varredura confirmou que nenhum outro arquivo de código ou documento os contém.

**Pacote de replicação.**
- `replication_kyklos/code/kyklos3/` (caminhos do pacote);
- `data/raw/imf_gfs_xdc/` e `data/raw/imf_weo_ngdp/`;
- `docs/plan_addendum_kyklos_3.md` e `docs/registration_timeline.md`;
- `output/final/` (tabelas e figuras na numeração final);
- README: passos 6–8, seção "Numbering of the final version", semente 20261116;
- `docs/deviations_from_plan.md`: seções 6 e 7.

Como antes, o código do pacote não foi rodado dentro dele, e o `numeracao_final.py` do pacote supõe a estrutura de pastas do projeto. Isso está dito no README.

**Commits.** Nenhum além do terceiro adendo (`c402c35`).
