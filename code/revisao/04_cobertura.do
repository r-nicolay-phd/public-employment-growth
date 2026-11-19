* 04_cobertura.do -- bloco 4.3 do plano: governo geral x governo central na mesma amostra [P9]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/revisao/00_setup.do"
capture log close
log using "$RLOG/04_cobertura.log", replace text

global XP "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"

* ---------------------------------------------------------------- contagens de federacoes (definicao unica: Forum of Federations)
use "$RINT/anual_rv.dta", clear
keep if micro == 0
egen tagf = tag(id) if federal == 1
count if tagf == 1
rv_kv fed_list `r(N)'
* federacoes com as duas series (geral e central) em 2010-2019
preserve
keep if inrange(year, 2010, 2019) & !missing(wagebill_gdp, wagebill_cg_wdi) & wagebill_cg_wdi > 0
collapse (mean) gg = wagebill_gdp cg = wagebill_cg_wdi (firstnm) federal iso3 country, by(id)
gen ratio = gg / cg
count if federal == 1
rv_kv fed_both_2010s `r(N)'
quietly summ ratio if federal == 1, detail
rv_kv ratio_fed_med `=string(r(p50), "%4.2f")'
quietly summ ratio if federal == 0, detail
rv_kv ratio_uni_med `=string(r(p50), "%4.2f")'
count if federal == 0
rv_kv uni_both_2010s `r(N)'
gsort -federal -ratio
save "$RINT/razao_gg_cg.dta", replace
restore

* ---------------------------------------------------------------- amostra comum (cinco anos, T3)
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen cg_m1 = wagebill_cg_wdi_m1
gen byte S5_common_GC = !missing(g, wb_m1, cg_m1, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
* federacoes na amostra de base do draft 7 e na amostra comum
merge 1:1 id period using "$RINT/amostras5.dta", keep(master match) nogen keepusing(S5_base)
egen tb = tag(id) if S5_base == 1 & federal == 1
count if tb == 1
rv_kv fed_base `r(N)'
egen tcom = tag(id) if S5_common_GC & federal == 1
count if tcom == 1
rv_kv fed_common_raw `r(N)'

tempname P
postfile `P' str8 grp str4 meas double(b se p) long(N nc nfed) using "$RINT/cobertura.dta", replace
foreach grp in all fed uni {
    local c = cond("`grp'" == "all", "1", cond("`grp'" == "fed", "federal == 1", "federal == 0"))
    foreach meas in gg cg {
        local w = cond("`meas'" == "gg", "wb_m1", "cg_m1")
        reghdfe g `w' $XP i.period if S5_common_GC & `c', absorb(id) vce(cluster id)
        estimates store C_`grp'_`meas'
        local b = _b[`w']
        local se = _se[`w']
        local p = 2 * ttail(e(df_r), abs(`b' / `se'))
        tempvar tg
        egen `tg' = tag(id) if e(sample) & federal == 1
        quietly count if `tg' == 1
        post `P' ("`grp'") ("`meas'") (`b') (`se') (`p') (e(N)) (e(N_clust)) (r(N))
        rv_kv cov_`grp'_`meas'_b `=string(`b', "%12.8f")'
        rv_kv cov_`grp'_`meas'_p `=string(`p', "%9.4f")'
        rv_kv cov_`grp'_`meas'_N `e(N)'
        rv_kv cov_`grp'_`meas'_nc `e(N_clust)'
    }
}
* governo central na amostra propria (como no draft 7, mas com o timing de T3)
reghdfe g cg_m1 $XP i.period, absorb(id) vce(cluster id)
estimates store C_cgown
post `P' ("own") ("cg") (_b[cg_m1]) (_se[cg_m1]) (2 * ttail(e(df_r), abs(_b[cg_m1] / _se[cg_m1]))) (e(N)) (e(N_clust)) (.)
rv_kv cov_own_cg_b `=string(_b[cg_m1], "%9.4f")'
rv_kv cov_own_cg_N `e(N)'
rv_kv cov_own_cg_nc `e(N_clust)'
postclose `P'

* ---------------------------------------------------------------- igualdade dos coeficientes: bootstrap pareado por pais
capture program drop difgc
program define difgc, rclass
    * diferenca geral - central; efeitos fixos no identificador `fe' (id, ou bid nas reamostras)
    args fe
    quietly reghdfe g wb_m1 $XP i.period, absorb(`fe') vce(cluster `fe')
    local b1 = _b[wb_m1]
    quietly reghdfe g cg_m1 $XP i.period, absorb(`fe') vce(cluster `fe')
    return scalar d = `b1' - _b[cg_m1]
end
tempname B
postfile `B' str8 grp double(d p lo hi) using "$RINT/cobertura_boot.dta", replace
foreach grp in all fed uni {
    local c = cond("`grp'" == "all", "1", cond("`grp'" == "fed", "federal == 1", "federal == 0"))
    preserve
    keep if S5_common_GC & `c'
    tempfile sub
    save `sub'
    difgc id
    local d0 = r(d)
    tempname R
    tempfile rr
    postfile `R' double d using `rr', replace
    set seed 20261017
    forvalues r = 1/999 {
        quietly use `sub', clear
        bsample, cluster(id) idcluster(bid)
        capture difgc bid
        if !_rc post `R' (r(d))
    }
    postclose `R'
    use `rr', clear
    _pctile d, p(2.5 97.5)
    local lo = r(r1)
    local hi = r(r2)
    quietly summ d
    local pp = 2 * normal(-abs(`d0' / r(sd)))
    post `B' ("`grp'") (`d0') (`pp') (`lo') (`hi')
    rv_kv cov_diff_`grp' `=string(`d0', "%9.4f")'
    rv_kv cov_diff_`grp'_p `=string(`pp', "%9.4f")'
    rv_kv cov_diff_`grp'_reps `=_N'
    restore
}
postclose `B'

* ---------------------------------------------------------------- por que o coeficiente e mais fraco nas federacoes
* interacao folha x federacao (governo geral, amostra de T3)
gen wbxfed = wb_m1 * federal
reghdfe g wb_m1 wbxfed $XP i.period, absorb(id) vce(cluster id)
estimates store C_int
rv_kv cov_int_b `=string(_b[wbxfed], "%9.4f")'
rv_kv cov_int_p `=string(2 * ttail(e(df_r), abs(_b[wbxfed] / _se[wbxfed])), "%9.4f")'
* federacoes: excluir uma por vez (governo geral, so federacoes, amostra de T3)
quietly reghdfe g wb_m1 $XP i.period if federal == 1, absorb(id) vce(cluster id)
gen byte sF = e(sample)
rv_kv cov_fedT3_b `=string(_b[wb_m1], "%9.4f")'
rv_kv cov_fedT3_N `e(N)'
rv_kv cov_fedT3_nc `e(N_clust)'
tempname O
postfile `O' str3 iso3 double(b se) using "$RINT/cobertura_loo.dta", replace
levelsof iso3 if sF, local(fl)
foreach c of local fl {
    quietly reghdfe g wb_m1 $XP i.period if sF & iso3 != "`c'", absorb(id) vce(cluster id)
    post `O' ("`c'") (_b[wb_m1]) (_se[wb_m1])
}
postclose `O'
preserve
use "$RINT/cobertura_loo.dta", clear
summ b
rv_kv cov_loo_min `=string(r(min), "%9.4f")'
rv_kv cov_loo_max `=string(r(max), "%9.4f")'
sort b
list, noobs
restore

* =====================================================================================
* Tabela 4 (texto principal): cobertura na amostra comum
* =====================================================================================
use "$RINT/cobertura.dta", clear
rv_new, ncol(7) head1("All countries" "" "Federations" "" "Unitary countries" "" "Own sample") ///
    head2("General gov." "Central gov." "General gov." "Central gov." "General gov." "Central gov." "Central gov.")
local cb ""
local cs ""
local cn ""
local cc ""
local cf ""
foreach k in "all gg" "all cg" "fed gg" "fed cg" "uni gg" "uni cg" "own cg" {
    gettoken grp meas : k
    local meas = strtrim("`meas'")
    quietly summ b if grp == "`grp'" & meas == "`meas'"
    local b = r(mean)
    quietly summ p if grp == "`grp'" & meas == "`meas'"
    rv_fmt `b' %12.3f `=r(mean)'
    local cb `"`cb' "`r(s)'""'
    quietly summ se if grp == "`grp'" & meas == "`meas'"
    rv_fmt `=r(mean)' %12.3f
    local cs `"`cs' "(`r(s)')""'
    quietly summ N if grp == "`grp'" & meas == "`meas'"
    rv_fmt `=r(mean)' %12.0fc
    local cn `"`cn' "`r(s)'""'
    quietly summ nc if grp == "`grp'" & meas == "`meas'"
    rv_fmt `=r(mean)' %12.0fc
    local cc `"`cc' "`r(s)'""'
    quietly summ nfed if grp == "`grp'" & meas == "`meas'"
    rv_fmt `=r(mean)' %12.0fc
    local cf `"`cf' "`r(s)'""'
}
rv_row "Wage bill (% of GDP), t_p − 1" `cb'
rv_row "" `cs'
use "$RINT/cobertura_boot.dta", clear
local cd ""
foreach grp in all fed uni {
    quietly summ d if grp == "`grp'"
    local d = r(mean)
    quietly summ p if grp == "`grp'"
    rv_fmt `d' %12.3f `=r(mean)'
    local dd "`r(s)'"
    quietly summ lo if grp == "`grp'"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if grp == "`grp'"
    rv_fmt `=r(mean)' %12.3f
    local cd `"`cd' "`dd' [`l'; `r(s)']" """'
}
rv_row "Difference general − central [95% CI, pairs bootstrap]" `cd' ""
rv_mid
rv_row "Observations" `cn'
rv_row "Countries" `cc'
rv_row "Federations in the sample" `cf'
rv_row "Controls" "Predetermined" "Predetermined" "Predetermined" "Predetermined" "Predetermined" "Predetermined" "Predetermined"
rv_row "Country FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes"
rv_row "Period FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes"
rv_row "Standard errors" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster"
import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
foreach k in fed_list fed_both_2010s fed_base ratio_fed_med ratio_uni_med uni_both_2010s {
    quietly levelsof value if key == "`k'", local(`k') clean
    local `k' : word 1 of ``k''
}
rv_out Tab4_coverage, landscape ///
    title("Table 4. General versus central government wage bill on the same sample") ///
    notes("Dependent variable: growth of real GDP per capita (%, five-year average), 1979–2023. Columns 1–6 use the same country-periods for both measures (country-periods with the general government wage bill, IMF GFS, and the central government wage bill, WDI, both in t_p − 1, and the predetermined controls of Table 2); column 7 uses every country-period with the central government series. Federations follow a single definition, the Forum of Federations list (`fed_list' countries in the data); `fed_both_2010s' federations have both series in 2010–2019, when the median ratio of the general to the central government wage bill is `ratio_fed_med' in federations and `ratio_uni_med' in unitary countries (`uni_both_2010s' unitary countries); `fed_base' federations are in the conventional-specification sample. Country and period fixed effects; standard errors clustered by country. The difference between the general and the central government coefficients is estimated on 999 pairs-bootstrap samples drawn by country, with both equations re-estimated on each sample; percentile confidence interval and normal-approximation p-value. Microstates excluded. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela suplementar: razao geral/central por pais e federacoes
* =====================================================================================
use "$RINT/razao_gg_cg.dta", clear
rv_new, ncol(4) head1("Federal" "General gov. (% of GDP)" "Central gov. (% of GDP)" "Ratio")
forvalues i = 1/`=_N' {
    rv_fmt `=gg[`i']' %12.2f
    local a "`r(s)'"
    rv_fmt `=cg[`i']' %12.2f
    local c "`r(s)'"
    rv_fmt `=ratio[`i']' %12.2f
    rv_row "`=country[`i']'" "`=cond(federal[`i'] == 1, "Yes", "No")'" "`a'" "`c'" "`r(s)'"
    if `i' < _N {
        if federal[`i'] == 1 & federal[`i' + 1] == 0 rv_mid
    }
}
rv_out TabS_gg_cg_ratio, ///
    title("Table S5. General and central government wage bill by country, 2010–2019 averages") ///
    notes("Compensation of employees of the general government (IMF GFS) and of the central government (WDI, compensation of employees as a share of expense times expense as a share of GDP, divided by 100), averages over 2010–2019 for countries with both series; microstates excluded. Federal: Forum of Federations list. Federations first, then unitary countries, each sorted by the ratio.")

log close
