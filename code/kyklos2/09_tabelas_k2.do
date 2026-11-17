* 09_tabelas_k2.do -- tabelas e figura das estimacoes finais (numeracao da versao 4)
* Le os resultados de 01-08 (data/interim/kyklos2) e grava em output/kyklos2/tables e output/kyklos2/figures:
*   Table_A5_simulation (nova Tabela A5), Figure_A3_simulation (nova Figura A3), Table_A11_panel_bias_checks,
*   Table_A15_new_panels, Table_A16_new_rows, Table_A6_new_rows, Table_A17_new_columns, Table_A18_new_panel,
*   Table_A2_panel_B_harmonized. Aplica as regras do Bloco 9 e grava as decisoes em data/interim/kyklos2/kv.csv.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/09_tabelas_k2.log", replace text

capture mata: mata drop _arfmt()
mata:
string scalar _arfmt(string scalar s)
{
    string scalar r, m, out
    real scalar k
    r = s
    out = ""
    while (ustrregexm(r, "-?[0-9]*\.[0-9]+|-?[0-9]+")) {
        m = ustrregexs(0)
        k = strpos(r, m)
        out = out + substr(r, 1, k - 1) + strofreal(strtoreal(m), "%9.3f")
        r = substr(r, k + strlen(m), .)
    }
    out = out + r
    out = subinstr(out, "entire grid", "(" + uchar(8722) + uchar(8734) + ", +" + uchar(8734) + ")")
    out = subinstr(out, "+inf", "+" + uchar(8734))
    out = subinstr(out, " U ", " " + uchar(8746) + " ")
    out = subinstr(out, ",", ";")
    out = subinstr(out, "-", uchar(8722))
    out = stritrim(subinstr(out, "[ ", "["))
    return(out)
}
end
capture program drop f3
program define f3, rclass
    * f3 x -> r(s) com 3 casas e sinal de menos tipografico
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

* =====================================================================================
* Bloco 1: resumo das simulacoes, inclinacao, teste de sanidade, regra
* =====================================================================================
use "$RINT/sim2_draws.dta", clear
preserve
keep if var == "obs"
keep meas b
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
save "$RINT/sim2_sum.dta", replace
kcsv "$RINT/sim2_sum.dta" Table_A5_simulation
* inclinacao da media sobre (1 - eps), replicacao a replicacao
use "$RINT/sim2_draws.dta", clear
keep if inlist(var, "anc", "reg") & inlist(meas, "wb", "wb_ham", "wb_hp1", "wb_l1", "T3")
gen double x = 1 - eps
bysort var meas rep: egen double xm = mean(x)
bysort var meas rep: egen double bm = mean(b)
gen double num = (x - xm) * (b - bm)
gen double den = (x - xm)^2
collapse (sum) num den (count) k = b, by(var meas rep)
keep if k == 5
gen double slope = num / den
bysort var meas: egen double slo = pctile(slope), p(2.5)
bysort var meas: egen double shi = pctile(slope), p(97.5)
collapse (mean) slope (first) slo shi (count) nrs = slope, by(var meas)
list, noobs
save "$RINT/sim2_slope.dta", replace
kcsv "$RINT/sim2_slope.dta" Table_A5_simulation_slopes
* teste de sanidade e regra (adendo 2)
use "$RINT/sim2_slope.dta", clear
quietly summ slope if var == "anc" & meas == "wb"
local sl = r(mean)
quietly summ shi if var == "anc" & meas == "wb"
local slhi = r(mean)
quietly summ slo if var == "anc" & meas == "wb"
local sllo = r(mean)
use "$RINT/sim2_sum.dta", clear
quietly summ mean if var == "anc" & meas == "wb" & eps == 1
local m1 = r(mean)
quietly summ p025 if var == "anc" & meas == "wb" & eps == 1
local l1 = r(mean)
quietly summ p975 if var == "anc" & meas == "wb" & eps == 1
local h1 = r(mean)
quietly summ bobs if meas == "wb"
local bo = r(mean)
quietly summ share if var == "anc" & meas == "wb" & abs(eps - 0.48) < 1e-6
local sh = r(mean)
local san1 = (`sl' < 0 & `slhi' < 0)
local san2 = (abs(`m1') <= 0.10 * abs(`bo') & `l1' <= 0 & `h1' >= 0)
local san = `san1' & `san2'
local rule1 = cond(!`san', "sanity fails", cond(`sh' >= 0.50, "most", cond(`sh' >= 0.20, "substantial", "small")))
rv_kv b1_slope `=string(`sl', "%9.4f")'
rv_kv b1_slope_lo `=string(`sllo', "%9.4f")'
rv_kv b1_slope_hi `=string(`slhi', "%9.4f")'
rv_kv b1_mean_eps1 `=string(`m1', "%9.4f")'
rv_kv b1_sanity_slope `san1'
rv_kv b1_sanity_eps1 `san2'
rv_kv b1_sanity `san'
rv_kv b1_share_048 `=string(`sh', "%9.4f")'
rv_kv b1_rule "`rule1'"
di "Bloco 1: inclinacao `sl' [`sllo'; `slhi']; media em eps = 1: `m1' [`l1'; `h1']; sanidade = `san' (`san1', `san2'); fracao em 0,48 = `sh'; regra: `rule1'"
local pct = string(100 * `sh', "%3.0f")

* ---------------------------------------------------------------- Tabela A5 (nova)
use "$RINT/sim2_sum.dta", clear
merge m:1 var meas using "$RINT/sim2_slope.dta", keep(master match) nogen
save "$RINT/sim2_tab.dta", replace
rv_new, ncol(7) head1("Observed" "ε = 0" "ε = 0.25" "ε = 0.48" "ε = 0.75" "ε = 1" "Slope on 1 − ε")
foreach vv in "anc A. Anchored on the observed ratio of t − 1 (main)" "sta B. Mean-reverting (stationary), ε = 0.48" "reg C. Registered design (random walk in the wage bill), rerun on the same grid" {
    gettoken v ttl : vv
    rv_row "`=strtrim("`ttl'")'" "" "" "" "" "" "" ""
    foreach mm in "wb Annual: same-year ratio" "wb_ham Annual: % of trend GDP (Hamilton)" "wb_hp1 Annual: % of trend GDP (one-sided HP)" "wb_l1 Annual: lagged one year" "T3 Five-year: t_p − 1 (T3)" {
        gettoken m lab : mm
        quietly summ bobs if meas == "`m'"
        f3 `=r(mean)'
        local c0 "`r(s)'"
        local r1 ""
        local r2 ""
        foreach e in 0 0.25 0.48 0.75 1 {
            quietly summ mean if var == "`v'" & meas == "`m'" & abs(eps - `e') < 1e-6
            if r(N) == 0 {
                local r1 `"`r1' """'
                local r2 `"`r2' """'
                continue
            }
            f3 `=r(mean)'
            local r1 `"`r1' "`r(s)'""'
            quietly summ p025 if var == "`v'" & meas == "`m'" & abs(eps - `e') < 1e-6
            local l = r(mean)
            quietly summ p975 if var == "`v'" & meas == "`m'" & abs(eps - `e') < 1e-6
            fci `l' `=r(mean)'
            local r2 `"`r2' "`r(s)'""'
        }
        local s1 ""
        local s2 ""
        quietly summ slope if var == "`v'" & meas == "`m'"
        if r(N) > 0 {
            f3 `=r(mean)'
            local s1 "`r(s)'"
            quietly summ slo if var == "`v'" & meas == "`m'"
            local l = r(mean)
            quietly summ shi if var == "`v'" & meas == "`m'"
            fci `l' `=r(mean)'
            local s2 "`r(s)'"
        }
        rv_row "`=strtrim("`lab'")'" "`c0'" `r1' "`s1'"
        rv_row "" "" `r2' "`s2'"
    }
    * fracao do observado (mesmo ano) e diagnosticos da serie sintetica
    local r1 ""
    foreach e in 0 0.25 0.48 0.75 1 {
        quietly summ share if var == "`v'" & meas == "wb" & abs(eps - `e') < 1e-6
        local r1 `"`r1' "`=cond(r(N) == 0, "", string(100 * r(mean), "%5.0f") + "%")'""'
    }
    rv_row "Share of the observed same-year coefficient" "" `r1' ""
    foreach dd in "sdw Within-country SD of the ratio (points of GDP)" "ar1 AR(1) coefficient of the ratio" "rpl Correlation with the placebo ratio" {
        gettoken d lab : dd
        quietly summ bobs if meas == "`d'"
        f3 `=r(mean)'
        local c0 "`r(s)'"
        local r1 ""
        foreach e in 0 0.25 0.48 0.75 1 {
            quietly summ mean if var == "`v'" & meas == "`d'" & abs(eps - `e') < 1e-6
            if r(N) == 0 local r1 `"`r1' """'
            else {
                f3 `=r(mean)'
                local r1 `"`r1' "`r(s)'""'
            }
        }
        rv_row "`=strtrim("`lab'")'" "`c0'" `r1' ""
    }
    rv_mid
}
use "$RINT/decomp.dta", clear
rv_row "D. Direct decomposition of the observed same-year coefficient (Table 1 model)" "Estimate" "95% CI" "p-value" "Obs." "" "" ""
forvalues i = 1/`=_N' {
    local it = item[`i']
    if inlist("`it'", "cov", "corr", "rpl_obs") {
        f3 `=b[`i']'
        rv_row "`=lab[`i']'" "`r(s)'" "" "" "`=string(N[`i'], "%9.0fc")'" "" "" ""
        continue
    }
    f3 `=b[`i']'
    local x "`r(s)'"
    fci `=lo[`i']' `=hi[`i']'
    local c "`r(s)'"
    fp `=p[`i']'
    rv_row "`=lab[`i']'" "`x'" "`c'" "`r(s)'" "`=string(N[`i'], "%9.0fc")'" "" "" ""
}
kget "$RINT/kv.csv" sim2_rho
local rho = real("`r(v)'")
local san_txt = cond(`san', "passes", "fails")
local ttl = cond(`san', "Table A5. A zero-effect wage bill anchored on the observed ratio reproduces `pct'% of the same-year coefficient", ///
    "Table A5. Simulated null: the anchored design does not pass the sanity check, so the share of the same-year coefficient it reproduces is not informative")
rv_out Table_A5_simulation, landscape title("`ttl'") ///
    notes("Simulation under the null that the wage bill has no effect on growth. Observed GDP, growth and controls are kept and only the wage bill ratio s = W/Y is replaced by a synthetic series. A (main): ln s_sim,t = ln s_obs,t−1 − (1 − ε) Δln Y_t + u_t, with Δln Y the observed growth of nominal GDP and u drawn with replacement from the country's own values of Δln s_obs + (1 − ε) Δln Y, recentred to zero within country. B: ln s_sim,t = μ_i + ρ (ln s_sim,t−1 − μ_i) − (1 − ε) Δln Y_t + u_t, with ρ = `=string(`rho', "%5.3f")' (within-country AR(1) of the observed log ratio), μ_i the country mean and u from the country's recentred residuals; ε = 0.48. C: design of the earlier version of this table (random walk in ln W from the country's first observed year, u from Δln W − ε Δln Y, not recentred), rerun on the same grid of ε. 1,000 replications per ε and design. In each replication the annual regressions of Table 1 (1996–2023, controls of Table 1, country and year fixed effects, Table 1 sample) and T3 (five-year averages, controls in t_p − 1, country and period fixed effects, T3 sample) are re-estimated with the synthetic series. Cells: mean of the simulated coefficients and, below, their 2.5–97.5 percentiles. Slope: OLS slope of the simulated mean on 1 − ε, with the 2.5–97.5 percentiles of the slope computed replication by replication. Sanity check (registered in the second plan addendum): in A, the slope of the same-year coefficient is negative with an interval that excludes zero, and at ε = 1 the mean is within 10% of the observed coefficient in absolute value with an interval that contains zero; the anchored design `san_txt' it. Within-country SD, AR(1) (pooled OLS on the lag) and correlation with the placebo ratio: means over replications, Table 1 sample. D: the same-year ratio replaced by its three log components (×100), estimated jointly; covariance and correlation of the numerator innovation with growth after removing country and year effects; regressions of 100 × Δln W on real growth, with country and year fixed effects; Driscoll-Kraay standard errors (maximum lag 3). The coefficient on nominal GDP growth in D is mechanically positive because real growth, the dependent variable, is part of nominal growth. $EXPL")

* ---------------------------------------------------------------- Figura A3 (nova)
use "$RINT/sim2_tab.dta", clear
keep if inlist(var, "anc", "sta", "reg") & inlist(meas, "wb", "T3")
gen double x = 1 - eps
gen double xr = x + 0.015
foreach m in wb T3 {
    quietly summ bobs if meas == "`m'"
    local o`m' = r(mean)
}
local yl = floor(10 * min(`owb', -0.8)) / 10
twoway (rcap p025 p975 x if var == "anc" & meas == "wb", lcolor(black)) (connected mean x if var == "anc" & meas == "wb", lcolor(black) mcolor(black) msymbol(O)) ///
    (rcap p025 p975 xr if var == "reg" & meas == "wb", lcolor(gs9)) (scatter mean xr if var == "reg" & meas == "wb", mcolor(gs9) msymbol(Oh)) ///
    (scatter mean x if var == "sta" & meas == "wb", mcolor(gs5) msymbol(T)) ///
    (function y = `owb' * x / 0.52, range(0 `=min(1, 0.52 * 1.0 / abs(`owb'))') lcolor(gs6) lpattern(dot)), ///
    $GOPT yline(`owb', lcolor(black) lpattern(dash)) yline(0, lcolor(gs12)) xscale(range(-0.03 1.05)) xlabel(0(0.25)1, format(%4.2f) labsize(8pt)) ///
    yscale(range(-1.05 0.15)) ylabel(-1(0.25)0, format(%4.2f)) title("(a) Annual, same-year ratio", size(9pt)) xtitle("1 − ε", size(8pt)) ytitle("Coefficient", size(8pt)) ///
    legend(order(2 "Anchored (95% interval)" 4 "Registered design" 5 "Mean-reverting" 6 "Full-accounting ray") cols(1) ring(0) pos(7) size(6.5pt) symxsize(6) region(lcolor(none) fcolor(white))) name(a, replace) nodraw
twoway (rcap p025 p975 x if var == "anc" & meas == "T3", lcolor(black)) (connected mean x if var == "anc" & meas == "T3", lcolor(black) mcolor(black) msymbol(O)) ///
    (rcap p025 p975 xr if var == "reg" & meas == "T3", lcolor(gs9)) (scatter mean xr if var == "reg" & meas == "T3", mcolor(gs9) msymbol(Oh)) ///
    (scatter mean x if var == "sta" & meas == "T3", mcolor(gs5) msymbol(T)), ///
    $GOPT yline(`oT3', lcolor(black) lpattern(dash)) yline(0, lcolor(gs12)) xscale(range(-0.03 1.05)) xlabel(0(0.25)1, format(%4.2f) labsize(8pt)) ///
    ylabel(, format(%4.2f)) title("(b) Five-year, t{sub:p} − 1 (T3)", size(9pt)) xtitle("1 − ε", size(8pt)) ytitle("Coefficient", size(8pt)) legend(off) name(b, replace) nodraw
use "$RINT/siminst_draws.dta", clear
keep if spec == "D" & meas == "c"
quietly summ b if des == "obs"
local oD = r(mean)
local xl = floor(min(`oD', -2.5))
twoway (kdensity b if des == "G", lcolor(black)) (kdensity b if des == "C", lcolor(gs8) lpattern(dash)), $GOPT ///
    xline(`oD', lcolor(black) lpattern(shortdash)) xline(0, lcolor(gs12)) xscale(range(`xl' 0.25)) xlabel(`xl'(1)0, format(%3.0f) labsize(8pt)) ///
    title("(c) Consumption × institutions", size(9pt)) xtitle("Interaction, same-year consumption", size(8pt)) ytitle("Density", size(8pt)) ///
    legend(order(1 "Elasticity gradient" 2 "No gradient (control)") cols(1) ring(0) pos(11) size(6.5pt) symxsize(6) region(lcolor(none) fcolor(white))) name(c, replace) nodraw
graph combine a b c, cols(3) graphregion(color(white)) ///
    note("Panels (a) and (b): simulated mean against 1 − ε; dashed line: observed coefficient; dotted ray: coefficient proportional to 1 − ε through the observed value at ε = 0.48." ///
    "Panel (c): distribution of the simulated same-year interaction (1,000 replications per design); short-dashed line: observed interaction.", size(6.5pt))
rv_fig Figure_A3_simulation, width(190) height(85)

* =====================================================================================
* Bloco 2: Tabela A11, painel novo
* =====================================================================================
use "$RINT/vies_res.dta", clear
kcsv "$RINT/vies_res.dta" Table_A11_panel_bias_checks
local allin = 1
local anysig = 0
local mainlow = 0
local chan ""
foreach it in i1 i2a i2b i3 i4 {
    quietly summ b if item == "`it'"
    local bb = r(mean)
    quietly summ pboot if item == "`it'"
    local pp = r(mean)
    if `bb' < -0.20 | `bb' > -0.08 local allin = 0
    if `pp' < 0.05 local anysig = 1
    if inlist("`it'", "i1", "i2a", "i2b", "i4") & `bb' < -0.20 & `pp' < 0.05 {
        local mainlow = 1
        local chan "`chan' `it'"
    }
}
local r2a = (`allin' & !`anysig')
use "$RINT/vies_gd.dta", clear
quietly summ est if stat == "gd"
local gd = r(mean)
quietly summ lo if stat == "gd"
local gdl = r(mean)
quietly summ hi if stat == "gd"
local gdh = r(mean)
local signed = (`gdl' > 0 | `gdh' < 0)
local sgn = cond(`gd' < 0, "negative", "positive")
quietly summ est if stat == "ovb"
local ovb = r(mean)
quietly summ lo if stat == "ovb"
local ovbl = r(mean)
quietly summ hi if stat == "ovb"
local ovbh = r(mean)
rv_kv b2_allin `allin'
rv_kv b2_anysig `anysig'
rv_kv b2_mainlow `mainlow'
rv_kv b2_signed `signed'
rv_kv b2_rule `=cond(`r2a', "does not depend", cond(`mainlow', "moderate cost", "keep text"))'
di "Bloco 2: todas em [-0,20; -0,08] = `allin'; alguma p < 0,05 = `anysig'; principal abaixo de -0,20 com p < 0,05 = `mainlow' (`chan'); sinal (gamma x delta) = `gd' [`gdl'; `gdh'] -> assinado = `signed'"
use "$RINT/vies_res.dta", clear
quietly summ b if inlist(item, "i1", "i2a", "i2b", "i3", "i4")
local bmin = string(r(min), "%4.2f")
local bmax = string(r(max), "%4.2f")
local bmin = subinstr("`bmin'", "-", uchar(8722), 1)
local bmax = subinstr("`bmax'", "-", uchar(8722), 1)
rv_new, ncol(6) head1("Wage-bill coefficient" "Bootstrap 95% CI" "Bootstrap p" "T3, same observations" "Obs." "Countries")
rv_row "Bias checks for the predetermined estimate" "" "" "" "" "" ""
forvalues i = 1/`=_N' {
    local it = item[`i']
    if inlist("`it'", "a7", "a7g") continue
    f3 `=b[`i']'
    local x "`r(s)'"
    fci `=blo[`i']' `=bhi[`i']'
    local c "`r(s)'"
    fp `=pboot[`i']'
    local pp "`r(s)'"
    f3 `=bT3s[`i']'
    rv_row "`=lab[`i']'" "`x'" "`c'" "`pp'" "`r(s)'" "`=string(N[`i'], "%9.0fc")'" "`=nc[`i']'"
    if "`it'" == "i4" {
        local ar = ar[`i']
        mata: st_local("ar", _arfmt(st_local("ar")))
        rv_row "   2SLS diagnostics: effective F (Montiel Olea–Pflueger); Hansen J p; Anderson-Rubin 95% CI" "`=string(Feff[`i'], "%6.1f")'" "`=string(Jp[`i'], "%5.3f")'" "`ar'" "" "" ""
    }
}
forvalues i = 1/`=_N' {
    local it = item[`i']
    if !inlist("`it'", "a7", "a7g") continue
    f3 `=b[`i']'
    local x "`r(s)'"
    fci `=blo[`i']' `=bhi[`i']'
    local c "`r(s)'"
    fp `=pboot[`i']'
    rv_row "`=lab[`i']'" "`x'" "`c'" "`r(s)'" "" "`=string(N[`i'], "%9.0fc")'" "`=nc[`i']'"
}
rv_mid
use "$RINT/vies_gelbach.dta", clear
rv_row "Gelbach (2016) decomposition of β(T3) − β(T3 + growth of p − 1 + gap), common sample" "Component" "SE" "" "" "Obs." ""
forvalues i = 1/`=_N' {
    local lab = cond(comp[`i'] == "gG", "Growth of p − 1", cond(comp[`i'] == "gH", "Output gap in t_p − 1", "Total change"))
    f3 `=d[`i']'
    local x "`r(s)'"
    f3 `=se[`i']'
    rv_row "   `lab'" "`x'" "(`r(s)')" "" "" "`=string(N[`i'], "%9.0fc")'" ""
}
use "$RINT/vies_gd.dta", clear
rv_row "Implied omitted-variable bias (country cluster bootstrap)" "Estimate" "95% CI" "" "" "Obs." "Replications"
foreach ss in "ga γ: growth of p on growth of p − 1 (within)" "de δ: ratio in t_p − 1 on growth of p − 1 (within)" "gd γ × δ" "ovb γ_long × π (bias in units of β)" "dif Observed difference β(T3) − β(T3 + growth of p − 1)" {
    gettoken s lab : ss
    quietly summ est if stat == "`s'"
    f3 `=r(mean)' %12.4f
    local x "`r(s)'"
    quietly summ lo if stat == "`s'"
    local l = r(mean)
    quietly summ hi if stat == "`s'"
    fci `l' `=r(mean)' %12.4f
    local c "`r(s)'"
    quietly summ N if stat == "`s'"
    local nn = r(mean)
    quietly summ nrep if stat == "`s'"
    rv_row "   `=strtrim("`lab'")'" "`x'" "`c'" "" "" "`=string(`nn', "%9.0fc")'" "`=string(r(mean), "%9.0fc")'"
}
quietly summ nrep if stat == "gd"
local nrgd = r(mean)
local ttl "Table A11 (new panel). Bias checks for the predetermined estimate: controlling for past growth, the output gap or instrumenting leaves the wage-bill coefficient between `bmin' and `bmax'"
rv_out Table_A11_panel_bias_checks, landscape title("`ttl'") ///
    notes("All rows except the last two: T3 specification (growth of real GDP per capita, five-year averages, wage bill in t_p − 1, controls in t_p − 1, country and period fixed effects) in the T3 sample, with the variable named in the row added. Output gap: 100 × (log real GDP − Hamilton trend, H = 2, k = 2) in t_p − 1. Growth of p − 1: lagged five-year average growth (LSDV, Nickell bias not corrected); rows with it lose the first period of each country. Negative-gap rows: the wage-bill coefficient after a positive gap, the interaction, and their sum. 2SLS: the ratio in t_p − 1 instrumented by the annual ratios in t_p − 2 and t_p − 3, country and period fixed effects, T3 controls, standard errors clustered by country; WRE wild bootstrap. Bootstrap: wild cluster bootstrap by country, Webb weights, 9,999 replications (p for T3 differs slightly from Table A9 because the bootstrap seed differs). T3, same observations: T3 re-estimated on the observations of the row. Annual rows: Table 1 model (1996–2023, controls of Table 1, country and year fixed effects) with the ratio in t − 1 over Hamilton trend GDP in t − 1; coefficient with wild cluster bootstrap by country. Gelbach (2016): contribution of each added variable to the change in the wage-bill coefficient, standard errors clustered by country. γ × δ: product of the within regressions of growth in p and of the ratio in t_p − 1 on growth in p − 1 (country and period fixed effects); γ_long × π: the coefficient on growth of p − 1 in T3 + growth of p − 1 times the coefficient of the wage bill in a regression of growth of p − 1 on the wage bill and the T3 controls, which equals the observed change; 95% intervals from a country-pairs bootstrap (`=string(`nrgd', "%5.0f")' replications). $EXPL")

* =====================================================================================
* Blocos 3 e 4: Tabela A15, paineis novos
* =====================================================================================
use "$RINT/opra_triple.dta", clear
quietly summ pboot if split == "m" & smp == "all" & meas == "gc_mean" & est == "fe"
local po = r(mean)
quietly summ b if split == "m" & smp == "all" & meas == "gc_mean" & est == "fe"
local bo3 = r(mean)
local r3 = cond(`po' < 0.05, "specific", "not different")
rv_kv b3_opra_rule2 "`r3'"
use "$RINT/siminst_sum.dta", clear
quietly summ shareG if spec == "D" & meas == "c"
local shG = r(mean)
quietly summ shareC if spec == "D" & meas == "c"
local shC = r(mean)
quietly summ share_net if spec == "D" & meas == "c"
local shN = r(mean)
quietly summ ctrl0 if spec == "D" & meas == "c"
local c0 = r(mean)
local r4 = cond(`shG' >= 0.50 & `c0', "explains", cond(`shN' >= 0.20, "part", "too small"))
rv_kv b4_rule2 "`r4'"
kget "$RINT/kv.csv" b4_eps0
local e0 = real("`r(v)'")
kget "$RINT/kv.csv" b4_eps1
local e1 = real("`r(v)'")
use "$RINT/opra_triple.dta", clear
rv_new, ncol(6) head1("Triple interaction" "95% CI" "p-value" "Interaction, early" "Interaction, late" "Obs. (countries)")
rv_row "E. Oto-Peralías and Romero-Ávila: consumption × institutions × later period (ICRG/QoG, five-year panel 1981–2020)" "" "" "" "" "" ""
local k_1 "m"
local s_1 "all"
local l_1 "Later period 2006–2020, all countries"
local k_2 "m"
local s_2 "both"
local l_2 "Later period 2006–2020, countries in both periods"
local k_3 "r"
local s_3 "all"
local l_3 "Later period 1996–2020 (overlap assigned to the later period)"
local k_4 "r"
local s_4 "both"
local l_4 "Later period 1996–2020, countries in both periods"
forvalues q = 1/4 {
    local sp "`k_`q''"
    local sm "`s_`q''"
    local lab "`l_`q''"
    foreach m in gc_mean gc_tp gc_m1 {
        foreach e in fe sgmm {
            quietly count if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'" & !missing(b)
            if r(N) == 0 continue
            quietly summ b if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
            f3 `=r(mean)'
            local x "`r(s)'"
            if "`e'" == "fe" {
                quietly summ blo if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
                local l = r(mean)
                quietly summ bhi if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
                fci `l' `=r(mean)'
                local c "`r(s)'"
                quietly summ pboot if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
                fp `=r(mean)'
                local pp "`r(s)'"
            }
            else {
                quietly summ b if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
                local bb = r(mean)
                quietly summ se if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
                fci `=`bb' - 1.96 * r(mean)' `=`bb' + 1.96 * r(mean)'
                local c "`r(s)'"
                quietly summ p if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
                fp `=r(mean)'
                local pp "`r(s)'"
            }
            quietly summ bE if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
            f3 `=r(mean)'
            local cE "`r(s)'"
            quietly summ bL if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
            f3 `=r(mean)'
            local cL "`r(s)'"
            quietly summ N if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
            local nn = r(mean)
            quietly summ nc if split == "`sp'" & smp == "`sm'" & meas == "`m'" & est == "`e'"
            local mlab = cond("`m'" == "gc_mean", "period mean", cond("`m'" == "gc_tp", "t_p", "t_p − 1"))
            rv_row "   `lab'; `mlab'; `=cond("`e'" == "fe", "FE", "System GMM")'" "`x'" "`c'" "`pp'" "`cE'" "`cL'" "`=string(`nn', "%9.0fc")' (`=r(mean)')"
        }
    }
}
rv_mid
use "$RINT/siminst_sum.dta", clear
rv_row "F. Interaction under the null: synthetic consumption with an elasticity gradient (ε_it = `=string(`e0', "%5.3f")' `=cond(`e1' < 0, uchar(8722), "+")' `=string(abs(`e1'), "%5.3f")' × WGI_t−1)" "Observed" "Simulated mean, gradient [2.5–97.5]" "Share" "Simulated mean, no gradient [2.5–97.5]" "Share" "Net share"
foreach k in "D|c|Published specification: same-year consumption" "D|l|Published specification: lagged consumption" "D|h|Published specification: % of trend GDP" "C|c|Approximate replication: same-year consumption" "C|l|Approximate replication: lagged consumption" "C|h|Approximate replication: % of trend GDP" {
    gettoken s k : k, parse("|")
    gettoken bar k : k, parse("|")
    gettoken m k : k, parse("|")
    gettoken bar lab : k, parse("|")
    quietly summ bobs if spec == "`s'" & meas == "`m'"
    f3 `=r(mean)'
    local c0 "`r(s)'"
    foreach d in G C {
        quietly summ mean`d' if spec == "`s'" & meas == "`m'"
        f3 `=r(mean)'
        local x "`r(s)'"
        quietly summ p025`d' if spec == "`s'" & meas == "`m'"
        local l = r(mean)
        quietly summ p975`d' if spec == "`s'" & meas == "`m'"
        fci `l' `=r(mean)'
        local m`d' "`x' `r(s)'"
        quietly summ share`d' if spec == "`s'" & meas == "`m'"
        local s`d' = cond("`m'" == "c", subinstr(string(100 * r(mean), "%5.0f"), "-", uchar(8722), 1) + "%", "—")
    }
    quietly summ share_net if spec == "`s'" & meas == "`m'"
    local sN = cond("`m'" == "c", subinstr(string(100 * r(mean), "%5.0f"), "-", uchar(8722), 1) + "%", "—")
    rv_row "   `lab'" "`c0'" "`mG'" "`sG'" "`mC'" "`sC'" "`sN'"
}
local t3 = cond("`r3'" == "specific", "the mitigation is specific to 1981–2005", "the mitigation does not differ significantly between periods")
local t4 = cond("`r4'" == "explains", "the elasticity gradient explains the annual amplification", cond("`r4'" == "part", "the elasticity gradient explains part of the annual amplification", "the elasticity gradient adds little to the annual amplification"))
rv_out Table_A15_new_panels, landscape title("Table A15 (new panels). Institutional tests: `t3'; `t4'") ///
    notes("Panel E: five-year averages aligned to 1981 (1981–1985 to 2016–2020), each period once; growth of real GDP per capita on government consumption (% of GDP, WDI) G, G × ICRG/QoG, G × later period, G × ICRG/QoG × later period, ICRG/QoG, ICRG/QoG × later period, initial log GDP per capita, secondary enrolment and investment, with period effects. The windows of Table A14 (1981–2005 and 1996–2020) overlap in 1996–2005: in the main split the later period is 2006–2020; in the alternative split the overlap is assigned to the later period (1996–2020). FE: country and period fixed effects, wild cluster bootstrap by country (Webb weights, 9,999 replications) for the CI and p of the triple interaction. System GMM: specification of Table A14, panel A, with the added interactions instrumented like G × ICRG (lags 2 and deeper, collapsed), two-step, Windmeijer-corrected standard errors, normal 95% CI. Interaction, early and late: G × ICRG/QoG in the earlier and in the later period. Panel F: government consumption / GDP replaced by an anchored synthetic series with no effect on growth, ln c_sim,t = ln c_obs,t−1 − (1 − ε_it) Δln nominal GDP_t + u_t, with ε_it = ε_0 + ε_1 × WGI_i,t−1, ε_0 = `=string(`e0', "%5.3f")' and ε_1 = `=subinstr(string(`e1', "%5.3f"), "-", uchar(8722), 1)' from the mechanism panel of this table (nominal growth of government consumption on nominal GDP growth × WGI, mean of the six indicators centred at its 1996–2023 mean, interpolated within country), and u drawn from the country's recentred values; the control sets the gradient to zero. 1,000 replications per design. Published specification: Table A14, panel D (Mollick and Vianna, 2024, GE, common sample of the three measures); approximate replication: Table A14, panel C. Share: simulated mean over the observed interaction; net share: (gradient mean − control mean) over the observed interaction; shares are shown only for the same-year interaction, because the lagged and trend-GDP interactions are close to zero and their ratios are not meaningful. $EXPL")

* =====================================================================================
* Bloco 3: Tabela A16, linhas novas
* =====================================================================================
use "$RINT/mv_ci.dta", clear
rv_new, ncol(7) head1("Interaction" "95% CI, White" "95% CI, clustered" "Published" "CI excludes published" "Equivalent to published (±0.5; ±1.0)" "Equivalent to zero (±0.5; ±1.0)")
rv_row "C. Mollick and Vianna (2024), published specification: lagged and trend-GDP interactions against the published interaction" "" "" "" "" "" "" ""
foreach i in ge cc rl {
    foreach m in lgy lgy_l1 lgy_ham {
        quietly summ b if inst == "`i'" & meas == "`m'" & vce == "robust"
        f3 `=r(mean)'
        local x "`r(s)'"
        quietly summ lo95 if inst == "`i'" & meas == "`m'" & vce == "robust"
        local l = r(mean)
        quietly summ hi95 if inst == "`i'" & meas == "`m'" & vce == "robust"
        fci `l' `=r(mean)'
        local cw "`r(s)'"
        quietly summ lo95 if inst == "`i'" & meas == "`m'" & vce == "cluster"
        local l = r(mean)
        quietly summ hi95 if inst == "`i'" & meas == "`m'" & vce == "cluster"
        fci `l' `=r(mean)'
        local cc "`r(s)'"
        quietly summ bpub if inst == "`i'" & meas == "`m'" & vce == "cluster"
        f3 `=r(mean)'
        local bp "`r(s)'"
        quietly summ excl if inst == "`i'" & meas == "`m'" & vce == "cluster"
        local ex = cond(r(mean), "Yes", "No")
        quietly summ tost_p05 if inst == "`i'" & meas == "`m'" & vce == "cluster"
        local a = cond(r(mean), "Yes", "No")
        quietly summ tost_p10 if inst == "`i'" & meas == "`m'" & vce == "cluster"
        local eqp "`a'; `=cond(r(mean), "Yes", "No")'"
        quietly summ tost_z05 if inst == "`i'" & meas == "`m'" & vce == "cluster"
        local a = cond(r(mean), "Yes", "No")
        quietly summ tost_z10 if inst == "`i'" & meas == "`m'" & vce == "cluster"
        local eqz "`a'; `=cond(r(mean), "Yes", "No")'"
        quietly summ N if inst == "`i'" & meas == "`m'" & vce == "cluster"
        local mlab = cond("`m'" == "lgy", "same year (reference)", cond("`m'" == "lgy_l1", "lagged one year", "% of trend GDP (Hamilton)"))
        rv_row "   `=upper("`i'")', `mlab'" "`x'" "`cw'" "`cc'" "`bp'" "`ex'" "`eqp'" "`eqz'"
    }
}
quietly summ N if inst == "ge" & vce == "cluster"
local nmv = r(mean)
quietly summ excl if inst == "ge" & meas == "lgy_l1" & vce == "cluster"
local exg = r(mean)
local t16 = cond(`exg', "the lagged interaction is significantly smaller than the published one", "the lagged interaction is imprecise and cannot be distinguished from the published one")
rv_out Table_A16_new_rows, landscape title("Table A16 (new rows). With the published specification, `t16'") ///
    notes("Specification of Table A16, panel C (Mollick and Vianna, 2024, Table 2): growth of real GDP on its lag, log government consumption, the institutional indicator, their interaction, log investment and population growth, country and year fixed effects, 1996–2019, their 138 countries, common sample of the three measures of consumption for each indicator (`=string(`nmv', "%9.0fc")' observations with GE). Interaction: coefficient on log consumption × indicator. 95% CIs with heteroskedasticity-robust (White) and country-clustered standard errors. Published: the full-period interaction of Mollick and Vianna (2024, Table 2): GE −0.811, CC −0.814, RL −0.835. CI excludes published: the clustered 95% CI does not contain the published value. Equivalence (two one-sided tests at 5%, i.e. the clustered 90% CI inside the margin) to the published value (|b − published| < 0.5 or 1.0) and to zero (|b| < 0.5 or 1.0). $EXPL")

* =====================================================================================
* Bloco 5: Tabela A6, linhas novas
* =====================================================================================
use "$RINT/fy_dif.dta", clear
quietly count if smp == "excl" & inlist(dif, "ham", "lag") & d < 0 & p < 0.01
local k5 = (r(N) == 2)
kget "$RINT/kv.csv" b5_nfy_countries
local lnfy = subinstr("`r(v)'", "_", ", ", .)
kget "$RINT/kv.csv" b5_realg_countries
local lrea = subinstr("`r(v)'", "_", ", ", .)
rv_new, ncol(5) head1("Coefficient" "95% CI" "p-value" "Obs." "Countries")
use "$RINT/fy_res.dta", clear
foreach sm in "excl Fiscal-year countries excluded" "real Fiscal years realigned" {
    gettoken s lab : sm
    rv_row "`=strtrim("`lab'")'" "" "" "" "" ""
    foreach mm in "wb Annual: same-year ratio" "wb_ham Annual: % of trend GDP (Hamilton)" "wb_hp1 Annual: % of trend GDP (one-sided HP)" "wb_l1 Annual: lagged one year" "wb_mean Five-year: period mean" "wb_m1 Five-year: t_p − 1, conventional controls" "T3 Five-year: T3" {
        gettoken m ml : mm
        quietly summ b if smp == "`s'" & m == "`m'"
        local bb = r(mean)
        quietly summ p if smp == "`s'" & m == "`m'"
        local pp = r(mean)
        rv_fmt `bb' %12.3f `pp'
        local x "`r(s)'"
        quietly summ lo if smp == "`s'" & m == "`m'"
        local l = r(mean)
        quietly summ hi if smp == "`s'" & m == "`m'"
        fci `l' `=r(mean)'
        local c "`r(s)'"
        fp `pp'
        local p3 "`r(s)'"
        quietly summ N if smp == "`s'" & m == "`m'"
        local nn = r(mean)
        quietly summ nc if smp == "`s'" & m == "`m'"
        rv_row "   `=strtrim("`ml'")'" "`x'" "`c'" "`p3'" "`=string(`nn', "%9.0fc")'" "`=r(mean)'"
    }
}
use "$RINT/fy_dif.dta", clear
rv_row "Tested differences (stacked models, wild cluster bootstrap)" "Difference" "95% CI (bootstrap)" "Bootstrap p" "" ""
foreach kk in "excl|ham|Excluded: same year − Hamilton" "excl|lag|Excluded: same year − lagged" "real|ham|Realigned: same year − Hamilton" "real|lag|Realigned: same year − lagged" "ex-f|wb|Excluded − full sample: same year" "ex-f|wb_ham|Excluded − full sample: Hamilton" "ex-f|wb_l1|Excluded − full sample: lagged" "ex-f|T3|Excluded − full sample: T3" {
    gettoken s kk : kk, parse("|")
    gettoken bar kk : kk, parse("|")
    gettoken dd kk : kk, parse("|")
    gettoken bar lab : kk, parse("|")
    quietly summ d if smp == "`s'" & dif == "`dd'"
    local x = r(mean)
    quietly summ p if smp == "`s'" & dif == "`dd'"
    local pp = r(mean)
    rv_fmt `x' %12.3f `pp'
    local xs "`r(s)'"
    quietly summ lo if smp == "`s'" & dif == "`dd'"
    local l = r(mean)
    quietly summ hi if smp == "`s'" & dif == "`dd'"
    fci `l' `=r(mean)'
    local c "`r(s)'"
    fp `pp'
    rv_row "   `lab'" "`xs'" "`c'" "`r(s)'" "" ""
}
local t6 = cond(`k5', "the same-year bias survives the exclusion and the realignment of fiscal years", "excluding or realigning fiscal years changes the same-year comparison")
rv_out Table_A6_new_rows, landscape title("Table A6 (new rows). Fiscal years: `t6'") ///
    notes("Countries whose general government reporting year does not start in January according to the IMF World Economic Outlook database (October 2026, attribute 'start/end months of reporting year' of general government expenditure); in the Table 1 sample: `lnfy'. Whether the GFS wage bill of these countries is converted to calendar years is not reported in the GFS metadata and could not be verified. Excluded: Table 1 (annual and five-year rows, their models and controls) and T3 re-estimated without these countries. Realigned: for fiscal years starting between April and September (`lrea'), the calendar-year ratio is the month-weighted average of the two fiscal years that overlap the calendar year, assuming each fiscal year is labelled by the calendar year that holds most of its months; measures over trend GDP and five-year measures are recomputed from the realigned ratio. Annual rows: Driscoll-Kraay standard errors; five-year rows: standard errors clustered by country. Differences: measures (or full and restricted samples) stacked with measure- or sample-specific fixed effects, controls and year effects; wild cluster bootstrap by country (Webb weights, 9,999 replications). $EXPL * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Bloco 6: Tabela A17, colunas novas
* =====================================================================================
use "$RINT/h2r_res.dta", clear
quietly count if smp == "H" & inlist(spec, "m1", "m2", "m3") & pboot < 0.05
local k6 = (r(N) == 3)
kget "$RINT/kv.csv" b6_rw_reg
local rwr = real("`r(v)'")
kget "$RINT/kv.csv" b6_rw_m1
local rw1 = real("`r(v)'")
kget "$RINT/kv.csv" b6_rw_m2
local rw2 = real("`r(v)'")
rv_new, ncol(7) head1("Log model" "(1) + growth of p − 1" "(2) + gap in t_p − 1" "(1) and (2)" "(3) GDP per worker of the year before the pair" "Wage bill held fixed" "(4) Wage bill fixed, (1) and (2)")
foreach sm in "H Registered sample (Table 3, column 3)" "S Strict timing sample (pairs in t_p − 1 to t_p − 4)" {
    gettoken s lab : sm
    rv_row "`=strtrim("`lab'")'" "" "" "" "" "" "" ""
    local r1 ""
    local r2 ""
    local r3 ""
    local r4 ""
    foreach sp in base m1 m2 m12 m3 m4base m4 {
        quietly summ b if smp == "`s'" & spec == "`sp'"
        f3 `=r(mean)'
        local r1 `"`r1' "`r(s)'""'
        quietly summ blo if smp == "`s'" & spec == "`sp'"
        local l = r(mean)
        quietly summ bhi if smp == "`s'" & spec == "`sp'"
        fci `l' `=r(mean)'
        local r2 `"`r2' "`r(s)'""'
        quietly summ pboot if smp == "`s'" & spec == "`sp'"
        fp `=r(mean)'
        local r3 `"`r3' "`r(s)'""'
        quietly summ N if smp == "`s'" & spec == "`sp'"
        local nn = r(mean)
        quietly summ nc if smp == "`s'" & spec == "`sp'"
        local r4 `"`r4' "`=string(`nn', "%9.0fc")' (`=r(mean)')""'
    }
    rv_row "   Log relative public wage" `r1'
    rv_row "   Bootstrap 95% CI" `r2'
    rv_row "   Bootstrap p" `r3'
    rv_row "   Obs. (countries)" `r4'
}
rv_row "Romano-Wolf p of H2 in the registered family (999 country draws)" "`=string(`rwr', "%5.3f")'" "`=string(`rw1', "%5.3f")'" "`=string(`rw2', "%5.3f")'" "" "" "" ""
local t17 = cond(`k6', "H2 survives the reverse-denominator check", "H2 is sensitive to the reverse-denominator channel")
rv_out Table_A17_new_columns, landscape title("Table A17 (new columns). `t17'") ///
    notes("Dependent variable: growth of real GDP per capita (five-year averages). Log model: log public employment and log relative public wage (WWBI pair closest to t_p − 1), controls in t_p − 1, country and period fixed effects (Table 3, column 3, and Table A17). (1): plus the lagged five-year average growth rate. (2): plus the output gap in t_p − 1 (100 × log real GDP minus Hamilton trend). (3): the relative wage divided by real GDP per worker (real GDP over total employment) of the year before the pair instead of the pair year. (4): log relative wage with the log wage bill (% of GDP) held fixed. Coefficient on the log relative public wage (in (3), on the relative wage of (3)); wild cluster bootstrap by country (Webb weights, 9,999 replications). Romano-Wolf: the registered family of Table A19 with the H2 estimate replaced by the model of the column (robustness only; the registered verdict does not change). $EXPL")

* =====================================================================================
* Bloco 7: Tabela A18, painel novo
* =====================================================================================
kget "$RINT/kv.csv" b7_T3_b
local bT3 = real("`r(v)'")
kget "$RINT/kv.csv" b7_T3_lo90
local lT3 = real("`r(v)'")
kget "$RINT/kv.csv" b7_T3_hi90
local hT3 = real("`r(v)'")
use "$RINT/lp2_res.dta", clear
quietly summ b if shock == "sa" & kind == "th5"
local th = r(mean)
local k7 = (`th' >= `lT3' & `th' <= `hT3')
rv_new, ncol(7) head1("Wage-bill response, shock (a)" "Multiplier, shock (a)" "F, (a)" "Multiplier, shock (b)" "F, (b)" "Multiplier, shock (c)" "F, (c)")
rv_row "C. Cumulative effects (Ramey–Zubairy integral multiplier, LP-IV)" "" "" "" "" "" "" ""
forvalues h = 0/6 {
    quietly summ b if shock == "sa" & kind == "resp" & h == `h'
    f3 `=r(mean)'
    local x "`r(s)'"
    quietly summ lo if shock == "sa" & kind == "resp" & h == `h'
    local l = r(mean)
    quietly summ hi if shock == "sa" & kind == "resp" & h == `h'
    fci `l' `=r(mean)'
    local c1 "`x' `r(s)'"
    foreach s in sa sb sc {
        quietly summ b if shock == "`s'" & kind == "mult" & h == `h'
        f3 `=r(mean)' %12.2f
        local x "`r(s)'"
        quietly summ lo if shock == "`s'" & kind == "mult" & h == `h'
        local l = r(mean)
        quietly summ hi if shock == "`s'" & kind == "mult" & h == `h'
        fci `l' `=r(mean)' %12.2f
        local m_`s' "`x' `r(s)'"
        quietly summ F if shock == "`s'" & kind == "mult" & h == `h'
        local F_`s' = string(r(mean), "%6.1f")
    }
    rv_row "   h = `h'" "`c1'" "`m_sa'" "`F_sa'" "`m_sb'" "`F_sb'" "`m_sc'" "`F_sc'"
}
local r1 ""
foreach s in sa sb sc {
    quietly summ b if shock == "`s'" & kind == "th5"
    f3 `=r(mean)' %12.2f
    local x "`r(s)'"
    quietly summ lo if shock == "`s'" & kind == "th5"
    local l = r(mean)
    quietly summ hi if shock == "`s'" & kind == "th5"
    fci `l' `=r(mean)' %12.2f
    local t_`s' "`x' `r(s)'"
    quietly summ F if shock == "`s'" & kind == "th5"
    local G_`s' = string(r(mean), "%6.1f")
}
rv_row "Average effect on annual growth over five years per point of GDP of wage bill maintained (θ/5)" "" "`t_sa'" "`G_sa'" "`t_sb'" "`G_sb'" "`t_sc'" "`G_sc'"
f3 `bT3'
local x "`r(s)'"
fci `lT3' `hT3'
rv_row "T3 (five-year estimate) and 90% CI" "`x' `r(s)'" "" "" "" "" "" ""
local t18 = cond(`k7', "the dynamic and five-year estimates agree", "the dynamic estimate is too imprecise to compare with the five-year estimate")
rv_out Table_A18_new_panel, landscape title("Table A18 (new panel). Cumulative effects: `t18'") ///
    notes("Shocks (a), (b) and (c) of Table A18; annual panel 1996–2023, country and year fixed effects, two lags of the shock and of growth. Wage-bill response: change in the wage bill (% of GDP) from t − 2 to t + h on shock (a), dated t − 1; Driscoll-Kraay 95% CI. Multiplier: cumulative change in log real GDP per capita (×100, from t − 1, summed over horizons 0 to h) on the cumulative change in the wage bill (points of GDP, from t − 2 for shock (a) and from t − 1 for shocks (b) and (c), summed over 0 to h), instrumented by the shock (LP-IV, Ramey and Zubairy, 2018); Driscoll-Kraay standard errors (bandwidth 4) and normal 95% CI; shock (b) is a generated regressor and its CIs are percentiles of a country block bootstrap that redoes the purge (999 replications; its standard error is the interquartile range of the bootstrap draws divided by 1.349, because draws with a near-zero first stage produce extreme ratios). F: Kleibergen-Paap robust first-stage F (one instrument); values below 10 indicate a weak instrument, and the multipliers and their CIs are then unreliable. θ/5: coefficient of the change in log GDP per capita (×100) from t − 1 to t + 5 on the mean change of the wage bill over h = 0–5, instrumented by the shock, divided by 5 (delta-method CI); dividing by 6, the number of growth years, gives values five-sixths as large. T3: the five-year coefficient (−0.142) and its 90% CI. $EXPL")
rv_kv b7_rule2 `=cond(`k7', "agree", "discrepancy")'

* =====================================================================================
* Bloco 8: Tabela A2, painel B na amostra exata da Tabela 1 (harmoniza 0,97 x 0,98)
* =====================================================================================
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1991, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
keep if sA
capture program drop descrow
program define descrow
    args v lab
    quietly summ `v', detail
    local m = r(mean)
    local sd = r(sd)
    local med = r(p50)
    local mn = r(min)
    local mx = r(max)
    local n = r(N)
    tempvar mi w
    quietly bysort id: egen double `mi' = mean(`v')
    quietly gen double `w' = `v' - `mi'
    quietly summ `mi' if !missing(`v')
    local sdb = r(sd)
    quietly summ `w'
    local sdw = r(sd)
    foreach x in m sd sdb sdw med mn mx {
        rv_fmt ``x'' %12.2f
        local f`x' "`r(s)'"
    }
    rv_row "`lab'" "`fm'" "`fsd'" "`fsdb'" "`fsdw'" "`fmed'" "`fmn'" "`fmx'" "`=string(`n', "%9.0fc")'"
end
rv_new, ncol(8) head1("Mean" "SD total" "SD between" "SD within" "Median" "Min" "Max" "N")
rv_row "B. Annual panel, Table 1 sample" "" "" "" "" "" "" "" ""
descrow g "GDP per capita growth (%)"
descrow wb "Wage bill, general government (% of GDP)"
descrow wb_ham "Wage bill (% of trend GDP, Hamilton)"
descrow wb_hp1 "Wage bill (% of trend GDP, one-sided HP)"
descrow d_wagebill_real "Real wage bill shock (% of lagged GDP)"
descrow rev_gdp "Total revenue (% of GDP)"
descrow balance_gdp "Fiscal balance (% of GDP)"
descrow infl "Inflation (%)"
rv_out Table_A2_panel_B_harmonized, landscape title("Table A2 (panel B, harmonized). Descriptive statistics, annual panel, exact Table 1 sample") ///
    notes("Panel B of Table A2 recomputed on the 1,621 country-years of Table 1 (the earlier panel B used 1,593 country-years, a sample that differs from Table 1 by 28 country-years, which is why its within-country SD of the wage bill, 0.97, differed from the 0.98 reported in Table A5). SD between: standard deviation of country means; SD within: standard deviation after removing country means. Cleaning rules as in Table A2.")
log close
