# Auditoria dos dados

Gerado por `code/04_descritivas.do` em 15 Oct 2026. Não editar à mão: todo número abaixo sai do código.

## 1. Regras de limpeza (na ordem aplicada)

| Regra | Descrição | Países | Obs. país-ano 1996–2023 (R4: 1980–2023) | Obs. com folha |
|---|---|---|---|---|
| 1a | Agregados regionais e de renda (lista do Banco Mundial) | 43 | 1204 | 0 |
| 1b | Territorios dependentes sem contas fiscais proprias | 20 | 560 | 0 |
| 2 | Microestados (populacao < 500 mil; mantidos so para robustez) | 29 | 812 | 176 |
| 3 | Folha > 30% do PIB ou despesa > 100% do PIB tratadas como ausentes | 4 | 18 | 18 |
| 4_g | Winsorizacao de g em p1 = -17.63 e p99 =  16.33 | . | 137 | . |
| 4_infl | Winsorizacao de infl em p1 =  -4.29 e p99 = 709.35 | . | 138 | . |
| 5 | Marcados (nao excluidos): anos de guerra (UCDP intensidade 2) = 217; hiperinflacao (>100%) = 48 | . | . | . |

Observações eliminadas pela regra 3 (folha acima de 30% do PIB ou despesa acima de 100% do PIB, valores do GFS antes da regra): Irã 1986–1989 (folha de 34% a 41% do PIB no GFS contra 9% a 12% do PIB na série de governo central do WDI, erro de fonte evidente), Ilhas Marshall 2009, Nauru 2015–2023 e Timor-Leste 2010–2012, 2016, 2021–2022 (despesa acima de 100% do PIB, financiada por fundos de recursos naturais ou doações). Ilhas Marshall e Nauru são microestados e já estavam fora da amostra principal. A lista completa está em `output/logs/03_painel.log`.

## 2. Tamanho das amostras

| Amostra | Países | Observações |
|---|---|---|
| Anual, folha GG, 1996–2023, sem microestados (principal) | 102 | 1891 |
| Anual, folha GG, com microestados | 115 | 2059 |
| Anual, folha GG ou GC (série combinada), sem microestados | 153 | 3215 |
| Anual, folha GC (WDI, como na dissertação), sem microestados | 134 | 2811 |
| Anual, folha GG, subamostra `income_grp == 1` | 25 | 260 |
| Anual, folha GG, subamostra `income_grp == 2` | 33 | 568 |
| Anual, folha GG, subamostra `income_grp == 3` | 14 | 300 |
| Anual, folha GG, subamostra `income_grp == 4` | 30 | 763 |
| Anual, folha GG, subamostra `oecd == 1` | 37 | 968 |
| Anual, folha GG, subamostra `oecd == 0` | 65 | 923 |
| Anual, folha GG, subamostra `federal == 1` | 16 | 337 |
| Anual, folha GG, subamostra `federal == 0` | 86 | 1554 |
| Anual, folha GG, subamostra `resource_rich == 1` | 17 | 198 |
| Anual, folha GG, subamostra `resource_rich == 0` | 85 | 1693 |
| Médias de 5 anos, folha GG no 1º ano, sem microestados | 101 | 421 |
| Médias de 3 anos, folha GG no 1º ano, sem microestados | 101 | 700 |

**Ponto de verificação (seção 6).** A folha do governo geral cobre 102 países e 1891 observações anuais na amostra principal, acima dos limites de 80 países e 1.200 observações. A variável principal é a de governo geral pura; a série combinada (governo geral ou, na falta, central, com dummy de cobertura) entra como robustez.

## 3. Cobertura por variável (amostra principal: 1996–2023, sem microestados)

| Variável | Obs. | Países | Primeiro ano | Último ano | Renda baixa | Média-baixa | Média-alta | Alta |
|---|---|---|---|---|---|---|---|---|
| `g` | 4599 | 167 | 1996 | 2023 | 1742 | 1375 | 614 | 868 |
| `wagebill_gdp` | 1891 | 102 | 1996 | 2023 | 260 | 568 | 300 | 763 |
| `wagebill_share` | 1876 | 101 | 1996 | 2023 | 259 | 564 | 296 | 757 |
| `wagebill_cyc` | 1891 | 102 | 1996 | 2023 | 260 | 568 | 300 | 763 |
| `d_wagebill_real` | 1815 | 101 | 1996 | 2023 | 230 | 537 | 293 | 755 |
| `wagebill_comb` | 3215 | 153 | 1996 | 2023 | 987 | 953 | 466 | 809 |
| `wagebill_cg_wdi` | 2811 | 134 | 1996 | 2023 | 784 | 859 | 434 | 734 |
| `wwbi_wagebill_gdp` | 3446 | 159 | 2000 | 2022 | 1246 | 1040 | 460 | 700 |
| `pubemp_share` | 1095 | 129 | 2000 | 2022 | 258 | 388 | 218 | 231 |
| `relwage` | 716 | 74 | 2000 | 2021 | 74 | 254 | 157 | 231 |
| `wwbi_prem_all` | 811 | 106 | 2000 | 2022 | 164 | 304 | 154 | 189 |
| `ilo_pubemp_share` | 1218 | 117 | 1996 | 2023 | 365 | 415 | 228 | 210 |
| `merit` | 4593 | 167 | 1996 | 2023 | 1728 | 1420 | 614 | 831 |
| `impartial` | 4656 | 167 | 1996 | 2023 | 1764 | 1438 | 614 | 840 |
| `wgi_ge` | 4166 | 168 | 1996 | 2023 | 1572 | 1276 | 543 | 775 |
| `hc` | 3864 | 138 | 1996 | 2023 | 1428 | 1036 | 532 | 868 |
| `inv` | 4118 | 159 | 1996 | 2023 | 1432 | 1271 | 608 | 807 |
| `open` | 4219 | 161 | 1996 | 2023 | 1499 | 1274 | 584 | 862 |
| `infl` | 4626 | 167 | 1996 | 2023 | 1742 | 1402 | 614 | 868 |
| `popg` | 4704 | 168 | 1996 | 2023 | 1764 | 1456 | 616 | 868 |
| `ctot_g` | 4410 | 159 | 1996 | 2023 | 1697 | 1278 | 603 | 832 |
| `ipriv` | 3634 | 154 | 1996 | 2019 | 1417 | 1006 | 493 | 718 |
| `tfp_g` | 3248 | 116 | 1996 | 2023 | 896 | 980 | 532 | 840 |
| `privemp_g` | 929 | 73 | 1996 | 2023 | 180 | 340 | 209 | 200 |
| `debt` | 4406 | 162 | 1996 | 2023 | 1679 | 1292 | 600 | 835 |
| `exp_gdp` | 1894 | 102 | 1996 | 2023 | 259 | 576 | 302 | 757 |
| `rev_gdp` | 1932 | 103 | 1996 | 2023 | 285 | 580 | 310 | 757 |
| `balance_gdp` | 1899 | 102 | 1996 | 2023 | 264 | 576 | 302 | 757 |
| `sh_inv` | 1900 | 102 | 1996 | 2023 | 265 | 576 | 302 | 757 |
| `sh_transf` | 1568 | 95 | 1996 | 2023 | 265 | 537 | 185 | 581 |
| `election` | 3987 | 162 | 1996 | 2020 | 1532 | 1230 | 500 | 725 |
| `election_fixed` | 3946 | 162 | 1996 | 2020 | 1500 | 1222 | 500 | 724 |
| `grd_tax` | 4012 | 160 | 1996 | 2023 | 1570 | 1144 | 524 | 774 |

## 4. Países com dado por ano (amostra principal)

| Ano | Folha GG | Folha GC (WDI) | Emprego público (WWBI) | Prêmio (WWBI) | Mérito (V-Dem) | WGI | Eleição predeterminada |
|---|---|---|---|---|---|---|---|
| 1996 | 40 | 71 | 0 | 0 | 157 | 163 | 155 |
| 1997 | 40 | 71 | 0 | 0 | 157 | 0 | 157 |
| 1998 | 41 | 77 | 0 | 0 | 158 | 163 | 156 |
| 1999 | 40 | 79 | 0 | 0 | 159 | 0 | 157 |
| 2000 | 45 | 75 | 23 | 18 | 159 | 163 | 154 |
| 2001 | 48 | 82 | 31 | 23 | 159 | 0 | 157 |
| 2002 | 57 | 87 | 35 | 29 | 159 | 164 | 156 |
| 2003 | 63 | 91 | 38 | 30 | 159 | 164 | 158 |
| 2004 | 62 | 94 | 41 | 27 | 159 | 165 | 158 |
| 2005 | 62 | 91 | 55 | 41 | 166 | 165 | 155 |
| 2006 | 65 | 95 | 49 | 38 | 166 | 167 | 157 |
| 2007 | 66 | 95 | 56 | 43 | 166 | 167 | 157 |
| 2008 | 70 | 100 | 62 | 49 | 166 | 167 | 158 |
| 2009 | 71 | 105 | 62 | 50 | 166 | 167 | 159 |
| 2010 | 72 | 110 | 63 | 52 | 166 | 167 | 157 |
| 2011 | 73 | 110 | 67 | 52 | 167 | 168 | 160 |
| 2012 | 74 | 116 | 66 | 60 | 167 | 168 | 162 |
| 2013 | 75 | 112 | 62 | 52 | 167 | 168 | 160 |
| 2014 | 79 | 121 | 62 | 51 | 167 | 168 | 159 |
| 2015 | 80 | 124 | 63 | 51 | 167 | 168 | 160 |
| 2016 | 79 | 124 | 54 | 47 | 167 | 168 | 159 |
| 2017 | 82 | 125 | 50 | 40 | 167 | 168 | 159 |
| 2018 | 85 | 123 | 53 | 33 | 167 | 168 | 160 |
| 2019 | 87 | 122 | 50 | 8 | 167 | 168 | 158 |
| 2020 | 88 | 119 | 39 | 6 | 167 | 168 | 158 |
| 2021 | 84 | 113 | 13 | 10 | 167 | 168 | 0 |
| 2022 | 83 | 101 | 1 | 1 | 167 | 168 | 0 |
| 2023 | 80 | 78 | 0 | 0 | 167 | 168 | 0 |

Os valores do WGI para 1997, 1999 e 2001 são interpolados linearmente (marcados em `wgi_interp`). O DPI termina em 2020: as variáveis eleitorais não existem para 2021–2023.

## 5. Folha do governo geral contra governo central (% do PIB, média 2010–2019)

| País | Governo geral (GFS) | Governo central (WDI, dissertação) | Governo central (GFS) | WWBI | Eurostat (S13) | Razão GG/GC (WDI) |
|---|---|---|---|---|---|---|
| BRA |  11.2 |   2.7 |   2.7 |   9.8 | – |  4.1 |
| USA |   9.2 |   2.3 |   2.3 |   9.6 | – |  4.0 |
| DEU |   7.7 |   1.8 |   1.8 |   7.8 |   7.9 |  4.4 |
| IND | – |   1.4 |   1.4 |   1.1 | – | – |
| ARG | – |   3.0 |   3.0 |  11.2 | – | – |
| MEX |   5.1 |   2.4 |   2.4 |   5.3 | – |  2.1 |
| CAN |  12.1 |   2.0 |   2.0 |  12.1 | – |  6.2 |
| FRA |  12.2 |   8.8 |   8.8 |  12.7 |  12.9 |  1.4 |
| ZAF |  13.1 |   4.6 |   4.6 |  10.4 | – |  2.9 |
| IDN |   5.1 | – |   2.3 |   5.3 | – | – |

Nos países federais (Brasil, Estados Unidos, Alemanha, Índia, Argentina, México, Canadá), a série de governo central do WDI usada na dissertação capta só uma fração da folha do governo geral. A diferença é menor em países unitários.

## 6. Verificação da decomposição da folha

- `relwage` = folha (% do PIB, GFS) / emprego público (% do emprego total, WWBI). O produto `pubemp_share × relwage` reproduz `wagebill_gdp` com discrepância máxima de  7.70e-07 pontos percentuais em 716 observações; a identidade é algébrica por construção, pois o mesmo emprego total entra no numerador e no denominador.
- Verificação com fonte independente: a folha implícita no ILOSTAT (salário médio mensal dos empregados públicos × 12 × emprego público, % do PIB) dividida pela folha do GFS tem mediana 0.81 (p25 = 0.62, p75 = 0.97, 532 observações). Valores abaixo de 1 são esperados: o salário do ILOSTAT exclui contribuições sociais do empregador, que fazem parte da remuneração de empregados no GFS, e as pesquisas domiciliares cobrem mal os níveis subnacionais.
- Folha do WWBI contra folha do GFS: correlação 0.90 em 1587 observações (o WWBI combina fontes de governo central e geral conforme o país).

## 7. Downloads que falharam

Ver `docs/DOWNLOADS_MANUAIS.md`. Falha registrada pelo script de coleta (`data/raw/_falhas.txt`):

- Nenhuma falha nas fontes automáticas. O FMI Fiscal Rules Dataset (atualização 1985–2024) foi obtido por download manual (o servidor bloqueia acesso automatizado); 123 países listados, membros do FMI ausentes codificados sem regra; 1979–1984 reconstruídos pelo ano de implementação (decisão D38).
