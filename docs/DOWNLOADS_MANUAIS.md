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
