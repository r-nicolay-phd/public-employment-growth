* master_kyklos.do -- estimacoes adicionais da submissao a Kyklos (plano: docs/plan_addendum_kyklos.md, commit 3faa1ea)
* Usage (from the package root, in a clean session): do code/kyklos/master_kyklos.do
* Inputs: panels and results of code/master.do in data/analysis/intermediate. With global KYK_REBUILD = 1, code/master.do
* is run first.
* Outputs: output/generated/kyklos/tables (Tables S19-S28 and the single-inference Table 2; .tex, .docx, .csv) and
* output/generated/kyklos/figures (Figures S5-S8 and the proposed new Figures 1 and 3). Then run
* python code/kyklos_numbering.py output/generated output
version 17
do "`c(pwd)'/code/config.do"
local root "$ROOT"
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
if "$KYK_REBUILD" == "1" {
    do "`root'/code/master.do"
    global ROOT "`root'"
}
capture erase "`root'/data/analysis/kyklos/kv.csv"
local etapas 01_mollick_cabral 02_outras_razoes 03_grade_quinquenal 04_h2_estrito 05_lp_predeterminado ///
    06_simulacao 06b_simulacao_ar 06c_tabela_simulacao 07_equivalencia 08_instituicoes_k 09_cobertura_k 10_verificacoes
foreach e of local etapas {
    di as result _n "==== kyklos/`e' ====" _n
    global T1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    global ROOT "`root'"
    do "`root'/code/kyklos/`e'.do"
    capture log close _all
    di as result "tempo, `e': " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T1) / 1000 " s"
}
di as result "TEMPO TOTAL: " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T0) / 1000 " s"
