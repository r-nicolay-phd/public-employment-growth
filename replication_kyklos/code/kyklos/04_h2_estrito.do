* 04_h2_estrito.do -- Bloco 4: H2 com timing estrito (pares do WWBI so de t_p - 1 a t_p - 4) e vies de divisao
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/04_h2_estrito.log", replace text

mata:
string scalar _arfmt(string scalar s)
{
    string scalar r, m, out
    real scalar k
    r = s
    out = ""
    while (ustrregexm(r, "-?[0-9]*\.[0-9]+|-?[0-9]+")) {
        m = ustrregexs(0)
        k = strpos(r, m)
        out = out + substr(r, 1, k - 1) + strofreal(strtoreal(m), "%9.2f")
        r = substr(r, k + strlen(m), .)
    }
    out = out + r
    out = subinstr(out, "entire grid", "(" + uchar(8722) + uchar(8734) + ", +" + uchar(8734) + ")")
    out = subinstr(out, "+inf", "+" + uchar(8734))
    out = subinstr(out, "[ ... ,", "(" + uchar(8722) + uchar(8734) + ",")
    out = subinstr(out, " U ", " " + uchar(8746) + " ")
    out = subinstr(out, "-", uchar(8722))
    out = stritrim(subinstr(out, "[ ", "["))
    return(out)
}
end

use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen relw_sel = wb_sel / pe_sel
gen lpe = ln(pe_sel)
gen lrw = ln(relw_sel)
gen lwbs = ln(wb_sel)
gen lrwh = ln(relh_sel)
gen lilo = ln(ilo_sel)
gen prem01 = prem_sel / 0.1
gen byte sH = !missing(g, lpe, lrw, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
gen byte strict = inrange(yd, 1, 4)
gen byte sS = strict & !missing(g, lpe, lrw, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
gen byte sP = inrange(ydp, 1, 4) & !missing(g, prem01, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
count if !missing(yd)
rv_kv h2s_pairs_all `r(N)'
count if !missing(yd) & !strict
rv_kv h2s_pairs_out `r(N)'
count if !missing(yd) & yd != 1
rv_kv h2s_pairs_not_m1 `r(N)'
tab yd
count if sS
rv_kv h2s_N `r(N)'
save "$RINT/p5_h2strict.dta", replace

tempname P
postfile `P' str10 spec str8 v double(b se p lo hi pboot blo bhi sdw sdg) long(N nc) str60 ar double(Feff) using "$RINT/h2s_res.dta", replace
capture program drop posth
program define posth
    args P spec v
    local b = _b[`v']
    local se = _se[`v']
    local df = e(df_r)
    local N = e(N)
    local nc = e(N_clust)
    tempvar dm w dg wg
    quietly bysort id: egen double `dm' = mean(`v') if e(sample)
    quietly gen double `w' = `v' - `dm' if e(sample)
    quietly summ `w'
    local sdw = r(sd)
    quietly bysort id: egen double `dg' = mean(g) if e(sample)
    quietly gen double `wg' = g - `dg' if e(sample)
    quietly summ `wg'
    local sdg = r(sd)
    capture kboot `v'
    local pb = cond(_rc, ., r(p))
    local bl = cond(_rc, ., r(lo))
    local bh = cond(_rc, ., r(hi))
    post `P' ("`spec'") ("`v'") (`b') (`se') (2 * ttail(`df', abs(`b' / `se'))) (`b' - invttail(`df', 0.025) * `se') ///
        (`b' + invttail(`df', 0.025) * `se') (`pb') (`bl') (`bh') (`sdw') (`sdg') (`N') (`nc') ("") (.)
    rv_kv h2s_`spec'_`v'_b `=string(`b', "%9.4f")'
    rv_kv h2s_`spec'_`v'_pboot `=string(`pb', "%9.4f")'
end
* registrado (amostra harmonizada) para comparacao, e o -1,68 da Tabela S6
reghdfe g lpe lrw $XP i.period if sH, absorb(id) vce(cluster id)
posth `P' reg lpe
reghdfe g lpe lrw $XP i.period if sH, absorb(id) vce(cluster id)
posth `P' reg lrw
reghdfe g lrw lwbs $XP i.period if sH, absorb(id) vce(cluster id)
posth `P' regsepW lrw
* amostra estrita
reghdfe g lpe lrw $XP i.period if sS, absorb(id) vce(cluster id)
posth `P' a lpe
reghdfe g lpe lrw $XP i.period if sS, absorb(id) vce(cluster id)
posth `P' a lrw
reghdfe g lpe lwbs $XP i.period if sS, absorb(id) vce(cluster id)
posth `P' bE lpe
reghdfe g lrw lwbs $XP i.period if sS, absorb(id) vce(cluster id)
posth `P' bW lrw
reghdfe g lpe lrwh $XP i.period if sS, absorb(id) vce(cluster id)
posth `P' c lrwh
reghdfe g prem01 $XP i.period if sP, absorb(id) vce(cluster id)
posth `P' e prem01
* (d) IV: emprego do WWBI instrumentado pelo do ILOSTAT, F efetivo e IC de Anderson-Rubin
ivreghdfe g lrw $XP (lpe = lilo) i.period if sS, absorb(id) cluster(id)
local biv = _b[lrw]
local seiv = _se[lrw]
local bivE = _b[lpe]
local seivE = _se[lpe]
local Niv = e(N)
local nciv = e(N_clust)
gen byte sIV = e(sample)
capture kboot lrw
local pbiv = cond(_rc, ., r(p))
reghdfe lpe lilo lrw $XP i.period if sIV, absorb(id) vce(cluster id)
local Feff = (_b[lilo] / _se[lilo])^2
local ar ""
capture noisily weakiv ivreg2 g lrw $XP i.period i.id (lpe = lilo) if sIV, cluster(id)
if !_rc {
    local ar "`e(ar_cset)'"
    mata: st_local("ar", _arfmt(st_local("ar")))
}
post `P' ("d") ("lrw") (`biv') (`seiv') (2 * normal(-abs(`biv' / `seiv'))) (`biv' - 1.96 * `seiv') (`biv' + 1.96 * `seiv') ///
    (`pbiv') (.) (.) (.) (.) (`Niv') (`nciv') ("") (`Feff')
post `P' ("d") ("lpe") (`bivE') (`seivE') (2 * normal(-abs(`bivE' / `seivE'))) (`bivE' - 1.96 * `seivE') (`bivE' + 1.96 * `seivE') ///
    (.) (.) (.) (.) (.) (`Niv') (`nciv') ("`ar'") (`Feff')
rv_kv h2s_iv_Feff `=string(`Feff', "%9.2f")'
rv_kv h2s_iv_ar "`ar'"
postclose `P'

* =====================================================================================
* Romano-Wolf: familia registrada e familia alternativa com H2 na amostra estrita (mesmos 999 sorteios)
* =====================================================================================
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
rw_test H2strict "$RINT/p5_h2strict.dta" "sS" "reghdfe g lpe lrw $XP i.period, absorb(@) vce(cluster @)" lrw period
local bS = $RW_b0
local tS = $RW_t0
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
tempname F
postfile `F' str10 fam str10 code double(t p_raw p_rw) using "$RINT/h2s_rw.dta", replace
foreach fam in registered strict {
    use "$KIN/rw_main.dta", clear
    if "`fam'" == "strict" {
        replace t = `tS' if code == "H2"
        replace b = `bS' if code == "H2"
    }
    local K = _N
    mkmat t, matrix(T)
    forvalues k = 1/`K' {
        local c`k' = code[`k']
    }
    mata: TS = J(999, `K', .)
    forvalues k = 1/`K' {
        local f = cond("`fam'" == "strict" & "`c`k''" == "H2", "$RINT/rw_H2strict.dta", "$KIN/rw_`c`k''.dta")
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
use "$RINT/h2s_rw.dta", clear
list, noobs
foreach fam in registered strict {
    quietly summ p_rw if fam == "`fam'" & code == "H2"
    rv_kv h2s_rw_`fam' `=string(r(mean), "%6.3f")'
    local rw_`fam' = r(mean)
}

* =====================================================================================
* regra (adendo, Bloco 4) e Tabela S22
* =====================================================================================
use "$RINT/h2s_res.dta", clear
list spec v b se p pboot blo bhi sdw sdg N nc Feff ar, noobs sep(0)
kcsv "$RINT/h2s_res.dta" TabS22_h2_strict
quietly summ pboot if spec == "a" & v == "lrw"
local pS = r(mean)
local keep = (`pS' < 0.05)
rv_kv h2s_keep `keep'
di "Bloco 4: p bootstrap do salario relativo na amostra estrita = `pS'; manter H2 = `keep'; RW registrado = `rw_registered'; RW estrito = `rw_strict'"
local verb = cond(`keep', "remains", "does not remain")
import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
foreach k in h2s_pairs_all h2s_pairs_out h2s_pairs_not_m1 h2s_N {
    quietly levelsof value if key == "`k'", local(`k') clean
    local `k' : word `: word count ``k''' of ``k''
}
use "$RINT/h2s_res.dta", clear
rv_new, ncol(7) head1("Registered" "(a) Logs" "(b) Employment" "(b) Relative wage" "(c) Over trend GDP" "(d) IV" "(e) Premium") ///
    head2("(harmonized sample)" "strict" "+ log wage bill" "+ log wage bill" "strict" "strict" "strict")
local cols "reg a bE bW c d e"
foreach k in "lpe log public employment" "lrw log relative public wage" "lrwh log relative wage over trend GDP per worker" "prem01 Adjusted premium (per 0.1 log point)" {
    gettoken v lab : k
    local cb ""
    local cs ""
    local cp ""
    foreach s of local cols {
        quietly count if spec == "`s'" & v == "`v'"
        if r(N) == 0 {
            local cb `"`cb' """'
            local cs `"`cs' """'
            local cp `"`cp' """'
            continue
        }
        quietly summ b if spec == "`s'" & v == "`v'"
        local b = r(mean)
        quietly summ pboot if spec == "`s'" & v == "`v'"
        local pb = r(mean)
        if missing(`pb') {
            quietly summ p if spec == "`s'" & v == "`v'"
            local pb = r(mean)
        }
        rv_fmt `b' %12.3f `pb'
        local cb `"`cb' "`r(s)'""'
        quietly summ blo if spec == "`s'" & v == "`v'"
        local l = r(mean)
        quietly summ bhi if spec == "`s'" & v == "`v'"
        local h = r(mean)
        if missing(`l') {
            quietly summ lo if spec == "`s'" & v == "`v'"
            local l = r(mean)
            quietly summ hi if spec == "`s'" & v == "`v'"
            local h = r(mean)
        }
        rv_fmt `l' %12.3f
        local ls "`r(s)'"
        rv_fmt `h' %12.3f
        local cs `"`cs' "[`ls'; `r(s)']""'
        rv_fmt `pb' %12.3f
        local cp `"`cp' "`r(s)'""'
    }
    rv_row "`=strtrim("`lab'")'" `cb'
    rv_row "" `cs'
    rv_row "   p-value" `cp'
}
rv_mid
local cn ""
local cc ""
foreach s of local cols {
    quietly summ N if spec == "`s'"
    rv_fmt `=r(mean)' %12.0fc
    local cn `"`cn' "`r(s)'""'
    quietly summ nc if spec == "`s'"
    local cc `"`cc' "`=r(mean)'""'
}
rv_row "Observations" `cn'
rv_row "Countries" `cc'
quietly summ Feff if spec == "d"
local fe = string(r(mean), "%5.2f")
quietly levelsof ar if spec == "d" & ar != "", local(arc) clean
rv_row "First stage: effective F; Anderson–Rubin 95% CI for log employment" "" "" "" "" "" "F = `fe'; `arc'" ""
* efeito de 1 DP dentro do pais
local c1 ""
foreach s in reg a {
    quietly summ b if spec == "`s'" & v == "lrw"
    local b = r(mean)
    quietly summ sdw if spec == "`s'" & v == "lrw"
    local e = `b' * r(mean)
    quietly summ sdg if spec == "`s'" & v == "lrw"
    local sg = r(mean)
    rv_fmt `e' %12.2f
    local c1 `"`c1' "`r(s)' (SD of growth `=string(`sg', "%4.2f")')""'
}
rv_row "Relative wage: effect of 1 within-country SD, p.p. of growth" `c1' "" "" "" "" ""
rv_row "Romano–Wolf p of H2: registered family; family with the strict sample" "`=string(`rw_registered', "%5.3f")'" "`=string(`rw_strict', "%5.3f")'" "" "" "" "" ""
rv_out TabS22_h2_strict, landscape ///
    title("Table S22. Relative pay `verb' associated with growth when measured strictly before the period") ///
    notes("Five-year averages 1979–2023, no microstates; growth of real GDP per capita on the WWBI components of the wage bill, with the controls in t_p − 1 of T3, country and period fixed effects and standard errors clustered by country. Registered: harmonized sample of Table 3 (wage bill and public employment from the same year, the one closest to t_p − 1, searching t_p − 1 to t_p − 4 and then t_p to t_p + 3). Strict sample: only pairs measured in t_p − 1 to t_p − 4 (`h2s_N' country-periods before singletons are dropped; `h2s_pairs_out' of the `h2s_pairs_all' pairs fall outside this window, and `h2s_pairs_not_m1' are not in t_p − 1). (b) Each component with the log total wage bill as a control (the registered column 1 of Table S6 gives the −1.68 coefficient of the relative wage in this form, in the harmonized sample; it is shown in the replication files). (c) Relative wage over trend GDP per worker (Hamilton). (d) Log WWBI public employment instrumented with log ILOSTAT public-sector employment; effective F of Montiel Olea and Pflueger (equal to the cluster-robust first-stage F with one instrument) and Anderson–Rubin confidence set. (e) WWBI adjusted public-private premium, the premium's own year restricted to t_p − 1 to t_p − 4. Coefficients with stars, p-values and 95% CIs from the wild cluster bootstrap by country (Webb weights, 9,999 replications), except the IV column (normal distribution, cluster-robust). Romano–Wolf: step-down adjusted p of H2 within the seven hypothesis tests of Table S13, with the same 999 country draws; the strict-sample family replaces only the H2 test and does not change the registered verdict. Within-country SD: standard deviation of the regressor after removing country means, in the estimation sample. Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")
log close
