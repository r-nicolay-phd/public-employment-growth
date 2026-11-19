* 01c_resumo_k.do -- Bloco 1: distancia de momentos, k escolhido, regras; 1.000 replicacoes no (k, psi) escolhido
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 1, itens 2 e 3.
* D(k, eps) = soma, nos momentos DP dentro, AR(1), coeficiente da defasada e coeficiente sobre o PIB tendencial (Hamilton),
* de |media simulada - observado| / DP simulado.
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/01c_resumo_k.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
do "$ROOT/code/kyklos2/sim2_mata.do"

capture program drop gk_sum
program define gk_sum
    * a partir de draws (des eps k [psi] rep meas b) -> medias, DP, percentis, fracao, distancia
    syntax , by(string) obs(string) out(string)
    bysort `by' meas: egen double p025 = pctile(b), p(2.5)
    bysort `by' meas: egen double p975 = pctile(b), p(97.5)
    collapse (mean) mean = b (sd) sd = b (first) p025 p975 (count) nrep = b, by(`by' meas)
    merge m:1 meas using `obs', keep(master match) nogen
    gen double share = mean / bobs if meas == "wb"
    * com k = 0 a simulacao e deterministica (DP = 0): o desvio padronizado e tratado como muito grande se a media
    * difere do observado (registrado no log)
    gen double z = abs(mean - bobs) / max(sd, 1e-9) if inlist(meas, "sdw", "ar1", "wb_l1", "wb_ham")
    gen byte inside = bobs >= p025 & bobs <= p975
    bysort `by': egen double D = total(z)
    save `out', replace
end

use "$RINT/gk_draws.dta", clear
preserve
keep if des == "obs"
keep meas b
rename b bobs
tempfile obs
save `obs'
restore
drop if des == "obs"
tempfile gs
gk_sum, by(des eps k) obs(`obs') out(`gs')
use `gs', clear
save "$RINT/gk_sum.dta", replace
kcsv "$RINT/gk_sum.dta" Table_A4_part_moment_grid

* k escolhido por eps (desenho ancorado e desenho com elasticidades separadas)
tempname C
postfile `C' str4 des double(eps kstar Dmin share klo khi sharelo sharehi lag_in ham_in lag_mean lag_lo lag_hi ham_mean ham_lo ham_hi) ///
    using "$RINT/gk_choice.dta", replace
foreach dd in "anc 0.25" "anc 0.48" "anc 0.52" "anc 0.71" "sep 0" {
    tokenize `dd'
    use "$RINT/gk_sum.dta", clear
    keep if des == "`1'" & abs(eps - `2') < 1e-6
    preserve
    keep if meas == "wb"
    sort D k
    local ks = k[1]
    local Dm = D[1]
    local sh = share[1]
    quietly summ k if D <= 1.10 * `Dm'
    local klo = r(min)
    local khi = r(max)
    quietly summ share if D <= 1.10 * `Dm'
    local slo = r(min)
    local shi = r(max)
    restore
    foreach m in wb_l1 wb_ham {
        quietly summ inside if meas == "`m'" & abs(k - `ks') < 1e-6
        local in_`m' = r(mean)
        quietly summ mean if meas == "`m'" & abs(k - `ks') < 1e-6
        local mn_`m' = r(mean)
        quietly summ p025 if meas == "`m'" & abs(k - `ks') < 1e-6
        local lo_`m' = r(mean)
        quietly summ p975 if meas == "`m'" & abs(k - `ks') < 1e-6
        local hi_`m' = r(mean)
    }
    post `C' ("`1'") (`2') (`ks') (`Dm') (`sh') (`klo') (`khi') (`slo') (`shi') (`in_wb_l1') (`in_wb_ham') ///
        (`mn_wb_l1') (`lo_wb_l1') (`hi_wb_l1') (`mn_wb_ham') (`lo_wb_ham') (`hi_wb_ham')
}
postclose `C'
use "$RINT/gk_choice.dta", clear
list, noobs
kcsv "$RINT/gk_choice.dta" Table_A4_part_moment_choice
* reproduz algum dos dois momentos em algum k? (eps = 0,48)
use "$RINT/gk_sum.dta", clear
keep if des == "anc" & abs(eps - 0.48) < 1e-6 & inlist(meas, "wb_l1", "wb_ham")
bysort k: egen byte both = min(inside)
quietly summ both
local anyk = r(max)
use "$RINT/gk_choice.dta", clear
keep if des == "anc" & abs(eps - 0.48) < 1e-6
local ks = kstar[1]
local sh = share[1]
local rep2 = (lag_in[1] == 1 & ham_in[1] == 1)
local lag0 = (lag_lo[1] <= 0 & lag_hi[1] >= 0)
rv_kv b1_kstar48 `ks'
rv_kv b1_share48 `=string(`sh', "%9.4f")'
rv_kv b1_reproduce48 `rep2'
rv_kv b1_anyk_both48 `anyk'
rv_kv b1_lagnull_contains0 `lag0'
local r1 = cond(`rep2' & `sh' >= 0.50, "at least half", cond(`rep2' & `sh' >= 0.25, "quarter to half", cond(!`anyk', "full range", "neither")))
rv_kv b1_rule "`r1'"
rv_kv b1_rule_lag `=cond(`lag0', "keep prefer lagged", "report with null")'
di "Bloco 1: k* = `ks'; fracao = `sh'; reproduz defasada e Hamilton em k* = `rep2'; em algum k = `anyk'; regra: `r1'"

* ---------------------------------------------------------------- item 3: grade psi e ponto escolhido
use "$RINT/psi_draws.dta", clear
tempfile ps
gk_sum, by(eps k psi) obs(`obs') out(`ps')
use `ps', clear
save "$RINT/psi_sum.dta", replace
kcsv "$RINT/psi_sum.dta" Table_A4_part_psi_grid
tempname Q
postfile `Q' double(eps kstar psistar Dmin) using "$RINT/psi_choice.dta", replace
foreach e in 0.48 0.71 {
    use "$RINT/psi_sum.dta", clear
    keep if abs(eps - `e') < 1e-6 & meas == "wb"
    sort D k psi
    post `Q' (`e') (k[1]) (psi[1]) (D[1])
}
postclose `Q'
use "$RINT/psi_choice.dta", clear
list, noobs
local kp48 = kstar[1]
local pp48 = psistar[1]
local kp71 = kstar[2]
local pp71 = psistar[2]
* 1.000 replicacoes no ponto escolhido, para cada eps
tempname P
postfile `P' double(eps k psi) int rep str8 meas double b using "$RINT/psi_final.dta", replace
set seed 20261117
foreach e in 0.48 0.71 {
    local en = cond(`e' == 0.48, "48", "71")
    local kk = `kp`en''
    local pp = `pp`en''
    use "$KIN2/sim2_base.dta", clear
    gen double e = dlS + (1 - `e') * dlYn - `pp' * g / 100
    bysort id: egen double _me = mean(e)
    replace e = e - _me
    drop _me
    gen byte okP = okA & !missing(g)
    sort id year
    tempfile bp
    save `bp'
    forvalues r = 1/`R' {
        quietly {
            use `bp', clear
            gen double ud = .
            mata: _drawc("id", "e", "okP", "ud")
            gen double ws = 100 * exp(lS_l1 - (1 - `e') * dlYn + `kk' * ud + `pp' * g / 100)
            xtset id year
            gen double s_wb = ws
            gen double s_wb_ham = ws * exp(lnY - lnY_ham)
            gen double s_wb_l1 = L.ws
            foreach m in wb wb_ham wb_l1 {
                mata: _fwlb("A_`m'", "g", "s_`m'", "$XA", "id", "year", "sA", "BB")
                post `P' (`e') (`kk') (`pp') (`r') ("`m'") (BB[1, 1])
                if `r' == 1 {
                    reghdfe g s_`m' $XA if sA, absorb(id year)
                    assert reldif(_b[s_`m'], BB[1, 1]) < 1e-6
                }
            }
            bysort id: egen double _ms = mean(cond(sA, ws, .))
            gen double _ds = ws - _ms if sA
            summ _ds
            post `P' (`e') (`kk') (`pp') (`r') ("sdw") (r(sd))
            sort id year
            xtset id year
            capture regress ws L.ws if sA
            post `P' (`e') (`kk') (`pp') (`r') ("ar1") (cond(_rc, ., _b[L.ws]))
        }
    }
}
postclose `P'
use "$RINT/psi_final.dta", clear
tempfile pf
gk_sum, by(eps k psi) obs(`obs') out(`pf')
use `pf', clear
save "$RINT/psi_final_sum.dta", replace
list eps k psi meas mean p025 p975 bobs share inside D, noobs sepby(eps)
kcsv "$RINT/psi_final_sum.dta" Table_A4_part_psi_chosen
quietly summ share if abs(eps - 0.48) < 1e-6 & meas == "wb"
local shp = r(mean)
quietly summ inside if abs(eps - 0.48) < 1e-6 & inlist(meas, "wb_l1", "wb_ham")
local repp = (r(min) == 1)
local r2 = cond(`pp48' != 0 & `repp' & `shp' >= 0.80, "co-movement", "not identified")
rv_kv b1_psistar48 `pp48'
rv_kv b1_kpsi48 `kp48'
rv_kv b1_psi_share48 `=string(`shp', "%9.4f")'
rv_kv b1_psi_reproduce48 `repp'
rv_kv b1_rule_psi "`r2'"
di "Bloco 1 (psi): k = `kp48', psi = `pp48', fracao = `shp', reproduz = `repp'; regra: `r2'"
log close
