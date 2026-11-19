* 00_setup_k.do -- estimacoes adicionais para a Kyklos: caminhos, semente e rotinas
* Reaproveita as rotinas de code/revisao/00_setup.do (tabelas, figuras, filtros) e redireciona as saidas.
* Entradas: paineis de data/interim/revisao (gerados por code/revisao/master.do).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/00_setup.do"
global KIN   "$ROOT/data/analysis/intermediate"
global RINT  "$ROOT/data/analysis/kyklos"
global RTAB  "$ROOT/output/generated/kyklos/tables"
global RFIG  "$ROOT/output/generated/kyklos/figures"
global RLOG  "$ROOT/output/logs/kyklos"
global RCAP  "$ROOT/output/logs/kyklos/captions"
foreach d in "$RINT" "$ROOT/output/generated/kyklos" "$RTAB" "$RFIG" "$RLOG" "$RCAP" {
    capture mkdir "`d'"
}
set seed 20261113
set sortseed 20261113
global XA  "g_l1 lny_l1 hc inv open infl popg ctot_g"
global XD  "lny0 hc_tp inv open infl popg ctot_g"
global XP  "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"

* kboot coef_ou_expressao -> r(p), r(lo), r(hi): wild cluster bootstrap (Webb, 9.999, semente da Kyklos)
capture program drop kboot
program define kboot, rclass
    syntax anything(name=v equalok everything) [, reps(integer 9999)]
    quietly boottest `v', reps(`reps') weighttype(webb) seed(20261113) nograph
    return scalar p = r(p)
    capture matrix CI = r(CI)
    if !_rc {
        return scalar lo = CI[1, 1]
        return scalar hi = CI[1, 2]
    }
end

* kstars p -> local s com estrelas
capture program drop kstars
program define kstars, rclass
    args p
    local s ""
    if `p' < 0.01 local s "***"
    else if `p' < 0.05 local s "**"
    else if `p' < 0.10 local s "*"
    return local s "`s'"
end

* kcsv arquivo.dta nome -> grava output/kyklos/tables/nome.csv com os numeros da tabela
capture program drop kcsv
program define kcsv
    args f nm
    preserve
    use "`f'", clear
    export delimited using "$RTAB/`nm'.csv", replace
    restore
end
