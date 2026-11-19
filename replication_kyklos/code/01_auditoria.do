* 01_auditoria.do -- secao 4.0 do plano de revisao: fontes novas, limpeza ampliada, paineis da revisao,
* amostras canonicas, inconsistencias do draft 7 e reproducao das tabelas (docs/AUDITORIA_DRAFT7.md)
version 17
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
capture log close
log using "$RLOG/01_auditoria.log", replace text
capture erase "$RINT/kv.csv"

* =====================================================================================
* A. Fontes novas (data/raw/<fonte>/, ver _SOURCE.txt)
* =====================================================================================
* A1. WDI complementar
import delimited "$RAW/wdi_rev/wdi_rev.csv", clear varnames(1) case(lower) stringcols(1 3)
drop if missing(iso3) | iso3 == ""
replace indicator = subinstr(indicator, ".", "_", .)
reshape wide value, i(iso3 year) j(indicator) string
rename (valueSP_POP_DPND_OL valueSH_XPD_GHED_GD_ZS valueSE_XPD_TOTL_GD_ZS valueNE_CON_GOVT_KD valueNY_GDP_MKTP_KD) ///
       (oldage_dep health_gov_gdp educ_gov_gdp govcons_real gdp_real_wdi)
label var oldage_dep "Old-age dependency ratio (% of working-age population), WDI"
label var health_gov_gdp "General government health expenditure (% of GDP), WDI"
label var educ_gov_gdp "Government expenditure on education (% of GDP), WDI"
label var govcons_real "General government final consumption (constant 2015 USD), WDI"
save "$RINT/wdi_rev.dta", replace

* A2. Crises bancarias sistemicas: Laeven e Valencia (2018), anos de inicio a fim
import excel "$RAW/laeven_valencia/SYSTEMIC_BANKING_CRISES_DATABASE_2018.xlsx", sheet("Crisis Resolution and Outcomes") ///
    cellrange(A2) clear allstring
keep A B C
rename (A B C) (cname start end)
foreach v in cname start end {
    replace `v' = ustrregexra(`v', "[0-9]+/", "")
    replace `v' = strtrim(`v')
}
destring start end, replace force
drop if missing(start) | cname == ""
replace end = start if missing(end)
gen cn = lower(cname)
replace cn = ustrregexra(cn, "[^a-z ]", "")
replace cn = strtrim(stritrim(cn))
tempfile LV
save `LV'
use "$FINAL/painel_anual.dta", clear
keep iso3 country
duplicates drop
gen cn = lower(country)
replace cn = ustrregexra(cn, "[^a-z ]", "")
replace cn = strtrim(stritrim(cn))
* nomes do Laeven-Valencia que diferem dos do Banco Mundial
tempfile WB
save `WB'
use `LV', clear
replace cn = "bosnia and herzegovina" if cn == "bosnia and herzegovina"
replace cn = "cabo verde" if cn == "cape verde"
replace cn = "central african republic" if cn == "central african rep"
replace cn = "congo dem rep" if inlist(cn, "congo dem rep of", "congo democratic republic of", "democratic republic of congo", "congo dem rep")
replace cn = "congo rep" if inlist(cn, "congo rep of", "congo republic of", "congo")
replace cn = "cote divoire" if inlist(cn, "cote divoire", "cte divoire", "cote d ivoire")
replace cn = "egypt arab rep" if cn == "egypt"
replace cn = "gambia the" if cn == "gambia"
replace cn = "iran islamic rep" if cn == "iran"
replace cn = "korea rep" if cn == "korea"
replace cn = "kyrgyz republic" if inlist(cn, "kyrgyz republic", "kyrgyzstan")
replace cn = "lao pdr" if cn == "lao peoples democratic republic"
replace cn = "macedonia fyr" if cn == "macedonia"
replace cn = "north macedonia" if inlist(cn, "macedonia fyr", "fyr macedonia")
replace cn = "russian federation" if cn == "russia"
replace cn = "slovak republic" if cn == "slovak rep"
replace cn = "syrian arab republic" if cn == "syria"
replace cn = "venezuela rb" if cn == "venezuela"
replace cn = "yemen rep" if cn == "yemen"
replace cn = "turkiye" if cn == "turkey"
replace cn = "china" if cn == "china mainland"
replace cn = "dominican republic" if cn == "dominican rep"
replace cn = "kyrgyz republic" if cn == "kyrgyz rep"
replace cn = "sao tome and principe" if strpos(cn, "tom") & strpos(cn, "prncipe")
replace cn = "viet nam" if cn == "vietnam"
replace cn = "czechia" if inlist(cn, "czech republic")
replace cn = "eswatini" if cn == "swaziland"
replace cn = "sao tome and principe" if cn == "sao tome and principe"
merge m:1 cn using `WB', keep(master match)
di "Laeven-Valencia: episodios sem pais casado:"
list cname start if _merge == 1, noobs
keep if _merge == 3
expand end - start + 1
bysort iso3 start: gen year = start + _n - 1
gen byte crisis_bank = 1
collapse (max) crisis_bank, by(iso3 year)
label var crisis_bank "Systemic banking crisis (Laeven and Valencia 2018), start to end year"
save "$RINT/laeven_valencia.dta", replace

* A3. Consolidacoes narrativas (Alesina, Favero e Giavazzi 2019): componente de folha (Spending - Salaries)
* aba GDP, % do PIB de t-1; colunas por posicao (cabecalho em 2 linhas): A pais, B ano,
* BN-BT salarios (u_t, a_t, a_t+1..a_t+5), CW-DC tributos totais, DD-DJ gasto total
import excel "$RAW/afg/NewComponents1978-2014_final.xlsx", sheet("GDP") cellrange(A3) clear
rename (A B) (iso3 year)
rename (BN BO) (afg_sal_u afg_sal_a)
rename (CW CX) (afg_tax_u afg_tax_a)
rename (DD DE) (afg_spend_u afg_spend_a)
keep iso3 year afg_sal_u afg_sal_a afg_tax_u afg_tax_a afg_spend_u afg_spend_a
destring year afg_*, replace force
drop if missing(year) | iso3 == ""
* choque implementado no ano (nao antecipado + anunciado antes e implementado em t); positivo = corte
gen afg_sal = afg_sal_u + afg_sal_a
gen afg_spend = afg_spend_u + afg_spend_a
gen afg_tax = afg_tax_u + afg_tax_a
label var afg_sal "Narrative wage-bill consolidation (cuts, % of lagged GDP), AFG 2019"
label var afg_spend "Narrative spending consolidation (% of lagged GDP), AFG 2019"
label var afg_tax "Narrative tax consolidation (% of lagged GDP), AFG 2019"
tab iso3
summ afg_sal afg_spend afg_tax
count if afg_sal != 0 & !missing(afg_sal)
save "$RINT/afg.dta", replace

* A4. Densidade sindical (ILOSTAT)
import delimited "$RAW/ilostat_ud/ud.csv", clear varnames(1) case(lower)
keep ref_area time_period obs_value
rename (ref_area time_period obs_value) (iso3 year union_density)
destring year union_density, replace force
collapse (mean) union_density, by(iso3 year)
label var union_density "Trade union density (% of employees), ILOSTAT"
save "$RINT/ilo_ud.dta", replace

* A5. V-Dem (clientelismo/particularismo e regime)
import delimited "$RAW/vdem/vdem_rev.csv", clear varnames(1) case(lower)
rename country_text_id iso3
duplicates drop iso3 year, force
rename v2dlencmps clientelism_prog
label var clientelism_prog "Particularistic vs programmatic linkages (V-Dem v2dlencmps; higher = programmatic)"
keep iso3 year clientelism_prog v2x_regime
save "$RINT/vdem_rev.dta", replace

* A6. DPI: ideologia do executivo, maioria e fracionamento, competitividade
use "$RAW/dpi/DPI2020_stata13.dta", clear
rename ifs iso3
replace iso3 = "ROU" if iso3 == "ROM"
replace iso3 = "COD" if iso3 == "ZAR"
replace iso3 = "TLS" if iso3 == "TMP"
replace iso3 = "SRB" if iso3 == "YUG" & year >= 2006
keep iso3 year execrlc maj frac eiec liec checks
foreach v in execrlc maj frac eiec liec checks {
    replace `v' = . if `v' < 0
}
gen byte exec_left = execrlc == 3 if inlist(execrlc, 1, 2, 3)
gen byte exec_right = execrlc == 1 if inlist(execrlc, 1, 2, 3)
label var exec_left "Left executive (DPI execrlc = 3)"
label var maj "Government majority (share of seats, DPI)"
label var frac "Legislative fractionalization (DPI)"
duplicates drop iso3 year, force
save "$RINT/dpi_rev.dta", replace

* A7. QoG: ICRG quality of government (substituto publico da qualidade da burocracia do ICRG), Polity e BMR
import delimited "$RAW/qog/qog_std_ts_jan26.csv", clear varnames(1) case(lower) encoding(utf8)
keep ccodealp year icrg_qog p_polity2 bmr_dem bmr_demdur
rename ccodealp iso3
keep if strlen(iso3) == 3
duplicates drop iso3 year, force
label var icrg_qog "ICRG indicator of quality of government (0-1), via QoG"
save "$RINT/qog_rev.dta", replace

* A8. Polity5 (download manual de 2026-11-13): restricoes ao executivo (xconst, 1-7); codigos especiais
* -66 (interrupcao), -77 (interregno) e -88 (transicao) viram missing. Chave: codigo COW -> ISO3 pela QoG
import delimited "$RAW/qog/qog_std_ts_jan26.csv", clear varnames(1) case(lower) encoding(utf8)
keep ccodealp ccodecow
drop if missing(ccodecow) | strlen(ccodealp) != 3
duplicates drop ccodecow, force
rename (ccodealp ccodecow) (iso3 ccode)
tempfile cow
save `cow'
import excel "$RAW/polity/p5v2018.xls", firstrow clear
keep ccode country year xconst
merge m:1 ccode using `cow', keep(master match)
di "Polity5: paises sem codigo ISO3 pela QoG (ficam fora):"
tab country if _merge == 1 & year >= 1980
* codigos Polity que diferem do COW da QoG: correspondencia explicita pelo nome; Alemanha Ocidental e Iemen do
* Norte como predecessores; URSS e Iugoslavia (ate 1991) ficam fora
replace iso3 = "ETH" if country == "Ethiopia"
replace iso3 = "VNM" if country == "Vietnam"
replace iso3 = "SRB" if inlist(country, "Serbia", "Serbia and Montenegro")
replace iso3 = "MNE" if country == "Montenegro"
replace iso3 = "SSD" if country == "South Sudan"
replace iso3 = "DEU" if country == "Germany West"
replace iso3 = "YEM" if country == "Yemen North"
keep if !missing(iso3) & iso3 != ""
drop _merge
replace xconst = . if xconst < 1
* um registro por pais-ano (mudancas de codigo no mesmo ano: fica o ultimo registro)
bysort iso3 year: keep if _n == _N
keep iso3 year xconst
label var xconst "Executive constraints (Polity5, 1-7)"
save "$RINT/polity_rev.dta", replace

* A9. IMF GFS COFOG (download manual de 2026-11-13, convertido por code/conv_cofog.py): saude (GF07) e
* educacao (GF09) do governo geral (S13), em % do PIB e em % do desembolso total
import delimited "$RAW/imf_cofog/gfs_cofog_saude_educ.csv", clear varnames(1) case(lower) stringcols(1 3 4 5)
keep if sector == "S13"
gen str14 k = cofog + "_" + unit
keep iso3 year k value
reshape wide value, i(iso3 year) j(k) string
rename (valueGF07_POGDP valueGF09_POGDP valueGF07_POTO valueGF09_POTO valueTOTOUT_POGDP) ///
       (cofog_health_gdp cofog_educ_gdp cofog_health_sh cofog_educ_sh cofog_total_gdp)
gen health_edu_cofog = cofog_health_sh + cofog_educ_sh
label var health_edu_cofog "Health and education spending (% of total outlays), general government, IMF GFS COFOG"
save "$RINT/cofog_rev.dta", replace

* A10. WDI, series da replica fiel de Mollick e Vianna (2023) (code/dl_wdi_mv.py, 2026-11-13)
import delimited "$RAW/wdi_rev/wdi_rev_mv.csv", clear varnames(1) case(lower) stringcols(1 3)
drop if missing(iso3) | iso3 == ""
replace indicator = subinstr(indicator, ".", "_", .)
reshape wide value, i(iso3 year) j(indicator) string
rename (valueNY_GDP_MKTP_KD_ZG valueNE_GDI_TOTL_ZS valueNE_CON_GOVT_ZS) (gdp_growth_mv gcf_gdp_mv govcons_gdp_mv)
label var gdp_growth_mv "Real GDP growth (%), WDI NY.GDP.MKTP.KD.ZG (2026-11-13)"
label var gcf_gdp_mv "Gross capital formation (% of GDP), WDI NE.GDI.TOTL.ZS (2026-11-13)"
label var govcons_gdp_mv "General government final consumption (% of GDP), WDI NE.CON.GOVT.ZS (2026-11-13)"
save "$RINT/wdi_mv.dta", replace

* =====================================================================================
* B. Painel anual da revisao
* =====================================================================================
use "$FINAL/painel_anual.dta", clear
foreach f in wdi_rev laeven_valencia afg ilo_ud vdem_rev dpi_rev qog_rev polity_rev cofog_rev wdi_mv {
    merge 1:1 iso3 year using "$RINT/`f'.dta", keep(master match) nogen
}
replace crisis_bank = 0 if missing(crisis_bank) & year <= 2017
xtset id year

* B1. Limpeza ampliada [P31]: guarda os valores originais e conta cada regra
foreach v in rev_gdp balance_gdp infl infl_raw open wagebill_share sh_goods sh_int sh_transf sh_inv sh_other {
    gen double `v'_orig = `v'
}
local per "inrange(year, 1979, 2023) & micro == 0"
tempname R
file open `R' using "$RINT/limpeza_revisao.csv", write replace text
file write `R' "regra,obs_pais_ano" _n
count if rev_gdp > 100 & !missing(rev_gdp) & `per'
file write `R' "Receita > 100% do PIB,`r(N)'" _n
rv_kv clean_rev `r(N)'
replace rev_gdp = . if rev_gdp > 100
count if abs(balance_gdp) > 50 & !missing(balance_gdp) & `per'
file write `R' "Saldo fiscal fora de +-50% do PIB,`r(N)'" _n
rv_kv clean_bal `r(N)'
replace balance_gdp = . if abs(balance_gdp) > 50
count if infl_raw > 1000 & !missing(infl_raw) & `per'
file write `R' "Inflacao > 1000%,`r(N)'" _n
rv_kv clean_infl `r(N)'
replace infl = . if infl_raw > 1000 & !missing(infl_raw)
replace infl_raw = . if infl_raw > 1000
count if open == 0 & `per'
file write `R' "Abertura igual a zero,`r(N)'" _n
rv_kv clean_open `r(N)'
replace open = . if open == 0
local n = 0
foreach v in wagebill_share sh_goods sh_int sh_transf sh_inv sh_other {
    count if (`v' < 0 | `v' > 100) & !missing(`v') & `per'
    local n = `n' + r(N)
    replace `v' = . if `v' < 0 | `v' > 100
}
file write `R' "Participacoes na despesa fora de [0, 100],`n'" _n
rv_kv clean_shares `n'
* despesa e receita: a regra de despesa > 100% ja estava no draft 7; receita implausivel tambem zera as participacoes
file close `R'
* winsorizacao: limites aplicados no draft 7 (amostra sem microestados, 1980-2023)
_pctile g_raw if micro == 0 & inrange(year, 1980, 2023), p(1 99)
rv_kv wins_g_lo `=string(r(r1), "%5.2f")'
rv_kv wins_g_hi `=string(r(r2), "%5.2f")'

* B2. Tendencias do log do PIB real: Hamilton (H = 2, k = 2), HP unilateral e HP bilateral (lambda = 6,25)
rv_hamilton lnY, gen(lnY_ham) h(2) k(2)
rv_hp1s lnY, gen(lnY_hp1) lambda(6.25) minobs(8)
* lnY_hp (bilateral) ja existe no painel do draft 7
gen wb = wagebill_gdp
gen wb_ham = wagebill_gdp * exp(lnY - lnY_ham)
gen wb_hp1 = wagebill_gdp * exp(lnY - lnY_hp1)
gen wb_hp2 = wagebill_gdp * exp(lnY - lnY_hp)
label var wb "Wage bill, general government (% of GDP)"
label var wb_ham "Wage bill (% of trend GDP, Hamilton)"
label var wb_hp1 "Wage bill (% of trend GDP, one-sided HP)"
label var wb_hp2 "Wage bill (% of trend GDP, two-sided HP)"
* decomposicao multiplicativa: W/Y = (W/Y*)(Y*/Y)
gen lwb_trend = ln(wb_ham)
gen lgap_ham = lnY_ham - lnY
label var lwb_trend "log wage bill over trend GDP (Hamilton)"
label var lgap_ham "log(trend GDP / GDP), Hamilton"
* numerador placebo: folha real do ano anterior crescendo a tendencia do pais, dividida pelo PIB corrente
gen double wreal = wagebill_gdp / 100 * gdp_real
gen double dlw = ln(wreal) - ln(L.wreal)
bysort id: egen gstar = mean(dlw)
gen wb_placebo = L.wagebill_gdp * (L.gdp_real / gdp_real) * exp(gstar)
label var wb_placebo "Placebo ratio: lagged real wage bill grown at trend / current GDP (% of GDP)"
drop wreal dlw
* salario relativo sobre o PIB por trabalhador tendencial
gen relwage_ham = wb_ham / pubemp_share
label var relwage_ham "Relative public wage over trend GDP per worker (Hamilton)"
* ciclicidade do consumo do governo (Frankel-Vegh-Vuletin): dlog consumo real sobre o hiato (HP bilateral)
gen dlgc = 100 * (ln(govcons_real) - ln(L.govcons_real))
gen gap_hp = 100 * (lnY - lnY_hp)
gen double cyc_pre = .
levelsof id, local(ids)
foreach i of local ids {
    capture quietly regress dlgc gap_hp if id == `i' & inrange(year, 1970, 1995)
    if !_rc & e(N) >= 12 quietly replace cyc_pre = _b[gap_hp] if id == `i'
}
label var cyc_pre "Cyclicality of real government consumption, 1970-1995 (coef. on output gap)"
* democracia e idade da democracia (V-Dem polyarchy >= 0,5)
gen byte dem = v2x_polyarchy >= 0.5 if !missing(v2x_polyarchy)
gen demage = 0
bysort id (year): replace demage = cond(dem == 1, cond(_n == 1, 1, demage[_n - 1] + 1), 0) if !missing(dem)
replace demage = . if missing(dem)
gen byte dem_new = dem == 1 & demage <= 16 if !missing(dem)
label var dem "Democracy (V-Dem polyarchy >= 0.5)"
label var demage "Years of continuous democracy since 1970 (V-Dem)"
label var dem_new "New democracy (democracy for 16 years or fewer: about the first four elections)"
* zona do euro (membros e ano de adesao) e regioes
gen int euro_year = .
foreach c in AUT BEL DEU ESP FIN FRA IRL ITA LUX NLD PRT {
    replace euro_year = 1999 if iso3 == "`c'"
}
replace euro_year = 2001 if iso3 == "GRC"
replace euro_year = 2007 if iso3 == "SVN"
replace euro_year = 2008 if inlist(iso3, "CYP", "MLT")
replace euro_year = 2009 if iso3 == "SVK"
replace euro_year = 2011 if iso3 == "EST"
replace euro_year = 2014 if iso3 == "LVA"
replace euro_year = 2015 if iso3 == "LTU"
replace euro_year = 2023 if iso3 == "HRV"
gen byte euro = !missing(euro_year) & year >= euro_year
encode region, gen(region_id)
gen health_edu_share = 100 * (health_gov_gdp + educ_gov_gdp) / exp_gdp if exp_gdp > 0
label var health_edu_share "Health and education spending (% of total expenditure), WDI/GFS"
gen y100 = 100 * lny
label var y100 "100 x log GDP per capita"
compress
save "$RINT/anual_rv.dta", replace

* =====================================================================================
* C. Paineis de medias nao sobrepostas (5 e 3 anos), com variantes de timing
* =====================================================================================
* t_p = primeiro ano do periodo; t_p - 1 = ultimo ano do periodo anterior
capture program drop rv_painel
program define rv_painel
    args L
    use "$RINT/anual_rv.dta", clear
    keep if year >= 1978
    gen period = floor((year - 1979) / `L')
    gen year0 = 1979 + `L' * period
    gen byte first = year == year0
    gen byte notfirst = year > year0
    * crescimento: media do periodo (draft 7) e media excluindo o primeiro ano (T2)
    gen g_x1 = g if notfirst
    gen g_excr = g if !inlist(year, 2008, 2009, 2020, 2021)
    * valores no ano t_p - 1 (ultimo ano do periodo anterior) e em t_p
    sort id year
    local pre wb wb_ham wb_hp1 wb_hp2 wb_placebo wagebill_cg_wdi wagebill_comb cov_central wagebill_share exp_gdp ///
        rev_gdp balance_gdp sh_goods sh_int sh_transf sh_inv sh_other inv open infl popg ctot_g hc lny merit wgi_ge ///
        debt oldage_dep health_edu_share icrg_qog exec_left maj frac union_density clientelism_prog impartial ///
        dem demage dem_new v2x_polyarchy govcons_gdp lwb_trend lgap_ham health_edu_cofog xconst
    foreach v of local pre {
        gen `v'_m1 = L.`v'
        gen `v'_tp = `v'
    }
    * valores no ano t_p (draft 7) e em t_p - 1 so nas linhas do primeiro ano
    foreach v of local pre {
        replace `v'_m1 = . if !first
        replace `v'_tp = . if !first
    }
    * WWBI (4.4): mesmo ano para folha e emprego publico, o mais proximo de t_p - 1, com prioridade para anos anteriores
    * ordem de busca: t_p-1, t_p-2, t_p-3, t_p-4, t_p, t_p+1, t_p+2, t_p+3
    gen int yd = .
    gen pe_sel = .
    gen wb_sel = .
    gen prem_sel = .
    gen premf_sel = .
    gen ilo_sel = .
    gen relh_sel = .
    foreach d in 1 2 3 4 0 -1 -2 -3 {
        local s = cond(`d' > 0, "L`d'.", cond(`d' < 0, "F`=-`d''.", ""))
        replace pe_sel = `s'pubemp_share if first & missing(yd) & !missing(`s'pubemp_share, `s'wagebill_gdp)
        replace wb_sel = `s'wagebill_gdp if first & missing(yd) & !missing(`s'pubemp_share, `s'wagebill_gdp)
        replace relh_sel = `s'relwage_ham if first & missing(yd) & !missing(`s'pubemp_share, `s'wagebill_gdp)
        replace ilo_sel = `s'ilo_pubemp_share if first & missing(yd) & !missing(`s'pubemp_share, `s'wagebill_gdp)
        replace yd = `d' if first & missing(yd) & !missing(`s'pubemp_share, `s'wagebill_gdp)
    }
    * premio (mesma regra, so o premio)
    gen int ydp = .
    foreach d in 1 2 3 4 0 -1 -2 -3 {
        local s = cond(`d' > 0, "L`d'.", cond(`d' < 0, "F`=-`d''.", ""))
        replace prem_sel = `s'wwbi_prem_all if first & missing(ydp) & !missing(`s'wwbi_prem_all)
        replace premf_sel = `s'wwbi_prem_formal if first & missing(ydp) & !missing(`s'wwbi_prem_all)
        replace ydp = `d' if first & missing(ydp) & !missing(`s'wwbi_prem_all)
    }
    * crise no periodo e zona do euro 2008-2013
    gen byte euro_0813 = euro & inrange(year, 2008, 2013)
    gen ng = !missing(g)
    gen ng_x1 = !missing(g_x1)
    drop if year < 1979
    collapse (mean) g g_x1 g_excr g_raw infl infl_raw inv open popg ctot_g ipriv tfp_g privemp_g debt ///
        exp_gdp rev_gdp balance_gdp wb_mean = wb hc ///
        (max) crisis_p = crisis_bank euro_0813_p = euro_0813 war_any = war ///
        (firstnm) *_m1 *_tp yd ydp pe_sel wb_sel prem_sel premf_sel ilo_sel relh_sel ///
        iso3 country region region_id income_grp oecd resource_rich federal micro year0 euro_year ///
        (sum) ng ng_x1, by(id period)
    replace g = . if ng < cond(`L' == 5, 3, 2)
    replace g_x1 = . if ng_x1 < cond(`L' == 5, 3, 2)
    rename lny_m1 lny0
    xtset id period
    gen L_g = L.g
    * leads: folha no inicio do periodo seguinte
    gen wb_tp_lead = F.wb_tp
    gen wb_m1_lead = F.wb_m1
    label var g "GDP per capita growth (%, period mean)"
    label var g_x1 "GDP per capita growth (%, period mean excluding the first year)"
    label var wb_tp "Wage bill, general government (% of GDP), t_p"
    label var wb_m1 "Wage bill, general government (% of GDP), t_p - 1"
    label var wb_ham_m1 "Wage bill (% of trend GDP, Hamilton), t_p - 1"
    label var wb_mean "Wage bill (% of GDP), period mean"
    gen byte early2 = 0
    bysort id (period): replace early2 = _n <= 2 if !missing(wb_m1)
    compress
    save "$RINT/p`L'_rv.dta", replace
end
rv_painel 5
rv_painel 3

* =====================================================================================
* D. Amostras canonicas
* =====================================================================================
global X5D "lny0 hc_tp inv open infl popg ctot_g"
use "$RINT/p5_rv.dta", clear
keep if micro == 0
xtset id period
* S5_base: especificacao de base do draft 7 (A1), com a limpeza ampliada
reghdfe g wb_tp $X5D, absorb(id period) vce(cluster id)
gen byte S5_base = e(sample)
rv_kv S5_base_N `e(N)'
rv_kv S5_base_nc `e(N_clust)'
* o mesmo modelo com as variaveis sem a limpeza ampliada (para contar o efeito da limpeza)
gen byte S5_bond = 0
gen byte S5_common_GC = 0
keep id period S5_base S5_bond S5_common_GC
save "$RINT/amostras5.dta", replace

use "$RINT/anual_rv.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023)
xtset id year
gen byte S1_base = !missing(wb, wb_hp2, wb_ham, L.wb, g, L.g, L.lny, hc, inv, open, infl, popg, ctot_g)
count if S1_base
rv_kv S1_base_N `r(N)'
keep id year S1_base
save "$RINT/amostras1.dta", replace

* =====================================================================================
* E. Inconsistencias apontadas pelo parecer [P13, P20, P22, P24]
* =====================================================================================
* E1. folha defasada 0,040 na S12 (1.594 obs.) e na S1 (1.622 obs.): dois modelos distintos?
use "$FINAL/painel_anual.dta", clear
keep if micro == 0 & inrange(year, 1996, 2023)
xtset id year
gen wb_lag = L.wagebill_gdp
gen byte s4 = !missing(wagebill_gdp, wagebill_cyc, wagebill_cyc_ham, wb_lag, g, L.g, L.lny, hc, inv, open, infl, popg, ctot_g)
xtscc g wb_lag L.g L.lny hc inv open infl popg ctot_g i.year if s4, fe
local b12 = _b[wb_lag]
local se12 = _se[wb_lag]
local n12 = e(N)
gen wagebill_gdp0 = L.wagebill_gdp
gen L_g = L.g
gen lny0 = L.lny
gen hc0 = L.hc
xtscc g wagebill_gdp0 L_g lny0 hc0 inv open infl popg ctot_g i.year, fe
local b1 = _b[wagebill_gdp0]
local se1 = _se[wagebill_gdp0]
local n1 = e(N)
di "E1: S12 col. 4 = " %9.6f `b12' " (EP " %8.6f `se12' ", N = `n12'); S1 col. 3 = " %9.6f `b1' " (EP " %8.6f `se1' ", N = `n1')"
rv_kv e1_b12 `=string(`b12', "%9.6f")'
rv_kv e1_b1 `=string(`b1', "%9.6f")'
rv_kv e1_n12 `n12'
rv_kv e1_n1 `n1'
* diferenca entre os modelos: S1 usa capital humano defasado e a amostra nao exige HP/Hamilton
* E2. Tabela S14: quantos paises no A1 e quantos na lista
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
reghdfe g wagebill_gdp0 lny0 hc0 inv open infl popg ctot_g, absorb(id period) vce(cluster id)
gen byte sA1 = e(sample)
egen tagA1 = tag(id) if sA1
count if tagA1 == 1
rv_kv e2_nA1 `r(N)'
tab income_grp if tagA1 == 1
egen tagall = tag(id) if !missing(wagebill_gdp0)
count if tagall == 1
rv_kv e2_nlist `r(N)'
* singletons: paises com uma so observacao na amostra do A1 (antes do descarte)
gen byte sA1x = !missing(g, wagebill_gdp0, lny0, hc0, inv, open, infl, popg, ctot_g)
bysort id: egen nobs_i = total(sA1x)
egen tagx = tag(id) if sA1x
count if tagx == 1
rv_kv e3_nc_presingleton `r(N)'
count if tagx == 1 & nobs_i == 1
rv_kv e3_singletons `r(N)'
count if sA1x
rv_kv e3_N_presingleton `r(N)'
* subamostras por renda: observacoes sem grupo de renda na amostra do A1
count if sA1 & missing(income_grp)
rv_kv e5_noincome `r(N)'
forvalues k = 1/4 {
    quietly reghdfe g wagebill_gdp0 lny0 hc0 inv open infl popg ctot_g if income_grp == `k', absorb(id period) vce(cluster id)
    local ninc`k' = e(N)
    quietly count if sA1 & income_grp == `k'
    local nraw`k' = r(N)
}
rv_kv e5_inc_N_sum `=`ninc1' + `ninc2' + `ninc3' + `ninc4''
rv_kv e5_inc_raw_sum `=`nraw1' + `nraw2' + `nraw3' + `nraw4''
* E7. Hansen e diferenca-em-Hansen na S7, col. 1
quietly tab period, gen(pd)
drop pd1
xtabond2 g L_g wagebill_gdp0 lny0 hc0 inv open infl popg ctot_g pd*, gmm(L_g, lag(1 1) collapse) ///
    gmm(wagebill_gdp0 inv lny0, lag(2 2) collapse) iv(hc0 open infl popg ctot_g pd*) twostep robust small
matrix DH = e(diffsargan)
matrix list DH
rv_kv e7_hansen `=string(e(hansenp), "%6.4f")'
rv_kv e7_dh_levels `=string(DH[5, 1], "%6.4f")'
rv_kv e7_dh_rows `=rowsof(DH)'
* E8. ponto de inflexao da S3 com os coeficientes sem arredondamento
use "$FINAL/painel_5anos.dta", clear
keep if micro == 0
gen pubemp_sq0 = pubemp_share0^2
reghdfe g pubemp_share0 pubemp_sq0 relwage0 lny0 hc0 inv open infl popg ctot_g, absorb(id period) vce(cluster id)
local tp = -_b[pubemp_share0] / (2 * _b[pubemp_sq0])
rv_kv e8_b1 `=string(_b[pubemp_share0], "%9.5f")'
rv_kv e8_b2 `=string(_b[pubemp_sq0], "%9.6f")'
rv_kv e8_tp `=string(`tp', "%5.1f")'
* E6. periodos de tres anos do draft 7: inicio em 1981
use "$FINAL/painel_3anos.dta", clear
summ year0
rv_kv e6_y0min `r(min)'
rv_kv e6_y0max `r(max)'
* =====================================================================================
* F. Reproducao das tabelas do draft 7: compara os numeros dos .tex do commit de base com os refeitos
* =====================================================================================
mata:
void _rvcomp(string scalar f0, string scalar f1, string scalar lbl, string scalar out)
{
    string colvector a, b
    real colvector x0, x1
    real scalar nd, md, fh, i
    a = cat(f0)
    b = cat(f1)
    x0 = _rvnums(a)
    x1 = _rvnums(b)
    nd = .
    md = .
    if (rows(x0) == rows(x1)) {
        nd = 0
        md = 0
        for (i = 1; i <= rows(x0); i++) {
            if (abs(x0[i] - x1[i]) > 0.001) nd++
            if (abs(x0[i] - x1[i]) > md) md = abs(x0[i] - x1[i])
        }
    }
    fh = fopen(out, "a")
    fput(fh, lbl + "," + strofreal(rows(x0)) + "," + strofreal(rows(x1)) + "," + strofreal(nd) + "," + strofreal(md))
    fclose(fh)
}
real colvector _rvnums(string colvector s)
{
    real colvector r
    real scalar i
    string scalar t, m
    r = J(0, 1, .)
    for (i = 1; i <= rows(s); i++) {
        t = s[i]
        if (strpos(t, "%") == 1) continue
        while (ustrregexm(t, "-?[0-9]+(,[0-9]{3})*(\.[0-9]+)?")) {
            m = ustrregexs(0)
            r = r \ strtoreal(subinstr(m, ",", ""))
            t = substr(t, strpos(t, m) + strlen(m), .)
        }
    }
    return(r)
}
end
* (comparison with earlier versions of the article omitted from the replication package)

log close
