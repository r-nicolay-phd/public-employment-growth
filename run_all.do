* run_all.do -- refaz todas as etapas em Stata a partir de data/raw/
* Uso (na pasta do projeto):  StataMP-64.exe /e do run_all.do   (ou bash run_all.sh, que inclui a coleta)
global ROOT "`c(pwd)'"
local etapas 02_limpeza_wf1_fase0 02_limpeza_wdi 02_limpeza_fmi 02_limpeza_trabalho 02_limpeza_instituicoes ///
    03_painel 04_descritivas
* etapas de estimacao (Fase 2) e saidas (Fase 3) sao acrescentadas abaixo conforme criadas
local etapas `etapas' $ETAPAS_EXTRA
foreach e of local etapas {
    di as result _n "==== `e' ====" _n
    do "$ROOT/code/`e'.do"
}
