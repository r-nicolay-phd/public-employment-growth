* 01b_decomposicao.do -- Bloco 1, itens 6 e 7: decomposicao direta do coeficiente do mesmo ano e placebo
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 1. Modelo anual da Tabela 1 (amostra sA, Driscoll-Kraay).
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/01b_decomposicao.log", replace text

use "$RINT/sim2_base.dta", clear
xtset id year
gen double c_ls1 = 100 * lS_l1
gen double c_dlW = 100 * dlW
gen double c_dlY = 100 * dlYn
gen double g_l2 = L2.g
tempname P
postfile `P' str8 item str90 lab double(b se lo hi p) long(N nc) using "$RINT/decomp.dta", replace
capture program drop pd
program define pd
    args P item lab v
    local b = _b[`v']
    local se = _se[`v']
    local df = e(df_r)
    post `P' ("`item'") ("`lab'") (`b') (`se') (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') ///
        (2 * ttail(`df', abs(`b' / `se'))) (e(N)) (e(N_g))
end
* (6a) mesmo modelo com a razao do mesmo ano trocada por ln s_t-1 + dln W_t - dln Y_t (estimados juntos)
xtscc g c_ls1 c_dlW c_dlY $XA i.year if sA, fe lag($DKLAG)
pd `P' dec_ls1 "100 × ln(W/Y) in t − 1" c_ls1
pd `P' dec_dlW "100 × Δln W (nominal wage bill)" c_dlW
pd `P' dec_dlY "100 × Δln Y (nominal GDP)" c_dlY
* referencia: razao do mesmo ano (Tabela 1)
xtscc g wb $XA i.year if sA, fe lag($DKLAG)
pd `P' samey "Same-year ratio (Table 1)" wb
* (6b) covariancia (dentro do pais e do ano) da inovacao do numerador com o crescimento real per capita
gen double innov = c_dlW - 0.48 * c_dlY
reghdfe innov if sA, absorb(id year) residuals(r_in)
reghdfe g if sA, absorb(id year) residuals(r_g)
quietly corr r_in r_g if sA, covariance
local cov = r(cov_12)
quietly corr r_in r_g if sA
local rho = r(rho)
quietly count if sA & !missing(r_in, r_g)
post `P' ("cov") ("Covariance of (Δln W − 0.48 Δln Y) × 100 with growth, net of country and year effects") (`cov') (.) (.) (.) (.) (r(N)) (.)
post `P' ("corr") ("Correlation of (Δln W − 0.48 Δln Y) with growth, net of country and year effects") (`rho') (.) (.) (.) (.) (r(N)) (.)
* (6c) dln W no crescimento real corrente e em duas defasagens (efeitos fixos de pais e ano), sem e com dln Y nominal
xtscc c_dlW g g_l1 g_l2 i.year if sA, fe lag($DKLAG)
pd `P' w_g "Δln W on growth: growth in t" g
pd `P' w_g1 "Δln W on growth: growth in t − 1" g_l1
pd `P' w_g2 "Δln W on growth: growth in t − 2" g_l2
xtscc c_dlW g g_l1 g_l2 c_dlY i.year if sA, fe lag($DKLAG)
pd `P' wy_g "Δln W on growth, controlling for nominal GDP growth: growth in t" g
pd `P' wy_g1 "Δln W on growth, controlling for nominal GDP growth: growth in t − 1" g_l1
pd `P' wy_g2 "Δln W on growth, controlling for nominal GDP growth: growth in t − 2" g_l2
pd `P' wy_y "Δln W on growth, controlling for nominal GDP growth: nominal GDP growth" c_dlY
* (7) correlacao do placebo com a razao observada
quietly corr wb wb_placebo if sA
post `P' ("rpl_obs") ("Correlation of the placebo ratio with the observed ratio") (r(rho)) (.) (.) (.) (.) (r(N)) (.)
postclose `P'
use "$RINT/decomp.dta", clear
list, noobs sep(0)
kcsv "$RINT/decomp.dta" Table_A5_panel_D_decomposition
log close
