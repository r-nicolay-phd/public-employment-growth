* run_all.do -- refaz todas as etapas em Stata a partir de data/raw/
* Uso (na pasta do projeto):  StataMP-64.exe /e do run_all.do   (ou bash run_all.sh, que inclui a coleta)
global ROOT "`c(pwd)'"
* cronometro por relogio (clear all, chamado por cada etapa, zera os timers do Stata)
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
local etapas 02_limpeza_wf1_fase0 02_limpeza_wdi 02_limpeza_fmi 02_limpeza_trabalho 02_limpeza_instituicoes ///
    03_painel 04_descritivas 05_base 06_decomposicao 07_moderacao 07b_figura4 08_dinamica 09_mecanismos ///
    10_economia_politica 10b_regras_fiscais 11_robustez 12_relatorio
foreach e of local etapas {
    di as result _n "==== `e' ====" _n
    global T1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    do "$ROOT/code/`e'.do"
    di as result "tempo da etapa `e': " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T1) / 1000 " s"
    global ROOT "`c(pwd)'"
}
di as result "TEMPO TOTAL: " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T0) / 1000 " s"
