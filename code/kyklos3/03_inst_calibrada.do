* 03_inst_calibrada.do -- Bloco 2 (item 5) e Bloco 6 (item 1): interacao institucional sob a nula, desenho calibrado
* Plano: docs/plan_addendum_kyklos_3.md. Base: data/interim/kyklos2/siminst_base.dta (somente leitura).
* Consumo sintetico ancorado com residuos multiplicados por k (calibrado pelo DP dentro do pais da razao observada,
* separadamente para a serie do WDI de Mollick e Vianna, painel D, e a do projeto, painel C); eps0 = 0,556 e 0,701,
* eps1 = -0,180 (gradiente) ou 0 (controle). Tambem o desenho ancorado (k = 1) com eps0 = 0,701.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/03_inst_calibrada.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
local RK = cond("$SIMK" == "", 200, real("$SIMK"))
do "$ROOT/code/kyklos2/sim2_mata.do"
kget "$KIN2/kv.csv" b4_minst
local minst = real("`r(v)'")
kget "$KIN2/kv.csv" b4_eps1
local e1 = real("`r(v)'")
di "centragem = `minst'; eps1 = `e1'"

use "$KIN2/siminst_base.dta", clear
xtset id year
* DP dentro do pais observado das duas series de consumo, nas amostras das duas especificacoes
foreach s in v p {
    local smp = cond("`s'" == "v", "sD", "sMV")
    gen double cobs_`s' = 100 * exp(lC`s')
    bysort id: egen double _m = mean(cond(`smp', cobs_`s', .))
    gen double _d = cobs_`s' - _m if `smp'
    quietly summ _d
    local tsd_`s' = r(sd)
    drop _m _d
    di "DP dentro observado, serie `s': `tsd_`s''"
}
sort id year
xtset id year
tempfile base
save `base'
capture program drop mk_pool
program define mk_pool
    * gera os pools de residuos recentrados para eps0 e o gradiente dados
    args e0 e1 minst
    capture drop eps
    gen double eps = `e0' + `e1' * (instL - `minst')
    foreach s in v p {
        capture drop e`s'
        gen double e`s' = dlC`s' + (1 - eps) * dlYn if ok`s'
        bysort id: egen double _m = mean(e`s')
        replace e`s' = e`s' - _m
        drop _m
    }
    sort id year
    xtset id year
end

* ---------------------------------------------------------------- calibracao de k (eps0 = 0,556, com gradiente)
use `base', clear
kget "$KIN2/kv.csv" b4_eps0
local e0a = real("`r(v)'")
mk_pool `e0a' `e1' `minst'
tempfile bk
save `bk'
tempname K
postfile `K' double k int rep double(sd_v sd_p) using "$RINT/siminst_k.dta", replace
set seed 20261116
forvalues kk = 30(5)100 {
    local k = `kk' / 100
    forvalues r = 1/`RK' {
        quietly {
            use `bk', clear
            foreach s in v p {
                local smp = cond("`s'" == "v", "sD", "sMV")
                gen double u`s' = .
                mata: _drawc("id", "e`s'", "ok`s'", "u`s'")
                gen double cs`s' = 100 * exp(lC`s'_l1 - (1 - eps) * dlYn + `k' * u`s')
                bysort id: egen double _m = mean(cond(`smp', cs`s', .))
                gen double _d = cs`s' - _m if `smp'
                summ _d
                local sd_`s' = r(sd)
                drop _m _d
                sort id year
            }
            post `K' (`k') (`r') (`sd_v') (`sd_p')
        }
    }
}
postclose `K'
use "$RINT/siminst_k.dta", clear
collapse (mean) sd_v sd_p, by(k)
gen double dv = abs(sd_v - `tsd_v')
gen double dp = abs(sd_p - `tsd_p')
list, noobs
sort dv
local kv = k[1]
sort dp
local kp = k[1]
rv_kv b2i_k_v `kv'
rv_kv b2i_k_p `kp'
rv_kv b2i_tsd_v `=string(`tsd_v', "%9.4f")'
rv_kv b2i_tsd_p `=string(`tsd_p', "%9.4f")'
di "k calibrado: serie WDI-MV (painel D) = `kv'; serie do projeto (painel C) = `kp'"

* ---------------------------------------------------------------- simulacoes
tempname P
postfile `P' str8 des int rep str2 spec str2 meas double b using "$RINT/siminst3_draws.dta", replace
set seed 20261116
foreach dd in "cal 0.556 G" "cal 0.556 C" "cal 0.701 G" "cal 0.701 C" "anc 0.701 G" "anc 0.701 C" {
    tokenize `dd'
    local kind `1'
    local e0 = cond(`2' == 0.556, `e0a', `2')
    local grad = cond("`3'" == "G", `e1', 0)
    local kV = cond("`kind'" == "cal", `kv', 1)
    local kP = cond("`kind'" == "cal", `kp', 1)
    local des = "`1'`=cond(`2' == 0.556, "556", "701")'`3'"
    use `base', clear
    mk_pool `e0' `grad' `minst'
    tempfile bd
    save `bd'
    di as result "desenho `des' (eps0 = `e0', eps1 = `grad', k = `kV' / `kP')"
    forvalues r = 1/`R' {
        quietly {
            use `bd', clear
            foreach s in v p {
                gen double u`s' = .
                mata: _drawc("id", "e`s'", "ok`s'", "u`s'")
                local kk = cond("`s'" == "v", `kV', `kP')
                gen double cs`s' = 100 * exp(lC`s'_l1 - (1 - eps) * dlYn + `kk' * u`s')
            }
            xtset id year
            gen double S_c = csp
            gen double S_l = L.csp
            gen double S_h = csp * exp(lnY - lnY_ham)
            foreach m in c l h {
                gen double X = S_`m' * instc
                mata: _fwlb("C_`m'", "g", "S_`m' X", "instc g_l1 lny_l1 hc inv open infl popg ctot_g", "id", "year", "sMV", "BB")
                post `P' ("`des'") (`r') ("C") ("`m'") (BB[1, 2])
                if `r' == 1 {
                    reghdfe g S_`m' instc X g_l1 lny_l1 hc inv open infl popg ctot_g i.year if sMV, absorb(id)
                    assert reldif(_b[X], BB[1, 2]) < 1e-6
                }
                drop X
            }
            gen double L_c = ln(csv)
            gen double L_l = L.L_c
            gen double L_h = L_c + lnY - lnY_ham
            foreach m in c l h {
                gen double X = L_`m' * I
                mata: _fwlb("D_`m'", "gy", "L_`m' X", "gy_l1 I liy popg", "id", "year", "sD", "BB")
                post `P' ("`des'") (`r') ("D") ("`m'") (BB[1, 2])
                if `r' == 1 {
                    reghdfe gy gy_l1 I L_`m' X liy popg i.year if sD, absorb(id)
                    noisily di "conferencia FWL x reghdfe (`des', D, `m'): " %12.8f _b[X] " " %12.8f BB[1, 2]
                    assert reldif(_b[X], BB[1, 2]) < 1e-6
                }
                drop X
            }
        }
    }
}
postclose `P'

* ---------------------------------------------------------------- resumo: fracoes com percentis
use "$KIN2/siminst_draws.dta", clear
keep if des == "obs"
keep spec meas b
rename b bobs
tempfile ob
save `ob'
use "$KIN2/siminst_draws.dta", clear
drop if des == "obs"
replace des = "anc556" + des
append using "$RINT/siminst3_draws.dta"
merge m:1 spec meas using `ob', nogen
gen double sh = b / bobs
gen double shp = b / (-0.811) if spec == "D"
bysort des spec meas: egen double sh_lo = pctile(sh), p(2.5)
bysort des spec meas: egen double sh_hi = pctile(sh), p(97.5)
bysort des spec meas: egen double shp_lo = pctile(shp), p(2.5)
bysort des spec meas: egen double shp_hi = pctile(shp), p(97.5)
bysort des spec meas: egen double p025 = pctile(b), p(2.5)
bysort des spec meas: egen double p975 = pctile(b), p(97.5)
collapse (mean) mean = b share = sh share_pub = shp (first) sh_lo sh_hi shp_lo shp_hi p025 p975 bobs (count) nrep = b, by(des spec meas)
list if meas == "c", noobs sepby(spec)
save "$RINT/siminst3_sum.dta", replace
kcsv "$RINT/siminst3_sum.dta" Table_A13_panel_F_rows_calibrated
* regra (adendo 3, Bloco 6): fracao na especificacao registrada (C), desenho calibrado, gradiente, eps0 = 0,556
quietly summ share if des == "cal556G" & spec == "C" & meas == "c"
local shC = r(mean)
rv_kv b6_share_registered `=string(`shC', "%9.4f")'
rv_kv b6_rule `=cond(`shC' < 0.33, "cite range", "keep about half")'
di "Bloco 6: fracao na especificacao registrada (calibrado, gradiente, eps0 = 0,556) = `shC'"
log close
