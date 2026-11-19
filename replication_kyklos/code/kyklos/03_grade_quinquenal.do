* 03_grade_quinquenal.do -- Bloco 3: sequencia quinquenal com controles predeterminados (grade 3 x 2 na mesma amostra)
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/03_grade_quinquenal.log", replace text

use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
* amostra comum de todas as celulas
gen byte sG = !missing(g, g_x1, wb_mean, wb_tp, wb_m1, wb_ham_m1, lny0, hc_tp, inv, open, infl, popg, ctot_g, ///
    hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
count if sG
rv_kv grid_N `r(N)'
tempname P
postfile `P' str10 dep str10 meas str4 ctrl str12 swap double(b se p lo hi pboot blo bhi) long(N nc) using "$RINT/grade_res.dta", replace
capture program drop gcell
program define gcell
    args P dep meas ctrl swap X
    quietly reghdfe `dep' `meas' `X' i.period if sG, absorb(id) vce(cluster id)
    local b = _b[`meas']
    local se = _se[`meas']
    local df = e(df_r)
    local N = e(N)
    local nc = e(N_clust)
    kboot `meas'
    post `P' ("`dep'") ("`meas'") ("`ctrl'") ("`swap'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) ///
        (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') (r(p)) (r(lo)) (r(hi)) (`N') (`nc')
end
foreach dep in g g_x1 {
    foreach meas in wb_mean wb_tp wb_m1 wb_ham_m1 {
        gcell `P' `dep' `meas' mean none "$XD"
        gcell `P' `dep' `meas' m1 none "$XP"
    }
}
* decomposicao: a partir de T1 (wb_m1, controles da media do periodo), troca um controle por vez para t_p - 1
foreach k in "inv inv_m1" "open open_m1" "infl infl_m1" "popg popg_m1" "ctot_g ctot_g_m1" "lny0 lny0" "hc_tp hc_m1" {
    tokenize `k'
    local X : subinstr global XD "`1'" "`2'", word
    gcell `P' g wb_m1 swap `1' "`X'"
}
postclose `P'

use "$RINT/grade_res.dta", clear
list, noobs sep(0)
kcsv "$RINT/grade_res.dta" TabS21_five_year_grid
* regra (adendo, Bloco 3): reducao de t_p para t_p - 1 com controles predeterminados
quietly summ b if dep == "g" & meas == "wb_tp" & ctrl == "m1"
local btp = r(mean)
quietly summ b if dep == "g" & meas == "wb_m1" & ctrl == "m1"
local bm1 = r(mean)
local red = 1 - `bm1' / `btp'
rv_kv grid_btp_pre `=string(`btp', "%9.4f")'
rv_kv grid_bm1_pre `=string(`bm1', "%9.4f")'
rv_kv grid_red `=string(`red', "%9.4f")'
local keep = (`red' >= 0.40)
rv_kv grid_keep `keep'
di "Bloco 3: t_p = `btp'; t_p - 1 = `bm1'; reducao = `red'; manter frase = `keep'"
quietly summ b if dep == "g" & meas == "wb_tp" & ctrl == "mean"
local btpm = r(mean)
quietly summ b if dep == "g" & meas == "wb_m1" & ctrl == "mean"
local red_mean = 1 - r(mean) / `btpm'
rv_kv grid_red_meanctrl `=string(`red_mean', "%9.4f")'
local ttl = cond(`keep', "With predetermined controls, moving the wage bill from t_p to t_p − 1 still reduces the five-year coefficient", ///
    "With predetermined controls, first-year timing matters little for the five-year coefficient")

rv_new, ncol(4) head1("Period-mean controls" "" "Controls in t_p − 1" "") head2("Average growth" "Growth excl. t_p" "Average growth" "Growth excl. t_p")
rv_row "A. Same sample for all cells: measure of the wage bill" "" "" "" ""
foreach m in wb_mean wb_tp wb_m1 wb_ham_m1 {
    local lab = cond("`m'" == "wb_mean", "Period mean", cond("`m'" == "wb_tp", "First year (t_p)", cond("`m'" == "wb_m1", "Last year of previous period (t_p − 1)", "t_p − 1, % of trend GDP (Hamilton)")))
    local cb ""
    local cs ""
    foreach c in "mean g" "mean g_x1" "m1 g" "m1 g_x1" {
        tokenize `c'
        quietly summ b if meas == "`m'" & ctrl == "`1'" & dep == "`2'" & swap == "none"
        local b = r(mean)
        quietly summ pboot if meas == "`m'" & ctrl == "`1'" & dep == "`2'" & swap == "none"
        rv_fmt `b' %12.3f `=r(mean)'
        local cb `"`cb' "`r(s)'""'
        quietly summ blo if meas == "`m'" & ctrl == "`1'" & dep == "`2'" & swap == "none"
        rv_fmt `=r(mean)' %12.3f
        local l "`r(s)'"
        quietly summ bhi if meas == "`m'" & ctrl == "`1'" & dep == "`2'" & swap == "none"
        rv_fmt `=r(mean)' %12.3f
        local cs `"`cs' "[`l'; `r(s)']""'
    }
    rv_row "`lab'" `cb'
    rv_row "" `cs'
}
quietly summ N if swap == "none"
local n = r(mean)
quietly summ nc if swap == "none"
rv_row "Observations (countries)" "`=string(`n', "%9.0fc")' (`=r(mean)')" "" "" ""
rv_mid
rv_row "B. From period-mean controls (wage bill in t_p − 1, average growth): one control switched to t_p − 1" "" "" "" ""
foreach s in none inv open infl popg ctot_g lny0 hc_tp {
    local lab = cond("`s'" == "none", "None (all period-mean controls)", cond("`s'" == "inv", "Investment", cond("`s'" == "open", "Openness", ///
        cond("`s'" == "infl", "Inflation", cond("`s'" == "popg", "Population growth", cond("`s'" == "ctot_g", "Terms-of-trade growth", ///
        cond("`s'" == "lny0", "Log GDP per capita (already in t_p − 1)", "Human capital")))))))
    if "`s'" == "none" {
        quietly summ b if meas == "wb_m1" & ctrl == "mean" & dep == "g" & swap == "none"
        local b = r(mean)
        quietly summ pboot if meas == "wb_m1" & ctrl == "mean" & dep == "g" & swap == "none"
        local pb = r(mean)
        quietly summ blo if meas == "wb_m1" & ctrl == "mean" & dep == "g" & swap == "none"
        local l = r(mean)
        quietly summ bhi if meas == "wb_m1" & ctrl == "mean" & dep == "g" & swap == "none"
        local h = r(mean)
    }
    else {
        quietly summ b if swap == "`s'"
        local b = r(mean)
        quietly summ pboot if swap == "`s'"
        local pb = r(mean)
        quietly summ blo if swap == "`s'"
        local l = r(mean)
        quietly summ bhi if swap == "`s'"
        local h = r(mean)
    }
    rv_fmt `b' %12.3f `pb'
    local x "`r(s)'"
    rv_fmt `l' %12.3f
    local ls "`r(s)'"
    rv_fmt `h' %12.3f
    rv_row "`lab'" "`x'" "[`ls'; `r(s)']" "" ""
}
rv_out TabS21_five_year_grid, landscape ///
    title("Table S21. `ttl'") ///
    notes("Five-year averages 1979–2023, no microstates; growth of real GDP per capita (average of the period, or of t_p + 1 to t_p + 4) on the wage bill (general government, % of GDP), country and period fixed effects, standard errors clustered by country. All cells of panel A use one sample, the intersection of every cell (country-periods with all measures and both sets of controls). Period-mean controls: log GDP per capita in t_p − 1, human capital in t_p and period means of investment, openness, inflation, population growth and terms-of-trade growth (the conventional specification). Controls in t_p − 1: all controls in the last year of the previous period (T3). Panel B starts from the wage bill in t_p − 1 with period-mean controls and switches one control at a time to its t_p − 1 value. Coefficients with stars and 95% CIs from the wild cluster bootstrap by country (Webb weights, 9,999 replications). Reduction from t_p to t_p − 1 with controls in t_p − 1: `=string(100 * `red', "%4.1f")'%; with period-mean controls: `=string(100 * `red_mean', "%4.1f")'%. Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")

* Figura: grade (nova versao da Figura 1)
use "$RINT/grade_res.dta", clear
keep if swap == "none" & dep == "g"
gen ord = cond(meas == "wb_mean", 4, cond(meas == "wb_tp", 3, cond(meas == "wb_m1", 2, 1)))
gen pos = ord + cond(ctrl == "mean", 0.15, -0.15)
twoway (rcap blo bhi pos if ctrl == "mean", horizontal lcolor(black)) (scatter pos b if ctrl == "mean", msymbol(O) mcolor(black) msize(small)) ///
       (rcap blo bhi pos if ctrl == "m1", horizontal lcolor(gs8) lpattern(dash)) (scatter pos b if ctrl == "m1", msymbol(D) mcolor(gs8) msize(small)), ///
       $GOPT xline(0, lcolor(gs10) lpattern(shortdash)) ///
       ylabel(4 "Period mean" 3 "First year (t{sub:p})" 2 "Last year of previous period (t{sub:p} − 1)" 1 "t{sub:p} − 1, % of trend GDP", angle(0) labsize(8pt) nogrid) ///
       ytitle("") xtitle("Coefficient on the wage bill (p.p. of growth per p.p. of GDP), bootstrap 95% CI", size(8pt)) ///
       legend(order(2 "Period-mean controls" 4 "Controls in t{sub:p} − 1") rows(1) pos(6) size(8pt))
rv_fig Fig1new_timing_grid, width(190) height(90)
log close
