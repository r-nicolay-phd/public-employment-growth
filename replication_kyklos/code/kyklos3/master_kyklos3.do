* master_kyklos3.do -- estimacoes do parecer da versao final da submissao a Kyklos
* Plano: docs/plan_addendum_kyklos_3.md (commit c402c35). Log: docs/KYKLOS_FINAL2_LOG.md.
* Uso (na pasta Estimacoes, numa sessao limpa):  StataMP-64.exe /e do code/kyklos3/master_kyklos3.do
* Entradas (somente leitura): data/analysis/intermediate, data/analysis/kyklos, data/analysis/kyklos2; data/raw (inclusive
* data/raw/imf_gfs_xdc e data/raw/imf_weo_ngdp, baixados por code/kyklos3/dl_fontes.py).
* Saidas: output/kyklos3/tables, output/kyklos3/figures, output/kyklos3/logs. Depois:
*     python code/kyklos3/numeracao_final.py   (tabelas e figuras com a numeracao final em output/kyklos3/final)
version 17
do "`c(pwd)'/code/config.do"
local root "$ROOT"
global T0 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
capture erase "`root'/data/analysis/kyklos3/kv.csv"
local etapas 01_tamanho 02_simulacao_calibrada 03_inst_calibrada 04_controles_pred 05_defasagens 06_vies_comum ///
    07_inst_celulas 08_fontes 09_conferencia 10_tabelas_k3
foreach e of local etapas {
    di as result _n "==== kyklos3/`e' ====" _n
    global T1 = clock("`c(current_date)' `c(current_time)'", "DMYhms")
    global ROOT "`root'"
    do "`root'/code/kyklos3/`e'.do"
    capture log close _all
    di as result "tempo, `e': " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T1) / 1000 " s"
}
di as result "TEMPO TOTAL: " %8.0f (clock("`c(current_date)' `c(current_time)'", "DMYhms") - $T0) / 1000 " s"
