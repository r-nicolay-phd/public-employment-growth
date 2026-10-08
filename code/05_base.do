* 05_base.do -- Bloco A (H1): especificacoes de base, Tabela 2, sensibilidade de instrumentos (A.4) e
*               verificacao de Bond (A.5)
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/05_base.log", replace text

global X5 "lny0 hc0 inv open infl popg ctot_g"

* ---------------------------------------------------------------- A1. EF pais e periodo, medias de 5 anos
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
xtset id period
reghdfe g wagebill_gdp0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store A1

* ---------------------------------------------------------------- A4. restricao orcamentaria do governo
* As participacoes das categorias somam 100: uma categoria fica omitida e o coeficiente da folha mede a
* realocacao de 1 p.p. da despesa da categoria omitida para a folha. O resultado fiscal e receita - despesa
* no GFS; com receita e despesa no modelo ele fica implicito (colinearidade exata).
reghdfe g wagebill_share0 sh_goods0 sh_int0 sh_transf0 sh_other0 exp_gdp0 rev_gdp0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estadd local omitted "Investment"
estimates store A4a
reghdfe g wagebill_share0 sh_goods0 sh_int0 sh_inv0 sh_other0 exp_gdp0 rev_gdp0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estadd local omitted "Transfers"
estimates store A4b
* forma reduzida de H1: participacao da folha, mantida a despesa total (apendice)
reghdfe g wagebill_share0 exp_gdp0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store A4s

* ---------------------------------------------------------------- A5. System GMM (Blundell-Bond)
* Crescimento defasado (L_g = crescimento medio do periodo anterior), folha inicial, investimento e renda
* inicial tratados como endogenos; capital humano, abertura, inflacao, populacao, termos de troca e dummies
* de periodo como instrumentos padrao. Instrumentos colapsados; defasagens 2-3 (L_g: 1-2, que sao as
* defasagens 2-3 de g); dois estagios com correcao de Windmeijer.
local exo "hc0 open infl popg ctot_g"
quietly tab period, gen(pd)
drop pd1
local gmmset1 "gmm(L_g, lag(1 1) collapse) gmm(wagebill_gdp0 inv lny0, lag(2 2) collapse)"
local gmmset2 "gmm(L_g, lag(1 2) collapse) gmm(wagebill_gdp0 inv lny0, lag(2 3) collapse)"
local gmmset3 "gmm(L_g, lag(1 3) collapse) gmm(wagebill_gdp0 inv lny0, lag(2 4) collapse)"
forvalues s = 1/3 {
    xtabond2 g L_g wagebill_gdp0 $X5 pd*, `gmmset`s'' iv(`exo' pd*) twostep robust small
    estadd scalar nc = e(N_g)
    estadd scalar nins = e(j)
    estadd scalar ratio_ins = e(j) / e(N_g)
    matrix DH = e(diffsargan)
    estadd scalar dhansenp = DH[5, 1]
    di "Conjunto `s': instrumentos = " e(j) ", paises = " e(N_g) ", AR(2) p = " %5.3f e(ar2p) ", Hansen p = " %5.3f e(hansenp) ", dif-Hansen (nivel) p = " %5.3f DH[5, 1]
    assert e(j) < e(N_g) / 2
    estimates store A5_s`s'
}
estimates restore A5_s2
estimates store A5

* ---------------------------------------------------------------- A6. verificacao de Bond: MQO agrupado e EF
regress g L_g wagebill_gdp0 $X5 pd*, vce(cluster id)
estadd scalar nc = e(N_clust)
estimates store A6_ols
reghdfe g L_g wagebill_gdp0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store A6_fe

* ---------------------------------------------------------------- A7. EF com correcao de vies (Breitung, Kripfganz e Hayakawa 2022)
xtdpdbc g wagebill_gdp0 $X5, fe lags(1) teffects vce(robust) small
estadd scalar nc = e(N_g)
estimates store A7

* ---------------------------------------------------------------- A2. medias de 3 anos
use "$FINAL/painel_3anos.dta", clear
keep if micro == 0
xtset id period
reghdfe g wagebill_gdp0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store A2

* ---------------------------------------------------------------- A3. painel anual, folha defasada, Driscoll-Kraay
use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023)
xtset id year
* nomes alinhados com as colunas de medias: valores defasados em um ano
gen wagebill_gdp0 = L.wagebill_gdp
gen L_g = L.g
gen lny0 = L.lny
gen hc0 = L.hc
xtscc g wagebill_gdp0 L_g lny0 hc0 inv open infl popg ctot_g i.year, fe
estadd scalar nc = e(N_g)
estadd scalar r2w = e(r2_w)
estimates store A3

* =====================================================================================
* Tabela 2
* =====================================================================================
local stars "* p<0.10, ** p<0.05, *** p<0.01."
tab_new, ncol(7) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
    head2("FE, 5-year" "FE, 3-year" "FE annual, DK" "Budget (a)" "Budget (b)" "System GMM" "BC-FE")
tab_est A1 A2 A3 A4a A4b A5 A7, keep(wagebill_gdp0 wagebill_share0 L_g lny0 hc0 inv open infl popg ctot_g exp_gdp0 rev_gdp0)
tab_mid
tab_row "Omitted expenditure category" "" "" "" "Investment" "Transfers" "" ""
tab_row "Other expenditure shares" "" "" "" "Yes" "Yes" "" ""
tab_row "Country fixed effects" "Yes" "Yes" "Yes" "Yes" "Yes" "GMM" "Yes"
tab_row "Period fixed effects" "Yes" "Yes" "Yes (year)" "Yes" "Yes" "Yes" "Yes"
tab_stat N "Observations"
tab_stat nc "Countries"
tab_stat r2w "R2 (within)" %5.3f
tab_stat nins "Instruments"
tab_stat ar2p "AR(2), p-value" %5.3f
tab_stat hansenp "Hansen, p-value" %5.3f
tab_stat dhansenp "Diff-in-Hansen (levels), p-value" %5.3f
tab_out Table2_baseline, title("Table 2. Public wage bill and growth: baseline estimates") landscape ///
    notes("Dependent variable: growth of real GDP per capita (%, annual average over the period in columns 1, 2 and 4-7; annual in column 3). The wage bill is compensation of employees of the general government (IMF GFS), measured in the first year of each period (columns 1, 2, 4-7) or lagged one year (column 3). Columns 1-2 and 4-5: country and period fixed effects, standard errors clustered by country. Column 3: annual panel with country and year fixed effects, Driscoll-Kraay standard errors; regressors lagged one year. Columns 4-5: government budget constraint, with expenditure shares of goods and services, interest, other expense and either transfers (4) or investment (5), total expenditure and revenue; the fiscal balance is implied. The wage bill coefficient measures a reallocation of one percentage point of spending from the omitted category to the wage bill. Column 6: two-step system GMM (Blundell-Bond) with Windmeijer-corrected standard errors; lagged growth, wage bill, investment and initial income instrumented with lags 2-3, collapsed. Column 7: bias-corrected fixed effects for dynamic panels (Breitung, Kripfganz and Hayakawa, 2022), robust standard errors. Five-year periods 1979-2023, three-year periods 1981-2023, annual 1996-2023; microstates excluded. `stars'")

* ---------------------------------------------------------------- Tabela A4: sensibilidade de instrumentos
tab_new, ncol(3) head1("(1)" "(2)" "(3)") head2("Lags 2" "Lags 2-3 (baseline)" "Lags 2-4")
tab_est A5_s1 A5_s2 A5_s3, keep(wagebill_gdp0 L_g lny0 inv)
tab_mid
tab_stat N "Observations"
tab_stat nc "Countries"
tab_stat nins "Instruments"
tab_stat ratio_ins "Instruments / countries" %5.2f
tab_stat ar1p "AR(1), p-value" %5.3f
tab_stat ar2p "AR(2), p-value" %5.3f
tab_stat hansenp "Hansen, p-value" %5.3f
tab_stat dhansenp "Diff-in-Hansen (levels), p-value" %5.3f
tab_out TableA4_gmm_instruments, title("Table A4. System GMM: sensitivity to the instrument set") ///
    notes("Dependent variable: growth of real GDP per capita (%, five-year average). Two-step system GMM with Windmeijer-corrected standard errors, collapsed instruments; all columns include the controls of Table 2 and period dummies. Lagged growth, the initial wage bill, investment and initial income are treated as endogenous and instrumented with the lags shown in the column header (for lagged growth, the same lags of growth). `stars'")

* ---------------------------------------------------------------- Tabela A5: verificacao de Bond
tab_new, ncol(4) head1("(1)" "(2)" "(3)" "(4)") head2("Pooled OLS" "Fixed effects" "System GMM" "BC-FE")
tab_est A6_ols A6_fe A5 A7, keep(L_g wagebill_gdp0)
tab_mid
foreach m in A6_ols A6_fe A5 A7 {
    estimates restore `m'
    capture local rho_`m' = _b[L_g]
    if _rc local rho_`m' = _b[L.g]
}
local ok = cond(`rho_A5' <= `rho_A6_ols' & `rho_A5' >= `rho_A6_fe', "Yes", "No")
local okbc = cond(`rho_A7' <= `rho_A6_ols' & `rho_A7' >= `rho_A6_fe', "Yes", "No")
tab_row "Lagged growth within [FE, OLS] bounds" "" "" "`ok'" "`okbc'"
tab_stat N "Observations"
tab_stat nc "Countries"
tab_out TableA5_bond_check, title("Table A5. Bond (2002) check on the coefficient of lagged growth") ///
    notes("Five-year averages, 1979-2023, microstates excluded. All columns include the controls of Table 2 and period effects. Pooled OLS is biased upwards and fixed effects downwards for the coefficient of the lagged dependent variable; a consistent estimator should lie between them. Standard errors clustered by country (1-2), Windmeijer-corrected (3) and robust (4). `stars'")
di "Bond: OLS = " `rho_A6_ols' ", FE = " `rho_A6_fe' ", GMM = " `rho_A5' ", BC-FE = " `rho_A7'

* guarda as estimativas usadas depois (resultados e robustez)
foreach m in A1 A2 A3 A4a A4b A4s A5 A5_s1 A5_s2 A5_s3 A6_ols A6_fe A7 {
    estimates restore `m'
    estimates save "$LOG/est_`m'", replace
}

log close
