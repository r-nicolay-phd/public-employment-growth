* master.do -- runs the whole replication package: builds the panels from data/raw and produces every table
* and figure of the article and the appendix.
* Usage: set ROOT in code/config.do (or start Stata in the package root) and run
*     do code/master.do
* Then run  python code/kyklos_numbering.py output/generated output  to copy the tables and figures to the
* Kyklos numbering (output/tables, output/figures).
version 17
do "`c(pwd)'/code/config.do"
local root "$ROOT"
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
capture mkdir "`root'/output"
capture mkdir "`root'/output/logs"
capture mkdir "`root'/data/analysis"
capture mkdir "`root'/data/analysis/interim"

* 1. Construction of the annual, three-year and five-year panels (data/raw -> data/analysis)
foreach e in 02_limpeza_wdi 02_limpeza_fmi 02_limpeza_trabalho 02_limpeza_instituicoes 03_painel {
    di as result _n "==== build/`e' ====" _n
    global T1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    global ROOT "`root'"
    do "`root'/code/build/`e'.do"
    capture log close _all
    di as result "time, build/`e': " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T1) / 1000 " s"
}

* 2. Analysis: tables and figures (output/generated)
foreach e in 01_auditoria 02_timing 03_vies 04_cobertura 05_decomposicao 06_instituicoes 07_estrutural ///
    08_merito 09_economia_politica 10_exogena 11_longo_prazo 12_inferencia 13_tabelas 14_figuras 15_documentos {
    di as result _n "==== `e' ====" _n
    global T1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    global ROOT "`root'"
    do "`root'/code/`e'.do"
    capture log close _all
    di as result "time, `e': " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T1) / 1000 " s"
}
di as result "TOTAL TIME: " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T0) / 1000 " s"
