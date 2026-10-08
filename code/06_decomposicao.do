* 06_decomposicao.do -- Bloco B (H2): emprego publico x salario relativo; Tabela 3
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/06_decomposicao.log", replace text

global X5 "lny0 hc0 inv open infl popg ctot_g"
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
xtset id period
gen pubemp_sq0 = pubemp_share0^2

* B1. emprego publico e salario relativo juntos
reghdfe g pubemp_share0 relwage0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store B1

* B2. termo quadratico do emprego publico (U invertido de Baerlocher, 2021)
reghdfe g pubemp_share0 pubemp_sq0 relwage0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
local b1 = _b[pubemp_share0]
local b2 = _b[pubemp_sq0]
test pubemp_share0 pubemp_sq0
estadd scalar p_joint = r(p)
estimates store B2
* ponto de maximo (ou minimo) e IC pelo metodo delta
nlcom (peak: -_b[pubemp_share0] / (2 * _b[pubemp_sq0])), post
local pk = _b[peak]
local pkse = _se[peak]
estimates store B2_peak
estimates restore B2
quietly count if e(sample)
local nB2 = r(N)
quietly count if e(sample) & pubemp_share0 < `pk'
local left = r(N)
local invU = (`b1' > 0 & `b2' < 0)
estadd scalar peak = `pk'
estadd scalar peak_lo = `pk' - invnormal(0.975) * `pkse'
estadd scalar peak_hi = `pk' + invnormal(0.975) * `pkse'
estadd scalar share_left = 100 * `left' / `nB2'
estadd local shape = cond(`invU', "Inverted U", "U")
estimates store B2
di "B2: b1 = " `b1' ", b2 = " `b2' ", extremo = " `pk' " (EP " `pkse' "), " %4.1f 100 * `left' / `nB2' "% da amostra a esquerda; forma: " cond(`invU', "U invertido", "U")

* B3. premio salarial do WWBI no lugar do salario relativo
reghdfe g pubemp_share0 wwbi_prem_all0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store B3

* ---------------------------------------------------------------- Tabela 3
local stars "* p<0.10, ** p<0.05, *** p<0.01."
tab_new, ncol(3) head1("(1)" "(2)" "(3)") head2("B1" "B2" "B3")
tab_est B1 B2 B3, keep(pubemp_share0 pubemp_sq0 relwage0 wwbi_prem_all0 lny0 hc0 inv open infl popg ctot_g)
tab_mid
foreach m in B2 {
    estimates restore B2
    local pk : display %5.1f e(peak)
    local lo : display %5.1f e(peak_lo)
    local hi : display %5.1f e(peak_hi)
    local sl : display %4.1f e(share_left)
    local pj : display %5.3f e(p_joint)
    local shp = cond("`e(shape)'" == "U", "U-shaped (minimum)", "Inverted U (maximum)")
}
tab_row "Shape of the quadratic in public employment" "" "`shp'" ""
tab_row "Turning point of public employment (%)" "" "`=strtrim("`pk'")'" ""
tab_row "95% CI of turning point (delta method)" "" "[`=strtrim("`lo'")', `=strtrim("`hi'")']" ""
tab_row "Share of sample left of turning point (%)" "" "`=strtrim("`sl'")'" ""
tab_row "Joint test, linear and squared terms (p)" "" "`=strtrim("`pj'")'" ""
tab_row "Country and period fixed effects" "Yes" "Yes" "Yes"
tab_stat N "Observations"
tab_stat nc "Countries"
tab_stat r2w "R2 (within)" %5.3f
tab_out Table3_decomposition, title("Table 3. Employment or pay? Decomposing the public wage bill") ///
    notes("Dependent variable: growth of real GDP per capita (%, five-year average). Public employment is public sector employment as a share of total employment (World Bank WWBI); the relative public wage is the general government wage bill (% of GDP, IMF GFS) divided by the public employment share, i.e. pay per public employee relative to GDP per worker; the public wage premium is the WWBI conditional public-private wage gap with respect to all private employees (log points). WWBI variables are survey-based: the first observation available within each period is used. Country and period fixed effects; standard errors clustered by country. Turning point = -b1/(2 b2), with a 95% confidence interval from the delta method. Five-year periods, 1999-2023 (WWBI starts in 2000); microstates excluded. `stars'")

foreach m in B1 B2 B3 {
    estimates restore `m'
    estimates save "$LOG/est_`m'", replace
}
log close
