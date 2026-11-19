* 08_conferencia.do -- Bloco 8: conferencia de contagens e numeros que nao fecham
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 8. Sem estimacao nova: recontagens e as mesmas regressoes das tabelas.
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/08_conferencia.log", replace text

tempname C
postfile `C' str6 item str100 desc double value using "$RINT/conf.dta", replace

* (1) DP dentro do pais da folha anual: Tabela A2 (painel B) x Tabela A5 antiga
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023)
merge 1:1 id year using "$KIN/amostras1.dta", keep(master match) nogen
keep if S1_base
count
post `C' ("1") ("A2: country-years of the Table 1 sample (S1_base)") (r(N))
bysort id: egen double mi = mean(wb)
gen double w = wb - mi
quietly summ w
post `C' ("1") ("A2: within SD of the wage bill (descrow; country means over S1_base)") (r(sd))
post `C' ("1") ("A2: N of the within SD") (r(N))
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1991, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
keep if inrange(year, 1996, 2023)
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
count if sA
post `C' ("1") ("A5 (old): country-years of the Table 1 sample (sA)") (r(N))
bysort id: egen double _m = mean(cond(sA, wb, .))
gen double _d = wb - _m if sA
quietly summ _d
post `C' ("1") ("A5 (old): within SD of the wage bill (country means over sA)") (r(sd))
merge 1:1 id year using "$KIN/amostras1.dta", keep(master match) nogen
count if sA & !S1_base
post `C' ("1") ("Country-years in sA but not in S1_base") (r(N))
count if !sA & S1_base == 1
post `C' ("1") ("Country-years in S1_base but not in sA") (r(N))
* (6) correlacao do crescimento da tendencia HP unilateral com o crescimento do PIB (texto: 0,86; registro com 3 casas: 0,855)
xtset id year
gen dY = lnY - L.lnY
gen dHP1 = lnY_hp1 - L.lnY_hp1
gen dHAM = lnY_ham - L.lnY_ham
quietly corr dY dHP1 if sA
post `C' ("6") ("Correlation of one-sided HP trend growth with GDP growth (exact)") (r(rho))
quietly corr dY dHAM if sA
post `C' ("6") ("Correlation of Hamilton trend growth with GDP growth (exact)") (r(rho))

* (2) federacoes na amostra da Tabela 2 (comum geral x central, T3)
use "$KIN1/cov9.dta", clear
foreach v in tf tu tl ta {
    capture drop `v'
}
egen tf = tag(id) if federal == 1
count if tf
post `C' ("2") ("Table 2: federations in the common sample, before singletons") (r(N))
egen tu = tag(id) if federal == 0
count if tu
post `C' ("2") ("Table 2: unitary countries in the common sample, before singletons") (r(N))
egen ta = tag(id)
count if ta
post `C' ("2") ("Table 2: countries in the common sample, before singletons") (r(N))
count
post `C' ("2") ("Table 2: observations in the common sample, before singletons") (r(N))
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
post `C' ("2") ("Table 2: observations, all countries (after singletons)") (e(N))
post `C' ("2") ("Table 2: countries, all (after singletons)") (e(N_clust))
reghdfe g wb_m1 $XP i.period if federal == 1, absorb(id) vce(cluster id)
post `C' ("2") ("Table 2: observations, federations (after singletons)") (e(N))
post `C' ("2") ("Table 2: federations (after singletons)") (e(N_clust))
reghdfe g wb_m1 $XP i.period if federal == 0, absorb(id) vce(cluster id)
post `C' ("2") ("Table 2: observations, unitary (after singletons)") (e(N))
post `C' ("2") ("Table 2: unitary countries (after singletons)") (e(N_clust))

* (3) Tabela A2: paises da amostra de T3 por grupo de renda; media e DP dentro da folha em t_p - 1
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
keep if e(sample)
egen t = tag(id)
count if t
post `C' ("3") ("T3 sample: countries") (r(N))
levelsof income_grp if t, local(gr)
foreach k of local gr {
    count if t & income_grp == `k'
    local lb : label (income_grp) `k'
    post `C' ("3") (`"T3 sample: countries in income group `k' (`lb')"') (r(N))
}
capture confirm string variable region
if !_rc {
    levelsof region if t, local(rg)
    foreach k of local rg {
        count if t & region == `"`k'"'
        post `C' ("3") (`"T3 sample: countries in region `k'"') (r(N))
    }
}
quietly summ wb_m1
post `C' ("3") ("T3 sample: mean of the wage bill in t_p − 1 (% of GDP)") (r(mean))
bysort id: egen double mi = mean(wb_m1)
gen double w = wb_m1 - mi
quietly summ w
post `C' ("3") ("T3 sample: within SD of the wage bill in t_p − 1") (r(sd))

* (4) Mollick e Vianna: amostra propria (GE) e amostra comum as tres medidas
import delimited "$KIN/kv.csv", clear varnames(1) stringcols(_all)
foreach k in mvf_ge_full_own_c_N mvf_ge_full_common_c_N mvf_ge_full_common_l_N mvf_ge_full_common_h_N mvf_ge_full_common_c_bX mvf_ge_full_own_c_bX {
    quietly levelsof value if key == "`k'", local(v) clean
    local n : word count `v'
    local v : word `n' of `v'
    post `C' ("4") ("Revision register `k'") (real("`v'"))
}

* (5) H2: coeficiente do log da folha na amostra da Tabela 3, coluna 3
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen relw_sel = wb_sel / pe_sel
gen lpe = ln(pe_sel)
gen lrw = ln(relw_sel)
gen lwbs = ln(wb_sel)
gen prem01 = prem_sel / 0.1
gen byte sH = !missing(g, lpe, lrw, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
reghdfe g lwbs $XP i.period if sH, absorb(id) vce(cluster id)
post `C' ("5") ("Table 3 col. 3 sample: coefficient on log wage bill (% of GDP)") (_b[lwbs])
post `C' ("5") ("Table 3 col. 3 sample: observations") (e(N))
reghdfe g lpe lrw $XP i.period if sH, absorb(id) vce(cluster id)
post `C' ("5") ("Table 3 col. 3: coefficient on log relative wage") (_b[lrw])
post `C' ("5") ("Table 3 col. 3: coefficient on log public employment") (_b[lpe])
postclose `C'
use "$RINT/conf.dta", clear
list, noobs sep(0)
kcsv "$RINT/conf.dta" conferencia_bloco8
log close
