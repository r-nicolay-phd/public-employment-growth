# Log da preparação da submissão à Kyklos (figuras, dados e plano)

Execução de `PROMPT_Claude_Code_Kyklos_figuras_dados.md` em 13/11/2026, na pasta `Estimações` (raiz que contém `code/revisao/master.do`). Stata: `C:\Program Files\Stata17\StataMP-64.exe` (StataMP 17), em modo batch.

## Decisões gerais

- **Pasta raiz.** O prompt trata como raiz a pasta que contém `code/revisao/master.do`. As saídas novas ficam em `output/kyklos/` e `replication_kyklos/`, dentro de `Estimações`.
- **Backup.** Todo `.do` alterado foi copiado antes para `backup_kyklos/code/revisao/`. As tabelas, as figuras, o registro `kv.csv` e os relatórios internos anteriores à nova rodada foram copiados para `backup_kyklos/output/`, `backup_kyklos/data/` e `backup_kyklos/docs/`.
- **Nenhum commit.** O prompt não pede commit, e a preferência registrada do autor é só commitar quando pedido. A única operação git foi a criação da tag anotada pedida no bloco B.3, que é local (não houve push).

## Bloco A — Figuras sem rótulos internos

### A.1 Ocorrências encontradas (rótulos, títulos, legendas e notas)

Busca por `draft`, `Draft`, `rascunho`, `revis`, `rodada` e `T6: draft` em todos os `.do`, `.ado`, `.py` e `.R` do projeto.

O código do pipeline anterior (`code/*.do`, `code/extensoes/`) não gera nenhuma figura do artigo nem do apêndice e não foi alterado. Nenhum `.R` existe no projeto, e os `.ado` são pacotes de terceiros, sem ocorrências em rótulos.

Ocorrências em rótulos de **figuras**:

| Arquivo | Linha | Figura (numeração Kyklos) | Texto |
|---|---|---|---|
| `code/revisao/02_timing.do` | 216 | Figura 1 (timing) | `ylabel(6 "T6: draft 7 (t{sub:p})" ...` |
| `code/revisao/02_timing.do` | 220 | Figura 1 (timing) | `legend(order(2 "Own sample" 4 "Draft-7 baseline sample") ...` |
| `code/revisao/06_instituicoes.do` | 592 | Figura 2 (instituições) | seis rótulos `OPRA, ...` |
| `code/revisao/06_instituicoes.do` | 593 | Figura 2 (instituições) | três rótulos `OPRA (WGI), ...` e três `MV (approx.): ...` |
| `code/revisao/06_instituicoes.do` | 594 | Figura 2 (instituições) | três rótulos `MV (published spec.): ...` |

As outras 11 figuras não tinham rótulos internos.

Ocorrências em títulos, cabeçalhos, linhas e notas de **tabelas** (passo A.5):

| Arquivo | Linha | Tabela | Texto |
|---|---|---|---|
| `02_timing.do` | 116, 182, 195 | A1 (antiga 2) | `T6: draft 7`; `Same model in the draft-7 baseline sample`; nota com `(draft 7)` e `draft-7 baseline sample` |
| `03_vies.do` | 326, 370 | 1; S3 | `controls of the draft-7 baseline`; `draft-7 controls` |
| `04_cobertura.do` | 218 | 2 (antiga 4) | `draft-7 baseline sample` |
| `05_decomposicao.do` | 183, 193, 194 | 3 (antiga 5) | linha `Draft 7`; título `(revised)`; nota `draft-7 decomposition B1`, `draft-7 controls` |
| `06_instituicoes.do` | 384, 476 | A3 (antiga 6); S17 | `revision protocol`, `revision plan`; `WDI revisions` |
| `07_estrutural.do` | 164 | S8 | `(draft-7 specification)` |
| `11_longo_prazo.do` | 147, 224 | S11 | `Draft-7 timing (t_p)`; `draft-7 timing`; `in the draft came from` |
| `13_tabelas.do` | 288, 303, 447 | S14; A5 (antiga 8); S16 | `(draft-7 specification)`; `Draft-7 timing`; frase `The draft-7 table listed ...` |
| `15_documentos.do` | 45–53, 61, 79, 140–141 | S1; legendas; lista de pacotes | `Draft 7`, `Revision` (5 linhas); `extended cleaning rules of the revision`, `draft-7 baseline coefficient (see docs/DECISOES_REVISAO.md, D1)`; `Captions (revision, draft 8)`; `draft-7 baseline sample`; `used in the revision`, `draft-7 package folder` |

### A.2 e A.5 Substituições

Aplicadas com `scratchpad/kyklos_rotulos.py` (pares exatos; cada par precisava casar uma única vez). Foram 38 trocas em 9 arquivos, conforme a tabela do prompt:

- `T6: draft 7 (t_p)` / `T6: draft 7` → `T6: conventional (t_p)` / `T6: conventional`;
- `Draft-7 baseline sample` → `Conventional-specification sample`;
- `draft-7 baseline` → `conventional specification`;
- outros `Draft 7` / `draft 7` → `Conventional` / `conventional`;
- `OPRA` → `Oto-Peralías & Romero-Ávila`; `MV (approx.)` → `Mollick & Vianna (approx.)`; `MV (published spec.)` → `Mollick & Vianna (published)`.

Decisões que a tabela do prompt não cobria (sempre a opção mais conservadora):

- **`draft-7 baseline sample` dentro de frases** virou `conventional-specification sample`, com hífen, para a frase continuar gramatical, como na tabela do prompt para `Draft-7 baseline sample`.
- **`revis*`, que o prompt manda remover mas sem dizer por quê trocar:**
  - `(revised)` sai do título da Tabela 3;
  - as linhas `Revision` da Tabela S1 viram `Extended` (são as regras de limpeza ampliada);
  - `revision protocol` e `revision plan` viram `analysis plan`;
  - `WDI revisions` vira `later vintages of the WDI series`.
- **Frases sobre a história interna das versões** saem, em vez de trocar `draft` por `conventional`, que as tornaria falsas:
  - "The draft-7 table listed the 101 countries ..." (nota da S16) foi removida;
  - "in the draft came from 15 countries" virou "in the conventional specification came from 15 countries" (nota da S11);
  - `draft-7 decomposition B1` virou `conventional decomposition`, porque B1 é um código interno de modelo.
- **Remissões a documentos internos** saem das notas: `(see docs/DECISOES_REVISAO.md, D1)` e `docs/README_REPLICACAO.md`, este substituído por `the replication README`.
- **Ficaram sem troca**, porque não aparecem em nenhuma figura ou tabela:
  - tokens internos de macro (`tim == "draft"`, `A_draft`, `bond_draft_N`);
  - a mensagem de log `di "Cenario: ... OPRA ... MV"`;
  - o arquivo interno `output/revisao/MAPA_NUMERACAO.md`, que documenta a correspondência entre numerações e não vai para a revista.
- **Rótulos longos da Figura 2.** Os rótulos do eixo y já usavam 7,5 pt, menor que `labsize(small)`. A largura foi conferida na figura regerada (ver A.3).

### A.3 Regeração das figuras

- **EPS.** `rv_fig` (em `00_setup.do`) passou a exportar também EPS (`graph export ..., as(eps)`), e a figura do interflex (`08_merito.do`) ganhou a mesma linha. Estilo, tons de cinza, dimensões e resolução (largura de 4.488 px) não mudaram.
- **Rodada completa.** As figuras saem de oito do-files diferentes, que dependem do registro `kv.csv` refeito pelo `01_auditoria`. Por isso o `master.do` foi rodado inteiro, do zero.
- **Tabelas.** As tabelas de `output/revisao/tables/` foram guardadas antes da rodada e restauradas depois. As versões regeradas, que só diferem nos rótulos, ficaram guardadas para o pacote de replicação.

#### Resultado da rodada

- **Execução.** `master.do` completo do zero, em 1.817 s, sem erros.
- **Números.** Os 764 valores numéricos do registro `data/interim/revisao/kv.csv` são idênticos aos de antes da rodada (diferença máxima de 0,001: nenhuma acima).
- **Tabelas.** Os `.tex` regerados diferem dos anteriores só nos números que faziam parte de rótulos removidos: o "7" de "draft 7"/"draft-7", o "1" de "B1"/"D1" e o "101" da frase retirada da S16. Nenhuma estimativa mudou.
- **Restauração.** As tabelas de `output/revisao/tables/` foram restauradas a partir do backup, como manda o passo A.5. As versões regeradas estão em `backup_kyklos/output/revisao/tables_regeradas_rotulos/` e alimentam o pacote de replicação.
- **Figura 2, rótulos cortados.** Na primeira regeração, os rótulos longos ("Oto-Peralías & Romero-Ávila (WGI), FE: period mean") ficaram cortados na margem esquerda.
  - A quebra em duas linhas foi testada, mas o Stata ignora `labsize()` em rótulos de várias linhas e os desenhou num tamanho enorme.
  - Solução adotada: rótulos em uma linha, mesma fonte de 7,5 pt, margem esquerda maior (`graphregion(margin(l=18 r=2 t=2 b=2))`), legenda em duas linhas (`rows(2) span`) e altura de 150 mm em vez de 130 mm.
  - Só o `06_instituicoes.do` foi rodado de novo. Os `.tex` das tabelas que ele grava saíram idênticos, e elas foram restauradas outra vez.
- **Verificação.**
  - Os 13 PNGs têm 4.488 px de largura.
  - Não havia OCR disponível. O texto dos PDFs vetoriais e dos EPS de cada figura foi extraído e não contém `draft`, `Draft`, `OPRA`, `MV (`, `rascunho` nem `revis`.
  - Controle positivo: os rótulos novos ("conventional", "Oto-Peralías", "Mollick & Vianna (published)") aparecem no texto extraído.
  - As Figuras 1 e 2 foram conferidas visualmente.

### A.4 Exportação com a numeração Kyklos

`output/kyklos/figures/` tem as 13 figuras em PNG, PDF e EPS (39 arquivos), com os nomes da tabela do prompt. Todos os arquivos de origem existiam com o nome esperado. A cópia e a renomeação são feitas por `replication_kyklos/code/kyklos_numbering.py`.

### A.6 Manuscrito

`manuscript/kyklos/Kyklos_Article_Public_Wage_Bills_Growth.docx` e `..._Online_Appendix_...docx` não existem na pasta do projeto (busca por `*kyklos*` em toda a pasta do artigo). A troca de imagens não foi feita. Quando os arquivos forem colocados em `manuscript/kyklos/`, o passo pode ser executado.

## Bloco B — Dados, plano registrado e ORCID

### B.1 Pacote de replicação (`replication_kyklos/`)

**Estrutura.**
- `README.md` (modelo dos Social Science Data Editors) e `LICENSE.txt`;
- `data/raw/`, com as fontes redistribuíveis e um `SOURCE.txt` em inglês por pasta;
- `data/analysis/`, vazio;
- `code/`, `output/tables/`, `output/figures/` e `docs/`.

**Construção dos painéis.** O código da análise (`code/revisao`) parte de painéis em `data/final/`, montados pelo pipeline anterior. Para reproduzir a partir dos dados brutos, o pacote inclui em `code/build/` as etapas que constroem esses painéis: `00_setup`, `00_tabelas`, `00_rotulos`, `02_limpeza_wdi`, `02_limpeza_fmi`, `02_limpeza_trabalho`, `02_limpeza_instituicoes` e `03_painel`, além do coletor `01_coleta_fontes.py`.
- `02_limpeza_wf1_fase0.do` fica fora. É uma checagem de controle sobre o workfile da dissertação, que não é público e não alimenta os painéis.

**Código da análise.**
- `code/` traz `00_setup` a `15_documentos`, com os caminhos ajustados (`data/analysis`, `output/generated`, `output/logs`).
- No `01_auditoria`, saíram as seções F e G (comparação com versões anteriores do artigo e relatório interno), que não produzem nenhuma tabela nem figura.
- No `15_documentos`, saiu a gravação do `MAPA_NUMERACAO.md`.
- O `16_relatorio.do` não entra: só gera relatórios internos em português.
- Nenhuma especificação mudou. O montador é `scratchpad/monta_pacote.py`.

**Configuração.** `code/config.do` é o único arquivo de configuração: define o diretório e o caminho dos pacotes.

**Pacotes comunitários.** `code/ado/plus` junta a pasta da análise (`ado/plus`) e a do pipeline de construção (`code/ado/plus`), sem sobrescrever as versões da análise. A primeira tentativa de teste falhou porque `kountry`, usado na construção, só existia na pasta antiga.

**Saídas.** `output/tables/` e `output/figures/` têm as 26 tabelas (`.tex` e `.docx`) e as 13 figuras com a numeração Kyklos.
- As tabelas são as versões regeradas com os rótulos corrigidos, com títulos e remissões renumerados (Tabela 1 = antiga 1; 2 = 4; 3 = 5; A1 = 2; A2 = 3; A3 = 6; A4 = 7; A5 = 8; S1–S18 inalteradas). As figuras foram renumeradas da mesma forma (por exemplo, "Figure 9" virou "Figure 4" e "Table 6, panel A" virou "Table A3, panel A").
- As citações a tabelas de outros trabalhos ("Mollick and Vianna (2024, Table 2)", "their Table 1", "Penn World Table 11") são protegidas e não mudam.
- O cabeçalho dos `.tex` e os rótulos LaTeX (`\label{tab:...}`) passaram a usar nomes neutros e os nomes Kyklos.
- Os 2.041 números das tabelas renumeradas são idênticos aos das tabelas geradas pelo código.

**Teste de reprodução (B.1.3).**
- **Como foi feito.** Cópia limpa do pacote em `scratchpad/repl_test`, fora do Dropbox, sem `data/analysis/` e sem `output/`. Os cinco arquivos não redistribuíveis foram acrescentados, simulando um replicador que fez os downloads. O diretório vem de `code/config.do`, e o comando foi `StataMP-64.exe /e do code/master.do`.
- **Primeira tentativa.** Falhou em `build/02_limpeza_instituicoes` (`kountry` ausente). Os pacotes foram unificados, e o teste recomeçou do zero.
- **Segunda tentativa.** Rodou sem erros, em **1.859 s (cerca de 31 minutos)**: 25 s na construção dos painéis e 1.051 s no `12_inferencia`.
- **Comparação.**
  - Os 2.561 números das tabelas geradas no teste são idênticos aos das tabelas atuais (tolerância de 0,001: zero diferenças).
  - Os 756 valores numéricos do `kv.csv` também são idênticos. Os 8 valores que faltam são da auditoria interna retirada do pacote.
  - As tabelas renumeradas pelo `kyklos_numbering.py` no teste são iguais às de `replication_kyklos/output/tables/`.
- **Ressalva.** O teste usou a versão da Figura 2 anterior ao ajuste de margem e legenda (só rótulos; nenhum número).
- O tempo entrou no `README.md`.

**`data/analysis/` vazio.** Os painéis construídos combinam fontes que não podem ser redistribuídas (QoG/ICRG, Polity5), e por isso não entram. Eles são refeitos pelo `master.do`.

### B.2 Licenças

O resultado está em `replication_kyklos/docs/data_sources.csv`: 22 fontes, 17 redistribuídas e 5 não redistribuídas. Termos consultados na internet em 13/11/2026:

| Fonte | Classificação | Base |
|---|---|---|
| FMI: GFS, COFOG (subconjunto), ICSD, GDD, CTOT, Fiscal Decentralization, Fiscal Rules; Laeven e Valencia (2018) | Redistribuível | IMF Copyright and Usage (out. 2024): os dados estatísticos podem ser copiados, adaptados e redistribuídos para uso não comercial |
| WDI, WGI, WWBI, classificação de renda do Banco Mundial | Redistribuível | CC BY 4.0 |
| Penn World Table 11.0 | Redistribuível | CC BY 4.0 (DataverseNL) |
| ILOSTAT | Redistribuível | CC BY 4.0 (desde 03/05/2023) |
| V-Dem v16 (extratos de variáveis) | Redistribuível | CC BY-SA 4.0; os extratos vão sob a mesma licença |
| DPI 2020 | Redistribuível sem modificação | CC BY-NC-ND 3.0 IGO |
| Eurostat gov_10a_main | Redistribuível | CC BY 4.0 |
| QoG Standard (inclui o ICRG via QoG) e QoG Expert Survey | **Não** | Os codebooks da QoG proíbem a redistribuição; o ICRG é proprietário (PRS Group). Tratado como não redistribuível, conforme o prompt |
| Polity5 | **Não** | Center for Systemic Peace: redistribuição só com autorização escrita |
| Alesina, Favero e Giavazzi (planos de ajuste) | **Não** (termos incertos) | A cópia no Harvard Dataverse (doi:10.7910/DVN/J104NQ) está sob CC0, mas foi depositada por terceiros; os termos da base original do IGIER não estão declarados |
| UCDP/PRIO v26.1 | **Não** (termos incertos) | Nenhuma licença explícita nas páginas do provedor (só uma página de terceiros cita CC BY 4.0) |

O export completo do COFOG (530 MB) não entra; entra o subconjunto produzido por `conv_cofog.py`. Os zips completos do V-Dem também não entram.

As citações de V-Dem e QoG usam "et al." e autoria institucional. **Os autores devem conferir a lista de autores sugerida por cada provedor** antes de submeter, porque a norma APA 7 pede até 20 autores.

### B.3 Plano de análise registrado

- O commit existe: `2182199cbd7a3a4c775c06f0d5ae01f22c215218`, "Sat Oct 17 16:16:00 2026 -0300", arquivo `docs/PLANO_REVISAO.md`.
- A tag anotada `analysis-plan-2026-10-17` foi criada nesse commit. É local; não houve push.
- `replication_kyklos/docs/analysis_plan.pdf` (12 páginas) foi feito com `git show 2182199:docs/PLANO_REVISAO.md`, convertido com pandoc (md → docx) e Word (docx → PDF). Tem um cabeçalho em inglês com o hash completo, a data e a tag.
- **Conflito registrado.** O plano está em português e contém rótulos internos ("draft 7 → draft 8", "revisão"). Foi reproduzido sem nenhuma alteração, como o prompt exige ("exatamente como estava nesse commit"). Alterá-lo descaracterizaria o registro. Esta é a principal ocorrência que resta na verificação final.
- `replication_kyklos/docs/deviations_from_plan.md` lista as quatro análises exploratórias pedidas pelo prompt e as sete análises previstas e não feitas: MONA (duas), safras do OECD Economic Outlook, Herbst-Johannsen, Government at a Glance, transições do GFSM e eleições subnacionais. O prompt pedia, no mínimo, MONA e Herbst-Johannsen; as outras saíram de `docs/DECISOES_REVISAO.md`. Nenhuma entra nos veredictos da Tabela S13.
- **COFOG.** O prompt classifica a linha 4b da S8 como exploratória. O documento registra a nuance: o plano nomeava o COFOG, mas o dado chegou depois, e a linha "todas juntas" mantém o substituto registrado.

### B.4 Textos para a submissão

- `output/kyklos/submission_texts.md` traz:
  - a declaração de disponibilidade de dados no formato da Wiley, com `[REPOSITORY]`, `[DOI/URL]` e `[ID]` como marcadores, porque nada foi publicado;
  - os textos das notas 1 e 2;
  - 23 citações de dados em APA 7, incluindo o próprio pacote;
  - o bloco de autores.
- `docs/authors.csv` não existia. Foi criado com o cabeçalho e os dados conhecidos de Rodolfo Tomás da Fonseca Nicolay. O título e o endereço ficaram vazios.
- **ORCID.** Nenhum foi inventado nem procurado na internet. O validador (formato e dígito verificador ISO 7064 11-2, testado com os exemplos da documentação do ORCID) registra: ORCID de Rodolfo ausente; linhas dos dois coautores ausentes. **Os autores precisam preencher.**
- **Coautores.** Os nomes não estão em nenhum arquivo do projeto. `LICENSE.txt`, `README.md` e a citação do pacote usam `[AUTHOR 2]` e `[AUTHOR 3]`.
- **B.4.6.** O manuscrito não está na pasta (ver A.6): as notas e as referências não foram substituídas.

## Bloco C — Publicação

`docs/PUBLISH_OK.txt` não existe. Nada foi publicado. O GitHub CLI (`gh`) também não está instalado nesta máquina.

`output/kyklos/publish_commands.sh` traz os comandos para os autores. Eles publicam **só** `replication_kyklos/` num repositório novo (`kyklos-wage-bill-replication`), porque o repositório de pesquisa contém material de trabalho que não deve ser público. Também criam a tag com o hash original na mensagem e a release `v1.0-kyklos-submission`, com o `analysis_plan.pdf` anexado.

Para obter o DOI, a integração Zenodo–GitHub precisa ser ativada em https://zenodo.org/account/settings/github/ antes da release.

## Bloco D — Verificação final

### D.1 Busca por draft, Draft, rascunho, revis, OPRA e MV (

- **output/kyklos/** (figuras PNG, PDF e EPS, submission_texts.md, publish_commands.sh): nenhuma ocorrência de rótulo interno. Única ocorrência: o título "Systemic banking crises revisited" do working paper de Laeven e Valencia (2018), que é o título publicado.
- **replication_kyklos/**, fora do código: o mesmo título nas citações do README, de data_sources.csv e de data/raw/laeven_valencia/SOURCE.txt; a palavra "revised"/"revisions" no conteúdo dos próprios provedores (notas de quebra de série da ILOSTAT e nota metodológica da classificação de renda do Banco Mundial); o nome do arquivo gerado pelo código tables/TabS_opra_xconst, citado na tabela de correspondência do README; e o analysis_plan.pdf, cópia literal do plano registrado (ver B.3).
- **Código do pacote** (replication_kyklos/code/): 90 ocorrências, todas internas: 35 em comentários, 31 em nomes de macro, variável ou arquivo (opra_icrg, opra_xc, A_draft, bond_draft_N, limpeza_revisao.csv) e o restante em chaves de comparação, numa mensagem di de log e no mapa de nomes do kyklos_numbering.py. Nenhuma aparece em tabela ou figura.
- **Tabelas do pacote** (.docx e .tex): nenhuma ocorrência.

### D.2 Figuras

As 13 figuras existem nos três formatos (39 arquivos) em output/kyklos/figures/ e em replication_kyklos/output/figures/, com os nomes da tabela do Bloco A.
