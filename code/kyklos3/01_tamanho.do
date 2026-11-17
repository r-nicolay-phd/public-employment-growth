* 01_tamanho.do -- Bloco 1: H1 x H2 e o tamanho da folha (amostras e formas funcionais)
* Plano: docs/plan_addendum_kyklos_3.md, Bloco 1. Especificacao de T3 (controles em t_p - 1, efeitos fixos de pais e
* periodo, erros agrupados por pais) com a folha em nivel e em log, em quatro amostras; conversao do log por ponto do PIB
* na media da amostra; testes por bootstrap de pares de paises (999); decomposicao da diferenca T3 x H2.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/01_tamanho.log", replace text
local BR = cond("$BOOTR" == "", 999, real("$BOOTR"))

use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen relw_sel = wb_sel / pe_sel
gen lpe = ln(pe_sel)
gen lrw = ln(relw_sel)
gen prem01 = prem_sel / 0.1
gen lwm = ln(wb_m1)
gen lws = ln(wb_sel)
quietly reghdfe g wb_m1 $XP i.period, absorb(id) vce(cluster id)
gen byte sa = e(sample)
gen byte sb = sa & year0 >= 1999
gen byte sc = !missing(g, lpe, lrw, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
gen byte sd = inrange(yd, 1, 4) & !missing(g, lpe, lrw, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
quietly summ year0 if sc
rv_kv b1_sc_minyear0 `r(min)'
di "primeiro periodo da amostra H2: `r(min)'"
keep id period year0 g wb_m1 wb_sel lwm lws sa sb sc sd $XP
save "$RINT/tam_base.dta", replace

* especificacoes: amostra, regressor, rotulo do regressor em nivel (para a media)
local specs "a_wm a_lwm b_wm b_lwm c_wm c_lwm c_ws c_lws d_wm d_lwm d_ws d_lws"
capture program drop tam_est
program define tam_est, rclass
    * tam_est idvar -> r(<spec>) coeficientes em pontos por ponto do PIB (log convertido na media da amostra)
    args idv
    foreach s in a b c d {
        foreach x in wm lwm ws lws {
            if inlist("`s'", "a", "b") & inlist("`x'", "ws", "lws") continue
            local v = cond("`x'" == "wm", "wb_m1", cond("`x'" == "lwm", "lwm", cond("`x'" == "ws", "wb_sel", "lws")))
            local lv = cond(inlist("`x'", "wm", "lwm"), "wb_m1", "wb_sel")
            capture quietly reghdfe g `v' $XP i.period if s`s' & !missing(`lv'), absorb(`idv')
            if _rc {
                return scalar `s'_`x' = .
                continue
            }
            local b = _b[`v']
            if substr("`x'", 1, 1) == "l" {
                quietly summ `lv' if e(sample)
                local b = `b' / r(mean)
            }
            return scalar `s'_`x' = `b'
        }
    }
end

tempname P
postfile `P' str2 smp str4 x double(b se lo hi pboot conv conv_lo conv_hi mean) long(N nc) using "$RINT/tam_res.dta", replace
foreach s in a b c d {
    foreach x in wm lwm ws lws {
        if inlist("`s'", "a", "b") & inlist("`x'", "ws", "lws") continue
        local v = cond("`x'" == "wm", "wb_m1", cond("`x'" == "lwm", "lwm", cond("`x'" == "ws", "wb_sel", "lws")))
        local lv = cond(inlist("`x'", "wm", "lwm"), "wb_m1", "wb_sel")
        reghdfe g `v' $XP i.period if s`s' & !missing(`lv'), absorb(id) vce(cluster id)
        local b = _b[`v']
        local se = _se[`v']
        local df = e(df_r)
        local N = e(N)
        local nc = e(N_clust)
        quietly summ `lv' if e(sample)
        local m = r(mean)
        kboot `v'
        local pb = r(p)
        local lo = `b' - invttail(`df', 0.025) * `se'
        local hi = `b' + invttail(`df', 0.025) * `se'
        local isl = substr("`x'", 1, 1) == "l"
        local cv = cond(`isl', `b' / `m', `b')
        local cl = cond(`isl', `lo' / `m', `lo')
        local ch = cond(`isl', `hi' / `m', `hi')
        post `P' ("`s'") ("`x'") (`b') (`se') (`lo') (`hi') (`pb') (`cv') (`cl') (`ch') (`m') (`N') (`nc')
    }
}
postclose `P'
use "$RINT/tam_res.dta", clear
list, noobs sep(4)

* ---------------------------------------------------------------- bootstrap de pares de paises
use "$RINT/tam_base.dta", clear
tam_est id
foreach s of local specs {
    local o_`s' = r(`s')
}
tempfile base
save `base'
tempname B
postfile `B' int r double(`specs') using "$RINT/tam_boot.dta", replace
set seed 20261116
forvalues r = 1/`BR' {
    quietly use `base', clear
    quietly bsample, cluster(id) idcluster(bid)
    quietly tam_est bid
    local row ""
    foreach s of local specs {
        local row "`row' (r(`s'))"
    }
    post `B' (`r') `row'
}
postclose `B'
use "$RINT/tam_boot.dta", clear
tempname D
postfile `D' str16 stat str60 lab double(est lo hi p) long(nrep) using "$RINT/tam_dif.dta", replace
capture program drop pdif
program define pdif
    args D stat lab expr oexpr
    tempvar z
    quietly gen double `z' = `expr'
    quietly summ `z'
    local n = r(N)
    _pctile `z', p(2.5 97.5)
    local lo = r(r1)
    local hi = r(r2)
    quietly count if `z' > 0 & !missing(`z')
    local pp = min(1, 2 * min(r(N), `n' - r(N)) / `n')
    post `D' ("`stat'") ("`lab'") (`oexpr') (`lo') (`hi') (`pp') (`n')
end
pdif `D' ac_lev "(a) − (c), level, wage bill in t_p − 1" "a_wm - c_wm" `=`o_a_wm' - `o_c_wm''
pdif `D' ac_log "(a) − (c), log converted, wage bill in t_p − 1" "a_lwm - c_lwm" `=`o_a_lwm' - `o_c_lwm''
foreach s in a b c d {
    pdif `D' ll_`s' "Level − log converted, sample (`s'), t_p − 1" "`s'_wm - `s'_lwm" `=`o_`s'_wm' - `o_`s'_lwm''
}
foreach s in c d {
    pdif `D' llp_`s' "Level − log converted, sample (`s'), pair year" "`s'_ws - `s'_lws" `=`o_`s'_ws' - `o_`s'_lws''
}
pdif `D' st2 "Step (ii): functional form, (a) log − (a) level" "a_lwm - a_wm" `=`o_a_lwm' - `o_a_wm''
pdif `D' st3 "Step (iii): period, (b) − (a), log" "b_lwm - a_lwm" `=`o_b_lwm' - `o_a_lwm''
pdif `D' st4 "Step (iv): WWBI countries, (c) − (b), log, t_p − 1" "c_lwm - b_lwm" `=`o_c_lwm' - `o_b_lwm''
pdif `D' st5 "Step (v): timing of the pair, (c) pair year − (c) t_p − 1, log" "c_lws - c_lwm" `=`o_c_lws' - `o_c_lwm''
pdif `D' tot "Total, (c) pair year log − (a) level" "c_lws - a_wm" `=`o_c_lws' - `o_a_wm''
postclose `D'
use "$RINT/tam_dif.dta", clear
quietly summ est if stat == "tot"
local tot = r(mean)
gen double share = est / `tot' if inlist(stat, "st2", "st3", "st4", "st5")
list, noobs
save "$RINT/tam_dif.dta", replace

* ---------------------------------------------------------------- regra (adendo 3, Bloco 1)
use "$RINT/tam_res.dta", clear
quietly summ conv if smp == "a" & x == "lwm"
local la = r(mean)
local in90 = (`la' >= -0.2608744 & `la' <= -0.0240056)
quietly summ conv if smp == "c" & x == "lwm"
local lc = r(mean)
quietly summ conv_lo if smp == "c" & x == "lwm"
local lcl = r(mean)
quietly summ conv_hi if smp == "c" & x == "lwm"
local lch = r(mean)
local near = (`lcl' <= -0.5 & `lch' >= -0.5 & `lc' <= -0.35)
quietly count if inlist(smp, "a", "b", "c", "d") & inlist(x, "wm", "lwm") & conv <= -0.30 & pboot < 0.05
local cost = (r(N) > 0)
use "$RINT/tam_dif.dta", clear
quietly summ share if stat == "st5"
local tim = (r(mean) > 0.5)
rv_kv b1_in90 `in90'
rv_kv b1_near `near'
rv_kv b1_timing `tim'
rv_kv b1_cost `cost'
di "Bloco 1: log convertido em (a) = `la' (dentro do IC 90% de T3 = `in90'); (c) GFS t_p-1 = `lc' [`lcl'; `lch'] (perto de -0,5 = `near'); timing do par > 50% = `tim'; custo >= 0,3 com p < 0,05 = `cost'"
kcsv "$RINT/tam_res.dta" Table_A15_panel_size
kcsv "$RINT/tam_dif.dta" Table_A15_panel_size_differences
log close
