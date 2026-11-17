* 01_grade_k.do -- Bloco 1 (itens 1, 2, 4 e 5): fracao contabil robusta ao desenho
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 1. Base: data/interim/kyklos2/sim2_base.dta (somente leitura).
* Desenho ancorado com residuos multiplicados por k (grade de 11 valores) e eps em {0,25; 0,48; 0,52; 0,71};
* 1.000 replicacoes por celula; desenho com elasticidades real e de precos separadas (item 5); decomposicao analitica (item 4).
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/01_grade_k.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
do "$ROOT/code/kyklos2/sim2_mata.do"
local KGRID "0 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.75 1"

* ---------------------------------------------------------------- uma replicacao (ws = razao sintetica, % do PIB)
capture program drop simk_regs
program define simk_regs
    args P des eps k r
    quietly {
        xtset id year
        gen double s_wb = ws
        gen double s_wb_ham = ws * exp(lnY - lnY_ham)
        gen double s_wb_hp1 = ws * exp(lnY - lnY_hp1)
        gen double s_wb_hp2 = ws * exp(lnY - lnY_hp)
        gen double s_wb_l1 = L.ws
        foreach m in wb wb_ham wb_hp1 wb_hp2 wb_l1 {
            mata: _fwlb("A_`m'", "g", "s_`m'", "$XA", "id", "year", "sA", "BB")
            post `P' ("`des'") (`eps') (`k') (`r') ("`m'") (BB[1, 1])
        }
        mata: _fwlb("T3", "P_g", "s_wb_l1", "P_lny0 P_hc P_inv P_open P_infl P_popg P_ctot", "id", "perT", "sT3", "BB")
        post `P' ("`des'") (`eps') (`k') (`r') ("T3") (BB[1, 1])
        if `r' == 1 {
            reghdfe g s_wb_l1 $XA if sA, absorb(id year)
            mata: _fwlb("A_wb_l1", "g", "s_wb_l1", "$XA", "id", "year", "sA", "BB")
            assert reldif(_b[s_wb_l1], BB[1, 1]) < 1e-6
        }
        bysort id: egen double _ms = mean(cond(sA, ws, .))
        gen double _ds = ws - _ms if sA
        summ _ds
        post `P' ("`des'") (`eps') (`k') (`r') ("sdw") (r(sd))
        sort id year
        xtset id year
        capture regress ws L.ws if sA
        post `P' ("`des'") (`eps') (`k') (`r') ("ar1") (cond(_rc, ., _b[L.ws]))
    }
end

* ---------------------------------------------------------------- observados
use "$KIN2/sim2_base.dta", clear
xtset id year
tempname P
postfile `P' str4 des double(eps k) int rep str8 meas double b using "$RINT/gk_draws.dta", replace
foreach m in wb wb_ham wb_hp1 wb_hp2 wb_l1 {
    quietly reghdfe g `m' $XA if sA, absorb(id year)
    post `P' ("obs") (.) (.) (0) ("`m'") (_b[`m'])
}
quietly reghdfe P_g wb_l1 P_lny0 P_hc P_inv P_open P_infl P_popg P_ctot i.perT if sT3, absorb(id)
post `P' ("obs") (.) (.) (0) ("T3") (_b[wb_l1])
bysort id: egen double _m = mean(cond(sA, wb, .))
gen double _d = wb - _m if sA
quietly summ _d
post `P' ("obs") (.) (.) (0) ("sdw") (r(sd))
drop _m _d
sort id year
xtset id year
quietly regress wb L.wb if sA
post `P' ("obs") (.) (.) (0) ("ar1") (_b[L.wb])

* ---------------------------------------------------------------- (item 5) elasticidades real e de precos
gen double c_dlW = 100 * dlW
gen double c_dlYr = 100 * (ln(gdp_real) - ln(L.gdp_real))
gen double pi = 100 * (ln(gdp_nom_lcu / gdp_real) - ln(L.gdp_nom_lcu / L.gdp_real))
xtscc c_dlW c_dlYr pi i.year if sA, fe lag($DKLAG)
local er = _b[c_dlYr]
local ep = _b[pi]
rv_kv b1_eps_real `=string(`er', "%9.4f")'
rv_kv b1_eps_real_se `=string(_se[c_dlYr], "%9.4f")'
rv_kv b1_eps_price `=string(`ep', "%9.4f")'
rv_kv b1_eps_price_se `=string(_se[pi], "%9.4f")'
di "elasticidade real = `er'; de precos = `ep'"

* ---------------------------------------------------------------- (item 4) decomposicao analitica
preserve
keep if sA
foreach e in 0.48 0.71 {
    local en = subinstr("`e'", ".", "", 1)
    gen double A`en' = -(1 - `e') * dlYn
    gen double u`en' = dlS - A`en'
}
foreach v in dlS A048 u048 A071 u071 g {
    quietly reghdfe `v', absorb(id year) residuals(r_`v')
}
quietly corr r_dlS r_g, covariance
local cSg = r(cov_12)
local vS = r(Var_1)
foreach en in 048 071 {
    quietly corr r_A`en' r_u`en', covariance
    local vA = r(Var_1)
    local vU = r(Var_2)
    local cAU = r(cov_12)
    quietly corr r_A`en' r_g, covariance
    local cAg = r(cov_12)
    rv_kv b1_an_`en'_varA `=string(`vA' / `vS', "%9.4f")'
    rv_kv b1_an_`en'_varU `=string(`vU' / `vS', "%9.4f")'
    rv_kv b1_an_`en'_covAU `=string(2 * `cAU' / `vS', "%9.4f")'
    rv_kv b1_an_`en'_lambda `=string(`vA' / `vS', "%9.4f")'
    rv_kv b1_an_`en'_share `=string(`cAg' / `cSg', "%9.4f")'
    di "eps = `en': Var(A)/Var(dln s) = " `vA' / `vS' "; Var(u) = " `vU' / `vS' "; 2Cov = " 2 * `cAU' / `vS' "; fracao implicita = " `cAg' / `cSg'
}
restore

* ---------------------------------------------------------------- (item 1) grade k x eps; (item 5) elasticidades separadas
set seed 20261117
foreach eps in 0.25 0.48 0.52 0.71 {
    use "$KIN2/sim2_base.dta", clear
    gen double e = dlS + (1 - `eps') * dlYn
    bysort id: egen double _me = mean(e)
    replace e = e - _me
    drop _me
    sort id year
    tempfile be
    save `be'
    foreach k of local KGRID {
        di as result "eps = `eps', k = `k'"
        forvalues r = 1/`R' {
            quietly {
                use `be', clear
                gen double ud = .
                mata: _drawc("id", "e", "okA", "ud")
                gen double ws = 100 * exp(lS_l1 - (1 - `eps') * dlYn + `k' * ud)
            }
            simk_regs `P' anc `eps' `k' `r'
        }
    }
}
* elasticidades separadas: dln s = (er - 1) dln Yr + (ep - 1) pi + k u
use "$KIN2/sim2_base.dta", clear
xtset id year
gen double dlYr = ln(gdp_real) - ln(L.gdp_real)
gen double dlP = ln(gdp_nom_lcu / gdp_real) - ln(L.gdp_nom_lcu / L.gdp_real)
gen double comp = (`er' - 1) * dlYr + (`ep' - 1) * dlP
gen double e = dlS - comp
bysort id: egen double _me = mean(e)
replace e = e - _me
drop _me
gen byte okR = okA & !missing(comp)
sort id year
tempfile bs
save `bs'
foreach k of local KGRID {
    di as result "elasticidades separadas, k = `k'"
    forvalues r = 1/`R' {
        quietly {
            use `bs', clear
            gen double ud = .
            mata: _drawc("id", "e", "okR", "ud")
            gen double ws = 100 * exp(lS_l1 + comp + `k' * ud)
        }
        simk_regs `P' sep 0 `k' `r'
    }
}
postclose `P'
log close
