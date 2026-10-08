* 04_descritivas.do -- Tabela 1, tabelas de apendice, Figuras 1 e 2, cobertura e docs/AUDITORIA_DADOS.md
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/04_descritivas.log", replace text

use "$FINAL/painel_anual.dta", clear
gen byte main = micro == 0 & inrange(year, 1996, 2023)

* ---------------------------------------------------------------- Tabela 1
local T1 g wagebill_gdp wagebill_share wagebill_cyc d_wagebill_real pubemp_share relwage wwbi_prem_all ///
    merit wgi_ge lny hc inv open infl popg ctot_g ipriv tfp_g privemp_g debt exp_gdp rev_gdp balance_gdp election_fixed
label var election_fixed "Predetermined election year (0/1)"
label var lny "Log GDP per capita"
label var inv "Investment (% of GDP)"
label var open "Trade openness (% of GDP)"
label var popg "Population growth (%)"
label var wwbi_prem_all "Public wage premium (log points)"
label var merit "Meritocratic recruitment (V-Dem)"
label var wgi_ge "Government effectiveness (WGI)"
label var debt "Public debt (% of GDP)"
label var exp_gdp "Total expenditure (% of GDP)"
label var rev_gdp "Total revenue (% of GDP)"
label var balance_gdp "Fiscal balance (% of GDP)"
label var hc "Human capital index (PWT)"
tab_new, ncol(7) head1("Mean" "SD overall" "SD between" "SD within" "Min" "Max" "N")
foreach v of local T1 {
    quietly xtsum `v' if main
    local lab : variable label `v'
    local r ""
    foreach s in mean sd sd_b sd_w min max {
        local x : display %9.3f r(`s')
        local r `"`r' "`=strtrim("`x'")'""'
    }
    local n : display %9.0fc r(N)
    tab_row "`lab'" `r' "`=strtrim("`n'")'"
}
tab_out Table1_descriptives, title("Table 1. Descriptive statistics, annual panel") ///
    notes("Annual country-year observations, 1996-2023, excluding microstates (population below 500,000). SD between is the standard deviation of country means; SD within is the standard deviation of deviations from country means. Growth and inflation winsorized at the 1st and 99th percentiles. Wage bill: compensation of employees of the general government (IMF GFS). Public employment, relative wage and premium: World Bank Worldwide Bureaucracy Indicators.")

* desvio-padrao dentro do pais da folha (usado no tamanho de efeito)
quietly xtsum wagebill_gdp if main
scalar sdw_wb = r(sd_w)
use "$FINAL/painel_5anos.dta", clear
quietly xtsum wagebill_gdp0 if micro == 0
scalar sdw_wb5 = r(sd_w)
clear
set obs 1
gen sdw_wb_annual = sdw_wb
gen sdw_wb_5yr = sdw_wb5
save "$INTERIM/efeito_sd.dta", replace

* ---------------------------------------------------------------- Apendice: definicoes e fontes
tab_new, ncol(2) head1("Definition" "Source")
tab_row "GDP per capita growth" "Annual growth of real GDP per capita (%)" "WDI (NY.GDP.PCAP.KD.ZG)"
tab_row "Wage bill (% of GDP)" "Compensation of employees, general government (GFSM 2014 code 21)" "IMF GFS, Statement of Operations"
tab_row "Wage bill (% of total expenditure)" "Compensation of employees / (expense + net investment in nonfinancial assets)" "IMF GFS"
tab_row "Wage bill (% of trend GDP)" "Wage bill x GDP / trend GDP; HP filter (lambda 6.25) or Hamilton (h=2, p=2) on log real GDP" "IMF GFS; WDI"
tab_row "Real wage bill change" "Change in real wage bill (GDP deflator) as % of previous-year real GDP" "IMF GFS; WDI"
tab_row "Wage bill, central government" "Compensation share of expense x expense (% of GDP), central government" "WDI (GC.XPN.COMP.ZS, GC.XPN.TOTL.GD.ZS)"
tab_row "Public employment" "Public sector employment (% of total employment)" "WWBI (BI.EMP.TOTL.PB.ZS)"
tab_row "Relative public wage" "Wage bill (% of GDP) / public employment share: pay per public worker relative to GDP per worker" "IMF GFS; WWBI"
tab_row "Public wage premium" "Conditional public-private wage gap vs all private employees (log points)" "WWBI (BI.WAG.PREM.PB.GP)"
tab_row "Meritocratic recruitment" "Criteria for appointment decisions in the state administration (v2stcritrecadm)" "V-Dem v16"
tab_row "Government effectiveness" "WGI estimate (1997, 1999, 2001 linearly interpolated)" "WGI"
tab_row "Log initial GDP per capita" "Log real GDP per capita in the year before the period" "WDI (NY.GDP.PCAP.KD)"
tab_row "Human capital" "Human capital index (years of schooling and returns)" "PWT 11.0"
tab_row "Investment" "Gross fixed capital formation (% of GDP)" "WDI (NE.GDI.FTOT.ZS)"
tab_row "Trade openness" "Exports plus imports (% of GDP)" "WDI (NE.TRD.GNFS.ZS)"
tab_row "Inflation" "CPI inflation (GDP deflator where CPI missing), winsorized" "WDI"
tab_row "Population growth" "Annual population growth (%)" "WDI (SP.POP.GROW)"
tab_row "Commodity terms of trade" "Growth of commodity net export price index, GDP-weighted, fixed weights" "IMF CTOT (Gruss and Kebhaj)"
tab_row "Private investment" "Private gross fixed capital formation (% of GDP)" "IMF ICSD"
tab_row "TFP growth" "Growth of TFP at constant national prices" "PWT 11.0 (rtfpna)"
tab_row "Private employment growth" "Growth of total minus public employment, same survey" "ILOSTAT"
tab_row "Public debt" "General government gross debt (% of GDP); central where general missing" "IMF Global Debt Database"
tab_row "Election year" "Executive election (presidential systems) or legislative election (others)" "DPI 2020"
tab_row "Predetermined election" "Election held in the year the constitutional term expires (years left in term = 0)" "DPI 2020"
tab_row "Income group" "World Bank analytical classification for 1996 data" "World Bank (OGHIST)"
tab_row "Federal" "Federal country (28 federations, including Spain and South Africa)" "Forum of Federations"
tab_row "Resource rich" "Natural resource rents above 10% of GDP (1996-2023 mean)" "WDI (NY.GDP.TOTL.RT.ZS)"
tab_out TableA1_definitions, title("Table A1. Variable definitions and sources") landscape

* ---------------------------------------------------------------- Apendice: paises por grupo de renda
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0 & !missing(g, wagebill_gdp0)
collapse (firstnm) iso3 income_grp, by(id)
label define inc 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income", replace
label values income_grp inc
decode income_grp, gen(grp)
replace grp = "Unclassified" if grp == ""
tab_new, ncol(2) head1("Countries (ISO3)" "N")
levelsof grp, local(G)
foreach gg of local G {
    quietly levelsof iso3 if grp == "`gg'", local(L) clean
    local n : word count `L'
    tab_row "`gg'" "`L'" "`n'"
}
tab_out TableA2_countries, title("Table A2. Countries in the main five-year sample, by 1996 income group") landscape

* ---------------------------------------------------------------- Apendice: matriz de correlacao
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
local C g wagebill_gdp0 merit0 lny0 hc0 inv open infl popg ctot_g
quietly correlate `C'
matrix R = r(C)
local k : word count `C'
local hd ""
forvalues j = 1/`k' {
    local hd `"`hd' "(`j')""'
}
tab_new, ncol(`k') head1(`hd')
forvalues i = 1/`k' {
    local v : word `i' of `C'
    local lab "${LBL_`v'}"
    if "`lab'" == "" local lab : variable label `v'
    local r ""
    forvalues j = 1/`k' {
        if `j' > `i' local r `"`r' """'
        else {
            local x : display %6.2f R[`i', `j']
            local r `"`r' "`=strtrim("`x'")'""'
        }
    }
    tab_row "(`i') `lab'" `r'
}
tab_out TableA3_correlations, title("Table A3. Correlation matrix, five-year panel") landscape ///
    notes("Pairwise correlations over five-year periods with all variables observed, excluding microstates.")

* ---------------------------------------------------------------- Figura 1: folha por grupo de renda
use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023) & !missing(wagebill_gdp, income_grp)
collapse (median) wb = wagebill_gdp (count) n = wagebill_gdp, by(income_grp year)
twoway (connected wb year if income_grp == 1, lcolor("$C1") mcolor("$C1") msymbol(O) msize(small) lpattern(solid)) ///
       (connected wb year if income_grp == 2, lcolor("$C2") mcolor("$C2") msymbol(T) msize(small) lpattern(dash)) ///
       (connected wb year if income_grp == 3, lcolor("$C3") mcolor("$C3") msymbol(S) msize(small) lpattern(shortdash)) ///
       (connected wb year if income_grp == 4, lcolor("$C4") mcolor("$C4") msymbol(D) msize(small) lpattern(longdash_dot)), ///
       $GOPT ytitle("Wage bill, general government (% of GDP)", size(8pt)) xtitle("", size(8pt)) ///
       xlabel(1996(4)2024) legend(order(1 "Low income" 2 "Lower middle" 3 "Upper middle" 4 "High income") rows(1) pos(6))
fig_export Figure1_wagebill_income, width(190) height(95)

* ---------------------------------------------------------------- Figura 2: emprego publico x salario relativo
use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023)
collapse (mean) pubemp_share relwage wagebill_gdp (firstnm) iso3, by(id)
keep if !missing(pubemp_share, relwage)
gen lab = iso3 if inlist(iso3, "BRA", "USA", "DEU", "IND", "ARG", "FRA", "GBR", "MEX", "ZAF") | ///
                  inlist(iso3, "EGY", "NOR", "IDN", "CHL", "SWE") | inlist(iso3, "TUR", "NGA", "PAK", "COL", "THA")
gen pos = 3
replace pos = 12 if inlist(iso3, "SWE", "NOR")
replace pos = 6 if inlist(iso3, "FRA", "EGY")
replace pos = 9 if inlist(iso3, "MEX")
twoway (scatter relwage pubemp_share, mcolor("$C2%60") msymbol(Oh) msize(small)) ///
       (scatter relwage pubemp_share if lab != "", mcolor("$C1") msymbol(O) msize(small) mlabel(lab) mlabsize(6.5pt) mlabcolor("$C1") mlabvposition(pos)), ///
       $GOPT legend(off) xtitle("Public employment (% of total employment)", size(8pt)) ///
       ytitle("Relative public wage (pay per public worker / GDP per worker)", size(8pt))
fig_export Figure2_employment_vs_wage, width(190) height(110)

* ---------------------------------------------------------------- Figura A: cobertura
use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
foreach v in wagebill_gdp wagebill_cg_wdi pubemp_share wwbi_prem_all merit {
    gen byte h_`v' = !missing(`v')
}
collapse (sum) h_*, by(year)
twoway (line h_wagebill_gdp year, lcolor("$C1") lpattern(solid) lwidth(medthick)) ///
       (line h_wagebill_cg_wdi year, lcolor("$C2") lpattern(dash)) ///
       (line h_pubemp_share year, lcolor("$C3") lpattern(shortdash)) ///
       (line h_wwbi_prem_all year, lcolor("$C4") lpattern(longdash_dot)) ///
       (line h_merit year, lcolor("$C5") lpattern(dot) lwidth(medthick)), ///
       $GOPT ytitle("Countries with data", size(8pt)) xtitle("") xlabel(1990(5)2025) ///
       legend(order(1 "Wage bill, general government (GFS)" 2 "Wage bill, central government (WDI)" ///
                    3 "Public employment (WWBI)" 4 "Public wage premium (WWBI)" 5 "Meritocratic recruitment (V-Dem)") cols(2) pos(6))
fig_export FigureA1_coverage, width(190) height(100)

* =====================================================================================
* docs/AUDITORIA_DADOS.md (todos os numeros sao calculados aqui)
* =====================================================================================
tempname A
file open `A' using "$ROOT/docs/AUDITORIA_DADOS.md", write replace text
file write `A' "# Auditoria dos dados" _n _n
file write `A' "Gerado por \`code/04_descritivas.do\` em `c(current_date)'. Não editar à mão: todo número abaixo sai do código." _n _n

* --- regras de limpeza
file write `A' "## 1. Regras de limpeza (na ordem aplicada)" _n _n
file write `A' "| Regra | Descrição | Países | Obs. país-ano 1996–2023 (R4: 1980–2023) | Obs. com folha |" _n "|---|---|---|---|---|" _n
preserve
import delimited "$LOG/regras_limpeza.csv", clear varnames(1) stringcols(_all) delimiters(",")
forvalues i = 1/`=_N' {
    file write `A' "| " (regra[`i']) " | " (descricao[`i']) " | " (paises[`i']) " | " (obs_pais_ano[`i']) " | " (obs_folha[`i']) " |" _n
}
restore
file write `A' _n "Observações eliminadas pela regra 3 (folha acima de 30% do PIB ou despesa acima de 100% do PIB, valores do GFS antes da regra): Irã 1986–1989 (folha de 34% a 41% do PIB no GFS contra 9% a 12% do PIB na série de governo central do WDI, erro de fonte evidente), Ilhas Marshall 2009, Nauru 2015–2023 e Timor-Leste 2010–2012, 2016, 2021–2022 (despesa acima de 100% do PIB, financiada por fundos de recursos naturais ou doações). Ilhas Marshall e Nauru são microestados e já estavam fora da amostra principal. A lista completa está em \`output/logs/03_painel.log\`." _n _n

* --- amostras
use "$FINAL/painel_anual.dta", clear
gen byte main = micro == 0 & inrange(year, 1996, 2023)
file write `A' "## 2. Tamanho das amostras" _n _n
file write `A' "| Amostra | Países | Observações |" _n "|---|---|---|" _n
local labs `""Anual, folha GG, 1996–2023, sem microestados (principal)" "Anual, folha GG, com microestados" "Anual, folha GG ou GC (série combinada), sem microestados" "Anual, folha GC (WDI, como na dissertação), sem microestados""'
local conds `""main & !missing(wagebill_gdp)" "inrange(year,1996,2023) & !missing(wagebill_gdp)" "main & !missing(wagebill_comb)" "main & !missing(wagebill_cg_wdi)""'
forvalues j = 1/4 {
    local c : word `j' of `conds'
    local l : word `j' of `labs'
    quietly count if `c'
    local n = r(N)
    quietly levelsof id if `c'
    file write `A' "| `l' | `: word count `r(levels)'' | `n' |" _n
}
foreach s in "income_grp == 1" "income_grp == 2" "income_grp == 3" "income_grp == 4" "oecd == 1" "oecd == 0" "federal == 1" "federal == 0" "resource_rich == 1" "resource_rich == 0" {
    quietly count if main & !missing(wagebill_gdp) & `s'
    local n = r(N)
    quietly levelsof id if main & !missing(wagebill_gdp) & `s'
    file write `A' "| Anual, folha GG, subamostra \`" "`s'" "\` | `: word count `r(levels)'' | `n' |" _n
}
foreach L in 5 3 {
    preserve
    use "$FINAL/painel_`L'anos.dta", clear
    quietly count if micro == 0 & !missing(g, wagebill_gdp0)
    local n = r(N)
    quietly levelsof id if micro == 0 & !missing(g, wagebill_gdp0)
    file write `A' "| Médias de `L' anos, folha GG no 1º ano, sem microestados | `: word count `r(levels)'' | `n' |" _n
    restore
}
file write `A' _n

* --- ponto de verificacao
quietly count if main & !missing(wagebill_gdp)
local nobs = r(N)
quietly levelsof id if main & !missing(wagebill_gdp)
local nc : word count `r(levels)'
file write `A' "**Ponto de verificação (seção 6).** A folha do governo geral cobre `nc' países e `nobs' observações anuais na amostra principal, acima dos limites de 80 países e 1.200 observações. A variável principal é a de governo geral pura; a série combinada (governo geral ou, na falta, central, com dummy de cobertura) entra como robustez." _n _n

* --- cobertura por variavel e por grupo de renda
file write `A' "## 3. Cobertura por variável (amostra principal: 1996–2023, sem microestados)" _n _n
file write `A' "| Variável | Obs. | Países | Primeiro ano | Último ano | Renda baixa | Média-baixa | Média-alta | Alta |" _n "|---|---|---|---|---|---|---|---|---|" _n
foreach v in g wagebill_gdp wagebill_share wagebill_cyc d_wagebill_real wagebill_comb wagebill_cg_wdi wwbi_wagebill_gdp ///
    pubemp_share relwage wwbi_prem_all ilo_pubemp_share merit impartial wgi_ge hc inv open infl popg ctot_g ipriv tfp_g ///
    privemp_g debt exp_gdp rev_gdp balance_gdp sh_inv sh_transf election election_fixed grd_tax {
    quietly count if main & !missing(`v')
    local n = r(N)
    quietly levelsof id if main & !missing(`v')
    local k : word count `r(levels)'
    quietly summ year if main & !missing(`v')
    local y0 = r(min)
    local y1 = r(max)
    local gr ""
    forvalues q = 1/4 {
        quietly count if main & !missing(`v') & income_grp == `q'
        local gr "`gr' | `r(N)'"
    }
    file write `A' "| \``v'\` | `n' | `k' | `y0' | `y1'`gr' |" _n
}
file write `A' _n

* --- cobertura por ano das variaveis-chave
file write `A' "## 4. Países com dado por ano (amostra principal)" _n _n
file write `A' "| Ano | Folha GG | Folha GC (WDI) | Emprego público (WWBI) | Prêmio (WWBI) | Mérito (V-Dem) | WGI | Eleição predeterminada |" _n "|---|---|---|---|---|---|---|---|" _n
forvalues y = 1996/2023 {
    local r "| `y'"
    foreach v in wagebill_gdp wagebill_cg_wdi pubemp_share wwbi_prem_all merit wgi_ge election_fixed {
        quietly count if main & year == `y' & !missing(`v')
        local r "`r' | `r(N)'"
    }
    file write `A' "`r' |" _n
}
file write `A' _n "Os valores do WGI para 1997, 1999 e 2001 são interpolados linearmente (marcados em \`wgi_interp\`). O DPI termina em 2020: as variáveis eleitorais não existem para 2021–2023." _n _n

* --- governo geral x central
file write `A' "## 5. Folha do governo geral contra governo central (% do PIB, média 2010–2019)" _n _n
file write `A' "| País | Governo geral (GFS) | Governo central (WDI, dissertação) | Governo central (GFS) | WWBI | Eurostat (S13) | Razão GG/GC (WDI) |" _n "|---|---|---|---|---|---|---|" _n
foreach c in BRA USA DEU IND ARG MEX CAN FRA ZAF IDN {
    local r "| `c'"
    foreach v in wagebill_gdp wagebill_cg_wdi wagebill_cg_gfs wwbi_wagebill_gdp wagebill_eurostat {
        quietly summ `v' if iso3 == "`c'" & inrange(year, 2010, 2019)
        if r(N) == 0 local r "`r' | –"
        else local r "`r' | `: display %5.1f r(mean)'"
        if "`v'" == "wagebill_gdp" local gg = r(mean)
        if "`v'" == "wagebill_cg_wdi" local cg = r(mean)
    }
    if missing(`gg') | missing(`cg') local r "`r' | –"
    else local r "`r' | `: display %4.1f `gg' / `cg''"
    file write `A' "`r' |" _n
}
file write `A' _n "Nos países federais (Brasil, Estados Unidos, Alemanha, Índia, Argentina, México, Canadá), a série de governo central do WDI usada na dissertação capta só uma fração da folha do governo geral. A diferença é menor em países unitários." _n _n

* --- verificacao da decomposicao
file write `A' "## 6. Verificação da decomposição da folha" _n _n
quietly gen double _chk = abs(pubemp_share * relwage - wagebill_gdp)
quietly summ _chk if main
file write `A' "- \`relwage\` = folha (% do PIB, GFS) / emprego público (% do emprego total, WWBI). O produto \`pubemp_share × relwage\` reproduz \`wagebill_gdp\` com discrepância máxima de `: display %9.2e r(max)' pontos percentuais em `r(N)' observações; a identidade é algébrica por construção, pois o mesmo emprego total entra no numerador e no denominador." _n
quietly summ ratio_ilo_gfs if main, detail
file write `A' "- Verificação com fonte independente: a folha implícita no ILOSTAT (salário médio mensal dos empregados públicos × 12 × emprego público, % do PIB) dividida pela folha do GFS tem mediana `: display %4.2f r(p50)' (p25 = `: display %4.2f r(p25)', p75 = `: display %4.2f r(p75)', `r(N)' observações). Valores abaixo de 1 são esperados: o salário do ILOSTAT exclui contribuições sociais do empregador, que fazem parte da remuneração de empregados no GFS, e as pesquisas domiciliares cobrem mal os níveis subnacionais." _n
quietly correlate wwbi_wagebill_gdp wagebill_gdp if main
file write `A' "- Folha do WWBI contra folha do GFS: correlação `: display %4.2f r(rho)' em `r(N)' observações (o WWBI combina fontes de governo central e geral conforme o país)." _n _n

* --- downloads
file write `A' "## 7. Downloads que falharam" _n _n
file write `A' "Ver \`docs/DOWNLOADS_MANUAIS.md\`. Falha registrada pelo script de coleta (\`data/raw/_falhas.txt\`):" _n _n
capture confirm file "$RAW/_falhas.txt"
local nf 0
if !_rc {
    tempname F
    file open `F' using "$RAW/_falhas.txt", read text
    file read `F' line
    while r(eof) == 0 {
        if "`line'" != "" {
            file write `A' "- `line'" _n
            local ++nf
        }
        file read `F' line
    }
    file close `F'
}
if `nf' == 0 file write `A' "- Nenhuma falha nas fontes automáticas. Pendente apenas o FMI Fiscal Rules Dataset (bloqueio do servidor; download manual)." _n
file close `A'

log close
