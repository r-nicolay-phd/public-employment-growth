* 02_limpeza_instituicoes.do -- V-Dem, QoG (inclui ICTD/UNU-WIDER GRD), QoG Expert Survey, DPI e UCDP/PRIO
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/02_limpeza_instituicoes.log", replace text

* ---------------------------------------------------------------- V-Dem v16
import delimited "$RAW/vdem/vdem_subset.csv", clear varnames(1) case(lower) encoding(utf8)
rename country_text_id iso3
keep if year >= 1950
* codigos V-Dem que diferem do ISO3 do Banco Mundial
replace iso3 = "XKX" if iso3 == "XKX" | country_name == "Kosovo"
replace iso3 = "PSE" if country_name == "Palestine/West Bank"
drop if inlist(country_name, "Palestine/Gaza", "Somaliland", "Zanzibar", "Hong Kong") & iso3 != "HKG"
duplicates report iso3 year
duplicates drop iso3 year, force
rename (v2stcritrecadm v2clrspct v2excrptps) (merit impartial pubcorrupt)
label var merit "Meritocratic recruitment in state administration (V-Dem v2stcritrecadm)"
label var impartial "Rigorous and impartial public administration (V-Dem v2clrspct)"
label var pubcorrupt "Public sector corruption (V-Dem v2excrptps; higher = less corrupt)"
keep iso3 year merit impartial pubcorrupt v2x_polyarchy v2x_rule v2stcritrecadm_codelow v2stcritrecadm_codehigh
save "$INTERIM/vdem.dta", replace

* ---------------------------------------------------------------- QoG Standard (receita ICTD/UNU-WIDER GRD)
import delimited using "$RAW/qog/qog_std_ts_jan26.csv", clear varnames(1) case(lower) encoding(utf8)
keep ccodealp year ictd_revexsc ictd_taxexsc ictd_nontax ictd_revres ictd_taxnresexsc
rename ccodealp iso3
keep if strlen(iso3) == 3 & year >= 1980
rename (ictd_revexsc ictd_taxexsc ictd_nontax ictd_revres) (grd_rev grd_tax grd_nontax grd_resrev)
label var grd_rev "Total revenue excl. social contributions (% of GDP), ICTD/UNU-WIDER GRD"
label var grd_tax "Tax revenue excl. social contributions (% of GDP), ICTD/UNU-WIDER GRD"
duplicates drop iso3 year, force
save "$INTERIM/qog_grd.dta", replace

* ---------------------------------------------------------------- QoG Expert Survey 2020 (corte transversal)
import delimited "$RAW/qog/qog_exp_agg_20.csv", clear varnames(1) case(lower) encoding(utf8)
rename (ccodealp proff_pca close_pca) (iso3 qog_prof qog_closed)
keep iso3 qog_prof qog_closed impar1
rename impar1 qog_impartial
label var qog_prof "Professionalism index (QoG Expert Survey 2020)"
label var qog_closed "Closedness index (QoG Expert Survey 2020)"
save "$INTERIM/qog_expert.dta", replace

* ---------------------------------------------------------------- DPI 2020: eleicoes e federalismo
use "$RAW/dpi/DPI2020_stata13.dta", clear
rename ifs iso3
* codigos antigos do DPI
replace iso3 = "ROU" if iso3 == "ROM"
replace iso3 = "COD" if iso3 == "ZAR"
replace iso3 = "TLS" if iso3 == "TMP"
replace iso3 = "SRB" if iso3 == "YUG" & year >= 2006
foreach v in system yrcurnt exelec legelec author finittrm {
    replace `v' = . if `v' < 0
}
* eleicao relevante: presidencial em sistemas presidencialistas; legislativa nos demais
gen byte election = cond(system == 0, exelec, legelec) if !missing(system)
replace election = 1 if election == 0 & system == 0 & legelec == 1 & missing(exelec)
* calendario predeterminado: eleicao no ano em que o mandato constitucional expira (yrcurnt == 0)
gen byte election_fixed = election == 1 & yrcurnt == 0 if !missing(election)
replace election_fixed = . if missing(yrcurnt) & election == 1
gen byte election_early = election == 1 & yrcurnt > 0 & !missing(yrcurnt)
label var election "Election year (executive in presidential, legislative otherwise), DPI"
label var election_fixed "Election year with predetermined date (term expires that year), DPI"
keep iso3 year system election election_fixed election_early author yrcurnt
duplicates report iso3 year
duplicates drop iso3 year, force
save "$INTERIM/dpi.dta", replace

* ---------------------------------------------------------------- UCDP/PRIO: anos de guerra
import delimited "$RAW/ucdp/UcdpPrioConflict_v26_1.csv", clear varnames(1) case(lower) encoding(utf8) stringcols(_all)
destring year intensity_level, replace
keep if intensity_level == 2
* gwno_loc pode listar varios paises
split gwno_loc, parse(",") gen(gw)
gen id = _n
reshape long gw, i(id) j(k)
drop if missing(gw)
destring gw, replace
gen byte war = 1
collapse (max) war, by(gw year)
* Gleditsch-Ward para ISO3 (kountry usa codigos COW; diferencas GW/COW tratadas abaixo)
kountry gw, from(cown) to(iso3c)
rename _ISO3C_ iso3
replace iso3 = "SRB" if gw == 340
replace iso3 = "YEM" if inlist(gw, 678, 679, 680)
replace iso3 = "DEU" if gw == 260
replace iso3 = "RUS" if gw == 365
replace iso3 = "SSD" if gw == 626
replace iso3 = "TLS" if gw == 860
replace iso3 = "XKX" if gw == 347
count if missing(iso3)
list gw year if missing(iso3)
drop if missing(iso3)
collapse (max) war, by(iso3 year)
save "$INTERIM/ucdp.dta", replace

log close
