* 02_timing.do -- bloco 4.1 do plano: timing da medida inicial e controles predeterminados [P7, P25]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
capture log close
log using "$RLOG/02_timing.log", replace text

global XD  "lny0 hc_tp inv open infl popg ctot_g"
global XP  "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"
global XPN "lny0 hc_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"

use "$RINT/p5_rv.dta", clear
keep if micro == 0
merge 1:1 id period using "$RINT/amostras5.dta", keep(master match) nogen
xtset id period

tempname P
postfile `P' str8 spec str8 smp double(b se p pboot lo hi) long(N nc) using "$RINT/timing.dta", replace
* spec: dependente, folha, controles
local s_T1 "g wb_m1 $XD"
local s_T2 "g_x1 wb_tp $XD"
local s_T3 "g wb_m1 $XP"
local s_T4 "g wb_m1 $XPN"
local s_T5 "g wb_ham_m1 $XP"
local s_T6 "g wb_tp $XD"
foreach t in T1 T2 T3 T4 T5 T6 {
    gettoken dep rest : s_`t'
    gettoken w ctrl : rest
    foreach smp in own base {
        local cond = cond("`smp'" == "own", "1", "S5_base == 1")
        reghdfe `dep' `w' `ctrl' i.period if `cond', absorb(id) vce(cluster id)
        local b = _b[`w']
        local se = _se[`w']
        local p = 2 * ttail(e(df_r), abs(`b' / `se'))
        local N = e(N)
        local nc = e(N_clust)
        estimates store `t'_`smp'
        rv_boot `w'
        local pb = r(p)
        local lo = r(lo)
        local hi = r(hi)
        post `P' ("`t'") ("`smp'") (`b') (`se') (`p') (`pb') (`lo') (`hi') (`N') (`nc')
        rv_kv `t'_`smp'_b `=string(`b', "%12.8f")'
        rv_kv `t'_`smp'_se `=string(`se', "%9.4f")'
        rv_kv `t'_`smp'_p `=string(`p', "%9.4f")'
        rv_kv `t'_`smp'_pboot `=string(`pb', "%9.4f")'
        rv_kv `t'_`smp'_lo `=string(`lo', "%9.4f")'
        rv_kv `t'_`smp'_hi `=string(`hi', "%9.4f")'
        rv_kv `t'_`smp'_N `N'
        rv_kv `t'_`smp'_nc `nc'
    }
}
estimates restore T3_own
estimates save "$RINT/est_T3", replace
* amostra da especificacao preferida (usada nos blocos seguintes)
gen byte S5_T3 = 0
quietly reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
replace S5_T3 = e(sample)
preserve
keep id period S5_T3
save "$RINT/amostra_T3.dta", replace
restore

* ---------------------------------------------------------------- painel de tres anos (inicio em 1979)
use "$RINT/p3_rv.dta", clear
keep if micro == 0
xtset id period
foreach t in T3 T6 {
    local spec = cond("`t'" == "T3", "g wb_m1 $XP", "g wb_tp $XD")
    gettoken dep rest : spec
    gettoken w ctrl : rest
    reghdfe `dep' `w' `ctrl' i.period, absorb(id) vce(cluster id)
    local b = _b[`w']
    local se = _se[`w']
    local p = 2 * ttail(e(df_r), abs(`b' / `se'))
    estimates store `t'_3y
    rv_boot `w'
    post `P' ("`t'") ("3y") (`b') (`se') (`p') (r(p)) (r(lo)) (r(hi)) (e(N)) (e(N_clust))
    rv_kv `t'_3y_b `=string(`b', "%12.8f")'
    rv_kv `t'_3y_p `=string(`p', "%9.4f")'
    rv_kv `t'_3y_N `e(N)'
}

* ---------------------------------------------------------------- painel anual: folha e todos os controles defasados
use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023)
xtset id year
gen wb_l1 = L.wb
gen g_l1 = L.g
foreach v in lny hc inv open infl popg ctot_g {
    gen `v'_l1 = L.`v'
}
* draft 7 (S1 col. 3): folha defasada, controles contemporaneos (exceto renda e capital humano)
xtscc g wb_l1 g_l1 lny_l1 hc_l1 inv open infl popg ctot_g i.year, fe lag($DKLAG)
local b = _b[wb_l1]
local se = _se[wb_l1]
estimates store A_draft
post `P' ("A_draft") ("annual") (`b') (`se') (2 * ttail(e(df_r), abs(`b' / `se'))) (.) (.) (.) (e(N)) (e(N_g))
* revisao: todos os controles defasados
xtscc g wb_l1 g_l1 lny_l1 hc_l1 inv_l1 open_l1 infl_l1 popg_l1 ctot_g_l1 i.year, fe lag($DKLAG)
local b = _b[wb_l1]
local se = _se[wb_l1]
estimates store A_pre
post `P' ("A_pre") ("annual") (`b') (`se') (2 * ttail(e(df_r), abs(`b' / `se'))) (.) (.) (.) (e(N)) (e(N_g))
rv_kv A_pre_b `=string(`b', "%12.8f")'
rv_kv A_pre_se `=string(`se', "%9.4f")'
rv_kv A_pre_N `e(N)'
postclose `P'

* =====================================================================================
* Tabela: timing (texto principal)
* =====================================================================================
use "$RINT/timing.dta", clear
list, noobs sep(0)
rv_new, ncol(8) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)" "(8)") ///
    head2("T6: conventional" "T1" "T2" "T3: preferred" "T4" "T5" "T3, 3-year" "Annual")
local order "T6 T1 T2 T3 T4 T5"
* linha de coeficientes (amostra propria)
local cb ""
local cs ""
local cp ""
local cn ""
local cc ""
local bb ""
local bs ""
foreach t of local order {
    quietly summ b if spec == "`t'" & smp == "own"
    local b = r(mean)
    quietly summ se if spec == "`t'" & smp == "own"
    local se = r(mean)
    quietly summ p if spec == "`t'" & smp == "own"
    rv_fmt `b' %12.3f `=r(mean)'
    local cb `"`cb' "`r(s)'""'
    rv_fmt `se' %12.3f
    local cs `"`cs' "(`r(s)')""'
    quietly summ pboot if spec == "`t'" & smp == "own"
    rv_fmt `=r(mean)' %12.3f
    local cp `"`cp' "`r(s)'""'
    quietly summ N if spec == "`t'" & smp == "own"
    rv_fmt `=r(mean)' %12.0fc
    local cn `"`cn' "`r(s)'""'
    quietly summ nc if spec == "`t'" & smp == "own"
    rv_fmt `=r(mean)' %12.0fc
    local cc `"`cc' "`r(s)'""'
    quietly summ b if spec == "`t'" & smp == "base"
    local b2 = r(mean)
    quietly summ se if spec == "`t'" & smp == "base"
    local se2 = r(mean)
    quietly summ p if spec == "`t'" & smp == "base"
    rv_fmt `b2' %12.3f `=r(mean)'
    local bb `"`bb' "`r(s)'""'
    rv_fmt `se2' %12.3f
    local bs `"`bs' "(`r(s)')""'
}
foreach k in 3y annual {
    local sp = cond("`k'" == "3y", "T3", "A_pre")
    quietly summ b if spec == "`sp'" & smp == "`k'"
    local b = r(mean)
    quietly summ se if spec == "`sp'" & smp == "`k'"
    local se = r(mean)
    quietly summ p if spec == "`sp'" & smp == "`k'"
    rv_fmt `b' %12.3f `=r(mean)'
    local cb `"`cb' "`r(s)'""'
    rv_fmt `se' %12.3f
    local cs `"`cs' "(`r(s)')""'
    quietly summ pboot if spec == "`sp'" & smp == "`k'"
    rv_fmt `=r(mean)' %12.3f
    local cp `"`cp' "`r(s)'""'
    quietly summ N if spec == "`sp'" & smp == "`k'"
    rv_fmt `=r(mean)' %12.0fc
    local cn `"`cn' "`r(s)'""'
    quietly summ nc if spec == "`sp'" & smp == "`k'"
    rv_fmt `=r(mean)' %12.0fc
    local cc `"`cc' "`r(s)'""'
    local bb `"`bb' """'
    local bs `"`bs' """'
}
rv_row "Wage bill, general government (% of GDP)" `cb'
rv_row "" `cs'
rv_row "Wild cluster bootstrap p-value" `cp'
rv_mid
rv_row "Same model in the conventional-specification sample" `bb'
rv_row "" `bs'
rv_mid
rv_row "Wage bill measured in" "t_p" "t_p − 1" "t_p" "t_p − 1" "t_p − 1" "t_p − 1, % of trend GDP" "t_p − 1" "t − 1"
rv_row "Growth averaged over" "t_p to t_p + 4" "t_p to t_p + 4" "t_p + 1 to t_p + 4" "t_p to t_p + 4" "t_p to t_p + 4" "t_p to t_p + 4" "t_p to t_p + 2" "year t"
rv_row "Controls" "Period means" "Period means" "Period means" "Predetermined" "Predet., no investment" "Predetermined" "Predetermined" "Lagged one year"
rv_row "Observations" `cn'
rv_row "Countries" `cc'
rv_row "Country FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes"
rv_row "Period FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes" "Year"
rv_row "Standard errors" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster" "Cluster" "Driscoll-Kraay (3)"
rv_out Tab2_timing, landscape ///
    title("Table 2. Timing of the initial wage bill and predetermined controls") ///
    notes("Dependent variable: growth of real GDP per capita (%, average over the years shown). t_p is the first year of period p and t_p − 1 the last year of the previous period. Columns 1–6: non-overlapping five-year averages, 1979–2023; column 7: three-year averages, 1979–2023; column 8: annual panel, 1996–2023, with lagged growth. Period-mean controls (conventional): log GDP per capita in t_p − 1, human capital in t_p and period means of investment, openness, inflation, population growth and commodity terms-of-trade growth. Predetermined controls: the same variables in t_p − 1 (in t − 1 in column 8). Column 5 drops investment, the mediator proposed in H4. Column 6 divides the wage bill by trend GDP from the Hamilton filter (H = 2, k = 2). Country and period fixed effects; standard errors clustered by country (t distribution with G − 1 degrees of freedom), except column 8 (Driscoll-Kraay, maximum lag 3, t distribution with T − 1 degrees of freedom). Wild cluster bootstrap p-values: Webb weights, 9,999 replications, clustered by country. The second panel restricts each specification to the conventional-specification sample (365 country-periods), keeping the country-periods that also have the variables of that column. Microstates excluded. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Figura: coeficientes por timing, amostra propria e amostra do draft 7
* =====================================================================================
use "$RINT/timing.dta", clear
keep if inlist(smp, "own", "base")
gen ord = .
local i = 0
foreach t in T6 T1 T2 T3 T4 T5 {
    local ++i
    replace ord = 7 - `i' if spec == "`t'"
}
gen lo95 = b - invttail(nc - 1, 0.025) * se
gen hi95 = b + invttail(nc - 1, 0.025) * se
gen y = ord + cond(smp == "own", 0.12, -0.12)
twoway (rcap lo95 hi95 y if smp == "own", horizontal lcolor(black) lwidth(medthin)) ///
       (scatter y b if smp == "own", msymbol(O) mcolor(black) msize(small)) ///
       (rcap lo95 hi95 y if smp == "base", horizontal lcolor(gs8) lpattern(dash) lwidth(medthin)) ///
       (scatter y b if smp == "base", msymbol(Dh) mcolor(gs6) msize(small)), ///
       $GOPT xline(0, lcolor(gs10) lpattern(shortdash)) ///
       ylabel(6 "T6: conventional (t{sub:p})" 5 "T1: t{sub:p} − 1" 4 "T2: t{sub:p}, growth excl. t{sub:p}" 3 "T3: t{sub:p} − 1, predetermined" ///
              2 "T4: T3 without investment" 1 "T5: T3, % of trend GDP", angle(0) labsize(8pt) nogrid) ///
       xlabel(, format(%3.1f) labsize(8pt)) ytitle("") yscale(range(0.5 6.5)) ///
       xtitle("Coefficient on the wage bill (p.p. of growth per p.p. of GDP), 95% CI", size(8pt)) ///
       legend(order(2 "Own sample" 4 "Conventional-specification sample") rows(1) pos(6) size(8pt))
rv_fig Fig3_timing, width(190) height(90)

log close
