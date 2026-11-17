* 07_lp_acumulado.do -- Bloco 7: efeito acumulado das projecoes locais numa metrica comum
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 7. Choques (a), (b) e (c) da Tabela A18 (code/kyklos/05_lp_predeterminado.do).
* (1) resposta da propria folha; (2) multiplicador integral (Ramey e Zubairy, 2018) por LP-IV; (3) efeito em nivel em
* h = 5 por ponto de folha mantido, dividido por 5, contra o beta de T3 e seu IC de 90%.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/07_lp_acumulado.log", replace text
local BR = cond("$BOOTR" == "", 999, real("$BOOTR"))

use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1980, 2023)
xtset id year
gen sa = L.wagebill_gdp * L.gdp_nom_lcu / L2.gdp_nom_lcu - L2.wagebill_gdp
gen sc = wagebill_gdp * gdp_nom_lcu / L.gdp_nom_lcu - L.wagebill_gdp
gen s0 = d_wagebill_real
gen g_l1 = L.g
gen g_l2 = L2.g
gen byte sPu = !missing(s0, g, g_l1, g_l2) & inrange(year, 1990, 2023)
reghdfe s0 if sPu, absorb(id year id#c.g id#c.g_l1 id#c.g_l2) residuals(sb)
forvalues h = 0/6 {
    gen dy`h' = F`h'.y100 - L.y100
    gen dwa`h' = F`h'.wagebill_gdp - L2.wagebill_gdp
    gen dwb`h' = F`h'.wagebill_gdp - L.wagebill_gdp
}
foreach s in sa sb sc {
    forvalues k = 1/2 {
        gen `s'_l`k' = L`k'.`s'
    }
}
* somas acumuladas e media da folha em h = 0..5
forvalues h = 0/6 {
    egen double Y`h' = rowtotal(dy0-dy`h'), missing
    egen double Wa`h' = rowtotal(dwa0-dwa`h'), missing
    egen double Wb`h' = rowtotal(dwb0-dwb`h'), missing
    egen _nmy = rownonmiss(dy0-dy`h')
    egen _nmw = rownonmiss(dwa0-dwa`h')
    replace Y`h' = . if _nmy < `h' + 1
    replace Wa`h' = . if _nmw < `h' + 1
    drop _nmw
    egen _nmw = rownonmiss(dwb0-dwb`h')
    replace Wb`h' = . if _nmw < `h' + 1
    drop _nmy _nmw
}
gen double MWa = Wa5 / 6
gen double MWb = Wb5 / 6
gen byte sY = inrange(year, 1996, 2023)
save "$RINT/lp2_base.dta", replace

tempname P
postfile `P' str2 shock str5 kind int h double(b se lo hi p F) long(N nc) using "$RINT/lp2_res.dta", replace
foreach s in sa sb sc {
    local w = cond("`s'" == "sa", "a", "b")
    * (1) resposta da folha (pontos do PIB)
    forvalues h = 0/6 {
        quietly xtscc dw`w'`h' `s' `s'_l1 `s'_l2 g_l1 g_l2 i.year if sY, fe lag($DKLAG)
        local b = _b[`s']
        local se = _se[`s']
        local df = e(df_r)
        post `P' ("`s'") ("resp") (`h') (`b') (`se') (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') ///
            (2 * ttail(`df', abs(`b' / `se'))) (.) (e(N)) (e(N_g))
    }
    * (2) multiplicador integral: soma de dy sobre soma de dw, instrumentada pelo choque (Driscoll-Kraay, banda 4)
    forvalues h = 0/6 {
        quietly ivreghdfe Y`h' (W`w'`h' = `s') `s'_l1 `s'_l2 g_l1 g_l2 if sY, absorb(id year) dkraay(4)
        local b = _b[W`w'`h']
        local se = _se[W`w'`h']
        post `P' ("`s'") ("mult") (`h') (`b') (`se') (`b' - invnormal(0.975) * `se') (`b' + invnormal(0.975) * `se') ///
            (2 * normal(-abs(`b' / `se'))) (e(widstat)) (e(N)) (e(N_clust))
    }
    * (3) efeito em nivel em h = 5 por ponto de folha mantido (media de dw_0 ... dw_5)
    quietly ivreghdfe dy5 (MW`w' = `s') `s'_l1 `s'_l2 g_l1 g_l2 if sY, absorb(id year) dkraay(4)
    local b = _b[MW`w']
    local se = _se[MW`w']
    post `P' ("`s'") ("theta") (5) (`b') (`se') (`b' - invnormal(0.975) * `se') (`b' + invnormal(0.975) * `se') ///
        (2 * normal(-abs(`b' / `se'))) (e(widstat)) (e(N)) (e(N_clust))
    post `P' ("`s'") ("th5") (5) (`b' / 5) (`se' / 5) ((`b' - invnormal(0.975) * `se') / 5) ((`b' + invnormal(0.975) * `se') / 5) ///
        (2 * normal(-abs(`b' / `se'))) (e(widstat)) (e(N)) (e(N_clust))
    post `P' ("`s'") ("th6") (5) (`b' / 6) (`se' / 6) ((`b' - invnormal(0.975) * `se') / 6) ((`b' + invnormal(0.975) * `se') / 6) ///
        (2 * normal(-abs(`b' / `se'))) (e(widstat)) (e(N)) (e(N_clust))
}
postclose `P'

* ---------------------------------------------------------------- choque (b): bootstrap por blocos de pais refazendo a purga
* LP-IV exatamente identificado: coeficiente = forma reduzida / primeiro estagio (mesmos controles e efeitos fixos)
use "$RINT/lp2_base.dta", clear
keep id year s0 g g_l1 g_l2 sPu sY Y0-Y6 Wb0-Wb6 dwb0-dwb6 dy5 MWb
tempfile base
save `base'
tempname B
postfile `B' int r str5 kind int h double b using "$RINT/lp2_bootb.dta", replace
set seed 20261115
forvalues r = 1/`BR' {
    quietly use `base', clear
    quietly bsample, cluster(id) idcluster(bid)
    quietly xtset bid year
    capture quietly reghdfe s0 if sPu, absorb(bid year bid#c.g bid#c.g_l1 bid#c.g_l2) residuals(sbb)
    if _rc continue
    quietly gen sbb_l1 = L.sbb
    quietly gen sbb_l2 = L2.sbb
    forvalues h = 0/6 {
        capture quietly reghdfe dwb`h' sbb sbb_l1 sbb_l2 g_l1 g_l2 if sY, absorb(bid year)
        if !_rc post `B' (`r') ("resp") (`h') (_b[sbb])
        capture quietly reghdfe Y`h' sbb sbb_l1 sbb_l2 g_l1 g_l2 if sY & !missing(Wb`h'), absorb(bid year)
        if _rc continue
        local rf = _b[sbb]
        capture quietly reghdfe Wb`h' sbb sbb_l1 sbb_l2 g_l1 g_l2 if sY & !missing(Y`h'), absorb(bid year)
        if !_rc post `B' (`r') ("mult") (`h') (`rf' / _b[sbb])
    }
    capture quietly reghdfe dy5 sbb sbb_l1 sbb_l2 g_l1 g_l2 if sY & !missing(MWb), absorb(bid year)
    if _rc continue
    local rf = _b[sbb]
    capture quietly reghdfe MWb sbb sbb_l1 sbb_l2 g_l1 g_l2 if sY & !missing(dy5), absorb(bid year)
    if !_rc post `B' (`r') ("theta") (5) (`rf' / _b[sbb])
}
postclose `B'
use "$RINT/lp2_bootb.dta", clear
bysort kind h: egen double blo = pctile(b), p(2.5)
bysort kind h: egen double bhi = pctile(b), p(97.5)
* EP robusto a valores extremos (replicacoes com primeiro estagio quase nulo): intervalo interquartil / 1,349
bysort kind h: egen double q25 = pctile(b), p(25)
bysort kind h: egen double q75 = pctile(b), p(75)
gen double bsd = (q75 - q25) / 1.349
bysort kind h: gen nrep = _N
bysort kind h: keep if _n == 1
keep kind h blo bhi bsd nrep
list, noobs
quietly summ nrep
rv_kv b7_bootb_reps_min `r(min)'
tempfile bs
save `bs'
* substitui a inferencia do choque (b) pelo bootstrap por blocos (percentis)
use "$RINT/lp2_res.dta", clear
gen kind0 = kind
replace kind = "theta" if inlist(kind, "th5", "th6")
merge m:1 kind h using `bs', keep(master match) nogen
gen double dv = cond(kind0 == "th5", 5, cond(kind0 == "th6", 6, 1))
replace se = bsd / dv if shock == "sb" & !missing(bsd)
replace lo = blo / dv if shock == "sb" & !missing(blo)
replace hi = bhi / dv if shock == "sb" & !missing(bhi)
replace p = 2 * normal(-abs(b / se)) if shock == "sb" & !missing(bsd)
replace kind = kind0
drop kind0 blo bhi bsd nrep dv
save "$RINT/lp2_res.dta", replace

* ---------------------------------------------------------------- T3 e regra (adendo 2, Bloco 7)
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
local bT3 = _b[wb_m1]
local t90 = invttail(e(df_r), 0.05)
local lo90 = _b[wb_m1] - `t90' * _se[wb_m1]
local hi90 = _b[wb_m1] + `t90' * _se[wb_m1]
rv_kv b7_T3_b `=string(`bT3', "%9.4f")'
rv_kv b7_T3_lo90 `=string(`lo90', "%9.4f")'
rv_kv b7_T3_hi90 `=string(`hi90', "%9.4f")'
use "$RINT/lp2_res.dta", clear
list, noobs sepby(shock kind)
kcsv "$RINT/lp2_res.dta" Table_A18_panel_cumulative
quietly summ b if shock == "sa" & kind == "th5"
local th = r(mean)
local inside = (`th' >= `lo90' & `th' <= `hi90')
rv_kv b7_th5_a `=string(`th', "%9.4f")'
rv_kv b7_rule `=cond(`inside', "agree", "discrepancy")'
di "Bloco 7: theta/5 (choque a) = `th'; IC de 90% de T3 = [`lo90'; `hi90']; dentro = `inside'"
log close
