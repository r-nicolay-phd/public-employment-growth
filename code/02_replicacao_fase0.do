* 02_replicacao_fase0.do -- Fase 0: replicacao de controle da base original
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/02_replicacao_fase0.log", replace text
import delimited "$INTERIM/wf1_original.csv", clear varnames(1) case(lower)
encode country_code, gen(id)
xtset id year
* casos completos nas 8 variaveis
egen nmiss = rowmiss(gdp_pc_growth exp_pub_gdp gov_eff fbkf_gdp inflation trade_gdp pop_growth terms_of_trade)
gen cc = nmiss == 0
count if cc
local N = r(N)

quietly levelsof country_code if cc
local K : word count `r(levels)'
summ year if cc
di "Casos completos: `N' obs, `K' paises, " r(min) "-" r(max)
assert `N' == 2042 & `K' == 133 & r(min) == 2005 & r(max) == 2023
* especificacao de controle: EF pais e ano, cluster pais
gen L_g = L.gdp_pc_growth
gen inter = exp_pub_gdp * gov_eff
* areg conta os efeitos fixos de pais nos graus de liberdade (como na referencia: -0,865; EP 0,269)
areg gdp_pc_growth L_g exp_pub_gdp gov_eff inter fbkf_gdp inflation trade_gdp pop_growth i.year if cc, absorb(id) vce(cluster id)
di "coef = " %6.3f _b[exp_pub_gdp] "  ep = " %6.3f _se[exp_pub_gdp]
assert abs(_b[exp_pub_gdp] + 0.865) < 0.001 & abs(_se[exp_pub_gdp] - 0.269) < 0.001
* reghdfe/xtreg tratam o EF como aninhado no cluster: mesmo coeficiente, EP 0,261
reghdfe gdp_pc_growth L_g exp_pub_gdp gov_eff inter fbkf_gdp inflation trade_gdp pop_growth if cc, absorb(id year) vce(cluster id)
* agregados: nenhum entra na amostra (lista do WDI aplicada na Fase 1); aqui, checa que todos tem GOV_EFF ausente
log close
