* master_kyklos.do -- estimacoes adicionais da submissao a Kyklos (plano: docs/plan_addendum_kyklos.md, commit 3faa1ea)
* Uso (na pasta Estimacoes, numa sessao limpa):  StataMP-64.exe /e do code/kyklos/master_kyklos.do
* Entradas: paineis e resultados de code/revisao/master.do em data/interim/revisao. Com global KYK_REBUILD = 1, o
* master da revisao e rodado antes (refaz as entradas e regenera as tabelas com as notas corrigidas, Bloco 10).
* Saidas: output/kyklos/tables (S19-S28 e a nova Tabela 2; .tex, .docx e .csv) e output/kyklos/figures (S5-S8 e as
* novas versoes das Figuras 1 e 3). Depois: python replication_kyklos/code/kyklos_numbering.py output/revisao output/kyklos
* copia as tabelas antigas regeneradas com a numeracao da Kyklos.
version 17
global ROOT "`c(pwd)'"
local root "$ROOT"
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
if "$KYK_REBUILD" == "1" {
    do "`root'/code/revisao/master.do"
    global ROOT "`root'"
}
capture erase "`root'/data/interim/kyklos/kv.csv"
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
