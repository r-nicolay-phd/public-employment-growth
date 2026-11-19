* 02_outras_razoes.do -- Bloco 2: o argumento vale para outras razoes de gasto? Condicao de sinal da equacao (1)
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/02_outras_razoes.log", replace text

* investimento publico bruto (IMF ICSD, P51G_S13, % do PIB)
import delimited "$RAW/imf_icsd/icsd.csv", clear varnames(1) case(lower)
keep if indicator == "P51G_S13_Q_POGDP_PT"
rename (country time_period obs_value) (iso3 year pinv)
keep iso3 year pinv
destring year pinv, replace force
duplicates drop iso3 year, force
tempfile icsd
save `icsd'

use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
merge 1:1 iso3 year using `icsd', keep(master match) nogen
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen x_wb = wb
gen x_cons = govcons_gdp
gen x_exp = exp_gdp
gen x_transf = sh_transf * exp_gdp / 100
gen x_pinv = pinv
foreach it in wb cons exp transf pinv {
    replace x_`it' = . if x_`it' <= 0
    * real do item deflacionado pelo deflator do PIB: (x / 100) x PIB real
    gen double r_`it' = x_`it' / 100 * gdp_real
    gen double dl_`it' = ln(r_`it') - ln(L.r_`it')
    bysort id: egen double gs_`it' = mean(dl_`it')
    xtset id year
    gen m1_`it' = x_`it'
    gen m2_`it' = L.x_`it' * (L.gdp_real / gdp_real) * exp(gs_`it')
    gen m3_`it' = x_`it' * exp(lnY - lnY_ham)
    gen m4_`it' = x_`it' * exp(lnY - lnY_hp1)
    gen m5_`it' = L.x_`it'
    * elasticidades: nominal-nominal e real-real (100 x dlog), como no painel C da Tabela S3
    gen dlXn_`it' = 100 * (ln(x_`it' / 100 * gdp_nom_lcu) - ln(L.x_`it' / 100 * L.gdp_nom_lcu))
    gen dlXr_`it' = 100 * dl_`it'
}
gen dlYn = 100 * (ln(gdp_nom_lcu) - ln(L.gdp_nom_lcu))
gen dlYr = 100 * (lnY - L.lnY)
keep if inrange(year, 1996, 2023)

tempname P
postfile `P' str8 item str4 meas double(b se p lo hi) long(N nc) using "$RINT/razoes_res.dta", replace
foreach it in wb cons exp transf pinv {
    gen byte s_`it' = !missing(g, m1_`it', m2_`it', m3_`it', m4_`it', m5_`it', g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
    forvalues k = 1/5 {
        quietly xtscc g m`k'_`it' $XA i.year if s_`it', fe lag($DKLAG)
        local b = _b[m`k'_`it']
        local se = _se[m`k'_`it']
        local df = e(df_r)
        post `P' ("`it'") ("m`k'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
            (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_g))
    }
    * elasticidades
    foreach t in n r {
        local yv = cond("`t'" == "n", "dlYn", "dlYr")
        quietly xtscc dlX`t'_`it' `yv' i.year if !missing(dlX`t'_`it', `yv') & abs(dlX`t'_`it') < 200 & abs(`yv') < 200, fe lag($DKLAG)
        local b = _b[`yv']
        local se = _se[`yv']
        local df = e(df_r)
        post `P' ("`it'") ("e`t'") (`b') (`se') (2 * ttail(`df', abs((`b' - 1) / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
            (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_g))
    }
    * vies = mesmo ano - defasada, modelo empilhado, wild cluster bootstrap
    preserve
    keep if s_`it'
    keep id year g m1_`it' m5_`it' g_l1 lny_l1 hc inv open infl popg ctot_g
    gen long obs = _n
    expand 2
    bysort obs: gen byte m = _n
    gen double x1 = m1_`it' * (m == 1)
    gen double x2 = m5_`it' * (m == 2)
    egen idm = group(id m)
    quietly reghdfe g x1 x2 c.(g_l1 lny_l1 hc inv open infl popg ctot_g)#i.m i.year#i.m, absorb(idm) vce(cluster id)
    lincom x1 - x2
    local d = r(estimate)
    kboot {x1 - x2 = 0}
    post `P' ("`it'") ("bias") (`d') (.) (r(p)) (r(lo)) (r(hi)) (e(N)) (.)
    restore
}
postclose `P'

* =====================================================================================
* condicao de sinal (adendo, Bloco 2) e Tabela S20
* =====================================================================================
use "$RINT/razoes_res.dta", clear
list, noobs sepby(item)
kcsv "$RINT/razoes_res.dta" TabS20_spending_items
local nconf = 0
foreach it in cons exp transf pinv wb {
    quietly summ lo if item == "`it'" & meas == "en"
    local elo = r(mean)
    quietly summ hi if item == "`it'" & meas == "en"
    local ehi = r(mean)
    quietly summ lo if item == "`it'" & meas == "bias"
    local blo = r(mean)
    quietly summ hi if item == "`it'" & meas == "bias"
    local bhi = r(mean)
    local pred = cond(`ehi' < 1, "negative", cond(`elo' > 1, "positive", "zero"))
    if "`pred'" == "negative" local ok = (`bhi' < 0)
    if "`pred'" == "positive" local ok = (`blo' > 0)
    if "`pred'" == "zero" local ok = (`blo' <= 0 & `bhi' >= 0)
    local pred_`it' "`pred'"
    local ok_`it' = `ok'
    if "`it'" != "wb" local nconf = `nconf' + `ok'
    rv_kv sign_`it'_pred `pred'
    rv_kv sign_`it'_ok `ok'
    di "`it': previsto `pred'; confirmado `ok'"
}
rv_kv sign_nconf `nconf'
local scope = cond(`nconf' >= 3, 1, 0)
rv_kv sign_scope `scope'
di "Bloco 2: condicao de sinal confirmada em `nconf' de 4 itens"
local ttl = cond(`nconf' >= 3, "The sign of the same-year bias follows the elasticity of each spending item to GDP", ///
    cond(`nconf' == 0, "The sign of the same-year bias does not follow the elasticity of spending items to GDP", ///
    "The sign of the same-year bias follows the elasticity to GDP in `nconf' of four spending items"))

rv_new, ncol(5) head1("Wage bill (reference)" "Government consumption" "Total expenditure" "Social benefits" "Public investment")
foreach k in "m1 Same year" "m2 Placebo numerator (denominator only)" "m3 % of trend GDP (Hamilton)" "m4 % of trend GDP (one-sided HP)" "m5 Lagged one year" {
    gettoken m lab : k
    local cb ""
    local cs ""
    foreach it in wb cons exp transf pinv {
        quietly summ b if item == "`it'" & meas == "`m'"
        local b = r(mean)
        quietly summ p if item == "`it'" & meas == "`m'"
        rv_fmt `b' %12.3f `=r(mean)'
        local cb `"`cb' "`r(s)'""'
        quietly summ lo if item == "`it'" & meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local l "`r(s)'"
        quietly summ hi if item == "`it'" & meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local cs `"`cs' "[`l'; `r(s)']""'
    }
    rv_row "`=strtrim("`lab'")'" `cb'
    rv_row "" `cs'
}
local cn ""
local cc ""
foreach it in wb cons exp transf pinv {
    quietly summ N if item == "`it'" & meas == "m1"
    rv_fmt `=r(mean)' %12.0fc
    local cn `"`cn' "`r(s)'""'
    quietly summ nc if item == "`it'" & meas == "m1"
    local cc `"`cc' "`=r(mean)'""'
}
rv_row "Observations" `cn'
rv_row "Countries" `cc'
rv_mid
foreach k in "bias Bias: same year − lagged (bootstrap 95% CI)" "en Elasticity to GDP, nominal (95% CI)" "er Elasticity to GDP, real (95% CI)" {
    gettoken m lab : k
    local cb ""
    foreach it in wb cons exp transf pinv {
        quietly summ b if item == "`it'" & meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local x "`r(s)'"
        quietly summ lo if item == "`it'" & meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local l "`r(s)'"
        quietly summ hi if item == "`it'" & meas == "`m'"
        rv_fmt `=r(mean)' %12.3f
        local cb `"`cb' "`x' [`l'; `r(s)']""'
    }
    rv_row "`=strtrim("`lab'")'" `cb'
}
rv_row "Predicted sign of the bias (from the nominal elasticity)" "`pred_wb'" "`pred_cons'" "`pred_exp'" "`pred_transf'" "`pred_pinv'"
rv_row "Sign condition confirmed" "`=cond(`ok_wb', "Yes", "No")'" "`=cond(`ok_cons', "Yes", "No")'" "`=cond(`ok_exp', "Yes", "No")'" "`=cond(`ok_transf', "Yes", "No")'" "`=cond(`ok_pinv', "Yes", "No")'"
rv_out TabS20_spending_items, landscape ///
    title("Table S20. `ttl'") ///
    notes("Annual panel 1996–2023, no microstates; growth of real GDP per capita on each measure of the spending item, with the controls of Table 1 (lagged growth, lagged log GDP per capita, human capital, investment, openness, inflation, population growth, terms-of-trade growth), country and year fixed effects, Driscoll-Kraay standard errors (maximum lag 3), 95% CI in brackets; stars from the same standard errors. Each column uses one sample, common to its five measures. Items: general government wage bill (IMF GFS; reference, as in Table 1); general government final consumption (WDI); total general government expenditure (IMF GFS); social benefits and transfers (GFS share of expense × total expenditure); gross public investment (IMF Investment and Capital Stock Dataset, general government). Placebo: lagged ratio × (lagged real GDP / current real GDP) × exp(country mean real growth of the item, deflated by the GDP deflator). Bias: same-year minus lagged coefficient, in a stacked model with country × measure fixed effects, wild cluster bootstrap by country (Webb weights, 9,999 replications) with bootstrap 95% CI. Elasticity: 100 × Δlog of the item on 100 × Δlog of GDP (nominal; real deflated by the GDP deflator), country and year fixed effects, Driscoll-Kraay 95% CI. Predicted sign (equation 1): negative if the elasticity CI lies below one, positive if above, zero if it contains one; the condition is confirmed if the bias CI agrees (below zero, above zero or containing zero). Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")
log close
