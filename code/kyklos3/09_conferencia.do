* 09_conferencia.do -- Bloco 8: conferencias e correcoes de consistencia (recontagens; sem estimacao nova)
* Plano: docs/plan_addendum_kyklos_3.md, Bloco 8.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/09_conferencia.log", replace text
tempname C
postfile `C' str4 item str120 desc double value str80 txt using "$RINT/conf3.dta", replace

* (1) Mollick e Cabral: 54 economias listadas x paises no painel anual estimado (FE, 1986-2004, medida (a))
local mc54 AUS AUT BEL CAN DNK FIN FRA DEU GRC ISL IRL ITA JPN NLD NZL NOR PRT ESP SWE CHE GBR USA ///
    ARG BGD BRA BGR CHL CHN COL CRI CZE DOM ECU EGY SLV HUN IND IDN ISR KOR MYS MEX MAR PAK PER PHL POL SGP ///
    ZAF THA TUN TUR URY VEN
use "$KIN/anual_rv.dta", clear
gen byte mc = 0
foreach c of local mc54 {
    replace mc = 1 if iso3 == "`c'"
}
egen t = tag(iso3) if mc
count if t
post `C' ("1") ("Mollick-Cabral: economies in their Table 1 found in the project data") (r(N)) ("")
local inproj ""
levelsof iso3 if t, local(inproj) clean
local notproj : list mc54 - inproj
post `C' ("1") ("Mollick-Cabral: listed economies absent from the project data") (`: word count `notproj'') ("`notproj'")
* amostra exata do painel anual da Tabela A6 (code/kyklos/01_mollick_cabral.do: as quatro medidas disponiveis)
use "$KIN1/mc_anual.dta", clear
xtset id year
keep if inrange(year, 1986, 2004)
gen byte ok = !missing(y, L.y, n, ls, lg_a, lg_b, lg_c, lg_d)
bysort iso3: egen byte anyok = max(ok)
egen t2 = tag(iso3)
count if t2 & anyok
post `C' ("1") ("Mollick-Cabral: economies in the estimated annual panel 1986-2004 (all four measures)") (r(N)) ("")
levelsof iso3 if t2 & !anyok, local(out) clean
post `C' ("1") ("Mollick-Cabral: economies dropped from the annual panel") (`: word count `out'') ("`out'")
gen byte has_gr0 = !missing(govcons_real)
bysort iso3: egen byte has_gr = max(has_gr0)
levelsof iso3 if t2 & !has_gr, local(o_gr) clean
post `C' ("1") ("Mollick-Cabral: economies without real government consumption (needed by the placebo)") (`: word count `o_gr'') ("`o_gr'")
foreach v in y ls lg_a lg_b lg_c lg_d {
    bysort iso3: egen byte has_`v' = max(!missing(`v'))
    levelsof iso3 if t2 & !has_`v', local(o_`v') clean
    post `C' ("1") ("Mollick-Cabral: economies with no data on `v', 1986-2004") (`: word count `o_`v''') ("`o_`v''")
}

* (2) Mollick e Vianna: paises listados, encontrados, estimados
import delimited "$KIN/kv.csv", clear varnames(1) stringcols(_all)
quietly levelsof value if key == "mvf_list_n", local(v) clean
local n : word count `v'
post `C' ("2") ("Mollick-Vianna: countries of their list found in the project data (138 listed; Puerto Rico absent)") (real("`: word `n' of `v''")) ("")
use "$KIN/mv_fiel.dta", clear
foreach i in ge cc rl {
    quietly summ nc if inst == "`i'" & per == "full" & smp == "own" & meas == "lgy"
    post `C' ("2") ("Mollick-Vianna replication, own sample, `i': countries") (r(mean)) ("")
    quietly summ nc if inst == "`i'" & per == "full" & smp == "common" & meas == "lgy"
    post `C' ("2") ("Mollick-Vianna replication, common sample, `i': countries") (r(mean)) ("")
}
quietly summ nc if smp == "pub"
post `C' ("2") ("Mollick-Vianna published (their Table 2): countries") (r(mean)) ("")
* (3) razao replicada / publicada: periodo inteiro e subperiodos
keep if meas == "lgy" & inlist(smp, "pub", "own")
keep inst per smp bX
reshape wide bX, i(inst per) j(smp) string
gen ratio = bXown / bXpub
list, noobs
quietly summ ratio if per == "full"
post `C' ("3") ("Replicated / published interaction, full period, min") (r(min)) ("")
post `C' ("3") ("Replicated / published interaction, full period, max") (r(max)) ("")
quietly summ ratio
post `C' ("3") ("Replicated / published interaction, full period and subperiods, min") (r(min)) ("")
post `C' ("3") ("Replicated / published interaction, full period and subperiods, max") (r(max)) ("")

* (4) H2 estrita: pares e amostras; p com a folha fixa nas duas rodadas
import delimited "$KIN1/kv.csv", clear varnames(1) stringcols(_all)
foreach k in h2s_pairs_all h2s_pairs_out h2s_N h2s_bW_lrw_pboot {
    quietly levelsof value if key == "`k'", local(v) clean
    local n : word count `v'
    post `C' ("4") ("Kyklos register (first round, seed 20261113): `k'") (real("`: word `n' of `v''")) ("")
}
use "$KIN2/h2r_res.dta", clear
quietly summ pboot if smp == "S" & spec == "m4base"
post `C' ("4") ("Second round (seed 20261115): wage bill held fixed, strict sample, bootstrap p") (r(mean)) ("")
use "$KIN/p5_rv.dta", clear
keep if micro == 0
gen byte strict = inrange(yd, 1, 4)
count if strict
post `C' ("4") ("Strict pairs (t_p - 1 to t_p - 4), all country-periods") (r(N)) ("")
count if strict & !missing(g, wb_sel, pe_sel, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
post `C' ("4") ("Strict pairs with growth and all controls (before singletons)") (r(N)) ("")
count if strict & missing(g)
post `C' ("4") ("Strict pairs without growth in period p") (r(N)) ("")
count if strict & !missing(g) & missing(lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
post `C' ("4") ("Strict pairs with growth but a missing control") (r(N)) ("")

* (5) premio salarial nas duas amostras
gen prem01 = prem_sel / 0.1
gen relw_sel = wb_sel / pe_sel
gen lpe = ln(pe_sel)
gen lrw = ln(relw_sel)
gen byte sH = !missing(g, lpe, lrw, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
gen byte sP = inrange(ydp, 1, 4) & !missing(g, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
xtset id period
foreach s in sH sP {
    reghdfe g prem01 $XP i.period if `s', absorb(id) vce(cluster id)
    local b = _b[prem01]
    local se = _se[prem01]
    local df = e(df_r)
    local N = e(N)
    kboot prem01
    local lab = cond("`s'" == "sH", "registered sample (Table 2)", "strict sample (pairs in t_p - 1 to t_p - 4)")
    post `C' ("5") ("Premium per 0.1 log point, `lab': coefficient") (`b') ("")
    post `C' ("5") ("Premium, `lab': 95% CI low (clustered)") (`b' - invttail(`df', 0.025) * `se') ("")
    post `C' ("5") ("Premium, `lab': 95% CI high (clustered)") (`b' + invttail(`df', 0.025) * `se') ("")
    post `C' ("5") ("Premium, `lab': bootstrap p") (r(p)) ("")
    post `C' ("5") ("Premium, `lab': observations") (`N') ("")
}

* (6) F do calendario eleitoral
import delimited "$KIN/kv.csv", clear varnames(1) stringcols(_all)
foreach k in ep_all_Feff ep_dem_Feff ep_new_Feff ep_old_Feff {
    quietly levelsof value if key == "`k'", local(v) clean
    local n : word count `v'
    post `C' ("6") ("Electoral calendar first stage, effective F: `k'") (real("`: word `n' of `v''")) ("")
}

* (7) sinal de theta/5: forma reduzida e primeiro estagio na amostra de theta (choque a)
use "$KIN2/lp2_base.dta", clear
gen byte sth = sY & !missing(dy5, MWa, sa, sa_l1, sa_l2, g_l1, g_l2)
xtscc dy5 sa sa_l1 sa_l2 g_l1 g_l2 i.year if sth, fe lag($DKLAG)
post `C' ("7") ("Shock (a), theta sample: reduced form, change in log GDP p.c. (x100) t-1 to t+5 on the shock") (_b[sa]) ("")
post `C' ("7") ("Shock (a), theta sample: reduced form, p-value") (2 * ttail(e(df_r), abs(_b[sa] / _se[sa]))) ("")
xtscc MWa sa sa_l1 sa_l2 g_l1 g_l2 i.year if sth, fe lag($DKLAG)
post `C' ("7") ("Shock (a), theta sample: first stage, mean wage-bill change h = 0-5 on the shock") (_b[sa]) ("")
post `C' ("7") ("Shock (a), theta sample: first stage, p-value") (2 * ttail(e(df_r), abs(_b[sa] / _se[sa]))) ("")
count if sth
post `C' ("7") ("Shock (a), theta sample: observations") (r(N)) ("")
use "$KIN1/lpk_res.dta", clear
quietly summ b if shock == "sa" & h == 5 & inf == "dk"
post `C' ("7") ("Shock (a), Table A16 (own sample): response at h = 5") (r(mean)) ("")

* (8) anos de crescimento negativo
use "$KIN1/verif.dta", clear
quietly summ b if chk == "rec_old"
post `C' ("8") ("Same-year ratio excluding negative-growth years (Table A5)") (r(mean)) ("")
quietly summ N if chk == "rec_old"
post `C' ("8") ("Same-year ratio excluding negative-growth years: observations") (r(mean)) ("")

postclose `C'
use "$RINT/conf3.dta", clear
list, noobs sep(0)
kcsv "$RINT/conf3.dta" conferencia_bloco8_final
log close
