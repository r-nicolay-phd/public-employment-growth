* 10_economia_politica.do -- Bloco F (H5): ciclo eleitoral da folha; Tabela 6 e Figura A4
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
do "$ROOT/code/00_lp.do"
log using "$LOG/10_economia_politica.log", replace text

use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
xtset id year
gen y100 = 100 * lny
gen L_g = L.g
* DPI termina em 2020
local per "inrange(year, 1996, 2020)"

* ---------------------------------------------------------------- F1. primeiro estagio
reghdfe d_wagebill_real election_fixed L_g if `per', absorb(id year) vce(cluster id)
estadd scalar nc = e(N_clust)
test election_fixed
estadd scalar F1 = r(F)
scalar F_fixed = r(F)
estimates store F1
reghdfe d_wagebill_real election L_g if `per', absorb(id year) vce(cluster id)
estadd scalar nc = e(N_clust)
test election
estadd scalar F1 = r(F)
estimates store F1b
di "F1: F do primeiro estagio (eleicao predeterminada) = " F_fixed

* ---------------------------------------------------------------- F2. VI apenas se o primeiro estagio for forte
* (regra fixada antes de ver os resultados: F > 10). Com instrumento fraco, o segundo estagio nao e
* apresentado como evidencia; o IC de Anderson-Rubin e reportado em qualquer caso, como diagnostico.
local strong = F_fixed > 10
ivreghdfe g (d_wagebill_real = election_fixed) balance_gdp L_g if `per', absorb(id year) cluster(id)
estadd scalar nc = e(N_clust)
estadd scalar F_kp = e(widstat)
estimates store F2
weakiv ivreg2 g (d_wagebill_real = election_fixed) balance_gdp L_g i.year i.id if `per', cluster(id)
di "F2: IC de Anderson-Rubin (95%): " e(ar_cset)
local arci "`e(ar_cset)'"
local arci : subinstr local arci "  ...  ]" " +inf)"
local arci : subinstr local arci "[  ...  " "(-inf"

* ---------------------------------------------------------------- F3. projecoes locais: anos eleitorais x nao eleitorais
gen byte elec = election_fixed
lpirf, y(y100) shocks(d_wagebill_real) state(elec) saving("$INTERIM/lp_F3.dta") h(6) cond(`per')
* interacao com merito: mesma decomposicao em paises-ano de merito alto e baixo (defasado, mediana)
quietly summ merit_l1 if `per' & !missing(d_wagebill_real), detail
local med = r(p50)
lpirf, y(y100) shocks(d_wagebill_real) state(elec) saving("$INTERIM/lp_F3_hi.dta") h(6) cond(`per' & merit_l1 > `med' & !missing(merit_l1))
lpirf, y(y100) shocks(d_wagebill_real) state(elec) saving("$INTERIM/lp_F3_lo.dta") h(6) cond(`per' & merit_l1 <= `med')

* ---------------------------------------------------------------- Tabela 6
local stars "* p<0.10, ** p<0.05, *** p<0.01."
tab_new, ncol(3) head1("(1)" "(2)" "(3)") head2("First stage" "First stage" "IV diagnostics")
* o coeficiente de VI nao e mostrado (instrumento fraco pela regra F > 10); ficam so os diagnosticos
if `strong' tab_est F1 F1b F2, keep(election_fixed election d_wagebill_real)
else tab_est F1 F1b F2, keep(election_fixed election)
tab_mid
tab_stat F1 "F statistic, excluded instrument" %6.2f
tab_stat F_kp "Kleibergen-Paap F" %6.2f
tab_row "Anderson-Rubin 95% CI" "" "" "`arci'"
tab_row "Second stage shown as evidence" "" "" "`=cond(`strong', "Yes", "No: weak instrument")'"
tab_stat N "Observations"
tab_stat nc "Countries"
tab_mid
* painel B: F3 em horizontes selecionados
tab_row "Panel B. Local projections, cumulative GDP per capita response (%)" "" "" ""
foreach f in F3 F3_hi F3_lo {
    local lab = cond("`f'" == "F3", "All", cond("`f'" == "F3_hi", "High merit", "Low merit"))
    preserve
    use "$INTERIM/lp_`f'.dta", clear
    foreach hh in 2 4 {
        foreach r in hi lo {
            quietly summ b if h == `hh' & regime == "`r'"
            local b_`r'_`hh' : display %6.3f r(mean)
            quietly summ se if h == `hh' & regime == "`r'"
            local s_`r'_`hh' : display %6.3f r(mean)
        }
        quietly summ pdiff if h == `hh'
        local p_`hh' : display %5.3f r(mean)
    }
    restore
    foreach hh in 2 4 {
        tab_row "`lab', h = `hh': election year / other years" "`=strtrim("`b_hi_`hh''")' / `=strtrim("`b_lo_`hh''")'" ///
            "(`=strtrim("`s_hi_`hh''")') / (`=strtrim("`s_lo_`hh''")')" "p(diff) = `=strtrim("`p_`hh''")'"
    }
}
tab_out Table6_political_economy, title("Table 6. Electoral cycles in the wage bill") landscape ///
    notes("Panel A, columns 1-2: dependent variable is the real change in the general government wage bill (% of lagged GDP); predetermined election year = election held in the year the constitutional term expires (DPI, years left in term = 0); election year = any executive (presidential systems) or legislative (other systems) election. Country and year fixed effects, lagged growth, standard errors clustered by country, 1996-2020 (DPI ends in 2020). Column 3: 2SLS of GDP per capita growth on the wage bill change instrumented by the predetermined election year, controlling for the overall fiscal balance (% of GDP) and lagged growth; following the pre-specified rule, the second-stage coefficient is shown only if the first-stage F exceeds 10, which is not the case here; the Anderson-Rubin confidence set is robust to weak instruments. Panel B: local projections of 100 x log GDP per capita on wage bill shocks occurring in predetermined election years and in other years (two lags of the shock and of growth, country and year fixed effects, Driscoll-Kraay standard errors); high and low merit split at the median of lagged V-Dem meritocratic recruitment. Entries: coefficient for election-year shocks / other-year shocks, standard errors in parentheses, p-value of the difference. `stars'")

* ---------------------------------------------------------------- Figura A4
use "$INTERIM/lp_F3.dta", clear
twoway (rarea lo hi h if regime == "lo", color("$C1%15") lwidth(none)) ///
       (rarea lo hi h if regime == "hi", color("$C3%25") lwidth(none)) ///
       (connected b h if regime == "lo", lcolor("$C1") mcolor("$C1") msymbol(T) lpattern(dash)) ///
       (connected b h if regime == "hi", lcolor("$C3") mcolor("$C3") msymbol(O) lpattern(solid)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(dash)) xlabel(0(1)6, labsize(7pt)) ylabel(, labsize(7pt) nogrid angle(horizontal)) ///
       legend(order(4 "Shock in predetermined election year" 3 "Shock in other years") cols(1) pos(6) size(7pt) symxsize(8)) ///
       xtitle("Years after the shock", size(8pt)) ytitle("GDP per capita (%)", size(8pt) margin(r=1))
fig_export FigureA4_lp_elections, width(90) height(90)

foreach m in F1 F1b F2 {
    estimates restore `m'
    estimates save "$LOG/est_`m'", replace
}
log close
