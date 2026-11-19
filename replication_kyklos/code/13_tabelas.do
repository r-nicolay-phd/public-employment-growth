* 13_tabelas.do -- tabelas que juntam os blocos: Tabela 3 (base e composicao), Tabela 8 (mapa de robustez),
* mecanismos (H4), projecoes locais por horizonte, resumo da inferencia e vereditos, descritivas (S2), paises (S14),
* captions.md e MAPA_NUMERACAO.md
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
capture log close
log using "$RLOG/13_tabelas.log", replace text

* registro chave-valor em macros KV_<chave>
capture program drop kvload
program define kvload
    preserve
    import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
    gen long n = _n
    bysort key (n): keep if _n == _N
    forvalues i = 1/`=_N' {
        c_local KV_`=key[`i']' "`=value[`i']'"
    }
    restore
end
kvload

* =====================================================================================
* Vereditos (regra do plano, secao 2.1): sinal previsto, p do wild bootstrap e Romano-Wolf
* =====================================================================================
* erros-padrao das especificacoes preferidas guardadas em disco
estimates use "$RINT/est_H1b_tr"
local se_H1b = _se[wagebill_share_m1]
estimates use "$RINT/est_H4_ipriv"
local se_H4inv = _se[wb_m1]
estimates use "$RINT/est_H4_tfp_g"
local se_H4tfp = _se[wb_m1]
tempname V
postfile `V' str6 h str60 lab str6 sign double(b se lo hi p pboot prw) str20 verdict using "$RINT/vereditos.dta", replace
foreach h in H1 H1b H2 H3 H4inv H4tfp H5 {
    if "`h'" == "H1" {
        local b = `KV_T3_own_b'
        local se = `KV_T3_own_se'
        local p = `KV_T3_own_p'
        local pb = `KV_T3_own_pboot'
        local s = -1
        local lab "Wage bill (t_p − 1), five-year growth (T3)"
    }
    if "`h'" == "H1b" {
        local b = `KV_H1b_tr_b'
        local se = `se_H1b'
        local p = `KV_H1b_tr_p'
        local pb = `KV_H1b_tr_pboot'
        local s = -1
        local lab "Wage bill share of spending, transfers omitted"
    }
    if "`h'" == "H2" {
        local b = `KV_d_log_lrw_b'
        local se = `KV_d_log_lrw_se'
        local p = `KV_d_log_lrw_p'
        local pb = `KV_d_log_lrw_pboot'
        local s = -1
        local lab "log relative public wage (log model)"
    }
    if "`h'" == "H3" {
        local b = `KV_h3_bi'
        local se = `KV_h3_sei'
        local p = `KV_h3_pi'
        local pb = `KV_h3_pboot'
        local s = 1
        local lab "Wage bill × merit (mitigation predicted)"
    }
    if "`h'" == "H4inv" {
        local b = `KV_h4_ipriv_b'
        local se = `se_H4inv'
        local p = `KV_h4_ipriv_p'
        local pb = `KV_h4_ipriv_pboot'
        local s = -1
        local lab "Wage bill (t_p − 1) on private investment"
    }
    if "`h'" == "H4tfp" {
        local b = `KV_h4_tfp_g_b'
        local se = `se_H4tfp'
        local p = `KV_h4_tfp_g_p'
        local pb = `KV_h4_tfp_g_pboot'
        local s = -1
        local lab "Wage bill (t_p − 1) on TFP growth"
    }
    if "`h'" == "H5" {
        local b = `KV_ep_dem_b'
        local se = `KV_ep_dem_se'
        local p = `KV_ep_dem_p'
        local pb = `KV_ep_dem_pboot'
        local s = 1
        local lab "Predetermined election on wage bill change (democracies)"
    }
    local prw = `KV_rw_`h''
    local ok = sign(`b') == `s'
    local v "Not supported"
    if `ok' & `pb' < 0.05 & `prw' < 0.05 local v "Supported"
    else if `ok' & ((`pb' >= 0.05 & `pb' < 0.10) | (`pb' < 0.05 & `prw' >= 0.05)) local v "Inconclusive"
    post `V' ("`h'") ("`lab'") ("`=cond(`s' < 0, "−", "+")'") (`b') (`se') (`b' - 1.96 * `se') (`b' + 1.96 * `se') (`p') (`pb') (`prw') ("`v'")
    rv_kv verdict_`h' "`v'"
}
postclose `V'
use "$RINT/vereditos.dta", clear
list, noobs
* enquadramento (secao 2.2 do plano)
kvload
local H1v "`KV_verdict_H1'"
local A = ("`H1v'" == "Supported") & (`KV_dl_wbL_sum' < 0) & (`KV_dl_wbL_sum_pboot' < 0.05) & ///
    (`KV_dl_wbL_sum_bootlo' <= `KV_T3_own_b') & (`KV_dl_wbL_sum_boothi' >= `KV_T3_own_b')
local nitida_dec = (`KV_vies_wb_placebo_b' < 0) & (`KV_vies_wb_placebo_p' < 0.05) & (`KV_dif_12_p' < 0.05)
* replicas nitidas: sinal publicado com p < 0,10 na medida contemporanea e perda de significancia na predeterminada
preserve
use "$RINT/replicas.dta", clear
quietly summ pi if rep == "opra_icrg" & meas == "gc_mean" & est == "sgmm"
local o_c = r(mean)
quietly summ bi if rep == "opra_icrg" & meas == "gc_mean" & est == "sgmm"
local o_cb = r(mean)
quietly summ pi if rep == "opra_icrg" & meas == "gc_m1" & est == "sgmm"
local o_p = r(mean)
quietly summ pi if rep == "mv" & meas == "gc"
local m_c = r(mean)
quietly summ bi if rep == "mv" & meas == "gc"
local m_cb = r(mean)
quietly summ pi if rep == "mv" & meas == "gc_l1"
local m_p = r(mean)
* sensibilidade (exploratoria, depois do plano): a mesma regra aplicada a replica com a especificacao publicada
* de Mollick e Vianna (GE, mesma amostra); nao entra na regra registrada do cenario
use "$RINT/mv_fiel.dta", clear
quietly summ pX if inst == "ge" & per == "full" & smp == "common" & meas == "lgy"
local f_c = r(mean)
quietly summ bX if inst == "ge" & per == "full" & smp == "common" & meas == "lgy"
local f_cb = r(mean)
quietly summ pX if inst == "ge" & per == "full" & smp == "common" & meas == "lgy_l1"
local f_p = r(mean)
restore
local nit_mvf = (`f_cb' < 0) & (`f_c' < 0.10) & (`f_p' >= 0.10)
rv_kv nit_mvf `nit_mvf'
local nit_opra = (`o_cb' > 0) & (`o_c' < 0.10) & (`o_p' >= 0.10)
local nit_mv = (`m_cb' < 0) & (`m_c' < 0.10) & (`m_p' >= 0.10)
local C = (`KV_afg_fs_Feff' >= 10) | (`KV_afg_y100_h4_p' < 0.05)
local B = ("`H1v'" != "Supported") & `nitida_dec' & (`nit_opra' | `nit_mv')
local cen = cond(`C', "C", cond(`A', "A", cond(`B', "B", "B (parcial)")))
rv_kv scen_A `A'
rv_kv scen_B `B'
rv_kv scen_C `C'
rv_kv nitida_dec `nitida_dec'
rv_kv nit_opra `nit_opra'
rv_kv nit_mv `nit_mv'
rv_kv cenario "`cen'"
di "Cenario: `cen' (A = `A', B = `B', C = `C'; decomposicao nitida = `nitida_dec'; OPRA = `nit_opra'; MV = `nit_mv')"

* =====================================================================================
* Tabela 3 (texto principal): resultado de base e composicao
* =====================================================================================
foreach m in T3 T3_gmm T3_bc H1b_sh H1b_tr H1b_inv {
    estimates use "$RINT/est_`m'"
    estimates store `m'
}
rv_new, ncol(6) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
    head2("Fixed effects (T3)" "System GMM" "BC-FE" "Share, total spending held" "Budget: transfers omitted" "Budget: investment omitted")
rv_estrow "Wage bill (% of GDP), t_p − 1", models(T3 T3_gmm T3_bc . . .) vars(wb_m1)
rv_estrow "Wage bill (% of total expenditure), t_p − 1", models(. . . H1b_sh H1b_tr H1b_inv) vars(wagebill_share_m1)
rv_estrow "Lagged growth (previous period)", models(. T3_gmm . . . .) vars(L_g)
rv_estrow "Lagged growth (previous period)", models(. . T3_bc . . .) vars(L.g)
rv_estrow "Total expenditure (% of GDP), t_p − 1", models(. . . H1b_sh H1b_tr H1b_inv) vars(exp_gdp_m1)
rv_estrow "Total revenue (% of GDP), t_p − 1", models(. . . . H1b_tr H1b_inv) vars(rev_gdp_m1)
rv_mid
rv_stat "Wild cluster bootstrap p-value (wage bill)", models(T3 . . H1b_sh H1b_tr H1b_inv) stat(pboot) fmt(%12.3f)
rv_stat "Observations", models(T3 T3_gmm T3_bc H1b_sh H1b_tr H1b_inv) stat(N)
rv_stat "Countries", models(T3 T3_gmm T3_bc H1b_sh H1b_tr H1b_inv) stat(N_clust)
rv_stat "Groups (GMM, BC-FE)", models(. T3_gmm T3_bc . . .) stat(N_g)
rv_stat "Instruments", models(. T3_gmm . . . .) stat(nins)
rv_stat "AR(2), p-value", models(. T3_gmm . . . .) stat(ar2p) fmt(%12.3f)
rv_stat "Hansen, p-value", models(. T3_gmm . . . .) stat(hansenp) fmt(%12.3f)
rv_stat "Difference-in-Hansen (levels), p-value", models(. T3_gmm . . . .) stat(dhansenp) fmt(%12.3f)
rv_row "Controls" "Predetermined" "Predetermined" "Predetermined" "Predetermined" "Predetermined" "Predetermined"
rv_row "Country FE" "Yes" "GMM" "Yes" "Yes" "Yes" "Yes"
rv_row "Period FE" "Yes" "Yes" "Yes" "Yes" "Yes" "Yes"
rv_row "Standard errors" "Cluster" "Windmeijer" "Robust" "Cluster" "Cluster" "Cluster"
rv_out Tab3_baseline_composition, landscape ///
    title("Table 3. Baseline estimates and the composition of spending") ///
    notes("Dependent variable: growth of real GDP per capita (%, five-year average), 1979–2023; all regressors in t_p − 1, the last year of the previous period. Predetermined controls: log GDP per capita, human capital, investment, openness, inflation, population growth and commodity terms-of-trade growth, all in t_p − 1. Column 1: preferred H1 specification (T3), country and period fixed effects, standard errors clustered by country. Column 2: two-step system GMM with lagged growth, the wage bill and initial income instrumented by lags 2–3 (lagged growth: lags 1–2), collapsed, other controls and period dummies as standard instruments; Windmeijer-corrected standard errors. Column 3: bias-corrected fixed effects (Breitung, Kripfganz and Hayakawa, 2022), which assumes the controls are strictly exogenous; robust standard errors. Columns 4–6: wage bill as a share of total expenditure (expense plus net investment in non-financial assets); column 4 holds total expenditure constant; columns 5–6 add the shares of goods and services, interest, other expense and either public investment (5) or transfers (6), total expenditure and revenue, so the wage-bill coefficient measures a reallocation of one percentage point of spending from the omitted category; the fiscal balance is implied. Shares, revenue and expenditure follow the extended cleaning rules (Table S1). Wild cluster bootstrap: Webb weights, 9,999 replications, clustered by country. Countries row: clusters (columns 1, 4–6) or groups (columns 2–3). * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela suplementar: mecanismos (H4)
* =====================================================================================
foreach m in H4_ipriv H4_tfp_g H4_privemp_g {
    estimates use "$RINT/est_`m'"
    estimates store `m'
}
rv_new, ncol(3) head1("Private investment (% of GDP)" "TFP growth (%)" "Private employment growth (%)")
rv_estrow "Wage bill (% of GDP), t_p − 1", models(H4_ipriv H4_tfp_g H4_privemp_g) vars(wb_m1)
rv_mid
rv_stat "Wild cluster bootstrap p-value", models(H4_ipriv H4_tfp_g H4_privemp_g) stat(pboot) fmt(%12.3f)
rv_row "Romano-Wolf adjusted p-value (H1–H5 family)" "`KV_rw_H4inv'" "`KV_rw_H4tfp'" ""
rv_stat "Observations", models(H4_ipriv H4_tfp_g H4_privemp_g) stat(N)
rv_stat "Countries", models(H4_ipriv H4_tfp_g H4_privemp_g) stat(N_clust)
rv_out TabS_mechanisms, ///
    title("Table S12. Mechanisms: private investment, productivity and private employment (H4)") ///
    notes("Five-year averages of the dependent variable, 1979–2023: private investment (IMF Investment and Capital Stock Dataset, available to 2019), TFP growth (Penn World Table 11.0) and private employment growth (ILOSTAT, total minus public employment from the same survey). Wage bill in t_p − 1; predetermined controls of Table 2 without investment, which is the mediator; country and period fixed effects; standard errors clustered by country. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela suplementar: resumo da inferencia e vereditos
* =====================================================================================
use "$RINT/vereditos.dta", clear
rv_new, ncol(6) head1("Predicted sign" "Coefficient" "p (cluster)" "p (wild bootstrap)" "p (Romano-Wolf)" "Verdict")
forvalues i = 1/`=_N' {
    rv_fmt `=b[`i']' %12.3f
    local bb "`r(s)'"
    rv_row "`=h[`i']': `=lab[`i']'" "`=sign[`i']'" "`bb'" "`=string(p[`i'], "%5.3f")'" "`=string(pboot[`i'], "%5.3f")'" "`=string(prw[`i'], "%5.3f")'" "`=verdict[`i']'"
}
rv_out TabS_inference_summary, landscape ///
    title("Table S13. Hypothesis tests: preferred specifications, bootstrap and multiple-testing adjustment") ///
    notes("Preferred specification of each hypothesis as registered in the analysis plan (commit 2182199, 17 October 2026). Wild cluster bootstrap: Webb weights, 9,999 replications, clustered by country. Romano-Wolf step-down p-values over the seven tests, from 999 bootstrap resamples of countries shared by all tests (each test re-estimated on every resample with fixed effects on the resampled country copies). Verdict rule: supported if the coefficient has the predicted sign, the bootstrap p-value is below 0.05 and the Romano-Wolf p-value is below 0.05; inconclusive if the sign is right and the bootstrap p-value is between 0.05 and 0.10, or below 0.05 without surviving Romano-Wolf; not supported otherwise. H3 predicts mitigation (positive interaction); H5 uses the first stage in democracies.")

* =====================================================================================
* Tabela suplementar: projecoes locais por horizonte (coeficientes, p ajustados e inferencia alternativa)
* =====================================================================================
use "$RINT/estrutural_lp.dta", clear
keep if spec == "base"
tempfile LPM
save `LPM'
use "$RINT/rw_lpmerit_adj.dta", clear
gen h = real(substr(code, 2, .))
keep h p_raw p_rw
merge 1:1 h using `LPM', nogen
sort h
rv_new, ncol(7) head1("h = 0" "h = 1" "h = 2" "h = 3" "h = 4" "h = 5" "h = 6")
foreach row in bhi blo {
    local cb ""
    local cs ""
    forvalues hh = 0/6 {
        quietly summ `row' if h == `hh'
        local b = r(mean)
        quietly summ se`=substr("`row'", 2, .)' if h == `hh'
        rv_fmt `b' %12.3f `=2 * normal(-abs(`b' / r(mean)))'
        local cb `"`cb' "`r(s)'""'
        quietly summ se`=substr("`row'", 2, .)' if h == `hh'
        rv_fmt `=r(mean)' %12.3f
        local cs `"`cs' "(`r(s)')""'
    }
    rv_row "`=cond("`row'" == "bhi", "High merit: response to a 1 p.p. wage bill shock", "Low merit")'" `cb'
    rv_row "" `cs'
}
local r1 ""
local r2 ""
local r3 ""
local r4 ""
forvalues hh = 0/6 {
    quietly summ pdiff if h == `hh'
    rv_fmt `=r(mean)' %12.3f
    local r1 `"`r1' "`r(s)'""'
    quietly summ p_rw if h == `hh'
    rv_fmt `=r(mean)' %12.3f
    local r2 `"`r2' "`r(s)'""'
    quietly summ nep_hi if h == `hh'
    local n1 = r(mean)
    quietly summ nc_hi if h == `hh'
    local r3 `"`r3' "`n1' / `=r(mean)'""'
    quietly summ N if h == `hh'
    rv_fmt `=r(mean)' %12.0fc
    local r4 `"`r4' "`r(s)'""'
}
rv_row "p-value, high = low (Driscoll-Kraay)" `r1'
rv_row "Romano-Wolf p-value, high − low (7 horizons)" `r2'
rv_row "High-merit episodes / countries" `r3'
rv_row "Observations" `r4'
rv_mid
use "$RINT/lp_inferencia.dta", clear
foreach mm in shock meritdif {
    foreach k in dk la jk {
        local cb ""
        forvalues hh = 0/6 {
            quietly summ b_`k' if m == "`mm'" & h == `hh'
            local b = r(mean)
            if "`k'" != "jk" {
                quietly summ se_`k' if m == "`mm'" & h == `hh'
                rv_fmt `b' %12.3f `=2 * normal(-abs(`b' / r(mean)))'
            }
            else rv_fmt `b' %12.3f
            local cb `"`cb' "`r(s)'""'
        }
        local lab = cond("`mm'" == "shock", "All countries", "High − low merit") + ": " + cond("`k'" == "dk", "Driscoll-Kraay (baseline)", cond("`k'" == "la", "lag-augmented, HC standard errors", "half-panel jackknife bias-corrected"))
        rv_row "`lab'" `cb'
    }
}
rv_out TabS_lp_horizons, landscape ///
    title("Table S14. Local projections by horizon: merit regimes, multiple-testing adjustment and alternative inference") ///
    notes("Cumulative response of 100 × log GDP per capita from t − 1 to t + h to a real wage bill shock of one percentage point of lagged GDP (conventional specification), annual panel 1996–2023, country and year fixed effects, two lags of the shock and of growth. Merit regimes: merit above the sample median in the year before the shock. Driscoll-Kraay standard errors (maximum lag 3). Romano-Wolf: step-down adjustment over the seven horizons of the high − low difference, 999 bootstrap resamples of countries (cluster-robust t statistics in the resamples). Lag-augmented local projections (Montiel Olea and Plagborg-Møller, 2021): one extra lag of the shock and of growth and heteroskedasticity-robust standard errors. Half-panel jackknife: 2 × full-sample estimate minus the average of the 1996–2009 and 2010–2023 estimates, a correction for the small-T fixed-effects bias; there is no Stata implementation of Herbst and Johannsen (2024), so their correction is not applied. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela 8 (texto principal): mapa de robustez
* =====================================================================================
kvload
tempname M
postfile `M' str70 lab double(b se p) long(N) str30 src using "$RINT/mapa.dta", replace
capture program drop addm
program define addm
    args M lab b p N src
    local se = .
    post `M' ("`lab'") (`b') (.) (`p') (`N') ("`src'")
end
addm `M' "Preferred (T3): wage bill in t_p − 1, predetermined controls" `KV_T3_own_b' `KV_T3_own_p' `KV_T3_own_N' "Table 2, col. 4"
addm `M' "Conventional timing (t_p, period-mean controls)" `KV_T6_own_b' `KV_T6_own_p' `KV_T6_own_N' "Table 2, col. 1"
addm `M' "Growth excluding the first year (T2)" `KV_T2_own_b' `KV_T2_own_p' `KV_T2_own_N' "Table 2, col. 3"
addm `M' "Three-year averages (T3)" `KV_T3_3y_b' `KV_T3_3y_p' `KV_T3_3y_N' "Table 2, col. 7"
addm `M' "Annual, all regressors lagged" `KV_A_pre_b' . `KV_A_pre_N' "Table 2, col. 8"
addm `M' "General government, common sample with central" `KV_cov_all_gg_b' `KV_cov_all_gg_p' `KV_cov_all_gg_N' "Table 4, col. 1"
addm `M' "Central government, common sample" `KV_cov_all_cg_b' `KV_cov_all_cg_p' `KV_cov_all_cg_N' "Table 4, col. 2"
addm `M' "Federations, general government" `KV_cov_fed_gg_b' `KV_cov_fed_gg_p' `KV_cov_fed_gg_N' "Table 4, col. 3"
addm `M' "Unitary countries, general government" `KV_cov_uni_gg_b' `KV_cov_uni_gg_p' `KV_cov_uni_gg_N' "Table 4, col. 5"
addm `M' "Country-specific linear trends" `KV_str_trend_b' `KV_str_trend_p' `KV_str_trend_N' "Table S8"
addm `M' "Region × period fixed effects" `KV_str_regper_b' `KV_str_regper_p' `KV_str_regper_N' "Table S8"
addm `M' "Excluding euro area 2009–2013" `KV_str_noeuro_b' `KV_str_noeuro_p' `KV_str_noeuro_N' "Table S8"
addm `M' "Periods from 1994–1998" `KV_str_post94_b' `KV_str_post94_p' `KV_str_post94_N' "Table S8"
addm `M' "Balanced panel" `KV_str_balanced_b' `KV_str_balanced_p' `KV_str_balanced_N' "Table S8"
addm `M' "Banking-crisis control" `KV_str_crisis_b' `KV_str_crisis_p' `KV_str_crisis_N' "Table S8"
addm `M' "Health and education share, IMF COFOG" `KV_str_healthcofog_b' `KV_str_healthcofog_p' `KV_str_healthcofog_N' "Table S8"
addm `M' "All structural changes together" `KV_str_all_b' `KV_str_all_p' `KV_str_all_N' "Table S8"
addm `M' "System GMM (T3 timing)" `KV_T3gmm_b' `KV_T3gmm_p' . "Table 3, col. 2"
addm `M' "Bias-corrected FE (T3 timing)" `KV_T3bc_b' `KV_T3bc_p' . "Table 3, col. 3"
postclose `M'
* acrescenta o longo prazo (S11) e a curva de especificacoes
use "$RINT/longo.dta", clear
gen p = 2 * normal(-abs(b / se))
keep if inlist(m, "pmg", "csardl")
gen str70 lab = cond(m == "pmg", "PMG, annual, ", "CS-ARDL(1,1), annual, ") + cond(w == "wbL", "lagged wage bill", "lagged wage bill over trend GDP")
gen str30 src = "Table S11"
keep lab b se p N src
append using "$RINT/mapa.dta"
gen ord = cond(src == "Table S11", 100 + _n, _n)
sort ord
rv_new, ncol(4) head1("Coefficient" "p-value" "Obs." "Source")
forvalues i = 1/`=_N' {
    rv_fmt `=b[`i']' %12.3f `=p[`i']'
    local bb "`r(s)'"
    local pp = cond(missing(p[`i']), "", string(p[`i'], "%5.3f"))
    local nn = cond(missing(N[`i']), "", string(N[`i'], "%9.0fc"))
    rv_row "`=lab[`i']'" "`bb'" "`pp'" "`nn'" "`=src[`i']'"
}
rv_mid
rv_row "Specification curve: share of the `KV_sc_n' estimates with a 95% CI below zero" "`=string(`KV_sc_negsig' / `KV_sc_n', "%5.3f")'" "" "" "Figure 9"
rv_row "Bayesian model averaging: posterior inclusion probability of the wage bill" "`KV_bma_pip_wb'" "" "`KV_bma_N'" "Table S15"
rv_out Tab8_robustness_map, ///
    title("Table 8. Robustness map of the wage bill coefficient") ///
    notes("Coefficient on the general government wage bill (% of GDP) in growth regressions; five-year averages with country and period fixed effects and clustered standard errors unless stated; annual rows use Driscoll-Kraay standard errors; long-run rows report long-run coefficients. p-values from the t distribution (cluster or Driscoll-Kraay) or the normal distribution (GMM, long run). Source: table or figure with the full specification. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Tabela suplementar: BMA
* =====================================================================================
use "$RINT/bma_rev.dta", clear
gsort -pip
rv_new, ncol(2) head1("Posterior inclusion probability" "Posterior mean")
forvalues i = 1/`=_N' {
    local v = var[`i']
    local lab = cond("`v'" == "wb_m1", "Wage bill (% of GDP), t_p − 1", cond("`v'" == "lny0", "Log GDP per capita, t_p − 1", ///
        cond("`v'" == "hc_m1", "Human capital, t_p − 1", cond("`v'" == "inv_m1", "Investment, t_p − 1", cond("`v'" == "open_m1", "Openness, t_p − 1", ///
        cond("`v'" == "infl_m1", "Inflation, t_p − 1", cond("`v'" == "popg_m1", "Population growth, t_p − 1", cond("`v'" == "ctot_g_m1", "Terms-of-trade growth, t_p − 1", ///
        cond("`v'" == "debt_m1", "Public debt, t_p − 1", "Meritocratic recruitment, t_p − 1")))))))))
    rv_fmt `=b[`i']' %12.3f
    rv_row "`lab'" "`=string(pip[`i'], "%5.3f")'" "`r(s)'"
}
rv_out TabS_bma, ///
    title("Table S15. Bayesian model averaging over the control set (T3 sample)") ///
    notes("Bayesian model averaging (De Luca and Magnus, 2011) over all 2^10 combinations of the regressors, all treated as auxiliary, after removing country and period fixed effects from every variable (Frisch-Waugh) in the effective T3 sample (`KV_bma_N' observations, singletons excluded). The posterior inclusion probability measures robustness to the choice of controls; it says nothing about endogeneity. Weighted-average least squares (WALS) on the same data: wage-bill coefficient `KV_wals_b_wb' (t = `KV_wals_t_wb').")

* =====================================================================================
* Tabela S2: descritivas das amostras de estimacao
* =====================================================================================
capture program drop descrow
program define descrow
    args v lab
    quietly summ `v', detail
    local m = r(mean)
    local sd = r(sd)
    local med = r(p50)
    local mn = r(min)
    local mx = r(max)
    local n = r(N)
    tempvar mi w
    quietly bysort id: egen double `mi' = mean(`v')
    quietly gen double `w' = `v' - `mi'
    quietly summ `mi' if !missing(`v')
    local sdb = r(sd)
    quietly summ `w'
    local sdw = r(sd)
    foreach x in m sd sdb sdw med mn mx {
        rv_fmt ``x'' %12.2f
        local f`x' "`r(s)'"
    }
    rv_row "`lab'" "`fm'" "`fsd'" "`fsdb'" "`fsdw'" "`fmed'" "`fmn'" "`fmx'" "`=string(`n', "%9.0fc")'"
end
rv_new, ncol(8) head1("Mean" "SD total" "SD between" "SD within" "Median" "Min" "Max" "N")
use "$RINT/p5_rv.dta", clear
keep if micro == 0
merge 1:1 id period using "$RINT/amostra_T3.dta", keep(master match) nogen
keep if S5_T3
rv_row "A. Five-year panel, T3 estimation sample" "" "" "" "" "" "" "" ""
descrow g "GDP per capita growth (%, period mean)"
descrow wb_m1 "Wage bill, general government (% of GDP), t_p − 1"
descrow wb_ham_m1 "Wage bill (% of trend GDP, Hamilton), t_p − 1"
descrow lny0 "Log GDP per capita, t_p − 1"
descrow hc_m1 "Human capital index, t_p − 1"
descrow inv_m1 "Investment (% of GDP), t_p − 1"
descrow open_m1 "Trade openness (% of GDP), t_p − 1"
descrow infl_m1 "Inflation (%), t_p − 1"
descrow popg_m1 "Population growth (%), t_p − 1"
descrow ctot_g_m1 "Commodity terms-of-trade growth (%), t_p − 1"
descrow merit_m1 "Meritocratic recruitment (V-Dem), t_p − 1"
rv_mid
use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023)
merge 1:1 id year using "$RINT/amostras1.dta", keep(master match) nogen
keep if S1_base
rv_row "B. Annual panel, Table 1 sample" "" "" "" "" "" "" "" ""
descrow g "GDP per capita growth (%)"
descrow wb "Wage bill, general government (% of GDP)"
descrow wb_ham "Wage bill (% of trend GDP, Hamilton)"
descrow wb_hp1 "Wage bill (% of trend GDP, one-sided HP)"
descrow d_wagebill_real "Real wage bill shock (% of lagged GDP)"
descrow rev_gdp "Total revenue (% of GDP)"
descrow balance_gdp "Fiscal balance (% of GDP)"
descrow infl "Inflation (%)"
rv_out TabS2_descriptives, landscape ///
    title("Table S2. Descriptive statistics of the estimation samples") ///
    notes("Panel A: country-periods of the preferred H1 specification (T3). Panel B: country-years of the annual rows of Table 1. SD between: standard deviation of country means; SD within: standard deviation after removing country means, the relevant variation with country fixed effects. Values follow the extended cleaning rules (revenue above 100% of GDP, fiscal balance outside ±50% of GDP and inflation above 1,000% treated as missing; growth and inflation winsorized at the 1st and 99th percentiles of the non-microstate sample, 1980–2023).")

* =====================================================================================
* Tabela S14b: paises da amostra efetiva (T3), por grupo de renda de 1996
* =====================================================================================
use "$RINT/p5_rv.dta", clear
keep if micro == 0
merge 1:1 id period using "$RINT/amostra_T3.dta", keep(master match) nogen
keep if S5_T3
collapse (count) n = g (firstnm) income_grp federal, by(iso3)
rv_new, ncol(2) head1("Countries (ISO3)" "N")
forvalues k = 1/4 {
    quietly levelsof iso3 if income_grp == `k', local(L) clean
    local nn : word count `L'
    local gg : word `k' of "Low income" "Lower middle income" "Upper middle income" "High income"
    rv_row "`gg'" "`L'" "`nn'"
}
quietly count
local tot = r(N)
rv_row "Total" "" "`tot'"
rv_out TabS16_countries, landscape ///
    title("Table S16. Countries in the preferred five-year estimation sample (T3), by 1996 income group") ///
    notes("Countries with at least one country-period in the T3 estimation sample (after singletons are dropped). World Bank income group in 1996.")

log close
