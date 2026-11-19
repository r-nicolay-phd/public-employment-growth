* 05_inst.do -- Bloco 5: instituicoes, escala publicada e safra dos dados
* Plano: docs/plan_addendum_kyklos_4.md, Bloco 5.
* (1) k do consumo escolhido por momentos (DP, AR(1), interacoes com o consumo defasado e sobre o PIB tendencial, na
*     especificacao publicada); 1.000 replicacoes no k escolhido; quadro completo das fracoes da nula.
* (2) especificacao publicada com as safras 2022 e 2023 do WDI (WDI Database Archives).
* (3) interacao sobre o PIB tendencial na especificacao registrada e sua nula. (4) Holm nas 24 celulas.
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos4/00_setup_k4.do"
capture log close
log using "$RLOG/05_inst.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
local RK = cond("$SIMK" == "", 200, real("$SIMK"))
do "$ROOT/code/kyklos2/sim2_mata.do"
local KGRID "0 0.05 0.10 0.15 0.20 0.25 0.30 0.40 0.50 0.75 1"
kget "$KIN2/kv.csv" b4_minst
local minst = real("`r(v)'")
kget "$KIN2/kv.csv" b4_eps1
local e1 = real("`r(v)'")
kget "$KIN2/kv.csv" b4_eps0
local e0a = real("`r(v)'")

capture program drop mk_pool
program define mk_pool
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
capture program drop inst_rep
program define inst_rep
    * uma replicacao com k: grava interacoes C e D (mesmo ano, defasado, tendencial) e DP/AR(1) da serie v em sD
    args P des k r chk
    quietly {
        foreach s in v p {
            gen double u`s' = .
            mata: _drawc("id", "e`s'", "ok`s'", "u`s'")
            gen double cs`s' = 100 * exp(lC`s'_l1 - (1 - eps) * dlYn + `k' * u`s')
        }
        xtset id year
        gen double S_c = csp
        gen double S_l = L.csp
        gen double S_h = csp * exp(lnY - lnY_ham)
        foreach m in c l h {
            gen double X = S_`m' * instc
            mata: _fwlb("C_`m'", "g", "S_`m' X", "instc g_l1 lny_l1 hc inv open infl popg ctot_g", "id", "year", "sMV", "BB")
            post `P' ("`des'") (`k') (`r') ("C") ("`m'") (BB[1, 2])
            drop X
        }
        gen double L_c = ln(csv)
        gen double L_l = L.L_c
        gen double L_h = L_c + lnY - lnY_ham
        foreach m in c l h {
            gen double X = L_`m' * I
            mata: _fwlb("D_`m'", "gy", "L_`m' X", "gy_l1 I liy popg", "id", "year", "sD", "BB")
            post `P' ("`des'") (`k') (`r') ("D") ("`m'") (BB[1, 2])
            if `chk' {
                reghdfe gy gy_l1 I L_`m' X liy popg i.year if sD, absorb(id)
                assert reldif(_b[X], BB[1, 2]) < 1e-6
            }
            drop X
        }
        bysort id: egen double _m = mean(cond(sD, csv, .))
        gen double _d = csv - _m if sD
        summ _d
        post `P' ("`des'") (`k') (`r') ("D") ("sdw") (r(sd))
        sort id year
        xtset id year
        capture regress csv L.csv if sD
        post `P' ("`des'") (`k') (`r') ("D") ("ar1") (cond(_rc, ., _b[L.csv]))
    }
end

* ---------------------------------------------------------------- observados (momentos do consumo, especificacao publicada)
use "$KIN2/siminst_base.dta", clear
xtset id year
gen double cobs = 100 * exp(lCv)
bysort id: egen double _m = mean(cond(sD, cobs, .))
gen double _d = cobs - _m if sD
quietly summ _d
local o_sdw = r(sd)
drop _m _d
sort id year
xtset id year
quietly regress cobs L.cobs if sD
local o_ar1 = _b[L.cobs]
use "$KIN2/siminst_draws.dta", clear
keep if des == "obs"
foreach s in C D {
    foreach m in c l h {
        quietly summ b if spec == "`s'" & meas == "`m'"
        local o_`s'`m' = r(mean)
    }
}
di "observados: DP = `o_sdw'; AR(1) = `o_ar1'; interacao defasada = `o_Dl'; tendencial = `o_Dh'"

* ---------------------------------------------------------------- (1) grade de k (gradiente, eps0 = 0,556) e escolha por momentos
use "$KIN2/siminst_base.dta", clear
mk_pool `e0a' `e1' `minst'
tempfile bk
save `bk'
tempname K
postfile `K' str8 des double k int rep str2 spec str4 meas double b using "$RINT/inst_kgrid.dta", replace
set seed 20261117
foreach k of local KGRID {
    forvalues r = 1/`RK' {
        quietly use `bk', clear
        inst_rep `K' grid `k' `r' `=(`r' == 1)'
    }
    di "k = `k'"
}
postclose `K'
use "$RINT/inst_kgrid.dta", clear
keep if spec == "D" & inlist(meas, "sdw", "ar1", "l", "h")
gen double obs = cond(meas == "sdw", `o_sdw', cond(meas == "ar1", `o_ar1', cond(meas == "l", `o_Dl', `o_Dh')))
collapse (mean) mean = b (sd) sd = b (first) obs, by(k meas)
gen double z = abs(mean - obs) / max(sd, 1e-9)
bysort k: egen double D = total(z)
list, noobs sepby(k)
save "$RINT/inst_kgrid_sum.dta", replace
sort D k
local kc = k[1]
rv_kv b5_kcons `kc'
di "k do consumo escolhido por momentos = `kc'"

* ---------------------------------------------------------------- 1.000 replicacoes no k escolhido
tempname P
postfile `P' str8 des double k int rep str2 spec str4 meas double b using "$RINT/inst_mm_draws.dta", replace
set seed 20261117
foreach dd in "556 G" "556 C" "701 G" "701 C" {
    tokenize `dd'
    local e0 = cond("`1'" == "556", `e0a', 0.701)
    local gr = cond("`2'" == "G", `e1', 0)
    use "$KIN2/siminst_base.dta", clear
    mk_pool `e0' `gr' `minst'
    tempfile bd
    save `bd'
    forvalues r = 1/`R' {
        quietly use `bd', clear
        inst_rep `P' mm`1'`2' `kc' `r' `=(`r' == 1)'
    }
}
postclose `P'

* ---------------------------------------------------------------- quadro completo das fracoes
use "$KIN2/siminst_draws.dta", clear
drop if des == "obs"
replace des = "anc556" + des
append using "$KIN3/siminst3_draws.dta"
append using "$RINT/inst_mm_draws.dta"
keep if inlist(meas, "c", "l", "h")
gen double bobs = .
foreach s in C D {
    foreach m in c l h {
        replace bobs = `o_`s'`m'' if spec == "`s'" & meas == "`m'"
    }
}
gen double sh = b / bobs
gen double shp = b / (-0.811) if spec == "D"
bysort des spec meas: egen double sh_lo = pctile(sh), p(2.5)
bysort des spec meas: egen double sh_hi = pctile(sh), p(97.5)
bysort des spec meas: egen double shp_lo = pctile(shp), p(2.5)
bysort des spec meas: egen double shp_hi = pctile(shp), p(97.5)
bysort des spec meas: egen double p025 = pctile(b), p(2.5)
bysort des spec meas: egen double p975 = pctile(b), p(97.5)
collapse (mean) mean = b share = sh share_pub = shp (first) sh_lo sh_hi shp_lo shp_hi p025 p975 bobs (count) nrep = b, by(des spec meas)
list des spec meas mean share sh_lo sh_hi share_pub if meas == "c", noobs sepby(spec)
save "$RINT/inst_shares.dta", replace
kcsv "$RINT/inst_shares.dta" Table_A13_part_null_shares_full
foreach s in C D {
    quietly summ share if spec == "`s'" & meas == "c"
    rv_kv b5_share_`s'_min `=string(r(min), "%9.4f")'
    rv_kv b5_share_`s'_max `=string(r(max), "%9.4f")'
}
quietly summ share_pub if spec == "D" & meas == "c"
rv_kv b5_sharepub_min `=string(r(min), "%9.4f")'
rv_kv b5_sharepub_max `=string(r(max), "%9.4f")'
* (3) interacao sobre o PIB tendencial na especificacao registrada e sua nula
quietly summ mean if spec == "C" & meas == "h"
rv_kv b5_Ch_null_min `=string(r(min), "%9.4f")'
rv_kv b5_Ch_null_max `=string(r(max), "%9.4f")'
rv_kv b5_Ch_obs `=string(`o_Ch', "%9.4f")'

* ---------------------------------------------------------------- (2) safra do WDI
local mvpaises ALB DZA ATG ARG ARM AUS AUT AZE BHS BHR BGD BRB BLR BEL BLZ BEN BTN BOL BWA BRA BRN BGR BFA BDI ///
    KHM CMR TCD CHL CHN COL COM COD COG CRI CIV HRV CYP CZE DNK DOM ECU EGY SLV EST SWZ FJI FIN FRA GAB GMB GEO ///
    DEU GHA GRC GTM GIN GNB HND HKG HUN ISL IND IDN IRN IRL ISR ITA JAM JPN JOR KAZ KEN KOR KWT KGZ LVA LBN LTU ///
    LUX MAC MDG MYS MLI MLT MRT MUS MEX MDA MNG MAR MOZ NAM NPL NLD NZL NIC NER NGA MKD NOR OMN PAK PAN PRY PER ///
    PHL POL PRT PRI ROU RUS RWA SAU SEN SRB SLE SGP SVK SVN ZAF ESP LKA SDN SWE CHE TJK TZA THA TGO TUN TUR UGA ///
    UKR GBR USA UZB VNM PSE
tempname W
postfile `W' str8 vint str2 inst double(bX seX pub ratio) long(N nc) using "$RINT/mv_vintage.dta", replace
foreach vint in current 202212 202312 {
    if "`vint'" != "current" {
        capture confirm file "$RAW/wdi_archives/wdi_`vint'.csv"
        if _rc {
            di "safra `vint' nao disponivel"
            continue
        }
        import delimited "$RAW/wdi_archives/wdi_`vint'.csv", clear varnames(1)
        rename (ny_gdp_mktp_kd_zg ne_con_govt_zs ne_gdi_totl_zs sp_pop_grow) (v_gy v_gc v_gcf v_popg)
        tempfile wv
        save `wv'
    }
    use "$KIN/anual_rv.dta", clear
    gen byte mv138 = 0
    foreach c of local mvpaises {
        replace mv138 = 1 if iso3 == "`c'"
    }
    keep if mv138 & inrange(year, 1994, 2019)
    if "`vint'" != "current" {
        merge 1:1 iso3 year using `wv', keep(master match) nogen
        replace gdp_growth_mv = v_gy
        replace govcons_gdp_mv = v_gc
        replace gcf_gdp_mv = v_gcf
        replace popg = v_popg
    }
    xtset id year
    gen gy = gdp_growth_mv
    gen gy_l1 = L.gy
    gen lgy = ln(govcons_gdp_mv) if govcons_gdp_mv > 0
    gen liy = ln(gcf_gdp_mv) if gcf_gdp_mv > 0
    foreach i in ge cc rl {
        by id: ipolate wgi_`i' year, gen(_ip)
        replace wgi_`i' = _ip if missing(wgi_`i') & inlist(year, 1997, 1999, 2001)
        drop _ip
    }
    keep if inrange(year, 1996, 2019)
    foreach i in ge cc rl {
        local pub = cond("`i'" == "ge", -0.811, cond("`i'" == "cc", -0.814, -0.835))
        capture drop I G GX
        gen I = wgi_`i'
        gen G = lgy
        gen GX = G * I
        quietly reghdfe gy gy_l1 I G GX liy popg i.year, absorb(id) vce(robust)
        capture drop tg
        egen tg = tag(id) if e(sample)
        quietly count if tg == 1
        post `W' ("`vint'") ("`i'") (_b[GX]) (_se[GX]) (`pub') (_b[GX] / `pub') (e(N)) (r(N))
    }
}
postclose `W'
use "$RINT/mv_vintage.dta", clear
list, noobs sepby(vint)
kcsv "$RINT/mv_vintage.dta" Table_A14_rows_vintage
quietly summ ratio if vint != "current"
local rmin = r(min)
local ok = (r(N) > 0)
rv_kv b5_vintage_available `ok'
rv_kv b5_vintage_ratio_min `=string(`rmin', "%9.4f")'
rv_kv b5_rule `=cond(`ok' & `rmin' < 1.5, "fractions of MV", "replicated only")'

* ---------------------------------------------------------------- (4) Holm nas 24 celulas
use "$KIN2/opra_triple.dta", clear
gen double pp = cond(est == "fe", pboot, p)
drop if missing(pp)
sort pp
gen int rk = _n
local m = _N
gen double ph = .
replace ph = min(1, (`m' - rk + 1) * pp) in 1
forvalues j = 2/`m' {
    replace ph = max(ph[`j' - 1], min(1, (`m' - rk + 1) * pp)) in `j'
}
quietly count if ph < 0.05
rv_kv b5_holm_sig `r(N)'
rv_kv b5_holm_cells `m'
list split smp meas est pp ph, noobs sep(0)
save "$RINT/opra_holm.dta", replace
kcsv "$RINT/opra_holm.dta" Table_A13_part_holm
log close
