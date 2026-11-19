* 09_cobertura_k.do -- Bloco 9: governo geral x central -- diferenca em diferencas, divisao dos unitarios e Tabela 2
* com uma so inferencia (bootstrap por pais: IC percentil e estrelas do mesmo bootstrap)
version 17
if "$ROOT" == "" do "`c(pwd)'/code/config.do"
do "$ROOT/code/kyklos/00_setup_k.do"
capture log close
log using "$RLOG/09_cobertura_k.log", replace text

use "$KIN/p5_rv.dta", clear
keep if micro == 0
xtset id period
gen cg_m1 = wagebill_cg_wdi_m1
gen byte S5_common_GC = !missing(g, wb_m1, cg_m1, lny0, hc_m1, inv_m1, open_m1, infl_m1, popg_m1, ctot_g_m1)
merge m:1 id using "$KIN/razao_gg_cg.dta", keep(master match) nogen keepusing(ratio)
gen byte unihi = federal == 0 & ratio > 1.5 & !missing(ratio)
gen byte unilo = federal == 0 & ratio <= 1.5 & !missing(ratio)
keep if S5_common_GC
* mediana da razao geral/central nas federacoes da amostra de estimacao
egen tf = tag(id) if federal == 1
quietly summ ratio if tf, detail
rv_kv cov9_fed_ratio_med `=string(r(p50), "%4.2f")'
quietly count if tf & !missing(ratio)
rv_kv cov9_fed_n_ratio `r(N)'
quietly count if tf
rv_kv cov9_fed_n `r(N)'
egen tu = tag(id) if unihi
quietly count if tu
rv_kv cov9_unihi_n `r(N)'
egen tl = tag(id) if unilo
quietly count if tl
rv_kv cov9_unilo_n `r(N)'
save "$RINT/cov9.dta", replace

* estatisticas numa amostra: 7 coeficientes da Tabela 2 e as diferencas
capture program drop covstats
program define covstats, rclass
    args fe
    local i = 0
    foreach grp in all fed uni own {
        local c = cond("`grp'" == "all", "1", cond("`grp'" == "fed", "federal == 1", cond("`grp'" == "uni", "federal == 0", "1")))
        foreach meas in gg cg {
            if "`grp'" == "own" & "`meas'" == "gg" continue
            local w = cond("`meas'" == "gg", "wb_m1", "cg_m1")
            capture quietly reghdfe g `w' $XP i.period if `c', absorb(`fe')
            return scalar b_`grp'_`meas' = cond(_rc, ., _b[`w'])
        }
    }
    foreach grp in unihi unilo {
        foreach meas in gg cg {
            local w = cond("`meas'" == "gg", "wb_m1", "cg_m1")
            capture quietly reghdfe g `w' $XP i.period if `grp', absorb(`fe')
            return scalar b_`grp'_`meas' = cond(_rc, ., _b[`w'])
        }
    }
end
covstats id
local names b_all_gg b_all_cg b_fed_gg b_fed_cg b_uni_gg b_uni_cg b_own_cg b_unihi_gg b_unihi_cg b_unilo_gg b_unilo_cg
foreach n of local names {
    local o_`n' = r(`n')
}
tempname B
postfile `B' int rep double(`names') using "$RINT/cov9_boot.dta", replace
local vals ""
foreach n of local names {
    local vals "`vals' (`o_`n'')"
}
post `B' (0) `vals'
set seed 20261113
forvalues r = 1/999 {
    quietly use "$RINT/cov9.dta", clear
    quietly bsample, cluster(id) idcluster(bid)
    quietly covstats bid
    local vals ""
    foreach n of local names {
        local vals "`vals' (r(`n'))"
    }
    post `B' (`r') `vals'
}
postclose `B'
* a amostra propria do governo central nao e a amostra comum: estimada a parte
use "$KIN/p5_rv.dta", clear
keep if micro == 0
gen cg_m1 = wagebill_cg_wdi_m1
reghdfe g cg_m1 $XP i.period, absorb(id) vce(cluster id)
keep if e(sample)
local o_own = _b[cg_m1]
local N_own = e(N)
local nc_own = e(N_clust)
tempfile own
save `own'
tempname Q
postfile `Q' int rep double b using "$RINT/cov9_boot_own.dta", replace
post `Q' (0) (`o_own')
forvalues r = 1/999 {
    quietly use `own', clear
    quietly bsample, cluster(id) idcluster(bid)
    capture quietly reghdfe g cg_m1 $XP i.period, absorb(bid)
    if !_rc post `Q' (`r') (_b[cg_m1])
}
postclose `Q'

* ---------------------------------------------------------------- resumo: IC percentil e p do mesmo bootstrap
use "$RINT/cov9_boot.dta", clear
gen d_all = b_all_gg - b_all_cg
gen d_fed = b_fed_gg - b_fed_cg
gen d_uni = b_uni_gg - b_uni_cg
gen did = d_fed - d_uni
gen d_unihi = b_unihi_gg - b_unihi_cg
gen d_unilo = b_unilo_gg - b_unilo_cg
gen did_hilo = d_unihi - d_unilo
gen did_fedhi = d_fed - d_unihi
gen did_fedlo = d_fed - d_unilo
tempname S
postfile `S' str14 stat double(est lo hi p) long(nrep) using "$RINT/cov9_res.dta", replace
foreach v in b_all_gg b_all_cg b_fed_gg b_fed_cg b_uni_gg b_uni_cg b_unihi_gg b_unihi_cg b_unilo_gg b_unilo_cg d_all d_fed d_uni did d_unihi d_unilo did_hilo did_fedhi did_fedlo {
    quietly summ `v' if rep == 0
    local e = r(mean)
    _pctile `v' if rep > 0, p(2.5 97.5)
    local lo = r(r1)
    local hi = r(r2)
    quietly count if rep > 0 & `v' <= 0
    local nl = r(N)
    quietly count if rep > 0 & `v' >= 0
    local nh = r(N)
    quietly count if rep > 0 & !missing(`v')
    local nn = r(N)
    post `S' ("`v'") (`e') (`lo') (`hi') (min(1, 2 * min(`nl', `nh') / `nn')) (`nn')
}
use "$RINT/cov9_boot_own.dta", clear
quietly summ b if rep == 0
local e = r(mean)
_pctile b if rep > 0, p(2.5 97.5)
local lo = r(r1)
local hi = r(r2)
quietly count if rep > 0 & b <= 0
local nl = r(N)
quietly count if rep > 0 & b >= 0
local nh = r(N)
quietly count if rep > 0
post `S' ("b_own_cg") (`e') (`lo') (`hi') (min(1, 2 * min(`nl', `nh') / r(N))) (r(N))
postclose `S'
use "$RINT/cov9_res.dta", clear
list, noobs
kcsv "$RINT/cov9_res.dta" TabS27_coverage
quietly summ p if stat == "did"
rv_kv cov9_did_p `=string(r(mean), "%9.4f")'
quietly summ est if stat == "did"
rv_kv cov9_did `=string(r(mean), "%9.4f")'
di "Bloco 9: diferenca em diferencas federacoes x unitarios = " r(mean)

* N e paises de cada coluna da Tabela 2 (amostra comum)
use "$RINT/cov9.dta", clear
foreach grp in all fed uni unihi unilo {
    local c = cond("`grp'" == "all", "1", cond("`grp'" == "fed", "federal == 1", cond("`grp'" == "uni", "federal == 0", "`grp'")))
    quietly reghdfe g wb_m1 $XP i.period if `c', absorb(id) vce(cluster id)
    local N_`grp' = e(N)
    local nc_`grp' = e(N_clust)
}
import delimited "$RINT/kv.csv", clear varnames(1) stringcols(_all)
foreach k in cov9_fed_ratio_med cov9_fed_n cov9_fed_n_ratio cov9_unihi_n cov9_unilo_n {
    quietly levelsof value if key == "`k'", local(`k') clean
    local `k' : word `: word count ``k''' of ``k''
}
use "$RINT/cov9_res.dta", clear
* nova Tabela 2
rv_new, ncol(7) head1("All countries" "" "Federations" "" "Unitary countries" "" "Own sample") ///
    head2("General gov." "Central gov." "General gov." "Central gov." "General gov." "Central gov." "Central gov.")
local cb ""
local ci ""
foreach s in b_all_gg b_all_cg b_fed_gg b_fed_cg b_uni_gg b_uni_cg b_own_cg {
    quietly summ est if stat == "`s'"
    local e = r(mean)
    quietly summ p if stat == "`s'"
    rv_fmt `e' %12.3f `=r(mean)'
    local cb `"`cb' "`r(s)'""'
    quietly summ lo if stat == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if stat == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local ci `"`ci' "[`l'; `r(s)']""'
}
rv_row "Wage bill, t_p − 1 (% of GDP)" `cb'
rv_row "" `ci'
local cd ""
foreach s in d_all d_fed d_uni {
    quietly summ est if stat == "`s'"
    local e = r(mean)
    quietly summ p if stat == "`s'"
    rv_fmt `e' %12.3f `=r(mean)'
    local x "`r(s)'"
    quietly summ lo if stat == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if stat == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local cd `"`cd' "`x' [`l'; `r(s)']" """'
}
rv_row "General − central (bootstrap 95% CI)" `cd' ""
rv_row "Observations" "`=string(`N_all', "%9.0fc")'" "`=string(`N_all', "%9.0fc")'" "`=string(`N_fed', "%9.0fc")'" "`=string(`N_fed', "%9.0fc")'" "`=string(`N_uni', "%9.0fc")'" "`=string(`N_uni', "%9.0fc")'" "`=string(`N_own', "%9.0fc")'"
rv_row "Countries" "`nc_all'" "`nc_all'" "`nc_fed'" "`nc_fed'" "`nc_uni'" "`nc_uni'" "`nc_own'"
quietly summ est if stat == "did"
local e = r(mean)
quietly summ p if stat == "did"
local pd = r(mean)
local hasdiff = (`pd' < 0.05)
local ttl2 = cond(`hasdiff', "The gap between general and central government coefficients differs between federations and unitary countries", ///
    "General and central government series give similar coefficients once the sample is common; federations and unitary countries do not differ significantly")
rv_out Tab2new_coverage, landscape ///
    title("Table 2. `ttl2'") ///
    notes("Five-year averages 1979–2023, no microstates; growth of real GDP per capita on the general government wage bill (IMF GFS) or the central government wage bill (WDI) in t_p − 1, with the controls in t_p − 1 of T3 and country and period fixed effects. Columns 1–6 use one sample (country-periods with both series and all controls); column 7 uses all country-periods with the central government series. One inference for the whole table: 95% percentile confidence intervals and stars from the same paired country bootstrap (999 replications, the same draws for both series), p-value = twice the smaller share of replications on either side of zero. Federations: Forum of Federations; `nc_fed' federations in the estimation sample (`cov9_fed_n' before singletons are dropped), median general/central ratio in 2010–2019 = `cov9_fed_ratio_med' (`cov9_fed_n_ratio' federations with both series). * p<0.10, ** p<0.05, *** p<0.01.")

* Tabela S27: diferenca em diferencas e divisao dos unitarios
rv_new, ncol(4) head1("Estimate" "Bootstrap 95% CI" "Bootstrap p" "Replications")
foreach k in "d_fed General − central, federations" "d_uni General − central, unitary countries" "did Difference in differences: federations − unitary" ///
    "d_unihi General − central, unitary with general/central ratio > 1.5" "d_unilo General − central, unitary with ratio ≤ 1.5" ///
    "did_hilo Unitary, ratio > 1.5 − ratio ≤ 1.5" "did_fedhi Federations − unitary with ratio > 1.5" "did_fedlo Federations − unitary with ratio ≤ 1.5" ///
    "b_unihi_gg Unitary, ratio > 1.5: general government" "b_unihi_cg Unitary, ratio > 1.5: central government" ///
    "b_unilo_gg Unitary, ratio ≤ 1.5: general government" "b_unilo_cg Unitary, ratio ≤ 1.5: central government" {
    gettoken s lab : k
    quietly summ est if stat == "`s'"
    local e = r(mean)
    quietly summ p if stat == "`s'"
    local pp = r(mean)
    rv_fmt `e' %12.3f `pp'
    local x "`r(s)'"
    quietly summ lo if stat == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local l "`r(s)'"
    quietly summ hi if stat == "`s'"
    rv_fmt `=r(mean)' %12.3f
    local h "`r(s)'"
    rv_fmt `pp' %12.3f
    local pps "`r(s)'"
    quietly summ nrep if stat == "`s'"
    rv_row "`=strtrim("`lab'")'" "`x'" "[`l'; `h']" "`pps'" "`=r(mean)'"
}
rv_out TabS27_coverage, landscape ///
    title("Table S27. `=cond(`hasdiff', "Federations and unitary countries differ in the general − central gap", "The general − central gap does not differ significantly between federations and unitary countries")'") ///
    notes("Common sample of Table 2 (five-year averages, wage bill and controls in t_p − 1, country and period fixed effects). Paired country bootstrap: in each of 999 replications countries are drawn with replacement and all coefficients are re-estimated on the same draw (fixed effects on the resampled country copies); 95% percentile CI; p-value = twice the smaller share of replications on either side of zero. Unitary countries are split by the median general/central wage bill ratio in 2010–2019 (above 1.5: `cov9_unihi_n' countries; at or below 1.5: `cov9_unilo_n' countries in the common sample). Exploratory (pre-registered in the plan addendum). * p<0.10, ** p<0.05, *** p<0.01.")
log close
