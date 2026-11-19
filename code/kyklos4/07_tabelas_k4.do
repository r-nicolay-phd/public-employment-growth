* 07_tabelas_k4.do -- partes novas das tabelas e figuras (numeracao da versao 5) a partir dos resultados de 01-05
* Grava em output/kyklos4/tables (Table_A4_part_moment_matched, Table_A8_part_drivers, Table_A9_part_common_scale,
* Table_A7_rows_grid_tests, Table_A6_rows_five_year_tests, Table_A12_rows_trend_null, Table_A13_part_null_shares,
* Table_A14_rows_vintage) e em output/kyklos4/figures (Figure_1_simulation, Figure_A3_common_scale, Figure_A2_influence).
* As figuras levam so titulos de painel, eixos e legendas; as notas ficam em output/kyklos4/EXHIBITS_CHANGES.md.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/07_tabelas_k4.log", replace text
global ADD "Exploratory (post-plan, pre-registered in the fourth addendum)."

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
    if missing(`x') return local s ""
    else return local s = subinstr(string(100 * `x', "%5.0f"), "-", uchar(8722), 1) + "%"
end
capture program drop kv4
program define kv4, rclass
    args key
    * valor completo (inclusive com espacos) da ultima ocorrencia da chave; kget devolve so a ultima palavra
    preserve
    quietly import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
    quietly keep if key == "`key'"
    local v = cond(_N > 0, value[_N], "")
    restore
    return local v "`v'"
end

* =====================================================================================
* Tabela A4: fracao contabil com calibracao por momentos (Bloco 1)
* =====================================================================================
use "$RINT/gk_draws.dta", clear
keep if des == "obs"
foreach m in wb wb_l1 wb_ham sdw ar1 {
    quietly summ b if meas == "`m'"
    local o_`m' = r(mean)
}
use "$RINT/gk_choice.dta", clear
rv_new, ncol(7) head1("k*" "Share of the same-year coefficient at k*" "k within 10% of the minimum distance (shares)" "Lagged ratio at k* [2.5–97.5]" "Ratio over Hamilton trend GDP at k* [2.5–97.5]" "Reproduces both" "")
rv_row "K. Moment-matched calibration (observed: lagged `=subinstr(string(`o_wb_l1', "%5.3f"), "-", uchar(8722), 1)', Hamilton `=subinstr(string(`o_wb_ham', "%5.3f"), "-", uchar(8722), 1)')" "" "" "" "" "" "" ""
forvalues i = 1/`=_N' {
    local lab = cond(des[`i'] == "sep", "Separate real and price elasticities", "ε = " + string(eps[`i'], "%4.2f"))
    fpc `=share[`i']'
    local sh "`r(s)'"
    fpc `=sharelo[`i']'
    local a "`r(s)'"
    fpc `=sharehi[`i']'
    local rg = string(klo[`i'], "%4.2f") + "–" + string(khi[`i'], "%4.2f") + " (`a' to `r(s)')"
    f3 `=lag_mean[`i']'
    local x "`r(s)'"
    fci `=lag_lo[`i']' `=lag_hi[`i']'
    local cl "`x' `r(s)'"
    f3 `=ham_mean[`i']'
    local x "`r(s)'"
    fci `=ham_lo[`i']' `=ham_hi[`i']'
    local ch "`x' `r(s)'"
    local rp = cond(lag_in[`i'] == 1 & ham_in[`i'] == 1, "Yes", "No")
    rv_row "   `lab'" "`=string(kstar[`i'], "%4.2f")'" "`sh'" "`rg'" "`cl'" "`ch'" "`rp'" ""
}
* referencia: k = 0 (sem residuo; simulacao deterministica), eps = 0,48
preserve
use "$RINT/gk_sum.dta", clear
keep if des == "anc" & abs(eps - 0.48) < 1e-6 & k == 0
quietly summ share if meas == "wb"
fpc `=r(mean)'
local sh0 "`r(s)'"
foreach m in wb_l1 wb_ham {
    quietly summ mean if meas == "`m'"
    f3 `=r(mean)'
    local c0_`m' "`r(s)'"
    quietly summ inside if meas == "`m'"
    local in0_`m' = r(mean)
}
restore
rv_row "   ε = 0.48, k = 0 (no residual; reference)" "0.00" "`sh0'" "" "`c0_wb_l1'" "`c0_wb_ham'" "`=cond(`in0_wb_l1' == 1 & `in0_wb_ham' == 1, "Yes", "No")'" ""
use "$RINT/psi_final_sum.dta", clear
rv_row "L. Residual correlated with real growth (ψ), chosen jointly with k" "k, ψ" "Share" "" "Lagged ratio [2.5–97.5]" "Hamilton [2.5–97.5]" "Reproduces both" ""
foreach e in 0.48 0.71 {
    quietly summ k if abs(eps - `e') < 1e-6
    local kk = r(mean)
    quietly summ psi if abs(eps - `e') < 1e-6
    local pp = r(mean)
    quietly summ share if abs(eps - `e') < 1e-6 & meas == "wb"
    fpc `=r(mean)'
    local sh "`r(s)'"
    foreach m in wb_l1 wb_ham {
        quietly summ mean if abs(eps - `e') < 1e-6 & meas == "`m'"
        f3 `=r(mean)'
        local x "`r(s)'"
        quietly summ p025 if abs(eps - `e') < 1e-6 & meas == "`m'"
        local l = r(mean)
        quietly summ p975 if abs(eps - `e') < 1e-6 & meas == "`m'"
        fci `l' `=r(mean)'
        local c_`m' "`x' `r(s)'"
        quietly summ inside if abs(eps - `e') < 1e-6 & meas == "`m'"
        local in_`m' = r(mean)
    }
    local rp = cond(`in_wb_l1' == 1 & `in_wb_ham' == 1, "Yes", "No")
    local kpl = string(`kk', "%4.2f") + ", " + subinstr(string(`pp', "%4.1f"), "-", uchar(8722), 1)
    local el = string(`e', "%4.2f")
    rv_row "   ε = `el'" "`kpl'" "`sh'" "" "`c_wb_l1'" "`c_wb_ham'" "`rp'" ""
}
rv_row "M. Analytic reference (no simulation)" "λ = Var(A)/Var(Δln s)" "Implied share" "" "" "" "" ""
foreach e in 048 071 {
    kv4 b1_an_`e'_lambda
    local la = real("`r(v)'")
    kv4 b1_an_`e'_share
    local s = real("`r(v)'")
    fpc `s'
    rv_row "   ε = `=substr("`e'", 1, 1)'.`=substr("`e'", 2, 2)'" "`=string(`la', "%5.3f")'" "`r(s)'" "" "" "" "" ""
}
kv4 b1_eps_real
local er = real("`r(v)'")
kv4 b1_eps_real_se
local ers = real("`r(v)'")
kv4 b1_eps_price
local ep = real("`r(v)'")
kv4 b1_eps_price_se
local eps_ = real("`r(v)'")
local c_er = string(`er', "%5.3f") + " (" + string(`ers', "%5.3f") + ")"
local c_ep = string(`ep', "%5.3f") + " (" + string(`eps_', "%5.3f") + ")"
rv_row "   Elasticity of the nominal wage bill to real GDP growth (SE); to deflator inflation (SE)" "`c_er'" "`c_ep'" "" "" "" "" ""
kv4 b1_rule
local r1 "`r(v)'"
kv4 b1_share48
local s48 = real("`r(v)'")
local t4 = cond("`r1'" == "full range", "at the central elasticity (ε = 0.48) no value of k reproduces both the lagged and the Hamilton coefficients, so the moments do not pin down the accounting share", ///
    cond("`r1'" == "at least half", "the moment-matched design reproduces the data and accounts for at least half of the same-year coefficient", ///
    "the moment-matched design reproduces the data and accounts for " + string(100 * `s48', "%3.0f") + "% of the same-year coefficient"))
rv_out Table_A4_part_moment_matched, landscape title("Table A4 (continued). Moment-matched calibration: `t4'") ///
    notes("Panel K: anchored design (the synthetic ratio starts each year from the observed ratio of the previous year and moves with nominal GDP with elasticity ε), with the drawn residuals multiplied by k ∈ {0, 0.05, 0.10, 0.15, 0.20, 0.25, 0.30, 0.40, 0.50, 0.75, 1}; 1,000 replications per cell. k* minimises the sum of the absolute deviations between simulated mean and observed value, each divided by its simulated standard deviation, of four moments: within-country SD of the ratio, its AR(1), the coefficient of the lagged ratio and the coefficient of the ratio over Hamilton trend GDP; the same-year coefficient does not enter. Share: simulated mean of the same-year coefficient over the observed one (−0.723). Reproduces both: the observed lagged and Hamilton coefficients lie inside the 2.5–97.5 percentiles of their simulated distributions at k*. Reference row k = 0: the synthetic ratio moves only with nominal GDP, so the simulation is deterministic and no percentiles are shown. Separate elasticities: Δln s = (ε_r − 1) Δln real GDP + (ε_p − 1) deflator inflation + k u, with the elasticities of panel M. Panel L: the numerator residual has a component ψ × real per-capita growth; k and ψ (grid −0.5 to 0.5) chosen by the same distance with 200 replications per cell, then 1,000 replications at the chosen point. Panel M: within-country and within-year variation in the Table 1 sample; A = −(1 − ε) Δln nominal GDP; implied share = cov(growth, A) / cov(growth, Δln s); elasticities from 100 × Δln W on 100 × Δln real GDP and deflator inflation, country and year fixed effects, Driscoll-Kraay standard errors. Regressions in each replication as in Table 1 (controls of Table 1, country and year fixed effects). $ADD")

* =====================================================================================
* Tabela A8: quais pais-periodos movem a estimativa quinquenal (Bloco 2)
* =====================================================================================
kv4 b2_b355
local b355 = real("`r(v)'")
kv4 b2_b311
local b311 = real("`r(v)'")
kv4 b2_Lg_recovered
local nrec = real("`r(v)'")
rv_new, ncol(5) head1("Lost (44)" "Kept (311)" "Difference" "p-value" "")
rv_row "Which country-periods drive the five-year estimate (`=subinstr(string(`b355', "%5.3f"), "-", uchar(8722), 1)' on 355; `=subinstr(string(`b311', "%5.3f"), "-", uchar(8722), 1)' on 311)" "" "" "" "" ""
use "$RINT/q5_desc.dta", clear
forvalues i = 1/`=_N' {
    local v = v[`i']
    local lab = cond("`v'" == "firstrep", "First period in which the country reports the GFS wage bill (share)", cond("`v'" == "trans99", "Transition economy, period before 1999 (share)", ///
        cond("`v'" == "early", "Period starting 1979–1993 (share)", cond("`v'" == "nineties", "Period starting 1989 or 1994 (share)", cond("`v'" == "lny0", "Log GDP per capita, t_p − 1", ///
        cond("`v'" == "merit_m1", "Meritocratic recruitment, t_p − 1", cond("`v'" == "debt_m1", "Public debt (% of GDP), t_p − 1", cond("`v'" == "g", "Growth in the period (%)", "Wage bill (% of GDP), t_p − 1"))))))))
    f3 `=m_lost[`i']' %12.2f
    local a "`r(s)'"
    f3 `=m_kept[`i']' %12.2f
    local b "`r(s)'"
    f3 `=d[`i']' %12.2f
    local c "`r(s)'"
    fp `=p[`i']'
    rv_row "   `lab'" "`a'" "`b'" "`c'" "`r(s)'" ""
}
use "$RINT/q5_groups.dta", clear
rv_row "Wage-bill coefficient by group (355)" "In the group" "Outside" "Interaction" "Bootstrap p" ""
forvalues i = 1/`=_N' {
    local lab = cond(grp[`i'] == "firstrep", "First reporting period", "Transition, before 1999")
    f3 `=b1[`i']'
    local a "`r(s)'"
    f3 `=b0[`i']'
    local b "`r(s)'"
    f3 `=bint[`i']'
    local c "`r(s)'"
    fp `=pboot_int[`i']'
    rv_row "   `lab'" "`a'" "`b'" "`c'" "`r(s)'" ""
}
use "$RINT/q5_infl.dta", clear
rv_row "Dropping blocks of the 44 from the 355" "Coefficient" "Share of the difference explained" "Obs." "" ""
foreach bb in "firstrep|First reporting periods" "trans99|Transition, before 1999" "early|Periods starting 1979–1993" "all44|All 44" {
    gettoken nm lab : bb, parse("|")
    local lab = substr("`lab'", 2, .)
    quietly summ b if kind == "block" & lab == "`nm'"
    f3 `=r(mean)'
    local a "`r(s)'"
    quietly summ share if kind == "block" & lab == "`nm'"
    fpc `=r(mean)'
    local s "`r(s)'"
    quietly summ N if kind == "block" & lab == "`nm'"
    rv_row "   `lab'" "`a'" "`s'" "`=r(mean)'" "" ""
}
quietly summ share if kind == "one"
rv_row "   One at a time: range of the share explained" "" "`=subinstr(string(100 * r(min), "%4.0f"), "-", uchar(8722), 1)'% to `=string(100 * r(max), "%4.0f")'%" "" "" ""
use "$RINT/q5_checks.dta", clear
rv_row "Bias checks on the full sample (355)" "Coefficient" "Preferred, same observations" "Difference" "Bootstrap p" ""
forvalues i = 1/`=_N' {
    local it = item[`i']
    local lab = cond("`it'" == "gap", "+ output gap in t_p − 1", cond("`it'" == "Lg_f", "+ growth before the period", cond("`it'" == "Lgf_ga", "+ growth before the period + output gap", "Negative-gap interaction: average effect")))
    f3 `=b[`i']'
    local a "`r(s)'"
    f3 `=bT3[`i']'
    local b "`r(s)'"
    f3 `=d[`i']'
    local c "`r(s)'"
    fp `=pboot[`i']'
    rv_row "   `lab'" "`a'" "`b'" "`c'" "`r(s)'" ""
}
use "$RINT/q5_adj.dta", clear
rv_row "Observed minus simulated null [95% CI]" "Null mean, 355" "Observed − null, 355" "Null mean, 311" "Observed − null, 311" ""
forvalues i = 1/`=_N' {
    local d = des[`i']
    local lab = cond("`d'" == "sta", "Mean-reverting design", cond("`d'" == "anc", "Anchored design, unscaled", "Moment-matched calibrated design"))
    f3 `=null355[`i']'
    local a "`r(s)'"
    f3 `=adj355[`i']'
    local x "`r(s)'"
    fci `=lo355[`i']' `=hi355[`i']'
    local b "`x' `r(s)'"
    f3 `=null311[`i']'
    local c "`r(s)'"
    f3 `=adj311[`i']'
    local x "`r(s)'"
    fci `=lo311[`i']' `=hi311[`i']'
    rv_row "   `lab'" "`a'" "`b'" "`c'" "`x' `r(s)'" ""
}
kv4 b2_share_firstrep
local sfr = real("`r(v)'")
rv_out Table_A8_part_drivers, landscape ///
    title("Table A8 (continued). The five-year estimate depends on the first reporting period of each country: dropping those periods explains `=string(100 * `sfr', "%3.0f")'% of the fall from `=subinstr(string(`b355', "%5.2f"), "-", uchar(8722), 1)' to `=subinstr(string(`b311', "%5.2f"), "-", uchar(8722), 1)'") ///
    notes("Preferred five-year specification (wage bill in t_p − 1, controls in t_p − 1, country and period fixed effects, standard errors clustered by country). The 44 country-periods are those of the 355 for which the previous period or the ratios in t_p − 2 and t_p − 3 are missing, so that they drop out of the common sample of the bias checks (311). First reporting period: the first period in which the country has the GFS wage bill in t_p − 1. Differences in means: regression on an indicator of the 44, standard errors clustered by country. Group coefficients: the wage bill interacted with the group indicator; wild cluster bootstrap p of the interaction (Webb weights, 9,999 replications). Share explained: [β(355) − β(355 without the block)] / [β(355) − β(311)]. Full-sample checks: growth before the period is the average growth of period p − 1 or, when that period is missing, the mean annual growth of the five years before t_p (`nrec' country-periods recovered); each variant is compared with the preferred specification on the same observations. Simulated nulls: observed minus the mean of 1,000 simulations of a zero-effect wage bill (mean-reverting design; anchored design with unscaled residuals; anchored design with the moment-matched k of Table A4, panel H, at ε = 0.48); 95% CI from 999 country pairs-bootstrap draws, each re-estimating the observed coefficient and running one new simulation on the resampled countries. Transition economies (former Soviet Union, Central and Eastern Europe, Balkans), periods starting before 1999: 3 of the 355 country-periods (BGR, HUN and SVN 1994); blocks are dropped only among the 44 lost country-periods, so the transition block is one country-period (SVN 1994, N = 354), whereas Table A9 drops all three (N = 352). $ADD")

* =====================================================================================
* Tabela A9: escala comum (Bloco 3)
* =====================================================================================
use "$RINT/esc_res.dta", clear
rv_new, ncol(5) head1("Effect on average growth over five years per point of GDP [95% CI]" "p-value" "Obs." "Countries" "")
rv_row "L. Annual, dynamic and five-year estimates on a common scale" "" "" "" "" ""
forvalues i = 1/`=_N' {
    local it = item[`i']
    if substr("`it'", 1, 4) == "lp_w" | substr("`it'", 1, 4) == "lp_y" continue
    f3 `=b[`i']'
    local x "`r(s)'"
    fci `=lo[`i']' `=hi[`i']'
    local c "`x' `r(s)'"
    if "`it'" == "lp_iv" {
        local ar = ci_note[`i']
        local ar = cond(strpos("`ar'", "entire") | "`ar'" == "", "Anderson-Rubin CI: the whole real line", "Anderson-Rubin CI: `ar'")
        local c "Not identified (first-stage F = `=string(F[`i'], "%5.3f")'); `ar'"
    }
    fp `=p[`i']'
    local pp = cond("`it'" == "lp_iv", "", "`r(s)'")
    local nc = cond(missing(nc[`i']), "", string(nc[`i']))
    rv_row "   `=lab[`i']'" "`c'" "`pp'" "`=string(N[`i'], "%9.0fc")'" "`nc'" ""
}
use "$RINT/esc_tests.dta", clear
rv_row "Compatibility tests (country pairs bootstrap, same draws)" "Difference [95% CI]" "p-value" "" "" ""
forvalues i = 1/`=_N' {
    local pr = pair[`i']
    local lab = cond("`pr'" == "ann − t3", "Annual − five-year (355)", cond("`pr'" == "ann − ww", "Annual − WWBI (registered sample)", cond("`pr'" == "t3 − ww", "Five-year − WWBI", ///
        cond("`pr'" == "lp − t3", "Local projection − five-year (not interpretable: projection not identified)", cond("`pr'" == "ann vs -0.14", "Annual effect − (−0.14)", "Annual effect − (−0.33)")))))
    f3 `=d[`i']'
    local x "`r(s)'"
    local c "`x'"
    if !missing(lo[`i']) {
        fci `=lo[`i']' `=hi[`i']'
        local c "`x' `r(s)'"
    }
    fp `=p[`i']'
    local pc "`r(s)'"
    if "`pr'" == "lp − t3" {
        local lab "Local projection − five-year"
        local c "Not computed: the projection is not identified"
        local pc ""
    }
    rv_row "   `lab'" "`c'" "`pc'" "" "" ""
}
kv4 b3_holm_family
local nf = "`r(v)'"
kv4 b3_holm_p_334
local h334 = real("`r(v)'")
kv4 b3_holm_p_logc
local hlc = real("`r(v)'")
kv4 b3_holm_p_logd
local hld = real("`r(v)'")
rv_row "Holm-adjusted p in the family of `nf' wage-bill coefficients (Tables A9, A10, A15)" "" "" "" "" ""
rv_row "   WWBI registered sample, level (−0.334; unadjusted wild-bootstrap p 0.030)" "" "`=string(`h334', "%5.3f")'" "" "" ""
rv_row "   WWBI registered sample, log (−0.264 per point of GDP; unadjusted 0.076)" "" "`=string(`hlc', "%5.3f")'" "" "" ""
rv_row "   WWBI strict sample, log (−0.294 per point of GDP; unadjusted 0.062)" "" "`=string(`hld', "%5.3f")'" "" "" ""
kv4 b3_annual_incompatible
local inc = real("`r(v)'")
rv_out Table_A9_part_common_scale, landscape ///
    title("Table A9 (continued). On a common scale the annual evidence is imprecise and `=cond(`inc', "incompatible with one of the five-year estimates", "compatible with the five-year estimates")'") ///
    notes("Common object: the effect on average annual growth of real GDP per capita over t_p … t_p + 4 of a wage bill 1 point of GDP higher, maintained from t_p − 1. Annual: Table 1 model (country and year fixed effects, controls of Table 1) with the ratio in t − 1 to t − 5, or their average, on the country-years with five lags; implied effect (1/5) Σ_h e_h with e_h = Σ_{j ≤ h+1} β_j + ρ e_{h−1}, ρ the coefficient on lagged growth; Driscoll-Kraay standard errors and delta-method CI. Local projections: shock (a) of Table A16; average growth over h = 0–4 on the mean response of the wage bill ratio over h = 0–4, instrumented by the shock, Driscoll-Kraay standard errors; with a first-stage effective F below 10 the object is not identified and the Anderson-Rubin CI is reported (standard errors clustered by country). Five-year: preferred specification on 355 and on the common bias sample (311). WWBI: the preferred specification on the registered and strict H2 samples with the GFS wage bill in t_p − 1. Harmonised: the country-periods of the registered H2 sample that are also in the preferred sample, and the annual country-years of those periods. Tests: differences across estimates computed on the same 999 country pairs-bootstrap draws; the annual effect is also tested against −0.14 and −0.33 with its bootstrap standard error. Holm: family of wage-bill coefficients of Tables A9 (subsample rows), A10 (specification rows) and A15 (size panel); bootstrap p where reported. p-values and 95% CIs of the five-year and WWBI rows are from standard errors clustered by country (t distribution); the wild cluster bootstrap p-values of the same coefficients are 0.120 (preferred specification, Table A17), 0.030 and 0.036 (WWBI samples, Table A15). $ADD")

* =====================================================================================
* Tabelas A7 e A6: testes da grade e de Mollick e Cabral (Bloco 4)
* =====================================================================================
use "$RINT/grid_tests.dta", clear
rv_new, ncol(4) head1("Difference" "Bootstrap 95% CI" "Bootstrap p" "Obs.")
foreach c in m1 mean {
    rv_row "Tested differences, `=cond("`c'" == "m1", "controls in t_p − 1", "period-mean controls")'" "" "" "" ""
    forvalues i = 1/`=_N' {
        if ctrl[`i'] != "`c'" continue
        local d = dif[`i']
        * rotulos completos (a variavel dif chega truncada em "(t_p")
        local lab = cond("`d'" == "trend", "Linear trend in timing (slope per step: period mean → t_p → t_p − 1)", ///
            cond("`d'" == "mean − t_p", "Period mean − t_p", cond("`d'" == "t_p − (t_p", "t_p − (t_p − 1)", ///
            cond("`d'" == "mean − (t_p", "Period mean − (t_p − 1)", "`d'"))))
        f3 `=d[`i']'
        local x "`r(s)'"
        fci `=lo[`i']' `=hi[`i']'
        local cc "`r(s)'"
        fp `=p[`i']'
        rv_row "   `lab'" "`x'" "`cc'" "`r(s)'" "`=N[`i']'"
    }
}
kv4 b4_trend_p
local tp = real("`r(v)'")
rv_out Table_A7_rows_grid_tests, title("Table A7 (continued). The coefficient becomes `=cond(`tp' < 0.05, "significantly ", "")'less negative as the wage bill moves out of the period") ///
    notes("Common sample of the grid (349 country-periods). The three measures of the wage bill (period mean, first year t_p, last year of the previous period t_p − 1) are stacked with measure-specific controls and period effects and country × measure fixed effects; differences tested by wild cluster bootstrap by country (Webb weights, 9,999 replications). Linear trend: the contrast (−1, 0, +1) on (period mean, t_p, t_p − 1), divided by two, i.e. the change per step of overlap with the period. $ADD")
use "$RINT/mc5_tests.dta", clear
rv_new, ncol(5) head1("Coefficient" "95% CI" "p-value" "CI" "Obs. (countries)")
foreach pr in 8604 8623 {
    rv_row "Five-year blocks `=cond("`pr'" == "8604", "1986–2004", "1986–2023")'" "" "" "" "" ""
    forvalues i = 1/`=_N' {
        if per[`i'] != "`pr'" continue
        local mm = meas[`i']
        local lab = cond("`mm'" == "lg_p", "ln(G/Y) in t_p − 1", cond("`mm'" == "lg_m", "ln(G/Y), period mean", "Difference t_p − 1 − period mean")) + cond(est[`i'] == "fe", ", fixed effects", ", System GMM, two-step")
        f3 `=b[`i']'
        local x "`r(s)'"
        fci `=lo[`i']' `=hi[`i']'
        local cc "`r(s)'"
        fp `=p[`i']'
        local nc = cond(missing(nc[`i']), "", " (" + string(nc[`i']) + ")")
        rv_row "   `lab'" "`x'" "`cc'" "`r(s)'" "`=ci[`i']'" "`=string(N[`i'], "%9.0f")'`nc'"
    }
}
rv_out Table_A6_rows_five_year_tests, landscape title("Table A6 (continued). Mollick and Cabral: the predetermined five-year coefficient is negative and smaller in absolute value than the period-mean one") ///
    notes("Approximate replication of Mollick and Cabral (2011), five-year blocks: log GDP per capita at the end of the block on its lag, population growth, log investment and log government consumption / GDP measured in the last year of the previous block (t_p − 1) or as the block mean. Fixed effects: country fixed effects, standard errors clustered by country, wild cluster bootstrap CI and p (Webb weights, 9,999 replications). System GMM: two-step, Windmeijer-corrected standard errors, normal CI. Difference: the two measures stacked with measure-specific controls and country × measure fixed effects, wild cluster bootstrap. Panel B differs from these rows in the GMM step and in inference: its System GMM is one-step with robust standard errors (hence the small differences in the coefficients, e.g. −0.072 one-step against −0.068 two-step for the period mean in 1986–2023) and its fixed-effects CIs and stars come from standard errors clustered by country (e.g. t_p − 1 in 1986–2004: −0.078, clustered CI [−0.133; −0.024], wild bootstrap p = 0.081). $ADD")

* =====================================================================================
* Tabelas A12, A13, A14: instituicoes (Bloco 5)
* =====================================================================================
use "$RINT/inst_shares.dta", clear
rv_new, ncol(6) head1("Simulated mean [2.5–97.5]" "Share of the replicated interaction [2.5–97.5]" "Share of the published interaction (−0.811) [2.5–97.5]" "" "" "")
foreach sp in "D|Published specification (replicated same-year interaction −2.326)" "C|Approximate replication registered in the plan (replicated −0.184)" {
    gettoken s lab : sp, parse("|")
    local lab = substr("`lab'", 2, .)
    rv_row "`lab'" "" "" "" "" "" ""
    foreach dd in "anc556G|Anchored (k = 1), ε_0 = 0.556, gradient" "anc556C|Anchored (k = 1), ε_0 = 0.556, no gradient" "anc701G|Anchored (k = 1), ε_0 = 0.701, gradient" "anc701C|Anchored (k = 1), ε_0 = 0.701, no gradient" ///
        "cal556G|k = 0.30, ε_0 = 0.556, gradient" "cal556C|k = 0.30, ε_0 = 0.556, no gradient" "cal701G|k = 0.30, ε_0 = 0.701, gradient" "cal701C|k = 0.30, ε_0 = 0.701, no gradient" ///
        "mm556G|Moment-matched k, ε_0 = 0.556, gradient" "mm556C|Moment-matched k, ε_0 = 0.556, no gradient" "mm701G|Moment-matched k, ε_0 = 0.701, gradient" "mm701C|Moment-matched k, ε_0 = 0.701, no gradient" {
        gettoken d dl : dd, parse("|")
        local dl = substr("`dl'", 2, .)
        quietly count if des == "`d'" & spec == "`s'" & meas == "c"
        if r(N) == 0 continue
        quietly summ mean if des == "`d'" & spec == "`s'" & meas == "c"
        f3 `=r(mean)'
        local x "`r(s)'"
        quietly summ p025 if des == "`d'" & spec == "`s'" & meas == "c"
        local l = r(mean)
        quietly summ p975 if des == "`d'" & spec == "`s'" & meas == "c"
        fci `l' `=r(mean)'
        local c1 "`x' `r(s)'"
        foreach v in share sh_lo sh_hi share_pub shp_lo shp_hi {
            quietly summ `v' if des == "`d'" & spec == "`s'" & meas == "c"
            fpc `=r(mean)'
            local `v' "`r(s)'"
        }
        local c3 = cond("`s'" == "D", "`share_pub' [`shp_lo'; `shp_hi']", "")
        rv_row "   `dl'" "`c1'" "`share' [`sh_lo'; `sh_hi']" "`c3'" "" "" ""
    }
}
kv4 b5_holm_sig
local hs = "`r(v)'"
kv4 b5_kcons
local kc = real("`r(v)'")
rv_row "Panel E: triple-interaction cells significant at 5% after Holm adjustment" "`hs' of 24" "" "" "" "" ""
kv4 b5_share_D_min
local dmin = real("`r(v)'")
kv4 b5_share_D_max
local dmax = real("`r(v)'")
kv4 b5_share_C_min
local cmin = real("`r(v)'")
kv4 b5_share_C_max
local cmax = real("`r(v)'")
rv_out Table_A13_part_null_shares, landscape ///
    title("Table A13 (continued). Across designs, a zero-effect consumption series reproduces `=string(100 * `cmin', "%3.0f")'–`=string(100 * `cmax', "%3.0f")'% of the replicated interaction in the registered specification and `=string(100 * `dmin', "%3.0f")'–`=string(100 * `dmax', "%3.0f")'% in the published one") ///
    notes("Same-year consumption × institutions interaction under the null of no effect of consumption on growth. Synthetic government consumption / GDP anchored on the observed ratio of t − 1, elasticity to nominal GDP ε_it = ε_0 + ε_1 × WGI_i,t−1 (gradient: ε_1 = −0.180; no gradient: ε_1 = 0); drawn residuals multiplied by k: 1 (anchored), 0.30, or the moment-matched k = `=string(`kc', "%4.2f")' (distance of Table A4, panel H, on the within-country SD and AR(1) of the consumption ratio and the replicated interactions with lagged consumption and with consumption over Hamilton trend GDP in the published specification; 200 replications per k). 1,000 replications per design; percentiles of the replication-level share in brackets. Published specification: Mollick and Vianna (2024), Table A12, panel D; approximate replication: Table A12, panel C. Shares relative to the published interaction (−0.811, their Table 2) are shown for the published specification only. Holm: adjustment over the 24 triple-interaction cells of panel E (FE cells: wild bootstrap p; System GMM cells: Windmeijer p). $ADD")
kv4 b5_Ch_obs
local cho = real("`r(v)'")
kv4 b5_Ch_null_min
local cnl = real("`r(v)'")
kv4 b5_Ch_null_max
local cnh = real("`r(v)'")
rv_new, ncol(3) head1("Replicated interaction" "Mean under the null (range across designs)" "")
f3 `cho'
local x "`r(s)'"
f3 `cnl'
local a "`r(s)'"
f3 `cnh'
rv_row "Approximate replication, consumption over Hamilton trend GDP" "`x'***" "`a' to `r(s)'" ""
rv_out Table_A12_rows_trend_null, title("Table A12 (continued). The trend-GDP interaction in the registered specification remains negative and is not reproduced by a zero-effect consumption series") ///
    notes("Table A12, panel C (approximate replication registered in the plan): interaction of consumption over Hamilton trend GDP with the mean WGI index (Driscoll-Kraay standard errors; *** p < 0.01, as in panel C). Null: means of the same interaction across the twelve simulated designs of Table A13 (anchored, k = 0.30 and moment-matched k; ε_0 = 0.556 and 0.701; with and without gradient), 1,000 replications each. $ADD")
use "$RINT/mv_vintage.dta", clear
rv_new, ncol(5) head1("Interaction" "SE (White)" "Replicated / published" "Obs." "Countries")
forvalues i = 1/`=_N' {
    local vv = vint[`i']
    local lab = cond("`vv'" == "current", "WDI current vintage", "WDI vintage " + substr("`vv'", 1, 4) + "-" + substr("`vv'", 5, 2)) + ", " + upper(inst[`i'])
    f3 `=bX[`i']'
    local x "`r(s)'"
    f3 `=seX[`i']'
    rv_row "   `lab'" "`x'" "(`r(s)')" "`=string(ratio[`i'], "%4.2f")'" "`=string(N[`i'], "%9.0fc")'" "`=nc[`i']'"
}
kv4 b5_vintage_available
local va = real("`r(v)'")
kv4 b5_vintage_ratio_min
local vr = real("`r(v)'")
rv_out Table_A14_rows_vintage, landscape ///
    title("Table A14 (continued). `=cond(`va', cond(`vr' < 1.5, "Older WDI vintages bring the replicated interaction close to the published one", "Older WDI vintages do not close the gap with the published interaction"), "WDI vintages: archive not available")'") ///
    notes("Published specification of Mollick and Vianna (2024, Table 2): growth of real GDP on its lag, log government consumption, the institutional indicator, their interaction, log investment and population growth, country and year fixed effects, White standard errors, their 138 listed countries, own sample of each indicator. The WDI series (GDP growth, government consumption, gross capital formation, population growth) are taken from the current vintage or from the December 2022 and December 2023 vintages of the WDI Database Archives (World Bank, source 57); the article does not report the authors' access date. Published interactions: GE −0.811, CC −0.814, RL −0.835. $ADD")

* =====================================================================================
* Figura 1 (tres paineis) e Figura A3 (escala comum); Figura A2 sem nota
* =====================================================================================
use "$RINT/gk_sum.dta", clear
keep if des == "anc"
preserve
keep if meas == "wb"
merge m:1 eps using "$RINT/gk_choice.dta", keepusing(kstar) keep(master match) nogen
gen double shs = 100 * share
gen double shk = shs if abs(k - kstar) < 1e-6
twoway (connected shs k if abs(eps - 0.25) < 1e-6, sort lcolor(gs11) mcolor(gs11) msymbol(Oh)) ///
    (connected shs k if abs(eps - 0.48) < 1e-6, sort lcolor(black) mcolor(black) msymbol(O)) ///
    (connected shs k if abs(eps - 0.52) < 1e-6, sort lcolor(gs7) mcolor(gs7) msymbol(D) lpattern(dash)) ///
    (connected shs k if abs(eps - 0.71) < 1e-6, sort lcolor(gs4) mcolor(gs4) msymbol(T) lpattern(shortdash)) ///
    (scatter shk k, msymbol(Sh) msize(large) mcolor(black)), $GOPT ///
    title("(a) Share of the same-year coefficient", size(9pt)) xtitle("k (scale of the numerator residual)", size(8pt)) ytitle("Simulated / observed (%)", size(8pt)) ///
    xlabel(0(0.25)1, format(%4.2f) labsize(8pt)) legend(order(1 "ε = 0.25" 2 "ε = 0.48" 3 "ε = 0.52" 4 "ε = 0.71" 5 "Chosen k") cols(3) ring(1) pos(6) size(6.5pt) symxsize(5) region(lcolor(none) fcolor(white))) ///
    name(a, replace) nodraw
restore
keep if abs(eps - 0.48) < 1e-6 & inlist(meas, "wb_l1", "wb_ham")
quietly summ bobs if meas == "wb_l1"
local ol = r(mean)
quietly summ bobs if meas == "wb_ham"
local oh = r(mean)
twoway (rarea p025 p975 k if meas == "wb_l1", sort color(gs13)) (connected mean k if meas == "wb_l1", sort lcolor(black) mcolor(black) msymbol(O)) ///
    (rarea p025 p975 k if meas == "wb_ham", sort color(gs14%60)) (connected mean k if meas == "wb_ham", sort lcolor(gs6) mcolor(gs6) msymbol(D) lpattern(dash)), $GOPT ///
    yline(`ol', lcolor(black) lpattern(shortdash)) yline(`oh', lcolor(gs6) lpattern(dot)) ///
    title("(b) Predicted coefficients, ε = 0.48", size(9pt)) xtitle("k", size(8pt)) ytitle("Coefficient", size(8pt)) xlabel(0(0.25)1, format(%4.2f) labsize(8pt)) ///
    legend(order(2 "Lagged ratio" 4 "Ratio over Hamilton trend GDP") cols(1) ring(1) pos(6) size(6.5pt) symxsize(5) region(lcolor(none) fcolor(white))) name(b, replace) nodraw
use "$RINT/inst_mm_draws.dta", clear
keep if spec == "D" & meas == "c" & inlist(des, "mm556G", "mm556C")
append using "$KIN2/siminst_draws.dta"
keep if spec == "D" & meas == "c"
quietly summ b if des == "obs"
local oD = r(mean)
local xl = floor(min(`oD', -2.5))
twoway (kdensity b if des == "mm556G", lcolor(black)) (kdensity b if des == "mm556C", lcolor(black) lpattern(dash)) ///
    (kdensity b if des == "G", lcolor(gs10)) (kdensity b if des == "C", lcolor(gs10) lpattern(dash)), $GOPT ///
    xline(`oD', lcolor(black) lpattern(shortdash)) xline(-0.811, lcolor(gs8) lpattern(dot)) xline(0, lcolor(gs12)) xscale(range(`xl' 0.25)) xlabel(`xl'(1)0, format(%3.0f) labsize(8pt)) ///
    title("(c) Consumption × institutions", size(9pt)) xtitle("Same-year interaction", size(8pt)) ytitle("Density", size(8pt)) ///
    legend(order(1 "Moment-matched, gradient" 2 "Moment-matched, no gradient" 3 "Anchored, gradient" 4 "Anchored, no gradient") cols(2) ring(1) pos(6) size(6.5pt) symxsize(5) region(lcolor(none) fcolor(white))) name(c, replace) nodraw
graph combine a b c, cols(3) graphregion(color(white))
rv_fig Figure_1_simulation, width(190) height(80)

use "$RINT/esc_res.dta", clear
keep if inlist(item, "ann_dl", "ann_ma", "h_ann", "T3_355", "T3_311", "wwbi_c", "wwbi_d", "h_T3")
gen int ord = cond(item == "ann_dl", 1, cond(item == "ann_ma", 2, cond(item == "h_ann", 3, cond(item == "T3_355", 4, cond(item == "T3_311", 5, cond(item == "wwbi_c", 6, cond(item == "wwbi_d", 7, 8)))))))
gen y = 9 - ord
label define fl 8 "Annual, lags t−1 to t−5" 7 "Annual, 5-year average of lags" 6 "Annual, harmonised years" 5 "Five-year, preferred (355)" ///
    4 "Five-year, common bias sample (311)" 3 "WWBI, registered sample" 2 "WWBI, strict sample" 1 "Five-year, harmonised (= WWBI)", replace
label values y fl
twoway (rcap lo hi y, horizontal lcolor(black)) (scatter y b, msymbol(O) mcolor(black)), $GOPT xline(0, lcolor(gs10)) ///
    ylabel(1(1)8, valuelabel angle(horizontal) labsize(7.5pt)) ytitle("") xtitle("Effect on average annual growth over five years per point of GDP (95% CI)", size(8pt)) legend(off) ///
    graphregion(margin(l=2 r=4))
rv_fig Figure_A3_common_scale, width(190) height(90)

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
graph combine i1 i2, cols(2) graphregion(color(white))
rv_fig Figure_A2_influence, width(190) height(80)
log close
