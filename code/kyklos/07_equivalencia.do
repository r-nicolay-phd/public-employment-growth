* 07_equivalencia.do -- Bloco 7: limites de equivalencia (TOST), efeito minimo detectavel e influencia em T3
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/07_equivalencia.log", replace text

tempname E
postfile `E' str8 spec double(b se df lo90 hi90 lo95 hi95 dmin mde) long(N nc) using "$RINT/equiv.dta", replace
* folha defasada no painel anual (modelo e amostra da Tabela 1)
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1991, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
xtscc g wb_l1 $XA i.year if sA, fe lag($DKLAG)
local b = _b[wb_l1]
local se = _se[wb_l1]
local df = e(df_r)
local t90 = invttail(`df', 0.05)
local t95 = invttail(`df', 0.025)
post `E' ("annlag") (`b') (`se') (`df') (`b' - `t90' * `se') (`b' + `t90' * `se') (`b' - `t95' * `se') (`b' + `t95' * `se') ///
    (max(abs(`b' - `t90' * `se'), abs(`b' + `t90' * `se'))) ((1.96 + 0.84) * `se') (e(N)) (e(N_g))
* T3
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
local b = _b[wb_m1]
local se = _se[wb_m1]
local df = e(df_r)
local t90 = invttail(`df', 0.05)
local t95 = invttail(`df', 0.025)
post `E' ("T3") (`b') (`se') (`df') (`b' - `t90' * `se') (`b' + `t90' * `se') (`b' - `t95' * `se') (`b' + `t95' * `se') ///
    (max(abs(`b' - `t90' * `se'), abs(`b' + `t90' * `se'))) ((1.96 + 0.84) * `se') (e(N)) (e(N_clust))
postclose `E'

* ---------------------------------------------------------------- influencia em T3
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
keep if e(sample)
local b0 = _b[wb_m1]
* paises com folha das GFS ate 2000
preserve
use "$KIN/anual_rv.dta", clear
keep if !missing(wagebill_gdp)
collapse (min) y1 = year, by(id)
tempfile ent
save `ent'
restore
merge m:1 id using `ent', keep(master match) nogen
gen byte early = y1 <= 2000
gen byte trans = inlist(iso3, "ARM", "AZE", "BLR", "EST", "GEO", "KAZ", "KGZ", "LVA", "LTU") | ///
    inlist(iso3, "MDA", "RUS", "TJK", "TKM", "UKR", "UZB", "BGR", "CZE", "HUN") | ///
    inlist(iso3, "POL", "ROU", "SVK", "SVN", "ALB", "HRV", "BIH", "SRB", "MNE") | inlist(iso3, "MKD", "XKX")
save "$RINT/infl_base.dta", replace
tempname F
postfile `F' str12 kind str20 lab double(b se p lo hi) long(N nc) using "$RINT/influencia.dta", replace
capture program drop infl1
program define infl1
    args F kind lab cond
    quietly reghdfe g wb_m1 $XP i.period if `cond', absorb(id) vce(cluster id)
    local b = _b[wb_m1]
    local se = _se[wb_m1]
    local df = e(df_r)
    post `F' ("`kind'") ("`lab'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
        (`b' + invttail(`df', 0.025) * `se') (e(N)) (e(N_clust))
end
infl1 `F' base "T3" "1"
infl1 `F' trans "Excl. transition < 1999" "!(trans & year0 < 1999)"
infl1 `F' covid "Excl. 2019-2023" "year0 != 2019"
infl1 `F' early "Excl. 1979-1993" "year0 >= 1994"
infl1 `F' gfs2000 "GFS data by 2000" "early"
levelsof id, local(cs)
foreach c of local cs {
    quietly levelsof iso3 if id == `c', local(iso) clean
    infl1 `F' loo_c "`iso'" "id != `c'"
}
levelsof year0, local(ps)
foreach p of local ps {
    infl1 `F' loo_p "`p'" "year0 != `p'"
}
postclose `F'
* selecao pela cobertura: renda, merito e divida em t_p - 1, entrada cedo x tarde
tempname S
postfile `S' str10 v double(m_early m_late d p) long(N) using "$RINT/selecao.dta", replace
foreach v in lny0 merit_m1 debt_m1 {
    capture confirm variable `v'
    if _rc continue
    quietly regress `v' early, vce(cluster id)
    local d = _b[early]
    local p = 2 * ttail(e(df_r), abs(_b[early] / _se[early]))
    quietly summ `v' if early == 1
    local me = r(mean)
    quietly summ `v' if early == 0
    post `S' ("`v'") (`me') (r(mean)) (`d') (`p') (e(N))
}
postclose `S'

* =====================================================================================
* regra (adendo, Bloco 7), Tabela S25 e Figura S8
* =====================================================================================
use "$RINT/equiv.dta", clear
list, noobs
kcsv "$RINT/equiv.dta" TabS25_equivalence
quietly summ dmin if spec == "T3"
local dT3 = r(mean)
local eq10 = (`dT3' < 0.10)
rv_kv eq_T3_dmin `=string(`dT3', "%9.4f")'
rv_kv eq_T3_eq10 `eq10'
quietly summ dmin if spec == "annlag"
rv_kv eq_annlag_dmin `=string(r(mean), "%9.4f")'
quietly summ lo95 if spec == "T3"
local l95 = r(mean)
quietly summ hi95 if spec == "T3"
local h95 = r(mean)
rv_kv eq_T3_cut3_lo `=string(-3 * `h95', "%9.4f")'
rv_kv eq_T3_cut3_hi `=string(-3 * `l95', "%9.4f")'
di "Bloco 7: menor limite de equivalencia para T3 = `dT3'; equivalencia a 0,10 = `eq10'"
local ttl = cond(`eq10', "The data rule out wage bill effects larger than 0.1 points of growth per point of GDP", ///
    "The data neither support nor rule out moderate wage bill effects")
rv_new, ncol(6) head1("Coefficient" "90% CI" "Equivalence at ±0.05" "at ±0.10" "at ±0.20" "Smallest bound; MDE (80%)")
foreach s in annlag T3 {
    quietly summ b if spec == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local c1 "`r(s)'"
    quietly summ lo90 if spec == "`s'"
    local l = r(mean)
    rv_fmt `l' %12.3f
    local ls "`r(s)'"
    quietly summ hi90 if spec == "`s'"
    local h = r(mean)
    rv_fmt `h' %12.3f
    local c2 "[`ls'; `r(s)']"
    local e05 = cond(`l' > -0.05 & `h' < 0.05, "Yes", "No")
    local e10 = cond(`l' > -0.10 & `h' < 0.10, "Yes", "No")
    local e20 = cond(`l' > -0.20 & `h' < 0.20, "Yes", "No")
    quietly summ dmin if spec == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local dm "`r(s)'"
    quietly summ mde if spec == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local lab = cond("`s'" == "annlag", "Annual panel, wage bill lagged one year (Driscoll-Kraay)", "Five-year T3 (clustered)")
    rv_row "`lab'" "`c1'" "`c2'" "`e05'" "`e10'" "`e20'" "`dm'; `r(s)'"
}
rv_fmt `=-3 * `h95'' %12.3f
local a "`r(s)'"
rv_fmt `=-3 * `l95'' %12.3f
rv_row "T3: annual growth effect of cutting the wage bill by 3 points of GDP (95% CI limits)" "[`a'; `r(s)']" "" "" "" "" ""
rv_mid
use "$RINT/influencia.dta", clear
kcsv "$RINT/influencia.dta" TabS25_influence
foreach k in base trans covid early gfs2000 {
    quietly summ b if kind == "`k'"
    local b = r(mean)
    quietly summ p if kind == "`k'"
    rv_fmt `b' %12.3f `=r(mean)'
    local x "`r(s)'"
    quietly summ lo if kind == "`k'"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if kind == "`k'"
    rv_fmt `=r(mean)' %12.3f
    local h "`r(s)'"
    quietly summ N if kind == "`k'"
    local n = r(mean)
    quietly summ nc if kind == "`k'"
    local lab = cond("`k'" == "base", "T3, full sample", cond("`k'" == "trans", "Excluding transition economies before 1999", ///
        cond("`k'" == "covid", "Excluding 2019–2023", cond("`k'" == "early", "Excluding 1979–1993", "Countries with GFS data by 2000"))))
    rv_row "`lab'" "`x'" "[`l'; `h']" "N = `=string(`n', "%9.0fc")'" "`=r(mean)' countries" "" ""
}
foreach k in loo_c loo_p {
    quietly summ b if kind == "`k'"
    local mn = r(min)
    local mx = r(max)
    quietly summ b if kind == "`k'" & b == `mn'
    levelsof lab if kind == "`k'" & abs(b - `mn') < 1e-9, local(lmn) clean
    levelsof lab if kind == "`k'" & abs(b - `mx') < 1e-9, local(lmx) clean
    quietly count if kind == "`k'" & p < 0.05
    local ns = r(N)
    quietly count if kind == "`k'"
    local nt = r(N)
    rv_fmt `mn' %12.3f
    local a "`r(s)'"
    rv_fmt `mx' %12.3f
    local lab = cond("`k'" == "loo_c", "Leave one country out: range (country)", "Leave one period out: range (period start)")
    rv_row "`lab'" "`a' (`lmn')" "`r(s)' (`lmx')" "p < 0.05 in `ns' of `nt'" "" "" ""
}
rv_mid
use "$RINT/selecao.dta", clear
kcsv "$RINT/selecao.dta" TabS25_selection
forvalues i = 1/`=_N' {
    local lab = cond(v[`i'] == "lny0", "Log GDP per capita", cond(v[`i'] == "merit_m1", "Meritocratic recruitment", "Public debt (% of GDP)"))
    rv_fmt `=m_early[`i']' %12.2f
    local a "`r(s)'"
    rv_fmt `=m_late[`i']' %12.2f
    local c "`r(s)'"
    rv_fmt `=d[`i']' %12.2f `=p[`i']'
    rv_row "Selection, t_p − 1: `lab' (early; late; difference)" "`a'" "`c'" "`r(s)'" "" "" ""
}
rv_out TabS25_equivalence, landscape ///
    title("Table S25. `ttl'") ///
    notes("Equivalence: two one-sided tests at 5% (90% CI) for the wage bill lagged one year in the annual model of Table 1 (1996–2023, Driscoll-Kraay standard errors) and for T3 (five-year averages, wage bill and controls in t_p − 1, country and period fixed effects, clustered standard errors). Equivalence at ±δ holds if the 90% CI lies within (−δ, δ); smallest bound: the smallest symmetric δ at which equivalence holds; MDE: minimum detectable effect at 5% and 80% power, (1.96 + 0.84) × SE. The growth effect of a 3-point cut is −3 × the 95% CI limits of T3. Influence: T3 re-estimated without the listed observations; transition economies: former Soviet Union, Central and Eastern Europe and the Balkans, periods starting before 1999; GFS data by 2000: countries whose general government wage bill starts in 2000 or earlier. Selection: means in the T3 sample of countries with GFS data by 2000 (early) and later (late), difference with standard errors clustered by country. All leave-one-out coefficients in Figure S8. Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")

* Figura S8: deixar um pais ou um periodo de fora
use "$RINT/influencia.dta", clear
quietly summ b if kind == "base"
local b0 = r(mean)
quietly summ lo if kind == "base"
local l0 = r(mean)
quietly summ hi if kind == "base"
local h0 = r(mean)
keep if inlist(kind, "loo_c", "loo_p")
gsort kind b
by kind: gen r = _n
twoway (rcap lo hi r if kind == "loo_c", lcolor(gs10)) (scatter b r if kind == "loo_c", msymbol(O) mcolor(black) msize(vsmall)), ///
    $GOPT yline(`b0', lcolor(black) lpattern(dash)) yline(0, lcolor(gs10) lpattern(shortdash)) xlabel(none) xtitle("Country left out (ranked)", size(8pt)) ///
    ytitle("T3 coefficient (95% CI)", size(8pt)) title("(a) Leave one country out", size(9pt)) legend(off) name(i1, replace) nodraw
twoway (rcap lo hi r if kind == "loo_p", lcolor(gs10)) (scatter b r if kind == "loo_p", msymbol(D) mcolor(black) msize(small)), ///
    $GOPT yline(`b0', lcolor(black) lpattern(dash)) yline(0, lcolor(gs10) lpattern(shortdash)) xlabel(none) xtitle("Period left out (ranked)", size(8pt)) ///
    ytitle("") title("(b) Leave one period out", size(9pt)) legend(off) name(i2, replace) nodraw
graph combine i1 i2, cols(2) graphregion(color(white)) note("Dashed line: full-sample T3 coefficient.", size(7pt))
rv_fig FigS8_influence, width(190) height(80)
log close
