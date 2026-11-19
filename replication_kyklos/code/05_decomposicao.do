* 05_decomposicao.do -- bloco 4.4 do plano: decomposicao emprego x salario relativo (H2) [P2, P19, P26]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
capture log close
log using "$RLOG/05_decomposicao.log", replace text

global XP "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"

* ---------------------------------------------------------------- folha total na amostra do B1 do draft 7 (205 obs.)
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
xtset id period
reghdfe g pubemp_share0 relwage0 lny0 hc0 inv open infl popg ctot_g, absorb(id period) vce(cluster id)
gen byte sB1 = e(sample)
rv_kv B1d_N `e(N)'
reghdfe g wagebill_gdp0 lny0 hc0 inv open infl popg ctot_g i.period if sB1, absorb(id) vce(cluster id)
estimates store D_total_B1
rv_kv B1d_total_b `=string(_b[wagebill_gdp0], "%9.4f")'
rv_kv B1d_total_p `=string(2 * ttail(e(df_r), abs(_b[wagebill_gdp0] / _se[wagebill_gdp0])), "%9.4f")'

* ---------------------------------------------------------------- painel da revisao: mesmo ano para folha e emprego
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen relw_sel = wb_sel / pe_sel
gen lpe = ln(pe_sel)
gen lrw = ln(relw_sel)
gen lwbs = ln(wb_sel)
gen lrwh = ln(relh_sel / pe_sel * pe_sel)
replace lrwh = ln(relh_sel)
gen lilo = ln(ilo_sel)
gen prem01 = prem_sel / 0.1
gen premf01 = premf_sel / 0.1
label var lpe "log public employment (% of total employment)"
label var lrw "log relative public wage"
* contagens do timing comum
count if !missing(yd)
rv_kv pairs_all `r(N)'
count if yd == 1
rv_kv pairs_exact `r(N)'
count if !missing(yd) & yd != 1
rv_kv pairs_other `r(N)'
tab yd
* amostra harmonizada (logs, premio disponivel, controles de T3)
gen byte sH = !missing(g, lpe, lrw, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
count if sH
* checagem algebrica: log WageBill = log PubEmp + log RelWage
gen double chk = abs(lwbs - lpe - lrw)
summ chk
rv_kv chk_max `=string(r(max), "%9.2e")'

tempname P
postfile `P' str10 spec str10 v double(b se p pboot sdw) long(N nc) using "$RINT/decomp.dta", replace
capture program drop postd
program define postd
    * postd P spec var: coeficiente, p (cluster), p (wild bootstrap) e DP dentro do pais na amostra
    args P spec v
    local b = _b[`v']
    local se = _se[`v']
    local p = 2 * ttail(e(df_r), abs(`b' / `se'))
    tempvar dm
    quietly bysort id: egen double `dm' = mean(`v') if e(sample)
    quietly summ `v' if e(sample)
    tempvar w
    quietly gen double `w' = `v' - `dm' if e(sample)
    quietly summ `w'
    local sdw = r(sd)
    local N = e(N)
    local nc = e(N_clust)
    capture rv_boot `v'
    local pb = cond(_rc, ., r(p))
    post `P' ("`spec'") ("`v'") (`b') (`se') (`p') (`pb') (`sdw') (`N') (`nc')
    rv_kv d_`spec'_`v'_b `=string(`b', "%9.4f")'
    rv_kv d_`spec'_`v'_se `=string(`se', "%9.4f")'
    rv_kv d_`spec'_`v'_p `=string(`p', "%9.4f")'
    rv_kv d_`spec'_`v'_pboot `=string(`pb', "%9.4f")'
    rv_kv d_`spec'_`v'_sdw `=string(`sdw', "%9.4f")'
    rv_kv d_`spec'_N `N'
end
* (2) niveis, timing comum, controles de T3 (contrapartida do B1)
reghdfe g pe_sel relw_sel $XP i.period, absorb(id) vce(cluster id)
estimates store D_lev
postd `P' lev pe_sel
estimates restore D_lev
postd `P' lev relw_sel
* (3) logs na amostra harmonizada: especificacao preferida de H2
reghdfe g lpe lrw $XP i.period if sH, absorb(id) vce(cluster id)
estimates store D_log
postd `P' log lpe
estimates restore D_log
postd `P' log lrw
* (4) logs so com pares exatamente em t_p - 1
reghdfe g lpe lrw $XP i.period if yd == 1, absorb(id) vce(cluster id)
estimates store D_exact
postd `P' exact lpe
estimates restore D_exact
postd `P' exact lrw
* (5) emprego do WWBI instrumentado pelo do ILOSTAT (mesmo ano), salario relativo exogeno
ivreghdfe g lrw $XP (lpe = lilo) i.period, absorb(id) cluster(id) first ffirst
estimates store D_iv
local Fkp = e(widstat)
rv_kv d_iv_Fkp `=string(`Fkp', "%9.2f")'
rv_kv d_iv_lpe_b `=string(_b[lpe], "%9.4f")'
rv_kv d_iv_lrw_b `=string(_b[lrw], "%9.4f")'
rv_kv d_iv_lrw_p `=string(2 * normal(-abs(_b[lrw] / _se[lrw])), "%9.4f")'
rv_kv d_iv_N `e(N)'
* F efetivo de Montiel Olea-Pflueger: com um instrumento, igual ao F robusto (cluster) do primeiro estagio
reghdfe lpe lilo lrw $XP i.period if e(sample), absorb(id) vce(cluster id)
local Feff = (_b[lilo] / _se[lilo])^2
rv_kv d_iv_Feff `=string(`Feff', "%9.2f")'
estimates restore D_iv
estadd scalar Feff = `Feff'
estimates store D_iv
* (6) e (7) modelos separados, controlando pela folha total
reghdfe g lpe lwbs $XP i.period if sH, absorb(id) vce(cluster id)
estimates store D_sepE
postd `P' sepE lpe
reghdfe g lrw lwbs $XP i.period if sH, absorb(id) vce(cluster id)
estimates store D_sepW
postd `P' sepW lrw
* (8) salario relativo sobre o PIB por trabalhador tendencial (Hamilton)
reghdfe g lpe lrwh $XP i.period, absorb(id) vce(cluster id)
estimates store D_trend
postd `P' trend lrwh
* (9) premio ajustado (por 0,1 ponto log) na amostra harmonizada; (10) premio contra privados formais
reghdfe g prem01 $XP i.period if sH, absorb(id) vce(cluster id)
estimates store D_prem
postd `P' prem prem01
reghdfe g lrw $XP i.period if sH, absorb(id) vce(cluster id)
estimates store D_lrwonly
postd `P' lrwonly lrw
reghdfe g premf01 $XP i.period if !missing(lpe), absorb(id) vce(cluster id)
estimates store D_premf
postd `P' premf premf01
* folha total na amostra harmonizada (log da folha), para comparacao direta
reghdfe g lwbs $XP i.period if sH, absorb(id) vce(cluster id)
estimates store D_lwb
postd `P' lwb lwbs
postclose `P'

* =====================================================================================
* Tabela 5 (texto principal): decomposicao revisada
* =====================================================================================
use "$RINT/decomp.dta", clear
list, noobs sep(0)
rv_new, ncol(7) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
    head2("Total, B1 sample" "Levels, same year" "Logs (preferred)" "Logs, exact t_p − 1" "IV for employment" "Premium" "Log wage bill")
rv_estrow "Wage bill, general government (% of GDP), initial", models(D_total_B1 . . . . . .) vars(wagebill_gdp0)
rv_estrow "Public employment (% of total employment)", models(. D_lev . . . . .) vars(pe_sel)
rv_estrow "Relative public wage", models(. D_lev . . . . .) vars(relw_sel)
rv_estrow "log public employment", models(. . D_log D_exact D_iv . .) vars(lpe)
rv_estrow "log relative public wage", models(. . D_log D_exact D_iv . .) vars(lrw)
rv_estrow "Adjusted public wage premium (per 0.1 log point)", models(. . . . . D_prem .) vars(prem01)
rv_estrow "log wage bill (% of GDP)", models(. . . . . . D_lwb) vars(lwbs)
rv_mid
* efeitos de 1 DP dentro do pais e p do wild bootstrap para os coeficientes de preco
local r1 ""
local r2 ""
foreach k in "lev relw_sel" "log lrw" "exact lrw" "iv lrw" "prem prem01" "lwb lwbs" {
    gettoken s v : k
    local v = strtrim("`v'")
    quietly summ b if spec == "`s'" & v == "`v'"
    local b = r(mean)
    quietly summ sdw if spec == "`s'" & v == "`v'"
    if r(N) == 0 {
        local r1 `"`r1' """'
        local r2 `"`r2' """'
        continue
    }
    rv_fmt `=`b' * r(mean)' %12.3f
    local r1 `"`r1' "`r(s)'""'
    quietly summ pboot if spec == "`s'" & v == "`v'"
    rv_fmt `=r(mean)' %12.3f
    local r2 `"`r2' "`r(s)'""'
}
rv_row "Price term: effect of 1 within-country SD" "" `r1'
rv_row "Price term: wild cluster bootstrap p-value" "" `r2'
rv_mid
rv_stat "Observations", models(D_total_B1 D_lev D_log D_exact D_iv D_prem D_lwb) stat(N)
rv_stat "Countries", models(D_total_B1 D_lev D_log D_exact D_iv D_prem D_lwb) stat(N_clust)
rv_stat "First-stage effective F (Montiel Olea–Pflueger)", models(. . . . D_iv . .) stat(Feff) fmt(%12.2f)
rv_row "Controls" "Conventional" "Predetermined" "Predetermined" "Predetermined" "Predetermined" "Predetermined" "Predetermined"
rv_row "Country FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes"
rv_row "Period FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes"
rv_row "Standard errors" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster"
import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
foreach k in pairs_all pairs_exact pairs_other B1d_N {
    quietly levelsof value if key == "`k'", local(`k') clean
    local `k' : word 1 of ``k''
}
rv_out Tab5_decomposition, landscape ///
    title("Table 5. Employment or relative pay? Decomposition of the wage bill") ///
    notes("Dependent variable: growth of real GDP per capita (%, five-year average), 1979–2023 (WWBI data from 2000). Column 1: total wage bill (first year of the period) on the country-periods of the conventional decomposition (`B1d_N' country-periods) that also have the first-year wage bill, with the conventional controls. Columns 2–7: the wage bill and public employment are taken from the same year, the one closest to t_p − 1 (searching t_p − 1 to t_p − 4, then t_p to t_p + 3); `pairs_all' country-periods have a pair, `pairs_exact' exactly in t_p − 1 (column 4) and `pairs_other' in another year. log WageBill = log PubEmp + log RelWage holds exactly in the data, so the log coefficients are directly comparable. Columns 3, 6 and 7 use the same harmonized sample (log employment, log relative wage and the adjusted premium all available). Column 5 instruments log WWBI public employment with log ILOSTAT public-sector employment in the same year (country and period fixed effects, clustered errors); with one instrument the effective F of Montiel Olea and Pflueger equals the cluster-robust first-stage F. The premium is the WWBI adjusted public-private wage gap against all private employees, rescaled to 0.1 log point. Within-country SD: standard deviation of the regressor after removing country means in the estimation sample. Predetermined controls of Table 2; country and period fixed effects; standard errors clustered by country; wild cluster bootstrap with Webb weights and 9,999 replications. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela suplementar: correcoes do vies de divisao
* =====================================================================================
rv_new, ncol(4) head1("(1)" "(2)" "(3)" "(4)") head2("Employment, controlling for wage bill" "Relative wage, controlling for wage bill" "Relative wage over trend GDP" "Premium vs formal private")
rv_estrow "log public employment", models(D_sepE . D_trend .) vars(lpe)
rv_estrow "log relative public wage", models(. D_sepW . .) vars(lrw)
rv_estrow "log relative wage over trend GDP per worker (Hamilton)", models(. . D_trend .) vars(lrwh)
rv_estrow "log wage bill (% of GDP)", models(D_sepE D_sepW . .) vars(lwbs)
rv_estrow "Premium vs formal private employees (per 0.1 log point)", models(. . . D_premf) vars(premf01)
rv_mid
rv_stat "Observations", models(D_sepE D_sepW D_trend D_premf) stat(N)
rv_stat "Countries", models(D_sepE D_sepW D_trend D_premf) stat(N_clust)
rv_out TabS_decomposition_bias, ///
    title("Table S6. Decomposition of the wage bill: division-bias corrections") ///
    notes("Dependent variable: growth of real GDP per capita (%, five-year average). Wage bill and public employment from the same year (see Table 5). Columns 1–2: each component with the log total wage bill as a control (harmonized sample of Table 5). Column 3: relative wage computed over trend GDP per worker (Hamilton filter), which removes the cyclical denominator from the price component. Column 4: WWBI wage premium against formal private employees (Gindling et al., 2020). Predetermined controls of Table 2, country and period fixed effects, standard errors clustered by country. * p<0.10, ** p<0.05, *** p<0.01.")

log close
