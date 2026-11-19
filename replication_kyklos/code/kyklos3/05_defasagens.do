* 05_defasagens.do -- Bloco 4: defasagens distribuidas e decomposicao sem o resultado no lado direito
* Plano: docs/plan_addendum_kyklos_3.md, Bloco 4. Modelo anual da Tabela 1, Driscoll-Kraay (defasagem maxima 3).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/05_defasagens.log", replace text

use "$KIN2/sim2_base.dta", clear
xtset id year
gen wb_l2 = L2.wb
gen wb_l3 = L3.wb
gen dwb_l1 = L.wb - L2.wb
gen dwb_l2 = L2.wb - L3.wb
gen double c_ls1 = 100 * lS_l1
gen double c_dlW = 100 * dlW
gen double c_dlY = 100 * dlYn
gen double pi = 100 * (ln(gdp_nom_lcu / gdp_real) - ln(L.gdp_nom_lcu / L.gdp_real))
gen double pi_l1 = L.pi
gen double pi_l2 = L2.pi
gen double c_dlW_l1 = L.c_dlW
gen byte sDL = sA & !missing(wb_l2, wb_l3)
count if sDL
tempname P
postfile `P' str8 item str90 lab double(b se lo hi p F) long(N nc) using "$RINT/dl_res.dta", replace
capture program drop pd
program define pd
    args P item lab v
    local b = _b[`v']
    local se = _se[`v']
    local df = e(df_r)
    if missing(`df') local df = 1e6
    post `P' ("`item'") ("`lab'") (`b') (`se') (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') ///
        (2 * ttail(`df', abs(`b' / `se'))) (.) (e(N)) (e(N_g))
end
* (1A) razao em t - 1, t - 2 e t - 3 juntas
xtscc g wb_l1 wb_l2 wb_l3 $XA i.year if sDL, fe lag($DKLAG)
pd `P' A_l1 "A: ratio in t − 1" wb_l1
pd `P' A_l2 "A: ratio in t − 2" wb_l2
pd `P' A_l3 "A: ratio in t − 3" wb_l3
lincom wb_l1 + wb_l2 + wb_l3
local df = e(df_r)
post `P' ("A_sum") ("A: sum of the three lags") (r(estimate)) (r(se)) (r(estimate) - invttail(`df', 0.025) * r(se)) ///
    (r(estimate) + invttail(`df', 0.025) * r(se)) (2 * ttail(`df', abs(r(estimate) / r(se)))) (.) (e(N)) (e(N_g))
local sumlo = r(estimate) - invttail(`df', 0.025) * r(se)
local sumhi = r(estimate) + invttail(`df', 0.025) * r(se)
nlcom (_b[wb_l1] + _b[wb_l2] + _b[wb_l3]) / (1 - _b[g_l1])
matrix bb = r(b)
matrix VV = r(V)
local lr = bb[1, 1]
local lrse = sqrt(VV[1, 1])
post `P' ("A_lr") ("A: implied long-run effect, sum / (1 − coefficient on lagged growth)") (`lr') (`lrse') ///
    (`lr' - invttail(`df', 0.025) * `lrse') (`lr' + invttail(`df', 0.025) * `lrse') (2 * ttail(`df', abs(`lr' / `lrse'))) (.) (e(N)) (e(N_g))
* referencia: so a razao em t - 1 na mesma amostra
xtscc g wb_l1 $XA i.year if sDL, fe lag($DKLAG)
pd `P' A_ref "Ratio in t − 1 alone (same sample)" wb_l1
* (1B) razao em t - 1 com as variacoes em t - 1 e t - 2
xtscc g wb_l1 dwb_l1 dwb_l2 $XA i.year if sDL, fe lag($DKLAG)
pd `P' B_l1 "B: ratio in t − 1" wb_l1
pd `P' B_d1 "B: change of the ratio in t − 1" dwb_l1
pd `P' B_d2 "B: change of the ratio in t − 2" dwb_l2
* (2) painel D sem dln Y
xtscc g c_ls1 c_dlW c_dlY $XA i.year if sA, fe lag($DKLAG)
pd `P' D_ls1 "Panel D as published: 100 × ln s in t − 1" c_ls1
pd `P' D_dlW "Panel D as published: 100 × Δln W" c_dlW
xtscc g c_ls1 c_dlW $XA i.year if sA, fe lag($DKLAG)
pd `P' D2_ls1 "Without Δln Y: 100 × ln s in t − 1" c_ls1
pd `P' D2_dlW "Without Δln Y: 100 × Δln W" c_dlW
* (3i) inflacao do deflator em t - 1 no lugar de dln Y
xtscc g c_ls1 c_dlW pi_l1 $XA i.year if sA, fe lag($DKLAG)
pd `P' D3_ls1 "Deflator inflation in t − 1 instead of Δln Y: 100 × ln s in t − 1" c_ls1
pd `P' D3_dlW "Deflator inflation in t − 1 instead of Δln Y: 100 × Δln W" c_dlW
pd `P' D3_pi "Deflator inflation in t − 1 instead of Δln Y: inflation in t − 1" pi_l1
* (3ii) inflacao em t instrumentada pelas defasagens t - 1 e t - 2
gen byte sIV = sA & !missing(pi, pi_l1, pi_l2, c_ls1, c_dlW)
ivreghdfe g c_ls1 c_dlW $XA (pi = pi_l1 pi_l2) if sIV, absorb(id year) dkraay(4)
local nIV = e(N)
local b = _b[c_dlW]
local se = _se[c_dlW]
local bl = _b[c_ls1]
local sel = _se[c_ls1]
local bp = _b[pi]
local sep = _se[pi]
quietly tab year if sIV, gen(yd_)
quietly tab id if sIV, gen(cd_)
ivreg2 g c_ls1 c_dlW $XA yd_* cd_* (pi = pi_l1 pi_l2) if sIV, cluster(id) partial(yd_* cd_*) small
local Feff = .
capture noisily weakivtest
if !_rc local Feff = r(F_eff)
drop yd_* cd_*
foreach k in "D4_ls1|2SLS, deflator inflation in t instrumented: 100 × ln s in t − 1|bl|sel" "D4_dlW|2SLS, deflator inflation in t instrumented: 100 × Δln W|b|se" "D4_pi|2SLS, deflator inflation in t instrumented: inflation in t|bp|sep" {
    tokenize "`k'", parse("|")
    local bb = ``5''
    local ss = ``7''
    post `P' ("`1'") ("`3'") (`bb') (`ss') (`bb' - 1.96 * `ss') (`bb' + 1.96 * `ss') (2 * normal(-abs(`bb' / `ss'))) (`Feff') (`nIV') (.)
}
* (4) duas leituras do numerador
xtscc c_dlW pi_l1 i.year if sA & !missing(pi_l1), fe lag($DKLAG)
pd `P' ix "Indexation: 100 × Δln W in t on deflator inflation in t − 1" pi_l1
xtscc pi c_dlW_l1 $XA i.year if sA & !missing(c_dlW_l1), fe lag($DKLAG)
pd `P' wp "Wage pressure: deflator inflation in t on 100 × Δln W in t − 1" c_dlW_l1
postclose `P'
use "$RINT/dl_res.dta", clear
list item b lo hi p F N, noobs sep(0)
kcsv "$RINT/dl_res.dta" Table_A4_panel_lags_numerator
* ---------------------------------------------------------------- regras (adendo 3, Bloco 4)
local sumx = (`sumlo' > 0 | `sumhi' < 0)
rv_kv b4_sum_excl0 `sumx'
rv_kv b4_sum_halfwidth `=string((`sumhi' - `sumlo') / 2, "%9.4f")'
quietly summ b if item == "D_dlW"
local s0 = sign(r(mean))
local wd = 0
foreach it in D2_dlW D3_dlW D4_dlW {
    quietly summ b if item == "`it'"
    local sg = sign(r(mean))
    quietly summ p if item == "`it'"
    if `sg' != `s0' | r(mean) >= 0.05 local wd = 1
}
rv_kv b4_withdraw_index `wd'
di "Bloco 4: soma das defasagens exclui zero = `sumx'; retirar a leitura de indexacao = `wd'"
log close
