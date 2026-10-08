* 02_limpeza_trabalho.do -- WWBI, ILOSTAT e Penn World Table
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/02_limpeza_trabalho.log", replace text

* ---------------------------------------------------------------- WWBI
import delimited "$RAW/wwbi/wwbi.csv", clear varnames(1) case(lower) encoding(utf8)
fixnames, lower
rename (bi_wag_totl_gd_zs bi_wag_totl_pb_zs bi_emp_totl_pb_zs bi_emp_pwrk_pb_zs bi_emp_frml_pb_zs ///
        bi_wag_prem_pb bi_wag_prem_pb_gp bi_wag_cprs_pb_zs bi_pwk_pubs_tt_ca_zs) ///
       (wwbi_wagebill_gdp wwbi_wagebill_exp wwbi_pubemp_total wwbi_pubemp_paid wwbi_pubemp_formal ///
        wwbi_prem_formal wwbi_prem_all wwbi_compression wwbi_tertiary)
drop country
* o WWBI publica participacoes como fracao (0-1) em algumas series; padroniza em %
foreach v in wwbi_pubemp_total wwbi_pubemp_paid wwbi_pubemp_formal wwbi_tertiary {
    quietly summ `v'
    if r(max) <= 1.0001 replace `v' = 100 * `v'
}
* premio: coeficiente log da dummy publica; convertido em % ((exp(b)-1)*100) so se estiver em log
quietly summ wwbi_prem_all
di "premio (todos os privados): media " r(mean) " min " r(min) " max " r(max)
label var wwbi_pubemp_total "Public employment (% of total employment), WWBI"
label var wwbi_prem_all "Public sector wage premium vs all private employees, WWBI"
label var wwbi_prem_formal "Public sector wage premium vs formal private employees, WWBI"
keep if year >= 1990
save "$INTERIM/wwbi.dta", replace

* ---------------------------------------------------------------- ILOSTAT
* varias fontes (pesquisas) por pais-ano: prioridade LFS > estimativas oficiais > outras; dentro da
* mesma classe, a fonte com mais anos no pais (serie mais longa e homogenea)
foreach f in EMP_PUBL_SEX_AGE_NB EMP_TEMP_SEX_AGE_NB EAR_PMTA_SEX_NB {
    import delimited "$RAW/ilostat/`f'.csv", clear varnames(1) case(lower) encoding(utf8) bindquote(strict)
    rename (ref_area time_period obs_value) (iso3 year value)
    keep if !missing(value) & freq == "A"
    capture confirm string variable year
    if !_rc {
        destring year, replace force
        drop if missing(year)
    }
    if "`f'" == "EAR_PMTA_SEX_NB" keep if unit_measure == "LC" | missing(unit_measure)
    gen byte prio = cond(substr(source, 1, 3) == "LFS", 1, cond(substr(source, 1, 2) == "OE", 2, 3))
    bysort iso3 source: gen nyrs = _N
    gsort iso3 year prio -nyrs source
    by iso3 year: keep if _n == 1
    gen str src_`f' = source
    keep iso3 year value src_`f'
    rename value v_`f'
    tempfile t_`f'
    save `t_`f''
}
use `t_EMP_TEMP_SEX_AGE_NB', clear
merge 1:1 iso3 year using `t_EMP_PUBL_SEX_AGE_NB', nogen
merge 1:1 iso3 year using `t_EAR_PMTA_SEX_NB', nogen
rename (v_EMP_TEMP_SEX_AGE_NB v_EMP_PUBL_SEX_AGE_NB v_EAR_PMTA_SEX_NB) (ilo_emp ilo_pubemp ilo_pubearn)
gen ilo_pubemp_share = 100 * ilo_pubemp / ilo_emp if src_EMP_PUBL == src_EMP_TEMP
label var ilo_pubemp_share "Public sector employment (% of total employment), ILOSTAT (same survey)"
label var ilo_pubearn "Average monthly earnings of public employees (local currency), ILOSTAT"
save "$INTERIM/ilostat.dta", replace

* ---------------------------------------------------------------- Penn World Table 11.0
use "$RAW/pwt/pwt110.dta", clear
rename countrycode iso3
keep iso3 year rgdpna rnna rtfpna hc emp avh labsh pop cgdpo
label var rtfpna "TFP at constant national prices (2021=1), PWT 11.0"
label var hc "Human capital index, PWT 11.0"
label var emp "Persons engaged (millions), PWT 11.0"
save "$INTERIM/pwt.dta", replace

log close
