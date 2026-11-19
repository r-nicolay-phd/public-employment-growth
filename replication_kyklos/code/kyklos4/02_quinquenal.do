* 02_quinquenal.do -- Bloco 2 (itens 1-4): por que a estimativa quinquenal cai de -0,14 (355) para -0,02 (311)
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 2. Bases: data/analysis/kyklos2/vies_base.dta (amostra de T3, 355) e
* data/analysis/kyklos3/vc_base.dta (amostra comum, 311).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/02_quinquenal.log", replace text

* primeiro periodo de reporte da folha das GFS (primeiro periodo com a folha em t_p - 1) e crescimento anual antes de t_p
use "$KIN/p5_rv.dta", clear
keep if micro == 0
bysort id: egen int p_first = min(cond(!missing(wb_m1), period, .))
keep id period p_first merit_m1 debt_m1
tempfile pf
save `pf'
use "$KIN/anual_rv.dta", clear
keep if micro == 0
xtset id year
forvalues j = 1/5 {
    gen double gL`j' = L`j'.g
}
egen byte n5 = rownonmiss(gL1-gL5)
egen double g_prev = rowmean(gL1-gL5)
keep if year >= 1979
gen period = floor((year - 1979) / 5)
keep if year == 1979 + 5 * period
keep id period g_prev n5
tempfile gp
save `gp'

use "$KIN2/vies_base.dta", clear
merge 1:1 id period using `pf', keep(master match) nogen
merge 1:1 id period using `gp', keep(master match) nogen
merge 1:1 id period using "$KIN3/vc_base.dta", keepusing(id) keep(master match) gen(_mc)
gen byte in311 = _mc == 3
drop _mc
gen byte lost = !in311
gen byte firstrep = period == p_first
gen byte trans = inlist(iso3, "ARM", "AZE", "BLR", "EST", "GEO", "KAZ", "KGZ", "LVA", "LTU") | ///
    inlist(iso3, "MDA", "RUS", "TJK", "TKM", "UKR", "UZB", "BGR", "CZE", "HUN") | ///
    inlist(iso3, "POL", "ROU", "SVK", "SVN", "ALB", "HRV", "BIH", "SRB", "MNE") | inlist(iso3, "MKD", "XKX")
gen byte trans99 = trans & year0 < 1999
gen byte early = year0 < 1994
gen byte nineties = inlist(year0, 1989, 1994)
count
count if lost
rv_kv b2_n_lost `r(N)'
save "$RINT/q5_base.dta", replace

* (1) lista e descricao
preserve
keep if lost
sort iso3 year0
list iso3 year0 firstrep trans99 g wb_m1 lny0, noobs sep(0)
export delimited iso3 year0 firstrep trans99 early g wb_m1 lny0 merit_m1 debt_m1 using "$RTAB/Table_A8_part_lost_country_periods.csv", replace
restore
tempname D
postfile `D' str12 v double(m_lost m_kept d p) long(N) using "$RINT/q5_desc.dta", replace
foreach v in firstrep trans99 early nineties lny0 merit_m1 debt_m1 g wb_m1 {
    quietly regress `v' lost, vce(cluster id)
    local d = _b[lost]
    local p = 2 * ttail(e(df_r), abs(_b[lost] / _se[lost]))
    quietly summ `v' if lost
    local ml = r(mean)
    quietly summ `v' if !lost
    post `D' ("`v'") (`ml') (r(mean)) (`d') (`p') (e(N))
}
postclose `D'

* (2) interacao com primeiro periodo de reporte e com transicao antes de 1999
tempname G
postfile `G' str10 grp double(b0 b1 bint p_int pboot_int) long(N) using "$RINT/q5_groups.dta", replace
foreach d in firstrep trans99 {
    capture drop wX
    gen double wX = wb_m1 * `d'
    reghdfe g wb_m1 wX `d' $XP i.period, absorb(id) vce(cluster id)
    local b0 = _b[wb_m1]
    local bi = _b[wX]
    local pi = 2 * ttail(e(df_r), abs(_b[wX] / _se[wX]))
    local N = e(N)
    kboot wX
    post `G' ("`d'") (`b0') (`b0' + `bi') (`bi') (`pi') (r(p)) (`N')
}
postclose `G'

* (3) influencia: cada um dos 44, e blocos
quietly reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
local b355 = _b[wb_m1]
quietly reghdfe g wb_m1 $XP i.period if in311, absorb(id) vce(cluster id)
local b311 = _b[wb_m1]
local dif = `b355' - `b311'
rv_kv b2_b355 `=string(`b355', "%9.4f")'
rv_kv b2_b311 `=string(`b311', "%9.4f")'
rv_kv b2_dif `=string(`dif', "%9.4f")'
tempname I
postfile `I' str16 kind str12 lab double(b share) long(N) using "$RINT/q5_infl.dta", replace
gen long obsn = _n
levelsof obsn if lost, local(ls)
foreach o of local ls {
    quietly levelsof iso3 if obsn == `o', local(iso) clean
    quietly summ year0 if obsn == `o'
    local y = r(mean)
    quietly reghdfe g wb_m1 $XP i.period if obsn != `o', absorb(id) vce(cluster id)
    post `I' ("one") ("`iso' `y'") (_b[wb_m1]) ((`b355' - _b[wb_m1]) / `dif') (e(N))
}
foreach bb in "firstrep|lost & firstrep" "trans99|lost & trans99" "early|lost & early" "all44|lost" {
    gettoken nm cond : bb, parse("|")
    local cond = substr("`cond'", 2, .)
    quietly reghdfe g wb_m1 $XP i.period if !(`cond'), absorb(id) vce(cluster id)
    post `I' ("block") ("`nm'") (_b[wb_m1]) ((`b355' - _b[wb_m1]) / `dif') (e(N))
}
postclose `I'
use "$RINT/q5_infl.dta", clear
list if kind == "block", noobs
quietly summ share if kind == "block" & inlist(lab, "firstrep", "trans99")
local mx = r(max)
rv_kv b2_block_max_share `=string(`mx', "%9.4f")'
rv_kv b2_rule_twothirds `=cond(`mx' >= 2 / 3, 1, 0)'
foreach nm in firstrep trans99 early all44 {
    quietly summ share if kind == "block" & lab == "`nm'"
    rv_kv b2_share_`nm' `=string(r(mean), "%9.4f")'
}

* (4) checagens de vies na amostra completa
use "$RINT/q5_base.dta", clear
gen double Lg_f = Lg
replace Lg_f = g_prev if missing(Lg_f)
count if missing(Lg) & !missing(g_prev)
rv_kv b2_Lg_recovered `r(N)'
gen double wbXneg2 = wb_m1 * neg
quietly summ neg
local fneg = r(mean)
tempname V
postfile `V' str6 item double(b bT3 d pboot) long(N) using "$RINT/q5_checks.dta", replace
capture program drop vchk
program define vchk
    args V item
    tempvar s
    quietly gen byte `s' = e(sample)
    kboot $VE
    local pb = r(p)
    quietly reghdfe g wb_m1 $XP i.period if `s', absorb(id) vce(cluster id)
    local b0 = _b[wb_m1]
    post `V' ("`item'") ($VB) (`b0') ($VB - `b0') (`pb') (e(N))
end
reghdfe g wb_m1 gap_m1 $XP i.period, absorb(id) vce(cluster id)
global VB = _b[wb_m1]
global VE "wb_m1"
vchk `V' gap
reghdfe g wb_m1 Lg_f $XP i.period, absorb(id) vce(cluster id)
global VB = _b[wb_m1]
global VE "wb_m1"
vchk `V' Lg_f
reghdfe g wb_m1 Lg_f gap_m1 $XP i.period, absorb(id) vce(cluster id)
global VB = _b[wb_m1]
global VE "wb_m1"
vchk `V' Lgf_gap
reghdfe g wb_m1 wbXneg2 neg $XP i.period, absorb(id) vce(cluster id)
global VB = _b[wb_m1] + `fneg' * _b[wbXneg2]
global VE "{wb_m1 + `fneg' * wbXneg2 = 0}"
vchk `V' neg
postclose `V'
use "$RINT/q5_checks.dta", clear
list, noobs
quietly summ d
local far = (max(abs(r(min)), abs(r(max))) >= 0.05)
rv_kv b2_rule_fullchecks `=cond(`far', "moves", "less than 0.05")'
kcsv "$RINT/q5_desc.dta" Table_A8_part_lost_description
kcsv "$RINT/q5_groups.dta" Table_A8_part_groups
kcsv "$RINT/q5_infl.dta" Table_A8_part_influence
kcsv "$RINT/q5_checks.dta" Table_A8_part_full_checks
log close
