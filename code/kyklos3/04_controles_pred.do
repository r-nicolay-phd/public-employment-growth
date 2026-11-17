* 04_controles_pred.do -- Bloco 3: Tabela 1 com controles anuais predeterminados
* Plano: docs/plan_addendum_kyklos_3.md, Bloco 3. Amostra comum: amostra da Tabela 1 com todos os controles em t - 1.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/04_controles_pred.log", replace text

use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1991, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
foreach v in hc inv open infl popg ctot_g {
    gen `v'_l1 = L.`v'
}
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
gen byte sL = sA & !missing(hc_l1, inv_l1, open_l1, infl_l1, popg_l1, ctot_g_l1)
count if sA
count if sL
local cv0 "$XA"
local cva "g_l1 lny_l1 hc_l1 inv_l1 open_l1 infl_l1 popg_l1 ctot_g_l1"
local cvb "g_l1 lny_l1 hc_l1 inv_l1 open_l1 popg_l1 ctot_g_l1"
local cvc "g_l1 lny_l1 hc_l1 open_l1 infl_l1 popg_l1 ctot_g_l1"
tempname P D
postfile `P' str2 ver str10 m double(b se p lo hi) long(N nc) using "$RINT/ctl_res.dta", replace
postfile `D' str2 ver str4 dif double(d lo hi p) using "$RINT/ctl_dif.dta", replace
foreach ver in 0 a b c {
    local X "`cv`ver''"
    foreach v in wb wb_hp2 wb_hp1 wb_ham wb_l1 wbham_l1 {
        quietly xtscc g `v' `X' i.year if sL, fe lag($DKLAG)
        local b = _b[`v']
        local se = _se[`v']
        local df = e(df_r)
        post `P' ("`ver'") ("`v'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
            (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_g))
    }
    preserve
    keep if sL
    keep id year g wb wb_ham wb_l1 `X'
    gen long obs = _n
    expand 3
    bysort obs: gen byte m = _n
    gen double x = cond(m == 1, wb, cond(m == 2, wb_ham, wb_l1))
    forvalues k = 1/3 {
        gen double x`k' = x * (m == `k')
    }
    egen idm = group(id m)
    quietly reghdfe g x1-x3 c.(`X')#i.m i.year#i.m, absorb(idm) vce(cluster id)
    foreach pr in "1 3 lag" "1 2 ham" {
        tokenize `pr'
        quietly lincom x`1' - x`2'
        local d = r(estimate)
        kboot {x`1' - x`2' = 0}
        post `D' ("`ver'") ("`3'") (`d') (r(lo)) (r(hi)) (r(p))
    }
    restore
}
postclose `P'
postclose `D'
use "$RINT/ctl_dif.dta", clear
list, noobs
quietly count if inlist(ver, "a", "b", "c") & dif == "lag" & p < 0.01
local k3 = (r(N) == 3)
rv_kv b3_rule `=cond(`k3', "cite", "report change")'
di "Bloco 3: mesmo ano - defasada com p < 0,01 nas tres versoes = `k3'"
use "$RINT/ctl_res.dta", clear
list, noobs sepby(ver)
kcsv "$RINT/ctl_res.dta" Table_A5_rows_predetermined_controls
kcsv "$RINT/ctl_dif.dta" Table_A5_rows_predetermined_controls_differences
log close
