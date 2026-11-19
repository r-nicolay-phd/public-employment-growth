* 03_escala.do -- Bloco 3: evidencias anual, dinamica, quinquenal e WWBI na mesma escala
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 3. Objeto: efeito sobre o crescimento medio anual do PIB per capita em
* t_p ... t_p + 4 de uma folha 1 ponto do PIB maior, mantida desde t_p - 1.
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/03_escala.log", replace text
local BR = cond("$BOOTR" == "", 999, real("$BOOTR"))

* ---------------------------------------------------------------- base anual com cinco defasagens
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1985, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
forvalues j = 1/5 {
    gen wb_l`j' = L`j'.wb
}
gen wbham_l1 = L.wb_ham
egen double ma5 = rowmean(wb_l1-wb_l5)
egen byte n5 = rownonmiss(wb_l1-wb_l5)
replace ma5 = . if n5 < 5
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
gen byte sDL = sA & n5 == 5
gen int period = floor((year - 1979) / 5)
count if sDL
save "$RINT/esc_annual.dta", replace

* efeito implicito: e_h = sum_{j <= h+1} b_j + rho e_{h-1}; media de h = 0..4
local e0 "(_b[wb_l1])"
local e1 "(_b[wb_l1] + _b[wb_l2] + _b[g_l1] * `e0')"
local e2 "(_b[wb_l1] + _b[wb_l2] + _b[wb_l3] + _b[g_l1] * `e1')"
local e3 "(_b[wb_l1] + _b[wb_l2] + _b[wb_l3] + _b[wb_l4] + _b[g_l1] * `e2')"
local e4 "(_b[wb_l1] + _b[wb_l2] + _b[wb_l3] + _b[wb_l4] + _b[wb_l5] + _b[g_l1] * `e3')"
local EDL "((`e0' + `e1' + `e2' + `e3' + `e4') / 5)"
local m0 "(_b[ma5] * 1 / 5)"
local m1 "(_b[ma5] * 2 / 5 + _b[g_l1] * `m0')"
local m2 "(_b[ma5] * 3 / 5 + _b[g_l1] * `m1')"
local m3 "(_b[ma5] * 4 / 5 + _b[g_l1] * `m2')"
local m4 "(_b[ma5] * 5 / 5 + _b[g_l1] * `m3')"
local EMA "((`m0' + `m1' + `m2' + `m3' + `m4') / 5)"
global EDL "`EDL'"
global EMA "`EMA'"

tempname P
postfile `P' str10 item str90 lab double(b se lo hi p F) long(N nc) str60 ci_note using "$RINT/esc_res.dta", replace
capture program drop pnl
program define pnl
    args P item lab
    matrix bb = r(b)
    matrix VV = r(V)
    local b = bb[1, 1]
    local se = sqrt(VV[1, 1])
    post `P' ("`item'") ("`lab'") (`b') (`se') (`b' - 1.96 * `se') (`b' + 1.96 * `se') (2 * normal(-abs(`b' / `se'))) (.) (e(N)) (e(N_g)) ("delta method")
end
xtscc g wb_l1 wb_l2 wb_l3 wb_l4 wb_l5 $XA i.year if sDL, fe lag($DKLAG)
nlcom $EDL
pnl `P' ann_dl "Annual: ratio in t − 1 to t − 5 (implied effect)"
xtscc g ma5 $XA i.year if sDL, fe lag($DKLAG)
nlcom $EMA
pnl `P' ann_ma "Annual: five-year moving average of the lagged ratio (implied effect)"

* ---------------------------------------------------------------- projecoes locais, choque (a)
use "$KIN2/lp2_base.dta", clear
xtset id year
forvalues h = 0/5 {
    quietly xtscc dwa`h' sa sa_l1 sa_l2 g_l1 g_l2 i.year if sY, fe lag($DKLAG)
    post `P' ("lp_w`h'") ("Shock (a): response of the wage bill ratio (points of GDP), h = `h'") (_b[sa]) (_se[sa]) ///
        (_b[sa] - invttail(e(df_r), 0.025) * _se[sa]) (_b[sa] + invttail(e(df_r), 0.025) * _se[sa]) (2 * ttail(e(df_r), abs(_b[sa] / _se[sa]))) (.) (e(N)) (e(N_g)) ("")
    quietly xtscc dy`h' sa sa_l1 sa_l2 g_l1 g_l2 i.year if sY, fe lag($DKLAG)
    post `P' ("lp_y`h'") ("Shock (a): response of 100 × log GDP per capita, h = `h'") (_b[sa]) (_se[sa]) ///
        (_b[sa] - invttail(e(df_r), 0.025) * _se[sa]) (_b[sa] + invttail(e(df_r), 0.025) * _se[sa]) (2 * ttail(e(df_r), abs(_b[sa] / _se[sa]))) (.) (e(N)) (e(N_g)) ("")
}
egen double MW4 = rowmean(dwa0-dwa4)
egen byte nw = rownonmiss(dwa0-dwa4)
replace MW4 = . if nw < 5
gen double G4y = dy4 / 5
gen byte sIV = sY & !missing(G4y, MW4, sa, sa_l1, sa_l2, g_l1, g_l2)
ivreghdfe G4y (MW4 = sa) sa_l1 sa_l2 g_l1 g_l2 if sIV, absorb(id year) dkraay(4)
local bl = _b[MW4]
local sel = _se[MW4]
local Fl = e(widstat)
local Nl = e(N)
local arci ""
if `Fl' < 10 {
    capture noisily weakiv ivreg2 G4y sa_l1 sa_l2 g_l1 g_l2 i.year i.id (MW4 = sa) if sIV, cluster(id)
    if !_rc local arci "`e(ar_cset)'"
}
post `P' ("lp_iv") ("Local projections: LP-IV, average growth over h = 0–4 per point of ratio maintained") (`bl') (`sel') ///
    (`bl' - 1.96 * `sel') (`bl' + 1.96 * `sel') (2 * normal(-abs(`bl' / `sel'))) (`Fl') (`Nl') (.) ("`arci'")
rv_kv b3_lp_F `=string(`Fl', "%9.3f")'
save "$RINT/esc_lp.dta", replace

* ---------------------------------------------------------------- quinquenal e WWBI
use "$RINT/q5_base.dta", clear
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
post `P' ("T3_355") ("Five-year: preferred specification (355)") (_b[wb_m1]) (_se[wb_m1]) (_b[wb_m1] - invttail(e(df_r), 0.025) * _se[wb_m1]) ///
    (_b[wb_m1] + invttail(e(df_r), 0.025) * _se[wb_m1]) (2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1]))) (.) (e(N)) (e(N_clust)) ("")
reghdfe g wb_m1 $XP i.period if in311, absorb(id) vce(cluster id)
post `P' ("T3_311") ("Five-year: preferred specification, common bias sample (311)") (_b[wb_m1]) (_se[wb_m1]) (_b[wb_m1] - invttail(e(df_r), 0.025) * _se[wb_m1]) ///
    (_b[wb_m1] + invttail(e(df_r), 0.025) * _se[wb_m1]) (2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1]))) (.) (e(N)) (e(N_clust)) ("")
use "$KIN3/tam_base.dta", clear
foreach s in c d {
    reghdfe g wb_m1 $XP i.period if s`s' & !missing(wb_m1), absorb(id) vce(cluster id)
    local lb = cond("`s'" == "c", "WWBI: wage bill in t_p − 1, registered H2 sample", "WWBI: wage bill in t_p − 1, strict H2 sample")
    post `P' ("wwbi_`s'") ("`lb'") (_b[wb_m1]) (_se[wb_m1]) (_b[wb_m1] - invttail(e(df_r), 0.025) * _se[wb_m1]) ///
        (_b[wb_m1] + invttail(e(df_r), 0.025) * _se[wb_m1]) (2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1]))) (.) (e(N)) (e(N_clust)) ("")
}
* harmonizado: pais-periodos da amostra H2 registrada com a folha em t_p - 1 que estao na amostra de T3
gen byte sH = sc & !missing(wb_m1) & sa
keep if sH
keep id period
gen byte hz = 1
tempfile hz
save `hz'
use "$KIN3/tam_base.dta", clear
merge 1:1 id period using `hz', nogen
replace hz = 0 if missing(hz)
reghdfe g wb_m1 $XP i.period if hz, absorb(id) vce(cluster id)
post `P' ("h_T3") ("Harmonised: five-year preferred specification (= WWBI estimate) on the common country-periods") (_b[wb_m1]) (_se[wb_m1]) ///
    (_b[wb_m1] - invttail(e(df_r), 0.025) * _se[wb_m1]) (_b[wb_m1] + invttail(e(df_r), 0.025) * _se[wb_m1]) (2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1]))) (.) (e(N)) (e(N_clust)) ("")
use `hz', clear
expand 5
bysort id period: gen year = 1979 + 5 * period + _n - 1
keep id year
tempfile hzy
save `hzy'
use "$RINT/esc_annual.dta", clear
merge 1:1 id year using `hzy', keep(master match) gen(_h)
gen byte sHA = sDL & _h == 3
count if sHA
capture noisily xtscc g wb_l1 wb_l2 wb_l3 wb_l4 wb_l5 $XA i.year if sHA, fe lag($DKLAG)
if !_rc {
    capture noisily nlcom $EDL
    if !_rc pnl `P' h_ann "Harmonised: annual implied effect on the years of the common country-periods"
}
postclose `P'

* ---------------------------------------------------------------- bootstrap de pares de paises (mesmos sorteios)
use "$RINT/esc_annual.dta", clear
keep if sDL
keep id year g wb_l1-wb_l5 $XA
tempfile an
save `an'
use "$RINT/q5_base.dta", clear
keep id period g wb_m1 in311 $XP
tempfile q5
save `q5'
use "$KIN3/tam_base.dta", clear
keep if sc & !missing(wb_m1)
keep id period g wb_m1 $XP
tempfile ww
save `ww'
use "$RINT/esc_lp.dta", clear
keep if sIV
keep id year G4y MW4 sa sa_l1 sa_l2 g_l1 g_l2
tempfile lp
save `lp'
use `an', clear
append using `q5'
append using `ww'
append using `lp'
keep id
duplicates drop
tempfile ids
save `ids'
capture program drop esc_est
program define esc_est, rclass
    args an q5 ww lp map
    use `an', clear
    joinby id using `map'
    quietly reghdfe g wb_l1 wb_l2 wb_l3 wb_l4 wb_l5 $XA i.year, absorb(bid)
    local e0 = _b[wb_l1]
    local e1 = _b[wb_l1] + _b[wb_l2] + _b[g_l1] * `e0'
    local e2 = _b[wb_l1] + _b[wb_l2] + _b[wb_l3] + _b[g_l1] * `e1'
    local e3 = _b[wb_l1] + _b[wb_l2] + _b[wb_l3] + _b[wb_l4] + _b[g_l1] * `e2'
    local e4 = _b[wb_l1] + _b[wb_l2] + _b[wb_l3] + _b[wb_l4] + _b[wb_l5] + _b[g_l1] * `e3'
    return scalar ann = (`e0' + `e1' + `e2' + `e3' + `e4') / 5
    use `q5', clear
    joinby id using `map'
    quietly reghdfe g wb_m1 $XP i.period, absorb(bid)
    return scalar t3 = _b[wb_m1]
    use `ww', clear
    joinby id using `map'
    quietly reghdfe g wb_m1 $XP i.period, absorb(bid)
    return scalar ww = _b[wb_m1]
    use `lp', clear
    joinby id using `map'
    quietly reghdfe G4y sa sa_l1 sa_l2 g_l1 g_l2, absorb(bid year)
    local rf = _b[sa]
    quietly reghdfe MW4 sa sa_l1 sa_l2 g_l1 g_l2, absorb(bid year)
    return scalar lp = `rf' / _b[sa]
end
tempname B
postfile `B' int r double(ann t3 ww lp) using "$RINT/esc_boot.dta", replace
set seed 20261117
forvalues r = 1/`BR' {
    quietly {
        use `ids', clear
        bsample
        gen long bid = _n
        tempfile map
        save `map'
        capture esc_est `an' `q5' `ww' `lp' `map'
        if !_rc post `B' (`r') (r(ann)) (r(t3)) (r(ww)) (r(lp))
    }
    if mod(`r', 100) == 0 di "  bootstrap: `r'"
}
postclose `B'

* testes de compatibilidade
use "$RINT/esc_res.dta", clear
foreach it in ann_dl T3_355 wwbi_c lp_iv {
    quietly summ b if item == "`it'"
    local o_`it' = r(mean)
}
use "$RINT/esc_boot.dta", clear
quietly count
local nb = r(N)
tempname T
postfile `T' str16 pair double(d lo hi p sd) long(nb) using "$RINT/esc_tests.dta", replace
foreach pr in "ann t3 ann_dl T3_355" "ann ww ann_dl wwbi_c" "t3 ww T3_355 wwbi_c" "lp t3 lp_iv T3_355" {
    tokenize `pr'
    gen double z = `1' - `2'
    quietly summ z
    local sd = r(sd)
    local mz = r(mean)
    _pctile z, p(2.5 97.5)
    local lo = r(r1)
    local hi = r(r2)
    local d = `o_`3'' - `o_`4''
    local pp = 2 * normal(-abs(`d' / `sd'))
    post `T' ("`1' − `2'") (`d') (`d' + `lo' - `mz') (`d' + `hi' - `mz') (`pp') (`sd') (`nb')
    drop z
}
quietly summ ann
local sda = r(sd)
foreach v in -0.14 -0.33 {
    local pv = 2 * normal(-abs((`o_ann_dl' - (`v')) / `sda'))
    post `T' ("ann vs `v'") (`o_ann_dl' - (`v')) (.) (.) (`pv') (`sda') (`nb')
}
postclose `T'
use "$RINT/esc_tests.dta", clear
list, noobs
quietly summ p if inlist(pair, "ann vs -0.14", "ann vs -0.33")
local inc = (r(min) < 0.05)
rv_kv b3_annual_incompatible `inc'
quietly summ p if pair == "ann vs -0.14"
rv_kv b3_p_ann_014 `=string(r(mean), "%9.4f")'
quietly summ p if pair == "ann vs -0.33"
rv_kv b3_p_ann_033 `=string(r(mean), "%9.4f")'
use "$RINT/esc_res.dta", clear
list item b lo hi p F N nc ci_note, noobs sep(0)
kcsv "$RINT/esc_res.dta" Table_A9_part_common_scale
kcsv "$RINT/esc_tests.dta" Table_A9_part_common_scale_tests
log close
