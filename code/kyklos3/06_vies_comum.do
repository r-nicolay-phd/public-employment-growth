* 06_vies_comum.do -- Bloco 5: faixa de sensibilidade de T3 numa amostra comum, nula descontada, sem um periodo
* Plano: docs/plan_addendum_kyklos_3.md, Bloco 5. Base quinquenal: data/interim/kyklos2/vies_base.dta (amostra de T3);
* base anual das simulacoes: data/interim/kyklos2/sim2_base.dta. Variantes: T3; + hiato; + crescimento de p - 1;
* + ambos; hiato negativo x folha (efeito medio); 2SLS (razoes de t_p - 2 e t_p - 3).
* Nula: desenho com reversao a media (rho = 0,870, eps = 0,48) e desenho ancorado calibrado pelo DP (k do Bloco 2).
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/06_vies_comum.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
local BR = cond("$BOOTR" == "", 999, real("$BOOTR"))
do "$ROOT/code/kyklos2/sim2_mata.do"
kget "$RINT/kv.csv" b2_k_sd
local k = real("`r(v)'")
if missing(`k') local k = 0.30
kget "$KIN2/kv.csv" sim2_rho
local rho = real("`r(v)'")
local eps = 0.48
di "k = `k'; rho = `rho'"

* ---------------------------------------------------------------- amostra comum
use "$KIN2/vies_base.dta", clear
gen byte sCm = !missing(g, wb_m1, gap_m1, Lg, neg, z2, z3, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
keep if sCm
quietly reghdfe g wb_m1 Lg gap_m1 $XP i.period, absorb(id) vce(cluster id)
keep if e(sample)
quietly ivregress 2sls g (wb_m1 = z2 z3) $XP i.period i.id, vce(cluster id)
keep if e(sample)
count
local Nc = r(N)
rv_kv b5_Ncommon `Nc'
quietly summ neg
local fneg = r(mean)
rv_kv b5_share_neg `=string(`fneg', "%9.4f")'
keep id period year0 g wb_m1 gap_m1 Lg neg z2 z3 $XP
save "$RINT/vc_base.dta", replace

* variantes: observado ou sintetico (prefixo das variaveis: wb_m1 z2 z3 ou s_m1 s_z2 s_z3)
capture program drop vc_est
program define vc_est, rclass
    args idv w z2v z3v fneg
    tempvar wx
    quietly gen double `wx' = `w' * neg
    quietly reghdfe g `w' $XP i.period, absorb(`idv')
    return scalar T3 = _b[`w']
    quietly reghdfe g `w' gap_m1 $XP i.period, absorb(`idv')
    return scalar i1 = _b[`w']
    quietly reghdfe g `w' Lg $XP i.period, absorb(`idv')
    return scalar i2a = _b[`w']
    quietly reghdfe g `w' Lg gap_m1 $XP i.period, absorb(`idv')
    return scalar i2b = _b[`w']
    quietly reghdfe g `w' `wx' neg $XP i.period, absorb(`idv')
    return scalar i3 = _b[`w'] + `fneg' * _b[`wx']
    capture quietly ivreghdfe g $XP (`w' = `z2v' `z3v') i.period, absorb(`idv')
    return scalar i4 = cond(_rc, ., _b[`w'])
end

* ---------------------------------------------------------------- estimativas observadas, p de bootstrap selvagem
use "$RINT/vc_base.dta", clear
gen double wbXneg = wb_m1 * neg
tempname P
postfile `P' str4 item double(b pboot blo bhi) long(N) using "$RINT/vc_obs.dta", replace
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
kboot wb_m1
post `P' ("T3") (_b[wb_m1]) (r(p)) (r(lo)) (r(hi)) (e(N))
reghdfe g wb_m1 gap_m1 $XP i.period, absorb(id) vce(cluster id)
kboot wb_m1
post `P' ("i1") (_b[wb_m1]) (r(p)) (r(lo)) (r(hi)) (e(N))
reghdfe g wb_m1 Lg $XP i.period, absorb(id) vce(cluster id)
kboot wb_m1
post `P' ("i2a") (_b[wb_m1]) (r(p)) (r(lo)) (r(hi)) (e(N))
reghdfe g wb_m1 Lg gap_m1 $XP i.period, absorb(id) vce(cluster id)
kboot wb_m1
post `P' ("i2b") (_b[wb_m1]) (r(p)) (r(lo)) (r(hi)) (e(N))
reghdfe g wb_m1 wbXneg neg $XP i.period, absorb(id) vce(cluster id)
local bavg = _b[wb_m1] + `fneg' * _b[wbXneg]
kboot {wb_m1 + `fneg' * wbXneg = 0}
post `P' ("i3") (`bavg') (r(p)) (r(lo)) (r(hi)) (e(N))
ivregress 2sls g (wb_m1 = z2 z3) $XP i.period i.id, vce(cluster id)
local biv = _b[wb_m1]
local Niv = e(N)
capture noisily boottest wb_m1, reps(9999) weighttype(webb) seed(20261116) nograph
if !_rc {
    matrix CI = r(CI)
    post `P' ("i4") (`biv') (r(p)) (CI[1, 1]) (CI[1, 2]) (`Niv')
}
else post `P' ("i4") (`biv') (.) (.) (.) (`Niv')
postclose `P'
use "$RINT/vc_obs.dta", clear
list, noobs

* ---------------------------------------------------------------- sinteticos: rotina que gera s_m1, s_z2, s_z3 por pais
capture program drop vc_syn
program define vc_syn
    * vc_syn desenho idvar -> ws (razao sintetica anual, % PIB) e variaveis do primeiro ano do periodo
    args des idv k rho eps
    if "`des'" == "sta" {
        gen double lss = .
        mata: _stat("`idv'", "lS", "dlYn", "e_sta", "muS", "lss", `rho', `eps')
        gen double ws = 100 * exp(lss)
    }
    else {
        gen double ud = .
        mata: _drawc("`idv'", "e_anc", "okA", "ud")
        gen double ws = 100 * exp(lS_l1 - (1 - `eps') * dlYn + `k' * ud)
    }
end
use "$KIN2/sim2_base.dta", clear
keep id year lS lS_l1 dlS dlYn okA muS period first
gen double e_anc = dlS + (1 - `eps') * dlYn
bysort id: egen double _m = mean(e_anc)
replace e_anc = e_anc - _m
drop _m
xtset id year
gen double e_sta = lS - muS - `rho' * (lS_l1 - muS) + (1 - `eps') * dlYn
bysort id: egen double _m = mean(e_sta)
replace e_sta = e_sta - _m
drop _m
sort id year
save "$RINT/vc_annual.dta", replace
capture program drop vc_first
program define vc_first
    * a partir de ws (anual, ordenado por idv year), devolve id period s_m1 s_z2 s_z3 nas linhas do primeiro ano
    args idv
    sort `idv' year
    by `idv': gen double s_m1 = ws[_n - 1] if first & year[_n - 1] == year - 1
    by `idv': gen double s_z2 = ws[_n - 2] if first & year[_n - 2] == year - 2
    by `idv': gen double s_z3 = ws[_n - 3] if first & year[_n - 3] == year - 3
    keep if first
end

* ---------------------------------------------------------------- media da nula na amostra inteira (1.000 simulacoes)
tempname S
postfile `S' str4 des int rep double(T3 i1 i2a i2b i3 i4) using "$RINT/vc_null.dta", replace
set seed 20261116
foreach des in sta cal {
    forvalues r = 1/`R' {
        quietly {
            use "$RINT/vc_annual.dta", clear
            vc_syn `des' id `k' `rho' `eps'
            vc_first id
            keep id period s_m1 s_z2 s_z3
            merge 1:1 id period using "$RINT/vc_base.dta", keep(using match) nogen
            vc_est id s_m1 s_z2 s_z3 `fneg'
        }
        post `S' ("`des'") (`r') (r(T3)) (r(i1)) (r(i2a)) (r(i2b)) (r(i3)) (r(i4))
        if mod(`r', 250) == 0 di "  nula `des': `r'"
    }
}
postclose `S'

* ---------------------------------------------------------------- bootstrap de pares com a nula refeita em cada sorteio
use "$RINT/vc_base.dta", clear
keep id
duplicates drop
tempfile ids
save `ids'
tempname B
postfile `B' int r str4 kind double(T3 i1 i2a i2b i3 i4) using "$RINT/vc_boot.dta", replace
set seed 20261116
forvalues r = 1/`BR' {
    quietly {
        use `ids', clear
        bsample
        gen long bid = _n
        tempfile map
        save `map'
        use "$RINT/vc_base.dta", clear
        joinby id using `map'
        tempfile b5
        save `b5'
        vc_est bid wb_m1 z2 z3 `fneg'
        post `B' (`r') ("obs") (r(T3)) (r(i1)) (r(i2a)) (r(i2b)) (r(i3)) (r(i4))
        foreach des in sta cal {
            use "$RINT/vc_annual.dta", clear
            joinby id using `map'
            sort bid year
            vc_syn `des' bid `k' `rho' `eps'
            vc_first bid
            keep bid period s_m1 s_z2 s_z3
            merge 1:1 bid period using `b5', keep(using match) nogen
            vc_est bid s_m1 s_z2 s_z3 `fneg'
            post `B' (`r') ("`des'") (r(T3)) (r(i1)) (r(i2a)) (r(i2b)) (r(i3)) (r(i4))
        }
    }
    if mod(`r', 100) == 0 di "  bootstrap: `r'"
}
postclose `B'

* ---------------------------------------------------------------- resumo
use "$RINT/vc_null.dta", clear
collapse (mean) T3 i1 i2a i2b i3 i4, by(des)
tempfile nm
save `nm'
use "$RINT/vc_boot.dta", clear
reshape wide T3 i1 i2a i2b i3 i4, i(r) j(kind) string
tempname Q
postfile `Q' str4 item double(b dT3 dT3_lo dT3_hi adj_sta adj_sta_lo adj_sta_hi adj_cal adj_cal_lo adj_cal_hi) using "$RINT/vc_sum.dta", replace
preserve
use "$RINT/vc_obs.dta", clear
foreach it in T3 i1 i2a i2b i3 i4 {
    quietly summ b if item == "`it'"
    local o_`it' = r(mean)
}
use `nm', clear
foreach des in sta cal {
    foreach it in T3 i1 i2a i2b i3 i4 {
        quietly summ `it' if des == "`des'"
        local n_`des'_`it' = r(mean)
    }
}
restore
foreach it in T3 i1 i2a i2b i3 i4 {
    gen double d_`it' = `it'obs - T3obs
    _pctile d_`it', p(2.5 97.5)
    local dl = r(r1)
    local dh = r(r2)
    foreach des in sta cal {
        gen double a_`des'_`it' = `it'obs - `it'`des'
        _pctile a_`des'_`it', p(2.5 97.5)
        local al_`des' = r(r1)
        local ah_`des' = r(r2)
    }
    post `Q' ("`it'") (`o_`it'') (`o_`it'' - `o_T3') (`dl') (`dh') (`o_`it'' - `n_sta_`it'') (`al_sta') (`ah_sta') ///
        (`o_`it'' - `n_cal_`it'') (`al_cal') (`ah_cal')
}
quietly count
local nb = r(N)
postclose `Q'
rv_kv b5_boot_draws `nb'
use "$RINT/vc_sum.dta", clear
merge 1:1 item using "$RINT/vc_obs.dta", nogen
list, noobs
save "$RINT/vc_sum.dta", replace
kcsv "$RINT/vc_sum.dta" Table_A8_panel_bias_common_sample

* ---------------------------------------------------------------- sem um periodo (amostra inteira de T3)
use "$KIN2/vies_base.dta", clear
levelsof year0, local(ps)
tempname L
postfile `L' int year0 double(b p) long(N) using "$RINT/vc_lopo.dta", replace
foreach p of local ps {
    quietly reghdfe g wb_m1 $XP i.period if year0 != `p', absorb(id) vce(cluster id)
    post `L' (`p') (_b[wb_m1]) (2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1]))) (e(N))
}
postclose `L'
use "$RINT/vc_lopo.dta", clear
list, noobs
quietly count if p < 0.05
rv_kv b5_lopo_sig `r(N)'
rv_kv b5_lopo_n `=_N'
kcsv "$RINT/vc_lopo.dta" Table_A8_leave_one_period_out

* ---------------------------------------------------------------- regras (adendo 3, Bloco 5)
use "$RINT/vc_sum.dta", clear
quietly count if item != "T3" & abs(dT3) >= 0.05
local far = r(N)
quietly count if pboot < 0.05
local sig = r(N)
local r1 = (`far' == 0 & `sig' == 0)
quietly summ adj_sta_lo if item == "T3"
local l = r(mean)
quietly summ adj_sta_hi if item == "T3"
local r3 = (`l' <= 0 & r(mean) >= 0)
quietly summ b
rv_kv b5_range_lo `=string(r(min), "%9.4f")'
rv_kv b5_range_hi `=string(r(max), "%9.4f")'
rv_kv b5_rule_within `r1'
rv_kv b5_far `far'
rv_kv b5_rule_nullT3 `r3'
di "Bloco 5: variantes a mais de 0,05 de T3 = `far'; com p < 0,05 = `sig'; T3 - nula (reversao) inclui zero = `r3'"
log close
