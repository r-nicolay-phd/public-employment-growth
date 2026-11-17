* 10_verificacoes.do -- Bloco 10: verificacoes menores (recessoes pelo hiato, antecipacao, tendencias, dinamica, GFSM)
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/10_verificacoes.log", replace text

tempname P
postfile `P' str12 chk str60 lab double(b se p lo hi) long(N nc) using "$RINT/verif.dta", replace
capture program drop pv
program define pv
    args P chk lab v
    local b = _b[`v']
    local se = _se[`v']
    local df = e(df_r)
    local nc = cond(e(N_clust) < ., e(N_clust), e(N_g))
    post `P' ("`chk'") ("`lab'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
        (`b' + invttail(`df', 0.025) * `se') (e(N)) (`nc')
end
* (1) recessoes pelo sinal do hiato de Hamilton em t - 1 (sem truncar a dependente)
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1991, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
gen gap_l1 = -L.lgap_ham
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
xtscc g wb $XA i.year if sA & gap_l1 < 0, fe lag($DKLAG)
pv `P' rec_neg "Same-year ratio, negative output gap in t − 1" wb
xtscc g wb $XA i.year if sA & gap_l1 >= 0 & !missing(gap_l1), fe lag($DKLAG)
pv `P' rec_pos "Same-year ratio, positive output gap in t − 1" wb
xtscc g wb $XA i.year if sA & g_raw >= 0, fe lag($DKLAG)
pv `P' rec_old "Same-year ratio, excluding negative-growth years (Table S3)" wb
* (3) correlacao do crescimento das tendencias com o crescimento corrente do PIB
gen dY = lnY - L.lnY
gen dHP1 = lnY_hp1 - L.lnY_hp1
gen dHAM = lnY_ham - L.lnY_ham
corr dY dHP1 if sA
local rhp = r(rho)
corr dY dHAM if sA
local rham = r(rho)
rv_kv ver_corr_hp1 `=string(`rhp', "%6.3f")'
rv_kv ver_corr_ham `=string(`rham', "%6.3f")'
* (2) antecipacao: folha em t_{p+1} - 1 sobre o crescimento do periodo p, controlando a folha em t_p - 1
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen wb_next = F.wb_m1
reghdfe wb_next g wb_m1 i.period, absorb(id) vce(cluster id)
pv `P' antic "Wage bill in t_(p+1) − 1 on growth in period p" g
* (4) dinamica no estimador preferido: T3 com crescimento defasado (LSDV)
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
pv `P' T3 "T3 (registered)" wb_m1
reghdfe g L.g wb_m1 $XP i.period, absorb(id) vce(cluster id)
pv `P' T3lsdv "T3 with lagged growth (LSDV)" wb_m1
postclose `P'
* T3 com correcao de vies (BC-FE de Breitung, Kripfganz e Hayakawa; estimado em code/revisao/12_inferencia.do)
import delimited "$KIN/kv.csv", clear varnames(1) stringcols(_all)
foreach k in T3bc_b T3bc_p {
    quietly levelsof value if key == "`k'", local(`k') clean
    local `k' : word `: word count ``k''' of ``k''
}
* (5) quebras do GFSM: as GFS do FMI (IMF.STA:GFS_SOO) nao informam a base metodologica por pais e ano
import delimited "$RAW/imf_gfs/gfs_soo.csv", clear varnames(1) case(lower) rowrange(1:2)
describe, varlist
local gv "`r(varlist)'"
local hasbase = strpos(lower("`gv'"), "gfsm") > 0 | strpos(lower("`gv'"), "method") > 0
rv_kv ver_gfsm_available `hasbase'
di "Colunas das GFS: `gv' -> base metodologica disponivel = `hasbase'"

use "$RINT/verif.dta", clear
list, noobs
kcsv "$RINT/verif.dta" TabS28_checks
rv_new, ncol(5) head1("Coefficient" "95% CI" "p-value" "Obs." "Countries")
forvalues i = 1/`=_N' {
    rv_fmt `=b[`i']' %12.3f `=p[`i']'
    local x "`r(s)'"
    rv_fmt `=lo[`i']' %12.3f
    local l "`r(s)'"
    rv_fmt `=hi[`i']' %12.3f
    local h "`r(s)'"
    rv_fmt `=p[`i']' %12.3f
    rv_row "`=lab[`i']'" "`x'" "[`l'; `h']" "`r(s)'" "`=string(N[`i'], "%9.0fc")'" "`=nc[`i']'"
}
rv_fmt `=real("`T3bc_b'")' %12.3f `=real("`T3bc_p'")'
rv_row "T3 with bias correction (BC-FE, Table A2, col. 3)" "`r(s)'" "" "`=string(real("`T3bc_p'"), "%5.3f")'" "" ""
rv_row "Correlation of one-sided HP trend growth with GDP growth" "`=string(`rhp', "%5.3f")'" "" "" "" ""
rv_row "Correlation of Hamilton trend growth with GDP growth" "`=string(`rham', "%5.3f")'" "" "" "" ""
rv_row "GFSM breaks (methodological basis by country-year)" "`=cond(`hasbase', "Available", "Not available in the GFS files: not estimated")'" "" "" "" ""
rv_out TabS28_checks, landscape ///
    title("Table S28. Smaller checks: recessions, anticipation, trend filters and dynamics") ///
    notes("Recessions: annual model of Table 1 (1996–2023, controls of Table 1, country and year fixed effects, Driscoll-Kraay standard errors), estimated separately for country-years with a negative or positive Hamilton output gap in t − 1 (log GDP minus Hamilton trend), instead of excluding years of negative growth (last row, as in Table S3). Anticipation: wage bill in the last year of period p (t_(p+1) − 1) on growth in period p, controlling for the wage bill in t_p − 1, country and period fixed effects, clustered standard errors. Trend filters: correlation between the annual growth of each trend (one-sided HP, λ = 6.25; Hamilton, H = 2, k = 2) and current GDP growth, Table 1 sample. Dynamics: T3 with the lagged five-year growth rate (LSDV, Nickell bias not corrected) and with bias correction (Table A2). GFSM breaks: the IMF GFS files used do not report the methodological basis (GFSM 1986, 2001 or 2014) by country and year, so the check of Table S8, row 7, could not be done. Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")
log close
