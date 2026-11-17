* 05_lp_predeterminado.do -- Bloco 5: projecoes locais com choques realmente predeterminados
* Choque atual: 100 (W_t/P_t - W_{t-1}/P_{t-1}) / y_{t-1} = wb_t PIBr_t/PIBr_{t-1} - wb_{t-1} (numerador corrente)
* (a) datado em t-1: wb_{t-1} PIBn_{t-1}/PIBn_{t-2} - wb_{t-2}  [= 100 (W_{t-1}/P_{t-2} - W_{t-2}/P_{t-2}) / y_{t-2}]
* (b) purgado: residuo do choque atual no crescimento corrente e em duas defasagens (inclinacoes por pais, EF de pais
*     e ano); regressor gerado -> bootstrap por blocos de pais refazendo a purga (999)
* (c) deflator de t-1: wb_t PIBn_t/PIBn_{t-1} - wb_{t-1}  [= 100 (W_t/P_{t-1} - W_{t-1}/P_{t-1}) / y_{t-1}]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/05_lp_predeterminado.log", replace text

use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1980, 2023)
xtset id year
gen sa = L.wagebill_gdp * L.gdp_nom_lcu / L2.gdp_nom_lcu - L2.wagebill_gdp
gen sc = wagebill_gdp * gdp_nom_lcu / L.gdp_nom_lcu - L.wagebill_gdp
gen s0 = d_wagebill_real
gen g_l1 = L.g
gen g_l2 = L2.g
* purga (inclinacoes por pais no crescimento corrente e em duas defasagens; EF de pais e ano)
gen byte sPu = !missing(s0, g, g_l1, g_l2) & inrange(year, 1990, 2023)
reghdfe s0 if sPu, absorb(id year id#c.g id#c.g_l1 id#c.g_l2) residuals(sb)
summ sa sb sc s0
corr s0 sa sb sc
forvalues hh = -3/6 {
    local nm = cond(`hh' < 0, "m`=-`hh''", "`hh'")
    if `hh' < 0 gen dy`nm' = L`=-`hh''.y100 - L.y100
    else gen dy`nm' = F`hh'.y100 - L.y100
}
foreach s in sa sb sc s0 {
    forvalues k = 1/3 {
        gen `s'_l`k' = L`k'.`s'
    }
}
gen g_l3 = L3.g
* regime de merito: acima da mediana em t - 2 (predeterminado em relacao ao choque (a))
gen merit_l2 = L2.merit
gen byte smpA = !missing(sa, sa_l1, sa_l2, g_l1, g_l2) & inrange(year, 1996, 2023)
quietly summ merit_l2 if smpA, detail
gen byte mhi = merit_l2 > r(p50) if !missing(merit_l2)
gen shi = sa * (mhi == 1) if !missing(mhi)
gen stot = sa if !missing(mhi)
save "$RINT/lp_k.dta", replace

tempname P
postfile `P' str4 shock int h str4 inf double(b se lo hi p) long(N nc) using "$RINT/lpk_res.dta", replace
foreach s in sa sb sc s0 {
    forvalues hh = -3/6 {
        if `hh' == -1 continue
        local nm = cond(`hh' < 0, "m`=-`hh''", "`hh'")
        * Driscoll-Kraay
        quietly xtscc dy`nm' `s' `s'_l1 `s'_l2 g_l1 g_l2 i.year if inrange(year, 1996, 2023), fe lag($DKLAG)
        local b = _b[`s']
        local se = _se[`s']
        local df = e(df_r)
        post `P' ("`s'") (`hh') ("dk") (`b') (`se') (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') ///
            (2 * ttail(`df', abs(`b' / `se'))) (e(N)) (e(N_g))
        local sedk = `se'
        local bdk = `b'
        local dfdk = `df'
        * defasagens aumentadas (uma defasagem extra do choque e do crescimento, EP robustos a heterocedasticidade)
        quietly reghdfe dy`nm' `s' `s'_l1 `s'_l2 `s'_l3 g_l1 g_l2 g_l3 if inrange(year, 1996, 2023), absorb(id year) vce(robust)
        local b = _b[`s']
        local se = _se[`s']
        local df = e(df_r)
        post `P' ("`s'") (`hh') ("la") (`b') (`se') (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') ///
            (2 * ttail(`df', abs(`b' / `se'))) (e(N)) (.)
        * jackknife de meio painel (EP de Driscoll-Kraay da amostra inteira)
        quietly xtscc dy`nm' `s' `s'_l1 `s'_l2 g_l1 g_l2 i.year if inrange(year, 1996, 2009), fe lag($DKLAG)
        local b1 = _b[`s']
        quietly xtscc dy`nm' `s' `s'_l1 `s'_l2 g_l1 g_l2 i.year if inrange(year, 2010, 2023), fe lag($DKLAG)
        local b2 = _b[`s']
        local bj = 2 * `bdk' - (`b1' + `b2') / 2
        post `P' ("`s'") (`hh') ("jk") (`bj') (`sedk') (`bj' - invttail(`dfdk', 0.025) * `sedk') (`bj' + invttail(`dfdk', 0.025) * `sedk') ///
            (2 * ttail(`dfdk', abs(`bj' / `sedk'))) (.) (.)
    }
}
* diferenca alto - baixo merito com o choque (a): Driscoll-Kraay
forvalues hh = 0/6 {
    quietly xtscc dy`hh' shi stot i.mhi sa_l1 sa_l2 g_l1 g_l2 i.year if inrange(year, 1996, 2023), fe lag($DKLAG)
    local b = _b[shi]
    local se = _se[shi]
    local df = e(df_r)
    post `P' ("mdif") (`hh') ("dk") (`b') (`se') (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') ///
        (2 * ttail(`df', abs(`b' / `se'))) (e(N)) (e(N_g))
}
postclose `P'

* ---------------------------------------------------------------- choque (b): bootstrap por blocos de pais refazendo a purga
use "$RINT/lp_k.dta", clear
keep id year s0 g g_l1 g_l2 sPu dy* y100
tempfile base
save `base'
tempname B
postfile `B' int r int h double b using "$RINT/lpk_bootb.dta", replace
set seed 20261113
forvalues r = 1/999 {
    quietly use `base', clear
    quietly bsample, cluster(id) idcluster(bid)
    quietly xtset bid year
    capture quietly reghdfe s0 if sPu, absorb(bid year bid#c.g bid#c.g_l1 bid#c.g_l2) residuals(sbb)
    if _rc continue
    quietly gen sbb_l1 = L.sbb
    quietly gen sbb_l2 = L2.sbb
    forvalues hh = -3/6 {
        if `hh' == -1 continue
        local nm = cond(`hh' < 0, "m`=-`hh''", "`hh'")
        capture quietly reghdfe dy`nm' sbb sbb_l1 sbb_l2 g_l1 g_l2 if inrange(year, 1996, 2023), absorb(bid year)
        if !_rc post `B' (`r') (`hh') (_b[sbb])
    }
}
postclose `B'
use "$RINT/lpk_bootb.dta", clear
bysort h: egen double blo = pctile(b), p(2.5)
bysort h: egen double bhi = pctile(b), p(97.5)
bysort h: egen double bsd = sd(b)
bysort h: gen nrep = _N
bysort h: keep if _n == 1
keep h blo bhi bsd nrep
save "$RINT/lpk_bootb_sum.dta", replace
list, noobs
quietly summ nrep
rv_kv lpk_bootb_reps_min `r(min)'
* substitui a inferencia do choque (b): EP e IC do bootstrap por blocos
use "$RINT/lpk_res.dta", clear
merge m:1 h using "$RINT/lpk_bootb_sum.dta", nogen
replace se = bsd if shock == "sb" & inlist(inf, "dk", "jk")
replace p = 2 * normal(-abs(b / bsd)) if shock == "sb" & inlist(inf, "dk", "jk")
replace lo = blo if shock == "sb" & inf == "dk"
replace hi = bhi if shock == "sb" & inf == "dk"
replace lo = b - invnormal(0.975) * bsd if shock == "sb" & inf == "jk"
replace hi = b + invnormal(0.975) * bsd if shock == "sb" & inf == "jk"
drop blo bhi bsd nrep
save "$RINT/lpk_res.dta", replace

* ---------------------------------------------------------------- Romano-Wolf: sete horizontes da diferenca alto - baixo (choque (a))
capture program drop rw_test
program define rw_test
    args code file cond cmd v tv
    local cmd0 : subinstr local cmd "@" "id", all
    local cmdb : subinstr local cmd "@" "bid", all
    quietly use "`file'", clear
    quietly keep if `cond'
    quietly `cmd0'
    local b0 = _b[`v']
    local t0 = _b[`v'] / _se[`v']
    quietly keep if e(sample)
    quietly merge m:1 id using "$KIN/rw_draws.dta", keep(match) nogen
    tempfile base
    quietly save `base'
    tempname R
    postfile `R' int r double tstar using "$RINT/rw_`code'.dta", replace
    forvalues r = 1/999 {
        quietly use `base', clear
        quietly drop if n`r' == 0
        quietly expand n`r'
        quietly bysort id `tv': gen int cp = _n
        quietly egen long bid = group(id cp)
        capture quietly `cmdb'
        if !_rc post `R' (`r') ((_b[`v'] - `b0') / _se[`v'])
        else post `R' (`r') (.)
    }
    postclose `R'
    post RWT ("`code'") (`b0') (`t0')
end
postfile RWT str20 code double(b t) using "$RINT/rw_lpka.dta", replace
forvalues hh = 0/6 {
    rw_test KA`hh' "$RINT/lp_k.dta" "inrange(year, 1996, 2023)" "reghdfe dy`hh' shi stot i.mhi sa_l1 sa_l2 g_l1 g_l2 i.year, absorb(@) vce(cluster @)" shi year
}
postclose RWT
mata:
void _rwp(real colvector t, real matrix TS)
{
    real scalar K, B, j, i, r, cnt, cntj
    real colvector o, praw, padj, mx
    K = rows(t)
    B = rows(TS)
    o = order(-abs(t), 1)
    praw = J(K, 1, .)
    padj = J(K, 1, .)
    for (j = 1; j <= K; j++) {
        i = o[j]
        cnt = 0
        cntj = 0
        for (r = 1; r <= B; r++) {
            mx = max(abs(TS[r, o[j..K]]))
            if (mx >= abs(t[i])) cnt++
            if (abs(TS[r, i]) >= abs(t[i])) cntj++
        }
        padj[i] = (cnt + 1) / (B + 1)
        praw[i] = (cntj + 1) / (B + 1)
        if (j > 1) padj[i] = max((padj[i], padj[o[j - 1]]))
    }
    st_matrix("PR", praw)
    st_matrix("PRW", padj)
}
end
use "$RINT/rw_lpka.dta", clear
mkmat t, matrix(T)
mata: TS = J(999, 7, .)
forvalues k = 1/7 {
    local hh = `k' - 1
    preserve
    use "$RINT/rw_KA`hh'.dta", clear
    mata: TS[., `k'] = st_data(., "tstar")
    restore
}
mata: TS = editmissing(TS, 0)
mata: _rwp(st_matrix("T"), TS)
gen h = _n - 1
gen double p_rw = .
forvalues k = 1/7 {
    replace p_rw = PRW[`k', 1] in `k'
}
keep h p_rw
save "$RINT/lpk_rw.dta", replace
list, noobs

* =====================================================================================
* regra (adendo, Bloco 5) e Tabela S23
* =====================================================================================
use "$RINT/lpk_res.dta", clear
merge m:1 h using "$RINT/lpk_rw.dta", nogen
replace p_rw = . if shock != "mdif"
sort shock inf h
list shock h inf b se p p_rw N, noobs sepby(shock inf)
save "$RINT/lpk_res_full.dta", replace
kcsv "$RINT/lpk_res_full.dta" TabS23_lp_predetermined
gen byte sig = p < 0.05 & inrange(h, 3, 6) & shock == "sa"
bysort h: egen nsig = total(sig)
quietly count if shock == "sa" & inf == "dk" & inrange(h, 3, 6) & nsig >= 2
local nrob = r(N)
local delayed = (`nrob' > 0)
rv_kv lpk_delayed `delayed'
foreach hh in 4 5 6 {
    quietly summ b if shock == "sa" & inf == "dk" & h == `hh'
    rv_kv lpk_sa_h`hh'_b `=string(r(mean), "%9.4f")'
    quietly summ p if shock == "sa" & inf == "dk" & h == `hh'
    rv_kv lpk_sa_h`hh'_p `=string(r(mean), "%9.4f")'
    quietly summ b if shock == "s0" & inf == "dk" & h == `hh'
    rv_kv lpk_s0_h`hh'_b `=string(r(mean), "%9.4f")'
}
di "Bloco 5: horizontes 3-6 com choque (a) significativos em 2 de 3 inferencias: `nrob'; custo defasado robusto = `delayed'"
local ttl = cond(`delayed', "A predetermined wage bill shock is followed by lower output at some horizons", ///
    "With a predetermined wage bill shock there is no robust evidence of a delayed output cost")

rv_new, ncol(9) head1("(a) Shock dated t − 1" "" "" "(b) Purged shock" "" "" "(c) Deflator of t − 1" "" "") ///
    head2("Driscoll-Kraay" "Lag-augmented" "Half-panel jackknife" "Block bootstrap" "Lag-augmented" "Jackknife, bootstrap SE" "Driscoll-Kraay" "Lag-augmented" "Half-panel jackknife")
rv_row "A. Cumulative response of 100 × log GDP per capita from t − 1 to t + h (leads h < 0)" "" "" "" "" "" "" "" "" ""
forvalues hh = -3/6 {
    if `hh' == -1 continue
    local cb ""
    local cs ""
    foreach k in "sa dk" "sa la" "sa jk" "sb dk" "sb la" "sb jk" "sc dk" "sc la" "sc jk" {
        tokenize `k'
        quietly summ b if shock == "`1'" & inf == "`2'" & h == `hh'
        local b = r(mean)
        quietly summ p if shock == "`1'" & inf == "`2'" & h == `hh'
        rv_fmt `b' %12.3f `=r(mean)'
        local cb `"`cb' "`r(s)'""'
        quietly summ lo if shock == "`1'" & inf == "`2'" & h == `hh'
        rv_fmt `=r(mean)' %12.2f
        local l "`r(s)'"
        quietly summ hi if shock == "`1'" & inf == "`2'" & h == `hh'
        rv_fmt `=r(mean)' %12.2f
        local cs `"`cs' "[`l'; `r(s)']""'
    }
    rv_row "h = `=cond(`hh' < 0, uchar(8722) + string(-`hh'), string(`hh'))'" `cb'
    rv_row "" `cs'
}
quietly summ N if shock == "sa" & inf == "dk" & h == 4
local na = r(mean)
quietly summ N if shock == "sc" & inf == "dk" & h == 4
local ncc = r(mean)
quietly summ N if shock == "sb" & inf == "dk" & h == 4
rv_row "Observations (h = 4)" "`=string(`na', "%9.0fc")'" "" "" "`=string(r(mean), "%9.0fc")'" "" "" "`=string(`ncc', "%9.0fc")'" "" ""
rv_mid
rv_row "B. Shock (a): high − low merit (merit above the median in t − 2)" "" "" "" "" "" "" "" "" ""
local cb ""
local cp ""
local cr ""
forvalues hh = 0/6 {
    quietly summ b if shock == "mdif" & h == `hh'
    local b = r(mean)
    quietly summ p if shock == "mdif" & h == `hh'
    local pdk = r(mean)
    rv_fmt `b' %12.3f `pdk'
    local x "`r(s)'"
    rv_fmt `pdk' %12.3f
    local px "`r(s)'"
    quietly summ p_rw if shock == "mdif" & h == `hh'
    rv_fmt `=r(mean)' %12.3f
    rv_row "h = `hh': difference; Driscoll-Kraay p; Romano–Wolf p" "`x'" "`px'" "`r(s)'" "" "" "" "" "" ""
}
rv_out TabS23_lp_predetermined, landscape ///
    title("Table S23. `ttl'") ///
    notes("Annual panel 1996–2023, no microstates. Local projections of 100 × log GDP per capita from t − 1 to t + h on a wage bill shock (percentage points of GDP), with two lags of the shock and of growth and country and year fixed effects; h = −1 is zero by construction. Shocks: (a) 100 × (W_{t−1}/P_{t−2} − W_{t−2}/P_{t−2}) / y_{t−2}, dated in t − 1 and deflated by the deflator of t − 2, so it uses no current prices or output; (b) residual of the current shock (100 × (W_t/P_t − W_{t−1}/P_{t−1}) / y_{t−1}) on current growth and two lags, with country-specific slopes and country and year fixed effects; (c) the current shock deflated by the deflator of t − 1. Inference: Driscoll-Kraay standard errors (maximum lag 3); lag-augmented local projections (Montiel Olea and Plagborg-Møller, 2021: one more lag of the shock and of growth, heteroskedasticity-robust errors); half-panel jackknife bias correction (2 × full sample − mean of 1996–2009 and 2010–2023), with the full-sample Driscoll-Kraay standard error. Shock (b) is a generated regressor: its standard errors and 95% CIs come from a country block bootstrap that re-estimates the purging regression in each of 999 replications (percentile CI in the first column; lag-augmented column with robust errors that ignore the generated-regressor step). Panel B: shock (a) interacted with merit above the median in t − 2 (V-Dem), with the total shock as control, so the coefficient is high − low; Romano–Wolf step-down p over h = 0–6, 999 country draws. Stars from the standard errors of each column; 95% CIs in brackets. Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")

* Figura S6: tres choques (Driscoll-Kraay; choque (b) com bootstrap)
use "$RINT/lpk_res.dta", clear
keep if inf == "dk" & inlist(shock, "sa", "sb", "sc")
local nobs = _N + 3
set obs `nobs'
replace shock = cond(_n == _N - 2, "sa", cond(_n == _N - 1, "sb", "sc")) if missing(h)
replace h = -1 if missing(h)
replace b = 0 if h == -1
replace lo = 0 if h == -1
replace hi = 0 if h == -1
gen hx = h + cond(shock == "sa", -0.15, cond(shock == "sb", 0, 0.15))
sort shock h
twoway (rcap lo hi hx if shock == "sa", lcolor(black)) (connected b hx if shock == "sa", lcolor(black) mcolor(black) msymbol(O) msize(small)) ///
       (rcap lo hi hx if shock == "sb", lcolor(gs7)) (connected b hx if shock == "sb", lcolor(gs7) mcolor(gs7) msymbol(D) msize(small) lpattern(dash)) ///
       (rcap lo hi hx if shock == "sc", lcolor(gs11)) (connected b hx if shock == "sc", lcolor(gs11) mcolor(gs11) msymbol(T) msize(small) lpattern(shortdash)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(shortdash)) xline(-1, lcolor(gs12) lpattern(dot)) xlabel(-3(1)6, labsize(8pt)) ///
       ytitle("100 × log GDP per capita, t − 1 to t + h", size(8pt)) xtitle("Horizon h (years)", size(8pt)) ///
       legend(order(2 "(a) Shock dated t − 1" 4 "(b) Purged shock" 6 "(c) Deflator of t − 1") rows(1) pos(6) size(8pt))
rv_fig FigS6_lp_shocks, width(190) height(95)
* nova Figura 3: choque (a) com leads
twoway (rcap lo hi h if shock == "sa", lcolor(black)) (connected b h if shock == "sa", lcolor(black) mcolor(black) msymbol(O) msize(small)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(shortdash)) xline(-1, lcolor(gs12) lpattern(dot)) xlabel(-3(1)6, labsize(8pt)) ///
       ytitle("100 × log GDP per capita, t − 1 to t + h", size(8pt)) xtitle("Horizon h (years); shock dated t − 1, Driscoll-Kraay 95% CI", size(8pt)) legend(off)
rv_fig Fig3new_lp_shock_a, width(190) height(85)
log close
