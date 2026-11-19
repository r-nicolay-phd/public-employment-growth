* 06c_tabela_simulacao.do -- Bloco 6: placebo x razao contemporanea, decomposicao em log, Tabela S24 e Figura S7
* Le os resultados da simulacao registrada (06_simulacao.do) e do diagnostico pos-hoc (06b_simulacao_ar.do).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/06c_tabela_simulacao.log", replace text
local simar_sd1 ""
local simar_ar1 ""
capture confirm file "$RINT/kv.csv"
if !_rc {
    preserve
    import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
        capture quietly levelsof value if key == "simar_sd1", local(simar_sd1) clean
    if "`simar_sd1'" != "" local simar_sd1 : word `: word count `simar_sd1'' of `simar_sd1'
    capture quietly levelsof value if key == "simar_ar1", local(simar_ar1) clean
    if "`simar_ar1'" != "" local simar_ar1 : word `: word count `simar_ar1'' of `simar_ar1'
    restore
}
* ---------------------------------------------------------------- placebo x razao contemporanea e decomposicao em log
use "$RINT/sim_base.dta", clear
corr wb wb_placebo if sA
local rho = r(rho)
rv_kv sim_corr_placebo `=string(`rho', "%6.3f")'
preserve
keep if sA
keep id year g wb wb_placebo $XA
gen long obs = _n
expand 2
bysort obs: gen byte m = _n
gen double x1 = wb * (m == 1)
gen double x2 = wb_placebo * (m == 2)
egen idm = group(id m)
quietly reghdfe g x1 x2 c.(g_l1 lny_l1 hc inv open infl popg ctot_g)#i.m i.year#i.m, absorb(idm) vce(cluster id)
lincom x2 - x1
local dpl = r(estimate)
kboot {x2 - x1 = 0}
local dpl_p = r(p)
local dpl_lo = r(lo)
local dpl_hi = r(hi)
restore
rv_kv sim_placebo_diff `=string(`dpl', "%9.4f")'
rv_kv sim_placebo_diff_p `=string(`dpl_p', "%9.4f")'
xtscc g lwb_trend lgap_ham $XA i.year if sA, fe lag($DKLAG)
local bl = _b[lwb_trend]
local sl = _se[lwb_trend]
quietly summ wb_ham if sA
local mw = r(mean)
local eff = `bl' / `mw'
local effse = `sl' / `mw'
rv_kv sim_logdec_eff `=string(`eff', "%9.4f")'
rv_kv sim_logdec_lo `=string(`eff' - 1.96 * `effse', "%9.4f")'
rv_kv sim_logdec_hi `=string(`eff' + 1.96 * `effse', "%9.4f")'

use "$RINT/sim_sum.dta", clear
quietly summ share if meas == "A_wb" & abs(eps - 0.48) < 1e-6
local sh = r(mean)
rv_kv sim_share_samey `=string(`sh', "%6.3f")'
quietly summ inside if meas == "F_wb_m1_m1" & abs(eps - 0.48) < 1e-6
rv_kv sim_T3_inside `r(mean)'
local rule = cond(`sh' >= 0.80, "essentially all", cond(`sh' >= 0.50, "most", "rewrite"))
rv_kv sim_rule "`rule'"
di "Bloco 6: a media simulada explica `sh' do coeficiente anual do mesmo ano; regra: `rule'"
local pct = string(100 * `sh', "%3.0f")

rv_new, ncol(7) head1("Observed" "Simulated, ε = 0.48" "" "" "ε = 0.30" "ε = 0.70" "") ///
    head2("coefficient" "Mean" "2.5–97.5 percentiles" "Share of observed" "Mean" "Mean" "Observed inside 95% (ε = 0.48)")
foreach blk in "A A. Annual panel (Table 1 sample)" "F B. Five-year averages (own samples)" {
    gettoken pf ttl : blk
    rv_row "`=strtrim("`ttl'")'" "" "" "" "" "" "" ""
    local ms = cond("`pf'" == "A", "A_wb A_wb_hp2 A_wb_hp1 A_wb_ham A_wb_l1 A_wbham_l1", "F_wb_mean_mean F_wb_tp_mean F_wb_m1_mean F_wb_mean_m1 F_wb_tp_m1 F_wb_m1_m1")
    foreach m of local ms {
        local lab = cond("`m'" == "A_wb", "Same year", cond("`m'" == "A_wb_hp2", "% of trend GDP, two-sided HP", cond("`m'" == "A_wb_hp1", "% of trend GDP, one-sided HP", ///
            cond("`m'" == "A_wb_ham", "% of trend GDP, Hamilton", cond("`m'" == "A_wb_l1", "Lagged one year", cond("`m'" == "A_wbham_l1", "Lagged, % of trend GDP (Hamilton)", ///
            cond("`m'" == "F_wb_mean_mean", "Period mean, period-mean controls", cond("`m'" == "F_wb_tp_mean", "t_p, period-mean controls", ///
            cond("`m'" == "F_wb_m1_mean", "t_p − 1, period-mean controls", cond("`m'" == "F_wb_mean_m1", "Period mean, controls in t_p − 1", ///
            cond("`m'" == "F_wb_tp_m1", "t_p, controls in t_p − 1", "t_p − 1, controls in t_p − 1 (T3)")))))))))))
        quietly summ bobs if meas == "`m'" & abs(eps - 0.48) < 1e-6
        rv_fmt `=r(mean)' %12.3f
        local c1 "`r(s)'"
        quietly summ mean if meas == "`m'" & abs(eps - 0.48) < 1e-6
        rv_fmt `=r(mean)' %12.3f
        local c2 "`r(s)'"
        quietly summ p025 if meas == "`m'" & abs(eps - 0.48) < 1e-6
        rv_fmt `=r(mean)' %12.3f
        local l "`r(s)'"
        quietly summ p975 if meas == "`m'" & abs(eps - 0.48) < 1e-6
        rv_fmt `=r(mean)' %12.3f
        local c3 "[`l'; `r(s)']"
        quietly summ share if meas == "`m'" & abs(eps - 0.48) < 1e-6
        local c4 = string(100 * r(mean), "%5.0f") + "%"
        quietly summ mean if meas == "`m'" & abs(eps - 0.30) < 1e-6
        rv_fmt `=r(mean)' %12.3f
        local c5 "`r(s)'"
        quietly summ mean if meas == "`m'" & abs(eps - 0.70) < 1e-6
        rv_fmt `=r(mean)' %12.3f
        local c6 "`r(s)'"
        quietly summ inside if meas == "`m'" & abs(eps - 0.48) < 1e-6
        local c7 = cond(r(mean) == 1, "Yes", "No")
        rv_row "`lab'" "`c1'" "`c2'" "`c3'" "`c4'" "`c5'" "`c6'" "`c7'"
    }
    rv_mid
}
rv_fmt `dpl' %12.3f `dpl_p'
local x "`r(s)'"
rv_fmt `dpl_lo' %12.3f
local l "`r(s)'"
rv_fmt `dpl_hi' %12.3f
rv_row "C. Placebo − same-year coefficient (stacked model, wild bootstrap 95% CI); correlation of the two regressors" "`x' [`l'; `r(s)']" "ρ = `=string(`rho', "%5.3f")'" "" "" "" "" ""
rv_fmt `eff' %12.3f
local x "`r(s)'"
rv_fmt `=`eff' - 1.96 * `effse'' %12.3f
local l "`r(s)'"
rv_fmt `=`eff' + 1.96 * `effse'' %12.3f
rv_row "D. log(W/Y*) coefficient per point of trend GDP at the sample mean (95% CI)" "`x' [`l'; `r(s)']" "" "" "" "" "" ""
quietly summ nrep if abs(eps - 0.48) < 1e-6
local nr = r(min)
* diagnostico da serie sintetica registrada (uma replicacao, eps = 0,48) contra a folha observada
preserve
do "$ROOT/code/kyklos/wsim_mata.do"
use "$RINT/sim_base.dta", clear
set seed 20261113
gen double u = dlW - 0.48 * dlYn
gen double lWs = .
mata: _wsim("id", "u", "dlYn", "w0", "lWs", 0.48)
gen double ws = 100 * exp(lWs) / gdp_nom_lcu
foreach v in wb ws {
    bysort id: egen double _m`v' = mean(`v') if sA
    gen double _d`v' = `v' - _m`v'
    quietly summ _d`v' if sA
    local sdw_`v' = r(sd)
}
xtset id year
quietly regress wb L.wb if sA
local ar_wb = _b[L.wb]
quietly regress ws L.ws if sA
local ar_ws = _b[L.ws]
quietly summ ws if sA
local mx_ws = r(max)
restore
rv_kv sim_diag_sdw_obs `=string(`sdw_wb', "%6.3f")'
rv_kv sim_diag_sdw_sim `=string(`sdw_ws', "%6.3f")'
rv_kv sim_diag_ar_obs `=string(`ar_wb', "%6.3f")'
rv_kv sim_diag_ar_sim `=string(`ar_ws', "%6.3f")'
local diag "In the registered design the synthetic ratio is a random walk: in one replication its within-country SD is `=string(`sdw_ws', "%4.2f")' points of GDP (observed: `=string(`sdw_wb', "%4.2f")'), its AR(1) coefficient `=string(`ar_ws', "%5.3f")' (observed: `=string(`ar_wb', "%5.3f")') and its maximum `=string(`mx_ws', "%4.1f")'% of GDP."
local pe ""
capture confirm file "$RINT/simar_sum.dta"
if !_rc {
    preserve
    use "$RINT/simar_sum.dta", clear
    rv_row "E. Post-hoc diagnostic, not pre-registered: synthetic ratio anchored on the observed ratio of t − 1 (ε = 0.48)" "" "" "" "" "" "" ""
    foreach m in A_wb A_wb_ham A_wb_l1 F_wb_m1_m1 {
        local lab = cond("`m'" == "A_wb", "Annual: same year", cond("`m'" == "A_wb_ham", "Annual: % of trend GDP, Hamilton", ///
            cond("`m'" == "A_wb_l1", "Annual: lagged one year", "Five-year: t_p − 1, controls in t_p − 1 (T3)")))
        quietly summ bobs if meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local c1 "`r(s)'"
        quietly summ mean if meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local c2 "`r(s)'"
        quietly summ p025 if meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local l "`r(s)'"
        quietly summ p975 if meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local c3 "[`l'; `r(s)']"
        quietly summ share if meas == "`m'"
        local c4 = string(100 * r(mean), "%5.0f") + "%"
        quietly summ bobs if meas == "`m'"
        local bo = r(mean)
        quietly summ p025 if meas == "`m'"
        local in = (`bo' >= r(mean))
        quietly summ p975 if meas == "`m'"
        local in = `in' & (`bo' <= r(mean))
        rv_row "`lab'" "`c1'" "`c2'" "`c3'" "`c4'" "" "" "`=cond(`in', "Yes", "No")'"
    }
    restore
    local pe " Panel E (post-hoc diagnostic, added after the registered result was seen and not used in any decision): the same null with the synthetic ratio anchored one step ahead on the observed ratio, ln(W/Y)_sim,t = ln(W/Y)_t−1 + (ε − 1) Δln nominal GDP_t + e_t, with e drawn from the country's values of Δln(W/Y) − (ε − 1) Δln nominal GDP; this removes the drift (within-country SD `simar_sd1', AR(1) `simar_ar1' in one replication)."
}
rv_out TabS24_simulation, landscape ///
    title("Table S24. A zero-effect wage bill reproduces `pct'% of the same-year coefficient") ///
    notes("Simulation under a calibrated null. The observed GDP, growth and controls of each country are kept and only the wage bill is replaced by a synthetic series with no effect on growth: ln W_sim,t = ln W_sim,t−1 + ε Δln nominal GDP_t + u_t, with u drawn with replacement from the country's own values of Δln W − ε Δln nominal GDP and the initial level equal to the observed wage bill in the country's first year; ε = 0.48 is the elasticity of Table S3 (variants 0.30 and 0.70); `nr' replications or more per measure. In each replication the regressions of Table 1 are re-estimated with the synthetic series: annual panel 1996–2023 with the controls of Table 1 and country and year fixed effects, in the Table 1 sample; five-year averages with period-mean controls or controls in t_p − 1 and country and period fixed effects, each in the sample of the observed specification. Share of observed: simulated mean divided by the observed coefficient. Panel C: placebo-numerator minus same-year coefficient in a stacked model with country × measure fixed effects, wild cluster bootstrap by country (Webb weights, 9,999 replications); ρ is the correlation between the same-year ratio and the placebo ratio in the Table 1 sample. Panel D: coefficient on log(wage bill / trend GDP) in the decomposition of Table S3 divided by the sample mean of the wage bill over trend GDP, with a delta-method 95% CI (Driscoll-Kraay standard error); compare with T3. `diag'`pe' Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")

* Figura S7: distribuicoes simuladas (eps = 0,48) com o valor observado
use "$RINT/sim_draws.dta", clear
keep if (abs(eps - 0.48) < 1e-6 | rep == 0) & inlist(meas, "A_wb", "F_wb_m1_m1")
quietly summ b if rep == 0 & meas == "A_wb"
local oa = r(mean)
quietly summ b if rep == 0 & meas == "F_wb_m1_m1"
local of = r(mean)
twoway (kdensity b if meas == "A_wb" & rep > 0, lcolor(black)), $GOPT xline(`oa', lcolor(black) lpattern(dash)) xline(0, lcolor(gs10) lpattern(shortdash)) xscale(range(`=floor(10 * `oa') / 10' 0.1)) xlabel(`=floor(10 * `oa') / 10'(0.1)0.1, format(%3.1f) labsize(8pt)) ///
    title("(a) Annual, same-year ratio", size(9pt)) xtitle("Coefficient", size(8pt)) ytitle("Density", size(8pt)) legend(off) name(s1, replace) nodraw
twoway (kdensity b if meas == "F_wb_m1_m1" & rep > 0, lcolor(black)), $GOPT xline(`of', lcolor(black) lpattern(dash)) xline(0, lcolor(gs10) lpattern(shortdash)) ///
    title("(b) Five-year, t{sub:p} − 1 with controls in t{sub:p} − 1 (T3)", size(9pt)) xtitle("Coefficient", size(8pt)) ytitle("Density", size(8pt)) legend(off) name(s2, replace) nodraw
graph combine s1 s2, cols(2) graphregion(color(white)) note("Solid: simulated coefficients with a zero-effect wage bill (ε = 0.48); dashed: observed coefficient.", size(7pt))
rv_fig FigS7_simulation, width(190) height(80)
log close
