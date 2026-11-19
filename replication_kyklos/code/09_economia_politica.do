* 09_economia_politica.do -- bloco 4.8 do plano: ciclo eleitoral (H5) e extensoes de economia politica [P29, P30]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
capture log close
log using "$RLOG/09_economia_politica.log", replace text

use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
xtset id year
gen L_g = L.g
* DPI termina em 2020
gen byte per = inrange(year, 1996, 2020)
quietly summ merit_l1 if per & !missing(d_wagebill_real), detail
gen byte mhi = merit_l1 > r(p50) if !missing(merit_l1)
gen efxm = election_fixed * mhi

mata:
string scalar _arfmt(string scalar s)
{
    string scalar r, m, out
    real scalar k
    r = s
    out = ""
    while (ustrregexm(r, "-?[0-9]*\.[0-9]+|-?[0-9]+")) {
        m = ustrregexs(0)
        k = strpos(r, m)
        out = out + substr(r, 1, k - 1) + strofreal(strtoreal(m), "%9.2f")
        r = substr(r, k + strlen(m), .)
    }
    out = out + r
    out = subinstr(out, "entire grid", "(" + uchar(8722) + uchar(8734) + ", +" + uchar(8734) + ")")
    out = subinstr(out, "+inf", "+" + uchar(8734))
    out = subinstr(out, "[ ... ,", "(" + uchar(8722) + uchar(8734) + ",")
    out = subinstr(out, "[  ...  ", "(" + uchar(8722) + uchar(8734))
    out = subinstr(out, " U ", " " + uchar(8746) + " ")
    out = subinstr(out, "-", uchar(8722))
    out = stritrim(subinstr(out, "[ ", "["))
    return(out)
}
end

tempname P
postfile `P' str10 smp double(b se p pboot Feff Fkp) str80 arci long(N nc) using "$RINT/ep_first.dta", replace
foreach smp in all dem new old {
    local c = cond("`smp'" == "all", "per", cond("`smp'" == "dem", "per & dem == 1", cond("`smp'" == "new", "per & dem_new == 1", "per & dem == 1 & dem_new == 0")))
    reghdfe d_wagebill_real election_fixed L_g i.year if `c', absorb(id) vce(cluster id)
    estimates store EP1_`smp'
    local b = _b[election_fixed]
    local se = _se[election_fixed]
    local p = 2 * ttail(e(df_r), abs(`b' / `se'))
    local Feff = (`b' / `se')^2
    local N = e(N)
    local nc = e(N_clust)
    rv_boot election_fixed
    local pb = r(p)
    * segundo estagio (so diagnostico se o instrumento for fraco) e Kleibergen-Paap
    capture noisily ivreghdfe g (d_wagebill_real = election_fixed) balance_gdp L_g i.year if `c', absorb(id) cluster(id)
    local Fkp = cond(_rc, ., e(widstat))
    * intervalo de Anderson-Rubin (weakiv), robusto a instrumento fraco
    local ar ""
    capture noisily weakiv ivreg2 g (d_wagebill_real = election_fixed) balance_gdp L_g i.year i.id if `c', cluster(id)
    if !_rc {
        * formato: duas casas, sinal de menos U+2212 e infinito
        local ar "`e(ar_cset)'"
        mata: st_local("ar", _arfmt(st_local("ar")))
    }
    post `P' ("`smp'") (`b') (`se') (`p') (`pb') (`Feff') (`Fkp') ("`ar'") (`N') (`nc')
    rv_kv ep_`smp'_b `=string(`b', "%9.4f")'
    rv_kv ep_`smp'_se `=string(`se', "%9.4f")'
    rv_kv ep_`smp'_p `=string(`p', "%9.4f")'
    rv_kv ep_`smp'_pboot `=string(`pb', "%9.4f")'
    rv_kv ep_`smp'_Feff `=string(`Feff', "%9.2f")'
    rv_kv ep_`smp'_N `N'
}
* interacao do choque eleitoral com o merito (democracias)
reghdfe d_wagebill_real election_fixed efxm mhi L_g i.year if per & dem == 1, absorb(id) vce(cluster id)
estimates store EP1_merit
rv_kv ep_merit_int `=string(_b[efxm], "%9.4f")'
rv_kv ep_merit_int_p `=string(2 * ttail(e(df_r), abs(_b[efxm] / _se[efxm])), "%9.4f")'
postclose `P'

* ---------------------------------------------------------------- projecoes locais por tipo de choque, democracias (H5)
tempname Q
postfile `Q' str10 smp int h double(bel seel bot seot pdiff) long(N nc) using "$RINT/ep_lp.dta", replace
gen sel = d_wagebill_real * (election_fixed == 1) if !missing(election_fixed)
gen sot = d_wagebill_real * (election_fixed == 0) if !missing(election_fixed)
foreach smp in all dem {
    local c = cond("`smp'" == "all", "per", "per & dem == 1")
    forvalues hh = 0/6 {
        tempvar dy
        quietly gen double `dy' = F`hh'.y100 - L.y100
        quietly xtscc `dy' sel sot i.election_fixed L(1/2).d_wagebill_real L(1/2).g i.year if `c', fe lag($DKLAG)
        quietly test sel = sot
        post `Q' ("`smp'") (`hh') (_b[sel]) (_se[sel]) (_b[sot]) (_se[sot]) (r(p)) (e(N)) (e(N_g))
        if `hh' == 4 {
            lincom sel - sot
            rv_kv eplp_`smp'_h4_diff `=string(r(estimate), "%9.4f")'
            rv_kv eplp_`smp'_h4_p `=string(r(p), "%9.4f")'
            rv_kv eplp_`smp'_h4_se `=string(r(se), "%9.4f")'
        }
        drop `dy'
    }
}
postclose `Q'

* =====================================================================================
* Extensoes: interacoes da folha (t_p - 1) com caracteristicas politicas (t_p - 1), controles de T3
* =====================================================================================
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
global XP "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"
tempname E
postfile `E' str20 v str70 lab double(bi sei pi bmain) long(N nc) using "$RINT/ep_ext.dta", replace
foreach v in exec_left maj frac demage union_density clientelism_prog impartial {
    capture drop zc wbxz
    quietly summ `v'_m1 if !missing(g, wb_m1, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
    gen zc = `v'_m1 - r(mean)
    gen wbxz = wb_m1 * zc
    capture noisily reghdfe g wb_m1 zc wbxz $XP i.period, absorb(id) vce(cluster id)
    if _rc continue
    estimates store EX_`v'
    local lab = cond("`v'" == "exec_left", "Left-wing executive (DPI)", cond("`v'" == "maj", "Government majority, share of seats (DPI)", ///
        cond("`v'" == "frac", "Legislative fractionalization (DPI)", cond("`v'" == "demage", "Age of democracy, years (V-Dem)", ///
        cond("`v'" == "union_density", "Trade union density, % (ILOSTAT)", cond("`v'" == "clientelism_prog", "Programmatic (vs clientelistic) linkages (V-Dem)", ///
        "Rigorous and impartial administration (V-Dem)"))))))
    post `E' ("`v'") ("`lab'") (_b[wbxz]) (_se[wbxz]) (2 * ttail(e(df_r), abs(_b[wbxz] / _se[wbxz]))) (_b[wb_m1]) (e(N)) (e(N_clust))
    rv_kv ext_`v'_bi `=string(_b[wbxz], "%9.4f")'
    rv_kv ext_`v'_pi `=string(2 * ttail(e(df_r), abs(_b[wbxz] / _se[wbxz])), "%9.4f")'
}
postclose `E'

* =====================================================================================
* Tabela 7 (texto principal): economia politica da folha
* =====================================================================================
use "$RINT/ep_first.dta", clear
list, noobs sep(0)
quietly count if Feff >= 10
local nstrong = r(N)
rv_new, ncol(4) head1("All countries" "Democracies" "New democracies" "Established democracies")
local cb ""
local cs ""
local c1 ""
local c2 ""
local c3 ""
local c4 ""
local cn ""
local cc ""
foreach smp in all dem new old {
    quietly summ b if smp == "`smp'"
    local b = r(mean)
    quietly summ p if smp == "`smp'"
    rv_fmt `b' %12.3f `=r(mean)'
    local cb `"`cb' "`r(s)'""'
    quietly summ se if smp == "`smp'"
    rv_fmt `=r(mean)' %12.3f
    local cs `"`cs' "(`r(s)')""'
    quietly summ pboot if smp == "`smp'"
    rv_fmt `=r(mean)' %12.3f
    local c1 `"`c1' "`r(s)'""'
    quietly summ Feff if smp == "`smp'"
    rv_fmt `=r(mean)' %12.2f
    local c2 `"`c2' "`r(s)'""'
    quietly summ Fkp if smp == "`smp'"
    rv_fmt `=r(mean)' %12.2f
    local c3 `"`c3' "`r(s)'""'
    quietly levelsof arci if smp == "`smp'", local(a) clean
    local c4 `"`c4' "`a'""'
    quietly summ N if smp == "`smp'"
    rv_fmt `=r(mean)' %12.0fc
    local cn `"`cn' "`r(s)'""'
    quietly summ nc if smp == "`smp'"
    local cc `"`cc' "`=r(mean)'""'
}
rv_row "A. First stage: real change in the wage bill (% of lagged GDP)" "" "" "" ""
rv_row "Predetermined election year" `cb'
rv_row "" `cs'
rv_row "Wild cluster bootstrap p-value" `c1'
rv_row "Effective F (Montiel Olea–Pflueger)" `c2'
rv_row "Kleibergen-Paap F" `c3'
rv_row "Anderson-Rubin 95% CI, second stage" `c4'
rv_row "Observations" `cn'
rv_row "Countries" `cc'
rv_mid
use "$RINT/ep_lp.dta", clear
keep if h == 4
local r1 ""
local r2 ""
local r3 ""
foreach smp in all dem {
    quietly summ bel if smp == "`smp'"
    local b = r(mean)
    quietly summ seel if smp == "`smp'"
    rv_fmt `b' %12.3f `=2 * normal(-abs(`b' / r(mean)))'
    local r1 `"`r1' "`r(s)'""'
    quietly summ bot if smp == "`smp'"
    local b = r(mean)
    quietly summ seot if smp == "`smp'"
    rv_fmt `b' %12.3f `=2 * normal(-abs(`b' / r(mean)))'
    local r2 `"`r2' "`r(s)'""'
    quietly summ pdiff if smp == "`smp'"
    rv_fmt `=r(mean)' %12.3f
    local r3 `"`r3' "`r(s)'""'
}
rv_row "B. Local projections, GDP per capita at h = 4 (100 × log)" "" "" "" ""
rv_row "Shock in a predetermined election year" `r1' "" ""
rv_row "Shock in other years" `r2' "" ""
rv_row "p-value, equal responses" `r3' "" ""
rv_mid
use "$RINT/ep_ext.dta", clear
rv_row "C. Wage bill (t_p − 1) × characteristic (t_p − 1, centred), five-year panel" "Interaction" "SE" "Obs." "Countries"
forvalues i = 1/`=_N' {
    rv_fmt `=bi[`i']' %12.3f `=pi[`i']'
    local a "`r(s)'"
    rv_fmt `=sei[`i']' %12.3f
    rv_row "`=lab[`i']'" "`a'" "(`r(s)')" "`=string(N[`i'], "%9.0fc")'" "`=nc[`i']'"
}
rv_out Tab7_political_economy, landscape ///
    title("Table 7. Political economy of the wage bill") ///
    notes("Panel A: annual panel 1996–2020 (DPI ends in 2020), real change in the general government wage bill (% of lagged GDP) on an indicator of an election in the year the constitutional term expires, with lagged growth, country and year fixed effects and standard errors clustered by country; wild cluster bootstrap with Webb weights and 9,999 replications. Democracies: V-Dem polyarchy ≥ 0.5; new democracies: 16 or fewer years of continuous democracy, an approximation of the first four elections (Brender and Drazen, 2005). With one instrument the effective F equals the squared cluster-robust t statistic. The second stage (growth on the instrumented wage bill change, with the fiscal balance and lagged growth) is reported through the Anderson-Rubin confidence set, which is robust to weak instruments; the instrument passes the pre-specified threshold (effective F ≥ 10) in `nstrong' of the four samples. Panel B: cumulative response of 100 × log GDP per capita four years after a real wage bill shock of one percentage point of GDP, separately for shocks in predetermined election years and in other years; country and year fixed effects, two lags of the shock and of growth, Driscoll-Kraay standard errors (maximum lag 3). Panel C: five-year averages, preferred H1 specification (T3) with the wage bill in t_p − 1 interacted with each characteristic in t_p − 1 (centred at its sample mean), one model per row; standard errors clustered by country. Staggered subnational elections in federations: not executed (no public subnational election calendar in the project data). * p<0.10, ** p<0.05, *** p<0.01.")

log close
