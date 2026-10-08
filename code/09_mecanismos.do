* 09_mecanismos.do -- Bloco E (H4): investimento privado, PTF e emprego privado; Tabela 5 e Figura A3
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
do "$ROOT/code/00_lp.do"
log using "$LOG/09_mecanismos.log", replace text

global X5 "lny0 hc0 inv open infl popg ctot_g"
global X5noinv "lny0 hc0 open infl popg ctot_g"

* ---------------------------------------------------------------- E1-E3 na especificacao A1 (medias de 5 anos)
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
xtset id period
* investimento privado e resultado: o investimento total sai dos controles para nao condicionar no canal
reghdfe ipriv wagebill_gdp0 $X5noinv, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store E1
reghdfe tfp_g wagebill_gdp0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store E2
reghdfe privemp_g wagebill_gdp0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store E3

* ---------------------------------------------------------------- E1-E3 na especificacao D1 (projecoes locais)
use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
xtset id year
gen tfp100 = 100 * ln(rtfpna)
gen pemp100 = 100 * ln(privemp)
lpirf, y(ipriv) shocks(d_wagebill_real) saving("$INTERIM/lp_E1.dta") h(6) cond(inrange(year, 1996, 2023))
lpirf, y(tfp100) shocks(d_wagebill_real) saving("$INTERIM/lp_E2.dta") h(6) cond(inrange(year, 1996, 2023))
lpirf, y(pemp100) shocks(d_wagebill_real) saving("$INTERIM/lp_E3.dta") h(6) cond(inrange(year, 1996, 2023))

* ---------------------------------------------------------------- Tabela 5
local stars "* p<0.10, ** p<0.05, *** p<0.01."
tab_new, ncol(3) head1("(1)" "(2)" "(3)") head2("Private investment" "TFP growth" "Private employment growth")
tab_row "Panel A. Five-year averages (specification A1)" "" "" ""
tab_est E1 E2 E3, keep(wagebill_gdp0)
tab_stat N "Observations"
tab_stat nc "Countries"
tab_stat r2w "R2 (within)" %5.3f
tab_mid
tab_row "Panel B. Local projections (specification D1): cumulative response to a real wage bill shock of 1% of GDP" "" "" ""
foreach hh in 0 2 4 6 {
    local rb ""
    local rs ""
    foreach e in E1 E2 E3 {
        preserve
        use "$INTERIM/lp_`e'.dta", clear
        quietly keep if h == `hh'
        local b = b[1]
        local se = se[1]
        local N = N[1]
        local df = df[1]
        restore
        local p = 2 * ttail(`df', abs(`b' / `se'))
        local st = cond(`p' < 0.01, "***", cond(`p' < 0.05, "**", cond(`p' < 0.10, "*", "")))
        local bs : display %6.3f `b'
        local ss : display %6.3f `se'
        local rb `"`rb' "`=strtrim("`bs'")'`st'""'
        local rs `"`rs' "(`=strtrim("`ss'")')""'
        local n_`e' `N'
    }
    tab_row "Horizon h = `hh'" `rb'
    tab_row "" `rs'
}
tab_row "Observations (h = 0)" "`n_E1'" "`n_E2'" "`n_E3'"
tab_out Table5_mechanisms, title("Table 5. Mechanisms: private investment, productivity and private employment") ///
    notes("Panel A: five-year averages, country and period fixed effects, standard errors clustered by country; the wage bill (% of GDP) is measured in the first year of the period; controls as in Table 2 (investment excluded in column 1, where private investment is the outcome). Outcomes: private gross fixed capital formation (% of GDP, IMF ICSD, available to 2019), TFP growth (PWT 11.0, rtfpna), growth of private employment (total minus public employment from the same ILOSTAT survey). Panel B: annual local projections, 1996-2023: response at horizon h of the outcome level (private investment in p.p. of GDP; 100 x log TFP; 100 x log private employment) relative to t-1, to a real wage bill increase of 1% of lagged GDP, with two lags of the shock and of GDP per capita growth, country and year fixed effects and Driscoll-Kraay standard errors. `stars'")

* ---------------------------------------------------------------- Figura A3: projecoes locais dos mecanismos
local i = 0
foreach e in E1 E2 E3 {
    local ++i
    local t : word `i' of "(a) Private investment (p.p. of GDP)" "(b) TFP (%)" "(c) Private employment (%)"
    use "$INTERIM/lp_`e'.dta", clear
    twoway (rarea lo hi h, color("$C2%25") lwidth(none)) (connected b h, lcolor("$C2") mcolor("$C2") msymbol(O) lpattern(solid)), ///
        $GOPT yline(0, lcolor(gs10) lpattern(dash)) legend(off) xlabel(0(1)6) ///
        xtitle("Years after the shock", size(8pt)) ytitle("") title("`t'", size(8pt) color(black) pos(11)) ///
        name(m`i', replace) nodraw
}
graph combine m1 m2 m3, cols(3) graphregion(color(white)) imargin(small)
fig_export FigureA3_lp_mechanisms, width(190) height(70)

foreach m in E1 E2 E3 {
    estimates restore `m'
    estimates save "$LOG/est_`m'", replace
}
log close
