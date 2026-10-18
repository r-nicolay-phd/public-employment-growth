* 08_merito.do -- bloco 4.7 do plano: moderacao pelo recrutamento meritocratico (H3) [P29, P21]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/revisao/00_setup.do"
capture log close
log using "$RLOG/08_merito.log", replace text

global XP "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"

use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
* amostra de estimacao e centragem do merito em t_p - 1 na media dessa amostra
gen byte sM = !missing(g, wb_m1, merit_m1, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
quietly reghdfe g wb_m1 merit_m1 $XP i.period if sM, absorb(id) vce(cluster id)
replace sM = e(sample)
quietly summ merit_m1 if sM
local mbar = r(mean)
rv_kv h3_merit_mean `=string(`mbar', "%6.3f")'
gen meritc = merit_m1 - `mbar'
gen wbxm = wb_m1 * meritc
_pctile meritc if sM, p(10 90)
local q10 = r(r1)
local q90 = r(r2)
rv_kv h3_q10 `=string(`q10' + `mbar', "%6.3f")'
rv_kv h3_q90 `=string(`q90' + `mbar', "%6.3f")'

* ---------------------------------------------------------------- interacao linear (especificacao preferida de H3)
reghdfe g wb_m1 meritc wbxm $XP i.period if sM, absorb(id) vce(cluster id)
estimates store H3
local bi = _b[wbxm]
local sei = _se[wbxm]
local pi = 2 * ttail(e(df_r), abs(`bi' / `sei'))
rv_boot wbxm
local pbi = r(p)
rv_kv h3_bi `=string(`bi', "%9.4f")'
rv_kv h3_sei `=string(`sei', "%9.4f")'
rv_kv h3_pi `=string(`pi', "%9.4f")'
rv_kv h3_pboot `=string(`pbi', "%9.4f")'
rv_kv h3_bmain `=string(_b[wb_m1], "%9.4f")'
rv_kv h3_N `e(N)'
rv_kv h3_nc `e(N_clust)'
lincom wb_m1 + `q10' * wbxm
rv_kv h3_me10 `=string(r(estimate), "%9.4f")'
lincom wb_m1 + `q90' * wbxm
rv_kv h3_me90 `=string(r(estimate), "%9.4f")'
* efeito minimo detectavel (poder de 80%, alfa = 5%, bilateral): (1,96 + 0,84) x EP
local mde = (invnormal(0.975) + invnormal(0.80)) * `sei'
* magnitude economicamente relevante: metade do coeficiente de T3 entre os percentis 10 e 90 do merito
estimates use "$RINT/est_T3"
local bT3 = _b[wb_m1]
local rel = 0.5 * abs(`bT3') / (`q90' - `q10')
rv_kv h3_mde `=string(`mde', "%9.4f")'
rv_kv h3_relevant `=string(`rel', "%9.4f")'
rv_kv h3_p1090 `=string(`q90' - `q10', "%6.3f")'

* ---------------------------------------------------------------- HMX: tercis com teste de Wald de linearidade
_pctile meritc if sM, p(33.333 66.667)
local c1 = r(r1)
local c2 = r(r2)
gen byte bin = cond(meritc <= `c1', 1, cond(meritc <= `c2', 2, 3)) if sM
tempname B
postfile `B' int bin double(zmed me se) long(n) using "$RINT/h3_bins.dta", replace
forvalues k = 1/3 {
    quietly summ meritc if bin == `k', detail
    local z`k' = r(p50)
    gen byte G`k' = bin == `k'
    gen DG`k' = wb_m1 * G`k'
    gen ZG`k' = (meritc - `z`k'') * G`k'
    gen DZG`k' = wb_m1 * (meritc - `z`k'') * G`k'
}
* estimador por faixas (um modelo, controles e efeitos fixos comuns): efeito marginal na mediana de cada faixa
reghdfe g DG1 DG2 DG3 ZG1 ZG2 ZG3 DZG1 DZG2 DZG3 G2 G3 $XP i.period if sM, absorb(id) vce(cluster id)
estimates store H3_bins
forvalues k = 1/3 {
    quietly count if bin == `k'
    post `B' (`k') (`z`k'' + `mbar') (_b[DG`k']) (_se[DG`k']) (r(N))
    rv_kv h3_bin`k' `=string(_b[DG`k'], "%9.4f")'
}
postclose `B'
* Wald (HMX): o modelo linear restrito contra o modelo por faixas (termos adicionais das faixas 2 e 3)
reghdfe g wb_m1 meritc wbxm G2 G3 DG2 DG3 ZG2 ZG3 DZG2 DZG3 $XP i.period if sM, absorb(id) vce(cluster id)
test G2 G3 DG2 DG3 ZG2 ZG3 DZG2 DZG3
rv_kv h3_wald_p `=string(r(p), "%9.4f")'
* divisao da amostra por tercis (modelos separados: efeitos fixos e controles proprios de cada faixa)
forvalues k = 1/3 {
    reghdfe g wb_m1 $XP i.period if sM & bin == `k', absorb(id) vce(cluster id)
    estimates store H3_split`k'
    rv_kv h3_split`k' `=string(_b[wb_m1], "%9.4f")'
    rv_kv h3_split`k'_N `e(N)'
}
* divisao na mediana
quietly summ meritc if sM, detail
gen byte above = meritc > r(p50) if sM
forvalues k = 0/1 {
    reghdfe g wb_m1 $XP i.period if sM & above == `k', absorb(id) vce(cluster id)
    estimates store H3_med`k'
    rv_kv h3_med`k' `=string(_b[wb_m1], "%9.4f")'
}
save "$RINT/h3_dados.dta", replace

* ---------------------------------------------------------------- kernel (interflex), com bootstrap por pais
preserve
keep if sM
* O kernel do interflex falha com efeitos fixos (bootstrap devolve ICs ausentes e a rotina grafica quebra) e nao
* converge com as dummies como covariaveis; por isso o kernel e implementado aqui: regressao local-linear com
* nucleo gaussiano, largura de banda escolhida pela validacao cruzada do interflex (0,49), efeitos fixos de pais e
* periodo, 25 pontos entre os percentis 5 e 95 do merito e bootstrap por pais (200 replicacoes).
local bw = 0.4897
_pctile meritc, p(5 95)
local e0 = r(r1)
local e1 = r(r2)
tempname K
postfile `K' double(zk mek lok hik) using "$RINT/h3_kernel.dta", replace
tempfile base
save `base'
forvalues j = 1/25 {
    local z0 = `e0' + (`e1' - `e0') * (`j' - 1) / 24
    quietly use `base', clear
    quietly gen double kw = normalden((meritc - `z0') / `bw')
    quietly gen double zd = meritc - `z0'
    quietly gen double dzd = wb_m1 * zd
    quietly reghdfe g wb_m1 zd dzd $XP i.period [aw = kw], absorb(id)
    local me0 = _b[wb_m1]
    tempname R
    tempfile rr
    postfile `R' double me using `rr', replace
    set seed 20261017
    forvalues r = 1/200 {
        quietly use `base', clear
        quietly bsample, cluster(id) idcluster(bid)
        quietly gen double kw = normalden((meritc - `z0') / `bw')
        quietly gen double zd = meritc - `z0'
        quietly gen double dzd = wb_m1 * zd
        capture quietly reghdfe g wb_m1 zd dzd $XP i.period [aw = kw], absorb(bid)
        if !_rc post `R' (_b[wb_m1])
    }
    postclose `R'
    quietly use `rr', clear
    quietly _pctile me, p(2.5 97.5)
    post `K' (`z0' + `mbar') (`me0') (r(r1)) (r(r2))
}
postclose `K'
rv_kv h3_kernel "executado (implementacao propria)"
use `base', clear
capture noisily interflex g wb_m1 meritc lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1, type(binning) fe(id period) ///
    vce(cluster) cluster(id) nbins(3) xlabel("Meritocratic recruitment in t_p − 1 (centred)") ylabel("Growth") dlabel("Wage bill")
if !_rc {
    graph export "$RFIG/FigS_interflex_binning.png", replace width(4488)
    graph export "$RFIG/FigS_interflex_binning.pdf", replace
}
restore

* =====================================================================================
* Limiares: Seo e Shin (2016) e Hansen (1999), painel anual balanceado, folha e merito defasados
* =====================================================================================
capture program drop setcmd
program define setcmd, eclass
    ereturn local cmd "`1'"
end
tempname T
postfile `T' str20 m double(b_lo b_hi thr pboot) long(N T nmom) using "$RINT/h3_threshold.dta", replace
foreach win in "2015 2019" "2000 2019" {
    use "$RINT/anual_rv.dta", clear
    keep if micro == 0
    xtset id year
    gen wb_l1 = L.wb
    local y0 : word 1 of `win'
    local y1 : word 2 of `win'
    keep if inrange(year, `y0', `y1')
    gen byte ok = !missing(g, wb_l1, merit_l1)
    bysort id: egen nok = total(ok)
    keep if nok == `y1' - `y0' + 1
    quietly levelsof id
    local Nbal : word count `r(levels)'
    local TT = `y1' - `y0' + 1
    local L = 0
    forvalues t = 3/`TT' {
        local L = `L' + 1 + (`t' - 2) + 1
    }
    xtset id year
    set seed 20261017
    capture noisily xthenreg g merit_l1 wb_l1, boost(500) grid_num(100) trim_rate(0.4)
    if !_rc {
        local k = colnumb(e(b), "wb_l1_b")
        local kd = colnumb(e(b), "wb_l1_d")
        post `T' ("seoshin_`y0'") (el(e(b), 1, `k')) (el(e(b), 1, `k') + el(e(b), 1, `kd')) (el(e(b), 1, colnumb(e(b), "r"))) (e(boots_p)) (`Nbal') (`TT') (`L')
        rv_kv thr_ss_`y0'_p `=string(e(boots_p), "%6.3f")'
        rv_kv thr_ss_`y0'_valid `=cond(`L' < `Nbal' / 2, "yes", "no")'
    }
    if `y0' == 2000 {
        quietly tab year, gen(yd)
        drop yd1
        capture noisily xthreg g yd*, rx(wb_l1) qx(merit_l1) thnum(1) trim(0.10) grid(300) bs(500)
        if !_rc {
            matrix FH = e(Fstat)
            matrix TH = e(Thrss)
            local hn : colnames e(b)
            local b1 = .
            local b2 = .
            local kk = 0
            foreach nm of local hn {
                local ++kk
                if strpos("`nm'", "wb_l1") == 0 continue
                if missing(`b1') local b1 = el(e(b), 1, `kk')
                else local b2 = el(e(b), 1, `kk')
            }
            post `T' ("hansen_2000") (`b1') (`b2') (TH[1, 1]) (FH[1, 4]) (`Nbal') (`TT') (0)
            rv_kv thr_hansen_p `=string(FH[1, 4], "%6.3f")'
        }
        * P21: o mesmo painel balanceado, modelo linear sem limiar (com e sem os controles e o crescimento defasado da Tabela 1)
        xtreg g wb_l1 yd*, fe vce(cluster id)
        rv_kv thr_lin_static `=string(_b[wb_l1], "%9.4f")'
        gen g_l1 = L.g
        gen lny_l1 = L.lny
        xtreg g wb_l1 g_l1 lny_l1 hc inv open infl popg ctot_g yd*, fe vce(cluster id)
        rv_kv thr_lin_controls `=string(_b[wb_l1], "%9.4f")'
        rv_kv thr_lin_N `e(N)'
    }
}
postclose `T'

* =====================================================================================
* Figura 6: efeito marginal ao longo do merito (linear, faixas), com histograma e N
* =====================================================================================
use "$RINT/h3_dados.dta", clear
estimates restore H3
local df = e(df_r)
local N = e(N)
quietly summ meritc if sM
local lo0 = r(min)
local hi0 = r(max)
preserve
clear
set obs 61
gen z = `lo0' + (`hi0' - `lo0') * (_n - 1) / 60
gen me = .
gen lo = .
gen hi = .
forvalues i = 1/61 {
    local zz = z[`i']
    quietly lincom wb_m1 + `zz' * wbxm
    quietly replace me = r(estimate) in `i'
    quietly replace lo = r(estimate) - invttail(`df', 0.025) * r(se) in `i'
    quietly replace hi = r(estimate) + invttail(`df', 0.025) * r(se) in `i'
}
gen zr = z + `mbar'
tempfile ME
save `ME'
use "$RINT/h3_bins.dta", clear
gen blo = me - invttail(`df', 0.025) * se
gen bhi = me + invttail(`df', 0.025) * se
append using `ME'
append using "$RINT/h3_kernel.dta"
twoway (rarea lo hi zr, fcolor(gs14) lcolor(gs8) lpattern(dash) lwidth(vthin)) (line me zr, lcolor(black)) ///
       (line mek zk, lcolor(gs4) lpattern(longdash)) (line lok zk, lcolor(gs8) lpattern(dot)) (line hik zk, lcolor(gs8) lpattern(dot)) ///
       (rcap blo bhi zmed, lcolor(black)) (scatter me zmed, msymbol(D) mcolor(black) msize(small)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(shortdash)) ylabel(, format(%3.1f) labsize(8pt) nogrid angle(horizontal)) ///
       xlabel(, format(%3.1f) labsize(8pt)) legend(order(2 "Linear interaction (95% CI)" 3 "Kernel (dotted: 95% CI, country bootstrap)" 7 "Tercile bins (95% CI)") rows(1) pos(6) size(7pt)) ///
       xtitle("Meritocratic recruitment (V-Dem), t{sub:p} − 1; higher = more merit-based", size(8pt)) ///
       ytitle("Marginal effect of the wage bill on growth (p.p.)", size(8pt)) name(me, replace) nodraw
restore
twoway (histogram merit_m1 if sM, frequency color(gs12) lcolor(gs8) width(0.25)), $GOPT ///
    xlabel(, format(%3.1f) labsize(8pt)) ylabel(, labsize(7pt) nogrid angle(horizontal)) ytitle("Count", size(7.5pt)) ///
    xtitle("") fysize(28) name(hist, replace) nodraw
graph combine me hist, cols(1) imargin(small) graphregion(color(white)) xcommon ///
    note("N = `N' country-periods", size(7pt))
rv_fig Fig6_marginal_merit, width(190) height(120)

* =====================================================================================
* Tabela suplementar: moderacao (H3)
* =====================================================================================
rv_new, ncol(7) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
    head2("Linear (preferred)" "Bins (HMX)" "Split: tercile 1" "Split: tercile 2" "Split: tercile 3" "Split: below median" "Split: above median")
rv_estrow "Wage bill (% of GDP), t_p − 1", models(H3 . H3_split1 H3_split2 H3_split3 H3_med0 H3_med1) vars(wb_m1)
rv_estrow "Wage bill × merit (centred)", models(H3 . . . . . .) vars(wbxm)
rv_estrow "Marginal effect, tercile 1 (median of bin)", models(. H3_bins . . . . .) vars(DG1)
rv_estrow "Marginal effect, tercile 2 (median of bin)", models(. H3_bins . . . . .) vars(DG2)
rv_estrow "Marginal effect, tercile 3 (median of bin)", models(. H3_bins . . . . .) vars(DG3)
rv_mid
rv_stat "Observations", models(H3 H3_bins H3_split1 H3_split2 H3_split3 H3_med0 H3_med1) stat(N)
rv_stat "Countries", models(H3 H3_bins H3_split1 H3_split2 H3_split3 H3_med0 H3_med1) stat(N_clust)
import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
foreach k in h3_merit_mean h3_pboot h3_wald_p h3_mde h3_relevant h3_p1090 h3_q10 h3_q90 thr_ss_2015_p thr_hansen_p thr_lin_static thr_lin_controls {
    quietly levelsof value if key == "`k'", local(`k') clean
    local `k' : word `: word count ``k''' of ``k''
}
foreach k in h3_merit_mean h3_q10 h3_q90 thr_lin_static thr_lin_controls {
    local `k' = subinstr(string(real("``k''"), "%9.3f"), "-", "−", 1)
    local `k' = strtrim("``k''")
}
rv_row "Wild cluster bootstrap p (interaction)" "`=string(real("`h3_pboot'"), "%5.3f")'" "" "" "" "" "" ""
rv_row "HMX Wald test of linearity, p" "" "`=string(real("`h3_wald_p'"), "%5.3f")'" "" "" "" "" ""
rv_row "Minimum detectable interaction (80% power)" "`=string(real("`h3_mde'"), "%5.3f")'" "" "" "" "" "" ""
rv_row "Economically relevant interaction" "`=string(real("`h3_relevant'"), "%5.3f")'" "" "" "" "" "" ""
rv_out TabS_moderation, landscape ///
    title("Table S9. Does meritocratic recruitment moderate the wage bill coefficient? (H3)") ///
    notes("Dependent variable: growth of real GDP per capita (%, five-year average). Wage bill and merit (V-Dem v2stcritrecadm; higher values = more merit-based) in t_p − 1; merit is centred at its estimation-sample mean (`h3_merit_mean'), so the main effect in column 1 is evaluated at average merit. Predetermined controls of Table 2, country and period fixed effects, standard errors clustered by country. Column 2: binning estimator of Hainmueller, Mummolo and Xu (2019), one model with bin-specific intercepts and slopes and common controls and fixed effects; marginal effects at the median of each tercile; the Wald test compares it with the linear model. Columns 3–7: separate regressions in each tercile or half, each with its own fixed effects (singletons dropped within each subsample), which is why they differ from column 2. Minimum detectable effect: (1.96 + 0.84) × standard error of the interaction. Economically relevant interaction: half of the preferred H1 coefficient (T3) divided by the distance between the 10th and 90th percentiles of merit (`h3_q10' to `h3_q90'). Threshold models (annual balanced panels, wage bill and merit lagged one year): Seo and Shin (2016), 2015–2019, linearity bootstrap p = `thr_ss_2015_p'; Hansen (1999), 2000–2019, p = `thr_hansen_p'. In the Hansen panel the linear fixed-effects coefficient of the lagged wage bill is `thr_lin_static' without controls and `thr_lin_controls' with the controls and lagged growth of Table 1, so the large regime coefficients reflect the static specification, not the threshold. * p<0.10, ** p<0.05, *** p<0.01.")

log close
