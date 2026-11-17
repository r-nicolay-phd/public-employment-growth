* 06_simulacao.do -- Bloco 6: folha sintetica sem efeito sobre o crescimento (hipotese nula calibrada) e placebo
* ln W_sim_t = ln W_sim_{t-1} + eps dln Ynom_t + u_t, u sorteado (com reposicao) dos valores do proprio pais de
* dln W - eps dln Ynom; nivel inicial = folha observada no primeiro ano do pais; eps = 0,48 (Tabela S3), 0,30 e 0,70;
* 1.000 replicacoes. PIB, crescimento e controles observados ficam como estao.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/06_simulacao.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))

do "$ROOT/code/kyklos/wsim_mata.do"

* ---------------------------------------------------------------- dados anuais (mesma construcao da Tabela 1)
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1970, 2023)
xtset id year
gen g_l1 = L.g
gen lny_l1 = L.lny
gen wb_l1 = L.wb
gen wbham_l1 = L.wb_ham
gen byte sA = !missing(g, wb, wb_hp2, wb_hp1, wb_ham, wb_l1, wbham_l1, wb_placebo, lwb_trend, lgap_ham) & ///
    !missing(g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g) & inrange(year, 1996, 2023)
count if sA
gen double lWn = ln(wagebill_gdp / 100 * gdp_nom_lcu)
gen double dlW = lWn - L.lWn
gen double dlYn = ln(gdp_nom_lcu) - ln(L.gdp_nom_lcu)
* primeiro ano com folha observada (desde 1970)
bysort id (year): gen double w0 = lWn if !missing(lWn) & sum(!missing(lWn)) == 1
sort id year
xtset id year
* periodos de cinco anos como em p5_rv (t_p = 1979 + 5 p)
gen int period = floor((year - 1979) / 5)
gen int year0 = 1979 + 5 * period
gen byte first = year == year0
save "$RINT/sim_base.dta", replace

* amostras e coeficientes observados (cinco anos: proprias amostras de cada especificacao)
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
keep id period g wb_mean wb_tp wb_m1 lny0 hc_tp inv open infl popg ctot_g hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1
foreach m in wb_mean wb_tp wb_m1 {
    foreach c in mean m1 {
        local X = cond("`c'" == "mean", "$XD", "$XP")
        quietly reghdfe g `m' `X' i.period, absorb(id) vce(cluster id)
        gen byte s_`m'_`c' = e(sample)
        local o5_`m'_`c' = _b[`m']
    }
}
drop wb_mean wb_tp wb_m1
save "$RINT/sim_p5.dta", replace
use "$RINT/sim_base.dta", clear
foreach m in wb wb_hp2 wb_hp1 wb_ham wb_l1 wbham_l1 {
    quietly reghdfe g `m' $XA if sA, absorb(id year)
    local oA_`m' = _b[`m']
}

* ---------------------------------------------------------------- simulacao
tempname P
postfile `P' double eps int rep str14 meas double b using "$RINT/sim_draws.dta", replace
foreach m in wb wb_hp2 wb_hp1 wb_ham wb_l1 wbham_l1 {
    post `P' (.) (0) ("A_`m'") (`oA_`m'')
}
foreach m in wb_mean wb_tp wb_m1 {
    foreach c in mean m1 {
        post `P' (.) (0) ("F_`m'_`c'") (`o5_`m'_`c'')
    }
}
set seed 20261113
foreach eps in 0.48 0.30 0.70 {
    di as result "eps = `eps'"
    forvalues r = 1/`R' {
        quietly {
            use "$RINT/sim_base.dta", clear
            gen double u = dlW - `eps' * dlYn
            gen double lWs = .
            mata: _wsim("id", "u", "dlYn", "w0", "lWs", `eps')
            gen double ws = 100 * exp(lWs) / gdp_nom_lcu
            gen double s_wb = ws
            gen double s_wb_hp2 = ws * exp(lnY - lnY_hp)
            gen double s_wb_hp1 = ws * exp(lnY - lnY_hp1)
            gen double s_wb_ham = ws * exp(lnY - lnY_ham)
            gen double s_wb_l1 = L.ws
            gen double s_wbham_l1 = L.s_wb_ham
            foreach m in wb wb_hp2 wb_hp1 wb_ham wb_l1 wbham_l1 {
                capture reghdfe g s_`m' $XA if sA, absorb(id year)
                if !_rc post `P' (`eps') (`r') ("A_`m'") (_b[s_`m'])
            }
            * cinco anos: media do periodo, t_p e t_p - 1 a partir da folha sintetica
            gen double s_tp = ws if first
            gen double s_m1 = L.ws if first
            keep if year >= 1979
            collapse (mean) s_mean = ws (firstnm) s_tp s_m1, by(id period)
            merge 1:1 id period using "$RINT/sim_p5.dta", keep(match) nogen
            foreach m in mean tp m1 {
                foreach c in mean m1 {
                    local X = cond("`c'" == "mean", "$XD", "$XP")
                    capture reghdfe g s_`m' `X' i.period if s_wb_`m'_`c', absorb(id)
                    if !_rc post `P' (`eps') (`r') ("F_wb_`m'_`c'") (_b[s_`m'])
                }
            }
        }
        if mod(`r', 100) == 0 di "  replicacao `r'"
    }
}
postclose `P'

* ---------------------------------------------------------------- resumo e regra (adendo, Bloco 6)
use "$RINT/sim_draws.dta", clear
preserve
keep if rep == 0
keep meas b
rename b bobs
tempfile obs
save `obs'
restore
drop if rep == 0
gen double b2 = b
collapse (mean) mean = b (p50) med = b (count) nrep = b, by(eps meas)
tempfile mm
save `mm'
use "$RINT/sim_draws.dta", clear
drop if rep == 0
bysort eps meas: egen double p025 = pctile(b), p(2.5)
bysort eps meas: egen double p975 = pctile(b), p(97.5)
bysort eps meas: keep if _n == 1
keep eps meas p025 p975
merge 1:1 eps meas using `mm', nogen
merge m:1 meas using `obs', nogen
gen double share = mean / bobs
gen byte inside = bobs >= p025 & bobs <= p975
sort meas eps
list, noobs sepby(meas)
save "$RINT/sim_sum.dta", replace
kcsv "$RINT/sim_sum.dta" TabS24_simulation
log close
