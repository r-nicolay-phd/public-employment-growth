* 04_grade_mc.do -- Bloco 4: testes formais da grade quinquenal e de Mollick e Cabral
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 4.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/04_grade_mc.log", replace text

* ---------------------------------------------------------------- grade quinquenal (amostra comum de code/kyklos/03_grade_quinquenal.do)
use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen byte sG = !missing(g, g_x1, wb_mean, wb_tp, wb_m1, wb_ham_m1, lny0, hc_tp, inv, open, infl, popg, ctot_g, ///
    hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
count if sG
keep if sG
tempname D
postfile `D' str4 ctrl str40 dif double(d lo hi p) long(N) using "$RINT/grid_tests.dta", replace
foreach c in mean m1 {
    local X = cond("`c'" == "mean", "$XD", "$XP")
    preserve
    keep id period g wb_mean wb_tp wb_m1 `X'
    gen long obs = _n
    expand 3
    bysort obs: gen byte m = _n
    gen double x = cond(m == 1, wb_mean, cond(m == 2, wb_tp, wb_m1))
    forvalues k = 1/3 {
        gen double x`k' = x * (m == `k')
    }
    egen idm = group(id m)
    quietly reghdfe g x1-x3 c.(`X')#i.m i.period#i.m, absorb(idm) vce(cluster id)
    local N = e(N) / 3
    foreach pr in "1 2 mean − t_p" "2 3 t_p − (t_p − 1)" "1 3 mean − (t_p − 1)" {
        tokenize `pr'
        local lab : list pr - 1
        local lab : list lab - 2
        quietly lincom x`1' - x`2'
        local d = r(estimate)
        kboot {x`1' - x`2' = 0}
        post `D' ("`c'") ("`3' `4' `5'") (`d') (r(lo)) (r(hi)) (r(p)) (`N')
    }
    * tendencia linear no timing: pesos (-1, 0, +1) em (media, t_p, t_p - 1), inclinacao por passo
    quietly lincom (x3 - x1) / 2
    local d = r(estimate)
    kboot {x3 - x1 = 0}
    post `D' ("`c'") ("trend") (`d') (r(lo) / 2) (r(hi) / 2) (r(p)) (`N')
    restore
}
postclose `D'
use "$RINT/grid_tests.dta", clear
list, noobs
quietly summ p if ctrl == "m1" & dif == "trend"
rv_kv b4_trend_p `=string(r(mean), "%9.4f")'
rv_kv b4_rule `=cond(r(mean) < 0.05, "significant", "not significant")'
kcsv "$RINT/grid_tests.dta" Table_A7_rows_grid_tests

* ---------------------------------------------------------------- Mollick e Cabral: painel quinquenal (construcao de code/kyklos/01_mollick_cabral.do)
use "$KIN1/mc_anual.dta", clear
gen int blk = floor((year - 1981) / 5)
gen int y0 = 1981 + 5 * blk
gen byte first = year == y0
xtset id year
gen gtp = govcons_gdp if first
gen gm1 = L.govcons_gdp if first
tempfile A
save `A'
tempname M
postfile `M' str4 per str4 est str6 meas double(b lo hi p) str20 ci long(N nc) using "$RINT/mc5_tests.dta", replace
foreach per in 8604 8623 {
    local y1 = cond("`per'" == "8604", 2004, 2023)
    use `A', clear
    keep if inrange(year, 1981, `y1')
    collapse (mean) n gcf = gcf_gdp_mv gmean = govcons_gdp (lastnm) y (firstnm) gtp gm1, by(id blk)
    xtset id blk
    gen ls = ln(gcf)
    gen lg_m = ln(gmean)
    gen lg_p = ln(gm1)
    gen Ly = L.y
    keep if blk >= 0
    gen byte s5 = blk >= 1 & !missing(y, Ly, n, ls, lg_m, lg_p)
    foreach mm in lg_p lg_m {
        reghdfe y Ly n ls `mm' if s5, absorb(id) vce(cluster id)
        local b = _b[`mm']
        local N = e(N)
        local nc = e(N_clust)
        kboot `mm'
        post `M' ("`per'") ("fe") ("`mm'") (`b') (r(lo)) (r(hi)) (r(p)) ("wild bootstrap") (`N') (`nc')
        capture quietly xtabond2 y L.y n ls `mm' if s5, gmm(L.y, lag(1 3)) gmm(ls `mm', lag(2 .)) iv(n) robust twostep
        if !_rc {
            local b = _b[`mm']
            local se = _se[`mm']
            post `M' ("`per'") ("gmm") ("`mm'") (`b') (`b' - 1.96 * `se') (`b' + 1.96 * `se') (2 * normal(-abs(`b' / `se'))) ("Windmeijer") (e(N)) (e(N_g))
        }
    }
    * diferenca t_p - 1 menos media do periodo, FE empilhado
    preserve
    keep if s5
    keep id blk y Ly n ls lg_m lg_p
    gen long obs = _n
    expand 2
    bysort obs: gen byte m = _n
    gen double x1 = lg_m * (m == 1)
    gen double x2 = lg_p * (m == 2)
    egen idm = group(id m)
    quietly reghdfe y x1 x2 c.(Ly n ls)#i.m, absorb(idm) vce(cluster id)
    quietly lincom x2 - x1
    local d = r(estimate)
    kboot {x2 - x1 = 0}
    post `M' ("`per'") ("fe") ("dif") (`d') (r(lo)) (r(hi)) (r(p)) ("wild bootstrap") (e(N) / 2) (.)
    restore
}
postclose `M'
use "$RINT/mc5_tests.dta", clear
list, noobs
kcsv "$RINT/mc5_tests.dta" Table_A6_rows_five_year_tests
log close
