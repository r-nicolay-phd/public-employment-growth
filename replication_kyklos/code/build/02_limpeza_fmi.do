* 02_limpeza_fmi.do -- FMI (GFS, ICSD, GDD, CTOT, FD) e Eurostat
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/build/00_setup.do"
log using "$LOG/02_limpeza_fmi.log", replace text

* ---------------------------------------------------------------- GFS, demonstrativo de operacoes
import delimited "$RAW/imf_gfs/gfs_soo.csv", clear varnames(1) case(lower) encoding(utf8)
keep if !missing(obs_value)
rename (country time_period obs_value) (iso3 year value)
* um registro por pais-setor-indicador-unidade-ano (GFS_GRP repete o mesmo valor em grupos diferentes)
duplicates tag iso3 sector indicator type_of_transformation year, gen(dup)
bysort iso3 sector indicator type_of_transformation year (value): gen double vdiff = value[_N] - value[1]
summ vdiff
assert r(max) < 1e-6
bysort iso3 sector indicator type_of_transformation year: keep if _n == 1
replace indicator = subinstr(subinstr(indicator, "_T", "", 1), "_A", "", 1)
gen un = cond(type_of_transformation == "POGDP_PT", "gdp", "out")
gen sec = ""
replace sec = "gg"  if sector == "S13"
replace sec = "cgs" if sector == "S1321"
replace sec = "cg"  if sector == "S1311"
replace sec = "bcg" if sector == "S1311B"
drop if sec == ""
gen vname = sec + "_" + lower(indicator) + "_" + un
keep iso3 year vname value
reshape wide value, i(iso3 year) j(vname) string
rename value* *
* governo geral: folha, despesa total, receita, resultado e categorias (todos em % do PIB no GFS)
rename gg_g21_gdp wagebill_gdp
* despesa total (outlays) = despesa + investimento liquido em ativos nao financeiros (GFSM 2014)
gen exp_gdp = gg_g2_gdp + gg_g31_gdp
rename (gg_g1_gdp gg_gnlb_gdp gg_g11_gdp) (rev_gdp balance_gdp tax_gdp)
* participacoes na despesa total; o GFS_SOO publica so % do PIB, entao a razao e calculada aqui
gen wagebill_share = 100 * wagebill_gdp / exp_gdp
gen sh_wage   = wagebill_share
gen sh_goods  = 100 * gg_g22_gdp / exp_gdp
gen sh_int    = 100 * gg_g24_gdp / exp_gdp
gen sh_transf = 100 * (gg_g25_gdp + gg_g26_gdp + gg_g27_gdp) / exp_gdp
gen sh_inv    = 100 * gg_g31_gdp / exp_gdp
* residual: outras despesas (G28) e consumo de capital fixo (G23)
gen sh_other  = 100 - sh_wage - sh_goods - sh_int - sh_transf - sh_inv
* serie combinada: governo geral; onde nao houver, governo central (com dummy de cobertura)
gen wagebill_comb = wagebill_gdp
gen byte cov_central = 0 if !missing(wagebill_gdp)
foreach s in cgs cg bcg {
    replace cov_central = 1 if missing(wagebill_comb) & !missing(`s'_g21_gdp)
    replace wagebill_comb = `s'_g21_gdp if missing(wagebill_comb)
}
gen wagebill_cg_gfs = cgs_g21_gdp
replace wagebill_cg_gfs = cg_g21_gdp if missing(wagebill_cg_gfs)
replace wagebill_cg_gfs = bcg_g21_gdp if missing(wagebill_cg_gfs)
keep iso3 year wagebill_gdp wagebill_share exp_gdp rev_gdp balance_gdp tax_gdp sh_* wagebill_comb cov_central wagebill_cg_gfs
label var wagebill_gdp "Wage bill, general government (% of GDP)"
label var wagebill_share "Wage bill, general government (% of total expenditure)"
label var wagebill_comb "Wage bill, general government or central where GG unavailable (% of GDP)"
label var cov_central "Wage bill coverage is central government only (combined series)"
compress
save "$INTERIM/gfs.dta", replace

* ---------------------------------------------------------------- ICSD
import delimited "$RAW/imf_icsd/icsd.csv", clear varnames(1) case(lower)
keep if !missing(obs_value)
rename (country time_period obs_value) (iso3 year value)
keep iso3 year indicator value
replace indicator = "igov"   if indicator == "P51G_S13_Q_POGDP_PT"
replace indicator = "ipriv"  if indicator == "P51G_PS_Q_POGDP_PT"
replace indicator = "ippp"   if indicator == "P51G_PUPVT_Q_POGDP_PT"
replace indicator = "kgov"   if indicator == "CAPSTCK_S13_Q_POGDP_PT"
replace indicator = "kppp"   if indicator == "CAPSTCK_PUPVT_Q_POGDP_PT"
reshape wide value, i(iso3 year) j(indicator) string
rename value* *
label var ipriv "Private investment (% of GDP), IMF ICSD"
label var igov "Public investment (% of GDP), IMF ICSD"
save "$INTERIM/icsd.dta", replace

* ---------------------------------------------------------------- Global Debt Database
import delimited "$RAW/imf_gdd/gdd.csv", clear varnames(1) case(lower)
keep if !missing(obs_value)
rename (country time_period obs_value) (iso3 year value)
keep iso3 year indicator value
replace indicator = "debt_gg" if indicator == "FL_S13_POGDP_PT"
replace indicator = "debt_cg" if indicator == "FL_S1311MIXED_POGDP_PT"
replace indicator = "debt_ps" if indicator == "FL_PS_POGDP_PT"
reshape wide value, i(iso3 year) j(indicator) string
rename value* *
* divida publica: governo geral; governo central onde o geral falta (marcado)
gen debt = debt_gg
gen byte debt_central = missing(debt_gg) & !missing(debt_cg)
replace debt = debt_cg if debt_central
label var debt "Public debt (% of GDP)"
save "$INTERIM/gdd.dta", replace

* ---------------------------------------------------------------- termos de troca de commodities
import delimited "$RAW/imf_ctot/ctot.csv", clear varnames(1) case(lower)
keep if frequency == "A" & !missing(obs_value)
keep if indicator == "CEMPI_CTOTXM_GDP"
rename (country time_period obs_value) (iso3 year value)
destring year, replace
gen w = cond(wgt_type == "H_FW_IX", "fw", "rw")
keep iso3 year w value
reshape wide value, i(iso3 year) j(w) string
rename (valuefw valuerw) (ctot ctot_rw)
label var ctot "Commodity terms of trade index (net export price, GDP-weighted, fixed weights)"
save "$INTERIM/ctot.dta", replace

* ---------------------------------------------------------------- descentralizacao fiscal
import delimited "$RAW/imf_fd/fd.csv", clear varnames(1) case(lower)
keep if indicator == "G2MD_PT" & sector == "SNG" & !missing(obs_value)
rename (country time_period obs_value) (iso3 year exp_decentr)
collapse (mean) exp_decentr, by(iso3)
label var exp_decentr "Subnational share of general government spending (%), 2010-2020 mean"
save "$INTERIM/fd.dta", replace

* ---------------------------------------------------------------- Eurostat (checagem cruzada)
import delimited "$RAW/eurostat/gov_10a_main.csv", clear varnames(1) case(lower)
keep if sector == "S13" & na_item == "D1PAY" & unit == "PC_GDP"
rename (geo time_period obs_value) (iso2 year wagebill_eurostat)
gen iso3 = ""
local pares AT AUT BE BEL BG BGR CY CYP CZ CZE DE DEU DK DNK EE EST EL GRC ES ESP FI FIN FR FRA HR HRV ///
    HU HUN IE IRL IT ITA LT LTU LU LUX LV LVA MT MLT NL NLD PL POL PT PRT RO ROU SE SWE SI SVN SK SVK ///
    IS ISL NO NOR CH CHE UK GBR
while "`pares'" != "" {
    gettoken a pares : pares
    gettoken b pares : pares
    replace iso3 = "`b'" if iso2 == "`a'"
}
keep if iso3 != ""
keep iso3 year wagebill_eurostat
save "$INTERIM/eurostat.dta", replace

* ---------------------------------------------------------------- regras fiscais (FMI, download manual)
* Fiscal Rules Dataset 1985-2024 (atualizacao de ago. 2025). A aba Rules lista os 123 paises que tiveram
* alguma regra nacional ou supranacional; membros do FMI ausentes da aba nao tem regra (codificados 0).
* O universo de membros e os codigos ISO3 vem da aba weo_group do proprio arquivo (decisao D38).
* 1979-1984 (anterior a base): regra em vigor se ja vigorava em 1985 e o ano de implementacao e <= ano.
local frfile : dir "$MANUAL" files "*Fiscal Rules*.xlsx"
local frfile : word 1 of `frfile'
capture erase "$INTERIM/fiscal_rules.dta"
if `"`frfile'"' != "" {
    import excel "$MANUAL/`frfile'", sheet("weo_group") firstrow clear allstring
    keep country ccode
    keep if strlen(ccode) == 3
    replace country = strtrim(country)
    rename ccode iso3
    replace iso3 = "XKX" if iso3 == "KOS"
    replace iso3 = "ROU" if iso3 == "ROM"
    tempfile univ
    save `univ'
    import excel "$MANUAL/`frfile'", sheet("Rules") cellrange(B5:O4924) clear allstring
    rename (B C D E F G H I J K L M N O) (year country er rr bbr dr er_lvl rr_lvl bbr_lvl dr_lvl er_imp rr_imp bbr_imp dr_imp)
    destring year, replace
    drop if missing(year) | country == ""
    replace country = strtrim(country)
    * 1 = regra em vigor; "-" = sem regra. Nivel: 0 nacional, 1 supranacional, 2 ambos
    foreach r in er rr bbr dr {
        gen byte rule_`r' = `r' == "1"
        destring `r'_lvl, replace force
    }
    gen byte rule_er_nat = rule_er == 1 & inlist(er_lvl, 0, 2)
    gen byte rule_bbr_nat = rule_bbr == 1 & inlist(bbr_lvl, 0, 2)
    * anos 1979-1984 a partir de 1985 e do ano de implementacao (primeiro ano listado na celula)
    expand 7 if year == 1985, gen(_pre)
    bysort country year _pre: replace year = 1978 + _n if _pre
    foreach r in er rr bbr dr {
        gen _imp = real(substr(strtrim(`r'_imp), 1, 4))
        replace rule_`r' = rule_`r' == 1 & _imp <= year if _pre
        drop _imp
    }
    replace rule_er_nat = rule_er_nat == 1 & rule_er == 1 if _pre
    replace rule_bbr_nat = rule_bbr_nat == 1 & rule_bbr == 1 if _pre
    drop if _pre & year == 1985
    drop _pre
    keep year country rule_*
    merge m:1 country using `univ', keep(match using)
    * todo nome da aba Rules precisa casar com um membro
    count if _merge == 1
    assert r(N) == 0
    gen byte in_frd = _merge == 3
    drop _merge
    * membros sem regra: um registro por ano 1979-2024
    expand 46 if in_frd == 0
    bysort iso3 (year): replace year = 1978 + _n if in_frd == 0
    foreach v of varlist rule_* {
        replace `v' = 0 if in_frd == 0
    }
    gen byte rule_any = rule_er | rule_rr | rule_bbr | rule_dr
    rename (rule_er rule_rr rule_bbr rule_dr rule_er_nat rule_bbr_nat) (rule_exp rule_rev rule_bb rule_debt rule_exp_nat rule_bb_nat)
    keep iso3 year rule_exp rule_rev rule_bb rule_debt rule_any rule_exp_nat rule_bb_nat in_frd
    isid iso3 year
    label var rule_exp "Expenditure rule in force (IMF FRD)"
    label var rule_rev "Revenue rule in force (IMF FRD)"
    label var rule_bb "Budget balance rule in force (IMF FRD)"
    label var rule_debt "Debt rule in force (IMF FRD)"
    label var rule_any "Any numerical fiscal rule in force (IMF FRD)"
    label var rule_exp_nat "National expenditure rule in force (IMF FRD)"
    label var rule_bb_nat "National budget balance rule in force (IMF FRD)"
    label var in_frd "Country listed in the IMF Fiscal Rules Dataset"
    tab year if inlist(year, 1979, 1984, 1985, 1996, 2005, 2015, 2023), sum(rule_any)
    save "$INTERIM/fiscal_rules.dta", replace
}
else di "Fiscal Rules Dataset ausente em $MANUAL"

log close
