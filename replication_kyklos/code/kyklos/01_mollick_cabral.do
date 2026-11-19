* 01_mollick_cabral.do -- Bloco 1: replica aproximada de Mollick e Cabral (2011, Kyklos 64(1): 122-137)
* Especificacao publicada (Consensus/mollick2011.pdf): 54 economias (Tabela 1, p. 126-127), 1986-2004; y = log do
* PIB per capita real sobre y(t-1), crescimento populacional, ln(I/Y), [abertura] e ln(G/Y), G/Y = consumo do governo
* (WDI); System GMM de um passo (Blundell-Bond), robusto, todos os regressores endogenos exceto n; instrumentos:
* defasagens 2-4 de y e todas as defasagens (2+) dos demais endogenos (p. 129-130); sem efeitos de tempo.
* Coeficientes publicados de ln(G/Y), amostra completa: -0,032 (0,008) anual (Tabela 2, col. 1, p. 131);
* -0,086 (0,060) quinquenal (Tabela 3, col. 1, p. 134).
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/01_mollick_cabral.log", replace text

local mc54 AUS AUT BEL CAN DNK FIN FRA DEU GRC ISL IRL ITA JPN NLD NZL NOR PRT ESP SWE CHE GBR USA ///
    ARG BGD BRA BGR CHL CHN COL CRI CZE DOM ECU EGY SLV HUN IND IDN ISR KOR MYS MEX MAR PAK PER PHL POL SGP ///
    ZAF THA TUN TUR URY VEN
use "$KIN/anual_rv.dta", clear
gen byte mc = 0
foreach c of local mc54 {
    replace mc = 1 if iso3 == "`c'"
}
egen tmc = tag(iso3) if mc
count if tmc
rv_kv mc_ncountries `r(N)'
keep if mc & inrange(year, 1975, 2023)
xtset id year
* variaveis do modelo deles
gen y = lny
gen ls = ln(gcf_gdp_mv) if gcf_gdp_mv > 0
gen lto = ln(open) if open > 0
gen n = popg
* medidas de tamanho do governo (em log)
gen double gstar_g = .
gen double dlgr = ln(govcons_real) - ln(L.govcons_real)
bysort id: egen double gs = mean(dlgr) if inrange(year, 1986, 2023)
bysort id: egen double gs2 = max(gs)
xtset id year
gen lg_a = ln(govcons_gdp) if govcons_gdp > 0
gen lg_b = ln(L.govcons_gdp * (L.gdp_real / gdp_real) * exp(gs2))
gen lg_c = ln(govcons_gdp * exp(lnY - lnY_ham)) if govcons_gdp > 0
gen lg_d = L.lg_a
save "$RINT/mc_anual.dta", replace

tempname P
postfile `P' str8 per str6 freq str4 meas str4 est str4 spec double(b se p lo hi) long(N nc nins) double(ar2 hansen) ///
    using "$RINT/mc_res.dta", replace
capture program drop mcest
program define mcest
    * mcest P per freq meas est spec cond: uma regressao (FE ou GMM) com a medida lg_`meas'
    args P per freq meas est spec cond
    local x "n ls lg_`meas'"
    if "`spec'" == "c4" local x "`x' lto"
    local endo "ls lg_`meas'"
    if "`spec'" == "c4" local endo "`endo' lto"
    if "`est'" == "fe" {
        quietly reghdfe y L.y `x' if `cond', absorb(id) vce(cluster id)
        local df = e(df_r)
        local nins = .
        local ar2 = .
        local hn = .
        local nc = e(N_clust)
    }
    else {
        quietly xtabond2 y L.y `x' if `cond', gmm(L.y, lag(1 3)) gmm(`endo', lag(2 .)) iv(n) robust
        local df = .
        local nins = e(j)
        local ar2 = e(ar2p)
        local hn = e(sarganp)
        local nc = e(N_g)
    }
    local b = _b[lg_`meas']
    local se = _se[lg_`meas']
    if "`est'" == "fe" local p = 2 * ttail(`df', abs(`b' / `se'))
    else local p = 2 * normal(-abs(`b' / `se'))
    local z = cond("`est'" == "fe", invttail(`df', 0.025), invnormal(0.975))
    post `P' ("`per'") ("`freq'") ("`meas'") ("`est'") ("`spec'") (`b') (`se') (`p') (`b' - `z' * `se') (`b' + `z' * `se') ///
        (e(N)) (`nc') (`nins') (`ar2') (`hn')
    rv_kv mc_`per'_`freq'_`meas'_`est'_`spec'_b `=string(`b', "%9.4f")'
    rv_kv mc_`per'_`freq'_`meas'_`est'_`spec'_p `=string(`p', "%9.4f")'
    rv_kv mc_`per'_`freq'_`meas'_`est'_`spec'_N `e(N)'
end

* ---------------------------------------------------------------- painel anual
foreach per in 8604 8623 {
    local y1 = cond("`per'" == "8604", 2004, 2023)
    use "$RINT/mc_anual.dta", clear
    xtset id year
    foreach spec in c1 c4 {
        local extra = cond("`spec'" == "c4", ", lto", "")
        capture drop sA
        gen byte sA = inrange(year, 1986, `y1') & !missing(y, L.y, n, ls, lg_a, lg_b, lg_c, lg_d`extra')
        foreach meas in a b c d {
            foreach est in fe gmm {
                mcest `P' `per' annual `meas' `est' `spec' "sA"
            }
        }
    }
    * diferencas (a)-(c), (a)-(d), (a)-(b): FE empilhado, wild cluster bootstrap por pais
    preserve
    keep if inrange(year, 1986, `y1') & !missing(y, L.y, n, ls, lg_a, lg_b, lg_c, lg_d)
    gen ly = L.y
    keep id year y ly n ls lg_a lg_b lg_c lg_d
    gen long obs = _n
    expand 4
    bysort obs: gen byte m = _n
    gen double x = cond(m == 1, lg_a, cond(m == 2, lg_b, cond(m == 3, lg_c, lg_d)))
    forvalues k = 1/4 {
        gen double x`k' = x * (m == `k')
    }
    egen idm = group(id m)
    quietly reghdfe y x1-x4 c.(ly n ls)#i.m, absorb(idm) vce(cluster id)
    foreach pr in "1 3" "1 4" "1 2" {
        gettoken a c : pr
        local c = strtrim("`c'")
        lincom x`a' - x`c'
        local d = r(estimate)
        kboot {x`a' - x`c' = 0}
        local nm = cond("`pr'" == "1 3", "ac", cond("`pr'" == "1 4", "ad", "ab"))
        post `P' ("`per'") ("annual") ("`nm'") ("diff") ("c1") (`d') (.) (r(p)) (r(lo)) (r(hi)) (e(N)) (.) (.) (.) (.)
        rv_kv mc_`per'_diff_`nm' `=string(`d', "%9.4f")'
        rv_kv mc_`per'_diff_`nm'_p `=string(r(p), "%9.4f")'
    }
    restore
}

* ---------------------------------------------------------------- painel quinquenal: blocos 1986-1990, ..., ultimo bloco truncado
use "$RINT/mc_anual.dta", clear
gen int blk = floor((year - 1981) / 5)
gen int y0 = 1981 + 5 * blk
gen byte first = year == y0
* ultimo ano do bloco anterior = ano anterior ao primeiro ano do bloco
xtset id year
gen gtp = govcons_gdp if first
gen gm1 = L.govcons_gdp if first
tempfile A
save `A'
foreach per in 8604 8623 {
    local y1 = cond("`per'" == "8604", 2004, 2023)
    use `A', clear
    keep if inrange(year, 1981, `y1')
    collapse (mean) n gcf = gcf_gdp_mv open gmean = govcons_gdp (lastnm) y (firstnm) gtp gm1 (count) ny = y, by(id blk)
    xtset id blk
    gen ls = ln(gcf)
    gen lto = ln(open)
    gen lg_m = ln(gmean)
    gen lg_t = ln(gtp)
    gen lg_p = ln(gm1)
    keep if blk >= 0
    foreach spec in c1 c4 {
        local extra = cond("`spec'" == "c4", ", lto", "")
        capture drop s5
        gen byte s5 = blk >= 1 & !missing(y, L.y, n, ls, lg_m, lg_t, lg_p`extra')
        foreach meas in m t p {
            foreach est in fe gmm {
                mcest `P' `per' five `meas' `est' `spec' "s5"
            }
        }
    }
}
postclose `P'

* =====================================================================================
* Tabela S19 e Figura S5
* =====================================================================================
use "$RINT/mc_res.dta", clear
list per freq meas est spec b se p N nc nins ar2 hansen, noobs sep(0)
kcsv "$RINT/mc_res.dta" TabS19_mollick_cabral
* regra de decisao (adendo, Bloco 1): coluna 1, 1986-2004, anual
foreach k in "a fe" "a gmm" "c gmm" "d gmm" "c fe" "d fe" {
    tokenize `k'
    quietly summ b if per == "8604" & freq == "annual" & meas == "`1'" & est == "`2'" & spec == "c1"
    local b_`1'_`2' = r(mean)
    quietly summ p if per == "8604" & freq == "annual" & meas == "`1'" & est == "`2'" & spec == "c1"
    local p_`1'_`2' = r(mean)
}
local repro = (`b_a_fe' < 0 & `p_a_fe' < 0.05 & `b_a_gmm' < 0 & `p_a_gmm' < 0.05)
local col_d = (abs(`b_d_gmm') <= 0.5 * abs(`b_a_gmm') & `p_d_gmm' >= 0.05)
local col_c = (abs(`b_c_gmm') <= 0.5 * abs(`b_a_gmm') & `p_c_gmm' >= 0.05)
local keep = `repro' & `p_d_gmm' >= 0.05 & (`col_d' | `col_c')
rv_kv mc_rule_repro `repro'
rv_kv mc_rule_col_d `col_d'
rv_kv mc_rule_col_c `col_c'
rv_kv mc_rule_keep `keep'
di "Bloco 1: reproduz = `repro'; colapsa com defasada = `col_d'; com Hamilton = `col_c'; manter titulo = `keep'"
local verb = cond(`col_d' & `col_c', "collapses when government size is measured before growth", ///
    cond(`col_c', "disappears over trend GDP but not with the lagged ratio", ///
    cond(`col_d', "disappears with the lagged ratio but not over trend GDP", "survives when government size is measured before growth")))

local cols `""8604 fe" "8604 gmm" "8623 fe" "8623 gmm""'
rv_new, ncol(4) head1("1986–2004" "" "1986–2023" "") head2("Fixed effects" "System GMM" "Fixed effects" "System GMM")
rv_row "Published (Mollick and Cabral, 2011, Tables 2–3, col. 1)" "" "" "" ""
rv_row "Annual, same-year ln(G/Y)" "" "−0.032***" "" ""
rv_row "" "" "(0.008)" "" ""
rv_row "Five-year averages, ln(G/Y)" "" "−0.086" "" ""
rv_row "" "" "(0.060)" "" ""
rv_mid
foreach blk in "annual A. Annual panel: measure of government size (log)" "five B. Five-year averages: measure of government size (log)" {
    gettoken fq ttl : blk
    rv_row "`=strtrim("`ttl'")'" "" "" "" ""
    local ms = cond("`fq'" == "annual", "a b c d", "m t p")
    foreach m of local ms {
        local lab = cond("`m'" == "a", "(a) Same year", cond("`m'" == "b", "(b) Placebo numerator (denominator only)", ///
            cond("`m'" == "c", "(c) % of trend GDP (Hamilton)", cond("`m'" == "d", "(d) Lagged one year", ///
            cond("`m'" == "m", "(e1) Period mean", cond("`m'" == "t", "(e2) First year (t_p)", "(e3) Last year of previous period (t_p − 1)"))))))
        local cb ""
        local cs ""
        foreach c of local cols {
            tokenize `c'
            quietly summ b if per == "`1'" & freq == "`fq'" & meas == "`m'" & est == "`2'" & spec == "c1"
            local b = r(mean)
            quietly summ p if per == "`1'" & freq == "`fq'" & meas == "`m'" & est == "`2'" & spec == "c1"
            rv_fmt `b' %12.3f `=r(mean)'
            local cb `"`cb' "`r(s)'""'
            quietly summ lo if per == "`1'" & freq == "`fq'" & meas == "`m'" & est == "`2'" & spec == "c1"
            local l = r(mean)
            quietly summ hi if per == "`1'" & freq == "`fq'" & meas == "`m'" & est == "`2'" & spec == "c1"
            local h = r(mean)
            rv_fmt `l' %12.3f
            local ls "`r(s)'"
            rv_fmt `h' %12.3f
            local cs `"`cs' "[`ls'; `r(s)']""'
        }
        rv_row "`lab'" `cb'
        rv_row "" `cs'
    }
    foreach st in N nc {
        local cn ""
        foreach c of local cols {
            tokenize `c'
            local mm = cond("`fq'" == "annual", "a", "m")
            quietly summ `st' if per == "`1'" & freq == "`fq'" & meas == "`mm'" & est == "`2'" & spec == "c1"
            rv_fmt `=r(mean)' %12.0fc
            local cn `"`cn' "`r(s)'""'
        }
        rv_row "`=cond("`st'" == "N", "Observations", "Countries")'" `cn'
    }
    rv_mid
}
rv_row "C. Differences, annual fixed effects (stacked model, wild cluster bootstrap)" "" "" "" ""
foreach d in ac ad ab {
    local lab = cond("`d'" == "ac", "(a) − (c)", cond("`d'" == "ad", "(a) − (d)", "(a) − (b)"))
    local cb ""
    foreach pr in 8604 8623 {
        quietly summ b if per == "`pr'" & meas == "`d'" & est == "diff"
        local b = r(mean)
        quietly summ p if per == "`pr'" & meas == "`d'" & est == "diff"
        rv_fmt `b' %12.3f `=r(mean)'
        local x "`r(s)'"
        quietly summ lo if per == "`pr'" & meas == "`d'" & est == "diff"
        rv_fmt `=r(mean)' %12.3f
        local l "`r(s)'"
        quietly summ hi if per == "`pr'" & meas == "`d'" & est == "diff"
        rv_fmt `=r(mean)' %12.3f
        local cb `"`cb' "`x' [`l'; `r(s)']" """'
    }
    rv_row "`lab'" `cb'
}
quietly summ nins if per == "8604" & freq == "annual" & est == "gmm" & spec == "c1" & meas == "a"
local ni = r(mean)
quietly summ ar2 if per == "8604" & freq == "annual" & est == "gmm" & spec == "c1" & meas == "a"
local a2 = string(r(mean), "%5.3f")
rv_out TabS19_mollick_cabral, landscape ///
    title("Table S19. Mollick and Cabral's annual coefficient `verb' (approximate replication)") ///
    notes("Approximate replication of Mollick and Cabral (2011, Kyklos 64: 122–137), full sample, their column 1. Their 54 industrial and emerging economies (Table 1); dependent variable: log real GDP per capita (WDI, current vintage) on its lag, population growth, log investment/GDP (gross capital formation) and log government size; no time effects, as in the original. Measures: (a) general government final consumption/GDP in the same year; (b) placebo numerator, lagged ratio × (lagged real GDP / current real GDP) × exp(country mean real growth of government consumption), which varies only through the denominator; (c) consumption over Hamilton trend GDP (H = 2, k = 2); (d) the ratio lagged one year; five-year blocks 1986–1990 to 2001–2004 (to 2021–2023 in the extension), log GDP per capita at the end of the block, other variables averaged; (e1)–(e3) the ratio as block mean, first year and last year of the previous block. Fixed effects: country fixed effects, standard errors clustered by country. System GMM: one-step Blundell–Bond, robust standard errors, all regressors endogenous except population growth, instruments lags 2–4 of log GDP per capita and all available lags (2+) of the other endogenous variables, uncollapsed, as in the original (annual, 1986–2004, measure (a): `ni' instruments, AR(2) p = `a2'). 95% confidence intervals in brackets; stars from the same standard errors. Panel C: differences between coefficients in a stacked model with country × measure fixed effects, wild cluster bootstrap by country (Webb weights, 9,999 replications), bootstrap 95% CI. Differences from the original: current WDI vintage (constant 2015 USD), no foreign-asset measures, and the published five-year coefficient is not smaller than the annual one in absolute value but loses significance. Results with trade openness (their column 4) in the replication files. Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")

* Figura S5
use "$RINT/mc_res.dta", clear
keep if spec == "c1" & est != "diff"
gen str40 lab = ""
gen ord = .
local i = 0
foreach m in a b c d m t p {
    local ++i
    replace ord = 8 - `i' if meas == "`m'"
}
replace lab = cond(meas == "a", "(a) Same year", cond(meas == "b", "(b) Placebo numerator", cond(meas == "c", "(c) % of trend GDP", ///
    cond(meas == "d", "(d) Lagged", cond(meas == "m", "(e1) 5-year: period mean", cond(meas == "t", "(e2) 5-year: t{sub:p}", "(e3) 5-year: t{sub:p} − 1"))))))
gen pos = ord + cond(est == "fe", 0.12, -0.12) + cond(per == "8623", -0.06, 0.06) * 0
twoway (rcap lo hi pos if est == "fe" & per == "8604", horizontal lcolor(black)) (scatter pos b if est == "fe" & per == "8604", msymbol(O) mcolor(black) msize(small)) ///
       (rcap lo hi pos if est == "gmm" & per == "8604", horizontal lcolor(gs8)) (scatter pos b if est == "gmm" & per == "8604", msymbol(D) mcolor(gs8) msize(small)), ///
       $GOPT xline(0, lcolor(gs10) lpattern(shortdash)) ///
       ylabel(7 "(a) Same year" 6 "(b) Placebo numerator" 5 "(c) % of trend GDP (Hamilton)" 4 "(d) Lagged one year" 3 "(e1) Five-year: period mean" ///
              2 "(e2) Five-year: t{sub:p}" 1 "(e3) Five-year: t{sub:p} − 1", angle(0) labsize(8pt) nogrid) ytitle("") ///
       xtitle("Coefficient on log government size, 1986–2004 (95% CI)", size(8pt)) ///
       legend(order(2 "Fixed effects" 4 "System GMM") rows(1) pos(6) size(8pt))
rv_fig FigS5_mollick_cabral, width(190) height(100)
log close
