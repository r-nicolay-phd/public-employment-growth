* L2_longo_prazo.do -- Extensao L2 (item 3 do Consensus, ajuste metodologico, out. 2026)
* Efeito de longo prazo da folha com heterogeneidade de curto prazo (PMG, MG, DFE; xtpmg) e com dependencia
* entre paises (CS-ARDL e CS-DL; Chudik et al., 2016; xtdcce2). Recupera o bloco G2 descartado em 15/10 e
* acrescenta: (i) a folha defasada sobre o PIB tendencial de Hamilton, que tira o pico do denominador no ano
* da recessao; (ii) um CS-ARDL(2,2), que deixa a recuperacao do ano seguinte na dinamica de curto prazo.
* Modelo: ARDL do crescimento anual com a folha defasada um ano (predeterminada).
* Saidas isoladas em output/extensoes/; xtpmg instalado em code/extensoes/ado (fora do code/ado do pipeline).
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
global TAB "$ROOT/output/extensoes/tables"
global LOG "$ROOT/output/extensoes/logs"
capture mkdir "$TAB"
capture mkdir "$LOG"
capture mkdir "$LOG/captions"
capture mkdir "$ROOT/code/extensoes/ado"
adopath + "$ROOT/code/extensoes/ado"
capture which xtpmg
if _rc {
    net set ado "$ROOT/code/extensoes/ado"
    ssc install xtpmg, replace
    net set ado PLUS
}
log using "$LOG/L2_longo_prazo.log", replace text

use "$FINAL/painel_anual.dta", clear
xtset id year
* tendencia de Hamilton (h = 2, p = 2), como em L1
sort id year
gen lnY_ham = .
levelsof id, local(ids)
foreach i of local ids {
    capture quietly regress lnY L2.lnY L3.lnY if id == `i'
    if !_rc & e(N) >= 10 {
        quietly predict double _h if id == `i' & e(sample), xb
        quietly replace lnY_ham = _h if id == `i'
        drop _h
    }
}
gen wb_ham = wagebill_gdp * exp(lnY - lnY_ham)
keep if micro == 0 & inrange(year, 1995, 2023)
xtset id year
gen wbL = L.wagebill_gdp
gen wbH = L.wb_ham
* mesma amostra para as duas medidas: paises com pelo menos 20 anos completos
gen byte okc = !missing(g, L.g, L2.g, wbL, L.wbL, L2.wbL, wbH, L.wbH, L2.wbH, inv, open, infl, popg) & year >= 1996
bysort id: egen nyc = total(okc)
keep if nyc >= 20
xtset id year

tempname P
postfile `P' str4 w str12 m double(b se ec ec_se N ng hp cd) using "$ROOT/output/extensoes/l2_resultados.dta", replace
foreach W in wbL wbH {
    capture drop X
    gen X = `W'
    * PMG, MG e DFE: longo prazo comum (PMG) ou heterogeneo (MG); ajuste e curto prazo por pais
    foreach est in pmg mg dfe {
        xtpmg d.g d.X d.inv d.open d.infl d.popg if okc, lr(l.g X inv open infl popg) ec(ec) replace `est'
        estimates store LR_`est'
        quietly count if e(sample)
        local N = r(N)
        quietly levelsof id if e(sample)
        local ng = r(r)
        post `P' ("`W'") ("`est'") (_b[ec:X]) (_se[ec:X]) (_b[SR:ec]) (_se[SR:ec]) (`N') (`ng') (.) (.)
    }
    hausman LR_mg LR_pmg, sigmamore
    local hp_`W' = r(p)
    * CS-ARDL(1,1) com todos os controles e medias transversais contemporaneas
    xtdcce2 g if okc, lr(L.g X L.X inv open infl popg) lr_options(ardl) cr(g X inv open infl popg) cr_lags(0)
    local cd = e(cd)
    post `P' ("`W'") ("csardl") (_b[lr_X]) (_se[lr_X]) (_b[lr_g]) (_se[lr_g]) (e(N)) (e(N_g)) (.) (`cd')
    * CS-ARDL(1,1) parcimonioso: so investimento, uma defasagem das medias
    xtdcce2 g if okc, lr(L.g X L.X inv) lr_options(ardl) cr(g X inv) cr_lags(1)
    local cd = e(cd)
    post `P' ("`W'") ("csardl_p") (_b[lr_X]) (_se[lr_X]) (_b[lr_g]) (_se[lr_g]) (e(N)) (e(N_g)) (.) (`cd')
    * CS-ARDL(2,2): a recuperacao pos-recessao fica na dinamica de curto prazo
    xtdcce2 g if okc, lr(L(1/2).g X L(1/2).X inv) lr_options(ardl) cr(g X inv) cr_lags(1)
    local cd = e(cd)
    post `P' ("`W'") ("csardl22") (_b[lr_X]) (_se[lr_X]) (_b[lr_g]) (_se[lr_g]) (e(N)) (e(N_g)) (.) (`cd')
    * CS-DL: longo prazo direto, com a primeira diferenca da folha e duas defasagens das medias
    xtdcce2 g X d.X inv if okc, cr(g X inv) cr_lags(2)
    local cd = e(cd)
    post `P' ("`W'") ("csdl") (_b[X]) (_se[X]) (.) (.) (e(N)) (e(N_g)) (.) (`cd')
}
postclose `P'
* xtdcce2 limpa a memoria do Mata: recarrega as funcoes de tabela
mata: mata clear
do "$ROOT/code/00_tabelas.do"
global TAB "$ROOT/output/extensoes/tables"
global LOG "$ROOT/output/extensoes/logs"

* ---------------------------------------------------------------- Tabela L2
use "$ROOT/output/extensoes/l2_resultados.dta", clear
replace hp = `hp_wbL' if w == "wbL" & m == "pmg"
replace hp = `hp_wbH' if w == "wbH" & m == "pmg"
save "$ROOT/output/extensoes/l2_resultados.dta", replace
list, noobs sepby(w)
local stars "* p<0.10, ** p<0.05, *** p<0.01."
local orderm "pmg mg dfe csardl csardl_p csardl22 csdl"
tab_new, ncol(7) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)" "(7)") ///
    head2("PMG" "MG" "DFE" "CS-ARDL(1,1)" "CS-ARDL(1,1), parsimonious" "CS-ARDL(2,2)" "CS-DL")
foreach W in wbL wbH {
    local ttl = cond("`W'" == "wbL", "Panel A. Wage bill (% of GDP), lagged one year", "Panel B. Wage bill (% of Hamilton trend GDP), lagged one year")
    tab_row "`ttl'" "" "" "" "" "" "" ""
    local rb ""
    local rs ""
    local re ""
    local res ""
    local rn ""
    local rg ""
    foreach m of local orderm {
        quietly summ b if w == "`W'" & m == "`m'"
        local bb = r(mean)
        quietly summ se if w == "`W'" & m == "`m'"
        local ss = r(mean)
        local p = 2 * normal(-abs(`bb' / `ss'))
        local st = cond(`p' < 0.01, "***", cond(`p' < 0.05, "**", cond(`p' < 0.10, "*", "")))
        local x : display %6.3f `bb'
        local rb `"`rb' "`=strtrim("`x'")'`st'""'
        local x : display %6.3f `ss'
        local rs `"`rs' "(`=strtrim("`x'")')""'
        quietly summ ec if w == "`W'" & m == "`m'"
        if r(N) == 0 {
            local re `"`re' """'
            local res `"`res' """'
        }
        else {
            local ee = r(mean)
            quietly summ ec_se if w == "`W'" & m == "`m'"
            local es = r(mean)
            local p = 2 * normal(-abs(`ee' / `es'))
            local st = cond(`p' < 0.01, "***", cond(`p' < 0.05, "**", cond(`p' < 0.10, "*", "")))
            local x : display %6.3f `ee'
            local re `"`re' "`=strtrim("`x'")'`st'""'
            local x : display %6.3f `es'
            local res `"`res' "(`=strtrim("`x'")')""'
        }
        quietly summ N if w == "`W'" & m == "`m'"
        local x : display %9.0fc r(mean)
        local rn `"`rn' "`=strtrim("`x'")'""'
        quietly summ ng if w == "`W'" & m == "`m'"
        local rg `"`rg' "`=r(mean)'""'
    }
    tab_row "Wage bill, long-run coefficient" `rb'
    tab_row "" `rs'
    tab_row "Adjustment / lagged growth coefficient" `re'
    tab_row "" `res'
    tab_row "Observations" `rn'
    tab_row "Countries" `rg'
    quietly summ hp if w == "`W'" & m == "pmg"
    local x : display %5.3f r(mean)
    tab_row "Hausman test, PMG vs MG (p-value)" "`=strtrim("`x'")'" "" "" "" "" "" ""
    if "`W'" == "wbL" tab_mid
}
tab_out TableL2_long_run, title("Table L2. Long-run effect of the wage bill: heterogeneous panels and cross-sectional dependence") landscape ///
    notes("Annual panel 1996-2023, countries with at least 20 complete annual observations (same sample in both panels), microstates excluded. ARDL models of GDP per capita growth with the general government wage bill lagged one year (predetermined), investment, openness, inflation and population growth. Panel B divides the lagged wage bill by Hamilton trend GDP instead of actual GDP, which removes the mechanical rise of the ratio in recession years. The first row is the long-run coefficient of the wage bill on growth (p.p. per p.p. of GDP), comparable to Table 2. Columns 1-3 (xtpmg): pooled mean group (common long-run coefficients, country-specific short run and adjustment), mean group and dynamic fixed effects; the second coefficient row is the error-correction (adjustment) coefficient. Columns 4-7 (xtdcce2): mean-group estimators augmented with cross-sectional averages (Chudik et al., 2016): CS-ARDL(1,1) with all controls and contemporaneous averages; CS-ARDL(1,1) with investment only and one lag of the averages; CS-ARDL(2,2) with investment only and one lag of the averages; CS-DL with two lags of the averages. For CS-ARDL the second coefficient row is the long-run adjustment coefficient reported by xtdcce2. The Hausman test compares MG and PMG (null: common long-run coefficients). `stars'")

log close
