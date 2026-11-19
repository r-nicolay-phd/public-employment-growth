* 02_simulacao_calibrada.do -- Bloco 2: simulacao ancorada calibrada a persistencia observada; grade de eps
* Plano: docs/plan_addendum_kyklos_3.md, Bloco 2. Base: data/analysis/kyklos2/sim2_base.dta (somente leitura).
* Desenho calibrado: ln s_t = ln s_obs,t-1 - (1 - eps) dln Y_t + k u_t (u recentrado no pais, como no desenho ancorado).
* k escolhido (grade 0,30-1,00, 200 replicacoes, eps = 0,48) pelo DP dentro do pais (alvo 0,976) e pelo AR(1) (alvo 0,970).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos3/00_setup_k3.do"
capture log close
log using "$RLOG/02_simulacao_calibrada.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
local RK = cond("$SIMK" == "", 200, real("$SIMK"))
do "$ROOT/code/kyklos2/sim2_mata.do"

* ---------------------------------------------------------------- uma replicacao: coeficientes e diagnosticos
capture program drop sim_regs
program define sim_regs
    args P var eps r
    quietly {
        xtset id year
        gen double s_wb = ws
        gen double s_wb_ham = ws * exp(lnY - lnY_ham)
        gen double s_wb_hp1 = ws * exp(lnY - lnY_hp1)
        gen double s_wb_l1 = L.ws
        foreach m in wb wb_ham wb_hp1 wb_l1 {
            mata: _fwlb("A_`m'", "g", "s_`m'", "$XA", "id", "year", "sA", "BB")
            post `P' ("`var'") (`eps') (`r') ("`m'") (BB[1, 1])
        }
        mata: _fwlb("T3", "P_g", "s_wb_l1", "P_lny0 P_hc P_inv P_open P_infl P_popg P_ctot", "id", "perT", "sT3", "BB")
        post `P' ("`var'") (`eps') (`r') ("T3") (BB[1, 1])
        if `r' == 1 {
            reghdfe g s_wb $XA if sA, absorb(id year)
            mata: _fwlb("A_wb", "g", "s_wb", "$XA", "id", "year", "sA", "BB")
            noisily di "conferencia FWL x reghdfe (`var', eps = `eps'): " %12.8f _b[s_wb] " " %12.8f BB[1, 1]
            assert reldif(_b[s_wb], BB[1, 1]) < 1e-6
        }
        bysort id: egen double _ms = mean(cond(sA, ws, .))
        gen double _ds = ws - _ms if sA
        summ _ds
        post `P' ("`var'") (`eps') (`r') ("sdw") (r(sd))
        sort id year
        xtset id year
        capture regress ws L.ws if sA
        post `P' ("`var'") (`eps') (`r') ("ar1") (cond(_rc, ., _b[L.ws]))
        corr ws wb_placebo if sA
        post `P' ("`var'") (`eps') (`r') ("rpl") (r(rho))
    }
end
capture program drop mk_anc
program define mk_anc
    * base ancorada para um eps: residuos recentrados no pais
    args eps
    use "$KIN2/sim2_base.dta", clear
    gen double e = dlS + (1 - `eps') * dlYn
    bysort id: egen double _me = mean(e)
    replace e = e - _me
    drop _me
    sort id year
end

* ---------------------------------------------------------------- calibracao de k (eps = 0,48)
tempname K
postfile `K' double k int rep double(sdw ar1) using "$RINT/simcal_k.dta", replace
mk_anc 0.48
tempfile b48
save `b48'
set seed 20261116
forvalues kk = 30(5)100 {
    local k = `kk' / 100
    forvalues r = 1/`RK' {
        quietly {
            use `b48', clear
            gen double ud = .
            mata: _drawc("id", "e", "okA", "ud")
            gen double ws = 100 * exp(lS_l1 - 0.52 * dlYn + `k' * ud)
            bysort id: egen double _ms = mean(cond(sA, ws, .))
            gen double _ds = ws - _ms if sA
            summ _ds
            local sd = r(sd)
            sort id year
            xtset id year
            regress ws L.ws if sA
            post `K' (`k') (`r') (`sd') (_b[L.ws])
        }
    }
    di "k = `k' concluido"
}
postclose `K'
use "$RINT/simcal_k.dta", clear
collapse (mean) sdw ar1, by(k)
gen double dsd = abs(sdw - 0.97593)
gen double dar = abs(ar1 - 0.97010)
list, noobs
sort dsd
local ksd = k[1]
sort dar
local kar = k[1]
rv_kv b2_k_sd `ksd'
rv_kv b2_k_ar `kar'
di "k calibrado pelo DP = `ksd'; pelo AR(1) = `kar'"
save "$RINT/simcal_k_sum.dta", replace

* ---------------------------------------------------------------- grade de eps
use "$KIN2/sim2_draws.dta", clear
keep if var == "obs"
tempfile obs
save `obs'
tempname P
postfile `P' str4 var double eps int rep str8 meas double b using "$RINT/simcal_draws.dta", replace
set seed 20261116
foreach eps in 0 0.25 0.48 0.52 0.71 0.75 1 {
    mk_anc `eps'
    tempfile be
    save `be'
    foreach d in csd car anc {
        if "`d'" == "anc" & !inlist(`eps', 0.52, 0.71) continue
        local k = cond("`d'" == "csd", `ksd', cond("`d'" == "car", `kar', 1))
        di as result "desenho `d' (k = `k'), eps = `eps'"
        forvalues r = 1/`R' {
            quietly {
                use `be', clear
                gen double ud = .
                mata: _drawc("id", "e", "okA", "ud")
                gen double ws = 100 * exp(lS_l1 - (1 - `eps') * dlYn + `k' * ud)
            }
            sim_regs `P' `d' `eps' `r'
        }
    }
    * desenho registrado (passeio aleatorio) nos dois valores novos
    if inlist(`eps', 0.52, 0.71) {
        use "$KIN2/sim2_base.dta", clear
        gen double u = dlW - `eps' * dlYn
        tempfile br
        save `br'
        di as result "desenho registrado, eps = `eps'"
        forvalues r = 1/`R' {
            quietly {
                use `br', clear
                gen double lWs = .
                mata: _wsim("id", "u", "dlYn", "w0", "lWs", `eps')
                gen double ws = 100 * exp(lWs) / gdp_nom_lcu
            }
            sim_regs `P' reg `eps' `r'
        }
    }
}
postclose `P'
log close
