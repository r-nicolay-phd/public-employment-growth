* 03_vies.do -- bloco 4.2 do plano: decomposicao do vies de medida contemporanea [P3-P6, P8, P10, P12]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/revisao/00_setup.do"
capture log close
log using "$RLOG/03_vies.log", replace text

* controles da Tabela 1 do draft 7 (painel anual)
global XA "g_l1 lny_l1 hc inv open infl popg ctot_g"

use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1991, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
forvalues k = 1/5 {
    gen wbL`k' = L`k'.wb
    gen whL`k' = L`k'.wb_ham
}
keep if inrange(year, 1996, 2023)
* amostra comum de todas as medidas anuais (inclui HP unilateral, placebo e decomposicao)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
count if sA
rv_kv sA_N `r(N)'
corr wb_l1 wb_ham if sA
local corrlh = string(r(rho), "%5.3f")
rv_kv corr_lag_ham `corrlh'
corr wb_l1 wbham_l1 if sA
rv_kv corr_lag_lagham `=string(r(rho), "%5.3f")'

tempname P
postfile `P' str16 m str60 lab double(b se p lo hi) long(N nc) using "$RINT/vies_medidas.dta", replace
capture program drop postx
program define postx
    args P m lab v
    local b = _b[`v']
    local se = _se[`v']
    local df = e(df_r)
    post `P' ("`m'") ("`lab'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
        (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_g))
    rv_kv vies_`m'_b `=string(`b', "%9.4f")'
    rv_kv vies_`m'_se `=string(`se', "%9.4f")'
    rv_kv vies_`m'_p `=string(2 * ttail(`df', abs(`b' / `se')), "%9.4f")'
    rv_kv vies_`m'_N `e(N)'
end
* 4.2.3 medidas (mesmo modelo, mesma amostra)
foreach v in wb wb_hp2 wb_hp1 wb_ham wb_l1 wbham_l1 wb_placebo {
    xtscc g `v' $XA i.year if sA, fe lag($DKLAG)
    estimates store M_`v'
    local lab = cond("`v'" == "wb", "Contemporaneous ratio", cond("`v'" == "wb_hp2", "% of trend GDP, two-sided HP", ///
        cond("`v'" == "wb_hp1", "% of trend GDP, one-sided HP", cond("`v'" == "wb_ham", "% of trend GDP, Hamilton", ///
        cond("`v'" == "wb_l1", "Lagged one year", cond("`v'" == "wbham_l1", "Lagged one year, % of trend GDP (Hamilton)", ///
        "Placebo numerator (denominator only)"))))))
    postx `P' `v' "`lab'" `v'
}
* 4.2.2 decomposicao multiplicativa: log(W/Y*) e log(Y*/Y)
xtscc g lwb_trend lgap_ham $XA i.year if sA, fe lag($DKLAG)
estimates store M_dec
postx `P' dec_lwb "log(W/Y*), Hamilton" lwb_trend
postx `P' dec_gap "log(Y*/Y), Hamilton" lgap_ham
* 4.2.9 rigidez: coeficiente contemporaneo fora dos anos de recessao
xtscc g wb $XA i.year if sA & g_raw >= 0, fe lag($DKLAG)
estimates store M_norec
postx `P' norec "Contemporaneous ratio, excluding recession years" wb

* 4.2.3 painel de cinco anos: media do periodo, t_p, t_p - 1 e t_p - 1 sobre Hamilton (controles do draft 7)
preserve
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen byte s5 = !missing(g, wb_mean, wb_tp, wb_m1, wb_ham_m1, lny0, hc_tp, inv, open, infl, popg, ctot_g)
foreach v in wb_mean wb_tp wb_m1 wb_ham_m1 {
    reghdfe g `v' lny0 hc_tp inv open infl popg ctot_g i.period if s5, absorb(id) vce(cluster id)
    estimates store M5_`v'
    local b = _b[`v']
    local se = _se[`v']
    local df = e(df_r)
    local lab = cond("`v'" == "wb_mean", "5-year: period mean", cond("`v'" == "wb_tp", "5-year: t_p", ///
        cond("`v'" == "wb_m1", "5-year: t_p − 1", "5-year: t_p − 1, % of trend GDP (Hamilton)")))
    post `P' ("`v'") ("`lab'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
        (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_clust))
    rv_kv vies5_`v'_b `=string(`b', "%9.4f")'
    rv_kv vies5_`v'_p `=string(2 * ttail(`df', abs(`b' / `se')), "%9.4f")'
}
restore
postclose `P'

* =====================================================================================
* 4.2.5 diferencas entre medidas: modelo empilhado, wild cluster bootstrap por pais
* =====================================================================================
preserve
keep if sA
keep id year g wb wb_hp1 wb_ham wb_l1 wb_hp2 wbham_l1 g_l1 lny_l1 hc inv open infl popg ctot_g
gen long obs = _n
expand 6
bysort obs: gen byte m = _n
gen double x = cond(m == 1, wb, cond(m == 2, wb_ham, cond(m == 3, wb_l1, cond(m == 4, wb_hp1, cond(m == 5, wb_hp2, wbham_l1)))))
forvalues k = 1/6 {
    gen double x`k' = x * (m == `k')
}
egen idm = group(id m)
reghdfe g x1-x6 c.(g_l1 lny_l1 hc inv open infl popg ctot_g)#i.m i.year#i.m, absorb(idm) vce(cluster id)
* checagem: os coeficientes empilhados reproduzem as regressoes separadas
di "empilhado: contemp = " _b[x1] ", Hamilton = " _b[x2] ", defasada = " _b[x3] ", HP unilateral = " _b[x4]
tempname D
postfile `D' str40 dif double(d lo hi p) using "$RINT/vies_diferencas.dta", replace
foreach pair in "1 2" "1 3" "1 4" "3 2" "1 5" "3 6" {
    gettoken a c : pair
    local c = strtrim("`c'")
    lincom x`a' - x`c'
    local d = r(estimate)
    boottest {x`a' - x`c' = 0}, reps(9999) weighttype(webb) seed(20261017) nograph
    local pb = r(p)
    matrix CI = r(CI)
    local nm = cond("`pair'" == "1 2", "Contemporaneous − Hamilton", cond("`pair'" == "1 3", "Contemporaneous − lagged", ///
        cond("`pair'" == "1 4", "Contemporaneous − one-sided HP", cond("`pair'" == "3 2", "Lagged − Hamilton", ///
        cond("`pair'" == "1 5", "Contemporaneous − two-sided HP", "Lagged − lagged over Hamilton trend")))))
    post `D' ("`nm'") (`d') (CI[1, 1]) (CI[1, 2]) (`pb')
    rv_kv dif_`a'`c'_d `=string(`d', "%9.4f")'
    rv_kv dif_`a'`c'_p `=string(`pb', "%9.4f")'
    rv_kv dif_`a'`c'_lo `=string(CI[1, 1], "%9.4f")'
    rv_kv dif_`a'`c'_hi `=string(CI[1, 2], "%9.4f")'
}
postclose `D'
restore

* =====================================================================================
* 4.2.6 defasagens distribuidas (1 a 5): em % do PIB e sobre o PIB tendencial (Hamilton)
* =====================================================================================
tempname L
postfile `L' str8 ser str12 term double(b se p pboot lo hi) long(N nc) using "$RINT/vies_dl.dta", replace
foreach ser in wbL whL {
    gen byte sDL_`ser' = !missing(g, `ser'1, `ser'2, `ser'3, `ser'4, `ser'5, g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
    xtscc g `ser'1-`ser'5 $XA i.year if sDL_`ser', fe lag($DKLAG)
    estimates store DL_`ser'
    local N = e(N)
    local nc = e(N_g)
    local df = e(df_r)
    forvalues k = 1/5 {
        post `L' ("`ser'") ("lag`k'") (_b[`ser'`k']) (_se[`ser'`k']) (2 * ttail(`df', abs(_b[`ser'`k'] / _se[`ser'`k']))) (.) (.) (.) (`N') (`nc')
    }
    lincom `ser'1 + `ser'2 + `ser'3 + `ser'4 + `ser'5
    local sb = r(estimate)
    local ss = r(se)
    local sp = r(p)
    local slo = r(lb)
    local shi = r(ub)
    * mesmo modelo com efeitos fixos e erros agrupados por pais, para o wild bootstrap da soma
    reghdfe g `ser'1-`ser'5 $XA i.year if sDL_`ser', absorb(id) vce(cluster id)
    lincom `ser'1 + `ser'2 + `ser'3 + `ser'4 + `ser'5
    local cb = r(estimate)
    boottest {`ser'1 + `ser'2 + `ser'3 + `ser'4 + `ser'5 = 0}, reps(9999) weighttype(webb) seed(20261017) nograph
    local pb = r(p)
    matrix CI = r(CI)
    post `L' ("`ser'") ("sum_dk") (`sb') (`ss') (`sp') (.) (`slo') (`shi') (`N') (`nc')
    post `L' ("`ser'") ("sum_boot") (`cb') (.) (.) (`pb') (CI[1, 1]) (CI[1, 2]) (`N') (`nc')
    rv_kv dl_`ser'_sum `=string(`sb', "%9.4f")'
    rv_kv dl_`ser'_sum_se `=string(`ss', "%9.4f")'
    rv_kv dl_`ser'_sum_p `=string(`sp', "%9.4f")'
    rv_kv dl_`ser'_sum_lo `=string(`slo', "%9.4f")'
    rv_kv dl_`ser'_sum_hi `=string(`shi', "%9.4f")'
    rv_kv dl_`ser'_sum_pboot `=string(`pb', "%9.4f")'
    rv_kv dl_`ser'_sum_bootlo `=string(CI[1, 1], "%9.4f")'
    rv_kv dl_`ser'_sum_boothi `=string(CI[1, 2], "%9.4f")'
    rv_kv dl_`ser'_N `N'
}

* EXPLORATORIO (posterior ao plano): a soma das defasagens 1 a 5 e instavel porque as defasagens e as razoes com
* denominadores diferentes sao quase colineares (correlacao 0,98-0,998). Diagnostico: media da folha de t-5 a t-1
* como regressor unico, em % do PIB e sobre o PIB tendencial (Hamilton), na amostra comum das duas series.
gen byte sDLc = sDL_wbL & sDL_whL
egen wbLm = rowmean(wbL1-wbL5)
egen whLm = rowmean(whL1-whL5)
foreach v in wbLm whLm {
    xtscc g `v' $XA i.year if sDLc, fe lag($DKLAG)
    estimates store EXP_`v'
    rv_kv expl_`v'_b `=string(_b[`v'], "%9.4f")'
    rv_kv expl_`v'_se `=string(_se[`v'], "%9.4f")'
    rv_kv expl_`v'_p `=string(2 * ttail(e(df_r), abs(_b[`v'] / _se[`v'])), "%9.4f")'
    rv_kv expl_`v'_N `e(N)'
    post `L' ("`v'") ("avg1to5") (_b[`v']) (_se[`v']) (2 * ttail(e(df_r), abs(_b[`v'] / _se[`v']))) (.) (.) (.) (e(N)) (e(N_g))
}
corr wbL1 whL1 wbL5 if sDLc
rv_kv corr_dl `=string(r(C)[1, 2], "%5.3f")'

* =====================================================================================
* 4.2.9 rigidez da folha: elasticidade da folha nominal ao PIB nominal
* =====================================================================================
xtset id year
gen double lW = ln(wagebill_gdp / 100 * gdp_nom_lcu)
gen double lYn = ln(gdp_nom_lcu)
gen dlW = 100 * D.lW
gen dlYn = 100 * D.lYn
xtscc dlW dlYn i.year if !missing(dlW, dlYn) & abs(dlW) < 200 & abs(dlYn) < 200, fe lag($DKLAG)
estimates store RIG
rv_kv rig_b `=string(_b[dlYn], "%9.4f")'
rv_kv rig_se `=string(_se[dlYn], "%9.4f")'
rv_kv rig_N `e(N)'
postclose `L'

* =====================================================================================
* 4.2.7 e 4.2.8 projecoes locais: nivel predeterminado (sobre Hamilton) e choque com leads (h = -3 ... 6)
* =====================================================================================
use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1985, 2023)
xtset id year
tempname Q
postfile `Q' str10 shock int h double(b se lo hi) long(N nc) using "$RINT/vies_lp.dta", replace
forvalues hh = -3/6 {
    if `hh' < 0 local lhs "L`=-`hh''.y100 - L.y100"
    else local lhs "F`hh'.y100 - L.y100"
    if `hh' == -1 continue
    tempvar dy
    gen double `dy' = `lhs'
    * choque real da folha (WageShock) com duas defasagens do choque e do crescimento
    quietly xtscc `dy' d_wagebill_real L(1/2).d_wagebill_real L(1/2).g i.year if inrange(year, 1996, 2023), fe lag($DKLAG)
    local df = e(df_r)
    post `Q' ("shock") (`hh') (_b[d_wagebill_real]) (_se[d_wagebill_real]) (_b[d_wagebill_real] - invttail(`df', 0.025) * _se[d_wagebill_real]) ///
        (_b[d_wagebill_real] + invttail(`df', 0.025) * _se[d_wagebill_real]) (e(N)) (e(N_g))
    * nivel da folha em t - 1 sobre o PIB tendencial (Hamilton)
    if `hh' >= 0 {
        quietly xtscc `dy' L.wb_ham L(1/2).g i.year if inrange(year, 1996, 2023), fe lag($DKLAG)
        local df = e(df_r)
        post `Q' ("level") (`hh') (_b[L.wb_ham]) (_se[L.wb_ham]) (_b[L.wb_ham] - invttail(`df', 0.025) * _se[L.wb_ham]) ///
            (_b[L.wb_ham] + invttail(`df', 0.025) * _se[L.wb_ham]) (e(N)) (e(N_g))
    }
    drop `dy'
}
* h = -1 e identicamente zero (y_{t-1} - y_{t-1}); registrado como referencia
post `Q' ("shock") (-1) (0) (0) (0) (0) (.) (.)
postclose `Q'

* =====================================================================================
* 4.2.8 antecipacao no painel de cinco anos (controles predeterminados de T3)
* =====================================================================================
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
global XP "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"
tempname E
postfile `E' str20 m double(b se p pboot) long(N nc) using "$RINT/vies_leads.dta", replace
foreach v in wb_tp_lead wb_m1_lead {
    reghdfe g `v' $XP i.period, absorb(id) vce(cluster id)
    estimates store LEAD_`v'
    local b = _b[`v']
    local se = _se[`v']
    local p = 2 * ttail(e(df_r), abs(`b' / `se'))
    rv_boot `v'
    post `E' ("`v'") (`b') (`se') (`p') (r(p)) (e(N)) (e(N_clust))
    rv_kv lead_`v'_b `=string(`b', "%9.4f")'
    rv_kv lead_`v'_p `=string(`p', "%9.4f")'
    rv_kv lead_`v'_pboot `=string(r(p), "%9.4f")'
}
* rebote no painel de cinco anos: folha em t_p - 1 sobre Hamilton com controles predeterminados (= T5)
postclose `E'

* =====================================================================================
* Tabelas
* =====================================================================================
* Tabela 1 (texto principal): medidas da folha, com N por linha e diferencas testadas
use "$RINT/vies_medidas.dta", clear
list, noobs sep(0)
rv_new, ncol(5) head1("Coefficient" "SE" "95% CI" "Obs." "Countries")
local ordA "wb wb_hp2 wb_hp1 wb_ham wb_l1 wbham_l1"
foreach v of local ordA {
    quietly levelsof lab if m == "`v'", local(lb) clean
    quietly summ b if m == "`v'"
    local b = r(mean)
    quietly summ p if m == "`v'"
    rv_fmt `b' %12.3f `=r(mean)'
    local cb "`r(s)'"
    quietly summ se if m == "`v'"
    rv_fmt `=r(mean)' %12.3f
    local cs "`r(s)'"
    quietly summ lo if m == "`v'"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if m == "`v'"
    rv_fmt `=r(mean)' %12.3f
    local hh "`r(s)'"
    quietly summ N if m == "`v'"
    rv_fmt `=r(mean)' %12.0fc
    local n "`r(s)'"
    quietly summ nc if m == "`v'"
    rv_row "Annual: `lb'" "`cb'" "(`cs')" "[`l'; `hh']" "`n'" "`=r(mean)'"
}
rv_mid
foreach v in wb_mean wb_tp wb_m1 wb_ham_m1 {
    quietly levelsof lab if m == "`v'", local(lb) clean
    quietly summ b if m == "`v'"
    local b = r(mean)
    quietly summ p if m == "`v'"
    rv_fmt `b' %12.3f `=r(mean)'
    local cb "`r(s)'"
    quietly summ se if m == "`v'"
    rv_fmt `=r(mean)' %12.3f
    local cs "`r(s)'"
    quietly summ lo if m == "`v'"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if m == "`v'"
    rv_fmt `=r(mean)' %12.3f
    local hh "`r(s)'"
    quietly summ N if m == "`v'"
    local n = r(mean)
    quietly summ nc if m == "`v'"
    rv_row "`lb'" "`cb'" "(`cs')" "[`l'; `hh']" "`n'" "`=r(mean)'"
}
rv_mid
use "$RINT/vies_diferencas.dta", clear
rv_row "Tested differences (annual, stacked model)" "Difference" "" "95% CI (bootstrap)" "Bootstrap p" ""
forvalues i = 1/`=_N' {
    rv_fmt `=d[`i']' %12.3f
    local dd "`r(s)'"
    rv_fmt `=lo[`i']' %12.3f
    local l "`r(s)'"
    rv_fmt `=hi[`i']' %12.3f
    local hh "`r(s)'"
    rv_fmt `=p[`i']' %12.3f
    rv_row "`=dif[`i']'" "`dd'" "" "[`l'; `hh']" "`r(s)'" ""
}
rv_out Tab1_measures, ///
    title("Table 1. The wage bill coefficient under different measures of the wage bill") ///
    notes("Dependent variable: growth of real GDP per capita (%). Annual rows: panel 1996–2023, same sample in all rows (country-years with every measure), country and year fixed effects, lagged growth, lagged log GDP per capita, human capital, investment, openness, inflation, population growth and commodity terms-of-trade growth; Driscoll-Kraay standard errors (maximum lag 3), confidence intervals from the t distribution with T − 1 degrees of freedom. Trend GDP is the trend of log real GDP: Hamilton filter (H = 2, k = 2, predetermined), one-sided HP filter (lambda = 6.25, recursive, uses only data up to t) and two-sided HP filter (lambda = 6.25, uses future data; reported for comparison only). Five-year rows: non-overlapping averages 1979–2023, same sample in all rows, country and period fixed effects, controls of the draft-7 baseline (log GDP per capita in t_p − 1, human capital in t_p and period means of investment, openness, inflation, population growth and commodity terms-of-trade growth), standard errors clustered by country. Tested differences: the six annual measures are stacked and estimated jointly with measure-specific controls and fixed effects (country × measure and year × measure); differences tested by wild cluster bootstrap clustered by country (Webb weights, 9,999 replications). The lagged measure and the Hamilton measure are not independent evidence: both use only information up to t − 1 or t − 2 (correlation between them in the annual sample: `corrlh'). Microstates excluded. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela suplementar: decomposicao do vies
* =====================================================================================
capture program drop rowm
program define rowm
    * rowm "rotulo" codigo  (le de vies_medidas.dta na memoria)
    args lab code
    quietly summ b if m == "`code'"
    local b = r(mean)
    quietly summ p if m == "`code'"
    rv_fmt `b' %12.3f `=r(mean)'
    local cb "`r(s)'"
    quietly summ se if m == "`code'"
    rv_fmt `=r(mean)' %12.3f
    local cs "`r(s)'"
    quietly summ N if m == "`code'"
    rv_fmt `=r(mean)' %12.0fc
    local n "`r(s)'"
    quietly summ nc if m == "`code'"
    rv_row "`lab'" "`cb'" "(`cs')" "`n'" "`=r(mean)'"
end
use "$RINT/vies_medidas.dta", clear
rv_new, ncol(4) head1("Coefficient" "SE" "Obs." "Countries")
rv_row "A. Annual panel, same sample" "" "" "" ""
rowm "Contemporaneous ratio W/Y (reference)" wb
rowm "Placebo ratio: lagged real wage bill grown at trend, over current GDP" wb_placebo
rowm "Multiplicative decomposition: log(W/Y*), Hamilton" dec_lwb
rowm "Multiplicative decomposition: log(Y*/Y), Hamilton" dec_gap
rowm "W/Y*, one-sided HP trend" wb_hp1
rowm "W/Y, excluding recession years" norec
rv_mid
rv_row "B. Rebound" "" "" "" ""
rowm "Annual: wage bill lagged one year, % of GDP" wb_l1
rowm "Annual: wage bill lagged one year, % of trend GDP (Hamilton)" wbham_l1
rowm "5-year: wage bill in t_p − 1, % of GDP" wb_m1
rowm "5-year: wage bill in t_p − 1, % of trend GDP (Hamilton)" wb_ham_m1
rv_mid
rv_row "C. Rigidity of the wage bill" "" "" "" ""
rv_estrow "Elasticity of the nominal wage bill to nominal GDP", models(RIG) vars(dlYn)
rv_stat "Observations", models(RIG) stat(N)
rv_out TabS_bias_decomposition, ///
    title("Table S3. Decomposition of the contemporaneous-ratio bias") ///
    notes("Dependent variable in panels A and B: growth of real GDP per capita (%). Panel A: annual panel 1996–2023 with country and year fixed effects, lagged growth, lagged log GDP per capita, human capital, investment, openness, inflation, population growth and commodity terms-of-trade growth; Driscoll-Kraay standard errors (maximum lag 3); same sample as the annual rows of Table 1, except the last row, which drops years with negative GDP per capita growth. The placebo numerator is the previous year's real wage bill grown at the country's average real growth of the wage bill, so the ratio varies with current GDP only through the denominator; its coefficient is the bias produced by the denominator alone. Y* is trend real GDP from the Hamilton filter (H = 2, k = 2); the two decomposition terms enter jointly and are in log units. Panel B: the rebound argument predicts a more negative coefficient when the lagged wage bill is divided by trend instead of actual GDP. Five-year rows: country and period fixed effects, draft-7 controls, standard errors clustered by country, common sample of the four five-year measures of Table 1. Panel C: annual log changes (×100) of the nominal wage bill on nominal GDP, country and year fixed effects, Driscoll-Kraay standard errors; observations with absolute changes above 200 excluded. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela suplementar: defasagens distribuidas e leads
* =====================================================================================
use "$RINT/vies_dl.dta", clear
rv_new, ncol(2) head1("Wage bill, % of GDP" "Wage bill, % of trend GDP (Hamilton)")
forvalues k = 1/5 {
    local cells ""
    local cses ""
    foreach ser in wbL whL {
        quietly summ b if ser == "`ser'" & term == "lag`k'"
        local b = r(mean)
        quietly summ p if ser == "`ser'" & term == "lag`k'"
        rv_fmt `b' %12.3f `=r(mean)'
        local cells `"`cells' "`r(s)'""'
        quietly summ se if ser == "`ser'" & term == "lag`k'"
        rv_fmt `=r(mean)' %12.3f
        local cses `"`cses' "(`r(s)')""'
    }
    rv_row "Lag `k'" `cells'
    rv_row "" `cses'
}
rv_mid
local c1 ""
local c2 ""
local c3 ""
local c4 ""
foreach ser in wbL whL {
    quietly summ b if ser == "`ser'" & term == "sum_dk"
    local b = r(mean)
    quietly summ p if ser == "`ser'" & term == "sum_dk"
    rv_fmt `b' %12.3f `=r(mean)'
    local c1 `"`c1' "`r(s)'""'
    quietly summ lo if ser == "`ser'" & term == "sum_dk"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if ser == "`ser'" & term == "sum_dk"
    rv_fmt `=r(mean)' %12.3f
    local c2 `"`c2' "[`l'; `r(s)']""'
    quietly summ pboot if ser == "`ser'" & term == "sum_boot"
    rv_fmt `=r(mean)' %12.3f
    local c3 `"`c3' "`r(s)'""'
    quietly summ lo if ser == "`ser'" & term == "sum_boot"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if ser == "`ser'" & term == "sum_boot"
    rv_fmt `=r(mean)' %12.3f
    local c4 `"`c4' "[`l'; `r(s)']""'
}
rv_row "Sum of lags 1–5 (Driscoll-Kraay, delta method)" `c1'
rv_row "95% CI" `c2'
rv_row "Sum of lags 1–5: wild cluster bootstrap p-value" `c3'
rv_row "95% CI (wild cluster bootstrap)" `c4'
local c1 ""
local c2 ""
foreach v in wbLm whLm {
    quietly summ b if ser == "`v'"
    local b = r(mean)
    quietly summ p if ser == "`v'"
    rv_fmt `b' %12.3f `=r(mean)'
    local c1 `"`c1' "`r(s)'""'
    quietly summ se if ser == "`v'"
    rv_fmt `=r(mean)' %12.3f
    local c2 `"`c2' "(`r(s)')""'
}
rv_mid
rv_row "Exploratory: average of lags 1–5 as a single regressor" `c1'
rv_row "" `c2'
quietly summ N if term == "lag1" & ser == "wbL"
local n1 = r(mean)
quietly summ N if term == "lag1" & ser == "whL"
local n2 = r(mean)
rv_row "Observations (lags model)" "`=string(`n1', "%9.0fc")'" "`=string(`n2', "%9.0fc")'"
rv_mid
use "$RINT/vies_leads.dta", clear
rv_row "Five-year leads (predetermined controls)" "Coefficient (SE)" "Bootstrap p"
forvalues i = 1/`=_N' {
    rv_fmt `=b[`i']' %12.3f `=p[`i']'
    local bb "`r(s)'"
    rv_fmt `=se[`i']' %12.3f
    local ss "`r(s)'"
    rv_fmt `=pboot[`i']' %12.3f
    local pp "`r(s)'"
    local lab = cond(m[`i'] == "wb_tp_lead", "Growth in p on the wage bill in t_(p+1)", "Growth in p on the wage bill in t_(p+1) − 1")
    rv_row "`lab'" "`bb' (`ss')" "`pp'"
}
rv_out TabS_lags_leads, landscape ///
    title("Table S4. Distributed lags of the wage bill (annual panel) and leads (five-year panel)") ///
    notes("Upper panel: annual panel 1996–2023, growth of real GDP per capita on the wage bill lagged one to five years, entered jointly, with country and year fixed effects and the controls of Table 1; coefficients and the sum with Driscoll-Kraay standard errors (maximum lag 3) and delta-method confidence intervals; the sum is also tested by wild cluster bootstrap by country (Webb weights, 9,999 replications) in the same model with standard errors clustered by country. The five lags are almost collinear (correlation above 0.98 between the first and the fifth lag and between the two denominators), so individual coefficients and their sum are imprecise and sensitive to the denominator. The exploratory row, added after the analysis plan, replaces the five lags by their average as a single regressor (common sample of both series). Lower panel: five-year averages, country and period fixed effects, predetermined controls of Table 2, standard errors clustered by country; the first row is equivalent to regressing growth in p − 1 on the wage bill in t_p; a non-zero coefficient would indicate anticipation (growth predicting the future wage bill). * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Figura 2: medidas da folha (anual e cinco anos)
* =====================================================================================
use "$RINT/vies_medidas.dta", clear
keep if inlist(m, "wb", "wb_hp2", "wb_hp1", "wb_ham", "wb_l1", "wbham_l1") | inlist(m, "wb_mean", "wb_tp", "wb_m1", "wb_ham_m1")
gen ord = .
local i = 0
foreach v in wb wb_hp2 wb_hp1 wb_ham wb_l1 wbham_l1 wb_mean wb_tp wb_m1 wb_ham_m1 {
    local ++i
    replace ord = 11 - `i' if m == "`v'"
}
gen byte annual = ord > 4
twoway (rcap lo hi ord, horizontal lcolor(black) lwidth(medthin)) ///
       (scatter ord b if annual, msymbol(O) mcolor(black) msize(small)) ///
       (scatter ord b if !annual, msymbol(Dh) mcolor(black) msize(small)), ///
       $GOPT xline(0, lcolor(gs10) lpattern(shortdash)) yline(4.5, lcolor(gs12) lpattern(solid)) ///
       ylabel(10 "Annual: contemporaneous ratio" 9 "Annual: % of trend GDP, two-sided HP" 8 "Annual: % of trend GDP, one-sided HP" ///
              7 "Annual: % of trend GDP, Hamilton" 6 "Annual: lagged one year" 5 "Annual: lagged, % of trend GDP (Hamilton)" ///
              4 "5-year: period mean" 3 "5-year: t{sub:p}" 2 "5-year: t{sub:p} − 1" 1 "5-year: t{sub:p} − 1, % of trend GDP", angle(0) labsize(7.5pt) nogrid) ///
       xlabel(-1(0.2)0.4, format(%3.1f) labsize(8pt)) ytitle("") yscale(range(0.5 10.5)) ///
       legend(order(2 "Annual panel" 3 "Five-year panel") rows(1) pos(6) size(8pt)) ///
       xtitle("Coefficient on the wage bill (p.p. of growth per p.p. of GDP), 95% CI", size(8pt))
rv_fig Fig2_measures, width(190) height(110)

* =====================================================================================
* Figura 7: projecoes locais -- choque com leads e nivel predeterminado
* =====================================================================================
use "$RINT/vies_lp.dta", clear
sort shock h
twoway (rarea lo hi h if shock == "shock", fcolor(gs14) lcolor(gs8) lpattern(dash) lwidth(vthin)) ///
       (connected b h if shock == "shock", lcolor(black) mcolor(black) msymbol(O) msize(small)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(shortdash)) xline(-0.5, lcolor(gs12)) xlabel(-3(1)6, labsize(8pt)) ///
       ylabel(, format(%3.1f) labsize(8pt) nogrid angle(horizontal)) legend(off) ///
       xtitle("Years relative to the shock", size(8pt)) ytitle("Cumulative response of GDP per capita (100 × log, %)", size(7.5pt)) ///
       title("(a) Real wage bill shock, with leads", size(8.5pt) color(black) pos(11)) name(fa, replace) nodraw
twoway (rarea lo hi h if shock == "level", fcolor(gs14) lcolor(gs8) lpattern(dash) lwidth(vthin)) ///
       (connected b h if shock == "level", lcolor(black) mcolor(black) msymbol(D) msize(small)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(shortdash)) xlabel(0(1)6, labsize(8pt)) ///
       ylabel(, format(%3.1f) labsize(8pt) nogrid angle(horizontal)) legend(off) ///
       xtitle("Years after t − 1", size(8pt)) ytitle("Cumulative response of GDP per capita (100 × log, %)", size(7.5pt)) ///
       title("(b) Predetermined wage bill level (t − 1, % of trend GDP)", size(8.5pt) color(black) pos(11)) name(fb, replace) nodraw
graph combine fa fb, cols(2) graphregion(color(white)) imargin(small)
rv_fig Fig7_lp_level_leads, width(190) height(85)

log close
