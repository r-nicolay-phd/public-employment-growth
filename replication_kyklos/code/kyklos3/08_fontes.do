* 08_fontes.do -- Bloco 7: erro de medida do PIB como terceiro canal mecanico
* Plano: docs/plan_addendum_kyklos_3.md, Bloco 7.
* (1) crescimento da Penn World Table 11.0 como dependente, razao original; (2) crescimento do WDI e razao com o PIB
* nominal do WEO (compensacao de empregados das GFS em moeda nacional / NGDP do WEO).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/08_fontes.log", replace text

import delimited "$RAW/imf_gfs_xdc/g21_xdc.csv", clear varnames(1)
keep country time_period obs_value
rename (country time_period obs_value) (iso3 year w_xdc)
drop if missing(w_xdc)
tempfile g21
save `g21'
import delimited "$RAW/imf_weo_ngdp/weo_ngdp.csv", clear varnames(1)
keep country time_period obs_value
rename (country time_period obs_value) (iso3 year ngdp_weo)
drop if missing(ngdp_weo)
tempfile weo
save `weo'
use "$RAW/pwt/pwt110.dta", clear
keep countrycode year rgdpna pop
rename countrycode iso3
tempfile pwt
save `pwt'

use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1989, 2023)
merge 1:1 iso3 year using `g21', keep(master match) nogen
merge 1:1 iso3 year using `weo', keep(master match) nogen
merge 1:1 iso3 year using `pwt', keep(master match) nogen
xtset id year
gen double wbW = 100 * w_xdc / ngdp_weo
gen double gP = 100 * (ln(rgdpna / pop) - ln(L.rgdpna / L.pop))
gen g_l1 = L.g
gen gP_l1 = L.gP
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
gen wbW_ham = wbW * exp(lnY - lnY_ham)
gen wbW_l1 = L.wbW
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
gen byte s1 = sA & !missing(gP, gP_l1)
gen byte s2 = sA & !missing(wbW, wbW_ham, wbW_l1)
corr wb wbW if s2
local rW = r(rho)
gen double rr = wbW / wb if s2
summ rr if s2, detail
rv_kv b7_corr_wb_wbW `=string(`rW', "%6.4f")'
count if s1
count if s2

tempname P D
postfile `P' str4 ver str10 m double(b se p lo hi) long(N nc) using "$RINT/fon_res.dta", replace
postfile `D' str4 ver str4 dif double(d lo hi p) using "$RINT/fon_dif.dta", replace
capture program drop fon1
program define fon1
    * fon1 P D versao amostra dependente lagdep "mesmo Hamilton defasada"
    args P D ver smp dep ldep ms mh ml
    local X "`ldep' lny_l1 hc inv open infl popg ctot_g"
    foreach v in `ms' `mh' `ml' {
        quietly xtscc `dep' `v' `X' i.year if `smp', fe lag($DKLAG)
        local b = _b[`v']
        local se = _se[`v']
        local df = e(df_r)
        local mm = cond("`v'" == "`ms'", "same", cond("`v'" == "`mh'", "ham", "lag"))
        post `P' ("`ver'") ("`mm'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
            (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_g))
    }
    preserve
    keep if `smp'
    keep id year `dep' `ms' `mh' `ml' `X'
    gen long obs = _n
    expand 3
    bysort obs: gen byte m = _n
    gen double x = cond(m == 1, `ms', cond(m == 2, `mh', `ml'))
    forvalues k = 1/3 {
        gen double x`k' = x * (m == `k')
    }
    egen idm = group(id m)
    quietly reghdfe `dep' x1-x3 c.(`X')#i.m i.year#i.m, absorb(idm) vce(cluster id)
    foreach pr in "1 3 lag" "1 2 ham" {
        tokenize `pr'
        quietly lincom x`1' - x`2'
        local d = r(estimate)
        kboot {x`1' - x`2' = 0}
        post `D' ("`ver'") ("`3'") (`d') (r(lo)) (r(hi)) (r(p))
    }
    restore
end
* (1) mesma razao; crescimento do WDI e da PWT na mesma amostra
fon1 `P' `D' o1 s1 g g_l1 wb wb_ham wb_l1
fon1 `P' `D' p1 s1 gP gP_l1 wb wb_ham wb_l1
* (2) crescimento do WDI; razao original e razao com o PIB do WEO na mesma amostra
fon1 `P' `D' o2 s2 g g_l1 wb wb_ham wb_l1
fon1 `P' `D' w2 s2 g g_l1 wbW wbW_ham wbW_l1
postclose `P'
postclose `D'
use "$RINT/fon_res.dta", clear
list, noobs sepby(ver)
foreach k in 1 2 {
    local alt = cond(`k' == 1, "p1", "w2")
    quietly summ b if ver == "o`k'" & m == "same"
    local bo = r(mean)
    quietly summ b if ver == "`alt'" & m == "same"
    local ch`k' = abs(r(mean) - `bo') / abs(`bo')
}
local k7 = (`ch1' < 0.20 & `ch2' < 0.20)
rv_kv b7_change_pwt `=string(`ch1', "%9.4f")'
rv_kv b7_change_weo `=string(`ch2', "%9.4f")'
rv_kv b7_rule `=cond(`k7', "not measurement error", "third channel")'
di "Bloco 7: mudanca relativa do coeficiente do mesmo ano: PWT `ch1'; WEO `ch2'; menos de 20% nas duas = `k7'"
kcsv "$RINT/fon_res.dta" Table_A5_rows_sources
use "$RINT/fon_dif.dta", clear
list, noobs
kcsv "$RINT/fon_dif.dta" Table_A5_rows_sources_differences
log close
