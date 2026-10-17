* 07_moderacao.do -- Bloco C (H3): moderacao pelo recrutamento meritocratico; Tabela 4, Figura 4, Tabela A6
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/07_moderacao.log", replace text

global X5 "lny0 hc0 inv open infl popg ctot_g"
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
xtset id period

* ---------------------------------------------------------------- C1. interacao linear com merit0
gen wb_x_merit0 = wagebill_gdp0 * merit0
reghdfe g wagebill_gdp0 merit0 wb_x_merit0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store C1
gen byte sC1 = e(sample)
* efeito marginal da folha ao longo de toda a faixa de merit0 (IC 95%)
quietly summ merit0 if sC1
local mlo = r(min)
local mhi = r(max)
preserve
clear
set obs 61
gen m = `mlo' + (_n - 1) * (`mhi' - `mlo') / 60
gen me = .
gen lo = .
gen hi = .
estimates restore C1
matrix V = e(V)
local df = e(df_r)
forvalues i = 1/61 {
    local mm = m[`i']
    quietly lincom wagebill_gdp0 + `mm' * wb_x_merit0
    quietly replace me = r(estimate) in `i'
    quietly replace lo = r(estimate) - invttail(`df', 0.025) * r(se) in `i'
    quietly replace hi = r(estimate) + invttail(`df', 0.025) * r(se) in `i'
}
save "$INTERIM/me_C1.dta", replace
restore
* efeito marginal nos percentis 10, 50 e 90 do moderador (para o texto)
foreach p in 10 50 90 {
    quietly _pctile merit0 if sC1, p(`p')
    local q = r(r1)
    quietly lincom wagebill_gdp0 + `q' * wb_x_merit0
    di "C1: efeito marginal no p`p' de merit0 (" %5.2f `q' "): " %6.3f r(estimate) " (EP " %5.3f r(se) ", p = " %5.3f r(p) ")"
}

* ---------------------------------------------------------------- C2. Hainmueller, Mummolo e Xu (2019): interflex
* binning (tercis) com teste de Wald da linearidade; kernel com bootstrap por pais
interflex g wagebill_gdp0 merit0 $X5 if sC1, fe(id period) type(binning) nbins(3) vce(cluster) cluster(id)
matrix BIN = e(estBin)
scalar pwald = e(pwald)
matrix list BIN
di "C2: teste de Wald (binning x linear), p = " pwald
preserve
clear
svmat BIN, names(col)
save "$INTERIM/me_bins.dta", replace
restore
* estimador por kernel (HMX 2019) implementado aqui: o modo kernel do interflex com efeitos fixos e
* bootstrap termina com erro de sintaxe interno (ver docs/DECISOES.md, D28). Banda escolhida pela validacao
* cruzada do proprio interflex (0,4701); regressao local ponderada (kernel gaussiano) de g em folha,
* (merit0 - x0), folha x (merit0 - x0) e controles, com EF de pais e periodo; IC por bootstrap por pais.
local bw = 0.4701
quietly summ merit0 if sC1
local kmin = r(min)
local kmax = r(max)
local neval = 30
tempname K
postfile `K' double(km_x km_me km_se km_lo km_hi) using "$INTERIM/me_kernel.dta", replace
forvalues v = 1/`neval' {
    local x0 = `kmin' + (`v' - 1) * (`kmax' - `kmin') / (`neval' - 1)
    capture drop _xx _dx _w
    quietly gen double _xx = merit0 - `x0'
    quietly gen double _dx = _xx * wagebill_gdp0
    quietly gen double _w = normalden(_xx / `bw')
    quietly reghdfe g wagebill_gdp0 _xx _dx $X5 [aw = _w] if sC1, absorb(id period)
    local me = _b[wagebill_gdp0]
    * bootstrap por pais (200 replicacoes)
    tempname B
    postfile `B' double bb using "$INTERIM/_kb.dta", replace
    forvalues r = 1/200 {
        preserve
        quietly keep if sC1
        bsample, cluster(id) idcluster(bid)
        capture quietly reghdfe g wagebill_gdp0 _xx _dx $X5 [aw = _w], absorb(bid period)
        if !_rc post `B' (_b[wagebill_gdp0])
        restore
    }
    postclose `B'
    preserve
    use "$INTERIM/_kb.dta", clear
    quietly summ bb
    local kse = r(sd)
    restore
    post `K' (`x0') (`me') (`kse') (`me' - 1.96 * `kse') (`me' + 1.96 * `kse')
}
postclose `K'
capture drop _xx _dx _w
* suporte comum: distribuicao do moderador na amostra de estimacao
preserve
keep if sC1
keep merit0
save "$INTERIM/merit0_sample.dta", replace
restore

* ---------------------------------------------------------------- C3. divisao da amostra (mediana e tercis de merit0)
quietly summ merit0 if sC1, detail
local med = r(p50)
_pctile merit0 if sC1, p(33.333 66.667)
local t1 = r(r1)
local t2 = r(r2)
gen byte grp2 = 1 + (merit0 > `med') if sC1
gen byte grp3 = 1 + (merit0 > `t1') + (merit0 > `t2') if sC1
reghdfe g wagebill_gdp0 $X5 if grp2 == 1, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store C3_lo
reghdfe g wagebill_gdp0 $X5 if grp2 == 2, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store C3_hi
forvalues k = 1/3 {
    reghdfe g wagebill_gdp0 $X5 if grp3 == `k', absorb(id period) vce(cluster id)
    estadd scalar nc = e(N_clust)
    estadd scalar r2w = e(r2_within)
    estimates store C3_t`k'
}
* teste de igualdade: modelo agrupado com folha e controles interagidos com o grupo
reghdfe g c.(wagebill_gdp0 $X5)#i.grp2 if sC1, absorb(id period#grp2) vce(cluster id)
test 1.grp2#c.wagebill_gdp0 = 2.grp2#c.wagebill_gdp0
scalar p_med = r(p)
reghdfe g c.(wagebill_gdp0 $X5)#i.grp3 if sC1, absorb(id period#grp3) vce(cluster id)
test (1.grp3#c.wagebill_gdp0 = 2.grp3#c.wagebill_gdp0) (2.grp3#c.wagebill_gdp0 = 3.grp3#c.wagebill_gdp0)
scalar p_ter = r(p)
di "C3: mediana = " `med' "; tercis = " `t1' ", " `t2' "; p igualdade (mediana) = " p_med "; p igualdade (tercis) = " p_ter

* ---------------------------------------------------------------- C5. interacao com o WGI (comparacao com a dissertacao)
gen wb_x_wgi0 = wagebill_gdp0 * wgi_ge0
reghdfe g wagebill_gdp0 wgi_ge0 wb_x_wgi0 $X5, absorb(id period) vce(cluster id)
estadd scalar nc = e(N_clust)
estadd scalar r2w = e(r2_within)
estimates store C5
gen byte sC5 = e(sample)
foreach p in 10 50 90 {
    quietly _pctile wgi_ge0 if sC5, p(`p')
    local q = r(r1)
    quietly lincom wagebill_gdp0 + `q' * wb_x_wgi0
    di "C5: efeito marginal no p`p' do WGI (" %5.2f `q' "): " %6.3f r(estimate) " (EP " %5.3f r(se) ", p = " %5.3f r(p) ")"
}
* efeito marginal ao longo do WGI (apendice)
quietly summ wgi_ge0 if sC5
local wlo = r(min)
local whi = r(max)
preserve
clear
set obs 61
gen m = `wlo' + (_n - 1) * (`whi' - `wlo') / 60
gen me = .
gen lo = .
gen hi = .
estimates restore C5
local df = e(df_r)
forvalues i = 1/61 {
    local mm = m[`i']
    quietly lincom wagebill_gdp0 + `mm' * wb_x_wgi0
    quietly replace me = r(estimate) in `i'
    quietly replace lo = r(estimate) - invttail(`df', 0.025) * r(se) in `i'
    quietly replace hi = r(estimate) + invttail(`df', 0.025) * r(se) in `i'
}
save "$INTERIM/me_C5.dta", replace
restore

capture program drop setcmd
program define setcmd, eclass
    * alguns comandos (xthenreg) nao definem e(cmd), o que impede estimates store
    ereturn local cmd "`1'"
end

* ---------------------------------------------------------------- C4. limiar: Seo e Shin (2016), xthenreg
* Painel anual estritamente balanceado (exigencia do estimador). Limiar em merit defasado; regressor
* sujeito a regime: folha defasada; modelo dinamico (FD-GMM) com crescimento defasado. Linearidade por
* bootstrap (500 replicacoes). Nao se estima limiar dentro de System GMM com muitos instrumentos.
* Condicoes de momento do FD-GMM de Seo e Shin no xthenreg: para cada t = 3..T, constante, todas as
* defasagens disponiveis de y (t-2) e os regressores; com T grande o numero de momentos passa de N
* (proliferacao de instrumentos). Duas janelas: 2000-2019 (T = 20) e 2015-2019 (T = 5). A regra da
* especificacao (instrumentos < N/2) e verificada e gravada; a janela que a viola nao e interpretada.
local w = 0
foreach win in "2000 2019" "2015 2019" {
    local ++w
    use "$FINAL/painel_anual.dta", clear
    keep if micro == 0
    xtset id year
    gen wb_l1 = L.wagebill_gdp
    local y0 : word 1 of `win'
    local y1 : word 2 of `win'
    keep if inrange(year, `y0', `y1')
    gen byte ok = !missing(g, wb_l1, merit_l1)
    bysort id: egen nok = total(ok)
    keep if nok == `y1' - `y0' + 1
    quietly levelsof id
    local Nbal : word count `r(levels)'
    local T = `y1' - `y0' + 1
    * momentos: soma em t = 3..T de [1 + (t - 2) + 1]
    local L = 0
    forvalues t = 3/`T' {
        local L = `L' + 1 + (`t' - 2) + 1
    }
    di "C4 janela `y0'-`y1': `Nbal' paises, T = `T', condicoes de momento = `L', N/2 = " `Nbal' / 2
    xtset id year
    set seed 20261007
    xthenreg g merit_l1 wb_l1, boost(500) grid_num(100) trim_rate(0.4)
    setcmd xthenreg
    estadd scalar nmom = `L'
    estadd scalar valid = `L' < `Nbal' / 2
    estadd scalar y0 = `y0'
    estimates store C4_w`w'
    if `w' == 1 {
        * Hansen (1999), efeitos fixos estaticos, sem instrumentos, mesmo painel, 500 replicacoes
        * dummies de ano como regressores independentes de regime (xthreg nao aceita variaveis de fator)
        quietly tab year, gen(yd)
        drop yd1
        xthreg g yd*, rx(wb_l1) qx(merit_l1) thnum(1) trim(0.10) grid(300) bs(500)
        estadd scalar Nb = `Nbal'
        estadd scalar Tb = `T'
        estimates store C4h
    }
}
estimates restore C4_w1
estimates store C4

* =====================================================================================
* Tabela 4
* =====================================================================================
local stars "* p<0.10, ** p<0.05, *** p<0.01."
tab_new, ncol(7) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
    head2("Merit, linear" "WGI, linear" "Merit < median" "Merit > median" "Merit, tercile 1" "Merit, tercile 2" "Merit, tercile 3")
tab_est C1 C5 C3_lo C3_hi C3_t1 C3_t2 C3_t3, keep(wagebill_gdp0 merit0 wb_x_merit0 wgi_ge0 wb_x_wgi0)
tab_mid
local pm : display %5.3f p_med
local pt : display %5.3f p_ter
tab_row "Equality of wage bill coefficients (p)" "" "" "`=strtrim("`pm'")'" "" "`=strtrim("`pt'")'" "" ""
tab_row "Controls" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes"
tab_row "Country and period fixed effects" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes"
tab_stat N "Observations"
tab_stat nc "Countries"
tab_stat r2w "R2 (within)" %5.3f
tab_out Table4_moderation, title("Table 4. Does bureaucratic recruitment moderate the growth cost of the wage bill?") landscape ///
    notes("Dependent variable: growth of real GDP per capita (%, five-year average). Wage bill: general government compensation of employees (% of GDP) in the first year of the period. Meritocratic recruitment: V-Dem v2stcritrecadm (criteria for appointment decisions in the state administration; higher values = more merit-based), measured in the first year of the period. WGI: government effectiveness (higher values = more effective), first year of the period (from 1996). A positive interaction means that the growth cost of the wage bill is smaller where the moderator is higher. Columns 3-7 split the sample at the median and terciles of merit in the estimation sample of column 1; the equality test comes from a pooled model with all coefficients and the period effects interacted with the group. Controls as in Table 2. Country and period fixed effects; standard errors clustered by country. The threshold estimates (Seo and Shin, 2016) are in Table A6. `stars'")

* ---------------------------------------------------------------- Tabela A6: modelos de limiar
tab_new, ncol(3) head1("(1)" "(2)" "(3)") head2("Seo-Shin, 2000-2019" "Seo-Shin, 2015-2019" "Hansen, 2000-2019")
foreach nm in Lag_y_b wb_l1_b cons_d Lag_y_d wb_l1_d {
    local rb ""
    local rs ""
    foreach w in 1 2 {
        estimates restore C4_w`w'
        local k = colnumb(e(b), "`nm'")
        local bb : display %9.3f el(e(b), 1, `k')
        local ss : display %9.3f sqrt(el(e(V), `k', `k'))
        local pv = 2 * normal(-abs(el(e(b), 1, `k') / sqrt(el(e(V), `k', `k'))))
        local st = cond(`pv' < 0.01, "***", cond(`pv' < 0.05, "**", cond(`pv' < 0.10, "*", "")))
        local rb `"`rb' "`=strtrim("`bb'")'`st'""'
        local rs `"`rs' "(`=strtrim("`ss'")')""'
    }
    local lab = cond("`nm'" == "Lag_y_b", "Lagged growth, lower regime", cond("`nm'" == "wb_l1_b", "Wage bill, lower regime", ///
        cond("`nm'" == "cons_d", "Intercept shift above threshold", cond("`nm'" == "Lag_y_d", "Lagged growth, change above threshold", ///
        "Wage bill, change above threshold"))))
    tab_row "`lab'" `rb' ""
    tab_row "" `rs' ""
}
estimates restore C4h
local hn : colnames e(b)
local k = 0
foreach nm of local hn {
    local ++k
    if strpos("`nm'", "wb_l1") == 0 continue
    local bb : display %9.3f el(e(b), 1, `k')
    local ss : display %9.3f sqrt(el(e(V), `k', `k'))
    local pv = 2 * ttail(e(df_r), abs(el(e(b), 1, `k') / sqrt(el(e(V), `k', `k'))))
    local st = cond(`pv' < 0.01, "***", cond(`pv' < 0.05, "**", cond(`pv' < 0.10, "*", "")))
    local reg = cond(strpos("`nm'", "0b.") | strpos("`nm'", "0.") == 1, "regime 1 (merit below threshold)", "regime 2 (merit above threshold)")
    tab_row "Wage bill, `reg'" "" "" "`=strtrim("`bb'")'`st'"
    tab_row "" "" "" "(`=strtrim("`ss'")')"
}
tab_mid
local r1 ""
foreach w in 1 2 {
    estimates restore C4_w`w'
    local t : display %6.3f el(e(b), 1, colnumb(e(b), "r"))
    local r1 `"`r1' "`=strtrim("`t'")'""'
}
estimates restore C4h
matrix TH = e(Thrss)
matrix FH = e(Fstat)
local thh : display %6.3f TH[1, 1]
local thhlo : display %6.3f TH[1, 4]
local thhhi : display %6.3f TH[1, 5]
tab_row "Threshold in lagged merit" `r1' "`=strtrim("`thh'")'"
tab_row "95% CI of threshold" "" "" "[`=strtrim("`thhlo'")', `=strtrim("`thhhi'")']"
local r2 ""
local r3 ""
local r4 ""
local r5 ""
foreach w in 1 2 {
    estimates restore C4_w`w'
    local bp : display %5.3f e(boots_p)
    local r2 `"`r2' "`=strtrim("`bp'")'""'
    local r3 `"`r3' "`=e(N)' x `=e(T)'""'
    local r4 `"`r4' "`=e(nmom)'""'
    local r5 `"`r5' "`=cond(e(valid), "Yes", "No")'""'
}
local hp : display %5.3f FH[1, 4]
estimates restore C4h
tab_row "Linearity test, bootstrap p (500 reps)" `r2' "`=strtrim("`hp'")'"
tab_row "Countries x years" `r3' "`=e(Nb)' x `=e(Tb)'"
tab_row "Moment conditions (GMM)" `r4' "none"
tab_row "Moment conditions below N/2" `r5' "n.a."
tab_out TableA6_threshold, title("Table A6. Threshold models with meritocratic recruitment as the regime variable") landscape ///
    notes("Dependent variable: annual growth of real GDP per capita (%). Strongly balanced annual panels (required by both estimators), microstates excluded. Regime-dependent regressor: general government wage bill (% of GDP), lagged one year; threshold variable: V-Dem meritocratic recruitment (higher values = more merit-based), lagged one year. Columns 1-2: dynamic panel threshold model of Seo and Shin (2016), first-difference GMM (xthenreg), asymptotic standard errors; the lower-regime slope and the change in the slope above the threshold are shown. In column 1 the number of moment conditions (all available lags of growth for each year) exceeds the number of countries, which is the instrument proliferation that the pre-specified rule excludes; its estimates are reported for transparency and are not interpreted. Column 3: fixed-effects threshold model of Hansen (1999), xthreg, with year dummies as regime-independent regressors and no instruments; slopes by regime. Linearity tests by bootstrap with 500 replications. * p<0.10, ** p<0.05, *** p<0.01.")

foreach m in C1 C3_lo C3_hi C3_t1 C3_t2 C3_t3 C5 C4 C4_w1 C4_w2 C4h {
    estimates restore `m'
    estimates save "$LOG/est_`m'", replace
}
log close
