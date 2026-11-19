# Downloads manuais

Fontes que não puderam ser baixadas automaticamente. Nenhuma foi substituída por dados simulados. Os scripts detectam o arquivo quando ele aparece no local indicado; basta rodar `run_all.do` de novo.

| Fonte | O que falta | Endereço | Onde colocar | Status em 2026-10-14 |
|---|---|---|---|---|
| FMI, Fiscal Rules Dataset | Planilha com regras de despesa, de resultado, de dívida e de receita por país e ano | https://www.imf.org/external/datamapper/FiscalRules/map/map.htm | `data/raw/manual/` (qualquer arquivo `*Fiscal Rules*.xlsx`) | **Obtido em 2026-10-14**: atualização 1985–2024 (`Publication - IMF FAD Fiscal Rules Dataset 1985-2024 Update.xlsx`), baixada à mão porque o servidor do FMI (Akamai) devolve HTTP 403 para acesso automatizado. Limpeza em `02_limpeza_fmi.do`; usado no bloco H (`10b_regras_fiscais.do`, Tabela A10). Decisão D38. |

## Fontes obtidas por espelho oficial ou rota alternativa

| Fonte prevista | Rota usada | Motivo |
|---|---|---|
| UNU-WIDER Government Revenue Dataset | Variáveis `ictd_*` redistribuídas no QoG Standard Dataset (jan. 2026), que é a versão ICTD/UNU-WIDER do GRD | O site do UNU-WIDER exige formulário de registro para o download |
| QoG Expert Survey | Arquivo agregado de 2020 (`qog_exp_agg_20.csv`) | É a onda mais recente; as ondas 2008–2012 e 2014 estão em arquivos de nível individual |
| OCDE e CEPALSTAT (checagem cruzada da folha) | Eurostat `gov_10a_main` (D1PAY, S13) | Os países da OCDE estão quase todos no GFS do FMI e no Eurostat; a checagem cruzada com Eurostat cobre o objetivo. CEPALSTAT fica como extensão possível |

## Revisão EJPE (2026-10-17)

Fontes pedidas pelo parecer. Todas as análises que dependem de fontes sem download aparecem como "não executada – dado indisponível" nas tabelas.

| Fonte | Endereço | Onde colocar | Status |
|---|---|---|---|
| Laeven e Valencia (2018), crises bancárias sistêmicas | https://www.imf.org/en/Publications/WP/Issues/2018/09/14/Systemic-Banking-Crises-Revisited-46232 | `data/raw/laeven_valencia/` | **Obtido** por cópia pública no Harvard Dataverse (o FMI devolve 403). A atualização até 2025 (IMF WP/26/94) pode substituir a base se for baixada à mão; ela cobriria 2018–2023, hoje ausentes. |
| Devries, Guajardo, Leigh e Pescatori (2011), consolidações por ações | https://www.imf.org/external/pubs/cat/longres.aspx?sk=24892.0 | `data/raw/devries/` | **Não obtido** (403). Substituído pela base de Alesina, Favero e Giavazzi (2019), em `data/raw/afg/`, que traz o componente de salários. |
| Condicionalidades do FMI, MONA (2002–) | https://www.imf.org/external/np/pdr/mona/ | `data/raw/mona/` (exportar a tabela "Combined SPC PA SB" em formato tabulado) | **Não obtido**: download bloqueado (403); a exportação exige navegação manual. Bloco 4.9, item 2: não executado. |
| OECD Economic Outlook em safras (previsões da remuneração de empregados) | https://data-explorer.oecd.org/ (safras anteriores) | `data/raw/oecd_eo_vintages/` | **Não obtido**: não há série pública de safras dessa variável acessível ao projeto. Bloco 4.9, item 3: não executado. |
| ICRG Bureaucracy Quality | https://www.prsgroup.com/ | `data/raw/icrg/` | **Pago.** Substituído pelo índice ICRG de qualidade de governo da QoG e pelo WGI. |
| Polity5 (restrições ao executivo) | https://www.systemicpeace.org/inscr/p5v2018.xls | `data/raw/polity/` | **Obtido à mão em 2026-11-13** (`p5v2018.xls`). Usado na Tabela S18 (exploratória). |
| Mollick e Vianna (2023), texto | https://doi.org/10.1007/s11127-023-01121-5 | `Consensus/` | **Obtido em 2026-11-13** (PDF na pasta `Consensus/` do artigo). Réplica com a especificação publicada na Tabela S17 (exploratória). |
| OCDE, Government at a Glance (emprego público) | https://data-explorer.oecd.org/ | `data/raw/oecd_gag/` | **Não obtido**; o emprego público do ILOSTAT foi usado como instrumento. |
| IMF GFS COFOG (saúde e educação) | https://data.imf.org/ | `data/raw/imf_cofog/` | **Obtido à mão em 2026-11-13** (exportação completa do portal); reduzido por `code/revisao/conv_cofog.py`. Tabela S8, linha 4b. |

Guia passo a passo para as fontes que continuam pendentes: `docs/Passo_a_passo_downloads_manuais.docx`.
