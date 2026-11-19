* 07_estrutural.do -- bloco 4.6 do plano: explicacoes estruturais e de crise [P11]
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
capture log close
log using "$RLOG/07_estrutural.log", replace text

global XP "lny0 hc_m1 inv_m1 open_m1 infl_m1 popg_m1 ctot_g_m1"

* =====================================================================================
* A. Especificacao preferida (T3) com cada alteracao
* =====================================================================================
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
merge 1:1 id period using "$RINT/amostra_T3.dta", keep(master match) nogen
* painel balanceado: paises presentes em todos os periodos da amostra de T3
bysort id: egen nT3 = total(S5_T3)
quietly summ nT3
gen byte balanced = nT3 == r(max)
gen byte excl_euro = euro_0813_p == 1 & year0 == 2009
tempname P
postfile `P' str12 spec str70 lab double(b se p) long(N nc) using "$RINT/estrutural.dta", replace
capture program drop est5
program define est5
    args P spec lab cond extra absorb
    if "`absorb'" == "" local absorb "id"
    reghdfe g wb_m1 $XP `extra' i.period if `cond', absorb(`absorb') vce(cluster id)
    estimates store S_`spec'
    post `P' ("`spec'") ("`lab'") (_b[wb_m1]) (_se[wb_m1]) (2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1]))) (e(N)) (e(N_clust))
    rv_kv str_`spec'_b `=string(_b[wb_m1], "%12.8f")'
    rv_kv str_`spec'_p `=string(2 * ttail(e(df_r), abs(_b[wb_m1] / _se[wb_m1])), "%9.4f")'
    rv_kv str_`spec'_N `e(N)'
end
est5 `P' base "Preferred specification (T3)" "1" "" ""
est5 `P' trend "1. Country-specific linear trends" "1" "" "id id#c.period"
est5 `P' regper "2. Region × period fixed effects" "1" "" "id region_id#period"
est5 `P' oldage "3. Old-age dependency ratio (t_p − 1)" "1" "oldage_dep_m1" ""
est5 `P' healthedu "4a. Health and education spending share, WDI substitute (t_p − 1)" "1" "health_edu_share_m1" ""
est5 `P' healthcofog "4b. Health and education spending share, IMF COFOG (t_p − 1)" "1" "health_edu_cofog_m1" ""
est5 `P' noeuro "5. Excluding euro-area members in 2009–2013" "!excl_euro" "" ""
est5 `P' post94 "6. Periods from 1994–1998 onwards" "year0 >= 1994" "" ""
est5 `P' balanced "8a. Balanced panel (countries in every period of T3)" "balanced" "" ""
est5 `P' early2 "8b. Indicator of each country's first two periods" "1" "early2" ""
est5 `P' crisis "9. Systemic banking crisis in the period (Laeven–Valencia)" "1" "crisis_p" ""
est5 `P' all "All together (1–6, 8b, 9)" "!excl_euro & year0 >= 1994" "oldage_dep_m1 health_edu_share_m1 early2 crisis_p" "id id#c.period region_id#period"
postclose `P'

* =====================================================================================
* B. Projecoes locais por regime de merito (D3 do draft 7) com cada alteracao
* =====================================================================================
use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1990, 2023)
xtset id year
gen byte smp = !missing(d_wagebill_real, L.d_wagebill_real, L2.d_wagebill_real, L.g, L2.g) & inrange(year, 1996, 2023)
quietly summ merit_l1 if smp, detail
local med = r(p50)
gen byte mhi = merit_l1 > `med' if !missing(merit_l1)
gen shi = d_wagebill_real * (mhi == 1) if !missing(mhi)
gen slo = d_wagebill_real * (mhi == 0) if !missing(mhi)
gen byte excl_euro = euro & inrange(year, 2008, 2013)
bysort id: egen nyr = total(smp & !missing(mhi))
quietly summ nyr
gen byte balanced = nyr == r(max)
gen oldage_l1 = L.oldage_dep
gen healthedu_l1 = L.health_edu_share
gen healthcofog_l1 = L.health_edu_cofog
tempname Q
postfile `Q' str12 spec int h double(bhi sehi blo selo pdiff) long(N nc nep_hi nc_hi) using "$RINT/estrutural_lp.dta", replace
foreach spec in base trend regyear oldage healthedu healthcofog noeuro balanced crisis all {
    local extra ""
    local cond "inrange(year, 1996, 2023)"
    if "`spec'" == "trend" local extra "i.id#c.year"
    if "`spec'" == "regyear" local extra "i.region_id#i.year"
    if "`spec'" == "oldage" local extra "oldage_l1"
    if "`spec'" == "healthedu" local extra "healthedu_l1"
    if "`spec'" == "healthcofog" local extra "healthcofog_l1"
    if "`spec'" == "noeuro" local cond "`cond' & !excl_euro"
    if "`spec'" == "balanced" local cond "`cond' & balanced"
    if "`spec'" == "crisis" local extra "crisis_bank"
    if "`spec'" == "all" {
        local extra "i.id#c.year i.region_id#i.year oldage_l1 healthedu_l1 crisis_bank"
        local cond "`cond' & !excl_euro"
    }
    forvalues hh = 0/6 {
        tempvar dy
        quietly gen double `dy' = F`hh'.y100 - L.y100
        capture quietly xtscc `dy' shi slo i.mhi L(1/2).d_wagebill_real L(1/2).g `extra' i.year if `cond', fe lag($DKLAG)
        if _rc {
            post `Q' ("`spec'") (`hh') (.) (.) (.) (.) (.) (.) (.) (.) (.)
            drop `dy'
            continue
        }
        quietly test shi = slo
        local pd = r(p)
        * episodios (pais-anos com choque diferente de zero) e paises no regime de merito alto
        quietly count if e(sample) & mhi == 1 & d_wagebill_real != 0
        local nep = r(N)
        tempvar tg
        quietly egen `tg' = tag(id) if e(sample) & mhi == 1
        quietly count if `tg' == 1
        local nch = r(N)
        post `Q' ("`spec'") (`hh') (_b[shi]) (_se[shi]) (_b[slo]) (_se[slo]) (`pd') (e(N)) (e(N_g)) (`nep') (`nch')
        drop `dy' `tg'
    }
}
postclose `Q'
use "$RINT/estrutural_lp.dta", clear
list if inlist(h, 4, 5), noobs sepby(spec)
foreach s in base all noeuro regyear {
    quietly summ bhi if spec == "`s'" & h == 5
    rv_kv lpm_`s'_h5_bhi `=string(r(mean), "%9.4f")'
    quietly summ pdiff if spec == "`s'" & h == 5
    rv_kv lpm_`s'_h5_pdiff `=string(r(mean), "%9.4f")'
    quietly summ nep_hi if spec == "`s'" & h == 5
    rv_kv lpm_`s'_h5_nep `=r(mean)'
    quietly summ nc_hi if spec == "`s'" & h == 5
    rv_kv lpm_`s'_h5_nc `=r(mean)'
}

* =====================================================================================
* Tabela suplementar: robustez estrutural
* =====================================================================================
use "$RINT/estrutural.dta", clear
gen ord = _n
tempfile T5
save `T5'
use "$RINT/estrutural_lp.dta", clear
keep if h == 5
rename (N nc) (N_lp nc_lp)
replace spec = "regper" if spec == "regyear"
merge 1:1 spec using `T5', nogen
sort ord
rv_new, ncol(6) head1("Five-year panel: T3" "" "" "Local projections by merit regime, h = 5" "" "") ///
    head2("Wage bill, t_p − 1" "Obs." "Countries" "High merit" "p (high = low)" "Episodes / countries, high merit")
forvalues i = 1/`=_N' {
    if missing(ord[`i']) continue
    rv_fmt `=b[`i']' %12.3f `=p[`i']'
    local c1 "`r(s)'"
    rv_fmt `=se[`i']' %12.3f
    local c1 "`c1' (`r(s)')"
    rv_fmt `=N[`i']' %12.0fc
    local c2 "`r(s)'"
    local c3 = nc[`i']
    if !missing(bhi[`i']) {
        rv_fmt `=bhi[`i']' %12.3f `=2 * normal(-abs(bhi[`i'] / sehi[`i']))'
        local c4 "`r(s)'"
        rv_fmt `=pdiff[`i']' %12.3f
        local c5 "`r(s)'"
        local c6 "`=nep_hi[`i']' / `=nc_hi[`i']'"
    }
    else {
        local c4 "—"
        local c5 ""
        local c6 ""
    }
    rv_row "`=lab[`i']'" "`c1'" "`c2'" "`c3'" "`c4'" "`c5'" "`c6'"
    if `i' == 1 rv_mid
}
rv_row "7. GFSM transition years" "Not executed: change-of-manual metadata by country not available" "" "" "" "" ""
rv_row "9b. IMF programmes (MONA)" "Not executed: MONA download blocked" "" "" "" "" ""
rv_out TabS_structural, landscape ///
    title("Table S8. Structural and crisis explanations") ///
    notes("Columns 1–3: preferred specification of H1 (T3: five-year averages 1979–2023, wage bill in t_p − 1, predetermined controls, country and period fixed effects, standard errors clustered by country) with one change at a time; the last row combines all changes except the balanced-panel restriction. Columns 4–6: local projections of 100 × log GDP per capita at h = 5 on the real wage bill shock interacted with merit above the median in the year before the shock (conventional specification), annual panel 1996–2023, country and year fixed effects, two lags of the shock and of growth, Driscoll-Kraay standard errors (maximum lag 3); in the local projections, row 2 uses region × year fixed effects, row 5 drops euro-area members in 2008–2013, and there is no post-1994 variant because the annual panel starts in 1996. Episodes: country-years with a non-zero shock in the high-merit regime in the estimation sample at h = 5. Region: World Bank regions. Old-age dependency ratio from the WDI. Row 4a: government health and education spending from the WDI divided by GFS total expenditure, the substitute declared in the plan while the COFOG series were unavailable; row 4b: the planned measure, general government health (GF07) and education (GF09) spending as a share of total outlays from the IMF GFS COFOG database (downloaded on 13 November 2026); the combined row keeps the WDI measure. * p<0.10, ** p<0.05, *** p<0.01.")

* =====================================================================================
* Figura suplementar: coeficientes de T3 por alteracao
* =====================================================================================
use "$RINT/estrutural.dta", clear
gen ord = _N - _n + 1
gen lo = b - invttail(nc - 1, 0.025) * se
gen hi = b + invttail(nc - 1, 0.025) * se
local yl ""
forvalues i = 1/`=_N' {
    local yl `"`yl' `=ord[`i']' "`=lab[`i']'""'
}
twoway (rcap lo hi ord, horizontal lcolor(black)) (scatter ord b, msymbol(O) mcolor(black) msize(small)), ///
    $GOPT xline(0, lcolor(gs10) lpattern(shortdash)) ylabel(`yl', angle(0) labsize(7pt) nogrid) ///
    xlabel(, format(%3.1f) labsize(8pt)) ytitle("") legend(off) ///
    xtitle("Coefficient on the wage bill in t{sub:p} − 1 (95% CI)", size(8pt))
rv_fig FigS_structural, width(190) height(100)

log close
