* 07b_figura4.do -- Figura 4: efeito marginal da folha ao longo do merito (C1), estimador por tercis e por
*                   kernel (C2) e histograma do moderador (suporte comum). Usa os arquivos gravados por 07.
if "$ROOT" == "" global ROOT "`c(pwd)'"
do "$ROOT/code/00_setup.do"
log using "$LOG/07b_figura4.log", replace text

* histograma do moderador na amostra de estimacao
use "$INTERIM/merit0_sample.dta", clear
_pctile merit0, p(5 95)
local p5 = r(r1)
local p95 = r(r2)
twoway__histogram_gen merit0, bin(20) gen(hh xx, replace) frequency
keep hh xx
keep if !missing(hh)
gen src = "hist"
tempfile H
save `H'

use "$INTERIM/me_C1.dta", clear
gen src = "lin"
append using "$INTERIM/me_bins.dta"
replace src = "bin" if missing(src)
capture confirm file "$INTERIM/me_kernel.dta"
local haskernel = !_rc
if `haskernel' {
    preserve
    use "$INTERIM/me_kernel.dta", clear
    * kernel so dentro do suporte comum (percentis 5 a 95 do moderador)
    keep if inrange(km_x, `p5', `p95')
    gen src = "ker"
    tempfile K
    save `K'
    restore
    append using `K'
}
append using `H'
* escala do histograma: ocupa os 18% inferiores do eixo
quietly summ lo if src == "lin"
local ymin = r(min)
quietly summ hi if src == "lin"
local ymax = r(max)
quietly summ bin_CI_l
local ymin = min(`ymin', r(min))
quietly summ bin_CI_u
local ymax = max(`ymax', r(max))
if `haskernel' {
    capture quietly summ km_lo
    if !_rc & r(N) > 0 local ymin = min(`ymin', r(min))
    capture quietly summ km_hi
    if !_rc & r(N) > 0 local ymax = max(`ymax', r(max))
}
local span = `ymax' - `ymin'
local base = `ymin' - 0.25 * `span'
quietly summ hh
gen hbar = `base' + hh / r(max) * 0.20 * `span' if src == "hist"
gen hbase = `base' if src == "hist"
quietly summ xx if src == "hist"
local bw = (r(max) - r(min)) / 19

local kplot ""
local kleg ""
if `haskernel' {
    local kplot (line km_me km_x if src == "ker", sort lcolor("$C3") lpattern(shortdash) lwidth(medthick)) ///
        (line km_lo km_x if src == "ker", sort lcolor("$C3") lpattern(dot) lwidth(thin)) ///
        (line km_hi km_x if src == "ker", sort lcolor("$C3") lpattern(dot) lwidth(thin))
    local kleg 5 "Kernel estimate (95% CI dotted)"
}
twoway (rbar hbase hbar xx if src == "hist", barwidth(`bw') color(gs12) lcolor(gs9) lwidth(vthin)) ///
       (rarea lo hi m if src == "lin", sort color("$C2%20") lwidth(none)) ///
       (line me m if src == "lin", sort lcolor("$C2") lwidth(medthick) lpattern(solid)) ///
       (rcap bin_CI_l bin_CI_u x0 if src == "bin", lcolor("$C1") lwidth(medthin)) ///
       `kplot' ///
       (scatter bin_marg x0 if src == "bin", msymbol(D) mcolor("$C1") msize(medsmall)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(dash)) ///
       legend(order(3 "Linear interaction (95% CI shaded)" `=cond(`haskernel', 8, 5)' "Tercile estimates" `kleg') rows(1) pos(6) size(7pt)) ///
       xtitle("Meritocratic recruitment, V-Dem (first year of period)", size(8pt)) ///
       ytitle("Marginal effect of wage bill on growth (p.p.)", size(8pt)) ///
       xlabel(, labsize(7pt)) ylabel(, labsize(7pt) nogrid angle(horizontal))
fig_export Figure4_marginal_effect_merit, width(190) height(100)

* apendice: efeito marginal ao longo do WGI (C5)
use "$INTERIM/me_C5.dta", clear
twoway (rarea lo hi m, sort color("$C2%20") lwidth(none)) (line me m, sort lcolor("$C2") lwidth(medthick) lpattern(solid)), ///
       $GOPT yline(0, lcolor(gs10) lpattern(dash)) legend(off) ///
       xtitle("Government effectiveness, WGI (first year of period)", size(8pt)) ///
       ytitle("Marginal effect of wage bill on growth (p.p.)", size(8pt)) ///
       xlabel(, labsize(7pt)) ylabel(, labsize(7pt) nogrid angle(horizontal))
fig_export FigureA2_marginal_effect_wgi, width(90) height(75)

log close
