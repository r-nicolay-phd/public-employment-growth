* 08_dinamica.do -- Bloco D: projecoes locais (D1-D3) e vies do denominador (D4); Figuras 3, 5 e 6; Tabela A7
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
do "$ROOT/code/00_lp.do"
log using "$LOG/08_dinamica.log", replace text

use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
xtset id year
gen y100 = 100 * lny
label var y100 "100 x log GDP per capita"

* ---------------------------------------------------------------- D1. resposta do PIB per capita ao choque de folha
lpirf, y(y100) shocks(d_wagebill_real) saving("$INTERIM/lp_D1.dta") h(6) cond(inrange(year, 1996, 2023))

* ---------------------------------------------------------------- D2. emprego x salario relativo
lpirf, y(y100) shocks(d_wb_emp d_wb_wage) saving("$INTERIM/lp_D2.dta") h(6) cond(inrange(year, 1996, 2023))

* ---------------------------------------------------------------- D3. dependencia de estado: merito alto x baixo
* estado definido pelo merito no ano anterior ao choque, contra a mediana da amostra de D1
gen byte smp = !missing(d_wagebill_real, L.d_wagebill_real, L2.d_wagebill_real, L.g, L2.g) & inrange(year, 1996, 2023)
quietly summ merit_l1 if smp, detail
local med = r(p50)
gen byte merit_hi = merit_l1 > `med' if !missing(merit_l1)
di "D3: mediana de merit_l1 na amostra = " `med'
lpirf, y(y100) shocks(d_wagebill_real) state(merit_hi) saving("$INTERIM/lp_D3.dta") h(6) cond(inrange(year, 1996, 2023))

* ---------------------------------------------------------------- D4. vies do denominador: comparacao direta
* mesma especificacao anual (EF de pais e ano, crescimento defasado e controles, Driscoll-Kraay), trocando
* so a medida da folha; e, nas medias de 5 anos, media do periodo contra valor inicial
local Xa "L.g L.lny hc inv open infl popg ctot_g"
preserve
keep if inrange(year, 1996, 2023)
gen wb_contemp = wagebill_gdp
gen wb_cyc_hp = wagebill_cyc
gen wb_cyc_ham = wagebill_cyc_ham
gen wb_lag = L.wagebill_gdp
* mesma amostra para todas as medidas anuais
gen byte s4 = !missing(wb_contemp, wb_cyc_hp, wb_cyc_ham, wb_lag, g, L.g, L.lny, hc, inv, open, infl, popg, ctot_g)
foreach v in wb_contemp wb_cyc_hp wb_cyc_ham wb_lag {
    xtscc g `v' `Xa' i.year if s4, fe
    estadd scalar nc = e(N_g)
    estimates store D4_`v'
}
restore
preserve
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
xtset id period
gen wb_mean5 = wagebill_gdp
gen wb_init5 = wagebill_gdp0
gen byte s5 = !missing(wb_mean5, wb_init5, g, lny0, hc0, inv, open, infl, popg, ctot_g)
foreach v in wb_mean5 wb_init5 {
    reghdfe g `v' lny0 hc0 inv open infl popg ctot_g if s5, absorb(id period) vce(cluster id)
    estadd scalar nc = e(N_clust)
    estimates store D4_`v'
}
restore
* dados da Figura 3 e Tabela A7
tempname F
postfile `F' str20 spec str60 label double(b se lo hi) int(N nc) using "$INTERIM/d4.dta", replace
local i = 0
foreach v in wb_contemp wb_cyc_hp wb_cyc_ham wb_lag wb_mean5 wb_init5 {
    local ++i
    estimates restore D4_`v'
    local lab : word `i' of "Annual: contemporaneous ratio" "Annual: % of trend GDP (HP)" "Annual: % of trend GDP (Hamilton)" "Annual: lagged one year" "5-year: period mean" "5-year: first year of period"
    local df = e(df_r)
    post `F' ("`v'") ("`lab'") (_b[`v']) (_se[`v']) (_b[`v'] - invttail(`df', 0.025) * _se[`v']) ///
        (_b[`v'] + invttail(`df', 0.025) * _se[`v']) (e(N)) (e(nc))
}
postclose `F'

* ---------------------------------------------------------------- Tabela A7 (D4)
capture program drop postd4
program define postd4, eclass
    args b V df N nc
    ereturn post `b' `V', dof(`df')
    ereturn scalar N = `N'
    ereturn scalar nc = `nc'
    ereturn local cmd "d4table"
end
local stars "* p<0.10, ** p<0.05, *** p<0.01."
foreach v in wb_contemp wb_cyc_hp wb_cyc_ham wb_lag wb_mean5 wb_init5 {
    estimates restore D4_`v'
    * renomeia o coeficiente para uma linha comum
    matrix b = e(b)
    matrix V = e(V)
    local cn : colnames b
    local cn : subinstr local cn "`v'" "wagebill_gdp", word
    matrix colnames b = `cn'
    matrix rownames V = `cn'
    matrix colnames V = `cn'
    local N = e(N)
    local nc = e(nc)
    local df = e(df_r)
    postd4 b V `df' `N' `nc'
    estimates store T_`v'
}
global LBL_wagebill_gdp "Wage bill measure (coefficient)"
tab_new, ncol(6) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
    head2("Contemporaneous" "Trend GDP (HP)" "Trend GDP (Hamilton)" "Lagged" "Period mean" "First year")
tab_est T_wb_contemp T_wb_cyc_hp T_wb_cyc_ham T_wb_lag T_wb_mean5 T_wb_init5, keep(wagebill_gdp)
tab_mid
tab_row "Panel" "Annual" "Annual" "Annual" "Annual" "5-year" "5-year"
tab_row "Standard errors" "Driscoll-Kraay" "Driscoll-Kraay" "Driscoll-Kraay" "Driscoll-Kraay" "Cluster" "Cluster"
tab_stat N "Observations"
tab_stat nc "Countries"
tab_out TableA7_denominator, title("Table A7. The denominator bias: same model, different timing of the wage bill") landscape ///
    notes("Dependent variable: growth of real GDP per capita (%). Columns 1-4: annual panel 1996-2023, same sample in all columns, country and year fixed effects, lagged growth, lagged log GDP per capita, human capital, investment, openness, inflation, population growth and commodity terms-of-trade growth; Driscoll-Kraay standard errors. Column 1: wage bill as % of current GDP; columns 2-3: wage bill as % of trend GDP (HP filter with lambda = 6.25; Hamilton filter with h = 2, p = 2); column 4: wage bill as % of GDP lagged one year. Columns 5-6: five-year averages with country and period fixed effects and the controls of Table 2, same sample; standard errors clustered by country. `stars'")

* =====================================================================================
* Figuras
* =====================================================================================
* Figura 3: vies do denominador
use "$INTERIM/d4.dta", clear
gen pos = 7 - _n
gen yl = label
twoway (rcap lo hi pos, horizontal lcolor("$C2") lwidth(medthin)) ///
       (scatter pos b if _n <= 4, msymbol(O) mcolor("$C1") msize(medsmall)) ///
       (scatter pos b if _n > 4, msymbol(D) mcolor("$C5") msize(medsmall)), ///
       $GOPT xline(0, lcolor(gs10) lpattern(dash)) legend(off) ///
       ylabel(6 "Annual: contemporaneous" 5 "Annual: % of trend GDP (HP)" 4 "Annual: % of trend GDP (Hamilton)" ///
              3 "Annual: lagged one year" 2 "5-year: period mean" 1 "5-year: first year", angle(0) labsize(8pt) nogrid) ///
       ytitle("") xtitle("Effect of 1 p.p. of GDP in wage bill on growth (p.p.)", size(8pt)) yscale(range(0.5 6.5))
fig_export Figure3_denominator, width(190) height(90)

* Figura 5: projecoes locais (D1 e D2)
use "$INTERIM/lp_D1.dta", clear
append using "$INTERIM/lp_D2.dta"
gen hh = h + cond(shock == "d_wb_emp", -0.12, cond(shock == "d_wb_wage", 0.12, 0))
twoway (rarea lo hi h if shock == "d_wagebill_real", color("$C2%25") lwidth(none)) ///
       (connected b h if shock == "d_wagebill_real", lcolor("$C2") mcolor("$C2") msymbol(O) lpattern(solid)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(dash)) legend(off) xlabel(0(1)6) ///
       xtitle("Years after the shock", size(8pt)) ytitle("GDP per capita (%)", size(8pt)) ///
       title("(a) Real wage bill shock", size(9pt) color(black) pos(11)) name(p1, replace) nodraw
twoway (rcap lo hi hh if shock == "d_wb_emp", lcolor("$C1")) ///
       (connected b hh if shock == "d_wb_emp", lcolor("$C1") mcolor("$C1") msymbol(T) lpattern(solid)) ///
       (rcap lo hi hh if shock == "d_wb_wage", lcolor("$C3")) ///
       (connected b hh if shock == "d_wb_wage", lcolor("$C3") mcolor("$C3") msymbol(S) lpattern(dash)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(dash)) xlabel(0(1)6) ///
       legend(order(2 "Employment component" 4 "Relative pay component") rows(1) pos(6)) ///
       xtitle("Years after the shock", size(8pt)) ytitle("GDP per capita (%)", size(8pt)) ///
       title("(b) Employment and pay components", size(9pt) color(black) pos(11)) name(p2, replace) nodraw
graph combine p1 p2, cols(2) graphregion(color(white)) imargin(small)
fig_export Figure5_local_projections, width(190) height(85)

* Figura 6: dependencia de estado
use "$INTERIM/lp_D3.dta", clear
gen hh = h + cond(regime == "hi", 0.1, -0.1)
twoway (rarea lo hi h if regime == "lo", color("$C5%20") lwidth(none)) ///
       (rarea lo hi h if regime == "hi", color("$C2%20") lwidth(none)) ///
       (connected b h if regime == "lo", lcolor("$C5") mcolor("$C5") msymbol(T) lpattern(dash)) ///
       (connected b h if regime == "hi", lcolor("$C2") mcolor("$C2") msymbol(O) lpattern(solid)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(dash)) xlabel(0(1)6) ///
       legend(order(4 "High merit (above median)" 3 "Low merit (below median)") cols(1) pos(6) size(7pt) symxsize(8)) ///
       xtitle("Years after the shock", size(8pt)) ytitle("GDP per capita (%)", size(8pt) margin(r=1)) ///
       ylabel(, labsize(7pt) nogrid angle(horizontal)) xlabel(0(1)6, labsize(7pt))
fig_export Figure6_lp_merit, width(90) height(90)
list h regime b se pdiff N, sepby(regime) noobs

log close
