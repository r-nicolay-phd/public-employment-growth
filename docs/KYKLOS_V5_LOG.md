# Log das reestimações do parecer da versão 5 (Kyklos)

Execução de `PROMPT_Claude_Code_Kyklos_reestimacoes_v5.md` a partir de 17/11/2026. Stata 17 (StataMP, modo batch), na pasta `Estimações`.

## Registro

- **Quarto adendo.** `docs/plan_addendum_kyklos_4.md`, escrito antes de qualquer estimação e commitado sozinho.
  - Hash: `fb6c84b1fa0293f197deeafe6735fe974004ebf1`
  - Data: 17/11/2026, 13:23:55 (−0300)
- **Código das rodadas anteriores.** `code/kyklos/`, `code/kyklos2/` e `code/kyklos3/` foram commitados (mensagem "Add code of addenda 1-3 (committed after estimation; see timeline)").
  - Hash: `54e4ccf285ba952ef5a82f2ac43a850bcc4f691e`
  - Data: 17/11/2026, 13:23:55
  - Esse commit é posterior às estimações dessas rodadas; está na linha do tempo.
- **Antes do commit do adendo, nenhuma estimação.** Só houve leitura de código e de saídas anteriores.

## Decisões durante a execução

**Bloco 0.**
- **Código do quarto adendo.** `code/kyklos4/` foi commitado antes da rodada final: `d28c3db55cf0653507fc84a759f5a8ba5410b825`, 17/11/2026 13:53:56. As rodadas de teste, com poucas replicações, vieram antes desse commit (o primeiro commit do código e o adendo são anteriores a elas); depois do commit, o código não mudou até a rodada final.
- **Tag para o bundle.** Criei a tag leve `kyklos-addendum-4` em `fb6c84b` para gerar `registration_osf/repo_until_addendum4.bundle` (verificado). O bundle anterior, até o terceiro adendo, foi mantido.
- **Pacote de depósito.** O PDF do adendo foi gerado de HTML com PyMuPDF; o `.md` é cópia exata do commit. `registration_timeline.md` (seção 5) e `README_OSF.md` foram atualizados.

**Bloco 1.**
- **Desvio padronizado com k = 0.** A simulação é determinística, então o DP simulado é zero. Para a distância, o desvio padronizado é calculado com DP mínimo de 1e−9, o que torna o momento muito distante quando a média difere do observado. Sem essa regra, a distância de k = 0 seria artificialmente zero.
- **Grade ψ.** Usa 200 replicações por célula (adendo) e roda o ponto escolhido com 1.000. Só os momentos e os coeficientes usados na distância são calculados na grade.

**Bloco 2.** O "primeiro período de reporte" é o primeiro período em que o país tem a folha das GFS em t_p − 1. A transição usa a lista de economias de `code/kyklos/07_equivalencia.do`.

**Bloco 3.**
- **Holm.** O Stata em modo batch não executa `shell`, então o ajuste de Holm foi feito em Stata (`03b_holm.do`), lendo o `.tex` da Tabela A10 (base), o `.csv` de influência da A9 e o painel de tamanho da A15. São 38 coeficientes.
- **LP-IV.** Como o F efetivo fica abaixo de 10, o IC de Anderson-Rubin é calculado com `weakiv` sobre `ivreg2` com dummies de país e ano e erros agrupados por país.

**Bloco 5.**
- **Safras do WDI.** As safras de dez/2022 e dez/2023 vêm da API do Banco Mundial (source 57, WDI Database Archives), por `code/kyklos4/dl_wdi_vintage.py`. A primeira tentativa foi interrompida pelo limite de tempo do terminal depois de gravar a de 2022; a de 2023 foi baixada numa segunda execução. O artigo de Mollick e Vianna não informa a data de acesso.
- **System GMM de Mollick e Cabral (Bloco 4).** Usa dois passos com correção de Windmeijer, como registrado no adendo. A Tabela A6 original usava um passo robusto.


## Rodada final

**`master_kyklos4.do` numa sessão limpa.** Terminou em 8.927 s (2 h 29 min), sem erros, com estes tempos:

| Etapa | Tempo |
|---|---|
| `01_grade_k` | 4.239 s |
| `01b_psi` | 3.177 s |
| `01c_resumo_k` | 118 s |
| `02_quinquenal` | 6 s |
| `02b_nula` | 668 s |
| `03_escala` | 264 s |
| `04_grade_mc` | 8 s |
| `05_inst` | 426 s |
| `03b_holm` | 0 s |
| `07_tabelas_k4` | 21 s |

**Regras do Bloco 7** (kv.csv):

| Item | Resultado |
|---|---|
| Fração contábil | `full range` |
| Defasada | `keep` |
| ψ | `not identified` |
| Primeiro período | ≥ 2/3 (105%) |
| Viés nos 355 | < 0,05 |
| Escala comum | compatível |
| WWBI | seção 4.3 (Holm 0,876) |
| Grade | significativa (p = 0,005) |
| Instituições | `replicated` (razão mínima 2,03) |

## Correções depois da rodada final

Nenhuma estimativa mudou. Commit `4874e52` (07_tabelas_k4.do), 16:29:16. O estágio 07 foi rodado de novo, sozinho e sem erros.

**Figura 1.**
- Títulos dos painéis (b) e (c) estavam cortados.
- A legenda cobria a série de Hamilton e os picos das densidades; as legendas foram para baixo dos painéis.

**Tabela A4, parte nova.**
- **Leitura da regra.** `kv4` lia a regra com `kget`, que devolve só a última palavra ("range"). Por isso o título dizia que o desenho "reproduz os dados". `kv4` passou a ler o valor inteiro.
- **Título.** Passou a dizer que a regra vale em ε = 0,48: com ε = 0,25, k = 1 reproduz os dois momentos.
- **Letras dos painéis.** Eram H–J, que já existiam na A4; passaram a K–M.
- **Linha das elasticidades.** Estava vazia por causa de uma expressão aninhada.

**Tabela A9.**
- O p de Holm do −0,334 saía vazio, por erro de digitação na chave (`b3_holm_p334`).
- A linha "LP − quinquenal" mostrava 27,9. Passou a "Not computed: the projection is not identified".

**Tabela A7.** Os rótulos das diferenças estavam truncados no `.dta` (`str40` com `−` multibyte). Foram completados na tabela.

**Tabela A6.** Título: "smaller in absolute value".

**Tabela A8.** Saiu a letra "K." do bloco novo (as outras partes da A8 não têm letras).

**`final_v5.py`.**
- Troca "A (main):" por "A (anchored design, unscaled residuals):" na nota da A4.
- "(main)" passa a ser padrão proibido.
- O p do −1,858 (amostra estrita, folha fixa) passa a 0,063 também na parte "reverse-denominator" da A15 (era 0,064, de outro sorteio do mesmo modelo).

## Verificação

- **Exibições finais.** `python code/kyklos4/final_v5.py`: 19 tabelas e 7 figuras em `output/kyklos4/final/`, 0 ocorrências proibidas.
- **Memorando.** `python code/kyklos4/confere_memo4.py`: 120 itens conferidos, 0 divergências. Os itens com três casas decimais também são procurados como texto no memorando.
- **Contagem.** Texto principal: 2 tabelas e 4 figuras. Apêndice: 17 tabelas (limite 18) e 3 figuras.
- **Revisão visual.** Figura 1, Figura A3, Figuras 2–4, A1 e A2 (nenhuma com nota embutida). Partes novas das Tabelas A4, A6, A7, A8, A9, A12, A13 e A14.

## Pacote de replicação

**Código e dados.**
- `replication_kyklos/code/kyklos4/`: cópia com os caminhos do pacote (`data/analysis/...`, `output/generated/...`, `output/logs/...`, `code/config.do`).
- `data/raw/wdi_archives/`.

**Documentos.**
- `docs/plan_addendum_kyklos_4.md`;
- `registration_timeline.md`;
- `deviations_from_plan.md` (seção 8).

**Saídas.** `output/final/`, com as exibições da versão 5 por cima das da versão final; os nomes coincidem e a Figura A3 é nova.

**README.**
- semente 20261117;
- passo 7, com tempo de 8.927 s;
- seção "Numbering of version 5";
- linha das safras do WDI em `docs/data_sources.csv`.

A numeração das linhas das listas do README, citada nas notas das tabelas, foi conferida e não mudou.
