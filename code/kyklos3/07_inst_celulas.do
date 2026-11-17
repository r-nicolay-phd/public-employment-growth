* 07_inst_celulas.do -- Bloco 6 (itens 3 e 4): celulas significativas do painel E da Tabela A13 e linhas repetidas
* Plano: docs/plan_addendum_kyklos_3.md, Bloco 6. Le data/interim/kyklos2/opra_triple.dta e refaz as amostras da
* parte inferior da Tabela A13 (code/kyklos/08_instituicoes_k.do) para verificar se as linhas ICRG/QoG 1996-2020 e
* "common sample" coincidem por construcao (mesma amostra) ou por erro de copia.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/07_inst_celulas.log", replace text

* (3) quadro-resumo das 24 celulas da tripla interacao
use "$KIN2/opra_triple.dta", clear
gen double pp = cond(est == "fe", pboot, p)
gen byte sig = pp < 0.05 if !missing(pp)
tempname C
postfile `C' str4 split str4 est long(cells sig) using "$RINT/opra_cells.dta", replace
foreach sp in m r {
    foreach e in fe sgmm {
        quietly count if split == "`sp'" & est == "`e'" & !missing(pp)
        local n = r(N)
        quietly count if split == "`sp'" & est == "`e'" & sig == 1
        post `C' ("`sp'") ("`e'") (`n') (r(N))
    }
}
postclose `C'
use "$RINT/opra_cells.dta", clear
list, noobs
quietly summ sig
rv_kv b6_cells_sig `r(sum)'
quietly summ cells
rv_kv b6_cells_n `r(sum)'
kcsv "$RINT/opra_cells.dta" Table_A13_panel_E_cell_count

* (4) amostras das linhas ICRG/QoG 1996-2020 e "common sample" (mesma construcao de code/kyklos/08_instituicoes_k.do)
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1980, 2020)
xtset id year
gen period = floor((year - 1981) / 5)
gen year0 = 1981 + 5 * period
gen byte first = year == year0
foreach v in govcons_gdp lny {
    gen `v'_tp = `v' if first
    gen `v'_m1 = L.`v' if first
}
drop if year < 1981
collapse (mean) g gc_mean = govcons_gdp icrg = icrg_qog wgi_ge secenr inv dependency ///
    (firstnm) gc_tp = govcons_gdp_tp gc_m1 = govcons_gdp_m1 lny0 = lny_m1, by(id period)
keep if period >= 3
gen byte sI = !missing(g, gc_mean, gc_m1, icrg, lny0, secenr, inv)
gen byte sCm = sI & !missing(wgi_ge)
count if sI
local nI = r(N)
count if sCm
local nC = r(N)
count if sI & missing(wgi_ge)
local nmiss = r(N)
rv_kv b6_icrg_N `nI'
rv_kv b6_common_N `nC'
rv_kv b6_icrg_wgi_missing `nmiss'
di "Linha ICRG/QoG 1996-2020: `nI' observacoes; amostra comum: `nC'; observacoes ICRG sem WGI: `nmiss'"
local same = (`nmiss' == 0)
rv_kv b6_rows_identical_by_construction `same'
* reestimacao FE das duas linhas (media do periodo), para conferir
foreach s in sI sCm {
    gen G = gc_mean
    gen GXI = G * icrg
    quietly reghdfe g G GXI icrg lny0 secenr inv i.period if `s', absorb(id) vce(cluster id)
    di "`s': interacao = " %9.4f _b[GXI] " (EP " %9.4f _se[GXI] "), N = " e(N)
    drop G GXI
}
log close
