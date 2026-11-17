* 02b_nula.do -- Bloco 2 (item 5): T3 menos a nula, nos 355 e nos 311, com tres desenhos
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 2, item 5. Desenhos: reversao a media (rho e eps = 0,48 do segundo adendo),
* ancorado sem escala (k = 1) e ancorado calibrado por momentos (k* do Bloco 1, eps = 0,48). Ponto: observado menos a media
* de 1.000 simulacoes; IC: 999 sorteios de pares de paises, cada um reestimando o observado e refazendo uma simulacao.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/02b_nula.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
local BR = cond("$BOOTR" == "", 999, real("$BOOTR"))
do "$ROOT/code/kyklos2/sim2_mata.do"
kget "$RINT/kv.csv" b1_kstar48
local ks = real("`r(v)'")
if missing(`ks') local ks = 1
kget "$KIN2/kv.csv" sim2_rho
local rho = real("`r(v)'")
local eps = 0.48
di "k* = `ks'; rho = `rho'"

capture program drop vsyn
program define vsyn
    args des idv k rho eps
    if "`des'" == "sta" {
        gen double lss = .
        mata: _stat("`idv'", "lS", "dlYn", "e_sta", "muS", "lss", `rho', `eps')
        gen double ws = 100 * exp(lss)
    }
    else {
        gen double ud = .
        mata: _drawc("`idv'", "e_anc", "okA", "ud")
        gen double ws = 100 * exp(lS_l1 - (1 - `eps') * dlYn + `k' * ud)
    }
    sort `idv' year
    by `idv': gen double s_m1 = ws[_n - 1] if first & year[_n - 1] == year - 1
    keep if first
end
capture program drop t3pair
program define t3pair, rclass
    args idv w
    quietly reghdfe g `w' $XP i.period, absorb(`idv')
    return scalar b355 = _b[`w']
    quietly reghdfe g `w' $XP i.period if in311, absorb(`idv')
    return scalar b311 = _b[`w']
end

use "$RINT/q5_base.dta", clear
keep id period g wb_m1 in311 $XP
tempfile q5
save `q5'
t3pair id wb_m1
local o355 = r(b355)
local o311 = r(b311)

* media da nula na amostra inteira
tempname S
postfile `S' str4 des int rep double(b355 b311) using "$RINT/q5_null.dta", replace
set seed 20261117
foreach des in sta anc cal {
    local k = cond("`des'" == "cal", `ks', 1)
    forvalues r = 1/`R' {
        quietly {
            use "$KIN3/vc_annual.dta", clear
            vsyn `des' id `k' `rho' `eps'
            keep id period s_m1
            merge 1:1 id period using `q5', keep(using match) nogen
            t3pair id s_m1
        }
        post `S' ("`des'") (`r') (r(b355)) (r(b311))
    }
}
postclose `S'

* bootstrap de pares com a nula refeita em cada sorteio
use `q5', clear
keep id
duplicates drop
tempfile ids
save `ids'
tempname B
postfile `B' int r str4 kind double(b355 b311) using "$RINT/q5_boot.dta", replace
set seed 20261117
forvalues r = 1/`BR' {
    quietly {
        use `ids', clear
        bsample
        gen long bid = _n
        tempfile map
        save `map'
        use `q5', clear
        joinby id using `map'
        tempfile b5
        save `b5'
        t3pair bid wb_m1
        post `B' (`r') ("obs") (r(b355)) (r(b311))
        foreach des in sta anc cal {
            local k = cond("`des'" == "cal", `ks', 1)
            use "$KIN3/vc_annual.dta", clear
            joinby id using `map'
            sort bid year
            vsyn `des' bid `k' `rho' `eps'
            keep bid period s_m1
            merge 1:1 bid period using `b5', keep(using match) nogen
            capture t3pair bid s_m1
            if !_rc post `B' (`r') ("`des'") (r(b355)) (r(b311))
        }
    }
    if mod(`r', 100) == 0 di "  bootstrap: `r'"
}
postclose `B'

* resumo
use "$RINT/q5_null.dta", clear
collapse (mean) n355 = b355 n311 = b311, by(des)
tempfile nm
save `nm'
use "$RINT/q5_boot.dta", clear
reshape wide b355 b311, i(r) j(kind) string
tempname Q
postfile `Q' str4 des double(null355 null311 adj355 lo355 hi355 adj311 lo311 hi311) long(ndraws) using "$RINT/q5_adj.dta", replace
foreach des in sta anc cal {
    preserve
    use `nm', clear
    quietly summ n355 if des == "`des'"
    local n355 = r(mean)
    quietly summ n311 if des == "`des'"
    local n311 = r(mean)
    restore
    foreach s in 355 311 {
        capture drop a
        gen double a = b`s'obs - b`s'`des'
        _pctile a, p(2.5 97.5)
        local lo`s' = r(r1)
        local hi`s' = r(r2)
    }
    quietly count if !missing(b355`des')
    post `Q' ("`des'") (`n355') (`n311') (`o355' - `n355') (`lo355') (`hi355') (`o311' - `n311') (`lo311') (`hi311') (r(N))
}
postclose `Q'
use "$RINT/q5_adj.dta", clear
list, noobs
quietly summ null311 if des == "sta"
local s311 = r(mean)
quietly summ null355 if des == "sta"
rv_kv b2_null_sta_355 `=string(r(mean), "%9.4f")'
rv_kv b2_null_sta_311 `=string(`s311', "%9.4f")'
di "nula com reversao a media: 355 = " r(mean) "; 311 = `s311'"
kcsv "$RINT/q5_adj.dta" Table_A8_part_null_adjusted
log close
