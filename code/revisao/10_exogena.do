* 10_exogena.do -- bloco 4.9 do plano: variacao exogena da folha [P1]
* Consolidacoes narrativas de Alesina, Favero e Giavazzi (2019): componente "Spending - Salaries" dos planos de
* ajuste, 16 paises da OCDE, 1978-2014; choque = medidas nao antecipadas + anunciadas implementadas no ano
* (% do PIB de t-1; positivo = corte). MONA e erros de previsao (OECD EO em safras): nao executados (dado
* indisponivel; ver docs/DOWNLOADS_MANUAIS.md).
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/revisao/00_setup.do"
capture log close
log using "$RLOG/10_exogena.log", replace text

use "$RINT/anual_rv.dta", clear
keep if inrange(year, 1975, 2023)
xtset id year
gen byte afgc = !missing(afg_sal)
bysort id: egen inafg = max(afgc)
keep if inafg
replace afg_sal = 0 if missing(afg_sal) & inrange(year, 1978, 2014)
gen afg_nonsal = afg_spend - afg_sal
* periodo do choque
gen byte pAFG = inrange(year, 1978, 2014)
count if pAFG & afg_sal != 0
rv_kv afg_nonzero `r(N)'
quietly levelsof iso3 if pAFG, local(cs)
rv_kv afg_countries `: word count `cs''
summ afg_sal if pAFG & afg_sal != 0

tempname Q
postfile `Q' str6 out int h double(b se lo hi p pboot) long(N nc) using "$RINT/exogena_lp.dta", replace
foreach out in y100 ipriv {
    forvalues hh = 0/6 {
        tempvar dy
        quietly gen double `dy' = F`hh'.`out' - L.`out'
        quietly xtscc `dy' afg_sal afg_nonsal afg_tax L(1/2).g i.year if pAFG, fe lag($DKLAG)
        local b = _b[afg_sal]
        local se = _se[afg_sal]
        local df = e(df_r)
        local N = e(N)
        local nc = e(N_g)
        local pb = .
        if `hh' == 4 {
            * exploratorio: wild cluster bootstrap por pais (16 clusters) no mesmo modelo com EF de pais
            quietly reghdfe `dy' afg_sal afg_nonsal afg_tax L(1/2).g i.year if pAFG, absorb(id) vce(cluster id)
            capture rv_boot afg_sal
            if !_rc local pb = r(p)
        }
        post `Q' ("`out'") (`hh') (`b') (`se') (`b' - invttail(`df', 0.025) * `se') (`b' + invttail(`df', 0.025) * `se') ///
            (2 * ttail(`df', abs(`b' / `se'))) (`pb') (`N') (`nc')
        if `hh' == 4 {
            rv_kv afg_`out'_h4_b `=string(`b', "%9.4f")'
            rv_kv afg_`out'_h4_p `=string(2 * ttail(`df', abs(`b' / `se')), "%9.4f")'
            rv_kv afg_`out'_h4_pboot `=string(`pb', "%9.4f")'
            rv_kv afg_`out'_h4_N `N'
        }
        drop `dy'
    }
}
postclose `Q'

* primeiro estagio: variacao real da folha (GFS, governo geral) sobre o corte narrativo de folha
reghdfe d_wagebill_real afg_sal afg_nonsal afg_tax L(1/2).g i.year if pAFG, absorb(id) vce(cluster id)
estimates store FS_afg
local Feff = (_b[afg_sal] / _se[afg_sal])^2
rv_kv afg_fs_b `=string(_b[afg_sal], "%9.4f")'
rv_kv afg_fs_p `=string(2 * ttail(e(df_r), abs(_b[afg_sal] / _se[afg_sal])), "%9.4f")'
rv_kv afg_fs_Feff `=string(`Feff', "%9.2f")'
rv_kv afg_fs_N `e(N)'
rv_kv afg_fs_nc `e(N_clust)'
estadd scalar Feff = `Feff'
estimates store FS_afg

* =====================================================================================
* Tabela e figura suplementares: variacao exogena
* =====================================================================================
use "$RINT/exogena_lp.dta", clear
list, noobs sepby(out)
rv_new, ncol(7) head1("h = 0" "h = 1" "h = 2" "h = 3" "h = 4" "h = 5" "h = 6")
foreach out in y100 ipriv {
    local cb ""
    local cs ""
    forvalues hh = 0/6 {
        quietly summ b if out == "`out'" & h == `hh'
        local b = r(mean)
        quietly summ p if out == "`out'" & h == `hh'
        rv_fmt `b' %12.3f `=r(mean)'
        local cb `"`cb' "`r(s)'""'
        quietly summ se if out == "`out'" & h == `hh'
        rv_fmt `=r(mean)' %12.3f
        local cs `"`cs' "(`r(s)')""'
    }
    local lab = cond("`out'" == "y100", "GDP per capita (100 × log)", "Private investment (% of GDP)")
    rv_row "`lab'" `cb'
    rv_row "" `cs'
    quietly summ pboot if out == "`out'" & h == 4
    rv_row "Wild cluster bootstrap p (h = 4, exploratory)" "" "" "" "" "`=string(r(mean), "%5.3f")'" "" ""
    quietly summ N if out == "`out'" & h == 0
    local n0 = r(mean)
    quietly summ N if out == "`out'" & h == 6
    rv_row "Observations (h = 0 / h = 6)" "`=string(`n0', "%9.0fc")'" "" "" "" "" "" "`=string(r(mean), "%9.0fc")'"
    rv_mid
}
estimates restore FS_afg
rv_row "First stage: real wage bill change on the narrative wage cut" "`=string(_b[afg_sal], "%6.3f")' (`=string(_se[afg_sal], "%6.3f")')" "" "" "" "" "" ""
rv_row "Effective F; observations; countries" "`=string(e(Feff), "%6.2f")'; `e(N)'; `e(N_clust)'" "" "" "" "" "" ""
rv_mid
rv_row "IMF conditionality (MONA, 2002–)" "Not executed: download blocked" "" "" "" "" "" ""
rv_row "Real-time forecast errors (OECD EO vintages)" "Not executed: no public vintage series of the wage bill" "" "" "" "" "" ""
rv_out TabS_exogenous, landscape ///
    title("Table S10. Narrative wage-bill consolidations: local projections and first stage") ///
    notes("Shock: wage-bill measures (Spending – Salaries) of the fiscal adjustment plans in Alesina, Favero and Giavazzi (2019), sum of unanticipated measures and of announced measures implemented in the year, % of previous-year GDP; positive values are cuts. 16 OECD countries, shocks 1978–2014. Cumulative change of the outcome from t − 1 to t + h on the shock, controlling for the non-wage spending and tax measures of the same plans and two lags of growth; country and year fixed effects; Driscoll-Kraay standard errors (maximum lag 3). With 16 countries, the wild cluster bootstrap p-value at h = 4 is exploratory. First stage: real change in the general government wage bill (IMF GFS, % of lagged GDP) on the same shock and controls, standard errors clustered by country; with one instrument the effective F equals the squared cluster-robust t statistic. * p<0.10, ** p<0.05, *** p<0.01.")

use "$RINT/exogena_lp.dta", clear
sort out h
twoway (rarea lo hi h if out == "y100", fcolor(gs14) lcolor(gs8) lpattern(dash) lwidth(vthin)) ///
       (connected b h if out == "y100", lcolor(black) mcolor(black) msymbol(O) msize(small)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(shortdash)) xlabel(0(1)6, labsize(8pt)) ylabel(, format(%3.1f) labsize(8pt) nogrid angle(horizontal)) ///
       legend(off) xtitle("Years after the shock", size(8pt)) ytitle("Cumulative response of GDP per capita (100 × log, %)", size(7.5pt)) ///
       title("(a) GDP per capita", size(8.5pt) color(black) pos(11)) name(e1, replace) nodraw
twoway (rarea lo hi h if out == "ipriv", fcolor(gs14) lcolor(gs8) lpattern(dash) lwidth(vthin)) ///
       (connected b h if out == "ipriv", lcolor(black) mcolor(black) msymbol(D) msize(small)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(shortdash)) xlabel(0(1)6, labsize(8pt)) ylabel(, format(%3.1f) labsize(8pt) nogrid angle(horizontal)) ///
       legend(off) xtitle("Years after the shock", size(8pt)) ytitle("Change in private investment (p.p. of GDP)", size(7.5pt)) ///
       title("(b) Private investment", size(8.5pt) color(black) pos(11)) name(e2, replace) nodraw
graph combine e1 e2, cols(2) graphregion(color(white)) imargin(small)
rv_fig FigS_exogenous, width(190) height(85)

log close
