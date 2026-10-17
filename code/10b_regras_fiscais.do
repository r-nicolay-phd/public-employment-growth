* 10b_regras_fiscais.do -- Bloco H: heterogeneidade por regras fiscais (FMI Fiscal Rules Dataset); Tabela A10
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/10b_regras_fiscais.log", replace text

capture confirm file "$INTERIM/fiscal_rules.dta"
if _rc {
    di "Fiscal Rules Dataset ausente: bloco H nao estimado"
    log close
    exit
}

global X5 "lny0 hc0 inv open infl popg ctot_g"
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
xtset id period

* regra em vigor no primeiro ano do periodo (como a folha); o modelo de cada coluna usa nomes genericos
* R0 (regra) e WBxR (folha x regra) para que os coeficientes fiquem na mesma linha da tabela
* membros da Uniao Europeia em algum momento de 1979-2023 (UE-27 e Reino Unido): regra de resultado supranacional
gen byte eu = inlist(iso3, "AUT", "BEL", "BGR", "HRV", "CYP", "CZE", "DNK", "EST", "FIN") | ///
    inlist(iso3, "FRA", "DEU", "GRC", "HUN", "IRL", "ITA", "LVA", "LTU", "LUX") | ///
    inlist(iso3, "MLT", "NLD", "POL", "PRT", "ROU", "SVK", "SVN", "ESP", "SWE") | iso3 == "GBR"
local regras "rule_exp0 rule_bb0 rule_any0 rule_exp_nat0 rule_bb_nat0 rule_exp0 rule_bb0"
local amostras `""1" "1" "1" "1" "1" "in_frd == 1" "eu == 0""'
local j = 0
foreach r of local regras {
    local ++j
    local cond : word `j' of `amostras'
    capture drop R0 WBxR
    gen R0 = `r'
    gen WBxR = wagebill_gdp0 * R0
    reghdfe g wagebill_gdp0 R0 WBxR $X5 if `cond', absorb(id period) vce(cluster id)
    estadd scalar nc = e(N_clust)
    estadd scalar r2w = e(r2_within)
    quietly lincom wagebill_gdp0 + WBxR
    estadd scalar me1 = r(estimate)
    estadd scalar me1_se = r(se)
    estadd scalar me1_p = r(p)
    * variacao que identifica a interacao: periodos com regra e paises que mudam de status na amostra
    tempvar s mx mn
    gen byte `s' = e(sample)
    quietly count if `s' & R0 == 1
    estadd scalar nrule = r(N)
    bysort id: egen `mx' = max(cond(`s', R0, .))
    bysort id: egen `mn' = min(cond(`s', R0, .))
    quietly egen _tg = tag(id) if `s' & `mx' != `mn'
    quietly count if _tg == 1
    estadd scalar nswitch = r(N)
    drop _tg
    estimates store H`j'
}
* coluna 8: regras de despesa e de resultado juntas
drop R0 WBxR
gen R0 = rule_exp0
gen WBxR = wagebill_gdp0 * R0
gen R2 = rule_bb0
gen WBxR2 = wagebill_gdp0 * R2
reghdfe g wagebill_gdp0 R0 WBxR R2 WBxR2 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
* efeito com as duas regras em vigor
quietly lincom wagebill_gdp0 + WBxR + WBxR2
estadd scalar me1 = r(estimate)
estadd scalar me1_se = r(se)
estadd scalar me1_p = r(p)
estimates store H8
* coluna 9: regra de resultado e merito juntos (a interacao com a regra nao e o merito disfarcado?)
gen wb_x_merit0 = wagebill_gdp0 * merit0
reghdfe g wagebill_gdp0 R2 WBxR2 merit0 wb_x_merit0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
quietly summ merit0 if e(sample)
local mm = r(mean)
quietly lincom wagebill_gdp0 + WBxR2 + `mm' * wb_x_merit0
estadd scalar me1 = r(estimate)
estadd scalar me1_se = r(se)
estadd scalar me1_p = r(p)
estimates store H9
quietly reghdfe g wagebill_gdp0 merit0 wb_x_merit0 $X5 if e(sample), absorb(id period) vce(cluster id)
di "C1 na amostra da coluna 9: folha x merito = " %6.3f _b[wb_x_merit0] " (EP " %5.3f _se[wb_x_merit0] ")"

* comparacao: modelo de base A1 na mesma amostra da coluna 1
quietly reghdfe g wagebill_gdp0 $X5 if !missing(rule_exp0), absorb(id period) vce(cluster id)
di "A1 na amostra com regra observada: b = " %6.3f _b[wagebill_gdp0] " (EP " %5.3f _se[wagebill_gdp0] "), N = " e(N)

* ---------------------------------------------------------------- Tabela A10
global LBL_R0 "Fiscal rule in force, initial"
global LBL_WBxR "Wage bill x fiscal rule"
global LBL_R2 "Budget balance rule in force, initial"
global LBL_WBxR2 "Wage bill x budget balance rule"
local stars "* p<0.10, ** p<0.05, *** p<0.01."
tab_new, ncol(9) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)" "(9)") ///
    head2("Expenditure rule" "Balance rule" "Any rule" "National expenditure rule" "National balance rule" "Expenditure rule, FRD countries" "Balance rule, excl. EU" "Expenditure and balance rules" "Balance rule and merit")
tab_est H1 H2 H3 H4 H5 H6 H7 H8 H9, keep(wagebill_gdp0 WBxR R0 WBxR2 R2 wb_x_merit0 merit0)
tab_mid
local rb ""
local rs ""
foreach m in H1 H2 H3 H4 H5 H6 H7 H8 H9 {
    quietly estimates restore `m'
    local b = e(me1)
    local p = e(me1_p)
    local st = cond(`p' < 0.01, "***", cond(`p' < 0.05, "**", cond(`p' < 0.10, "*", "")))
    local bs : display %6.3f `b'
    local ss : display %6.3f e(me1_se)
    local rb `"`rb' "`=strtrim("`bs'")'`st'""'
    local rs `"`rs' "(`=strtrim("`ss'")')""'
}
tab_row "Wage bill effect with the rule in force" `rb'
tab_row "" `rs'
tab_mid
tab_stat N "Observations"
tab_stat nc "Countries"
tab_stat nrule "Country-periods with the rule"
tab_stat nswitch "Countries that change rule status"
tab_stat r2w "R2 (within)" %5.3f
tab_out TableA10_fiscal_rules, title("Table A10. Heterogeneity by fiscal rules") landscape ///
    notes("Specification A1 (Table 2, column 1) with the wage bill interacted with an indicator of a numerical fiscal rule in force in the first year of the period (IMF Fiscal Rules Dataset, 1985-2024 update). The first coefficient is the wage bill effect without the rule; the row below the line is the effect with the rule in force (sum of the two coefficients). Rules cover national and supranational rules (EU Stability and Growth Pact, currency unions) for the central or general government; columns 4 and 5 count national rules only. IMF members absent from the dataset are coded as having no rule; column 6 restricts the sample to countries listed in the dataset; column 7 excludes countries that were EU members at any time in 1979-2023 (EU-27 and the United Kingdom). In column 8 the first interaction refers to the expenditure rule and the second to the budget balance rule, entered jointly, and the effect with the rule in force is evaluated with both rules in force. Column 9 adds the interaction with meritocratic recruitment of Table 4, column 1 (V-Dem, first year of the period); the effect with the rule in force is evaluated with a budget balance rule and merit at its sample mean. Rows on counts of rule periods and switching countries refer to the rule in columns 1-7. Five-year averages, country and period fixed effects, controls of Table 2, standard errors clustered by country; microstates excluded. `stars'")

foreach m in H1 H2 H3 H4 H5 H6 H7 H8 H9 {
    estimates restore `m'
    estimates save "$LOG/est_`m'", replace
}
log close
