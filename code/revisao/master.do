* master.do -- revisao EJPE: refaz todas as analises, tabelas, figuras e documentos a partir de data/final/
* Uso (na pasta Estimacoes):  StataMP-64.exe /e do code/revisao/master.do
* Pre-requisitos: pacotes em ado/plus (code/revisao/00_instala.do, uma vez); fontes novas em data/raw/<fonte>/;
* para a comparacao com o draft 7 (01_auditoria.do, secao F), os .tex do commit 781942e exportados para
* data/interim/revisao/draft7_tex/ (ver docs/README_REPLICACAO.md).
version 17
global ROOT "`c(pwd)'"
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
local etapas 01_auditoria 02_timing 03_vies 04_cobertura 05_decomposicao 06_instituicoes 07_estrutural ///
    08_merito 09_economia_politica 10_exogena 11_longo_prazo 12_inferencia 13_tabelas 14_figuras 15_documentos 16_relatorio
foreach e of local etapas {
    di as result _n "==== `e' ====" _n
    global T1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    do "$ROOT/code/revisao/`e'.do"
    global ROOT "`c(pwd)'"
    di as result "tempo da etapa `e': " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T1) / 1000 " s"
}
di as result "TEMPO TOTAL: " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T0) / 1000 " s"
