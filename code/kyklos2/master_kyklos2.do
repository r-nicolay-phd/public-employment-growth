* master_kyklos2.do -- estimacoes finais da submissao a Kyklos (versao 4)
* Plano: docs/plan_addendum_kyklos_2.md (commit be45e06). Log: docs/KYKLOS_FINAL_LOG.md.
* Uso (na pasta Estimacoes, numa sessao limpa):  StataMP-64.exe /e do code/kyklos2/master_kyklos2.do
* Entradas: data/interim/revisao (code/revisao/master.do) e data/interim/kyklos (code/kyklos/master_kyklos.do);
* data/raw/fiscal_year/fiscal_year_by_country.csv (Bloco 5).
* Saidas: output/kyklos2/tables (.docx, .tex, .csv), output/kyklos2/figures (.png, .pdf, .eps), output/kyklos2/logs.
version 17
global ROOT "`c(pwd)'"
local root "$ROOT"
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
capture erase "`root'/data/interim/kyklos2/kv.csv"
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
