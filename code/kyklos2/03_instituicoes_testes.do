* 03_instituicoes_testes.do -- Bloco 3: testes formais nas replicas institucionais
* Plano: docs/plan_addendum_kyklos_2.md, Bloco 3.
* (1) Oto-Peralias e Romero-Avila: 1981-2005 x periodo posterior empilhados num painel quinquenal unico (1981-2020,
*     cada periodo uma vez), tripla interacao consumo x instituicoes x posterior; FE com bootstrap e System GMM.
* (2-3) Mollick e Vianna, especificacao publicada: IC da interacao defasada e sobre o PIB tendencial, White e
*     agrupado, contra a interacao publicada; equivalencia a +-0,5 e +-1,0 (GE, CC, RL).
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/kyklos2/00_setup_k2.do"
capture log close
log using "$RLOG/03_instituicoes_testes.log", replace text

* =====================================================================================
* (1) Oto-Peralias e Romero-Avila
* =====================================================================================
use "$KIN/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1980, 2020)
xtset id year
gen period = floor((year - 1981) / 5)
gen year0 = 1981 + 5 * period
gen byte first = year == year0
foreach v in govcons_gdp lny {
    gen `v'_tp = `v' if first
    gen `v'_m1 = L.`v' if first
}
drop if year < 1981
collapse (mean) g gc_mean = govcons_gdp icrg = icrg_qog secenr inv dependency ///
    (firstnm) gc_tp = govcons_gdp_tp gc_m1 = govcons_gdp_m1 lny0 = lny_m1 iso3, by(id period)
xtset id period
keep if !missing(g, gc_mean, gc_tp, gc_m1, icrg, lny0, secenr, inv)
gen byte late_m = period >= 5
gen byte late_r = period >= 3
bysort id: egen byte e_m = max(late_m == 0)
bysort id: egen byte l_m = max(late_m == 1)
gen byte both_m = e_m & l_m
bysort id: egen byte e_r = max(late_r == 0)
bysort id: egen byte l_r = max(late_r == 1)
gen byte both_r = e_r & l_r
tab period late_m
count if both_m
save "$RINT/opra_stack.dta", replace

tempname O
postfile `O' str4 split str4 smp str8 meas str4 est double(b se p pboot blo bhi bE seE bL seL) long(N nc) double(ar2p hansp) ///
    using "$RINT/opra_triple.dta", replace
foreach split in m r {
    foreach smp in all both {
        foreach meas in gc_mean gc_tp gc_m1 {
            use "$RINT/opra_stack.dta", clear
            if "`smp'" == "both" keep if both_`split'
            gen L = late_`split'
            gen G = `meas'
            gen GXI = G * icrg
            gen GXL = G * L
            gen GXIXL = G * icrg * L
            gen IXL = icrg * L
            * efeitos fixos de pais e periodo, erros agrupados por pais; bootstrap selvagem da tripla interacao
            reghdfe g G GXI GXL GXIXL icrg IXL lny0 secenr inv i.period, absorb(id) vce(cluster id)
            local b = _b[GXIXL]
            local se = _se[GXIXL]
            local p = 2 * ttail(e(df_r), abs(`b' / `se'))
            local N = e(N)
            local nc = e(N_clust)
            local bE = _b[GXI]
            local seE = _se[GXI]
            quietly lincom GXI + GXIXL
            local bL = r(estimate)
            local seL = r(se)
            kboot GXIXL
            post `O' ("`split'") ("`smp'") ("`meas'") ("fe") (`b') (`se') (`p') (r(p)) (r(lo)) (r(hi)) (`bE') (`seE') (`bL') (`seL') ///
                (`N') (`nc') (.) (.)
            * System GMM (especificacao do painel A da Tabela A14, com as novas interacoes instrumentadas como G x I)
            quietly tab period, gen(pd)
            drop pd1
            capture noisily xtabond2 g G GXI GXL GXIXL icrg IXL lny0 secenr inv pd*, gmm(G GXI GXL GXIXL inv, lag(2 .) collapse) ///
                gmm(lny0 secenr icrg IXL, lag(1 .) collapse) iv(pd* dependency) twostep robust small
            if !_rc {
                local b = _b[GXIXL]
                local se = _se[GXIXL]
                quietly lincom GXI + GXIXL
                post `O' ("`split'") ("`smp'") ("`meas'") ("sgmm") (`b') (`se') (2 * ttail(e(df_r), abs(`b' / `se'))) (.) (.) (.) ///
                    (_b[GXI]) (_se[GXI]) (r(estimate)) (r(se)) (e(N)) (e(N_g)) (e(ar2p)) (e(hansenp))
            }
            else post `O' ("`split'") ("`smp'") ("`meas'") ("sgmm") (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.) (.)
        }
    }
}
postclose `O'
use "$RINT/opra_triple.dta", clear
list split smp meas est b se p pboot blo bhi bE bL N nc ar2p hansp, noobs sep(0)
kcsv "$RINT/opra_triple.dta" Table_A15_panel_triple_interaction
quietly summ pboot if split == "m" & smp == "all" & meas == "gc_mean" & est == "fe"
local pr = r(mean)
rv_kv b3_opra_pboot `=string(`pr', "%9.4f")'
rv_kv b3_opra_rule `=cond(`pr' < 0.05, "specific", "not different")'

* =====================================================================================
* (2-3) Mollick e Vianna, especificacao publicada (Tabela A14, painel D; Tabela A16)
* =====================================================================================
local mvpaises ALB DZA ATG ARG ARM AUS AUT AZE BHS BHR BGD BRB BLR BEL BLZ BEN BTN BOL BWA BRA BRN BGR BFA BDI ///
    KHM CMR TCD CHL CHN COL COM COD COG CRI CIV HRV CYP CZE DNK DOM ECU EGY SLV EST SWZ FJI FIN FRA GAB GMB GEO ///
    DEU GHA GRC GTM GIN GNB HND HKG HUN ISL IND IDN IRN IRL ISR ITA JAM JPN JOR KAZ KEN KOR KWT KGZ LVA LBN LTU ///
    LUX MAC MDG MYS MLI MLT MRT MUS MEX MDA MNG MAR MOZ NAM NPL NLD NZL NIC NER NGA MKD NOR OMN PAK PAN PRY PER ///
    PHL POL PRT PRI ROU RUS RWA SAU SEN SRB SLE SGP SVK SVN ZAF ESP LKA SDN SWE CHE TJK TZA THA TGO TUN TUR UGA ///
    UKR GBR USA UZB VNM PSE
use "$KIN/anual_rv.dta", clear
gen byte mv138 = 0
foreach c of local mvpaises {
    replace mv138 = 1 if iso3 == "`c'"
}
keep if mv138 & inrange(year, 1995, 2019)
xtset id year
gen gy = gdp_growth_mv
gen gy_l1 = L.gy
gen lgy = ln(govcons_gdp_mv) if govcons_gdp_mv > 0
gen lgy_l1 = L.lgy
gen lgy_ham = lgy + lnY - lnY_ham
gen liy = ln(gcf_gdp_mv) if gcf_gdp_mv > 0
foreach i in ge cc rl {
    by id: ipolate wgi_`i' year, gen(_ip)
    replace wgi_`i' = _ip if missing(wgi_`i') & inlist(year, 1997, 1999, 2001)
    drop _ip
}
keep if inrange(year, 1996, 2019)
save "$RINT/mv_base.dta", replace
* valores publicados (Mollick e Vianna, 2024, Tabela 2, periodo inteiro): interacao e erro-padrao
local pub_ge = -0.811
local pub_cc = -0.814
local pub_rl = -0.835
local spub_ge = 0.169
local spub_cc = 0.156
local spub_rl = 0.153
tempname M
postfile `M' str2 inst str7 meas str7 vce double(b se lo95 hi95 lo90 hi90 bpub excl tost_p05 tost_p10 tost_z05 tost_z10) long(N nc) ///
    using "$RINT/mv_ci.dta", replace
foreach i in ge cc rl {
    use "$RINT/mv_base.dta", clear
    gen I = wgi_`i'
    keep if !missing(gy, gy_l1, I, lgy, lgy_l1, lgy_ham, liy, popg)
    foreach meas in lgy lgy_l1 lgy_ham {
        capture drop G GX
        gen G = `meas'
        gen GX = G * I
        foreach v in robust cluster {
            local vv = cond("`v'" == "robust", "robust", "cluster id")
            quietly reghdfe gy gy_l1 I G GX liy popg i.year, absorb(id) vce(`vv')
            local b = _b[GX]
            local se = _se[GX]
            local df = e(df_r)
            local t95 = invttail(`df', 0.025)
            local t90 = invttail(`df', 0.05)
            local l95 = `b' - `t95' * `se'
            local h95 = `b' + `t95' * `se'
            local l90 = `b' - `t90' * `se'
            local h90 = `b' + `t90' * `se'
            local bp = `pub_`i''
            local ex = (`bp' < `l95' | `bp' > `h95')
            * TOST: equivalencia ao valor publicado e a zero (IC de 90% dentro da margem)
            local e05 = (`l90' > `bp' - 0.5 & `h90' < `bp' + 0.5)
            local e10 = (`l90' > `bp' - 1.0 & `h90' < `bp' + 1.0)
            local z05 = (`l90' > -0.5 & `h90' < 0.5)
            local z10 = (`l90' > -1.0 & `h90' < 1.0)
            local nc = cond("`v'" == "cluster", e(N_clust), .)
            post `M' ("`i'") ("`meas'") ("`v'") (`b') (`se') (`l95') (`h95') (`l90') (`h90') (`bp') (`ex') (`e05') (`e10') (`z05') (`z10') (e(N)) (`nc')
        }
    }
}
postclose `M'
use "$RINT/mv_ci.dta", clear
list, noobs sepby(inst)
kcsv "$RINT/mv_ci.dta" Table_A16_rows_mv_ci
quietly summ excl if inst == "ge" & meas == "lgy_l1" & vce == "cluster"
local ex = r(mean)
quietly summ b if inst == "ge" & meas == "lgy_l1" & vce == "cluster"
local bl = r(mean)
local mvr = cond(`ex' & `bl' > `pub_ge', "smaller", "indistinguishable")
rv_kv b3_mv_rule `mvr'
rv_kv b3_mv_excl_ge `ex'
log close
