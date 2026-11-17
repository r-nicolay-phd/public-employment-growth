* 05_ano_fiscal.do -- Bloco 5: ano fiscal diferente do ano civil
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 5. Lista: data/raw/fiscal_year/fiscal_year_by_country.csv (WEO).
* (2) Tabela 1 (anual e quinquenal) e T3 sem os paises de ano fiscal nao civil; (3) realinhamento para ano civil dos
* paises com ano fiscal iniciado entre abril e setembro; (4) diferencas por bootstrap em modelos empilhados.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/05_ano_fiscal.log", replace text

import delimited "$RAW/fiscal_year/fiscal_year_by_country.csv", clear varnames(1) encoding(utf-8) stringcols(_all)
gen byte nfy = fiscal_year_calendar == "não"
gen byte fyunk = fiscal_year_calendar == "não verificado"
destring start_month_num, gen(smon) force
keep iso3 nfy fyunk smon
tempfile fy
save `fy'

* ---------------------------------------------------------------- painel anual com a razao realinhada
use "$KIN/anual_rv.dta", clear
keep if micro == 0
merge m:1 iso3 using `fy', keep(master match) nogen
replace nfy = 0 if missing(nfy)
xtset id year
* realinhamento (inicio entre abril e setembro); rotulo = ano civil com a maioria dos meses
gen byte realg = nfy & inrange(smon, 4, 9)
gen double wbR = wb
replace wbR = ((smon - 1) / 12) * L.wb + ((13 - smon) / 12) * wb if realg & smon <= 6
replace wbR = ((smon - 1) / 12) * wb + ((13 - smon) / 12) * F.wb if realg & smon >= 7
gen double wbR_ham = wbR * exp(lnY - lnY_ham)
gen double wbR_hp1 = wbR * exp(lnY - lnY_hp1)
gen double wbR_hp2 = wbR * exp(lnY - lnY_hp)
save "$RINT/fy_anual.dta", replace
* medidas quinquenais a partir da razao realinhada
preserve
keep if year >= 1978
gen period = floor((year - 1979) / 5)
gen byte first = year == 1979 + 5 * period
gen double R_tp = wbR if first
gen double R_m1 = L.wbR if first
gen double R_ham_m1 = L.wbR_ham if first
keep if year >= 1979
collapse (mean) R_mean = wbR (firstnm) R_tp R_m1 R_ham_m1, by(id period)
tempfile r5
save `r5'
restore

* ---------------------------------------------------------------- anual: Tabela 1 nas tres amostras
keep if inrange(year, 1991, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
gen wbR_l1 = L.wbR
gen wbRham_l1 = L.wbR_ham
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
gen byte sAR = sA & !missing(wbR, wbR_hp2, wbR_hp1, wbR_ham, wbR_l1, wbRham_l1)
tab nfy if sA
levelsof iso3 if sA & nfy, local(lnfy) clean
levelsof iso3 if sA & realg, local(lrea) clean
rv_kv b5_nfy_countries "`=subinstr("`lnfy'", " ", "_", .)'"
rv_kv b5_realg_countries "`=subinstr("`lrea'", " ", "_", .)'"
quietly count if sA & nfy
rv_kv b5_nfy_obs `r(N)'
di "paises de ano fiscal nao civil na amostra da Tabela 1: `lnfy'"
di "realinhados: `lrea'"
tempname P
postfile `P' str4 smp str10 m double(b se p lo hi) long(N nc) using "$RINT/fy_res.dta", replace
foreach smp in full excl real {
    foreach v in wb wb_hp2 wb_hp1 wb_ham wb_l1 wbham_l1 {
        local x = cond("`smp'" == "real", subinstr("`v'", "wb", "wbR", 1), "`v'")
        local c = cond("`smp'" == "full", "sA", cond("`smp'" == "excl", "sA & !nfy", "sAR"))
        quietly xtscc g `x' $XA i.year if `c', fe lag($DKLAG)
        local b = _b[`x']
        local se = _se[`x']
        local df = e(df_r)
        post `P' ("`smp'") ("`v'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
            (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_g))
    }
}
* diferencas entre medidas (mesmo ano - Hamilton, mesmo ano - defasada) em cada amostra; modelo empilhado
tempname D
postfile `D' str4 smp str12 dif double(d lo hi p) using "$RINT/fy_dif.dta", replace
foreach smp in full excl real {
    preserve
    local c = cond("`smp'" == "full", "sA", cond("`smp'" == "excl", "sA & !nfy", "sAR"))
    keep if `c'
    if "`smp'" == "real" {
        replace wb = wbR
        replace wb_ham = wbR_ham
        replace wb_l1 = wbR_l1
    }
    keep id year g wb wb_ham wb_l1 $XA
    gen long obs = _n
    expand 3
    bysort obs: gen byte m = _n
    gen double x = cond(m == 1, wb, cond(m == 2, wb_ham, wb_l1))
    forvalues k = 1/3 {
        gen double x`k' = x * (m == `k')
    }
    egen idm = group(id m)
    quietly reghdfe g x1-x3 c.($XA)#i.m i.year#i.m, absorb(idm) vce(cluster id)
    foreach pr in "1 2 ham" "1 3 lag" {
        tokenize `pr'
        quietly lincom x`1' - x`2'
        local d = r(estimate)
        kboot {x`1' - x`2' = 0}
        post `D' ("`smp'") ("`3'") (`d') (r(lo)) (r(hi)) (r(p))
    }
    restore
}
* (4) diferenca entre os coeficientes com e sem os paises de ano fiscal nao civil (mesma medida, amostras empilhadas)
foreach v in wb wb_ham wb_l1 {
    preserve
    keep if sA
    keep id year g `v' nfy $XA
    gen long obs = _n
    expand 2
    bysort obs: gen byte m = _n
    drop if m == 2 & nfy
    gen double x1 = `v' * (m == 1)
    gen double x2 = `v' * (m == 2)
    egen idm = group(id m)
    quietly reghdfe g x1 x2 c.($XA)#i.m i.year#i.m, absorb(idm) vce(cluster id)
    quietly lincom x2 - x1
    local d = r(estimate)
    kboot {x2 - x1 = 0}
    post `D' ("ex-f") ("`v'") (`d') (r(lo)) (r(hi)) (r(p))
    restore
}
postclose `D'

* ---------------------------------------------------------------- cinco anos: medidas da Tabela 1 e T3
use "$KIN/p5_rv.dta", clear
keep if micro == 0
merge m:1 iso3 using `fy', keep(master match) nogen
replace nfy = 0 if missing(nfy)
merge 1:1 id period using `r5', keep(master match) nogen
xtset id period
gen byte s5 = !missing(g, wb_mean, wb_tp, wb_m1, wb_ham_m1, lny0, hc_tp, inv, open, infl, popg, ctot_g)
gen byte s5R = !missing(g, R_mean, R_tp, R_m1, R_ham_m1, lny0, hc_tp, inv, open, infl, popg, ctot_g)
foreach smp in full excl real {
    foreach v in wb_mean wb_tp wb_m1 wb_ham_m1 {
        local x = cond("`smp'" == "real", subinstr("`v'", "wb", "R", 1), "`v'")
        local c = cond("`smp'" == "full", "s5", cond("`smp'" == "excl", "s5 & !nfy", "s5R"))
        quietly reghdfe g `x' $XD i.period if `c', absorb(id) vce(cluster id)
        local b = _b[`x']
        local se = _se[`x']
        local df = e(df_r)
        post `P' ("`smp'") ("`v'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
            (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_clust))
    }
    local x = cond("`smp'" == "real", "R_m1", "wb_m1")
    local c = cond("`smp'" == "full", "1", cond("`smp'" == "excl", "!nfy", "1"))
    quietly reghdfe g `x' $XP i.period if `c', absorb(id) vce(cluster id)
    local b = _b[`x']
    local se = _se[`x']
    local df = e(df_r)
    post `P' ("`smp'") ("T3") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
        (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_clust))
}
* T3: diferenca com e sem os paises (empilhado, bootstrap)
preserve
quietly reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
keep if e(sample)
keep id period g wb_m1 nfy $XP
gen long obs = _n
expand 2
bysort obs: gen byte m = _n
drop if m == 2 & nfy
gen double x1 = wb_m1 * (m == 1)
gen double x2 = wb_m1 * (m == 2)
egen idm = group(id m)
quietly reghdfe g x1 x2 c.($XP)#i.m i.period#i.m, absorb(idm) vce(cluster id)
quietly lincom x2 - x1
local dT3 = r(estimate)
kboot {x2 - x1 = 0}
local pT3 = r(p)
local loT3 = r(lo)
local hiT3 = r(hi)
restore
postclose `P'
preserve
use "$RINT/fy_dif.dta", clear
set obs `=_N + 1'
replace smp = "ex-f" in l
replace dif = "T3" in l
replace d = `dT3' in l
replace lo = `loT3' in l
replace hi = `hiT3' in l
replace p = `pT3' in l
save "$RINT/fy_dif.dta", replace
list, noobs
restore

* ---------------------------------------------------------------- regra (adendo 2, Bloco 5)
use "$RINT/fy_dif.dta", clear
quietly count if smp == "excl" & inlist(dif, "ham", "lag") & d < 0 & p < 0.01
local keep = (r(N) == 2)
rv_kv b5_rule `=cond(`keep', "remove limitation", "report change")'
di "Bloco 5: diferencas mantidas sem os paises = `keep'"
use "$RINT/fy_res.dta", clear
list, noobs sepby(smp)
kcsv "$RINT/fy_res.dta" Table_A6_rows_fiscal_year
kcsv "$RINT/fy_dif.dta" Table_A6_rows_fiscal_year_differences
log close
