* 02_vies.do -- Bloco 2: sinal e limites do vies da estimativa quinquenal predeterminada (T3)
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 2. Amostra de T3 (N = 355); variantes com periodo defasado perdem
* observacoes e sao comparadas com T3 nas mesmas observacoes.
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/02_vies.log", replace text
local BR = cond("$BOOTR" == "", 999, real("$BOOTR"))

* razoes anuais em t_p - 2 e t_p - 3 (instrumentos do item 4)
use "$KIN/anual_rv.dta", clear
keep if micro == 0
xtset id year
gen z2 = L2.wb
gen z3 = L3.wb
keep if year >= 1979
gen period = floor((year - 1979) / 5)
keep if year == 1979 + 5 * period
keep id period z2 z3
tempfile zz
save `zz'

use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
merge 1:1 id period using `zz', keep(master match) nogen
xtset id period
gen Lg = L.g
gen gap_m1 = -100 * lgap_ham_m1
gen byte neg = gap_m1 < 0 if !missing(gap_m1)
gen wbXneg = wb_m1 * neg
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
gen byte sT3 = e(sample)
keep if sT3
count
save "$RINT/vies_base.dta", replace

tempname P
postfile `P' str8 item str90 lab double(b se lo hi pboot blo bhi bT3s) long(N nc) double(Feff Jp) str80 ar ///
    using "$RINT/vies_res.dta", replace
capture program drop pvies
program define pvies
    * estimativa corrente (reghdfe, cluster por pais) -> linha; T3 reestimada nas mesmas observacoes
    args P item lab v
    local b = _b[`v']
    local se = _se[`v']
    local df = e(df_r)
    local N = e(N)
    local nc = e(N_clust)
    tempvar s
    gen byte `s' = e(sample)
    kboot `v'
    local pb = r(p)
    local bl = r(lo)
    local bh = r(hi)
    quietly reghdfe g wb_m1 $XP i.period if `s', absorb(id) vce(cluster id)
    local b0 = _b[wb_m1]
    post `P' ("`item'") ("`lab'") (`b') (`se') (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') ///
        (`pb') (`bl') (`bh') (`b0') (`N') (`nc') (.) (.) ("")
end
* T3 registrado
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
pvies `P' T3 "T3 (registered)" wb_m1
* (1) hiato em t_p - 1
reghdfe g wb_m1 gap_m1 $XP i.period, absorb(id) vce(cluster id)
pvies `P' i1 "T3 + output gap in t_p − 1" wb_m1
* (2a) crescimento de p - 1 (LSDV)
reghdfe g wb_m1 Lg $XP i.period, absorb(id) vce(cluster id)
pvies `P' i2a "T3 + growth of p − 1 (LSDV)" wb_m1
* (2b) crescimento de p - 1 e hiato
reghdfe g wb_m1 Lg gap_m1 $XP i.period, absorb(id) vce(cluster id)
gen byte s2b = e(sample)
pvies `P' i2b "T3 + growth of p − 1 + output gap in t_p − 1" wb_m1
* (3) indicador de hiato negativo e interacao
reghdfe g wb_m1 wbXneg neg $XP i.period, absorb(id) vce(cluster id)
pvies `P' i3 "T3 + negative gap × wage bill: wage bill coefficient (positive gap)" wb_m1
reghdfe g wb_m1 wbXneg neg $XP i.period, absorb(id) vce(cluster id)
pvies `P' i3x "T3 + negative gap × wage bill: interaction" wbXneg
reghdfe g wb_m1 wbXneg neg $XP i.period, absorb(id) vce(cluster id)
local N3 = e(N)
local nc3 = e(N_clust)
lincom wb_m1 + wbXneg
local bn = r(estimate)
local sen = r(se)
local dfn = r(df)
kboot {wb_m1 + wbXneg = 0}
post `P' ("i3n") ("T3 + negative gap × wage bill: wage bill after a negative gap") (`bn') (`sen') ///
    (`bn' - invttail(`dfn', 0.025) * `sen') (`bn' + invttail(`dfn', 0.025) * `sen') (r(p)) (r(lo)) (r(hi)) (.) (`N3') (`nc3') (.) (.) ("")
* (4) 2SLS com efeitos fixos: razao de t_p - 1 instrumentada pelas de t_p - 2 e t_p - 3
quietly tab period, gen(pd)
quietly tab id, gen(cd)
ivreg2 g (wb_m1 = z2 z3) $XP pd* cd*, cluster(id) partial(pd* cd*) small
local biv = _b[wb_m1]
local seiv = _se[wb_m1]
local dfiv = e(Fdf2)
local Jp = e(jp)
local Niv = e(N)
local nciv = e(N_clust)
gen byte s4 = e(sample)
local Feff = .
capture noisily weakivtest
if !_rc local Feff = r(F_eff)
di "F efetivo (Montiel Olea-Pflueger) = `Feff'"
quietly reghdfe g wb_m1 $XP i.period if s4, absorb(id) vce(cluster id)
local b0iv = _b[wb_m1]
ivregress 2sls g (wb_m1 = z2 z3) $XP i.period i.id if s4, vce(cluster id)
local pbiv = .
local bliv = .
local bhiv = .
capture noisily boottest wb_m1, reps(9999) weighttype(webb) seed(20261115) nograph
if !_rc {
    local pbiv = r(p)
    capture matrix CI = r(CI)
    if !_rc {
        local bliv = CI[1, 1]
        local bhiv = CI[1, 2]
    }
}
local ar ""
capture noisily weakiv ivreg2 g $XP pd* cd* (wb_m1 = z2 z3) if s4, cluster(id)
if !_rc local ar "`e(ar_cset)'"
post `P' ("i4") ("2SLS: ratio in t_p − 1 instrumented by the ratios in t_p − 2 and t_p − 3") (`biv') (`seiv') ///
    (`biv' - invttail(`dfiv', 0.025) * `seiv') (`biv' + invttail(`dfiv', 0.025) * `seiv') (`pbiv') (`bliv') (`bhiv') (`b0iv') ///
    (`Niv') (`nciv') (`Feff') (`Jp') ("`ar'")
drop pd* cd*
* (7) painel anual: W_t-1 / Y*_t-1 (Hamilton), com e sem o hiato em t - 1
preserve
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1991, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
gen gap_l1 = -100 * L.lgap_ham
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
foreach k in "a7 0" "a7g 1" {
    tokenize `k'
    local gx = cond(`2', "gap_l1", "")
    local lb = cond(`2', "Annual: ratio in t − 1 over Hamilton trend GDP + output gap in t − 1", "Annual: ratio in t − 1 over Hamilton trend GDP")
    xtscc g wbham_l1 `gx' $XA i.year if sA, fe lag($DKLAG)
    local b = _b[wbham_l1]
    local se = _se[wbham_l1]
    local df = e(df_r)
    local N = e(N)
    local nc = e(N_g)
    reghdfe g wbham_l1 `gx' $XA i.year if sA, absorb(id) vce(cluster id)
    kboot wbham_l1
    post `P' ("`1'") ("`lb'") (`b') (`se') ///
        (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') (r(p)) (r(lo)) (r(hi)) (.) (`N') (`nc') (.) (.) ("")
}
restore
postclose `P'

* (5) Gelbach (2016): T3 -> T3 + crescimento de p - 1 + hiato, amostra comum (s2b)
preserve
keep if s2b
quietly tab period, gen(pd)
drop pd1
quietly tab id, gen(cd)
drop cd1
b1x2 g, x1all(wb_m1 $XP pd* cd*) x2all(Lg gap_m1) x1only(wb_m1) x2delta(gG = Lg : gH = gap_m1) cluster(id)
matrix D = e(b)
matrix VD = e(V)
local NG = e(N)
local cn : colnames D
di "`cn'"
tempname G
postfile `G' str8 comp double(d se) long(N) using "$RINT/vies_gelbach.dta", replace
local k = 0
foreach c of local cn {
    local ++k
    post `G' ("`c'") (D[1, `k']) (sqrt(VD[`k', `k'])) (`NG')
}
postclose `G'
restore

* (6) gamma x delta e vies de variavel omitida (gamma_longo x pi); bootstrap de paises (pares)
capture program drop gd_est
program define gd_est, rclass
    args idv
    quietly reghdfe g Lg i.period, absorb(`idv')
    local ga = _b[Lg]
    quietly reghdfe wb_m1 Lg i.period, absorb(`idv')
    local de = _b[Lg]
    quietly reghdfe g wb_m1 Lg $XP i.period, absorb(`idv')
    local gl = _b[Lg]
    local bl = _b[wb_m1]
    quietly reghdfe Lg wb_m1 $XP i.period, absorb(`idv')
    local pi = _b[wb_m1]
    quietly reghdfe g wb_m1 $XP i.period if !missing(Lg), absorb(`idv')
    local bs = _b[wb_m1]
    return scalar ga = `ga'
    return scalar de = `de'
    return scalar gd = `ga' * `de'
    return scalar ovb = `gl' * `pi'
    return scalar dif = `bs' - `bl'
end
keep if !missing(Lg)
gd_est id
local ga = r(ga)
local de = r(de)
local gd = r(gd)
local ovb = r(ovb)
local dif = r(dif)
local Ngd = _N
di "gamma = `ga'; delta = `de'; gamma x delta = `gd'; gamma_longo x pi = `ovb'; diferenca observada = `dif'"
tempfile gb
save `gb'
tempname B
postfile `B' int r double(ga de gd ovb dif) using "$RINT/vies_gd_boot.dta", replace
set seed 20261115
forvalues r = 1/`BR' {
    quietly use `gb', clear
    quietly bsample, cluster(id) idcluster(bid)
    capture gd_est bid
    if !_rc post `B' (`r') (r(ga)) (r(de)) (r(gd)) (r(ovb)) (r(dif))
}
postclose `B'
use "$RINT/vies_gd_boot.dta", clear
tempname S
postfile `S' str4 stat double(est lo hi) long(nrep N) using "$RINT/vies_gd.dta", replace
foreach s in ga de gd ovb dif {
    _pctile `s', p(2.5 97.5)
    post `S' ("`s'") (``s'') (r(r1)) (r(r2)) (_N) (`Ngd')
}
postclose `S'
use "$RINT/vies_gd.dta", clear
list, noobs
use "$RINT/vies_res.dta", clear
list item b lo hi pboot blo bhi bT3s N nc Feff Jp ar, noobs sep(0)
use "$RINT/vies_gelbach.dta", clear
list, noobs
log close
