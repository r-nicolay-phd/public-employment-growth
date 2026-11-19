* 00_setup.do -- revisao EJPE: caminhos, semente, pacotes, estilo grafico e rotinas comuns
* Chamado no topo de todo do-file de code/revisao/. Nao instala nada (ver 00_instala.do).
version 17
clear all
set more off
set seed 20261017
set sortseed 20261017
set maxvar 30000
set linesize 200
if "$ROOT" == "" global ROOT "`c(pwd)'"
global RAW     "$ROOT/data/raw"
global FINAL   "$ROOT/data/final"
global RINT    "$ROOT/data/interim/revisao"
global RTAB    "$ROOT/output/revisao/tables"
global RFIG    "$ROOT/output/revisao/figures"
global RLOG    "$ROOT/output/revisao/logs"
global RCAP    "$ROOT/output/revisao/logs/captions"
global DOCS    "$ROOT/docs"
foreach d in "$ROOT/data/interim" "$RINT" "$ROOT/output/revisao" "$RTAB" "$RFIG" "$RLOG" "$RCAP" {
    capture mkdir "`d'"
}
* pacotes comunitarios do projeto (instalados por 00_instala.do)
sysdir set PLUS "$ROOT/ado/plus"
adopath ++ "$ROOT/ado/plus"
foreach c in reghdfe ftools ivreghdfe ivreg2 ranktest xtscc xtabond2 xtdpdgmm xtdpdbc boottest rwolf2 ///
    weakivtest weakiv twostepweakiv xthenreg xthreg interflex xtpmg xtdcce2 xtcd2 bma wals estout coefplot {
    capture which `c'
    if _rc {
        di as error "pacote ausente: `c' (rodar code/revisao/00_instala.do)"
        exit 199
    }
}

* ---------------------------------------------------------------- estilo grafico (impressao em preto e branco)
set scheme plotplain
graph set window fontface "Arial"
graph set ps fontface "Arial"
global GOPT "graphregion(color(white) margin(small)) plotregion(color(white) lcolor(none)) ylabel(, nogrid labsize(8pt) angle(horizontal)) xlabel(, labsize(8pt)) legend(size(8pt) region(lcolor(none)))"
* defasagem maxima de Driscoll-Kraay usada em todo o painel anual (T = 28: floor(4 (28/100)^(2/9)) = 3)
global DKLAG 3

* ---------------------------------------------------------------- registro chave-valor (numeros do relatorio)
* rv_kv chave valor  -> acrescenta "chave,valor" em $RINT/kv.csv (lido pelos relatorios; nada e digitado)
capture program drop rv_kv
program define rv_kv
    args key val
    tempname F
    capture confirm file "$RINT/kv.csv"
    if _rc {
        file open `F' using "$RINT/kv.csv", write text replace
        file write `F' "key,value" _n
    }
    else file open `F' using "$RINT/kv.csv", write text append
    file write `F' `"`key',`val'"' _n
    file close `F'
end

* ---------------------------------------------------------------- filtros de tendencia do log do PIB real
* Hamilton (2018): tendencia em t = projecao de y_t em y_{t-H}, ..., y_{t-H-k+1} (por pais; predeterminada)
capture program drop rv_hamilton
program define rv_hamilton
    syntax varname, gen(name) [H(integer 2) K(integer 2) minobs(integer 10)]
    quietly gen double `gen' = .
    quietly levelsof id, local(ids)
    local last = `h' + `k' - 1
    foreach i of local ids {
        capture quietly regress `varlist' L(`h'/`last').`varlist' if id == `i'
        if !_rc & e(N) >= `minobs' {
            tempvar p
            quietly predict double `p' if id == `i' & e(sample), xb
            quietly replace `gen' = `p' if id == `i'
            drop `p'
        }
    }
end

* HP unilateral (recursivo): para cada t, HP(lambda) na janela [inicio, t] e guarda so o ultimo ponto
capture program drop rv_hp1s
program define rv_hp1s
    syntax varname, gen(name) [lambda(real 6.25) minobs(integer 8)]
    quietly gen double `gen' = .
    sort id year
    mata: _hp1s("`varlist'", "id", "`gen'", `lambda', `minobs')
end
mata:
void _hp1s(string scalar yv, string scalar idv, string scalar outv, real scalar lambda, real scalar minT)
{
    real colvector y, id, out, sel, ys, tr
    real scalar i, n, t, T
    real matrix D, A
    y = st_data(., yv)
    id = st_data(., idv)
    out = J(rows(y), 1, .)
    for (i = min(id); i <= max(id); i++) {
        sel = selectindex((id :== i) :& (y :< .))
        T = rows(sel)
        if (T < minT) continue
        for (t = minT; t <= T; t++) {
            ys = y[sel[1..t]]
            D = J(t - 2, t, 0)
            for (n = 1; n <= t - 2; n++) D[n, (n, n + 1, n + 2)] = (1, -2, 1)
            A = I(t) + lambda * D' * D
            tr = lusolve(A, ys)
            out[sel[t]] = tr[t]
        }
    }
    st_store(., outv, out)
}
end

* HP bilateral (mesmo do draft 7), para comparacao
capture program drop rv_hp2s
program define rv_hp2s
    syntax varname, gen(name) [lambda(real 6.25) minobs(integer 8)]
    quietly gen double `gen' = .
    sort id year
    mata: _hp2s("`varlist'", "id", "`gen'", `lambda', `minobs')
end
mata:
void _hp2s(string scalar yv, string scalar idv, string scalar outv, real scalar lambda, real scalar minT)
{
    real colvector y, id, out, sel, ys
    real scalar i, n, T
    real matrix D, A
    y = st_data(., yv)
    id = st_data(., idv)
    out = J(rows(y), 1, .)
    for (i = min(id); i <= max(id); i++) {
        sel = selectindex((id :== i) :& (y :< .))
        T = rows(sel)
        if (T < minT) continue
        ys = y[sel]
        D = J(T - 2, T, 0)
        for (n = 1; n <= T - 2; n++) D[n, (n, n + 1, n + 2)] = (1, -2, 1)
        A = I(T) + lambda * D' * D
        out[sel] = lusolve(A, ys)
    }
    st_store(., outv, out)
}
end

* ---------------------------------------------------------------- tabelas (grade em Mata -> .tex booktabs e .docx)
* rv_new, ncol() head1() head2()       zera a grade
* rv_row "rotulo" "c1" "c2" ...        linha livre
* rv_mid                               linha horizontal apos a ultima linha
* rv_bse "rotulo" b se p [b se p ...]  coeficiente com estrelas e EP abaixo (p = . -> normal)
* rv_estrow "rotulo", models() vars()  coeficientes de estimativas guardadas (uma variavel por modelo ou uma so)
* rv_stat "rotulo", models() stat() [fmt()]
* rv_out arquivo, title() notes() [landscape]
capture program drop rv_new
program define rv_new
    syntax , ncol(integer) [head1(string asis) head2(string asis) head3(string asis)]
    mata: RV = J(0, `ncol' + 1, ""); RVH = J(0, `ncol' + 1, ""); RVMID = J(0, 1, .)
    if `"`head1'"' != "" mata: RVH = RVH \ ("" , _rvuntok(tokens(`"`head1'"')))
    if `"`head2'"' != "" mata: RVH = RVH \ ("" , _rvuntok(tokens(`"`head2'"')))
    if `"`head3'"' != "" mata: RVH = RVH \ ("" , _rvuntok(tokens(`"`head3'"')))
end

capture program drop rv_row
program define rv_row
    gettoken lab rest : 0
    local cells ""
    while `"`rest'"' != "" {
        gettoken c rest : rest
        local cells `"`cells' `"`c'"'"'
    }
    mata: _rvadd(`"`lab'"', `"`cells'"')
end

capture program drop rv_mid
program define rv_mid
    mata: RVMID = RVMID \ rows(RV)
end

* formatacao de numero: sinal de menos U+2212, 3 casas (ou fmt), estrelas por p
capture program drop rv_fmt
program define rv_fmt, rclass
    args x fmt p
    if "`fmt'" == "" local fmt "%12.3f"
    if missing(`x') {
        return local s ""
        exit
    }
    local s : display `fmt' `x'
    local s = strtrim("`s'")
    if substr("`s'", 1, 1) == "-" local s = uchar(8722) + substr("`s'", 2, .)
    if "`p'" != "" & "`p'" != "." {
        if `p' < 0.01 local s "`s'***"
        else if `p' < 0.05 local s "`s'**"
        else if `p' < 0.10 local s "`s'*"
    }
    return local s "`s'"
end

capture program drop rv_bse
program define rv_bse
    gettoken lab rest : 0
    local brow ""
    local srow ""
    while `"`rest'"' != "" {
        gettoken b rest : rest
        gettoken se rest : rest
        gettoken p rest : rest
        if "`b'" == "" | "`b'" == "." {
            local brow `"`brow' """'
            local srow `"`srow' """'
            continue
        }
        if "`p'" == "." | "`p'" == "" local p = 2 * normal(-abs(`b' / `se'))
        rv_fmt `b' %12.3f `p'
        local bs "`r(s)'"
        rv_fmt `se' %12.3f
        local ss "(`r(s)')"
        local brow `"`brow' "`bs'""'
        local srow `"`srow' "`ss'""'
    }
    mata: _rvadd(`"`lab'"', `"`brow'"')
    mata: _rvadd("", `"`srow'"')
end

capture program drop rv_estrow
program define rv_estrow
    * rv_estrow "rotulo", models(m1 m2) vars(v) [noserow]
    gettoken lab 0 : 0, parse(",")
    syntax , models(string) vars(string) [noSErow dfnormal]
    local nm : word count `models'
    local nv : word count `vars'
    local brow ""
    local srow ""
    forvalues j = 1/`nm' {
        local m : word `j' of `models'
        local v : word `=cond(`nv' == 1, 1, `j')' of `vars'
        if "`m'" == "." | "`v'" == "." {
            local brow `"`brow' """'
            local srow `"`srow' """'
            continue
        }
        quietly estimates restore `m'
        local cn : colnames e(b)
        local found : list v in cn
        capture local b = _b[`v']
        if _rc | !`found' {
            local brow `"`brow' """'
            local srow `"`srow' """'
            continue
        }
        local se = _se[`v']
        if `se' == 0 | missing(`se') {
            local brow `"`brow' """'
            local srow `"`srow' """'
            continue
        }
        local df = e(df_r)
        if missing(`df') | "`dfnormal'" != "" local p = 2 * normal(-abs(`b' / `se'))
        else local p = 2 * ttail(`df', abs(`b' / `se'))
        rv_fmt `b' %12.3f `p'
        local brow `"`brow' "`r(s)'""'
        rv_fmt `se' %12.3f
        local srow `"`srow' "(`r(s)')""'
    }
    mata: _rvadd(`"`lab'"', `"`brow'"')
    if "`serow'" != "noserow" mata: _rvadd("", `"`srow'"')
end

capture program drop rv_stat
program define rv_stat
    gettoken lab 0 : 0, parse(",")
    syntax , models(string) stat(string) [fmt(string)]
    if "`fmt'" == "" local fmt "%12.0fc"
    local row ""
    foreach m of local models {
        if "`m'" == "." {
            local row `"`row' """'
            continue
        }
        quietly estimates restore `m'
        local x = e(`stat')
        rv_fmt `x' `fmt'
        local row `"`row' "`r(s)'""'
    }
    mata: _rvadd(`"`lab'"', `"`row'"')
end

capture program drop rv_out
program define rv_out
    syntax anything(name=fname), title(string) [notes(string) landscape]
    local fname `fname'
    mata: _rvtex("$RTAB/`fname'.tex", `"`title'"', `"`notes'"', "`fname'")
    mata: st_local("nr", strofreal(rows(RVH) + rows(RV))); st_local("nc", strofreal(cols(RV)))
    putdocx clear
    putdocx begin, pagesize(A4) `=cond("`landscape'" != "", "landscape", "")' font("Times New Roman", 9)
    putdocx paragraph, spacing(after, 4pt)
    putdocx text (`"`title'"'), bold
    putdocx table T = (`nr', `nc'), border(all, nil) border(top, single) border(bottom, single) layout(autofitcontents)
    mata: _rvdocx()
    if `"`notes'"' != "" {
        putdocx paragraph, spacing(before, 4pt)
        putdocx text ("Notes: "), italic font("Times New Roman", 8)
        putdocx text (`"`notes'"'), font("Times New Roman", 8)
    }
    putdocx save "$RTAB/`fname'.docx", replace
    tempname C
    file open `C' using "$RCAP/`fname'.txt", write replace text
    file write `C' `"`title'"' _n `"`notes'"' _n
    file close `C'
    di as text "tabela gravada: $RTAB/`fname'.{tex,docx}"
end

mata:
string rowvector _rvuntok(string rowvector t)
{
    real scalar i
    string scalar x
    for (i = 1; i <= cols(t); i++) {
        x = t[i]
        if (substr(x, 1, 2) == char(96) + char(34) & substr(x, -2, 2) == char(34) + char(39)) x = substr(x, 3, strlen(x) - 4)
        else if (substr(x, 1, 1) == char(34) & substr(x, -1, 1) == char(34)) x = substr(x, 2, strlen(x) - 2)
        t[i] = x
    }
    return(t)
}
void _rvadd(string scalar lab, string scalar cells)
{
    external string matrix RV
    string rowvector c
    real scalar k
    c = _rvuntok(tokens(cells))
    k = cols(RV) - 1
    if (cols(c) == 0) c = J(1, k, "")
    if (cols(c) < k) c = c, J(1, k - cols(c), "")
    RV = RV \ (lab, c[1..k])
}
string scalar _rvesc(string scalar s, | real scalar nostars)
{
    string scalar r
    r = subinstr(s, "\", "\textbackslash{}")
    r = subinstr(r, "%", "\%")
    r = subinstr(r, "&", "\&")
    r = subinstr(r, "_", "\_")
    r = subinstr(r, "#", "\#")
    r = subinstr(r, uchar(8722), "$-$")
    r = subinstr(r, uchar(215), "$\times$")
    r = subinstr(r, uchar(8211), "--")
    r = subinstr(r, "R2", "\$R^2\$")
    if (nostars == 1) return(r)
    if (strpos(r, "***")) r = subinstr(r, "***", "\sym{***}")
    else if (strpos(r, "**")) r = subinstr(r, "**", "\sym{**}")
    else if (strpos(r, "*")) r = subinstr(r, "*", "\sym{*}")
    return(r)
}
void _rvtex(string scalar fn, string scalar title, string scalar notes, string scalar lbl)
{
    external string matrix RV, RVH
    external real colvector RVMID
    real scalar fh, i, j, k
    string scalar line
    k = cols(RV)
    if (fileexists(fn)) unlink(fn)
    fh = fopen(fn, "w")
    fput(fh, "% generated by the Stata code of the project (Stata 17) -- do not edit by hand")
    fput(fh, "\begin{table}[htbp]\centering\footnotesize")
    fput(fh, "\providecommand{\sym}[1]{\ensuremath{^{#1}}}")
    fput(fh, "\caption{" + _rvesc(title, 1) + "}\label{tab:" + lbl + "}")
    fput(fh, "\begin{tabular}{l*{" + strofreal(k - 1) + "}{c}}")
    fput(fh, "\toprule")
    for (i = 1; i <= rows(RVH); i++) {
        line = _rvesc(RVH[i, 1], 1)
        for (j = 2; j <= k; j++) line = line + " & " + _rvesc(RVH[i, j], 1)
        fput(fh, line + " \\")
    }
    if (rows(RVH) > 0) fput(fh, "\midrule")
    for (i = 1; i <= rows(RV); i++) {
        line = _rvesc(RV[i, 1], 1)
        for (j = 2; j <= k; j++) line = line + " & " + _rvesc(RV[i, j])
        fput(fh, line + " \\")
        if (anyof(RVMID, i)) fput(fh, "\midrule")
    }
    fput(fh, "\bottomrule")
    fput(fh, "\end{tabular}")
    if (notes != "") fput(fh, "\begin{minipage}{0.95\linewidth}\vspace{4pt}\scriptsize \textit{Notes:} " + _rvesc(notes, 1) + "\end{minipage}")
    fput(fh, "\end{table}")
    fclose(fh)
}
void _rvdocx()
{
    external string matrix RV, RVH
    external real colvector RVMID
    real scalar i, j, h
    string scalar cmd, txt
    h = rows(RVH)
    for (i = 1; i <= h + rows(RV); i++) {
        for (j = 1; j <= cols(RV); j++) {
            txt = (i <= h ? RVH[i, j] : RV[i - h, j])
            if (txt == "") continue
            txt = subinstr(txt, char(34), "'")
            txt = subinstr(txt, "R2", "R" + uchar(178))
            cmd = "putdocx table T(" + strofreal(i) + "," + strofreal(j) + ") = (" + char(96) + char(34) + txt + char(34) + char(39) + ")"
            if (j > 1) cmd = cmd + ", halign(center)"
            stata(cmd)
        }
        if (i == h & h > 0) stata("putdocx table T(" + strofreal(i) + ",.), border(bottom, single)")
        if (i > h) {
            if (anyof(RVMID, i - h)) stata("putdocx table T(" + strofreal(i) + ",.), border(bottom, single)")
        }
    }
}
end

* ---------------------------------------------------------------- figuras
capture program drop rv_fig
program define rv_fig
    * rv_fig nome, width(90|190) height(mm): PDF vetorial e PNG a 600 dpi
    syntax anything(name=fname), width(integer) height(integer)
    local fname `fname'
    local win = `width' / 25.4
    local hin = `height' / 25.4
    graph display, xsize(`win') ysize(`hin')
    graph export "$RFIG/`fname'.pdf", replace
    graph export "$RFIG/`fname'.png", replace width(`=round(`win' * 600)')
    graph export "$RFIG/`fname'.eps", replace as(eps)
    di as text "figura gravada: $RFIG/`fname'.{pdf,png,eps} (`width' x `height' mm)"
end

* ---------------------------------------------------------------- wild cluster bootstrap padronizado
* rv_boot var [, reps(9999) weight(webb)]: depois de reghdfe/regress com vce(cluster id); devolve r(p), r(lo), r(hi)
capture program drop rv_boot
program define rv_boot, rclass
    syntax anything(name=v) [, reps(integer 9999) weight(string)]
    if "`weight'" == "" local weight "webb"
    quietly boottest `v', reps(`reps') weighttype(`weight') seed(20261017) nograph
    return scalar p = r(p)
    capture matrix CI = r(CI)
    if !_rc {
        return scalar lo = CI[1, 1]
        return scalar hi = CI[1, 2]
    }
end
