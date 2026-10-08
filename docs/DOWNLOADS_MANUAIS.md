# Downloads manuais

Fontes que não puderam ser baixadas automaticamente. Nenhuma foi substituída por dados simulados. Os scripts detectam o arquivo quando ele aparece no local indicado; basta rodar `run_all.do` de novo.

| Fonte | O que falta | Endereço | Onde colocar | Status em 2026-10-07 |
|---|---|---|---|---|
| FMI, Fiscal Rules Dataset (1985–2021) | Planilha com regras de despesa, de resultado, de dívida e de receita por país e ano | https://www.imf.org/external/datamapper/fiscalrules/IMF%20Fiscal%20Rules%20Dataset%201985%20-%202021%20-%20January%202022%20rev%20Dec%2021.xlsx (página: https://www.imf.org/external/datamapper/FiscalRules/map/map.htm) | `data/raw/manual/IMF_Fiscal_Rules_Dataset_1985_2021.xlsx` | Pendente. O servidor do FMI (Akamai) devolve HTTP 403 para acesso automatizado. A variável não entra em nenhuma especificação fixada da seção 7; seria usada só como heterogeneidade. `03_painel.do` cria `rule_exp` e `rule_bb` se o arquivo existir. |

## Fontes obtidas por espelho oficial ou rota alternativa

| Fonte prevista | Rota usada | Motivo |
|---|---|---|
| UNU-WIDER Government Revenue Dataset | Variáveis `ictd_*` redistribuídas no QoG Standard Dataset (jan. 2026), que é a versão ICTD/UNU-WIDER do GRD | O site do UNU-WIDER exige formulário de registro para o download |
| QoG Expert Survey | Arquivo agregado de 2020 (`qog_exp_agg_20.csv`) | É a onda mais recente; as ondas 2008–2012 e 2014 estão em arquivos de nível individual |
| OCDE e CEPALSTAT (checagem cruzada da folha) | Eurostat `gov_10a_main` (D1PAY, S13) | Os países da OCDE estão quase todos no GFS do FMI e no Eurostat; a checagem cruzada com Eurostat cobre o objetivo. CEPALSTAT fica como extensão possível |
