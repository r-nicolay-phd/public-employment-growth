* 06_instituicoes.do -- bloco 4.5 do plano: instituicoes e tamanho do governo -- replicas e mecanismo [P1, P3]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/revisao/00_setup.do"
capture log close
log using "$RLOG/06_instituicoes.log", replace text

tempname P
postfile `P' str14 rep str10 meas str8 est double(bi sei pi bg seg) long(N nc nins) using "$RINT/replicas.dta", replace

* =====================================================================================
* A. Replica de Oto-Peralias e Romero-Avila (2013): paineis de cinco anos 1981-1985 a 2001-2005
* =====================================================================================
* A1. painel alinhado a 1981 (como no artigo), com o consumo do governo na media do periodo, em t_p e em t_p - 1
capture program drop opra_painel
program define opra_painel
    args y0 y1
    use "$RINT/anual_rv.dta", clear
    keep if micro == 0 & inrange(year, `=`y0' - 1', `y1')
    xtset id year
    gen period = floor((year - `y0') / 5)
    gen year0 = `y0' + 5 * period
    gen byte first = year == year0
    egen wgi6 = rowmean(wgi_ge wgi_rq wgi_rl wgi_cc wgi_va wgi_pv)
    foreach v in govcons_gdp lny {
        gen `v'_tp = `v' if first
        gen `v'_m1 = L.`v' if first
    }
    drop if year < `y0'
    collapse (mean) g gc_mean = govcons_gdp icrg = icrg_qog wgi6 wgi_ge secenr inv dependency ///
        (firstnm) gc_tp = govcons_gdp_tp gc_m1 = govcons_gdp_m1 lny0 = lny_m1 iso3 oecd, by(id period)
    xtset id period
end

capture program drop opra_est
program define opra_est
    * opra_est P rotulo instituicao medida
    args P rep inst meas
    capture drop G
    capture drop GXI
    gen G = `meas'
    gen GXI = G * `inst'
    quietly tab period, gen(pd)
    capture drop pd1
    * System GMM (dois passos, colapsado): consumo, interacao e investimento endogenos; renda inicial e matricula
    * predeterminadas; dummies de periodo exogenas; razao de dependencia como instrumento excluido
    capture noisily xtabond2 g G GXI `inst' lny0 secenr inv pd*, gmm(G GXI inv, lag(2 .) collapse) ///
        gmm(lny0 secenr `inst', lag(1 .) collapse) iv(pd* dependency) twostep robust small
    if !_rc {
        post `P' ("`rep'") ("`meas'") ("sgmm") (_b[GXI]) (_se[GXI]) (2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI]))) ///
            (_b[G]) (_se[G]) (e(N)) (e(N_g)) (e(j))
        estimates store R_`rep'_`meas'_sgmm
    }
    * efeitos fixos de pais e periodo
    reghdfe g G GXI `inst' lny0 secenr inv i.period, absorb(id) vce(cluster id)
    post `P' ("`rep'") ("`meas'") ("fe") (_b[GXI]) (_se[GXI]) (2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI]))) ///
        (_b[G]) (_se[G]) (e(N)) (e(N_clust)) (.)
    estimates store R_`rep'_`meas'_fe
    drop pd*
end

* A2. janela original 1981-2005 com o indice ICRG de qualidade de governo (QoG), disponivel desde 1984
opra_painel 1981 2005
* mesma amostra para as tres medidas
gen byte sO = !missing(g, gc_mean, gc_tp, gc_m1, icrg, lny0, secenr, inv)
keep if sO
count
foreach meas in gc_mean gc_tp gc_m1 {
    opra_est `P' opra_icrg icrg `meas'
}
* A3. WGI (substituto pedido pelo roteiro): disponivel desde 1996; periodos 1996-2000 a 2016-2020 (alinhados a 1981)
opra_painel 1981 2020
keep if period >= 3
gen byte sW = !missing(g, gc_mean, gc_tp, gc_m1, wgi_ge, lny0, secenr, inv)
keep if sW
count
foreach meas in gc_mean gc_tp gc_m1 {
    opra_est `P' opra_wgi wgi_ge `meas'
}

* =====================================================================================
* B. Replica aproximada de Mollick e Vianna (2023): painel anual 1996-2019, consumo x media do WGI
* =====================================================================================
use "$RINT/anual_rv.dta", clear
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
foreach meas in gc gc_ham gc_l1 {
    capture drop G
    capture drop GXI
    gen G = `meas'
    gen GXI = G * instc
    xtscc g G instc GXI g_l1 lny_l1 hc inv open infl popg ctot_g i.year if sMV, fe lag($DKLAG)
    post `P' ("mv") ("`meas'") ("fe_dk") (_b[GXI]) (_se[GXI]) (2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI]))) ///
        (_b[G]) (_se[G]) (e(N)) (e(N_g)) (.)
    estimates store R_mv_`meas'
    rv_kv mv_`meas'_bi `=string(_b[GXI], "%9.4f")'
    rv_kv mv_`meas'_pi `=string(2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI])), "%9.4f")'
}

* =====================================================================================
* C. Mecanismo: ciclicidade fiscal (Frankel-Vegh-Vuletin) medida antes da amostra (1970-1995)
* =====================================================================================
* ciclicidade estimada no proprio periodo 1996-2023 (robustez exploratoria do mecanismo, prevista no plano)
gen double cyc_in = .
levelsof id, local(ids)
foreach i of local ids {
    capture quietly regress dlgc gap_hp if id == `i' & inrange(year, 1996, 2023)
    if !_rc & e(N) >= 12 quietly replace cyc_in = _b[gap_hp] if id == `i'
}
bysort id: egen inst_m = mean(inst)
egen tg = tag(id) if sMV
corr cyc_pre inst_m if tg
rv_kv cyc_corr_pre `=string(r(rho), "%5.3f")'
rv_kv cyc_corr_pre_n `r(N)'
corr cyc_in inst_m if tg
rv_kv cyc_corr_in `=string(r(rho), "%5.3f")'
tempname C
postfile `C' str12 spec double(bi sei pi bc sec pc) long(N nc) using "$RINT/ciclicidade.dta", replace
foreach cv in cyc_pre cyc_in {
    capture drop G
    capture drop GXI
    capture drop GXC
    gen G = gc
    gen GXI = G * instc
    quietly summ `cv' if sMV
    gen GXC = G * (`cv' - r(mean))
    * mesma amostra: com e sem a interacao com a ciclicidade
    gen byte sC_`cv' = sMV & !missing(`cv')
    xtscc g G instc GXI g_l1 lny_l1 hc inv open infl popg ctot_g i.year if sC_`cv', fe lag($DKLAG)
    estimates store CY_base_`cv'
    post `C' ("base_`cv'") (_b[GXI]) (_se[GXI]) (2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI]))) (.) (.) (.) (e(N)) (e(N_g))
    xtscc g G instc GXI GXC g_l1 lny_l1 hc inv open infl popg ctot_g i.year if sC_`cv', fe lag($DKLAG)
    estimates store CY_with_`cv'
    post `C' ("with_`cv'") (_b[GXI]) (_se[GXI]) (2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI]))) ///
        (_b[GXC]) (_se[GXC]) (2 * ttail(e(df_r), abs(_b[GXC] / _se[GXC]))) (e(N)) (e(N_g))
    rv_kv cyc_`cv'_bi_base `=string(_b[GXI], "%9.4f")'
}
* resposta contemporanea do consumo ao hiato por nivel institucional (exploratorio do mecanismo)
gen gapXinst = gap_hp * instc
xtscc dlgc gap_hp gapXinst instc i.year if sMV, fe lag($DKLAG)
estimates store CY_resp
rv_kv cyc_resp_inter `=string(_b[gapXinst], "%9.4f")'
rv_kv cyc_resp_inter_p `=string(2 * ttail(e(df_r), abs(_b[gapXinst] / _se[gapXinst])), "%9.4f")'

* =====================================================================================
* D. Consumo (WDI) x despesa total (GFS): composicao da amostra x conceito de gasto
* =====================================================================================
gen ex = exp_gdp
gen byte sCE = sMV & !missing(ex)
foreach k in "gc sMV own" "gc sCE common" "ex sCE common" {
    gettoken meas rest : k
    gettoken smp lab : rest
    local lab = strtrim("`lab'")
    capture drop G
    capture drop GXI
    gen G = `meas'
    gen GXI = G * instc
    xtscc g G instc GXI g_l1 lny_l1 hc inv open infl popg ctot_g i.year if `smp', fe lag($DKLAG)
    estimates store CE_`meas'_`lab'
    post `C' ("`meas'_`lab'") (_b[GXI]) (_se[GXI]) (2 * ttail(e(df_r), abs(_b[GXI] / _se[GXI]))) (.) (.) (.) (e(N)) (e(N_g))
    rv_kv ce_`meas'_`lab'_bi `=string(_b[GXI], "%9.4f")'
    rv_kv ce_`meas'_`lab'_N `e(N)'
}
postclose `C'
postclose `P'

* =====================================================================================
* Tabela 6 (texto principal): replicas
* =====================================================================================
use "$RINT/replicas.dta", clear
list, noobs sep(0)
rv_new, ncol(6) head1("Period mean (contemporaneous)" "" "First year (t_p)" "" "t_p − 1" "") ///
    head2("System GMM" "Fixed effects" "System GMM" "Fixed effects" "System GMM" "Fixed effects")
foreach rep in opra_icrg opra_wgi {
    local ttl = cond("`rep'" == "opra_icrg", "A. Oto-Peralías and Romero-Ávila (2013): five-year averages 1981–2005, ICRG quality of government (QoG)", ///
        "B. Same specification, WGI government effectiveness, five-year averages 1996–2020")
    rv_row "`ttl'" "" "" "" "" "" ""
    foreach row in i g {
        local cb ""
        local cs ""
        foreach meas in gc_mean gc_tp gc_m1 {
            foreach est in sgmm fe {
                quietly summ b`row' if rep == "`rep'" & meas == "`meas'" & est == "`est'"
                if r(N) == 0 {
                    local cb `"`cb' """'
                    local cs `"`cs' """'
                    continue
                }
                local b = r(mean)
                quietly summ se`row' if rep == "`rep'" & meas == "`meas'" & est == "`est'"
                local se = r(mean)
                rv_fmt `b' %12.3f `=2 * normal(-abs(`b' / `se'))'
                local cb `"`cb' "`r(s)'""'
                rv_fmt `se' %12.3f
                local cs `"`cs' "(`r(s)')""'
            }
        }
        local lab = cond("`row'" == "i", "Government consumption × institutions", "Government consumption (% of GDP)")
        rv_row "`lab'" `cb'
        rv_row "" `cs'
    }
    local cn ""
    local cc ""
    foreach meas in gc_mean gc_tp gc_m1 {
        foreach est in sgmm fe {
            quietly summ N if rep == "`rep'" & meas == "`meas'" & est == "`est'"
            rv_fmt `=r(mean)' %12.0fc
            local cn `"`cn' "`r(s)'""'
            quietly summ nc if rep == "`rep'" & meas == "`meas'" & est == "`est'"
            rv_fmt `=r(mean)' %12.0fc
            local cc `"`cc' "`r(s)'""'
        }
    }
    rv_row "Observations" `cn'
    rv_row "Countries" `cc'
    rv_mid
}
rv_row "C. Approximate replication of Mollick and Vianna (2023): annual 1996–2019, mean of six WGI indicators" "" "" "" "" "" ""
local cb ""
local cs ""
local cg ""
local cgs ""
foreach meas in gc gc_ham gc_l1 {
    quietly summ bi if rep == "mv" & meas == "`meas'"
    local b = r(mean)
    quietly summ pi if rep == "mv" & meas == "`meas'"
    rv_fmt `b' %12.3f `=r(mean)'
    local cb `"`cb' "`r(s)'" """'
    quietly summ sei if rep == "mv" & meas == "`meas'"
    rv_fmt `=r(mean)' %12.3f
    local cs `"`cs' "(`r(s)')" """'
}
rv_row "Measure of government consumption" "Contemporaneous" "" "% of trend GDP (Hamilton)" "" "Lagged one year" ""
rv_row "Government consumption × institutions" `cb'
rv_row "" `cs'
quietly summ N if rep == "mv"
rv_row "Observations (each measure)" "`=string(r(mean), "%9.0fc")'" "" "" "" "" ""
rv_out Tab6_replications, landscape ///
    title("Table 6. Institutions and government size: replications with contemporaneous and predetermined measures") ///
    notes("Dependent variable: growth of real GDP per capita (%). Panels A and B follow the panel specification of Oto-Peralías and Romero-Ávila (2013, working-paper version INFER 2012/3): five-year averages, growth on government final consumption (% of GDP, WDI), institutional quality and their interaction, with initial log GDP per capita, secondary school enrolment and investment, and period effects. Their ICRG bureaucracy-quality index is proprietary; panel A uses the public ICRG quality-of-government index distributed by QoG (0–1, from 1984) and panel B the WGI government effectiveness estimate (from 1996), as required by the revision protocol; legal origin, one of their excluded instruments, is not available and is dropped. System GMM: two-step, collapsed instruments, consumption, interaction and investment endogenous (lags 2 and deeper), income, enrolment and institutions predetermined (lags 1 and deeper), period dummies and the population dependency ratio as standard instruments; Windmeijer-corrected standard errors. Fixed effects: country and period fixed effects, standard errors clustered by country. Only the timing of government consumption changes across column pairs (period mean, first year of the period, last year of the previous period); each panel uses the same sample for all measures. A positive interaction means that better institutions mitigate the growth cost of government size. Panel C: annual panel 1996–2019 (the window of Mollick and Vianna, 2023), government consumption interacted with the mean of the six WGI indicators (centred), country and year fixed effects, lagged growth and the controls of Table 1, Driscoll-Kraay standard errors (maximum lag 3); the published text was not available, so the specification follows the description in the draft and is an approximate replication only. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela suplementar: ciclicidade fiscal e consumo x despesa total
* =====================================================================================
use "$RINT/ciclicidade.dta", clear
list, noobs sep(0)
rv_new, ncol(4) head1("Interaction with institutions" "" "Consumption × cyclicality" "") head2("Coefficient" "SE" "Coefficient" "SE")
foreach s in base_cyc_pre with_cyc_pre base_cyc_in with_cyc_in gc_own gc_common ex_common {
    quietly summ bi if spec == "`s'"
    local b = r(mean)
    quietly summ pi if spec == "`s'"
    rv_fmt `b' %12.3f `=r(mean)'
    local c1 "`r(s)'"
    quietly summ sei if spec == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local c2 "(`r(s)')"
    quietly summ bc if spec == "`s'"
    local bc = r(mean)
    quietly summ pc if spec == "`s'"
    rv_fmt `bc' %12.3f `=r(mean)'
    local c3 "`r(s)'"
    quietly summ sec if spec == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local c4 = cond("`r(s)'" == "", "", "(`r(s)')")
    quietly summ N if spec == "`s'"
    local n = r(mean)
    local lab = cond("`s'" == "base_cyc_pre", "Consumption, sample with pre-1996 cyclicality", cond("`s'" == "with_cyc_pre", "+ consumption × cyclicality 1970–1995", ///
        cond("`s'" == "base_cyc_in", "Consumption, sample with 1996–2023 cyclicality", cond("`s'" == "with_cyc_in", "+ consumption × cyclicality 1996–2023", ///
        cond("`s'" == "gc_own", "Consumption (WDI), own sample", cond("`s'" == "gc_common", "Consumption (WDI), common sample with expenditure", "Total expenditure (GFS), common sample"))))))
    rv_row "`lab' (N = `=string(`n', "%9.0fc")')" "`c1'" "`c2'" "`c3'" "`c4'"
    if inlist("`s'", "with_cyc_pre", "with_cyc_in") rv_mid
}
import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
foreach k in cyc_corr_pre cyc_corr_pre_n cyc_corr_in cyc_resp_inter cyc_resp_inter_p {
    quietly levelsof value if key == "`k'", local(`k') clean
    local `k' : word 1 of ``k''
}
rv_out TabS_cyclicality, landscape ///
    title("Table S7. Institutions, fiscal cyclicality and the measure of government size") ///
    notes("Annual panel 1996–2019, growth of real GDP per capita on government size, institutions (mean of six WGI indicators, centred) and their interaction, with country and year fixed effects, lagged growth and the controls of Table 1; Driscoll-Kraay standard errors (maximum lag 3). Cyclicality (Frankel, Végh and Vuletin, 2013): country-specific slope of the log change in real government consumption on the output gap (two-sided HP), estimated over 1970–1995 (before the sample) or, as an exploratory check, over 1996–2023; entered as an interaction with consumption (centred). Correlation between pre-1996 cyclicality and average institutions across countries: `cyc_corr_pre' (`cyc_corr_pre_n' countries); with 1996–2023 cyclicality: `cyc_corr_in'. In a regression of the change in real government consumption on the output gap, its interaction with institutions is `cyc_resp_inter' (p = `cyc_resp_inter_p'). Last three rows: government consumption (WDI) in its own sample, consumption and total expenditure (IMF GFS) on the same country-years. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Figura 4: reconciliacao institucional (interacoes por medida)
* =====================================================================================
use "$RINT/replicas.dta", clear
gen lo = bi - 1.96 * sei
gen hi = bi + 1.96 * sei
gen str60 lab = ""
gen ord = .
local i = 0
foreach k in "opra_icrg gc_mean sgmm" "opra_icrg gc_tp sgmm" "opra_icrg gc_m1 sgmm" "opra_icrg gc_mean fe" "opra_icrg gc_tp fe" "opra_icrg gc_m1 fe" ///
    "opra_wgi gc_mean fe" "opra_wgi gc_tp fe" "opra_wgi gc_m1 fe" "mv gc fe_dk" "mv gc_ham fe_dk" "mv gc_l1 fe_dk" {
    local ++i
    tokenize `k'
    replace ord = 13 - `i' if rep == "`1'" & meas == "`2'" & est == "`3'"
}
keep if !missing(ord)
* intervalos padronizados por escala da instituicao nao sao comparaveis entre paineis: um painel por replica
gen grp = cond(rep == "mv", 3, cond(rep == "opra_wgi", 2, 1))
twoway (rcap lo hi ord if grp == 1, horizontal lcolor(black)) (scatter ord bi if grp == 1, msymbol(O) mcolor(black) msize(small)) ///
       (rcap lo hi ord if grp == 2, horizontal lcolor(gs7) lpattern(dash)) (scatter ord bi if grp == 2, msymbol(Dh) mcolor(gs5) msize(small)) ///
       (rcap lo hi ord if grp == 3, horizontal lcolor(black) lpattern(shortdash)) (scatter ord bi if grp == 3, msymbol(T) mcolor(black) msize(small)), ///
       $GOPT xline(0, lcolor(gs10) lpattern(shortdash)) ///
       ylabel(12 "OPRA, S-GMM: period mean" 11 "OPRA, S-GMM: t{sub:p}" 10 "OPRA, S-GMM: t{sub:p} − 1" 9 "OPRA, FE: period mean" 8 "OPRA, FE: t{sub:p}" 7 "OPRA, FE: t{sub:p} − 1" ///
              6 "OPRA (WGI), FE: period mean" 5 "OPRA (WGI), FE: t{sub:p}" 4 "OPRA (WGI), FE: t{sub:p} − 1" 3 "MV (approx.): contemporaneous" 2 "MV (approx.): % of trend GDP" 1 "MV (approx.): lagged", ///
              angle(0) labsize(7.5pt) nogrid) xlabel(, format(%3.1f) labsize(8pt)) ytitle("") yscale(range(0.5 12.5)) ///
       legend(order(2 "ICRG (QoG), 1981–2005" 4 "WGI, 1996–2020" 6 "WGI mean, annual 1996–2019") rows(1) pos(6) size(7.5pt)) ///
       xtitle("Interaction: government consumption × institutions (95% CI)", size(8pt))
rv_fig Fig4_reconciliation, width(190) height(110)

log close
