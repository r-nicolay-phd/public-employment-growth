* 08_instituicoes_k.do -- Bloco 8: teste das diferencas nas replicas, mecanismo da interacao, indice x periodo
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/08_instituicoes_k.log", replace text

tempname D
postfile `D' str4 panel str10 dif double(d lo hi p) long(N) using "$RINT/inst_dif.dta", replace
* ---------------------------------------------------------------- painel C (replica aproximada de Mollick e Vianna)
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1993, 2023)
xtset id year
egen inst = rowmean(wgi_ge wgi_rq wgi_rl wgi_cc wgi_va wgi_pv)
gen gc = govcons_gdp
gen gc_l1 = L.govcons_gdp
gen gc_ham = govcons_gdp * exp(lnY - lnY_ham)
gen g_l1 = L.g
gen lny_l1 = L.lny
keep if inrange(year, 1996, 2023)
gen byte sMV = !missing(g, gc, gc_l1, gc_ham, inst, g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g) & year <= 2019
quietly summ inst if sMV
gen instc = inst - r(mean)
keep if sMV
keep id year g gc gc_ham gc_l1 instc g_l1 lny_l1 hc inv open infl popg ctot_g
gen long obs = _n
expand 3
bysort obs: gen byte m = _n
gen double G = cond(m == 1, gc, cond(m == 2, gc_ham, gc_l1))
forvalues k = 1/3 {
    gen double X`k' = G * instc * (m == `k')
    gen double G`k' = G * (m == `k')
}
egen idm = group(id m)
quietly reghdfe g X1-X3 G1-G3 c.(instc g_l1 lny_l1 hc inv open infl popg ctot_g)#i.m i.year#i.m, absorb(idm) vce(cluster id)
foreach pr in "1 3 lag" "1 2 trend" {
    tokenize `pr'
    lincom X`1' - X`2'
    local d = r(estimate)
    local nst = e(N)
    kboot {X`1' - X`2' = 0}
    post `D' ("C") ("`3'") (`d') (r(lo)) (r(hi)) (r(p)) (`nst')
}
* ---------------------------------------------------------------- painel D (especificacao publicada de Mollick e Vianna, GE)
local mvpaises ALB DZA ATG ARG ARM AUS AUT AZE BHS BHR BGD BRB BLR BEL BLZ BEN BTN BOL BWA BRA BRN BGR BFA BDI ///
    KHM CMR TCD CHL CHN COL COM COD COG CRI CIV HRV CYP CZE DNK DOM ECU EGY SLV EST SWZ FJI FIN FRA GAB GMB GEO ///
    DEU GHA GRC GTM GIN GNB HND HKG HUN ISL IND IDN IRN IRL ISR ITA JAM JPN JOR KAZ KEN KOR KWT KGZ LVA LBN LTU ///
    LUX MAC MDG MYS MLI MLT MRT MUS MEX MDA MNG MAR MOZ NAM NPL NLD NZL NIC NER NGA MKD NOR OMN PAK PAN PRY PER ///
    PHL POL PRT PRI ROU RUS RWA SAU SEN SRB SLE SGP SVK SVN ZAF ESP LKA SDN SWE CHE TJK TZA THA TGO TUN TUR UGA ///
    UKR GBR USA UZB VNM PSE
use "$KIN/anual_rv.dta", clear
gen byte mv138 = 0
foreach c of local mvpaises {
    replace mv138 = 1 if iso3 == "`c'"
}
keep if mv138 & inrange(year, 1995, 2019)
xtset id year
gen gy = gdp_growth_mv
gen gy_l1 = L.gy
gen lgy = ln(govcons_gdp_mv) if govcons_gdp_mv > 0
gen lgy_l1 = L.lgy
gen lgy_ham = lgy + lnY - lnY_ham
gen liy = ln(gcf_gdp_mv) if gcf_gdp_mv > 0
by id: ipolate wgi_ge year, gen(_ip)
replace wgi_ge = _ip if missing(wgi_ge) & inlist(year, 1997, 1999, 2001)
keep if inrange(year, 1996, 2019)
gen I = wgi_ge
keep if !missing(gy, gy_l1, I, lgy, lgy_l1, lgy_ham, liy, popg)
keep id year gy gy_l1 I lgy lgy_ham lgy_l1 liy popg
gen long obs = _n
expand 3
bysort obs: gen byte m = _n
gen double G = cond(m == 1, lgy, cond(m == 2, lgy_ham, lgy_l1))
forvalues k = 1/3 {
    gen double X`k' = G * I * (m == `k')
    gen double G`k' = G * (m == `k')
}
egen idm = group(id m)
quietly reghdfe gy X1-X3 G1-G3 c.(I gy_l1 liy popg)#i.m i.year#i.m, absorb(idm) vce(cluster id)
foreach pr in "1 3 lag" "1 2 trend" {
    tokenize `pr'
    lincom X`1' - X`2'
    local d = r(estimate)
    local nst = e(N)
    kboot {X`1' - X`2' = 0}
    post `D' ("D") ("`3'") (`d') (r(lo)) (r(hi)) (r(p)) (`nst')
}
postclose `D'

* ---------------------------------------------------------------- mecanismo
tempname M
postfile `M' str4 cond str12 v str6 inst double(b se p) long(N) using "$RINT/inst_mec.dta", replace
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1995, 2023)
xtset id year
egen inst = rowmean(wgi_ge wgi_rq wgi_rl wgi_cc wgi_va wgi_pv)
gen dlYn = 100 * (ln(gdp_nom_lcu) - ln(L.gdp_nom_lcu))
gen dlC = 100 * (ln(govcons_gdp / 100 * gdp_nom_lcu) - ln(L.govcons_gdp / 100 * L.gdp_nom_lcu))
gen dlW = 100 * (ln(wagebill_gdp / 100 * gdp_nom_lcu) - ln(L.wagebill_gdp / 100 * L.gdp_nom_lcu))
keep if inrange(year, 1996, 2023)
foreach iv in inst icrg_qog {
    quietly summ `iv'
    gen c_`iv' = `iv' - r(mean)
    foreach v in dlC dlW {
        quietly xtscc `v' c.dlYn##c.c_`iv' i.year if abs(`v') < 200 & abs(dlYn) < 200, fe lag($DKLAG)
        local b = _b[c.dlYn#c.c_`iv']
        local se = _se[c.dlYn#c.c_`iv']
        post `M' ("a") ("`v'") ("`iv'") (`b') (`se') (2 * ttail(e(df_r), abs(`b' / `se'))) (e(N))
    }
}
* (b) e (c): correlacoes entre paises
gen gap = -100 * lgap_ham
bysort id: egen vgap = sd(gap)
replace vgap = vgap^2
bysort id: egen minst = mean(inst)
bysort id: egen micrg = mean(icrg_qog)
gen double fitc = .
levelsof id, local(ids)
foreach i of local ids {
    capture quietly regress govcons_gdp gap if id == `i'
    if !_rc & e(N) >= 10 {
        quietly predict double _f if id == `i', xb
        quietly replace fitc = _f if id == `i'
        drop _f
    }
}
bysort id: egen sdcyc = sd(fitc)
egen tg = tag(id)
foreach iv in minst micrg {
    quietly pwcorr vgap `iv' if tg, sig obs
    post `M' ("b") ("var_gap") ("`iv'") (r(rho)) (.) (r(sig)[1, 2]) (r(N))
    quietly pwcorr sdcyc `iv' if tg, sig obs
    post `M' ("c") ("sd_cyc") ("`iv'") (r(rho)) (.) (r(sig)[1, 2]) (r(N))
}
postclose `M'

* ---------------------------------------------------------------- indice x periodo (Oto-Peralias e Romero-Avila)
capture program drop opra_painel
program define opra_painel
    args y0 y1
    use "$KIN/anual_rv.dta", clear
    keep if micro == 0 & inrange(year, `=`y0' - 1', `y1')
    xtset id year
    gen period = floor((year - `y0') / 5)
    gen year0 = `y0' + 5 * period
    gen byte first = year == year0
    foreach v in govcons_gdp lny {
        gen `v'_tp = `v' if first
        gen `v'_m1 = L.`v' if first
    }
    drop if year < `y0'
    collapse (mean) g gc_mean = govcons_gdp icrg = icrg_qog wgi_ge secenr inv dependency ///
        (firstnm) gc_tp = govcons_gdp_tp gc_m1 = govcons_gdp_m1 lny0 = lny_m1 iso3, by(id period)
    xtset id period
end
tempname O
postfile `O' str10 rep str8 meas str4 est double(b se p) long(N nc) using "$RINT/inst_opra.dta", replace
capture program drop oest
program define oest
    args O rep inst meas
    capture drop G GXI
    gen G = `meas'
    gen GXI = G * `inst'
    quietly tab period, gen(pd)
    capture drop pd1
    capture quietly xtabond2 g G GXI `inst' lny0 secenr inv pd*, gmm(G GXI inv, lag(2 .) collapse) ///
        gmm(lny0 secenr `inst', lag(1 .) collapse) iv(pd* dependency) twostep robust small
    if !_rc post `O' ("`rep'") ("`meas'") ("sgmm") (_b[GXI]) (_se[GXI]) (2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI]))) (e(N)) (e(N_g))
    else post `O' ("`rep'") ("`meas'") ("sgmm") (.) (.) (.) (.) (.)
    capture quietly reghdfe g G GXI `inst' lny0 secenr inv i.period, absorb(id) vce(cluster id)
    if !_rc post `O' ("`rep'") ("`meas'") ("fe") (_b[GXI]) (_se[GXI]) (2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI]))) (e(N)) (e(N_clust))
    else post `O' ("`rep'") ("`meas'") ("fe") (.) (.) (.) (.) (.)
    drop pd*
end
* (a) ICRG/QoG em 1996-2020
opra_painel 1981 2020
keep if period >= 3 & !missing(g, gc_mean, gc_m1, icrg, lny0, secenr, inv)
foreach m in gc_mean gc_m1 {
    oest `O' icrg9620 icrg `m'
}
* (b) WGI em 1996-2005
opra_painel 1981 2005
keep if period >= 3 & !missing(g, gc_mean, gc_m1, wgi_ge, lny0, secenr, inv)
foreach m in gc_mean gc_m1 {
    oest `O' wgi9605 wgi_ge `m'
}
* (c) ICRG/QoG e WGI na mesma amostra (1996-2020)
opra_painel 1981 2020
keep if period >= 3 & !missing(g, gc_mean, gc_m1, icrg, wgi_ge, lny0, secenr, inv)
* as escalas diferem (ICRG 0-1, WGI -2,5 a 2,5)
foreach m in gc_mean gc_m1 {
    oest `O' cmnicrg icrg `m'
    oest `O' cmnwgi wgi_ge `m'
}
postclose `O'

* =====================================================================================
* regra (adendo, Bloco 8) e Tabela S26
* =====================================================================================
use "$RINT/inst_dif.dta", clear
list, noobs
kcsv "$RINT/inst_dif.dta" TabS26_inst_differences
quietly summ p if panel == "D" & dif == "lag"
local difD = (r(mean) < 0.05)
use "$RINT/inst_mec.dta", clear
list, noobs
kcsv "$RINT/inst_mec.dta" TabS26_inst_mechanism
quietly count if p < 0.05 & ((cond == "a" & v == "dlC" & inst == "inst") | cond == "b" | cond == "c")
local mec = (r(N) > 0)
rv_kv inst_difD `difD'
rv_kv inst_mec `mec'
local rule = cond(`difD' & `mec', "explained by timing", cond(`difD', "consistent with a timing artifact", "timing explains part of the published result"))
rv_kv inst_rule "`rule'"
di "Bloco 8: diferenca (painel D) significativa = `difD'; condicao do mecanismo = `mec'; regra: `rule'"
use "$RINT/inst_opra.dta", clear
list, noobs
kcsv "$RINT/inst_opra.dta" TabS26_inst_opra
local ttl = cond(`difD' & `mec', "The annual amplification result is explained by timing", ///
    cond(`difD', "The annual amplification result is consistent with a timing artifact, but its mechanism is not shown", ///
    "Timing explains part of the published institutions results"))

rv_new, ncol(4) head1("Difference" "Bootstrap 95% CI" "p-value" "Obs. (stacked)")
use "$RINT/inst_dif.dta", clear
foreach k in "C lag" "C trend" "D lag" "D trend" {
    tokenize `k'
    quietly summ d if panel == "`1'" & dif == "`2'"
    local d = r(mean)
    quietly summ p if panel == "`1'" & dif == "`2'"
    local pp = r(mean)
    rv_fmt `d' %12.3f `pp'
    local x "`r(s)'"
    quietly summ lo if panel == "`1'" & dif == "`2'"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if panel == "`1'" & dif == "`2'"
    rv_fmt `=r(mean)' %12.3f
    local h "`r(s)'"
    quietly summ N if panel == "`1'" & dif == "`2'"
    local lab = cond("`1'" == "C", "Table A3, panel C (approximate replication)", "Table A3, panel D (published specification)") + ///
        cond("`2'" == "lag", ": same year − lagged", ": same year − % of trend GDP")
    rv_fmt `pp' %12.3f
    rv_row "`lab'" "`x'" "[`l'; `h']" "`r(s)'" "`=string(r(mean), "%9.0fc")'"
}
rv_mid
use "$RINT/inst_mec.dta", clear
rv_row "Mechanism" "Estimate" "SE" "p-value" "N"
forvalues i = 1/`=_N' {
    local c = cond[`i']
    local lab = cond("`c'" == "a", "(a) Interaction of nominal GDP growth with institutions, growth of ", ///
        cond("`c'" == "b", "(b) Correlation: variance of the output gap and mean institutions", "(c) Correlation: SD of the cyclical part of consumption/GDP and mean institutions")) + ///
        cond(v[`i'] == "dlC", "government consumption", cond(v[`i'] == "dlW", "wage bill", "")) + ///
        cond(inlist(inst[`i'], "inst", "minst"), " (WGI)", " (ICRG/QoG)")
    rv_fmt `=b[`i']' %12.3f `=p[`i']'
    local x "`r(s)'"
    rv_fmt `=se[`i']' %12.3f
    local s "`r(s)'"
    rv_fmt `=p[`i']' %12.3f
    rv_row "`lab'" "`x'" "`s'" "`r(s)'" "`=N[`i']'"
}
rv_mid
use "$RINT/inst_opra.dta", clear
rv_row "Oto-Peralías and Romero-Ávila: interaction, index and period separated" "FE" "System GMM" "Obs. (FE)" ""
foreach k in "icrg9620 ICRG/QoG, 1996–2020" "wgi9605 WGI, 1996–2005" "cmnicrg ICRG/QoG, common sample" "cmnwgi WGI, common sample" {
    gettoken r lab : k
    foreach m in gc_mean gc_m1 {
        quietly summ b if rep == "`r'" & meas == "`m'" & est == "fe"
        local b = r(mean)
        quietly summ p if rep == "`r'" & meas == "`m'" & est == "fe"
        rv_fmt `b' %12.3f `=r(mean)'
        local c1 "`r(s)'"
        quietly summ se if rep == "`r'" & meas == "`m'" & est == "fe"
        rv_fmt `=r(mean)' %12.3f
        local c1 "`c1' (`r(s)')"
        quietly summ b if rep == "`r'" & meas == "`m'" & est == "sgmm"
        local b = r(mean)
        quietly summ p if rep == "`r'" & meas == "`m'" & est == "sgmm"
        rv_fmt `b' %12.3f `=r(mean)'
        local c2 "`r(s)'"
        quietly summ se if rep == "`r'" & meas == "`m'" & est == "sgmm"
        rv_fmt `=r(mean)' %12.3f
        local c2 = cond("`c2'" == "", "not estimable", "`c2' (`r(s)')")
        quietly summ N if rep == "`r'" & meas == "`m'" & est == "fe"
        rv_row "`=strtrim("`lab'")', `=cond("`m'" == "gc_mean", "period mean", "t_p − 1")'" "`c1'" "`c2'" "`=string(r(mean), "%9.0fc")'" ""
    }
}
rv_out TabS26_institutions_tests, landscape ///
    title("Table S26. `ttl'") ///
    notes("Upper panel: differences between the same-year interaction (government consumption × institutions) and the lagged or trend-GDP interaction in the replications of Table A3, estimated in stacked models with country × measure fixed effects and measure-specific controls and year effects; wild cluster bootstrap by country (Webb weights, 9,999 replications), bootstrap 95% CI. Panel C: approximate replication (mean of six WGI indicators, centred; consumption in % of GDP; controls of Table 1); panel D: published specification of Mollick and Vianna (2024) with government effectiveness (log consumption; growth of real GDP). Mechanism: (a) coefficient on the interaction between nominal GDP growth and institutions (centred) in regressions of the nominal growth of government consumption or of the wage bill (100 × Δlog) on nominal GDP growth, institutions and their interaction, country and year fixed effects, Driscoll-Kraay standard errors, 1996–2023; (b) cross-country correlation between the variance of the Hamilton output gap and mean institutions; (c) cross-country correlation between the standard deviation of the cyclical part of consumption/GDP (fitted values of a country regression of the ratio on the Hamilton gap) and mean institutions; for (b) and (c) the estimate is the correlation and the p-value tests it is zero. Lower panel: specification of Table A3, panel A (five-year averages, System GMM and fixed effects), with the institutional index and the period separated; the two indices have different scales (ICRG/QoG 0–1; WGI −2.5 to 2.5). Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")
log close
