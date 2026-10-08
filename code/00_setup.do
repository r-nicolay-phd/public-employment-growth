* 00_setup.do -- caminhos, semente, estilo grafico e verificacao de pacotes
version 17
clear all
set more off
set seed 20261007
set sortseed 20261007
set maxvar 10000
* raiz do projeto: definida pelo master (run_all.do) ou pelo diretorio corrente
if "$ROOT" == "" global ROOT "`c(pwd)'"
global RAW     "$ROOT/data/raw"
global MANUAL  "$ROOT/data/raw/manual"
global INTERIM "$ROOT/data/interim"
global FINAL   "$ROOT/data/final"
global TAB     "$ROOT/output/tables"
global FIG     "$ROOT/output/figures"
global LOG     "$ROOT/output/logs"
* pacotes de usuario exigidos (versoes registradas em docs/README.md)
foreach c in reghdfe ftools ivreghdfe ivreg2 ranktest xtabond2 xtdpdgmm xtdpdbc ///
    xtscc locproj xthenreg xthreg interflex weakiv boottest xtdcce2 bma estout coefplot {
    capture which `c'
    if _rc {
        di as error "pacote ausente: `c' (ver docs/README.md)"
        exit 199
    }
}
