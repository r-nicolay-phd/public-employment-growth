* L1_frequencia_instituicoes.do -- Extensao L1 (lacuna 1 do Consensus, out. 2026)
* Pergunta: a divergencia entre paineis anuais (instituicoes AMPLIFICAM o custo do tamanho do governo;
* Mollick e Vianna, 2023) e medias de cinco anos (instituicoes ATENUAM; Oto-Peralias e Romero-Avila, 2013;
* Afonso e Jalles, 2016) vem do vies do denominador?
* Desenho: o mesmo do bloco D4 (08_dinamica.do), com o tamanho do governo interagido com a qualidade
* institucional, trocando so a medida do tamanho do governo:
*   anual: razao contemporanea, % do PIB tendencial (HP e Hamilton), defasada um ano;
*   cinco anos: media do periodo contra valor no primeiro ano.
* Tamanho do governo: consumo final do governo geral (WDI, NE.CON.GOVT.ZS) e despesa total do governo geral (GFS).
* Instituicoes: media dos seis indicadores do WGI, centrada na media da amostra de estimacao.
* Saidas isoladas em output/extensoes/ (nao altera nenhum arquivo do pipeline principal).
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
global TAB "$ROOT/output/extensoes/tables"
global FIG "$ROOT/output/extensoes/figures"
global LOG "$ROOT/output/extensoes/logs"
capture mkdir "$ROOT/output/extensoes"
capture mkdir "$TAB"
capture mkdir "$FIG"
capture mkdir "$LOG"
capture mkdir "$LOG/captions"
log using "$LOG/L1_frequencia_instituicoes.log", replace text

* ---------------------------------------------------------------- painel anual: tendencias e medidas
use "$FINAL/painel_anual.dta", clear
xtset id year
* tendencia de Hamilton (h = 2, p = 2), como em 03_painel.do (la ela e descartada depois de usada)
sort id year
gen lnY_ham = .
levelsof id, local(ids)
foreach i of local ids {
    capture quietly regress lnY L2.lnY L3.lnY if id == `i'
    if !_rc & e(N) >= 10 {
        quietly predict double _h if id == `i' & e(sample), xb
        quietly replace lnY_ham = _h if id == `i'
        drop _h
    }
}
egen inst = rowmean(wgi_ge wgi_rq wgi_rl wgi_cc wgi_va wgi_pv)
label var inst "Institutional quality (mean of six WGI indicators)"
foreach G in govcons_gdp exp_gdp {
    gen `G'_c = `G'
    gen `G'_hp = `G' * exp(lnY - lnY_hp)
    gen `G'_ham = `G' * exp(lnY - lnY_ham)
    gen `G'_lag = L.`G'
}
keep if micro == 0
tempfile A
save `A'

* ---------------------------------------------------------------- estimacao anual (desenho de D4)
local Xa "L.g L.lny hc inv open infl popg ctot_g"
tempname P
postfile `P' str12 G str8 m double(b se bi sei me10 se10 me90 se90 q10 q90) long(N nc) using "$ROOT/output/extensoes/l1_resultados.dta", replace
foreach G in govcons_gdp exp_gdp {
    use `A', clear
    keep if inrange(year, 1996, 2023)
    xtset id year
    * mesma amostra para as quatro medidas anuais
    gen byte s4 = !missing(`G'_c, `G'_hp, `G'_ham, `G'_lag, inst, g, L.g, L.lny, hc, inv, open, infl, popg, ctot_g)
    quietly summ inst if s4
    gen instc = inst - r(mean)
    _pctile instc if s4, p(10 90)
    local q10 = r(r1)
    local q90 = r(r2)
    foreach m in c hp ham lag {
        capture drop GV GXI
        gen GV = `G'_`m'
        gen GXI = GV * instc
        xtscc g GV instc GXI `Xa' i.year if s4, fe
        local df = e(df_r)
        quietly lincom GV + `q10' * GXI
        local me10 = r(estimate)
        local se10 = r(se)
        quietly lincom GV + `q90' * GXI
        post `P' ("`G'") ("`m'") (_b[GV]) (_se[GV]) (_b[GXI]) (_se[GXI]) (`me10') (`se10') (r(estimate)) (r(se)) ///
            (`q10') (`q90') (e(N)) (e(N_g))
        estimates store A_`G'_`m'
    }
}

* ---------------------------------------------------------------- medias de cinco anos
use `A', clear
keep if year >= 1979
gen period = floor((year - 1979) / 5)
gen year0 = 1979 + 5 * period
foreach G in govcons_gdp exp_gdp {
    gen `G'_0 = `G' if year == year0
}
* instituicoes: primeiro valor disponivel no periodo (o WGI comeca em 1996)
gen _t = year if !missing(inst)
bysort id period: egen _tmin = min(_t)
gen inst_0 = inst if year == _tmin
collapse (mean) govcons_gdp_m = govcons_gdp exp_gdp_m = exp_gdp (firstnm) govcons_gdp_0 exp_gdp_0 inst_0, by(id period)
tempfile M
save `M'
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
merge 1:1 id period using `M', keep(master match) nogen
xtset id period
foreach G in govcons_gdp exp_gdp {
    capture drop s5 instc
    gen byte s5 = !missing(`G'_m, `G'_0, inst_0, g, lny0, hc0, inv, open, infl, popg, ctot_g)
    quietly summ inst_0 if s5
    gen instc = inst_0 - r(mean)
    _pctile instc if s5, p(10 90)
    local q10 = r(r1)
    local q90 = r(r2)
    foreach m in m 0 {
        capture drop GV GXI
        gen GV = `G'_`m'
        gen GXI = GV * instc
        reghdfe g GV instc GXI lny0 hc0 inv open infl popg ctot_g if s5, absorb(id period) vce(cluster id)
        quietly lincom GV + `q10' * GXI
        local me10 = r(estimate)
        local se10 = r(se)
        quietly lincom GV + `q90' * GXI
        local mm = cond("`m'" == "m", "mean5", "init5")
        post `P' ("`G'") ("`mm'") (_b[GV]) (_se[GV]) (_b[GXI]) (_se[GXI]) (`me10') (`se10') (r(estimate)) (r(se)) ///
            (`q10') (`q90') (e(N)) (e(N_clust))
        estimates store F_`G'_`m'
    }
}
postclose `P'

* ---------------------------------------------------------------- Tabela L1
use "$ROOT/output/extensoes/l1_resultados.dta", clear
list G m b se bi sei me10 me90 N nc, noobs sepby(G)
local stars "* p<0.10, ** p<0.05, *** p<0.01."
tab_new, ncol(6) head1("(1)" "(2)" "(3)" "(4)" "(5)" "(6)") ///
    head2("Annual: contemporaneous" "Annual: % of trend GDP (HP)" "Annual: % of trend GDP (Hamilton)" "Annual: lagged one year" "5-year: period mean" "5-year: first year")
local orderm "c hp ham lag mean5 init5"
foreach G in govcons_gdp exp_gdp {
    local ttl = cond("`G'" == "govcons_gdp", "Panel A. Government consumption (% of GDP, WDI)", "Panel B. General government total expenditure (% of GDP, IMF GFS)")
    tab_row "`ttl'" "" "" "" "" "" ""
    foreach row in b bi me10 me90 {
        local lab = cond("`row'" == "b", "Government size (at mean institutions)", cond("`row'" == "bi", "Government size x institutional quality", cond("`row'" == "me10", "Government size, 10th pct. of institutions", "Government size, 90th pct. of institutions")))
        local sev = cond("`row'" == "b", "se", cond("`row'" == "bi", "sei", cond("`row'" == "me10", "se10", "se90")))
        local rb ""
        local rs ""
        foreach m of local orderm {
            quietly summ `row' if G == "`G'" & m == "`m'"
            local bb = r(mean)
            quietly summ `sev' if G == "`G'" & m == "`m'"
            local ss = r(mean)
            quietly summ N if G == "`G'" & m == "`m'"
            local p = 2 * normal(-abs(`bb' / `ss'))
            local st = cond(`p' < 0.01, "***", cond(`p' < 0.05, "**", cond(`p' < 0.10, "*", "")))
            local x : display %6.3f `bb'
            local rb `"`rb' "`=strtrim("`x'")'`st'""'
            local x : display %6.3f `ss'
            local rs `"`rs' "(`=strtrim("`x'")')""'
        }
        tab_row "`lab'" `rb'
        tab_row "" `rs'
    }
    local rn ""
    local rc ""
    foreach m of local orderm {
        quietly summ N if G == "`G'" & m == "`m'"
        local x : display %9.0fc r(mean)
        local rn `"`rn' "`=strtrim("`x'")'""'
        quietly summ nc if G == "`G'" & m == "`m'"
        local rc `"`rc' "`=r(mean)'""'
    }
    tab_row "Observations" `rn'
    tab_row "Countries" `rc'
    if "`G'" == "govcons_gdp" tab_mid
}
tab_out TableL1_frequency_institutions, title("Table L1. Government size, institutions and growth: annual versus five-year measures") landscape ///
    notes("Each column interacts a measure of government size with institutional quality (mean of the six WGI indicators, centred at the sample mean), so the first row is the effect of government size at average institutions. Columns 1-4: annual panel 1996-2023, same sample in each panel, country and year fixed effects, lagged growth and the controls of Table A7, Driscoll-Kraay standard errors; government size measured as the contemporaneous ratio, as a share of trend GDP (HP filter, lambda = 6.25; Hamilton filter), or lagged one year. Columns 5-6: five-year averages, country and period fixed effects, controls of Table 2, standard errors clustered by country; government size measured as the period mean or in the first year of the period, institutions in the first available year of the period. A negative interaction means that better institutions make government size more harmful (the result of Mollick and Vianna, 2023); a positive one means they mitigate it. `stars'")


* ---------------------------------------------------------------- Tabela L1b: robustez (consumo do governo)
* razao contemporanea contra defasada, em quatro variantes: base; janela de Mollick e Vianna (1996-2019);
* so a eficacia governamental do WGI; controles simples, sem crescimento defasado, capital humano e termos de troca
tempname R
postfile `R' str60 v double(bc sc bl sl) long(N nc) using "$ROOT/output/extensoes/l1b_resultados.dta", replace
local k = 0
foreach v in base mv2019 ge simple {
    local ++k
    use `A', clear
    keep if inrange(year, 1996, cond("`v'" == "mv2019", 2019, 2023))
    xtset id year
    if "`v'" == "ge" replace inst = wgi_ge
    local X "L.g L.lny hc inv open infl popg ctot_g"
    if "`v'" == "simple" local X "L.lny inv open infl popg"
    local Xs : subinstr local X "L.g" "g", all
    local Xs : subinstr local Xs "L.lny" "lny", all
    gen byte s = !missing(govcons_gdp_c, govcons_gdp_lag, inst, g, L.g, L.lny, hc, inv, open, infl, popg, ctot_g)
    quietly summ inst if s
    gen instc = inst - r(mean)
    foreach m in c lag {
        capture drop GV GXI
        gen GV = govcons_gdp_`m'
        gen GXI = GV * instc
        xtscc g GV instc GXI `X' i.year if s, fe
        local b`m' = _b[GXI]
        local s`m' = _se[GXI]
    }
    local lab : word `k' of "Baseline (Table L1, Panel A)" "Window 1996-2019 (Mollick and Vianna)" "Institutions: WGI government effectiveness" "Simple controls, no lagged growth"
    post `R' ("`lab'") (`bc') (`sc') (`blag') (`slag') (e(N)) (e(N_g))
}
postclose `R'
use "$ROOT/output/extensoes/l1b_resultados.dta", clear
list, noobs
local stars "* p<0.10, ** p<0.05, *** p<0.01."
tab_new, ncol(4) head1("Interaction: contemporaneous ratio" "Interaction: lagged one year" "Observations" "Countries")
forvalues j = 1/`=_N' {
    local cells ""
    foreach w in c l {
        local bb = b`w'[`j']
        local ss = s`w'[`j']
        local p = 2 * normal(-abs(`bb' / `ss'))
        local st = cond(`p' < 0.01, "***", cond(`p' < 0.05, "**", cond(`p' < 0.10, "*", "")))
        local x : display %6.3f `bb'
        local y : display %6.3f `ss'
        local cells `"`cells' "`=strtrim("`x'")'`st' (`=strtrim("`y'")')""'
    }
    local x : display %9.0fc N[`j']
    tab_row "`=v[`j']'" `cells' "`=strtrim("`x'")'" "`=nc[`j']'"
}
tab_out TableL1b_frequency_robustness, title("Table L1b. Government consumption x institutions: contemporaneous versus lagged measure, robustness") ///
    notes("Coefficient (standard error) of the interaction between government consumption (% of GDP, WDI) and institutional quality, with government consumption measured in the same year as growth or lagged one year. Annual panel, country and year fixed effects, Driscoll-Kraay standard errors; the two columns of each row use the same sample. Institutions: mean of the six WGI indicators except in row 3. Row 4 uses only lagged log GDP per capita, investment, openness, inflation and population growth as controls. `stars'")

use "$ROOT/output/extensoes/l1_resultados.dta", clear
local orderm "c hp ham lag mean5 init5"
* ---------------------------------------------------------------- Figura L1: interacao por medida
gen ord = .
local k = 0
foreach m of local orderm {
    local ++k
    replace ord = `k' if m == "`m'"
}
gen lo = bi - 1.96 * sei
gen hi = bi + 1.96 * sei
gen y = 7 - ord + cond(G == "govcons_gdp", 0.15, -0.15)
twoway (rcap lo hi y if G == "govcons_gdp", horizontal lcolor("$C2")) (scatter y bi if G == "govcons_gdp", mcolor("$C2") msymbol(O)) ///
    (rcap lo hi y if G == "exp_gdp", horizontal lcolor("$C3")) (scatter y bi if G == "exp_gdp", mcolor("$C3") msymbol(D)), ///
    $GOPT xline(0, lcolor(gs10) lpattern(dash)) ///
    ylabel(6 "Annual: contemporaneous" 5 "Annual: % of trend GDP (HP)" 4 "Annual: % of trend GDP (Hamilton)" ///
    3 "Annual: lagged one year" 2 "5-year: period mean" 1 "5-year: first year of period", labsize(7pt) nogrid angle(horizontal) noticks) ///
    ytitle("") xtitle("Interaction: government size x institutional quality (95% CI)", size(8pt)) xlabel(, labsize(7pt)) ///
    legend(order(2 "Government consumption (WDI)" 4 "Total expenditure (GFS)") rows(1) size(7pt) pos(6))
fig_export FigureL1_frequency_institutions, width(170) height(90)

log close
