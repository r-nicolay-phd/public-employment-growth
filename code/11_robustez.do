* 11_robustez.do -- Bloco G: robustez da especificacao A1; Tabelas A8a-A8c e A9; Figuras A5 e A6
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/11_robustez.log", replace text

global X5 "lny0 hc0 inv open infl popg ctot_g"
use "$FINAL/painel_5anos.dta", clear
xtset id period

capture program drop rob
program define rob
    * rob nome "if" [depvar] [wbvar] [extra]
    args nm cond dep wb extra
    if "`dep'" == "" local dep g
    if "`wb'" == "" local wb wagebill_gdp0
    local Xg "$X5"
    if "`dep'" == "g_raw" local Xg : subinstr local Xg "infl" "infl_raw"
    reghdfe `dep' wagebill_gdp0 `Xg' `extra' if `cond', absorb(id period) vce(cluster id)
    estadd scalar nc = e(N_clust)
    estadd scalar r2w = e(r2_within)
    estimates store G_`nm'
end

* a variavel de interesse e sempre nomeada wagebill_gdp0 para alinhar as colunas
gen wb_gg = wagebill_gdp0
* ---------------------------------------------------------------- G1. governo central e serie combinada
preserve
replace wagebill_gdp0 = wagebill_cg_wdi0
rob cg_wdi "micro == 0"
restore
preserve
replace wagebill_gdp0 = wagebill_comb0
rob comb "micro == 0" g wagebill_gdp0 "cov_central0"
restore
* ---------------------------------------------------------------- G2-G5
rob micro "1"
rob noresource "micro == 0 & resource_rich == 0"
rob nocrisis "micro == 0" g_excr
rob nowins "micro == 0" g_raw
rob debt "micro == 0" g wagebill_gdp0 "debt0"
* ---------------------------------------------------------------- G6-G7. subamostras
forvalues k = 1/4 {
    rob inc`k' "micro == 0 & income_grp == `k'"
}
rob oecd "micro == 0 & oecd == 1"
rob nonoecd "micro == 0 & oecd == 0"
rob federal "micro == 0 & federal == 1"
rob unitary "micro == 0 & federal == 0"

* ---------------------------------------------------------------- G8. exclusao de um pais por vez
estimates restore G_micro
reghdfe g wagebill_gdp0 $X5 if micro == 0, absorb(id period) vce(cluster id)
gen byte sA1 = e(sample)
local b0 = _b[wagebill_gdp0]
tempname L
postfile `L' int id str3 iso3 double(b se) using "$INTERIM/loo.dta", replace
levelsof id if sA1, local(ids)
foreach i of local ids {
    quietly reghdfe g wagebill_gdp0 $X5 if sA1 & id != `i', absorb(id period) vce(cluster id)
    quietly levelsof iso3 if id == `i', local(c) clean
    post `L' (`i') ("`c'") (_b[wagebill_gdp0]) (_se[wagebill_gdp0])
}
postclose `L'

* ---------------------------------------------------------------- G9. media bayesiana de modelos (BMA)
* efeitos fixos de pais e periodo retirados de todas as variaveis (Frisch-Waugh) na amostra comum;
* folha e controles sao regressores auxiliares (probabilidade posterior de inclusao calculada para todos)
local bmavars g wagebill_gdp0 $X5 debt0 merit0
preserve
keep if micro == 0
foreach v of local bmavars {
    quietly drop if missing(`v')
}
foreach v of local bmavars {
    quietly reghdfe `v', absorb(id period) resid(r_`v')
}
local aux ""
foreach v of local bmavars {
    if "`v'" != "g" local aux `aux' r_`v'
}
bma r_g, auxiliary(`aux')
matrix PIP = e(pip)
matrix B = e(b)
matrix V = e(V)
local nB = _N
local names : colnames PIP
clear
local k : word count `names'
set obs `k'
gen str32 var = ""
gen pip = .
gen b = .
gen se = .
forvalues j = 1/`k' {
    local nm : word `j' of `names'
    replace var = subinstr("`nm'", "r_", "", 1) in `j'
    replace pip = PIP[1, `j'] in `j'
    replace b = B[1, colnumb(B, "`nm'")] in `j'
    replace se = sqrt(V[colnumb(V, "`nm'"), colnumb(V, "`nm'")]) in `j'
}
gen N = `nB'
save "$INTERIM/bma.dta", replace
list, noobs
restore

* ---------------------------------------------------------------- G10. CCE de grupo medio (series anuais, paises com 20+ anos)
preserve
use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023)
xtset id year
gen wagebill_gdp0 = L.wagebill_gdp
gen L_g = L.g
gen byte okc = !missing(g, wagebill_gdp0, L_g, inv, open, infl, popg)
bysort id: egen nyc = total(okc)
keep if nyc >= 20 & okc
xtset id year
xtdcce2 g wagebill_gdp0 L_g inv open infl popg, cr(g wagebill_gdp0 inv open infl popg) cr_lags(0)
estadd scalar nc = e(N_g)
estimates store G_cce
* diagnostico: coeficientes pais a pais (CCE feito a mao, mesmas medias transversais) e sua dispersao
foreach v in g wagebill_gdp0 inv open infl popg {
    bysort year: egen cm_`v' = mean(`v')
}
tempname Q
postfile `Q' str3 iso3 double(b se sdwb) using "$INTERIM/cce_individual.dta", replace
levelsof id, local(ids)
foreach i of local ids {
    quietly regress g wagebill_gdp0 L_g inv open infl popg cm_* if id == `i'
    local bi = _b[wagebill_gdp0]
    local si = _se[wagebill_gdp0]
    quietly summ wagebill_gdp0 if id == `i'
    local sd = r(sd)
    quietly levelsof iso3 if id == `i', local(c) clean
    post `Q' ("`c'") (`bi') (`si') (`sd')
}
postclose `Q'
use "$INTERIM/cce_individual.dta", clear
summ b, detail
di "CCE individual: mediana = " r(p50) ", media = " r(mean) ", DP = " r(sd)
summ sdwb, detail
di "CCE individual: DP mediano da folha dentro do pais = " r(p50)
gsort -b
list in 1/5, noobs
restore
* xtdcce2 limpa a memoria do Mata: recarrega as funcoes de tabela
do "$ROOT/code/00_tabelas.do"

* =====================================================================================
* Tabelas
* =====================================================================================
local stars "* p<0.10, ** p<0.05, *** p<0.01."
estimates restore G_micro
tab_new, ncol(8) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") ///
    head2("Baseline" "CG wage bill (WDI)" "GG or CG" "With microstates" "No resource-rich" "Excl. 2008-09, 2020-21" "No winsorizing" "Debt control")
estimates restore G_micro
quietly reghdfe g wagebill_gdp0 $X5 if micro == 0, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store G_base
tab_est G_base G_cg_wdi G_comb G_micro G_noresource G_nocrisis G_nowins G_debt, keep(wagebill_gdp0 cov_central0 debt0)
tab_mid
tab_stat N "Observations"
tab_stat nc "Countries"
tab_stat r2w "R2 (within)" %5.3f
tab_out TableA8a_robustness_definitions, title("Table A8a. Robustness: measurement, sample and outliers") landscape ///
    notes("Specification A1 (Table 2, column 1): five-year averages, country and period fixed effects, controls of Table 2, standard errors clustered by country. The coefficient shown is that of the wage bill (% of GDP) in the first year of the period: general government (IMF GFS) except in column 2 (central government, WDI, as in the original dissertation) and column 3 (general government where available, central government otherwise, with a coverage dummy). Column 6 averages growth excluding 2008-2009 and 2020-2021; column 7 uses growth and inflation without winsorization; column 8 adds general government debt (% of GDP) in the first year of the period. `stars'")

tab_new, ncol(8) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") ///
    head2("Low income" "Lower middle" "Upper middle" "High income" "OECD" "Non-OECD" "Federal" "Unitary")
tab_est G_inc1 G_inc2 G_inc3 G_inc4 G_oecd G_nonoecd G_federal G_unitary, keep(wagebill_gdp0)
tab_mid
tab_stat N "Observations"
tab_stat nc "Countries"
tab_stat r2w "R2 (within)" %5.3f
tab_out TableA8b_robustness_subsamples, title("Table A8b. Robustness: subsamples") landscape ///
    notes("Specification A1 estimated separately by World Bank income group in 1996, OECD membership and federal structure (Forum of Federations). Five-year averages, country and period fixed effects, controls of Table 2, standard errors clustered by country; microstates excluded. `stars'")

tab_new, ncol(1) head1("CCE mean group")
tab_est G_cce, keep(wagebill_gdp0 L_g inv open infl popg)
tab_mid
tab_stat N "Observations"
tab_stat nc "Countries"
tab_out TableA8c_robustness_cce, title("Table A8c. Robustness: common correlated effects mean group") ///
    notes("Annual panel 1996-2023, countries with at least 20 annual observations, microstates excluded. Pesaran (2006) CCE mean group estimator (xtdcce2): country-specific regressions augmented with cross-sectional averages of all variables; the table reports mean-group coefficients with nonparametric standard errors. Wage bill lagged one year. `stars'")

* Tabela A9: BMA
use "$INTERIM/bma.dta", clear
gen lab = ""
foreach v in wagebill_gdp0 lny0 hc0 inv open infl popg ctot_g debt0 merit0 {
    replace lab = "${LBL_`v'}" if var == "`v'"
}
replace lab = "Public debt (% of GDP), initial" if var == "debt0"
gsort -pip
tab_new, ncol(3) head1("Posterior inclusion probability" "Posterior mean" "Posterior SD")
forvalues j = 1/`=_N' {
    local a : display %5.3f pip[`j']
    local bb : display %7.3f b[`j']
    local ss : display %7.3f se[`j']
    tab_row "`=lab[`j']'" "`=strtrim("`a'")'" "`=strtrim("`bb'")'" "`=strtrim("`ss'")'"
}
tab_out TableA9_bma, title("Table A9. Bayesian model averaging over the control set") ///
    notes("Bayesian model averaging (Magnus, Powell and Prufer, 2010; De Luca and Magnus, 2011) over all 2^10 combinations of the regressors listed, all treated as auxiliary. Five-year averages; country and period fixed effects partialled out of every variable beforehand (Frisch-Waugh), common sample of `=N[1]' observations, microstates excluded. Dependent variable: growth of real GDP per capita (%, five-year average).")

* Figura A6: probabilidades de inclusao
gen ord = _n
capture label drop ordl
forvalues j = 1/`=_N' {
    label define ordl `j' "`=lab[`j']'", add
}
label values ord ordl
twoway (bar pip ord, horizontal barwidth(0.6) color("$C2")), $GOPT ///
    ylabel(1/`=_N', valuelabel angle(0) labsize(7pt) nogrid) xlabel(0(0.2)1, labsize(7pt)) ///
    ytitle("") xtitle("Posterior inclusion probability", size(8pt)) xline(0.5, lcolor(gs10) lpattern(dash)) yscale(reverse)
fig_export FigureA6_bma_pip, width(190) height(80)

* Figura A5: exclusao de um pais por vez
use "$INTERIM/loo.dta", clear
summ b
local bmin = r(min)
local bmax = r(max)
count if b > 0
local npos = r(N)
gsort b
gen r = _n
gen lo = b - 1.96 * se
gen hi = b + 1.96 * se
twoway (rcap lo hi r, lcolor("$C2%40")) (scatter b r, msymbol(O) msize(vsmall) mcolor("$C1")), $GOPT ///
    yline(`b0', lcolor("$C5") lpattern(dash)) yline(0, lcolor(gs10)) legend(off) ///
    xtitle("Excluded country (ranked by estimate)", size(8pt)) ytitle("Wage bill coefficient", size(8pt)) xlabel(none)
fig_export FigureA5_leave_one_out, width(190) height(80)
di "Exclusao de um pais: coeficientes entre " `bmin' " e " `bmax' "; positivos: `npos'"
count if hi < 0
di "Exclusao de um pais: significativos a 5% (IC abaixo de zero): " r(N) " de " _N

foreach m in G_base G_cg_wdi G_comb G_micro G_noresource G_nocrisis G_nowins G_debt G_inc1 G_inc2 G_inc3 G_inc4 G_oecd G_nonoecd G_federal G_unitary G_cce {
    estimates restore `m'
    estimates save "$LOG/est_`m'", replace
}
log close
