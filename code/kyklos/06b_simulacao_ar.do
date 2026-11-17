* 06b_simulacao_ar.do -- DIAGNOSTICO POS-HOC (nao pre-registrado; acrescentado depois de ver o resultado do Bloco 6)
* A serie sintetica registrada (passeio aleatorio em ln W desde o primeiro ano do pais) gera uma razao folha/PIB nao
* estacionaria, com DP dentro do pais varias vezes o observado. Este diagnostico mantem a hipotese nula (folha sem
* efeito sobre o crescimento; elasticidade contemporanea eps = 0,48 ao PIB nominal) mas ancora a serie na razao
* observada do ano anterior (um passo a frente), o que elimina a deriva:
*     ln R_sim,t = ln R_obs,t-1 + (eps - 1) dln Ynom_t + e_t,   e sorteado de dln R_obs - (eps - 1) dln Ynom do pais.
* Nao entra na regra de decisao do Bloco 6.
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/06b_simulacao_ar.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
local eps = 0.48

capture mata: mata drop _drawc()
mata:
void _drawc(string scalar idv, string scalar ev, string scalar okv, string scalar outv)
{
    real colvector id, e, ok, out, pool, ee
    real matrix info
    real scalar i, p, q, r, n
    id = st_data(., idv)
    e = st_data(., ev)
    ok = st_data(., okv)
    out = J(rows(id), 1, .)
    info = panelsetup(id, 1)
    for (i = 1; i <= rows(info); i++) {
        p = info[i, 1]
        q = info[i, 2]
        ee = e[|p \ q|]
        pool = select(ee, ee :< .)
        n = rows(pool)
        if (n == 0) continue
        for (r = p; r <= q; r++) {
            if (ok[r] == 1) out[r] = pool[ceil(runiform(1, 1) * n)]
        }
    }
    st_store(., outv, out)
}
end

use "$RINT/sim_base.dta", clear
xtset id year
gen double lR = ln(wagebill_gdp / 100)
gen double lR_l1 = L.lR
gen double e_obs = (lR - lR_l1) - (`eps' - 1) * dlYn
gen byte okd = !missing(lR_l1, dlYn)
save "$RINT/simar_base.dta", replace

tempname P
postfile `P' int rep str14 meas double b using "$RINT/simar_draws.dta", replace
set seed 20261113
forvalues r = 1/`R' {
    quietly {
        use "$RINT/simar_base.dta", clear
        gen double ed = .
        mata: _drawc("id", "e_obs", "okd", "ed")
        gen double ws = 100 * exp(lR_l1 + (`eps' - 1) * dlYn + ed)
        xtset id year
        gen double s_wb = ws
        gen double s_wb_ham = ws * exp(lnY - lnY_ham)
        gen double s_wb_l1 = L.ws
        foreach m in wb wb_ham wb_l1 {
            capture reghdfe g s_`m' $XA if sA, absorb(id year)
            if !_rc post `P' (`r') ("A_`m'") (_b[s_`m'])
        }
        if `r' == 1 {
            bysort id: egen double _m = mean(ws) if sA
            gen double _d = ws - _m
            summ _d if sA
            local sd1 = r(sd)
            xtset id year
            regress ws L.ws if sA
            local ar1 = _b[L.ws]
            noisily di "DP dentro do pais (sintetica, 1a replicacao): `sd1'; AR(1): `ar1'"
        }
        gen double s_m1 = L.ws if first
        keep if year >= 1979
        collapse (firstnm) s_m1, by(id period)
        merge 1:1 id period using "$RINT/sim_p5.dta", keep(match) nogen
        capture reghdfe g s_m1 $XP i.period if s_wb_m1_m1, absorb(id)
        if !_rc post `P' (`r') ("F_wb_m1_m1") (_b[s_m1])
    }
}
postclose `P'
rv_kv simar_sd1 `=string(`sd1', "%6.3f")'
rv_kv simar_ar1 `=string(`ar1', "%6.3f")'
use "$RINT/simar_draws.dta", clear
bysort meas: egen double p025 = pctile(b), p(2.5)
bysort meas: egen double p975 = pctile(b), p(97.5)
collapse (mean) mean = b (first) p025 p975 (count) nrep = b, by(meas)
tempfile sm
save `sm'
use "$RINT/sim_draws.dta", clear
keep if rep == 0
keep meas b
rename b bobs
merge 1:1 meas using `sm', keep(using match) nogen
gen double share = mean / bobs
list, noobs
quietly summ share if meas == "A_wb"
rv_kv simar_share_samey `=string(r(mean), "%6.3f")'
save "$RINT/simar_sum.dta", replace
kcsv "$RINT/simar_sum.dta" TabS24_simulation_anchored_diagnostic
log close
