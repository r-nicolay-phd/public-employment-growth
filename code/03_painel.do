* 03_painel.do -- junta as fontes, aplica as regras de limpeza, constroi variaveis e monta os paineis
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/03_painel.log", replace text

* =====================================================================================
* 1. Juncao
* =====================================================================================
use "$INTERIM/wdi.dta", clear
keep if inrange(year, 1970, 2023)
merge m:1 iso3 using "$INTERIM/paises.dta", keep(master match) nogen
merge m:1 iso3 using "$INTERIM/renda_hist.dta", keep(master match) nogen
foreach f in gfs icsd gdd ctot eurostat wgi wwbi ilostat pwt vdem qog_grd dpi ucdp {
    merge 1:1 iso3 year using "$INTERIM/`f'.dta", keep(master match) nogen
}
merge m:1 iso3 using "$INTERIM/fd.dta", keep(master match) nogen
merge m:1 iso3 using "$INTERIM/qog_expert.dta", keep(master match) nogen
replace war = 0 if missing(war)

* regras fiscais (download manual; limpeza em 02_limpeza_fmi.do; ver docs/DOWNLOADS_MANUAIS.md)
capture confirm file "$INTERIM/fiscal_rules.dta"
if !_rc {
    merge 1:1 iso3 year using "$INTERIM/fiscal_rules.dta", keep(master match) nogen
}
else {
    di "Fiscal Rules Dataset ausente: variaveis rule_* ficam vazias"
    foreach v in rule_exp rule_rev rule_bb rule_debt rule_any rule_exp_nat rule_bb_nat in_frd {
        gen byte `v' = .
    }
}

* =====================================================================================
* 2. Regras de limpeza (na ordem da especificacao); contagens gravadas em regras_limpeza.csv
* =====================================================================================
tempname R
file open `R' using "$LOG/regras_limpeza.csv", write replace text
file write `R' "regra,descricao,paises,obs_pais_ano,obs_folha" _n
local per "inrange(year, 1996, 2023)"

* R1. agregados e territorios sem contas fiscais proprias
quietly levelsof iso3 if aggregate == 1 | missing(aggregate), local(L)
local k : word count `L'
count if (aggregate == 1 | missing(aggregate)) & `per'
local n = r(N)
count if (aggregate == 1 | missing(aggregate)) & `per' & !missing(wagebill_gdp)
file write `R' "1a,Agregados regionais e de renda (lista do Banco Mundial),`k',`n',`r(N)'" _n
drop if aggregate == 1 | missing(aggregate)
quietly levelsof iso3 if territory == 1, local(L)
local k : word count `L'
count if territory == 1 & `per'
local n = r(N)
count if territory == 1 & `per' & !missing(wagebill_gdp)
file write `R' "1b,Territorios dependentes sem contas fiscais proprias,`k',`n',`r(N)'" _n
drop if territory == 1
drop aggregate territory

encode iso3, gen(id)
xtset id year

* R2. microestados (populacao media 1996-2023 abaixo de 500 mil): fora da amostra principal
bysort id: egen _popm = mean(cond(`per', pop, .))
gen byte micro = _popm < 500000 if !missing(_popm)
replace micro = 1 if missing(micro)
drop _popm
quietly levelsof iso3 if micro == 1, local(L)
local k : word count `L'
count if micro == 1 & `per'
local n = r(N)
count if micro == 1 & `per' & !missing(wagebill_gdp)
file write `R' "2,Microestados (populacao < 500 mil; mantidos so para robustez),`k',`n',`r(N)'" _n

* R3. valores implausiveis de folha (>30% PIB) ou despesa (>100% PIB) viram ausentes
di "Folha acima de 30% do PIB ou despesa acima de 100% do PIB (antes da regra 3):"
list iso3 year wagebill_gdp exp_gdp wagebill_cg_wdi wwbi_wagebill_gdp if wagebill_gdp > 30 & !missing(wagebill_gdp) | exp_gdp > 100 & !missing(exp_gdp), noobs sepby(iso3)
count if (wagebill_gdp > 30 & !missing(wagebill_gdp)) | (exp_gdp > 100 & !missing(exp_gdp))
local n = r(N)
quietly levelsof iso3 if (wagebill_gdp > 30 & !missing(wagebill_gdp)) | (exp_gdp > 100 & !missing(exp_gdp)), local(L)
local k : word count `L'
file write `R' "3,Folha > 30% do PIB ou despesa > 100% do PIB tratadas como ausentes,`k',`n',`n'" _n
foreach v in wagebill_gdp wagebill_share exp_gdp sh_wage sh_goods sh_int sh_transf sh_inv sh_other {
    replace `v' = . if (wagebill_gdp > 30 & !missing(wagebill_gdp)) | (exp_gdp > 100 & !missing(exp_gdp))
}
replace wagebill_comb = . if wagebill_comb > 30 & !missing(wagebill_comb)
replace wagebill_cg_wdi = . if wagebill_cg_wdi > 30 & !missing(wagebill_cg_wdi)
replace wwbi_wagebill_gdp = . if wwbi_wagebill_gdp > 30 & !missing(wwbi_wagebill_gdp)

* R4. winsorizacao de crescimento e inflacao nos percentis 1 e 99 (amostra sem microestados, 1980-2023)
gen g_raw = gdppc_growth
rename infl infl_raw
foreach v in g infl {
    _pctile `v'_raw if micro == 0 & inrange(year, 1980, 2023), p(1 99)
    local lo = r(r1)
    local hi = r(r2)
    gen `v' = min(max(`v'_raw, `lo'), `hi') if !missing(`v'_raw)
    count if (`v'_raw < `lo' | `v'_raw > `hi') & !missing(`v'_raw) & micro == 0 & inrange(year, 1980, 2023)
    local n = r(N)
    file write `R' "4_`v',Winsorizacao de `v' em p1 = " %6.2f (`lo') " e p99 = " %6.2f (`hi') ",.,`n',." _n
}
label var g "GDP per capita growth (%), winsorized at p1/p99"
label var infl "Inflation (%), winsorized at p1/p99"

* R5. marcar (sem excluir) guerra e hiperinflacao
gen byte hyperinf = infl_raw > 100 & !missing(infl_raw)
count if war == 1 & micro == 0 & `per'
local n1 = r(N)
count if hyperinf == 1 & micro == 0 & `per'
file write `R' "5,Marcados (nao excluidos): anos de guerra (UCDP intensidade 2) = `n1'; hiperinflacao (>100%) = `r(N)',.,.,." _n
file close `R'

* =====================================================================================
* 3. Variaveis construidas (painel anual)
* =====================================================================================
gen lny = ln(gdppc)
label var lny "Log GDP per capita"

* choque: variacao real da folha em % do PIB do ano anterior (deflator do PIB)
*   W_t/P_t = (wb_t/100) * Yreal_t  =>  d_wb = wb_t * Yreal_t/Yreal_{t-1} - wb_{t-1}
gen d_wagebill_real = wagebill_gdp * gdp_real / L.gdp_real - L.wagebill_gdp
label var d_wagebill_real "Real change in wage bill (% of previous-year GDP)"

* folha sobre PIB tendencial: HP (lambda = 6,25, Ravn e Uhlig) e Hamilton (h = 2, p = 2)
gen lnY = ln(gdp_real)
gen lnY_hp = .
mata:
void hp_panel(string scalar yv, string scalar idv, string scalar outv, real scalar lambda)
{
    real colvector y, id, out, sel, ys
    real scalar i, n, T
    real matrix D, A
    st_view(y = ., ., yv)
    st_view(id = ., ., idv)
    out = J(rows(y), 1, .)
    for (i = min(id); i <= max(id); i++) {
        sel = selectindex((id :== i) :& (y :< .))
        T = rows(sel)
        if (T < 8) continue
        ys = y[sel]
        D = J(T - 2, T, 0)
        for (n = 1; n <= T - 2; n++) D[n, (n, n + 1, n + 2)] = (1, -2, 1)
        A = I(T) + lambda * D' * D
        out[sel] = lusolve(A, ys)
    }
    st_store(., outv, out)
}
end
sort id year
mata: hp_panel("lnY", "id", "lnY_hp", 6.25)
gen lnY_ham = .
levelsof id, local(ids)
foreach i of local ids {
    capture quietly regress lnY L2.lnY L3.lnY if id == `i'
    if !_rc & e(N) >= 10 {
        quietly predict double _h if id == `i' & e(sample), xb
        quietly replace lnY_ham = _h if id == `i'
        drop _h
    }
}
gen wagebill_cyc = wagebill_gdp * exp(lnY - lnY_hp)
gen wagebill_cyc_ham = wagebill_gdp * exp(lnY - lnY_ham)
label var wagebill_cyc "Wage bill (% of trend GDP, HP filter)"
label var wagebill_cyc_ham "Wage bill (% of trend GDP, Hamilton filter)"
drop lnY_ham

* decomposicao: emprego publico (% do emprego total) e salario relativo
gen pubemp_share = wwbi_pubemp_total
gen relwage = wagebill_gdp / pubemp_share
label var pubemp_share "Public employment (% of total employment)"
label var relwage "Relative public wage (wage bill per public employee / GDP per worker)"
gen double _chk = abs(pubemp_share * relwage - wagebill_gdp)
summ _chk
di "Verificacao algebrica do produto: discrepancia maxima = " r(max)
drop _chk
* verificacao com fonte independente: folha implicita no ILOSTAT (salario medio x emprego publico)
gen wagebill_ilo = 100 * 12 * ilo_pubearn * ilo_pubemp * 1000 / gdp_nom_lcu
gen ratio_ilo_gfs = wagebill_ilo / wagebill_gdp
label var wagebill_ilo "Implied wage bill from ILOSTAT earnings x public employment (% of GDP)"

* choques de emprego e de salario relativo (D2): contribuicao da variacao do emprego publico
* (WWBI x emprego total do PWT; so anos consecutivos observados, sem interpolacao) e residuo de salario
gen pubemp_n = pubemp_share / 100 * emp
gen d_wb_emp = L.wagebill_gdp * (pubemp_n / L.pubemp_n - 1) * gdp_real / L.gdp_real
gen d_wb_wage = d_wagebill_real - d_wb_emp
label var d_wb_emp "Wage bill change due to public employment (% of previous-year GDP)"
label var d_wb_wage "Wage bill change due to relative pay (% of previous-year GDP)"

* moderador: merito defasado
gen merit_l1 = L.merit
gen wgi_ge_l1 = L.wgi_ge

* controles e resultados
gen ctot_g = 100 * (ln(ctot) - ln(L.ctot))
gen inv = inv_gdp
gen open = trade_gdp
gen tfp_g = 100 * (ln(rtfpna) - ln(L.rtfpna))
gen privemp = ilo_emp - ilo_pubemp if src_EMP_PUBL == src_EMP_TEMP
egen _src = group(src_EMP_PUBL)
gen privemp_g = 100 * (ln(privemp) - ln(L.privemp)) if _src == L._src
drop _src
label var ctot_g "Commodity terms-of-trade growth (%)"
label var tfp_g "TFP growth (%), PWT"
label var privemp_g "Private employment growth (%), ILOSTAT"
label var ipriv "Private investment (% of GDP)"

* =====================================================================================
* 4. Classificacoes (fixas no tempo)
* =====================================================================================
gen byte oecd = inlist(iso3, "AUS", "AUT", "BEL", "CAN", "CHL", "COL", "CRI", "CZE", "DNK") | ///
                inlist(iso3, "EST", "FIN", "FRA", "DEU", "GRC", "HUN", "ISL", "IRL", "ISR") | ///
                inlist(iso3, "ITA", "JPN", "KOR", "LVA", "LTU", "LUX", "MEX", "NLD", "NZL") | ///
                inlist(iso3, "NOR", "POL", "PRT", "SVK", "SVN", "ESP", "SWE", "CHE", "TUR") | ///
                inlist(iso3, "GBR", "USA")
bysort id: egen _rents = mean(cond(`per', natres_rents, .))
gen byte resource_rich = _rents > 10 if !missing(_rents)
* federacoes segundo o Forum of Federations (inclui Espanha e Africa do Sul, federais na pratica);
* o indicador "author" do DPI foi descartado: ausente para 108 paises e positivo em paises unitarios
gen byte federal = inlist(iso3, "ARG", "AUS", "AUT", "BEL", "BIH", "BRA", "CAN", "CHE", "COM") | ///
                   inlist(iso3, "DEU", "ESP", "ETH", "IND", "IRQ", "MEX", "MYS", "NGA", "NPL") | ///
                   inlist(iso3, "PAK", "RUS", "SDN", "SSD", "USA", "VEN", "ARE", "FSM", "KNA") | ///
                   inlist(iso3, "ZAF")
drop _rents
label var oecd "OECD member (38 members, 2023)"
label var resource_rich "Natural resource rents > 10% of GDP (1996-2023 mean)"
label var federal "Federal country (Forum of Federations list)"
label var micro "Microstate (population < 500,000)"
label var income_grp "World Bank income group, 1996 classification"

sort id year
compress
save "$FINAL/painel_anual.dta", replace

* =====================================================================================
* 5. Paineis de medias nao sobrepostas (3 e 5 anos); folha e moderadores no primeiro ano
* =====================================================================================
local mean_vars g g_raw infl infl_raw inv open popg ctot_g ipriv privinv_wdi tfp_g privemp_g debt ///
    exp_gdp rev_gdp balance_gdp wagebill_gdp wagebill_cyc hc war hyperinf
local first_vars wagebill_gdp wagebill_share wagebill_cyc wagebill_cyc_ham wagebill_comb cov_central ///
    wagebill_cg_wdi wagebill_cg_gfs exp_gdp rev_gdp balance_gdp sh_wage sh_goods sh_int sh_transf ///
    sh_inv sh_other merit impartial pubcorrupt wgi_ge hc debt grd_rev ///
    rule_exp rule_bb rule_debt rule_any rule_exp_nat rule_bb_nat
local avail_vars pubemp_share relwage wwbi_prem_all wwbi_prem_formal wwbi_wagebill_gdp
local fl ""
foreach v of local first_vars {
    local fl `fl' `v'0
}
local al ""
foreach v of local avail_vars {
    local al `al' `v'0
}
foreach L in 5 3 {
    use "$FINAL/painel_anual.dta", clear
    local start = cond(`L' == 5, 1979, 1981)
    keep if year >= `start'
    gen period = floor((year - `start') / `L')
    gen year0 = `start' + `L' * period
    gen g_excr = g if !inlist(year, 2008, 2009, 2020, 2021)
    foreach v of local first_vars {
        gen `v'0 = `v' if year == year0
    }
    * componentes do WWBI (painel irregular): primeiro valor disponivel dentro do periodo
    foreach v of local avail_vars {
        gen _t = year if !missing(`v')
        bysort id period: egen _tmin = min(_t)
        gen `v'0 = `v' if year == _tmin
        drop _t _tmin
    }
    gen ng = !missing(g)
    collapse (mean) `mean_vars' g_excr (firstnm) `fl' `al' (sum) ng (max) war_any = war hyper_any = hyperinf ///
        (firstnm) iso3 country region income_grp oecd resource_rich federal micro exp_decentr qog_prof ///
        qog_closed in_frd year0, by(id period)
    * renda inicial: log do PIB per capita no ano anterior ao periodo (do painel anual)
    tempfile P
    save `P'
    use "$FINAL/painel_anual.dta", clear
    gen year0 = year + 1
    keep id year0 lny
    rename lny lny0
    merge 1:1 id year0 using `P', keep(using match) nogen
    * exige ao menos 3 de 5 (ou 2 de 3) anos de crescimento observados
    replace g = . if ng < cond(`L' == 5, 3, 2)
    gen year1 = year0 + `L' - 1
    xtset id period
    gen L_g = L.g
    label var g "GDP per capita growth (%, period mean)"
    label var L_g "Lagged GDP per capita growth (previous period)"
    label var lny0 "Log initial GDP per capita"
    label var wagebill_gdp0 "Wage bill (% of GDP), first year of period"
    label var wagebill_gdp "Wage bill (% of GDP), period mean"
    label var merit0 "Meritocratic recruitment (V-Dem), first year of period"
    label var g_excr "GDP per capita growth excl. 2008-09 and 2020-21 (%, period mean)"
    compress
    save "$FINAL/painel_`L'anos.dta", replace
}

* =====================================================================================
* 6. Dicionario e exportacao em parquet (conversao de formato)
* =====================================================================================
use "$FINAL/painel_anual.dta", clear
describe, replace clear
keep name type varlab
export delimited "$FINAL/dicionario.csv", replace
shell python "$ROOT/code/03b_exporta_parquet.py"

log close
