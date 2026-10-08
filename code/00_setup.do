* 00_setup.do -- caminhos, semente, estilo grafico e verificacao de pacotes
version 17
clear all
set more off
set seed 20261007
set sortseed 20261007
set maxvar 60000
* raiz do projeto: definida pelo master (run_all.do) ou pelo diretorio corrente
if "$ROOT" == "" global ROOT "`c(pwd)'"
global RAW     "$ROOT/data/raw"
global MANUAL  "$ROOT/data/raw/manual"
global INTERIM "$ROOT/data/interim"
global FINAL   "$ROOT/data/final"
global TAB     "$ROOT/output/tables"
global FIG     "$ROOT/output/figures"
global LOG     "$ROOT/output/logs"
* pacotes de usuario com versoes travadas: copia em code/ado/plus (ver docs/README.md)
sysdir set PLUS "$ROOT/code/ado/plus"
adopath ++ "$ROOT/code/ado/plus"
* pacotes de usuario exigidos (versoes registradas em docs/README.md)
foreach c in reghdfe ftools ivreghdfe ivreg2 ranktest xtabond2 xtdpdgmm xtdpdbc ///
    xtscc locproj xthenreg xthreg interflex weakiv avar boottest xtdcce2 bma estout coefplot {
    capture which `c'
    if _rc {
        di as error "pacote ausente: `c' (ver docs/README.md)"
        exit 199
    }
}

* utilitarios de tabelas e figuras, rotulos e estilo grafico
do "$ROOT/code/00_tabelas.do"
do "$ROOT/code/00_rotulos.do"
set scheme s2mono
graph set window fontface "Arial"
graph set ps fontface "Arial"
graph set eps fontface "Arial"
* paleta Okabe-Ito (segura para daltonismo): preto, azul, laranja, verde-azulado, vermelhao
global C1 "0 0 0"
global C2 "0 114 178"
global C3 "230 159 0"
global C4 "0 158 115"
global C5 "213 94 0"
global GOPT "graphregion(color(white) margin(small)) plotregion(color(white) lcolor(none)) ylabel(, nogrid labsize(8pt) angle(horizontal)) xlabel(, labsize(8pt)) legend(size(8pt) region(lcolor(none)))"

* fixnames: depois de import delimited, recupera nomes de coluna com ponto (guardados no rotulo)
capture program drop fixnames
program define fixnames
    syntax [, lower]
    foreach v of varlist _all {
        local l : variable label `v'
        if strpos("`l'", ".") {
            local n = subinstr("`l'", ".", "_", .)
            if "`lower'" != "" local n = lower("`n'")
            rename `v' `n'
        }
    }
end
