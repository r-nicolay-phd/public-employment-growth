* master_kyklos2.do -- estimacoes finais da submissao a Kyklos (versao 4)
* Plano: docs/plan_addendum_kyklos_2.md (commit be45e06). Log: docs/KYKLOS_FINAL_LOG.md.
* Usage (from the package root, in a clean session, after code/master.do and code/kyklos/master_kyklos.do):
*     do code/kyklos2/master_kyklos2.do
* Inputs: data/analysis/intermediate (code/master.do) and data/analysis/kyklos (code/kyklos/master_kyklos.do);
* data/raw/fiscal_year/fiscal_year_by_country.csv (Bloco 5).
* Outputs: output/generated/kyklos2/tables and figures (copied to the article numbering by code/kyklos_numbering.py).
version 17
do "`c(pwd)'/code/config.do"
local root "$ROOT"
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
capture erase "`root'/data/analysis/kyklos2/kv.csv"
local etapas 01_simulacao 01b_decomposicao 02_vies 03_instituicoes_testes 04_simulacao_inst 05_ano_fiscal ///
    06_h2_reverso 07_lp_acumulado 08_conferencia 09_tabelas_k2
foreach e of local etapas {
    di as result _n "==== kyklos2/`e' ====" _n
    global T1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    global ROOT "`root'"
    do "`root'/code/kyklos2/`e'.do"
    capture log close _all
    di as result "tempo, `e': " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T1) / 1000 " s"
}
di as result "TEMPO TOTAL: " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T0) / 1000 " s"
