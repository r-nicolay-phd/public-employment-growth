* 04_simulacao_inst.do -- Bloco 4: interacao institucional sob a hipotese nula (consumo sintetico ancorado)
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 4.
* ln c_sim,t = ln c_obs,t-1 - (1 - eps_it) dln Y_t + u_t, eps_it = eps0 + eps1 x WGI_i,t-1 (indice medio, centrado como
* no mecanismo da Tabela A15); u sorteado dos valores recentrados do proprio pais. Controle: eps1 = 0.
* Em cada replicacao: especificacao publicada de Mollick e Vianna (Tabela A14, painel D, GE, amostra comum) e
* especificacao aproximada (painel C), com o consumo sintetico do mesmo ano, defasado e sobre o PIB tendencial.
* Tambem gera a Tabela A15 (paineis novos: tripla interacao do Bloco 3 e esta simulacao).
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/04_simulacao_inst.log", replace text
local R = cond("$SIMR" == "", 1000, real("$SIMR"))
do "$ROOT/code/kyklos2/sim2_mata.do"

* ---------------------------------------------------------------- eps0 e eps1 (mecanismo da Tabela A15)
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1995, 2023)
xtset id year
egen inst = rowmean(wgi_ge wgi_rq wgi_rl wgi_cc wgi_va wgi_pv)
gen dlYn = 100 * (ln(gdp_nom_lcu) - ln(L.gdp_nom_lcu))
gen dlC = 100 * (ln(govcons_gdp / 100 * gdp_nom_lcu) - ln(L.govcons_gdp / 100 * L.gdp_nom_lcu))
keep if inrange(year, 1996, 2023)
quietly summ inst
local minst = r(mean)
gen c_inst = inst - `minst'
xtscc dlC c.dlYn##c.c_inst i.year if abs(dlC) < 200 & abs(dlYn) < 200, fe lag($DKLAG)
local e1 = _b[c.dlYn#c.c_inst]
local e0 = _b[dlYn]
di "eps0 = `e0'; eps1 = `e1'; media do indice (centragem) = `minst'"
rv_kv b4_eps0 `=string(`e0', "%9.4f")'
rv_kv b4_eps1 `=string(`e1', "%9.4f")'
rv_kv b4_minst `=string(`minst', "%9.4f")'

* ---------------------------------------------------------------- base
local mvpaises ALB DZA ATG ARG ARM AUS AUT AZE BHS BHR BGD BRB BLR BEL BLZ BEN BTN BOL BWA BRA BRN BGR BFA BDI ///
    KHM CMR TCD CHL CHN COL COM COD COG CRI CIV HRV CYP CZE DNK DOM ECU EGY SLV EST SWZ FJI FIN FRA GAB GMB GEO ///
    DEU GHA GRC GTM GIN GNB HND HKG HUN ISL IND IDN IRN IRL ISR ITA JAM JPN JOR KAZ KEN KOR KWT KGZ LVA LBN LTU ///
    LUX MAC MDG MYS MLI MLT MRT MUS MEX MDA MNG MAR MOZ NAM NPL NLD NZL NIC NER NGA MKD NOR OMN PAK PAN PRY PER ///
    PHL POL PRT PRI ROU RUS RWA SAU SEN SRB SLE SGP SVK SVN ZAF ESP LKA SDN SWE CHE TJK TZA THA TGO TUN TUR UGA ///
    UKR GBR USA UZB VNM PSE
use "$KIN/anual_rv.dta", clear
keep if inrange(year, 1993, 2023)
gen byte mv138 = 0
foreach c of local mvpaises {
    replace mv138 = 1 if iso3 == "`c'"
}
keep if mv138 | micro == 0
xtset id year
egen inst = rowmean(wgi_ge wgi_rq wgi_rl wgi_cc wgi_va wgi_pv)
* indice interpolado entre anos; antes de 1996, o valor de 1996
by id: ipolate inst year, gen(instI)
bysort id (year): egen double inst96 = max(cond(year == 1996, instI, .))
replace instI = inst96 if year < 1996
sort id year
xtset id year
gen double instL = L.instI
replace instL = inst96 if year <= 1996 & missing(instL)
gen double epsG = `e0' + `e1' * (instL - `minst')
gen double epsC = `e0'
gen double dlYn = ln(gdp_nom_lcu) - ln(L.gdp_nom_lcu)
gen double lCv = ln(govcons_gdp_mv / 100) if govcons_gdp_mv > 0
gen double lCp = ln(govcons_gdp / 100) if govcons_gdp > 0
foreach s in v p {
    gen double lC`s'_l1 = L.lC`s'
    gen double dlC`s' = lC`s' - lC`s'_l1
    gen byte ok`s' = !missing(lC`s'_l1, dlYn, epsG)
    foreach d in G C {
        gen double e`s'`d' = dlC`s' + (1 - eps`d') * dlYn if ok`s'
        bysort id: egen double _m = mean(e`s'`d')
        replace e`s'`d' = e`s'`d' - _m
        drop _m
    }
}
sort id year
xtset id year
* painel C (replica aproximada): amostra e variaveis como na Tabela A14
gen gc = govcons_gdp
gen gc_l1 = L.govcons_gdp
gen gc_ham = govcons_gdp * exp(lnY - lnY_ham)
gen g_l1 = L.g
gen lny_l1 = L.lny
gen byte sMV = micro == 0 & inrange(year, 1996, 2019) & !missing(g, gc, gc_l1, gc_ham, inst, g_l1, lny_l1, hc, inv, open, infl, popg, ctot_g)
quietly summ inst if sMV
gen instc = inst - r(mean)
* painel D (especificacao publicada, GE): amostra comum como na Tabela A16
gen gy = gdp_growth_mv
gen gy_l1 = L.gy
gen lgy = ln(govcons_gdp_mv) if govcons_gdp_mv > 0
gen lgy_l1 = L.lgy
gen lgy_ham = lgy + lnY - lnY_ham
gen liy = ln(gcf_gdp_mv) if gcf_gdp_mv > 0
by id: ipolate wgi_ge year, gen(_ip)
gen I = wgi_ge
replace I = _ip if missing(I) & inlist(year, 1997, 1999, 2001)
drop _ip
gen byte sD = mv138 & inrange(year, 1996, 2019) & !missing(gy, gy_l1, I, lgy, lgy_l1, lgy_ham, liy, popg)
count if sMV
count if sD
gen int yr = year
save "$RINT/siminst_base.dta", replace

* coeficientes observados
tempname P
postfile `P' str4 des int rep str2 spec str2 meas double b using "$RINT/siminst_draws.dta", replace
foreach k in "c gc" "l gc_l1" "h gc_ham" {
    tokenize `k'
    capture drop GX
    gen double GX = `2' * instc
    quietly reghdfe g `2' instc GX g_l1 lny_l1 hc inv open infl popg ctot_g i.year if sMV, absorb(id)
    post `P' ("obs") (0) ("C") ("`1'") (_b[GX])
}
foreach k in "c lgy" "l lgy_l1" "h lgy_ham" {
    tokenize `k'
    capture drop GX
    gen double GX = `2' * I
    quietly reghdfe gy gy_l1 I `2' GX liy popg i.year if sD, absorb(id)
    post `P' ("obs") (0) ("D") ("`1'") (_b[GX])
}
drop GX

* ---------------------------------------------------------------- simulacao
set seed 20261115
foreach d in G C {
    di as result "desenho `d' (G = gradiente, C = controle eps1 = 0)"
    forvalues r = 1/`R' {
        quietly {
            use "$RINT/siminst_base.dta", clear
            foreach s in v p {
                gen double u`s' = .
                mata: _drawc("id", "e`s'`d'", "ok`s'", "u`s'")
                gen double cs`s' = 100 * exp(lC`s'_l1 - (1 - eps`d') * dlYn + u`s')
            }
            xtset id year
            * painel C
            gen double S_c = csp
            gen double S_l = L.csp
            gen double S_h = csp * exp(lnY - lnY_ham)
            foreach m in c l h {
                gen double X = S_`m' * instc
                mata: _fwlb("C_`m'", "g", "S_`m' X", "instc g_l1 lny_l1 hc inv open infl popg ctot_g", "id", "year", "sMV", "BB")
                post `P' ("`d'") (`r') ("C") ("`m'") (BB[1, 2])
                if `r' == 1 {
                    reghdfe g S_`m' instc X g_l1 lny_l1 hc inv open infl popg ctot_g i.year if sMV, absorb(id)
                    noisily di "conferencia FWL x reghdfe (C, `d', `m'): " %12.8f _b[X] " " %12.8f BB[1, 2]
                    assert reldif(_b[X], BB[1, 2]) < 1e-6
                }
                drop X
            }
            * painel D
            gen double L_c = ln(csv)
            gen double L_l = L.L_c
            gen double L_h = L_c + lnY - lnY_ham
            foreach m in c l h {
                gen double X = L_`m' * I
                mata: _fwlb("D_`m'", "gy", "L_`m' X", "gy_l1 I liy popg", "id", "year", "sD", "BB")
                post `P' ("`d'") (`r') ("D") ("`m'") (BB[1, 2])
                if `r' == 1 {
                    reghdfe gy gy_l1 I L_`m' X liy popg i.year if sD, absorb(id)
                    noisily di "conferencia FWL x reghdfe (D, `d', `m'): " %12.8f _b[X] " " %12.8f BB[1, 2]
                    assert reldif(_b[X], BB[1, 2]) < 1e-6
                }
                drop X
            }
        }
        if mod(`r', 250) == 0 di "  replicacao `r'"
    }
}
postclose `P'

* ---------------------------------------------------------------- resumo e regra
use "$RINT/siminst_draws.dta", clear
preserve
keep if des == "obs"
keep spec meas b
rename b bobs
tempfile ob
save `ob'
restore
drop if des == "obs"
bysort des spec meas: egen double p025 = pctile(b), p(2.5)
bysort des spec meas: egen double p975 = pctile(b), p(97.5)
collapse (mean) mean = b (first) p025 p975 (count) nrep = b, by(des spec meas)
merge m:1 spec meas using `ob', nogen
gen double share = mean / bobs
gen byte inside = bobs >= p025 & bobs <= p975
reshape wide mean p025 p975 nrep share inside, i(spec meas) j(des) string
gen double share_net = (meanG - meanC) / bobs
gen byte ctrl0 = abs(meanC) <= 0.10 * abs(bobs) & p025C <= 0 & p975C >= 0
list, noobs
save "$RINT/siminst_sum.dta", replace
kcsv "$RINT/siminst_sum.dta" Table_A15_panel_simulation
quietly summ shareG if spec == "D" & meas == "c"
local sh = r(mean)
quietly summ share_net if spec == "D" & meas == "c"
local shn = r(mean)
quietly summ ctrl0 if spec == "D" & meas == "c"
local c0 = r(mean)
local rule = cond(`sh' >= 0.50 & `c0', "explains", cond(`shn' >= 0.20 & `shn' < 0.50, "part", cond(`shn' >= 0.50, "part", "too small")))
rv_kv b4_share `=string(`sh', "%9.4f")'
rv_kv b4_share_net `=string(`shn', "%9.4f")'
rv_kv b4_ctrl0 `c0'
rv_kv b4_rule "`rule'"
di "Bloco 4: fracao com gradiente = `sh'; liquida do controle = `shn'; controle perto de zero = `c0'; regra: `rule'"
log close
