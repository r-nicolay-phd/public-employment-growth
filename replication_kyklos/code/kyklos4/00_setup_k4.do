* 00_setup_k4.do -- reestimacoes do parecer da versao 5 (Kyklos): caminhos, semente e rotinas
* Plano: docs/plan_addendum_kyklos_4.md (commit fb6c84b). Reaproveita as rotinas de code/00_setup.do
* (tabelas, figuras) e redireciona as saidas para output/kyklos4.
* Entradas: data/analysis/intermediate, data/analysis/kyklos e data/analysis/kyklos2 e kyklos3 (somente leitura).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/00_setup.do"
global KIN   "$ROOT/data/analysis/intermediate"
global KIN1  "$ROOT/data/analysis/kyklos"
global KIN2  "$ROOT/data/analysis/kyklos2"
global KIN3  "$ROOT/data/analysis/kyklos3"
global RINT  "$ROOT/data/analysis/kyklos4"
global RTAB  "$ROOT/output/generated/kyklos4/tables"
global RFIG  "$ROOT/output/generated/kyklos4/figures"
global RLOG  "$ROOT/output/logs/kyklos4"
global RCAP  "$ROOT/output/logs/kyklos4/captions"
foreach d in "$RINT" "$ROOT/output/generated/kyklos4" "$RTAB" "$RFIG" "$RLOG" "$RCAP" {
    capture mkdir "`d'"
}
set seed 20261117
set sortseed 20261117
global XA  "g_l1 lny_l1 hc inv open infl popg ctot_g"
global XD  "lny0 hc_tp inv open infl popg ctot_g"
global XP  "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"
global EXPL "Exploratory (post-plan, pre-registered in the fourth plan addendum)."

* kboot coef_ou_expressao -> r(p), r(lo), r(hi): wild cluster bootstrap (Webb, 9.999, semente 20261117)
capture program drop kboot
program define kboot, rclass
    syntax anything(name=v equalok everything) [, reps(integer 9999) level(integer 95)]
    quietly boottest `v', reps(`reps') weighttype(webb) seed(20261117) nograph level(`level')
    return scalar p = r(p)
    capture matrix CI = r(CI)
    if !_rc {
        return scalar lo = CI[1, 1]
        return scalar hi = CI[1, 2]
    }
end

* kcsv arquivo.dta nome -> grava output/generated/kyklos4/tables/nome.csv
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
