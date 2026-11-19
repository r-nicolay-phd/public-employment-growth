* 02_limpeza_wdi.do -- WDI, WGI, classificacao historica de renda e universo de paises
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/build/00_setup.do"
log using "$LOG/02_limpeza_wdi.log", replace text

* ---------------------------------------------------------------- universo de paises
import delimited "$RAW/wdi/wdi_paises.csv", clear varnames(1) encoding(utf8) stringcols(_all)
replace region = strtrim(region)
gen byte aggregate = region == "Aggregates"
count if aggregate
di "Agregados regionais e de renda na lista do Banco Mundial: " r(N)
* territorios dependentes cujas contas fiscais integram as de outro Estado (ver docs/DECISOES.md, D10)
gen byte territory = inlist(iso3, "ABW", "ASM", "BMU", "CHI", "CUW", "CYM", "FRO", "GIB", "GRL") | ///
                     inlist(iso3, "GUM", "IMN", "MAF", "MNP", "NCL", "PRI", "PYF", "SXM", "TCA") | ///
                     inlist(iso3, "VGB", "VIR")
rename (name income) (country wb_income_current)
keep iso3 country region wb_income_current aggregate territory
save "$INTERIM/paises.dta", replace

* ---------------------------------------------------------------- WDI
import delimited "$RAW/wdi/wdi.csv", clear varnames(1) case(preserve) encoding(utf8)
fixnames
rename (NY_GDP_PCAP_KD NY_GDP_PCAP_KD_ZG NY_GDP_MKTP_KD NY_GDP_MKTP_CN NY_GDP_DEFL_ZS ///
        NE_GDI_FTOT_ZS NE_GDI_FPRV_ZS FP_CPI_TOTL_ZG NY_GDP_DEFL_KD_ZG NE_TRD_GNFS_ZS ///
        SP_POP_TOTL SP_POP_GROW NE_CON_GOVT_ZS NY_GDP_TOTL_RT_ZS SP_POP_DPND TT_PRI_MRCH_XD_WD ///
        GC_XPN_COMP_ZS GC_XPN_TOTL_GD_ZS GC_REV_XGRT_GD_ZS SL_TLF_TOTL_IN SL_UEM_TOTL_ZS ///
        SL_EMP_WORK_ZS SL_EMP_TOTL_SP_ZS SE_SEC_ENRR) ///
       (gdppc gdppc_growth gdp_real gdp_nom_lcu gdp_defl inv_gdp privinv_wdi infl_cpi infl_defl ///
        trade_gdp pop popg govcons_gdp natres_rents dependency tot_wdi ///
        cg_comp_share cg_exp_gdp cg_rev_gdp labforce unemp wage_workers emp_pop secenr)
drop country
* folha do governo central como na dissertacao (produto de dois indicadores do WDI)
gen wagebill_cg_wdi = cg_comp_share * cg_exp_gdp / 100
* inflacao: IPC; deflator do PIB onde o IPC falta (marcado)
gen infl = infl_cpi
gen byte infl_from_defl = missing(infl_cpi) & !missing(infl_defl)
replace infl = infl_defl if infl_from_defl
* emprego total (mil) = forca de trabalho x (1 - desemprego)
gen emp_wdi = labforce * (1 - unemp / 100) / 1000
label var gdppc "GDP per capita (constant 2015 USD)"
label var gdppc_growth "GDP per capita growth (%)"
label var wagebill_cg_wdi "Central government compensation of employees (% of GDP), WDI"
compress
save "$INTERIM/wdi.dta", replace

* ---------------------------------------------------------------- WGI
import delimited "$RAW/wgi/wgi.csv", clear varnames(1) case(lower) encoding(utf8)
fixnames, lower
rename (gov_wgi_ge_est gov_wgi_rq_est gov_wgi_rl_est gov_wgi_cc_est gov_wgi_va_est gov_wgi_pv_est) ///
       (wgi_ge wgi_rq wgi_rl wgi_cc wgi_va wgi_pv)
drop country
keep if year >= 1996
* o WGI nao foi publicado para 1997, 1999 e 2001: interpolacao linear, marcada
fillin iso3 year
drop _fillin
encode iso3, gen(_id)
xtset _id year
gen byte wgi_interp = inlist(year, 1997, 1999, 2001)
foreach v in ge rq rl cc va pv {
    by _id: ipolate wgi_`v' year, gen(_tmp)
    replace wgi_`v' = _tmp if wgi_interp & missing(wgi_`v')
    drop _tmp
}
replace wgi_interp = 0 if missing(wgi_ge)
drop _id
save "$INTERIM/wgi.dta", replace

* ---------------------------------------------------------------- grupo de renda historico
import delimited "$RAW/income_hist/OGHIST_country_analytical_history.csv", clear varnames(nonames) stringcols(_all) encoding(utf8)
* linha 6 traz o ano dos dados (calendario); paises comecam na linha 12
local base = 1996
local col ""
local lastv v`c(k)'
foreach v of varlist v3-`lastv' {
    if strtrim(`v'[6]) == "`base'" local col `v'
}
assert "`col'" != ""
gen row = _n
keep if row >= 12 & strlen(strtrim(v1)) == 3
rename v1 iso3
* ano-base fixo: classificacao com dados de 1996; se ausente, a primeira disponivel depois
gen income0 = strtrim(`col')
local after 0
foreach v of varlist v3-`lastv' {
    if "`v'" == "`col'" local after 1
    if `after' replace income0 = strtrim(`v') if inlist(income0, "", "..")
}
replace income0 = "" if income0 == ".."
replace income0 = "LM" if income0 == "LM*"
gen byte income_grp = 1 if income0 == "L"
replace income_grp = 2 if income0 == "LM"
replace income_grp = 3 if income0 == "UM"
replace income_grp = 4 if income0 == "H"
label define inc 1 "Low income" 2 "Lower middle income" 3 "Upper middle income" 4 "High income"
label values income_grp inc
tab income0, missing
keep iso3 income_grp
save "$INTERIM/renda_hist.dta", replace

log close
