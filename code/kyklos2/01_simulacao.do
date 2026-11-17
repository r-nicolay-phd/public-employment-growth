* 01_simulacao.do -- Bloco 1: simulacao sob a hipotese nula (ancorada, estacionaria, registrada), grade de eps
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 1. Folha sintetica sem efeito sobre o crescimento; PIB, crescimento e
* controles observados. Em cada replicacao: regressoes anuais da Tabela 1 (mesmo ano, Hamilton, HP unilateral,
* defasada) e T3; DP dentro do pais, AR(1) e correlacao com o placebo da razao sintetica.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/01_simulacao.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
do "$ROOT/code/kyklos2/sim2_mata.do"

* ---------------------------------------------------------------- base anual (mesma construcao da Tabela 1)
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1970, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & ///
    !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g) & inrange(year, 1996, 2023)
count if sA
gen double lS = ln(wagebill_gdp / 100)
gen double lS_l1 = L.lS
gen double dlS = lS - lS_l1
gen double lWn = ln(wagebill_gdp / 100 * gdp_nom_lcu)
gen double dlW = lWn - L.lWn
gen double dlYn = ln(gdp_nom_lcu) - ln(L.gdp_nom_lcu)
bysort id (year): gen double w0 = lWn if !missing(lWn) & sum(!missing(lWn)) == 1
sort id year
xtset id year
gen int period = floor((year - 1979) / 5)
gen int year0 = 1979 + 5 * period
gen byte first = year == year0
gen byte okA = !missing(lS_l1, dlYn)
* variante estacionaria: rho (efeitos fixos de pais) e mu_i na serie observada
reghdfe lS lS_l1, absorb(id)
local rho = _b[lS_l1]
gen byte sRho = e(sample)
bysort id: egen double muS = mean(cond(sRho, lS, .))
sort id year
xtset id year
rv_kv sim2_rho `=string(`rho', "%9.4f")'
di "rho (AR(1) com efeitos fixos de pais, ln s observada) = `rho'"
* T3: amostra e variaveis quinquenais nas linhas do primeiro ano do periodo
preserve
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
quietly reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
gen byte sT3 = e(sample)
local oT3 = _b[wb_m1]
local nT3 = e(N)
keep id period g lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1 sT3
rename (g lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1) (P_g P_lny0 P_hc P_inv P_open P_infl P_popg P_ctot)
gen byte first = 1
tempfile p5
save `p5'
restore
merge m:1 id period first using `p5', keep(master match) nogen
replace sT3 = 0 if missing(sT3)
gen int perT = period if sT3
sort id year
xtset id year
count if sT3
di "T3 observado = `oT3' (N = `nT3')"
save "$RINT/sim2_base.dta", replace

* coeficientes, DP dentro e AR(1) observados
foreach m in wb wb_ham wb_hp1 wb_l1 {
    quietly reghdfe g `m' $XA if sA, absorb(id year)
    local o_`m' = _b[`m']
}
bysort id: egen double _m = mean(cond(sA, wb, .))
gen double _d = wb - _m if sA
quietly summ _d
local sdo = r(sd)
xtset id year
quietly regress wb L.wb if sA
local aro = _b[L.wb]
quietly corr wb wb_placebo if sA
local rpo = r(rho)
tempname P
postfile `P' str4 var double eps int rep str8 meas double b using "$RINT/sim2_draws.dta", replace
foreach m in wb wb_ham wb_hp1 wb_l1 {
    post `P' ("obs") (.) (0) ("`m'") (`o_`m'')
}
post `P' ("obs") (.) (0) ("T3") (`oT3')
post `P' ("obs") (.) (0) ("sdw") (`sdo')
post `P' ("obs") (.) (0) ("ar1") (`aro')
post `P' ("obs") (.) (0) ("rpl") (`rpo')

* ---------------------------------------------------------------- rotina de uma replicacao: ws = razao sintetica (% PIB)
capture program drop sim_regs
program define sim_regs
    args P var eps r
    quietly {
        xtset id year
        gen double s_wb = ws
        gen double s_wb_ham = ws * exp(lnY - lnY_ham)
        gen double s_wb_hp1 = ws * exp(lnY - lnY_hp1)
        gen double s_wb_l1 = L.ws
        * coeficientes pontuais por Frisch-Waugh com projecao guardada (iguais aos de reghdfe; ver sim2_mata.do)
        foreach m in wb wb_ham wb_hp1 wb_l1 {
            mata: _fwlb("A_`m'", "g", "s_`m'", "$XA", "id", "year", "sA", "BB")
            post `P' ("`var'") (`eps') (`r') ("`m'") (BB[1, 1])
        }
        mata: _fwlb("T3", "P_g", "s_wb_l1", "P_lny0 P_hc P_inv P_open P_infl P_popg P_ctot", "id", "perT", "sT3", "BB")
        post `P' ("`var'") (`eps') (`r') ("T3") (BB[1, 1])
        if `r' == 1 {
            foreach m in wb wb_l1 {
                reghdfe g s_`m' $XA if sA, absorb(id year)
                mata: _fwlb("A_`m'", "g", "s_`m'", "$XA", "id", "year", "sA", "BB")
                noisily di "conferencia FWL x reghdfe (`var', eps = `eps', `m'): " %12.8f _b[s_`m'] " " %12.8f BB[1, 1]
                assert reldif(_b[s_`m'], BB[1, 1]) < 1e-6
            }
        }
        bysort id: egen double _ms = mean(cond(sA, ws, .))
        gen double _ds = ws - _ms if sA
        summ _ds
        post `P' ("`var'") (`eps') (`r') ("sdw") (r(sd))
        sort id year
        xtset id year
        capture regress ws L.ws if sA
        post `P' ("`var'") (`eps') (`r') ("ar1") (cond(_rc, ., _b[L.ws]))
        corr ws wb_placebo if sA
        post `P' ("`var'") (`eps') (`r') ("rpl") (r(rho))
    }
end

set seed 20261115
* (1) ancorada: ln s_t = ln s_obs,t-1 - (1 - eps) dln Y_t + u_t, u recentrado no pais
foreach eps in 0 0.25 0.48 0.75 1 {
    use "$RINT/sim2_base.dta", clear
    gen double e = dlS + (1 - `eps') * dlYn
    bysort id: egen double _me = mean(e)
    replace e = e - _me
    drop _me
    sort id year
    tempfile b_anc
    save `b_anc'
    di as result "ancorada, eps = `eps'"
    forvalues r = 1/`R' {
        quietly {
            use `b_anc', clear
            gen double ud = .
            mata: _drawc("id", "e", "okA", "ud")
            gen double ws = 100 * exp(lS_l1 - (1 - `eps') * dlYn + ud)
        }
        sim_regs `P' anc `eps' `r'
        if mod(`r', 250) == 0 di "  replicacao `r'"
    }
}
* (2) estacionaria (eps = 0,48)
local eps = 0.48
use "$RINT/sim2_base.dta", clear
gen double e = lS - muS - `rho' * (lS_l1 - muS) + (1 - `eps') * dlYn
bysort id: egen double _me = mean(e)
replace e = e - _me
drop _me
sort id year
tempfile b_st
save `b_st'
di as result "estacionaria, eps = `eps'"
forvalues r = 1/`R' {
    quietly {
        use `b_st', clear
        gen double lss = .
        mata: _stat("id", "lS", "dlYn", "e", "muS", "lss", `rho', `eps')
        gen double ws = 100 * exp(lss)
    }
    sim_regs `P' sta `eps' `r'
    if mod(`r', 250) == 0 di "  replicacao `r'"
}
* (3) registrada (passeio aleatorio em ln W, Tabela A5 antiga), mesma grade
foreach eps in 0 0.25 0.48 0.75 1 {
    use "$RINT/sim2_base.dta", clear
    gen double u = dlW - `eps' * dlYn
    tempfile b_reg
    save `b_reg'
    di as result "registrada, eps = `eps'"
    forvalues r = 1/`R' {
        quietly {
            use `b_reg', clear
            gen double lWs = .
            mata: _wsim("id", "u", "dlYn", "w0", "lWs", `eps')
            gen double ws = 100 * exp(lWs) / gdp_nom_lcu
        }
        sim_regs `P' reg `eps' `r'
        if mod(`r', 250) == 0 di "  replicacao `r'"
    }
}
postclose `P'
log close
