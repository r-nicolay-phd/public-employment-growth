* 11_longo_prazo.do -- bloco 4.10 do plano: verificacao de Bond na amostra comum, longo prazo e teste CD [P22, P23]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/revisao/00_setup.do"
capture log close
log using "$RLOG/11_longo_prazo.log", replace text

global XD "lny0 hc_tp inv open infl popg ctot_g"
global XP "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"

* =====================================================================================
* A. Verificacao de Bond: MQO, EF, S-GMM e BC-FE na mesma amostra (S5_bond)
* =====================================================================================
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
quietly tab period, gen(pd)
drop pd1
tempname P
postfile `P' str6 tim str6 est double(rho serho b se) long(N nc) using "$RINT/bond.dta", replace
foreach tim in draft T3 {
    local w = cond("`tim'" == "draft", "wb_tp", "wb_m1")
    local X = cond("`tim'" == "draft", "$XD", "$XP")
    local exo = cond("`tim'" == "draft", "hc_tp open infl popg ctot_g", "hc_m1 open_m1 infl_m1 popg_m1 ctot_g_m1")
    local endo = cond("`tim'" == "draft", "`w' inv lny0", "`w' lny0")
    if "`tim'" == "T3" local exo "`exo' inv_m1"
    * amostras proprias e intersecao
    quietly regress g L_g `w' `X' pd*, vce(cluster id)
    gen byte s_ols = e(sample)
    quietly reghdfe g L_g `w' `X' i.period, absorb(id) vce(cluster id)
    gen byte s_fe = e(sample)
    quietly xtabond2 g L_g `w' `X' pd*, gmm(L_g, lag(1 2) collapse) gmm(`endo', lag(2 3) collapse) iv(`exo' pd*) twostep robust small
    gen byte s_gmm = e(sample)
    quietly xtdpdbc g `w' `X', fe lags(1) teffects vce(robust) small
    gen byte s_bc = e(sample)
    gen byte S5_bond_`tim' = s_ols & s_fe & s_gmm & s_bc
    count if S5_bond_`tim'
    rv_kv bond_`tim'_N `r(N)'
    foreach k in ols fe gmm bc {
        count if s_`k'
        rv_kv bond_`tim'_own_`k' `r(N)'
    }
    drop s_ols s_fe s_gmm s_bc
    * os quatro estimadores na amostra comum
    regress g L_g `w' `X' pd* if S5_bond_`tim', vce(cluster id)
    post `P' ("`tim'") ("ols") (_b[L_g]) (_se[L_g]) (_b[`w']) (_se[`w']) (e(N)) (e(N_clust))
    estimates store BD_`tim'_ols
    reghdfe g L_g `w' `X' i.period if S5_bond_`tim', absorb(id) vce(cluster id)
    post `P' ("`tim'") ("fe") (_b[L_g]) (_se[L_g]) (_b[`w']) (_se[`w']) (e(N)) (e(N_clust))
    estimates store BD_`tim'_fe
    xtabond2 g L_g `w' `X' pd* if S5_bond_`tim', gmm(L_g, lag(1 2) collapse) gmm(`endo', lag(2 3) collapse) iv(`exo' pd*) twostep robust small
    post `P' ("`tim'") ("gmm") (_b[L_g]) (_se[L_g]) (_b[`w']) (_se[`w']) (e(N)) (e(N_g))
    rv_kv bond_`tim'_gmm_hansen `=string(e(hansenp), "%6.3f")'
    rv_kv bond_`tim'_gmm_ar2 `=string(e(ar2p), "%6.3f")'
    rv_kv bond_`tim'_gmm_j `e(j)'
    estimates store BD_`tim'_gmm
    xtdpdbc g `w' `X' if S5_bond_`tim', fe lags(1) teffects vce(robust) small
    post `P' ("`tim'") ("bc") (_b[L.g]) (_se[L.g]) (_b[`w']) (_se[`w']) (e(N)) (e(N_g))
    estimates store BD_`tim'_bc
}
postclose `P'
preserve
keep id period S5_bond_draft S5_bond_T3
save "$RINT/amostra_bond.dta", replace
restore

* =====================================================================================
* B. Longo prazo: PMG, MG, DFE, CCE-MG, CS-ARDL e CS-DL (painel anual, paises com 20 anos ou mais)
* =====================================================================================
use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1993, 2023)
xtset id year
gen wbL = L.wb
gen wbH = L.wb_ham
gen byte okc = !missing(g, L.g, L2.g, wbL, L.wbL, L2.wbL, wbH, L.wbH, L2.wbH, inv, open, infl, popg) & year >= 1996
bysort id: egen nyc = total(okc)
keep if nyc >= 20
xtset id year
tempname L
postfile `L' str4 w str10 m double(b se) long(N ng) double(hp) using "$RINT/longo.dta", replace
foreach W in wbL wbH {
    capture drop X
    gen X = `W'
    foreach est in pmg mg dfe {
        capture noisily xtpmg d.g d.X d.inv d.open d.infl d.popg if okc, lr(l.g X inv open infl popg) ec(ec) replace `est'
        if _rc continue
        estimates store LP_`W'_`est'
        quietly count if e(sample)
        local N = r(N)
        quietly levelsof id if e(sample)
        post `L' ("`W'") ("`est'") (_b[ec:X]) (_se[ec:X]) (`N') (r(r)) (.)
    }
    capture noisily hausman LP_`W'_mg LP_`W'_pmg, sigmamore
    local hp = cond(_rc, ., r(p))
    rv_kv lr_`W'_hausman `=string(`hp', "%6.3f")'
    * CCE-MG estatico (folha defasada e controles, medias transversais)
    capture noisily xtdcce2 g X inv open infl popg if okc, cr(g X inv open infl popg) cr_lags(0)
    if !_rc post `L' ("`W'") ("ccemg") (_b[X]) (_se[X]) (e(N)) (e(N_g)) (.)
    capture noisily xtdcce2 g if okc, lr(L.g X L.X inv open infl popg) lr_options(ardl) cr(g X inv open infl popg) cr_lags(0)
    if !_rc post `L' ("`W'") ("csardl") (_b[lr_X]) (_se[lr_X]) (e(N)) (e(N_g)) (.)
    capture noisily xtdcce2 g X d.X inv if okc, cr(g X inv) cr_lags(2)
    if !_rc post `L' ("`W'") ("csdl") (_b[X]) (_se[X]) (e(N)) (e(N_g)) (.)
}
postclose `L'
mata: mata clear
do "$ROOT/code/revisao/00_setup.do"
capture log close
log using "$RLOG/11_longo_prazo.log", append text

* =====================================================================================
* C. Teste CD de Pesaran nos residuos dos modelos anuais da Tabela 1
* =====================================================================================
use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1995, 2023)
xtset id year
gen wb_l1 = L.wb
gen g_l1 = L.g
gen lny_l1 = L.lny
keep if year >= 1996
tempname C
postfile `C' str10 m double(cd p) long(N) using "$RINT/cdtest.dta", replace
foreach v in wb wb_ham wb_l1 {
    quietly reghdfe g `v' g_l1 lny_l1 hc inv open infl popg ctot_g, absorb(id year) resid(r_`v')
    local NN = e(N)
    capture noisily xtcd2 r_`v'
    if !_rc {
        * r(CD) e r(p) podem ser escalares ou matrizes (CD, CDw, CDw+, CD*), conforme a versao do xtcd2
        tempname CDm Pm
        capture matrix `CDm' = r(CD)
        if _rc matrix `CDm' = (r(CD))
        capture matrix `Pm' = r(p)
        if _rc matrix `Pm' = (r(p))
        local cdv = `CDm'[1, 1]
        local cdp = `Pm'[1, 1]
        post `C' ("`v'") (`cdv') (`cdp') (`NN')
        rv_kv cd_`v' `=string(`cdv', "%6.2f")'
        rv_kv cd_`v'_p `=string(`cdp', "%6.3f")'
    }
}
postclose `C'

* =====================================================================================
* Tabela suplementar: Bond e longo prazo
* =====================================================================================
use "$RINT/bond.dta", clear
list, noobs sep(4)
rv_new, ncol(8) head1("Conventional timing (t_p)" "" "" "" "T3 timing (t_p − 1)" "" "" "") ///
    head2("Pooled OLS" "Fixed effects" "System GMM" "BC-FE" "Pooled OLS" "Fixed effects" "System GMM" "BC-FE")
foreach row in rho b {
    local cb ""
    local cs ""
    foreach tim in draft T3 {
        foreach est in ols fe gmm bc {
            quietly summ `row' if tim == "`tim'" & est == "`est'"
            local b = r(mean)
            quietly summ se`=cond("`row'" == "rho", "rho", "")' if tim == "`tim'" & est == "`est'"
            local se = r(mean)
            rv_fmt `b' %12.3f `=2 * normal(-abs(`b' / `se'))'
            local cb `"`cb' "`r(s)'""'
            rv_fmt `se' %12.3f
            local cs `"`cs' "(`r(s)')""'
        }
    }
    rv_row "`=cond("`row'" == "rho", "Lagged growth (previous period)", "Wage bill (% of GDP)")'" `cb'
    rv_row "" `cs'
}
local cok ""
foreach tim in draft T3 {
    foreach k in ols fe gmm bc {
        quietly summ rho if tim == "`tim'" & est == "`k'"
        local r_`k' = r(mean)
    }
    local ok1 = cond(`r_gmm' <= `r_ols' & `r_gmm' >= `r_fe', "Yes", "No")
    local ok2 = cond(`r_bc' <= `r_ols' & `r_bc' >= `r_fe', "Yes", "No")
    local cok `"`cok' "" "" "`ok1'" "`ok2'""'
}
rv_row "Lagged growth within the [FE, OLS] bounds" `cok'
local cn ""
local cc ""
foreach tim in draft T3 {
    foreach est in ols fe gmm bc {
        quietly summ N if tim == "`tim'" & est == "`est'"
        local cn `"`cn' "`=string(r(mean), "%9.0fc")'""'
        quietly summ nc if tim == "`tim'" & est == "`est'"
        local cc `"`cc' "`=r(mean)'""'
    }
}
rv_row "Observations (common sample)" `cn'
rv_row "Countries" `cc'
rv_mid
use "$RINT/longo.dta", clear
list, noobs sepby(w)
rv_row "Long-run coefficient of the lagged wage bill (annual)" "PMG" "MG" "DFE" "CCE-MG" "CS-ARDL(1,1)" "CS-DL" ""
foreach W in wbL wbH {
    local cb ""
    local cs ""
    foreach m in pmg mg dfe ccemg csardl csdl {
        quietly summ b if w == "`W'" & m == "`m'"
        if r(N) == 0 {
            local cb `"`cb' "n.a.""'
            local cs `"`cs' """'
            continue
        }
        local b = r(mean)
        quietly summ se if w == "`W'" & m == "`m'"
        local se = r(mean)
        rv_fmt `b' %12.3f `=2 * normal(-abs(`b' / `se'))'
        local cb `"`cb' "`r(s)'""'
        rv_fmt `se' %12.3f
        local cs `"`cs' "(`r(s)')""'
    }
    rv_row "`=cond("`W'" == "wbL", "Wage bill, % of GDP, t − 1", "Wage bill, % of trend GDP (Hamilton), t − 1")'" `cb' ""
    rv_row "" `cs' ""
}
quietly summ ng if m == "pmg"
local ngp = r(mean)
import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
foreach k in lr_wbL_hausman lr_wbH_hausman cd_wb cd_wb_p cd_wb_l1 cd_wb_l1_p bond_draft_N bond_T3_N {
    quietly levelsof value if key == "`k'", local(`k') clean
    local `k' : word 1 of ``k''
}
rv_out TabS_bond_longrun, landscape ///
    title("Table S11. Bond check on a common sample and long-run estimators") ///
    notes("Upper panel: five-year averages; the four estimators use the same country-periods (intersection of their own samples: `bond_draft_N' observations with the conventional timing and `bond_T3_N' with T3). The difference in countries between system GMM and fixed effects in the conventional specification came from 15 countries with a single observation (singletons), which fixed effects drop and pooled OLS and system GMM keep. Pooled OLS (clustered SE), fixed effects with country and period effects (clustered SE), two-step system GMM with collapsed instruments and Windmeijer-corrected SE, and the bias-corrected fixed-effects estimator of Breitung, Kripfganz and Hayakawa (2022) with robust SE, which assumes the regressors other than lagged growth are strictly exogenous. A consistent estimator of the coefficient of lagged growth should lie between the fixed-effects (downward-biased) and pooled OLS (upward-biased) estimates. Lower panel: annual panel 1996–2023, countries with at least 20 complete annual observations; ARDL models of growth on the lagged wage bill, investment, openness, inflation and population growth. PMG (common long run), MG and DFE estimated with xtpmg; Hausman test of PMG against MG: p = `lr_wbL_hausman' (% of GDP) and `lr_wbH_hausman' (% of trend GDP). CCE-MG (static), CS-ARDL(1,1) and CS-DL (xtdcce2) add cross-sectional averages (Pesaran, 2006; Chudik et al., 2016). Pesaran CD statistic on the residuals of the annual models of Table 1: `cd_wb' (p = `cd_wb_p') with the contemporaneous ratio and `cd_wb_l1' (p = `cd_wb_l1_p') with the lagged ratio. * p<0.10, ** p<0.05, *** p<0.01.")

log close
