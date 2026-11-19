* 06_h2_reverso.do -- Bloco 6: H2 com controle para o canal reverso do denominador
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 6. Amostras: registrada (Tabela 3, col. 3) e estrita (Tabela A17).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/06_h2_reverso.log", replace text

* crescimento do PIB real por trabalhador entre o ano anterior ao par e o ano do par (item 3)
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & year >= 1970
xtset id year
gen double lgpw = ln(gdp_real / emp) if emp > 0
gen double dlgpw = lgpw - L.lgpw
keep if year >= 1975
gen period = floor((year - 1979) / 5)
gen byte first = year == 1979 + 5 * period
foreach d in 1 2 3 4 0 -1 -2 -3 {
    local s = cond(`d' > 0, "L`d'.", cond(`d' < 0, "F`=-`d''.", ""))
    gen double dg`=cond(`d' < 0, "m`=-`d''", "`d'")' = `s'dlgpw if first
}
keep if first & year >= 1979
keep id period dg*
tempfile gpw
save `gpw'

use "$KIN/p5_rv.dta", clear
keep if micro == 0
merge 1:1 id period using `gpw', keep(master match) nogen
xtset id period
gen relw_sel = wb_sel / pe_sel
gen lpe = ln(pe_sel)
gen lrw = ln(relw_sel)
gen lwbs = ln(wb_sel)
gen prem01 = prem_sel / 0.1
gen Lg = L.g
gen gap_m1 = -100 * lgap_ham_m1
gen double dgpw = .
foreach d in 1 2 3 4 0 -1 -2 -3 {
    replace dgpw = dg`=cond(`d' < 0, "m`=-`d''", "`d'")' if yd == `d'
}
gen lrwP = lrw + dgpw
gen byte sH = !missing(g, lpe, lrw, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
gen byte sS = inrange(yd, 1, 4) & !missing(g, lpe, lrw, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
count if sH
count if sS
save "$RINT/h2r_base.dta", replace

tempname P
postfile `P' str4 smp str6 spec str5 v double(b se p lo hi pboot blo bhi) long(N nc) using "$RINT/h2r_res.dta", replace
capture program drop posth
program define posth
    args P smp spec v
    local b = _b[`v']
    local se = _se[`v']
    local df = e(df_r)
    local N = e(N)
    local nc = e(N_clust)
    capture kboot `v'
    local pb = cond(_rc, ., r(p))
    local bl = cond(_rc, ., r(lo))
    local bh = cond(_rc, ., r(hi))
    post `P' ("`smp'") ("`spec'") ("`v'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
        (`b' + invttail(`df', 0.025) * `se') (`pb') (`bl') (`bh') (`N') (`nc')
end
foreach smp in H S {
    * referencia: modelo em log (Tabela 3 col. 3 ou Tabela A17)
    reghdfe g lpe lrw $XP i.period if s`smp', absorb(id) vce(cluster id)
    posth `P' `smp' base lrw
    * (1) crescimento de p - 1
    reghdfe g lpe lrw Lg $XP i.period if s`smp', absorb(id) vce(cluster id)
    posth `P' `smp' m1 lrw
    * (2) hiato em t_p - 1
    reghdfe g lpe lrw gap_m1 $XP i.period if s`smp', absorb(id) vce(cluster id)
    posth `P' `smp' m2 lrw
    * (1) + (2)
    reghdfe g lpe lrw Lg gap_m1 $XP i.period if s`smp', absorb(id) vce(cluster id)
    posth `P' `smp' m12 lrw
    * (3) salario relativo sobre o PIB real por trabalhador do ano anterior ao par
    reghdfe g lpe lrwP $XP i.period if s`smp', absorb(id) vce(cluster id)
    posth `P' `smp' m3 lrwP
    * (4) salario relativo com a folha total fixa, com os dois controles
    reghdfe g lrw lwbs $XP i.period if s`smp', absorb(id) vce(cluster id)
    posth `P' `smp' m4base lrw
    reghdfe g lrw lwbs Lg gap_m1 $XP i.period if s`smp', absorb(id) vce(cluster id)
    posth `P' `smp' m4 lrw
}
postclose `P'

* ---------------------------------------------------------------- Romano-Wolf na familia registrada, H2 com o controle
capture program drop rw_test
program define rw_test
    args code file cond cmd v tv
    local cmd0 : subinstr local cmd "@" "id", all
    local cmdb : subinstr local cmd "@" "bid", all
    quietly use "`file'", clear
    quietly keep if `cond'
    quietly `cmd0'
    local b0 = _b[`v']
    local t0 = _b[`v'] / _se[`v']
    quietly keep if e(sample)
    quietly merge m:1 id using "$KIN/rw_draws.dta", keep(match) nogen
    tempfile base
    quietly save `base'
    tempname R
    postfile `R' int r double tstar using "$RINT/rw_`code'.dta", replace
    forvalues r = 1/999 {
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
    global RW_b0 = `b0'
    global RW_t0 = `t0'
end
capture mata: mata drop _rwp()
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
rw_test H2m1 "$RINT/h2r_base.dta" "sH" "reghdfe g lpe lrw Lg $XP i.period, absorb(@) vce(cluster @)" lrw period
local t_m1 = $RW_t0
rw_test H2m2 "$RINT/h2r_base.dta" "sH" "reghdfe g lpe lrw gap_m1 $XP i.period, absorb(@) vce(cluster @)" lrw period
local t_m2 = $RW_t0
tempname F
postfile `F' str4 fam str10 code double(t p_raw p_rw) using "$RINT/h2r_rw.dta", replace
foreach fam in reg m1 m2 {
    use "$KIN/rw_main.dta", clear
    if "`fam'" != "reg" replace t = `t_`fam'' if code == "H2"
    local K = _N
    mkmat t, matrix(T)
    forvalues k = 1/`K' {
        local c`k' = code[`k']
    }
    mata: TS = J(999, `K', .)
    forvalues k = 1/`K' {
        local f = cond("`fam'" != "reg" & "`c`k''" == "H2", "$RINT/rw_H2`fam'.dta", "$KIN/rw_`c`k''.dta")
        preserve
        use "`f'", clear
        mata: TS[., `k'] = st_data(., "tstar")
        restore
    }
    mata: TS = editmissing(TS, 0)
    mata: _rwp(st_matrix("T"), TS)
    forvalues k = 1/`K' {
        post `F' ("`fam'") ("`c`k''") (T[`k', 1]) (PR[`k', 1]) (PRW[`k', 1])
    }
}
postclose `F'
use "$RINT/h2r_rw.dta", clear
list, noobs sepby(fam)
foreach fam in reg m1 m2 {
    quietly summ p_rw if fam == "`fam'" & code == "H2"
    rv_kv b6_rw_`fam' `=string(r(mean), "%6.4f")'
}

* ---------------------------------------------------------------- regra (adendo 2, Bloco 6)
use "$RINT/h2r_res.dta", clear
list, noobs sepby(smp)
kcsv "$RINT/h2r_res.dta" Table_A17_columns_reverse_denominator
quietly count if smp == "H" & inlist(spec, "m1", "m2", "m3") & pboot < 0.05
local keep = (r(N) == 3)
rv_kv b6_rule `=cond(`keep', "survives", "sensitive")'
di "Bloco 6: H2 mantem p < 0,05 nos tres modelos = `keep'"
log close
