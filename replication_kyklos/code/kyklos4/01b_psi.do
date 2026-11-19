* 01b_psi.do -- Bloco 1 (item 3): residuo do numerador correlacionado com o ciclo real
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 1, item 3. ln s_t = ln s_obs,t-1 - (1 - eps) dln Y_t + k u_t + psi g_t / 100,
* u sorteado de e_psi = dln s_obs + (1 - eps) dln Y - psi g / 100 (recentrado no pais). Grade k x psi (200 replicacoes)
* para eps = 0,48 e 0,71; escolha pela distancia de momentos (01c); 1.000 replicacoes no ponto escolhido (em 01c).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/01b_psi.log", replace text
local RG = cond("$SIMG" == "", 200, real("$SIMG"))
do "$ROOT/code/kyklos2/sim2_mata.do"
local KGRID "0 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.75 1"
local PGRID "-0.5 -0.4 -0.3 -0.2 -0.1 0 0.1 0.2 0.3 0.4 0.5"

capture program drop psi_regs
program define psi_regs
    args P eps k psi r
    quietly {
        xtset id year
        gen double s_wb = ws
        gen double s_wb_ham = ws * exp(lnY - lnY_ham)
        gen double s_wb_l1 = L.ws
        foreach m in wb wb_ham wb_l1 {
            mata: _fwlb("A_`m'", "g", "s_`m'", "$XA", "id", "year", "sA", "BB")
            post `P' (`eps') (`k') (`psi') (`r') ("`m'") (BB[1, 1])
        }
        if `r' == 1 {
            reghdfe g s_wb $XA if sA, absorb(id year)
            mata: _fwlb("A_wb", "g", "s_wb", "$XA", "id", "year", "sA", "BB")
            assert reldif(_b[s_wb], BB[1, 1]) < 1e-6
        }
        bysort id: egen double _ms = mean(cond(sA, ws, .))
        gen double _ds = ws - _ms if sA
        summ _ds
        post `P' (`eps') (`k') (`psi') (`r') ("sdw") (r(sd))
        sort id year
        xtset id year
        capture regress ws L.ws if sA
        post `P' (`eps') (`k') (`psi') (`r') ("ar1") (cond(_rc, ., _b[L.ws]))
    }
end
tempname P
postfile `P' double(eps k psi) int rep str8 meas double b using "$RINT/psi_draws.dta", replace
set seed 20261117
foreach eps in 0.48 0.71 {
    foreach psi of local PGRID {
        use "$KIN2/sim2_base.dta", clear
        gen double e = dlS + (1 - `eps') * dlYn - `psi' * g / 100
        bysort id: egen double _me = mean(e)
        replace e = e - _me
        drop _me
        gen byte okP = okA & !missing(g)
        sort id year
        tempfile bp
        save `bp'
        di as result "eps = `eps', psi = `psi'"
        foreach k of local KGRID {
            forvalues r = 1/`RG' {
                quietly {
                    use `bp', clear
                    gen double ud = .
                    mata: _drawc("id", "e", "okP", "ud")
                    gen double ws = 100 * exp(lS_l1 - (1 - `eps') * dlYn + `k' * ud + `psi' * g / 100)
                }
                psi_regs `P' `eps' `k' `psi' `r'
            }
        }
    }
}
postclose `P'
log close
