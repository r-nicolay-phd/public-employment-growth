* 00_setup_k2.do -- estimacoes finais para a Kyklos (versao 4): caminhos, semente e rotinas
* Plano: docs/plan_addendum_kyklos_2.md (commit be45e06). Reaproveita as rotinas de code/revisao/00_setup.do
* (tabelas, figuras) e redireciona as saidas para output/kyklos2.
* Entradas: data/interim/revisao (code/revisao/master.do) e data/interim/kyklos (code/kyklos/master_kyklos.do).
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/revisao/00_setup.do"
global KIN   "$ROOT/data/interim/revisao"
global KIN1  "$ROOT/data/interim/kyklos"
global RINT  "$ROOT/data/interim/kyklos2"
global RTAB  "$ROOT/output/kyklos2/tables"
global RFIG  "$ROOT/output/kyklos2/figures"
global RLOG  "$ROOT/output/kyklos2/logs"
global RCAP  "$ROOT/output/kyklos2/logs/captions"
foreach d in "$RINT" "$ROOT/output/kyklos2" "$RTAB" "$RFIG" "$RLOG" "$RCAP" {
    capture mkdir "`d'"
}
set seed 20261115
set sortseed 20261115
global XA  "g_l1 lny_l1 hc inv open infl popg ctot_g"
global XD  "lny0 hc_tp inv open infl popg ctot_g"
global XP  "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"
global EXPL "Exploratory (post-plan, pre-registered in the second plan addendum)."

* kboot coef_ou_expressao -> r(p), r(lo), r(hi): wild cluster bootstrap (Webb, 9.999, semente 20261115)
capture program drop kboot
program define kboot, rclass
    syntax anything(name=v equalok everything) [, reps(integer 9999) level(integer 95)]
    quietly boottest `v', reps(`reps') weighttype(webb) seed(20261115) nograph level(`level')
    return scalar p = r(p)
    capture matrix CI = r(CI)
    if !_rc {
        return scalar lo = CI[1, 1]
        return scalar hi = CI[1, 2]
    }
end

* kcsv arquivo.dta nome -> grava output/kyklos2/tables/nome.csv
capture program drop kcsv
program define kcsv
    args f nm
    preserve
    use "`f'", clear
    export delimited using "$RTAB/`nm'.csv", replace
    restore
end

* kget arquivo chave -> r(v) (ultimo valor da chave num kv.csv)
capture program drop kget
program define kget, rclass
    args f key
    preserve
    quietly import delimited "`f'", clear varnames(1) stringcols(_all)
    quietly levelsof value if key == "`key'", local(vv) clean
    restore
    local n : word count `vv'
    if `n' == 0 return local v ""
    else return local v : word `n' of `vv'
end

* kci b lo hi [p] -> r(s) "b [lo; hi]" com sinal de menos tipografico
capture program drop kci
program define kci, rclass
    args b lo hi
    rv_fmt `b' %12.3f
    local s "`r(s)'"
    rv_fmt `lo' %12.3f
    local l "`r(s)'"
    rv_fmt `hi' %12.3f
    return local s "`s' [`l'; `r(s)']"
end
