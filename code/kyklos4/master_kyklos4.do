* master_kyklos4.do -- reestimacoes do parecer da versao 5 da submissao a Kyklos
* Plano: docs/plan_addendum_kyklos_4.md (commit fb6c84b). Log: docs/KYKLOS_V5_LOG.md.
* Uso (na pasta Estimacoes, numa sessao limpa):  StataMP-64.exe /e do code/kyklos4/master_kyklos4.do
* Entradas (somente leitura): data/interim/revisao, kyklos, kyklos2, kyklos3; data/raw/wdi_archives (code/kyklos4/dl_wdi_vintage.py).
* Saidas: output/kyklos4/tables, output/kyklos4/figures, output/kyklos4/logs. Depois:
*     python code/kyklos4/final_v5.py   (exibicoes completas na numeracao da versao 5 em output/kyklos4/final)
version 17
global ROOT "`c(pwd)'"
local root "$ROOT"
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
capture erase "`root'/data/interim/kyklos4/kv.csv"
local etapas 01_grade_k 01b_psi 01c_resumo_k 02_quinquenal 02b_nula 03_escala 04_grade_mc 05_inst 03b_holm 07_tabelas_k4
foreach e of local etapas {
    di as result _n "==== kyklos4/`e' ====" _n
    global T1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    global ROOT "`root'"
    do "`root'/code/kyklos4/`e'.do"
    capture log close _all
    di as result "tempo, `e': " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T1) / 1000 " s"
}
di as result "TEMPO TOTAL: " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T0) / 1000 " s"
