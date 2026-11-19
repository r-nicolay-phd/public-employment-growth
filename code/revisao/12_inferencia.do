* 12_inferencia.do -- bloco 4.11 do plano: H1b e H4, wild bootstrap, Romano-Wolf, curva de especificacoes,
* inferencia das projecoes locais e BMA [P30]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/revisao/00_setup.do"
capture log close
log using "$RLOG/12_inferencia.log", replace text

global XP "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"
global XPN "lny0 hc_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"
global XD "lny0 hc_tp inv open infl popg ctot_g"

* =====================================================================================
* A. H1b (restricao orcamentaria) e H4 (mecanismos) com o timing de T3
* =====================================================================================
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
* H1b: participacoes em t_p - 1; omitido: transferencias (principal) ou investimento publico
local shares "sh_goods_m1 sh_int_m1 sh_other_m1"
reghdfe g wagebill_share_m1 `shares' sh_inv_m1 exp_gdp_m1 rev_gdp_m1 $XP i.period, absorb(id) vce(cluster id)
estimates store H1b_tr
rv_boot wagebill_share_m1
estadd scalar pboot = r(p)
estimates store H1b_tr
reghdfe g wagebill_share_m1 `shares' sh_transf_m1 exp_gdp_m1 rev_gdp_m1 $XP i.period, absorb(id) vce(cluster id)
estimates store H1b_inv
rv_boot wagebill_share_m1
estadd scalar pboot = r(p)
estimates store H1b_inv
* participacao da folha mantida a despesa total (contrapartida do -0,027 do draft 7)
reghdfe g wagebill_share_m1 exp_gdp_m1 $XP i.period, absorb(id) vce(cluster id)
estimates store H1b_sh
rv_boot wagebill_share_m1
estadd scalar pboot = r(p)
estimates store H1b_sh
* T3 com WCB guardado
estimates use "$RINT/est_T3"
estimates store T3
reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
rv_boot wb_m1
estadd scalar pboot = r(p)
estimates store T3
* S-GMM e BC-FE com o timing de T3 (amostra propria)
quietly tab period, gen(pd)
drop pd1
xtabond2 g L_g wb_m1 $XP pd*, gmm(L_g, lag(1 2) collapse) gmm(wb_m1 lny0, lag(2 3) collapse) ///
    iv(hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1 pd*) twostep robust small
matrix DH = e(diffsargan)
estadd scalar dhansenp = DH[5, 1]
estadd scalar nins = e(j)
estimates store T3_gmm
xtdpdbc g wb_m1 $XP, fe lags(1) teffects vce(robust) small
estimates store T3_bc
* H4: investimento privado, crescimento da PTF e do emprego privado (medias do periodo), T3 sem investimento
foreach y in ipriv tfp_g privemp_g {
    reghdfe `y' wb_m1 $XPN i.period, absorb(id) vce(cluster id)
    estimates store H4_`y'
    rv_boot wb_m1
    estadd scalar pboot = r(p)
    estimates store H4_`y'
    rv_kv h4_`y'_b `=string(_b[wb_m1], "%9.4f")'
    rv_kv h4_`y'_p `=string(2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1])), "%9.4f")'
    rv_kv h4_`y'_pboot `=string(e(pboot), "%9.4f")'
    rv_kv h4_`y'_N `e(N)'
}
foreach m in H1b_tr H1b_inv H1b_sh {
    estimates restore `m'
    rv_kv `m'_b `=string(_b[wagebill_share_m1], "%9.4f")'
    rv_kv `m'_p `=string(2 * ttail(e(df_r), abs(_b[wagebill_share_m1] / _se[wagebill_share_m1])), "%9.4f")'
    rv_kv `m'_pboot `=string(e(pboot), "%9.4f")'
    rv_kv `m'_N `e(N)'
}
estimates restore T3_gmm
rv_kv T3gmm_b `=string(_b[wb_m1], "%12.8f")'
rv_kv T3gmm_p `=string(2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1])), "%9.4f")'
estimates restore T3_bc
rv_kv T3bc_b `=string(_b[wb_m1], "%12.8f")'
rv_kv T3bc_p `=string(2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1])), "%9.4f")'
foreach m in T3 H1b_tr H1b_inv H1b_sh T3_gmm T3_bc H4_ipriv H4_tfp_g H4_privemp_g {
    estimates restore `m'
    estimates save "$RINT/est_`m'", replace
}

* =====================================================================================
* B. Romano-Wolf (step-down) com as mesmas 999 reamostras de paises em todos os testes
* =====================================================================================
* rwolf2 nao aceita equacoes em bases distintas (cinco anos e anual) nem troca o identificador dos efeitos
* fixos nas reamostras; a implementacao abaixo segue Romano e Wolf (2005, 2016): t* = (b* - b) / se* em cada
* reamostra de paises (efeitos fixos no identificador da copia), p ajustado pelo maximo |t*| dos testes restantes.
local B = 999
use "$RINT/anual_rv.dta", clear
keep if micro == 0
keep id
duplicates drop
tempfile ids
save `ids'
set seed 20261017
forvalues r = 1/`B' {
    quietly use `ids', clear
    quietly bsample
    quietly contract id, freq(n`r')
    if `r' == 1 {
        tempfile W
        quietly save `W'
    }
    else {
        quietly merge 1:1 id using `W', nogen
        quietly save `W', replace
    }
}
use `W', clear
forvalues r = 1/`B' {
    quietly replace n`r' = 0 if missing(n`r')
}
save "$RINT/rw_draws.dta", replace

capture program drop rw_test
program define rw_test
    * rw_test codigo arquivo "condicao" "comando com @ no lugar do id dos efeitos fixos" var tvar(year|period)
    args code file cond cmd v tv
    local cmd0 : subinstr local cmd "@" "id", all
    local cmdb : subinstr local cmd "@" "bid", all
    quietly use "`file'", clear
    quietly keep if `cond'
    quietly `cmd0'
    local b0 = _b[`v']
    local t0 = _b[`v'] / _se[`v']
    quietly keep if e(sample)
    quietly merge m:1 id using "$RINT/rw_draws.dta", keep(match) nogen
    tempfile base
    quietly save `base'
    tempname R
    postfile `R' int r double tstar using "$RINT/rw_`code'.dta", replace
    forvalues r = 1/$RWB {
        quietly use `base', clear
        quietly drop if n`r' == 0
        quietly expand n`r'
        quietly bysort id `tv': gen int cp = _n
        quietly egen long bid = group(id cp)
        capture quietly `cmdb'
        if !_rc post `R' (`r') ((_b[`v'] - `b0') / _se[`v'])
        else post `R' (`r') (.)
    }
    postclose `R'
    post RWT ("`code'") (`b0') (`t0')
end
global RWB = `B'

* famila 1: testes principais de H1-H5
tempname RWT0
postfile RWT str20 code double(b t) using "$RINT/rw_main.dta", replace
rw_test H1 "$RINT/p5_rv.dta" "micro == 0" "reghdfe g wb_m1 $XP i.period, absorb(@) vce(cluster @)" wb_m1 period
rw_test H1b "$RINT/p5_rv.dta" "micro == 0" "reghdfe g wagebill_share_m1 sh_goods_m1 sh_int_m1 sh_other_m1 sh_inv_m1 exp_gdp_m1 rev_gdp_m1 $XP i.period, absorb(@) vce(cluster @)" wagebill_share_m1 period
* H2: modelo em logs na amostra harmonizada (variaveis construidas como em 05_decomposicao.do)
use "$RINT/p5_rv.dta", clear
keep if micro == 0
gen lpe = ln(pe_sel)
gen lrw = ln(wb_sel / pe_sel)
gen prem01 = prem_sel / 0.1
gen byte sH = !missing(g, lpe, lrw, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
save "$RINT/p5_h2.dta", replace
rw_test H2 "$RINT/p5_h2.dta" "micro == 0 & sH" "reghdfe g lpe lrw $XP i.period, absorb(@) vce(cluster @)" lrw period
* H3: interacao centrada (merito em t_p - 1 centrado na media da amostra de estimacao)
use "$RINT/h3_dados.dta", clear
save "$RINT/p5_h3.dta", replace
rw_test H3 "$RINT/p5_h3.dta" "sM" "reghdfe g wb_m1 meritc wbxm $XP i.period, absorb(@) vce(cluster @)" wbxm period
rw_test H4inv "$RINT/p5_rv.dta" "micro == 0" "reghdfe ipriv wb_m1 $XPN i.period, absorb(@) vce(cluster @)" wb_m1 period
rw_test H4tfp "$RINT/p5_rv.dta" "micro == 0" "reghdfe tfp_g wb_m1 $XPN i.period, absorb(@) vce(cluster @)" wb_m1 period
* H5: primeiro estagio em democracias (painel anual)
use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
xtset id year
gen L_g = L.g
keep if inrange(year, 1996, 2020) & dem == 1
save "$RINT/anual_h5.dta", replace
rw_test H5 "$RINT/anual_h5.dta" "1" "reghdfe d_wagebill_real election_fixed L_g i.year, absorb(@) vce(cluster @)" election_fixed year
postclose RWT

* familias 2: sete horizontes da LP por regime de merito (diferenca alto - baixo) e por tipo de choque em democracias
use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
xtset id year
gen byte smp = !missing(d_wagebill_real, L.d_wagebill_real, L2.d_wagebill_real, L.g, L2.g) & inrange(year, 1996, 2023)
quietly summ merit_l1 if smp, detail
gen byte mhi = merit_l1 > r(p50) if !missing(merit_l1)
gen shi = d_wagebill_real * (mhi == 1) if !missing(mhi)
gen slo = d_wagebill_real * (mhi == 0) if !missing(mhi)
gen sdif = shi
gen sel = d_wagebill_real * (election_fixed == 1) if !missing(election_fixed)
gen sot = d_wagebill_real * (election_fixed == 0) if !missing(election_fixed)
forvalues k = 1/2 {
    gen dw_l`k' = L`k'.d_wagebill_real
    gen g_l`k' = L`k'.g
}
forvalues hh = 0/6 {
    gen dy`hh' = F`hh'.y100 - L.y100
}
* reparametrizacao: shi + slo = choque total; o coeficiente de shi com o choque total no modelo mede alto - baixo
gen stot = d_wagebill_real if !missing(mhi)
gen stotE = d_wagebill_real if !missing(election_fixed)
save "$RINT/anual_lp_rw.dta", replace
postfile RWT str20 code double(b t) using "$RINT/rw_lpmerit.dta", replace
forvalues hh = 0/6 {
    rw_test M`hh' "$RINT/anual_lp_rw.dta" "inrange(year, 1996, 2023)" "reghdfe dy`hh' shi stot i.mhi dw_l1 dw_l2 g_l1 g_l2 i.year, absorb(@) vce(cluster @)" shi year
}
postclose RWT
postfile RWT str20 code double(b t) using "$RINT/rw_lpelec.dta", replace
forvalues hh = 0/6 {
    rw_test E`hh' "$RINT/anual_lp_rw.dta" "inrange(year, 1996, 2020) & dem == 1" "reghdfe dy`hh' sel stotE i.election_fixed dw_l1 dw_l2 g_l1 g_l2 i.year, absorb(@) vce(cluster @)" sel year
}
postclose RWT

* p-valores ajustados (Romano-Wolf step-down)
capture program drop rw_adjust
program define rw_adjust
    args fam
    use "$RINT/rw_`fam'.dta", clear
    local K = _N
    forvalues k = 1/`K' {
        local c`k' = code[`k']
    }
    tempname T
    mkmat t, matrix(`T')
    local B = $RWB
    mata: TS = J(`B', `K', .)
    forvalues k = 1/`K' {
        preserve
        use "$RINT/rw_`c`k''.dta", clear
        mata: TS[., `k'] = st_data(., "tstar")
        restore
    }
    * reamostras que falharam (raras) entram com t* = 0
    mata: TS = editmissing(TS, 0)
    mata: _rwp(st_matrix("`T'"), TS)
    gen double p_raw = .
    gen double p_rw = .
    forvalues k = 1/`K' {
        replace p_raw = PR[`k', 1] in `k'
        replace p_rw = PRW[`k', 1] in `k'
    }
    list, noobs
    save "$RINT/rw_`fam'_adj.dta", replace
end
mata:
void _rwp(real colvector t, real matrix TS)
{
    real scalar K, B, j, i, r, cnt, cntj
    real colvector o, praw, padj, mx
    K = rows(t)
    B = rows(TS)
    o = order(-abs(t), 1)
    praw = J(K, 1, .)
    padj = J(K, 1, .)
    for (j = 1; j <= K; j++) {
        i = o[j]
        cnt = 0
        cntj = 0
        for (r = 1; r <= B; r++) {
            mx = max(abs(TS[r, o[j..K]]))
            if (mx >= abs(t[i])) cnt++
            if (abs(TS[r, i]) >= abs(t[i])) cntj++
        }
        padj[i] = (cnt + 1) / (B + 1)
        praw[i] = (cntj + 1) / (B + 1)
        if (j > 1) padj[i] = max((padj[i], padj[o[j - 1]]))
    }
    st_matrix("PR", praw)
    st_matrix("PRW", padj)
}
end
rw_adjust main
foreach k in H1 H1b H2 H3 H4inv H4tfp H5 {
    quietly summ p_rw if code == "`k'"
    rv_kv rw_`k' `=string(r(mean), "%6.3f")'
    quietly summ p_raw if code == "`k'"
    rv_kv rwraw_`k' `=string(r(mean), "%6.3f")'
}
rw_adjust lpmerit
rw_adjust lpelec

* =====================================================================================
* C. Curva de especificacoes (216 especificacoes)
* =====================================================================================
tempname S
postfile `S' byte(meas ctrl freq smp fe) double(b se) long(N) using "$RINT/specurve.dta", replace
foreach L in 5 3 {
    use "$RINT/p`L'_rv.dta", clear
    xtset id period
    forvalues m = 1/3 {
        local w : word `m' of wb_tp wb_m1 wb_ham_m1
        forvalues c = 1/3 {
            local X : word `c' of "$XD" "$XP" "$XPN"
            forvalues s = 1/4 {
                local cs : word `s' of "micro == 0" "1" "micro == 0 & crisis_p != 1" "micro == 0 & year0 >= 1994"
                forvalues f = 1/3 {
                    local ab : word `f' of "id" "id id#c.period" "id region_id#period"
                    capture quietly reghdfe g `w' `X' i.period if `cs', absorb(`ab') vce(cluster id)
                    if _rc continue
                    post `S' (`m') (`c') (`L') (`s') (`f') (_b[`w']) (_se[`w']) (e(N))
                }
            }
        }
    }
}
postclose `S'
use "$RINT/specurve.dta", clear
gen lo = b - 1.96 * se
gen hi = b + 1.96 * se
count
rv_kv sc_n `r(N)'
count if b < 0
rv_kv sc_neg `r(N)'
count if hi < 0
rv_kv sc_negsig `r(N)'
count if lo > 0
rv_kv sc_possig `r(N)'
summ b, detail
rv_kv sc_med `=string(r(p50), "%6.3f")'
sort b
gen rank = _n
* painel de escolhas: cada dimensao em linhas
local yl ""
gen y_m = cond(meas == 1, -1, cond(meas == 2, -2, -3))
gen y_c = cond(ctrl == 1, -4.5, cond(ctrl == 2, -5.5, -6.5))
gen y_f = cond(freq == 5, -8, -9)
gen y_s = cond(smp == 1, -10.5, cond(smp == 2, -11.5, cond(smp == 3, -12.5, -13.5)))
gen y_e = cond(fe == 1, -15, cond(fe == 2, -16, -17))
twoway (rspike lo hi rank, lcolor(gs11)) (scatter b rank if hi < 0, msymbol(O) msize(vsmall) mcolor(black)) ///
       (scatter b rank if hi >= 0, msymbol(Oh) msize(vsmall) mcolor(gs6)), ///
       $GOPT yline(0, lcolor(gs8) lpattern(shortdash)) ylabel(, format(%3.1f) labsize(7.5pt) nogrid angle(horizontal)) ///
       xlabel(none) xtitle("") ytitle("Wage bill coefficient (95% CI)", size(8pt)) ///
       legend(order(2 "95% CI below zero" 3 "95% CI includes zero") rows(1) pos(12) size(7pt)) name(sc1, replace) nodraw
twoway (scatter y_m rank, msymbol(S) msize(tiny) mcolor(black)) (scatter y_c rank, msymbol(S) msize(tiny) mcolor(black)) ///
       (scatter y_f rank, msymbol(S) msize(tiny) mcolor(black)) (scatter y_s rank, msymbol(S) msize(tiny) mcolor(black)) ///
       (scatter y_e rank, msymbol(S) msize(tiny) mcolor(black)), $GOPT legend(off) xlabel(none) xtitle("Specifications, ranked by coefficient", size(8pt)) ///
       ylabel(-1 "Wage bill in t{sub:p}" -2 "Wage bill in t{sub:p} − 1" -3 "t{sub:p} − 1, % of trend GDP" -4.5 "Period-mean controls" -5.5 "Predetermined controls" ///
              -6.5 "Predetermined, no investment" -8 "Five-year averages" -9 "Three-year averages" -10.5 "Sample: baseline" -11.5 "Incl. microstates" ///
              -12.5 "Excl. banking crises" -13.5 "Post-1994" -15 "Country + period FE" -16 "+ country trends" -17 "+ region × period FE", angle(0) labsize(6.5pt) nogrid) ///
       ytitle("") fysize(60) name(sc2, replace) nodraw
graph combine sc1 sc2, cols(1) imargin(small) graphregion(color(white)) xcommon
rv_fig Fig9_specification_curve, width(190) height(150)

* =====================================================================================
* D. Inferencia das projecoes locais: defasagens aumentadas (HC) e jackknife de meio painel
* =====================================================================================
use "$RINT/anual_lp_rw.dta", clear
xtset id year
gen dw_l3 = L3.d_wagebill_real
gen g_l3 = L3.g
tempname Q
postfile `Q' str8 m int h double(b_dk se_dk b_la se_la b_jk) using "$RINT/lp_inferencia.dta", replace
forvalues hh = 0/6 {
    * choque total (D1 do draft 7)
    quietly xtscc dy`hh' d_wagebill_real dw_l1 dw_l2 g_l1 g_l2 i.year if inrange(year, 1996, 2023), fe lag($DKLAG)
    local bdk = _b[d_wagebill_real]
    local sdk = _se[d_wagebill_real]
    quietly reghdfe dy`hh' d_wagebill_real dw_l1 dw_l2 dw_l3 g_l1 g_l2 g_l3 if inrange(year, 1996, 2023), absorb(id year) vce(robust)
    local bla = _b[d_wagebill_real]
    local sla = _se[d_wagebill_real]
    quietly xtscc dy`hh' d_wagebill_real dw_l1 dw_l2 g_l1 g_l2 i.year if inrange(year, 1996, 2009), fe lag($DKLAG)
    local b1 = _b[d_wagebill_real]
    quietly xtscc dy`hh' d_wagebill_real dw_l1 dw_l2 g_l1 g_l2 i.year if inrange(year, 2010, 2023), fe lag($DKLAG)
    local b2 = _b[d_wagebill_real]
    post `Q' ("shock") (`hh') (`bdk') (`sdk') (`bla') (`sla') (2 * `bdk' - (`b1' + `b2') / 2)
    * merito alto (regime) com o choque total como controle: coeficiente = diferenca alto - baixo
    quietly xtscc dy`hh' shi stot i.mhi dw_l1 dw_l2 g_l1 g_l2 i.year if inrange(year, 1996, 2023), fe lag($DKLAG)
    local bdk = _b[shi]
    local sdk = _se[shi]
    quietly reghdfe dy`hh' shi stot i.mhi dw_l1 dw_l2 dw_l3 g_l1 g_l2 g_l3 if inrange(year, 1996, 2023), absorb(id year) vce(robust)
    local bla = _b[shi]
    local sla = _se[shi]
    quietly xtscc dy`hh' shi stot i.mhi dw_l1 dw_l2 g_l1 g_l2 i.year if inrange(year, 1996, 2009), fe lag($DKLAG)
    local b1 = _b[shi]
    quietly xtscc dy`hh' shi stot i.mhi dw_l1 dw_l2 g_l1 g_l2 i.year if inrange(year, 2010, 2023), fe lag($DKLAG)
    local b2 = _b[shi]
    post `Q' ("meritdif") (`hh') (`bdk') (`sdk') (`bla') (`sla') (2 * `bdk' - (`b1' + `b2') / 2)
}
postclose `Q'
use "$RINT/lp_inferencia.dta", clear
list, noobs sepby(m)

* =====================================================================================
* E. BMA na amostra efetiva de T3 (efeitos fixos retirados por Frisch-Waugh)
* =====================================================================================
use "$RINT/p5_rv.dta", clear
keep if micro == 0
merge 1:1 id period using "$RINT/amostra_T3.dta", keep(master match) nogen
keep if S5_T3
local bv g wb_m1 lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1 debt_m1 merit_m1
foreach v of local bv {
    drop if missing(`v')
}
foreach v of local bv {
    quietly reghdfe `v', absorb(id period) resid(r_`v')
}
drop if missing(r_g)
count
rv_kv bma_N `r(N)'
local aux ""
foreach v of local bv {
    if "`v'" != "g" local aux `aux' r_`v'
}
bma r_g, auxiliary(`aux')
matrix PIP = e(pip)
local k = colnumb(PIP, "r_wb_m1")
rv_kv bma_pip_wb `=string(PIP[1, `k'], "%6.3f")'
matrix BB = e(b)
rv_kv bma_b_wb `=string(BB[1, colnumb(BB, "r_wb_m1")], "%6.3f")'
local auxw : subinstr local aux "r_wb_m1" "", all
* WALS: a folha como regressor focal (sempre incluido) e os demais como auxiliares
capture noisily wals r_g r_wb_m1, auxiliary(`auxw') noconstant
if !_rc {
    rv_kv wals_b_wb `=string(_b[r_wb_m1], "%6.3f")'
    rv_kv wals_t_wb `=string(_b[r_wb_m1] / _se[r_wb_m1], "%6.2f")'
}
clear
local names : colnames PIP
local kk : word count `names'
set obs `kk'
gen str32 var = ""
gen pip = .
gen b = .
forvalues j = 1/`kk' {
    local nm : word `j' of `names'
    replace var = subinstr("`nm'", "r_", "", 1) in `j'
    replace pip = PIP[1, `j'] in `j'
    replace b = BB[1, colnumb(BB, "`nm'")] in `j'
}
save "$RINT/bma_rev.dta", replace

log close
