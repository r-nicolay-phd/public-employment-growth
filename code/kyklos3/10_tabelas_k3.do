* 10_tabelas_k3.do -- tabelas e Figura 1 das estimacoes do parecer da versao final (numeracao final)
* Le os resultados de 01-09 (data/interim/kyklos3) e grava em output/kyklos3/tables e output/kyklos3/figures:
*   Table_A4_panel_calibrated, Table_A4_panel_lags_numerator, Table_A5_rows_controls_sources, Table_A8_panel_bias_common,
*   Table_A13_rows_calibrated, Table_A15_panel_size e Figure_1_simulation. Aplica as regras do Bloco 9 (kv.csv).
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/10_tabelas_k3.log", replace text

capture program drop f3
program define f3, rclass
    args x fmt
    if "`fmt'" == "" local fmt "%12.3f"
    rv_fmt `x' `fmt'
    return local s "`r(s)'"
end
capture program drop fci
program define fci, rclass
    args lo hi fmt
    if "`fmt'" == "" local fmt "%12.3f"
    rv_fmt `lo' `fmt'
    local l "`r(s)'"
    rv_fmt `hi' `fmt'
    return local s "[`l'; `r(s)']"
end
capture program drop fp
program define fp, rclass
    args p
    if missing(`p') return local s ""
    else if `p' < 0.001 return local s "<0.001"
    else return local s = string(`p', "%5.3f")
end
capture program drop fpc
program define fpc, rclass
    args x
    return local s = subinstr(string(100 * `x', "%5.0f"), "-", uchar(8722), 1) + "%"
end

* =====================================================================================
* Bloco 2: resumo da simulacao calibrada e Tabela A4 (painel novo)
* =====================================================================================
use "$KIN2/sim2_draws.dta", clear
append using "$RINT/simcal_draws.dta"
preserve
keep if var == "obs"
keep meas b
duplicates drop meas, force
rename b bobs
tempfile ob
save `ob'
restore
drop if var == "obs"
bysort var eps meas: egen double p025 = pctile(b), p(2.5)
bysort var eps meas: egen double p975 = pctile(b), p(97.5)
collapse (mean) mean = b (first) p025 p975 (count) nrep = b, by(var eps meas)
merge m:1 meas using `ob', keep(master match) nogen
gen double share = mean / bobs if inlist(meas, "wb", "wb_ham", "wb_hp1", "wb_l1", "T3")
save "$RINT/simcal_sum.dta", replace
kcsv "$RINT/simcal_sum.dta" Table_A4_panel_calibrated
kget "$RINT/kv.csv" b2_k_sd
local ksd = real("`r(v)'")
kget "$RINT/kv.csv" b2_k_ar
local kar = real("`r(v)'")
* placebo: coeficiente do placebo de numerador fixo sobre o observado (Tabela 1 / painel D antigo)
use "$KIN2/decomp.dta", clear
quietly summ b if item == "samey"
local bo = r(mean)
import delimited "$KIN/kv.csv", clear varnames(1) stringcols(_all)
quietly levelsof value if key == "vies_wb_placebo_b", local(v) clean
local n : word count `v'
local bpl = real("`: word `n' of `v''")
local shpl = `bpl' / `bo'
rv_kv b2_placebo_share `=string(`shpl', "%9.4f")'
* regra
use "$RINT/simcal_sum.dta", clear
quietly summ share if var == "csd" & meas == "wb" & abs(eps - 0.48) < 1e-6
local sh48 = r(mean)
quietly summ share if var == "csd" & meas == "wb" & abs(eps - 0.71) < 1e-6
local sh71 = r(mean)
local r2 = cond(`sh48' > 0.50, cond(`sh71' > 0.50, "at least half, title", "at least half"), cond(`sh48' >= 0.25, "quarter to half", "minority"))
rv_kv b2_share_cal48 `=string(`sh48', "%9.4f")'
rv_kv b2_share_cal71 `=string(`sh71', "%9.4f")'
rv_kv b2_rule "`r2'"
di "Bloco 2: fracao (calibrado pelo DP) = `sh48' (eps 0,48), `sh71' (eps 0,71); regra: `r2'"
foreach v in reg anc csd car sta {
    foreach e in 0.48 0.71 {
        quietly summ share if var == "`v'" & meas == "wb" & abs(eps - `e') < 1e-6
        local f_`v'_`=subinstr("`e'", ".", "", 1)' = r(mean)
    }
}
local pct = string(100 * `sh48', "%3.0f")
rv_new, ncol(8) head1("Observed" "ε = 0" "ε = 0.25" "ε = 0.48" "ε = 0.52" "ε = 0.71" "ε = 0.75" "ε = 1")
foreach vv in "csd|E. Calibrated anchored design: residuals scaled by k = `=string(`ksd', "%4.2f")' (within-country SD of the ratio)" ///
    "car|F. Calibrated anchored design: residuals scaled by k = `=string(`kar', "%4.2f")' (AR(1) of the ratio)" {
    gettoken v ttl : vv, parse("|")
    local ttl = substr("`ttl'", 2, .)
    rv_row "`ttl'" "" "" "" "" "" "" "" ""
    foreach mm in "wb|Annual: same-year ratio" "wb_ham|Annual: % of trend GDP (Hamilton)" "wb_l1|Annual: lagged one year" "T3|Five-year: wage bill in t_p − 1 (preferred specification)" {
        gettoken m lab : mm, parse("|")
        local lab = substr("`lab'", 2, .)
        quietly summ bobs if meas == "`m'"
        f3 `=r(mean)'
        local c0 "`r(s)'"
        local r1 ""
        local r2 ""
        foreach e in 0 0.25 0.48 0.52 0.71 0.75 1 {
            quietly summ mean if var == "`v'" & meas == "`m'" & abs(eps - `e') < 1e-6
            f3 `=r(mean)'
            local r1 `"`r1' "`r(s)'""'
            quietly summ p025 if var == "`v'" & meas == "`m'" & abs(eps - `e') < 1e-6
            local l = r(mean)
            quietly summ p975 if var == "`v'" & meas == "`m'" & abs(eps - `e') < 1e-6
            fci `l' `=r(mean)'
            local r2 `"`r2' "`r(s)'""'
        }
        rv_row "`lab'" "`c0'" `r1'
        rv_row "" "" `r2'
    }
    local r1 ""
    foreach e in 0 0.25 0.48 0.52 0.71 0.75 1 {
        quietly summ share if var == "`v'" & meas == "wb" & abs(eps - `e') < 1e-6
        fpc `=r(mean)'
        local r1 `"`r1' "`r(s)'""'
    }
    rv_row "Share of the observed same-year coefficient" "" `r1'
    foreach dd in "sdw|Within-country SD of the ratio" "ar1|AR(1) coefficient of the ratio" {
        gettoken d lab : dd, parse("|")
        local lab = substr("`lab'", 2, .)
        quietly summ bobs if meas == "`d'"
        f3 `=r(mean)'
        local c0 "`r(s)'"
        local r1 ""
        foreach e in 0 0.25 0.48 0.52 0.71 0.75 1 {
            quietly summ mean if var == "`v'" & meas == "`d'" & abs(eps - `e') < 1e-6
            f3 `=r(mean)'
            local r1 `"`r1' "`r(s)'""'
        }
        rv_row "`lab'" "`c0'" `r1'
    }
    rv_mid
}
rv_row "G. Share of the same-year coefficient by design" "" "" "" "ε = 0.48" "" "ε = 0.71" "" ""
foreach dd in "reg|Registered design (random walk in the wage bill; panel C)" "anc|Anchored design (panel A)" "csd|Calibrated anchored design, SD (panel E)" "car|Calibrated anchored design, AR(1) (panel F)" "sta|Mean-reverting design (panel B; ε = 0.48 only)" {
    gettoken d lab : dd, parse("|")
    local lab = substr("`lab'", 2, .)
    local a ""
    local b ""
    if !missing(`f_`d'_048') {
        fpc `f_`d'_048'
        local a "`r(s)'"
    }
    if !missing(`f_`d'_071') {
        fpc `f_`d'_071'
        local b "`r(s)'"
    }
    rv_row "   `lab'" "" "" "" "`a'" "" "`b'" "" ""
}
fpc `shpl'
rv_row "   Fixed-numerator placebo (does not depend on ε)" "" "" "" "`r(s)'" "" "`r(s)'" "" ""
rv_out Table_A4_panel_calibrated, landscape ///
    title("Table A4 (continued). Calibrated to the observed variance of the ratio, a zero-effect wage bill reproduces `pct'% of the same-year coefficient") ///
    notes("Panels E and F: anchored design of panel A (the synthetic ratio starts each year from the observed ratio of the previous year and moves with nominal GDP with elasticity ε), with the drawn residuals multiplied by k. k is the value of a grid from 0.30 to 1.00 (step 0.05; 200 replications per value at ε = 0.48) whose synthetic ratio has the within-country SD (panel E) or the AR(1) coefficient (panel F) closest to the observed one (0.976 and 0.970). Both criteria select the lowest value of the grid, 0.30; with k = 0.30 the within-country SD matches the observed one, while the AR(1) coefficient (0.961) stays below the observed one. 1,000 replications per ε. Cells: mean of the simulated coefficients and, below, their 2.5–97.5 percentiles; regressions as in panel A (annual model of Table 1 with its controls, country and year fixed effects, Table 1 sample; five-year preferred specification with controls in t_p − 1, country and period fixed effects). ε = 0.48 is the elasticity of the nominal wage bill to nominal GDP estimated on 1997–2023 (1,774 country-years); ε = 0.52 is the same elasticity on 1996–2023 (1,814 country-years, Table A3); ε = 0.71 is the elasticity of the nominal wage bill to nominal GDP growth holding real growth fixed (panel D), i.e. its response to prices. Panel G: simulated mean of the same-year coefficient over the observed one (−0.723), by design; the placebo row is the coefficient of the fixed-numerator placebo ratio over the observed one. $EXPL")

* =====================================================================================
* Bloco 4: Tabela A4 (painel novo): defasagens e numerador
* =====================================================================================
use "$RINT/dl_res.dta", clear
kget "$RINT/kv.csv" b4_sum_excl0
local sx = real("`r(v)'")
kget "$RINT/kv.csv" b4_withdraw_index
local wd = real("`r(v)'")
rv_new, ncol(5) head1("Coefficient" "95% CI" "p-value" "Effective F" "Obs.")
rv_row "H. Distributed lags of the wage bill (annual model of Table 1)" "" "" "" "" ""
forvalues i = 1/`=_N' {
    local it = item[`i']
    if "`it'" == "D_ls1" rv_row "I. Panel D and the numerator without nominal GDP growth on the right-hand side" "" "" "" "" ""
    if "`it'" == "ix" rv_row "J. Two readings of the numerator (no causal attribution)" "" "" "" "" ""
    f3 `=b[`i']'
    local x "`r(s)'"
    fci `=lo[`i']' `=hi[`i']'
    local c "`r(s)'"
    fp `=p[`i']'
    local pp "`r(s)'"
    local ff = cond(missing(F[`i']), "", string(F[`i'], "%5.1f"))
    rv_row "   `=lab[`i']'" "`x'" "`c'" "`pp'" "`ff'" "`=string(N[`i'], "%9.0fc")'"
}
local t4 = cond(`wd', "without nominal GDP growth on the right-hand side, the numerator is not associated with growth", "the numerator keeps its association with growth without nominal GDP growth on the right-hand side")
rv_out Table_A4_panel_lags_numerator, landscape ///
    title("Table A4 (continued). The lagged wage bill has no significant association with growth, and `t4'") ///
    notes("Annual panel 1996–2023, growth of real GDP per capita, controls of Table 1 (lagged growth, lagged log GDP per capita, human capital, investment, openness, inflation, population growth, terms-of-trade growth), country and year fixed effects, Driscoll-Kraay standard errors (maximum lag 3). Panel H: the ratio in t − 1, t − 2 and t − 3 jointly (A), or the ratio in t − 1 with its changes in t − 1 and t − 2 (B), on the Table 1 sample with three lags available; the implied long-run effect divides the sum by one minus the coefficient on lagged growth (delta method). Panel I: the decomposition of panel D (100 × log of the ratio in t − 1, 100 × Δlog of the nominal wage bill and 100 × Δlog of nominal GDP) re-estimated without Δlog nominal GDP, with deflator inflation in t − 1 instead, and with deflator inflation in t instrumented by its values in t − 1 and t − 2 (2SLS with country and year fixed effects, Driscoll-Kraay standard errors with bandwidth 4, normal CI; effective F of Montiel Olea and Pflueger, 2013). Deflator inflation: 100 × Δlog(nominal GDP / real GDP). Panel J: Δlog of the nominal wage bill on deflator inflation in t − 1 with country and year fixed effects (indexation), and deflator inflation on the lagged Δlog of the wage bill with the controls of Table 1 (wage pressure). $EXPL")

* =====================================================================================
* Blocos 3 e 7: Tabela A5 (linhas novas)
* =====================================================================================
rv_new, ncol(5) head1("Coefficient" "95% CI" "p-value" "Obs." "Countries")
use "$RINT/ctl_res.dta", clear
foreach vv in "0|Predetermined annual controls: Table 1 controls on the common sample" "a|Predetermined annual controls: all controls in t − 1" "b|Predetermined annual controls: in t − 1, without inflation" "c|Predetermined annual controls: in t − 1, without investment" {
    gettoken v lab : vv, parse("|")
    local lab = substr("`lab'", 2, .)
    rv_row "`lab'" "" "" "" "" ""
    foreach mm in "wb|Same-year ratio" "wb_hp1|% of trend GDP (one-sided HP)" "wb_ham|% of trend GDP (Hamilton)" "wb_l1|Lagged one year" {
        gettoken m ml : mm, parse("|")
        local ml = substr("`ml'", 2, .)
        quietly summ b if ver == "`v'" & m == "`m'"
        local bb = r(mean)
        quietly summ p if ver == "`v'" & m == "`m'"
        local pp = r(mean)
        rv_fmt `bb' %12.3f `pp'
        local x "`r(s)'"
        quietly summ lo if ver == "`v'" & m == "`m'"
        local l = r(mean)
        quietly summ hi if ver == "`v'" & m == "`m'"
        fci `l' `=r(mean)'
        local c "`r(s)'"
        fp `pp'
        local p3 "`r(s)'"
        quietly summ N if ver == "`v'" & m == "`m'"
        local nn = r(mean)
        quietly summ nc if ver == "`v'" & m == "`m'"
        rv_row "   `ml'" "`x'" "`c'" "`p3'" "`=string(`nn', "%9.0fc")'" "`=r(mean)'"
    }
    preserve
    use "$RINT/ctl_dif.dta", clear
    foreach dd in "lag|Same year − lagged (bootstrap)" "ham|Same year − Hamilton (bootstrap)" {
        gettoken d dl : dd, parse("|")
        local dl = substr("`dl'", 2, .)
        quietly summ d if ver == "`v'" & dif == "`d'"
        local x = r(mean)
        quietly summ p if ver == "`v'" & dif == "`d'"
        local pp = r(mean)
        rv_fmt `x' %12.3f `pp'
        local xs "`r(s)'"
        quietly summ lo if ver == "`v'" & dif == "`d'"
        local l = r(mean)
        quietly summ hi if ver == "`v'" & dif == "`d'"
        fci `l' `=r(mean)'
        local c "`r(s)'"
        fp `pp'
        rv_row "   `dl'" "`xs'" "`c'" "`r(s)'" "" ""
    }
    restore
}
rv_mid
use "$RINT/fon_res.dta", clear
foreach vv in "o1|Growth and denominator from different sources: Table 1 (WDI growth, IMF GDP in the ratio)" "p1|Growth from the Penn World Table 11.0, same ratio" "o2|Table 1 on the sample with GFS compensation in national currency" "w2|Ratio with WEO nominal GDP (GFS compensation in national currency / WEO GDP)" {
    gettoken v lab : vv, parse("|")
    local lab = substr("`lab'", 2, .)
    rv_row "`lab'" "" "" "" "" ""
    foreach mm in "same|Same-year ratio" "ham|% of trend GDP (Hamilton)" "lag|Lagged one year" {
        gettoken m ml : mm, parse("|")
        local ml = substr("`ml'", 2, .)
        quietly summ b if ver == "`v'" & m == "`m'"
        local bb = r(mean)
        quietly summ p if ver == "`v'" & m == "`m'"
        local pp = r(mean)
        rv_fmt `bb' %12.3f `pp'
        local x "`r(s)'"
        quietly summ lo if ver == "`v'" & m == "`m'"
        local l = r(mean)
        quietly summ hi if ver == "`v'" & m == "`m'"
        fci `l' `=r(mean)'
        local c "`r(s)'"
        fp `pp'
        local p3 "`r(s)'"
        quietly summ N if ver == "`v'" & m == "`m'"
        local nn = r(mean)
        quietly summ nc if ver == "`v'" & m == "`m'"
        rv_row "   `ml'" "`x'" "`c'" "`p3'" "`=string(`nn', "%9.0fc")'" "`=r(mean)'"
    }
    preserve
    use "$RINT/fon_dif.dta", clear
    quietly summ d if ver == "`v'" & dif == "lag"
    local x = r(mean)
    quietly summ p if ver == "`v'" & dif == "lag"
    local pp = r(mean)
    rv_fmt `x' %12.3f `pp'
    local xs "`r(s)'"
    quietly summ lo if ver == "`v'" & dif == "lag"
    local l = r(mean)
    quietly summ hi if ver == "`v'" & dif == "lag"
    fci `l' `=r(mean)'
    local c "`r(s)'"
    fp `pp'
    rv_row "   Same year − lagged (bootstrap)" "`xs'" "`c'" "`r(s)'" "" ""
    restore
}
kget "$RINT/kv.csv" b7_change_pwt
local cp = real("`r(v)'")
kget "$RINT/kv.csv" b7_corr_wb_wbW
local rw = real("`r(v)'")
rv_out Table_A5_rows_controls_sources, landscape ///
    title("Table A5 (continued). The same-year bias survives predetermined annual controls and growth measured from a different source") ///
    notes("Predetermined annual controls: the annual model of Table 1 (1996–2023, country and year fixed effects, Driscoll-Kraay standard errors) on the Table 1 sample with all controls also available in t − 1 (the same sample in the four blocks), with the controls of Table 1, with all controls in t − 1 (lagged growth, lagged log GDP per capita, human capital, investment, openness, inflation, population growth and terms-of-trade growth), and without inflation or investment. Different sources: growth of real GDP per capita from the Penn World Table 11.0 (100 × Δlog of rgdpna / pop; its own lag replaces lagged WDI growth among the controls), with the wage bill ratio built with IMF GDP; and WDI growth with the ratio of general government compensation of employees in national currency (IMF GFS) to nominal GDP of the IMF World Economic Outlook. The GFS ratios are computed with WEO GDP (correlation with the ratio of Table 1: `=string(`rw', "%5.3f")'), so the second check differs from Table 1 mainly by vintage; the Penn World Table check changes the same-year coefficient by `=string(100 * `cp', "%3.0f")'%. Differences: the three measures stacked with measure-specific controls and year effects, wild cluster bootstrap by country (Webb weights, 9,999 replications). $EXPL * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Bloco 5: Tabela A8 (painel de vies na amostra comum, substitui o painel anterior)
* =====================================================================================
kget "$RINT/kv.csv" b5_Ncommon
local Nc = real("`r(v)'")
kget "$RINT/kv.csv" b5_share_neg
local fneg = real("`r(v)'")
kget "$RINT/kv.csv" b5_lopo_sig
local ls = real("`r(v)'")
kget "$RINT/kv.csv" b5_lopo_n
local ln = real("`r(v)'")
kget "$RINT/kv.csv" b5_boot_draws
local nbd = real("`r(v)'")
use "$RINT/vc_sum.dta", clear
quietly summ b
local blo = r(min)
local bhi = r(max)
rv_new, ncol(7) head1("Wage-bill coefficient" "Bootstrap p" "Difference from the preferred estimate [95% CI]" "Observed − mean-reverting null [95% CI]" "Observed − calibrated null [95% CI]" "" "")
rv_row "Bias checks for the predetermined estimate on a common sample (`=string(`Nc', "%9.0fc")' country-periods)" "" "" "" "" "" "" ""
foreach kk in "T3|Preferred specification" "i1|+ output gap in t_p − 1" "i2a|+ growth of p − 1 (LSDV)" "i2b|+ growth of p − 1 + output gap" "i3|Negative-gap interaction: average effect" "i4|2SLS: ratio in t_p − 1 instrumented by the ratios in t_p − 2 and t_p − 3" {
    gettoken it lab : kk, parse("|")
    local lab = substr("`lab'", 2, .)
    quietly summ b if item == "`it'"
    f3 `=r(mean)'
    local c1 "`r(s)'"
    quietly summ pboot if item == "`it'"
    fp `=r(mean)'
    local c2 "`r(s)'"
    local c3 ""
    if "`it'" != "T3" {
        quietly summ dT3 if item == "`it'"
        f3 `=r(mean)'
        local x "`r(s)'"
        quietly summ dT3_lo if item == "`it'"
        local l = r(mean)
        quietly summ dT3_hi if item == "`it'"
        fci `l' `=r(mean)'
        local c3 "`x' `r(s)'"
    }
    foreach d in sta cal {
        quietly summ adj_`d' if item == "`it'"
        f3 `=r(mean)'
        local x "`r(s)'"
        quietly summ adj_`d'_lo if item == "`it'"
        local l = r(mean)
        quietly summ adj_`d'_hi if item == "`it'"
        fci `l' `=r(mean)'
        local c_`d' "`x' `r(s)'"
    }
    rv_row "   `lab'" "`c1'" "`c2'" "`c3'" "`c_sta'" "`c_cal'" "" ""
}
rv_row "Leave one period out (full sample of the preferred specification): periods whose omission leaves p < 0.05" "`ls' of `ln'" "" "" "" "" "" ""
rv_out Table_A8_panel_bias_common, landscape ///
    title("Table A8 (continued). On a common sample, every bias check stays within 0.05 of the preferred estimate (`=subinstr(string(`blo', "%5.3f"), "-", uchar(8722), 1)' to `=subinstr(string(`bhi', "%5.3f"), "-", uchar(8722), 1)')") ///
    notes("Replaces the bias panel of the earlier version. Common sample: the country-periods of the preferred specification (five-year averages, wage bill in t_p − 1, controls in t_p − 1, country and period fixed effects) for which every variant can be estimated (output gap in t_p − 1, average growth of p − 1, and the annual ratios in t_p − 2 and t_p − 3). The negative-gap model is summarised by its average effect, the coefficient after a positive gap plus the interaction times the share of negative gaps (`=string(`fneg', "%4.2f")'). Bootstrap p: wild cluster bootstrap by country (Webb weights, 9,999 replications; WRE for 2SLS). Differences from the preferred estimate: country pairs bootstrap, the same `nbd' draws for every variant. Null-adjusted estimates: observed coefficient minus the mean of 1,000 simulations of a zero-effect wage bill (mean-reverting design of Table A4, panel B, or calibrated anchored design of Table A4, panel E), with the simulated ratios replacing the observed ones (also in the instruments); the CI comes from the same pairs-bootstrap draws, each re-estimating the observed coefficient and running one new simulation on the resampled countries, so that it combines sampling and simulation error. Leave one period out: the preferred specification on its full sample, dropping each period in turn, clustered standard errors. $EXPL")

* =====================================================================================
* Blocos 2 (item 5) e 6: Tabela A13 (linhas novas no painel F)
* =====================================================================================
use "$RINT/siminst3_sum.dta", clear
kget "$RINT/kv.csv" b2i_k_v
local kv = real("`r(v)'")
kget "$RINT/kv.csv" b6_cells_sig
local csig = real("`r(v)'")
kget "$RINT/kv.csv" b6_cells_n
local cn = real("`r(v)'")
kget "$RINT/kv.csv" b6_rows_identical_by_construction
local same = real("`r(v)'")
rv_new, ncol(6) head1("Simulated mean [2.5–97.5]" "Share of the observed interaction [2.5–97.5]" "Share of the published interaction (−0.811) [2.5–97.5]" "" "" "")
foreach sp in "D|Published specification (observed same-year interaction −2.326)" "C|Approximate replication registered in the plan (observed −0.184)" {
    gettoken s lab : sp, parse("|")
    local lab = substr("`lab'", 2, .)
    rv_row "`lab'" "" "" "" "" "" ""
    foreach dd in "anc556G|Anchored, ε_0 = 0.556, gradient" "anc556C|Anchored, ε_0 = 0.556, no gradient" "anc701G|Anchored, ε_0 = 0.701, gradient" "anc701C|Anchored, ε_0 = 0.701, no gradient" "cal556G|Calibrated, ε_0 = 0.556, gradient" "cal556C|Calibrated, ε_0 = 0.556, no gradient" "cal701G|Calibrated, ε_0 = 0.701, gradient" "cal701C|Calibrated, ε_0 = 0.701, no gradient" {
        gettoken d dl : dd, parse("|")
        local dl = substr("`dl'", 2, .)
        quietly summ mean if des == "`d'" & spec == "`s'" & meas == "c"
        f3 `=r(mean)'
        local x "`r(s)'"
        quietly summ p025 if des == "`d'" & spec == "`s'" & meas == "c"
        local l = r(mean)
        quietly summ p975 if des == "`d'" & spec == "`s'" & meas == "c"
        fci `l' `=r(mean)'
        local c1 "`x' `r(s)'"
        quietly summ share if des == "`d'" & spec == "`s'" & meas == "c"
        fpc `=r(mean)'
        local x "`r(s)'"
        quietly summ sh_lo if des == "`d'" & spec == "`s'" & meas == "c"
        fpc `=r(mean)'
        local l "`r(s)'"
        quietly summ sh_hi if des == "`d'" & spec == "`s'" & meas == "c"
        fpc `=r(mean)'
        local c2 "`x' [`l'; `r(s)']"
        local c3 ""
        if "`s'" == "D" {
            quietly summ share_pub if des == "`d'" & spec == "`s'" & meas == "c"
            fpc `=r(mean)'
            local x "`r(s)'"
            quietly summ shp_lo if des == "`d'" & spec == "`s'" & meas == "c"
            fpc `=r(mean)'
            local l "`r(s)'"
            quietly summ shp_hi if des == "`d'" & spec == "`s'" & meas == "c"
            fpc `=r(mean)'
            local c3 "`x' [`l'; `r(s)']"
        }
        rv_row "   `dl'" "`c1'" "`c2'" "`c3'" "" "" ""
    }
}
rv_row "Panel E: triple-interaction cells with p < 0.05" "`csig' of `cn'" "" "" "" "" ""
quietly summ share if des == "cal556G" & spec == "C" & meas == "c"
local shC = r(mean)
quietly summ share if des == "anc556C" & spec == "D" & meas == "c"
local shD = r(mean)
rv_out Table_A13_rows_calibrated, landscape ///
    title("Table A13 (continued). In the registered specification a zero-effect consumption series reproduces `=string(100 * `shC', "%3.0f")'% of the interaction (calibrated design)") ///
    notes("Rows added to panel F. Same-year consumption × institutions interaction under the null of no effect of consumption on growth: synthetic consumption / GDP anchored on the observed ratio of t − 1, with elasticity to nominal GDP ε_it = ε_0 + ε_1 × WGI_i,t−1 (gradient: ε_1 = −0.180, from the mechanism panel; no gradient: ε_1 = 0). ε_0 = 0.556 is the elasticity at mean institutions in the mechanism regression (with the WGI interaction, 1996–2023); ε_0 = 0.701 is the elasticity of government consumption to GDP without the interaction (Table A3). Calibrated: drawn residuals multiplied by k = `=string(`kv', "%4.2f")', the value of a grid from 0.30 to 1.00 whose synthetic ratio has the within-country SD closest to the observed one in each specification. 1,000 replications per design; percentiles of the replication-level share in brackets. Published specification: Mollick and Vianna (2024), Table A12, panel D; approximate replication: Table A12, panel C. Panel E summary: cells of the triple-interaction test (three timings × FE and System GMM × all countries and countries in both periods × two splits of the overlapping years); FE cells use the wild bootstrap p, System GMM cells the Windmeijer-corrected p. `=cond(`same', "The lower rows ICRG/QoG 1996–2020 and ICRG/QoG common sample coincide because every country-period with the ICRG/QoG index also has WGI; they are the same estimate, not a copy error.", "")' $EXPL")

* =====================================================================================
* Bloco 1: Tabela A15 (painel novo)
* =====================================================================================
use "$RINT/tam_res.dta", clear
rv_new, ncol(7) head1("Coefficient (95% CI)" "Bootstrap p" "Per point of GDP [95% CI]" "Mean wage bill" "Obs." "Countries" "")
foreach ss in "a|(a) Preferred-specification sample" "b|(b) Preferred-specification sample, periods from 1999" "c|(c) Registered H2 sample (Table 2, column 3)" "d|(d) Strict H2 sample" {
    gettoken s lab : ss, parse("|")
    local lab = substr("`lab'", 2, .)
    rv_row "`lab'" "" "" "" "" "" "" ""
    foreach xx in "wm|Wage bill in t_p − 1, level" "lwm|Wage bill in t_p − 1, log" "ws|Wage bill in the year of the WWBI pair, level" "lws|Wage bill in the year of the WWBI pair, log" {
        gettoken x xl : xx, parse("|")
        local xl = substr("`xl'", 2, .)
        quietly count if smp == "`s'" & x == "`x'"
        if r(N) == 0 continue
        quietly summ b if smp == "`s'" & x == "`x'"
        f3 `=r(mean)'
        local bb "`r(s)'"
        quietly summ lo if smp == "`s'" & x == "`x'"
        local l = r(mean)
        quietly summ hi if smp == "`s'" & x == "`x'"
        fci `l' `=r(mean)'
        local c1 "`bb' `r(s)'"
        quietly summ pboot if smp == "`s'" & x == "`x'"
        fp `=r(mean)'
        local c2 "`r(s)'"
        quietly summ conv if smp == "`s'" & x == "`x'"
        f3 `=r(mean)'
        local cc "`r(s)'"
        quietly summ conv_lo if smp == "`s'" & x == "`x'"
        local l = r(mean)
        quietly summ conv_hi if smp == "`s'" & x == "`x'"
        fci `l' `=r(mean)'
        local c3 "`cc' `r(s)'"
        quietly summ mean if smp == "`s'" & x == "`x'"
        local c4 = string(r(mean), "%5.2f")
        quietly summ N if smp == "`s'" & x == "`x'"
        local c5 = string(r(mean), "%9.0fc")
        quietly summ nc if smp == "`s'" & x == "`x'"
        rv_row "   `xl'" "`c1'" "`c2'" "`c3'" "`c4'" "`c5'" "`=r(mean)'" ""
    }
}
rv_mid
use "$RINT/tam_dif.dta", clear
rv_row "Decomposition of the difference and tests (country pairs bootstrap)" "Points of growth per point of GDP" "95% CI" "Share of the total" "" "" "" ""
forvalues i = 1/`=_N' {
    f3 `=est[`i']'
    local x "`r(s)'"
    fci `=lo[`i']' `=hi[`i']'
    local c "`r(s)'"
    local sh = ""
    if !missing(share[`i']) {
        fpc `=share[`i']'
        local sh "`r(s)'"
    }
    rv_row "   `=lab[`i']'" "`x'" "`c'" "`sh'" "" "" "" ""
}
kget "$RINT/kv.csv" b1_cost
local cost = real("`r(v)'")
rv_out Table_A15_panel_size, landscape ///
    title("Table A15 (continued). Wage bill size across samples and functional forms: `=cond(`cost', "a cost of at least 0.3 points per point of GDP appears in the H2 samples", "no cost of 0.3 points per point of GDP in any sample")'") ///
    notes("Growth of real GDP per capita (five-year averages) on the wage bill (% of GDP, IMF GFS) in level or in log, with the controls in t_p − 1 and the country and period fixed effects of the preferred specification, standard errors clustered by country (95% CI) and wild cluster bootstrap p (Webb weights, 9,999 replications). Samples: (a) the preferred specification; (b) its periods starting in 1999 or later, the first period with WWBI pairs; (c) the registered H2 sample of Table 2, column 3; (d) the strict H2 sample (WWBI pairs in t_p − 1 to t_p − 4). In (c) and (d) the wage bill is measured in t_p − 1, as in the preferred specification, or in the year of the WWBI pair, as in Table 2; rows with the wage bill in t_p − 1 lose the country-periods where it is missing. Per point of GDP: log coefficient divided by the sample mean of the wage bill (delta method, mean treated as fixed); level coefficients unchanged. Decomposition: the change from the level coefficient in (a) to the log coefficient with the pair-year wage bill in (c), split in the order functional form, period, WWBI countries and timing of the pair; tests and decomposition steps with 95% CIs from a country pairs bootstrap (999 draws). $EXPL")

* =====================================================================================
* Figura 1 (nova versao): desenho calibrado em preto, ancorado em cinza
* =====================================================================================
use "$RINT/simcal_sum.dta", clear
keep if inlist(var, "csd", "anc", "reg", "sta") & inlist(meas, "wb", "T3")
gen double x = 1 - eps
gen double xa = x + 0.012
gen double xr = x - 0.012
foreach m in wb T3 {
    quietly summ bobs if meas == "`m'"
    local o`m' = r(mean)
}
twoway (rcap p025 p975 x if var == "csd" & meas == "wb", lcolor(black)) (connected mean x if var == "csd" & meas == "wb", sort lcolor(black) mcolor(black) msymbol(O)) ///
    (connected mean xa if var == "anc" & meas == "wb", sort lcolor(gs10) mcolor(gs10) msymbol(Oh) lpattern(dash)) ///
    (scatter mean xr if var == "reg" & meas == "wb", mcolor(gs8) msymbol(X)) (scatter mean x if var == "sta" & meas == "wb", mcolor(gs5) msymbol(T)) ///
    (function y = `owb' * x / 0.52, range(0 `=min(1, 0.52 / abs(`owb'))') lcolor(gs6) lpattern(dot)), ///
    $GOPT yline(`owb', lcolor(black) lpattern(dash)) yline(0, lcolor(gs12)) xscale(range(-0.03 1.05)) xlabel(0(0.25)1, format(%4.2f) labsize(8pt)) ///
    yscale(range(-1.05 0.15)) ylabel(-1(0.25)0, format(%4.2f)) title("(a) Annual, same-year ratio", size(9pt)) xtitle("1 − ε", size(8pt)) ytitle("Coefficient", size(8pt)) ///
    legend(order(2 "Calibrated (95% interval)" 3 "Anchored" 4 "Registered design" 5 "Mean-reverting" 6 "Full-accounting ray") cols(1) ring(0) pos(7) size(6.5pt) symxsize(6) region(lcolor(none) fcolor(white))) name(a, replace) nodraw
twoway (rcap p025 p975 x if var == "csd" & meas == "T3", lcolor(black)) (connected mean x if var == "csd" & meas == "T3", sort lcolor(black) mcolor(black) msymbol(O)) ///
    (connected mean xa if var == "anc" & meas == "T3", sort lcolor(gs10) mcolor(gs10) msymbol(Oh) lpattern(dash)) ///
    (scatter mean xr if var == "reg" & meas == "T3", mcolor(gs8) msymbol(X)) (scatter mean x if var == "sta" & meas == "T3", mcolor(gs5) msymbol(T)), ///
    $GOPT yline(`oT3', lcolor(black) lpattern(dash)) yline(0, lcolor(gs12)) xscale(range(-0.03 1.05)) xlabel(0(0.25)1, format(%4.2f) labsize(8pt)) ///
    ylabel(, format(%4.2f)) title("(b) Five-year, wage bill in t{sub:p} − 1", size(9pt)) xtitle("1 − ε", size(8pt)) ytitle("Coefficient", size(8pt)) legend(off) name(b, replace) nodraw
use "$RINT/siminst3_draws.dta", clear
keep if spec == "D" & meas == "c" & inlist(des, "cal556G", "cal556C")
append using "$KIN2/siminst_draws.dta"
keep if spec == "D" & meas == "c"
quietly summ b if des == "obs"
local oD = r(mean)
local xl = floor(min(`oD', -2.5))
twoway (kdensity b if des == "cal556G", lcolor(black)) (kdensity b if des == "cal556C", lcolor(black) lpattern(dash)) ///
    (kdensity b if des == "G", lcolor(gs10)) (kdensity b if des == "C", lcolor(gs10) lpattern(dash)), $GOPT ///
    xline(`oD', lcolor(black) lpattern(shortdash)) xline(0, lcolor(gs12)) xscale(range(`xl' 0.25)) xlabel(`xl'(1)0, format(%3.0f) labsize(8pt)) ///
    title("(c) Consumption × institutions", size(9pt)) xtitle("Interaction, same-year consumption", size(8pt)) ytitle("Density", size(8pt)) ///
    legend(order(1 "Calibrated, gradient" 2 "Calibrated, no gradient" 3 "Anchored, gradient" 4 "Anchored, no gradient") cols(1) ring(0) pos(11) size(6.5pt) symxsize(6) region(lcolor(none) fcolor(white))) name(c, replace) nodraw
graph combine a b c, cols(3) graphregion(color(white)) ///
    note("Panels (a) and (b): simulated mean against 1 − ε for a zero-effect wage bill; dashed line: observed coefficient; dotted ray: coefficient proportional to 1 − ε through the observed value at ε = 0.48." ///
    "Panel (c): simulated same-year interaction in the published specification of Mollick and Vianna (2024), 1,000 replications per design; short-dashed line: observed interaction.", size(6.5pt))
rv_fig Figure_1_simulation, width(190) height(85)

* Figura A2 (influencia): mesma figura de code/kyklos/07_equivalencia.do, com rotulos sem nomes internos
use "$KIN1/influencia.dta", clear
quietly summ b if kind == "base"
local b0 = r(mean)
keep if inlist(kind, "loo_c", "loo_p")
gsort kind b
by kind: gen r = _n
twoway (rcap lo hi r if kind == "loo_c", lcolor(gs10)) (scatter b r if kind == "loo_c", msymbol(O) mcolor(black) msize(vsmall)), ///
    $GOPT yline(`b0', lcolor(black) lpattern(dash)) yline(0, lcolor(gs10) lpattern(shortdash)) xlabel(none) xtitle("Country left out (ranked)", size(8pt)) ///
    ytitle("Coefficient, preferred specification (95% CI)", size(8pt)) title("(a) Leave one country out", size(9pt)) legend(off) name(i1, replace) nodraw
twoway (rcap lo hi r if kind == "loo_p", lcolor(gs10)) (scatter b r if kind == "loo_p", msymbol(D) mcolor(black) msize(small)), ///
    $GOPT yline(`b0', lcolor(black) lpattern(dash)) yline(0, lcolor(gs10) lpattern(shortdash)) xlabel(none) xtitle("Period left out (ranked)", size(8pt)) ///
    ytitle("") title("(b) Leave one period out", size(9pt)) legend(off) name(i2, replace) nodraw
graph combine i1 i2, cols(2) graphregion(color(white)) note("Dashed line: full-sample coefficient of the preferred specification.", size(7pt))
rv_fig Figure_A2_influence, width(190) height(80)
log close
