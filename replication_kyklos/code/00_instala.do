* 00_instala.do -- instala os pacotes comunitarios da revisao em ado/plus (executar uma vez, com internet)
* Os pacotes ficam no projeto; 00_setup.do so verifica que existem. Versoes registradas em docs/PACOTES_STATA.md.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
capture mkdir "$ROOT/ado"
capture mkdir "$ROOT/code/ado/plus"
sysdir set PLUS "$ROOT/code/ado/plus"
net set ado "$ROOT/code/ado/plus"

* pacotes do SSC
local ssc require ftools reghdfe ivreg2 ranktest ivreghdfe xtscc xtabond2 xtdpdgmm boottest rwolf rwolf2 ///
    weakivtest weakiv twostepweakiv avar xthreg xtpmg xtdcce2 xtcd2 xtcsd estout coefplot blindschemes ///
    moremata locproj
foreach p of local ssc {
    capture noisily ssc install `p', replace
    if _rc di as error "falha no SSC: `p' (rc = " _rc ")"
}
* ftools e reghdfe precisam compilar o Mata depois da instalacao
capture noisily ftools, compile
capture noisily reghdfe, compile

* pacotes fora do SSC: tenta a fonte do autor; se falhar, copia a versao ja usada no pipeline do draft 7
capture noisily net install xtdpdbc, from("http://www.kripfganz.de/stata") replace
capture noisily net install xthenreg, from("https://raw.githubusercontent.com/xuyiqing/xthenreg/master") replace
capture noisily net install interflex, from("https://raw.githubusercontent.com/xuyiqing/interflex_stata/master") replace
capture noisily net install st0239_1, from("http://www.stata-journal.com/software/sj11-4") replace
capture noisily net install specurve, from("https://raw.githubusercontent.com/mgao6767/specurve/master") replace

* fallback: copia de code/ado/plus (versoes do pipeline do draft 7) para o que nao instalou
foreach c in xtdpdbc xthenreg interflex bma wals specurve locproj {
    capture which `c'
    if _rc {
        local l = substr("`c'", 1, 1)
        capture mkdir "$ROOT/ado/plus/`l'"
        local fl : dir "$ROOT/code/ado/plus/`l'" files "`c'*"
        foreach f of local fl {
            copy "$ROOT/code/ado/plus/`l'/`f'" "$ROOT/ado/plus/`l'/`f'", replace
        }
        capture which `c'
        if !_rc di as text "`c': copiado de code/ado/plus (fallback)"
        else di as error "`c': indisponivel"
    }
}
