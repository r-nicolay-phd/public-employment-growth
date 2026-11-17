* 03b_holm.do -- Bloco 3, item 8: ajuste de Holm do -0,334 na familia de coeficientes da folha
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 3, item 6. Familia: Tabela A9 (linhas de subamostra e influencia, sem
* deixar-um-de-fora), Tabela A10 (linhas de especificacao, sem a preferida e sem os resumos; lidas do .tex da tabela) e
* Tabela A15 (painel de tamanho, nivel e log). p de bootstrap quando a tabela o reporta.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/03b_holm.log", replace text

import delimited "$ROOT/output/kyklos/tables/Table_A5_robustness_map.tex", clear delimiter("&") varnames(nonames) stringcols(_all) encoding(utf-8)
keep if !missing(v3)
gen lab = strtrim(v1)
gen bs = subinstr(subinstr(subinstr(subinstr(v2, "$-$", "-", .), "\sym{***}", "", .), "\sym{**}", "", .), "\sym{*}", "", .)
destring bs, gen(b) force
destring v3, gen(p) force
drop if missing(b) | missing(p) | lab == ""
drop if strpos(lab, "Preferred") == 1 | strpos(lab, "Specification curve") | strpos(lab, "Bayesian")
gen str4 tab = "A10"
gen str20 ptype = "reported"
keep tab lab b p ptype
tempfile a10
save `a10'
import delimited "$ROOT/output/kyklos/tables/TabS25_influence.csv", clear varnames(1)
keep if inlist(kind, "base", "trans", "covid", "early", "gfs2000")
gen str4 tab = "A9"
replace lab = kind + ": " + lab
gen str20 ptype = "clustered"
keep tab lab b p ptype
append using `a10'
tempfile a9
save `a9'
import delimited "$ROOT/output/kyklos3/tables/Table_A15_panel_size.csv", clear varnames(1)
gen str4 tab = "A15"
gen lab = "sample " + smp + ", " + x
rename pboot p
gen str20 ptype = "wild bootstrap"
keep tab lab b p ptype
append using `a9'
sort p
local m = _N
gen int rk = _n
gen double p_holm = .
replace p_holm = min(1, (`m' - rk + 1) * p) in 1
forvalues j = 2/`m' {
    replace p_holm = max(p_holm[`j' - 1], min(1, (`m' - rk + 1) * p)) in `j'
}
list tab lab b p p_holm, noobs sep(0)
save "$RINT/holm_wwbi.dta", replace
kcsv "$RINT/holm_wwbi.dta" Table_A9_part_holm_wwbi
rv_kv b3_holm_family `m'
foreach k in "c, wm|334" "c, lwm|logc" "d, lwm|logd" {
    gettoken s nm : k, parse("|")
    local nm = substr("`nm'", 2, .)
    quietly summ p_holm if tab == "A15" & lab == "sample `s'"
    rv_kv b3_holm_p_`nm' `=string(r(mean), "%9.4f")'
}
quietly summ p_holm if tab == "A15" & lab == "sample c, wm"
rv_kv b3_rule_wwbi `=cond(r(mean) < 0.05, "abstract", "section 4.3")'
di "familia: `m' coeficientes; Holm do -0,334 = " r(mean)
log close
