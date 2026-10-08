* 00_tabelas.do -- utilitarios de tabelas e figuras para publicacao (chamado por 00_setup.do)
*
* Fluxo das tabelas:
*   1) tab_new                         -- zera a grade de strings (Mata: TAB)
*   2) tab_est m1 m2 ..., keep() ...   -- coeficientes, EP entre parenteses e estrelas a partir de estimativas
*      ou tab_row "rotulo" "c1" "c2"   -- linha livre (estatisticas descritivas, testes)
*   3) tab_stat nome "rotulo" fmt      -- linha de estatistica e(nome) de cada modelo
*   4) tab_out arquivo, title() notes() -- grava output/tables/arquivo.tex e .docx
* Rotulos legiveis das variaveis vem de globals LBL_<nome> (definidos em code/00_rotulos.do).

capture program drop tab_new
program define tab_new
    syntax , ncol(integer) [head1(string asis) head2(string asis)]
    mata: TAB = J(0, `ncol' + 1, ""); TABH = J(0, `ncol' + 1, ""); TABMID = J(0, 1, .)
    if `"`head1'"' != "" mata: TABH = TABH \ ("" , _untok(tokens(`"`head1'"')))
    if `"`head2'"' != "" mata: TABH = TABH \ ("" , _untok(tokens(`"`head2'"')))
    global TAB_MODELS ""
end

capture program drop tab_row
program define tab_row
    * tab_row "rotulo" "c1" "c2" ...
    local lab `"`1'"'
    macro shift
    local cells ""
    while `"`1'"' != "" {
        local cells `"`cells' `"`1'"'"'
        macro shift
    }
    mata: _tab_addrow(`"`lab'"', `"`cells'"')
end

capture program drop tab_mid
program define tab_mid
    * marca uma linha horizontal (midrule) depois da ultima linha ja inserida
    mata: TABMID = TABMID \ rows(TAB)
end

capture program drop tab_est
program define tab_est
    syntax namelist, keep(string) [dec(integer 3) noSE]
    global TAB_MODELS "`namelist'"
    foreach v of local keep {
        local lab "${LBL_`v'}"
        if "`lab'" == "" local lab "`v'"
        local brow ""
        local srow ""
        foreach m of local namelist {
            quietly estimates restore `m'
            capture local b = _b[`v']
            local miss = _rc != 0
            if !`miss' local miss = missing(`b') | (`b' == 0 & _se[`v'] == 0)
            if `miss' {
                local brow `"`brow' """'
                local srow `"`srow' """'
                continue
            }
            local sev = _se[`v']
            local df = e(df_r)
            if missing(`df') local p = 2 * normal(-abs(`b' / `sev'))
            else local p = 2 * ttail(`df', abs(`b' / `sev'))
            local st = cond(`p' < 0.01, "***", cond(`p' < 0.05, "**", cond(`p' < 0.10, "*", "")))
            local bs : display %12.`dec'f `b'
            local ss : display %12.`dec'f `sev'
            local bs = strtrim("`bs'")
            local ss = "(" + strtrim("`ss'") + ")"
            local brow `"`brow' "`bs'`st'""'
            local srow `"`srow' "`ss'""'
        }
        mata: _tab_addrow(`"`lab'"', `"`brow'"')
        if "`se'" != "nose" mata: _tab_addrow("", `"`srow'"')
    }
end

capture program drop tab_stat
program define tab_stat
    * tab_stat escalar "rotulo" formato   (escalar de e(); ausente fica em branco)
    args sc lab fmt
    if "`fmt'" == "" local fmt "%9.0fc"
    local row ""
    foreach m of global TAB_MODELS {
        quietly estimates restore `m'
        local x = e(`sc')
        if missing(`x') local row `"`row' """'
        else {
            local s : display `fmt' `x'
            local row `"`row' "`=strtrim("`s'")'""'
        }
    }
    mata: _tab_addrow(`"`lab'"', `"`row'"')
end

capture program drop tab_yesno
program define tab_yesno
    * tab_yesno "rotulo" "Yes" "No" ... (linha de indicadores de efeitos fixos etc.)
    tab_row `0'
end

capture program drop tab_out
program define tab_out
    syntax anything(name=fname), title(string) [notes(string) landscape colwidth(string)]
    local fname `fname'
    mata: _tab_tex("$TAB/`fname'.tex", `"`title'"', `"`notes'"', "`fname'")
    * docx
    mata: st_local("nr", strofreal(rows(TABH) + rows(TAB))); st_local("nc", strofreal(cols(TAB)))
    putdocx clear
    putdocx begin, pagesize(A4) `=cond("`landscape'" != "", "landscape", "")' font("Times New Roman", 10)
    putdocx paragraph, spacing(after, 4pt)
    putdocx text (`"`title'"'), bold
    putdocx table T = (`nr', `nc'), border(all, nil) border(top, single) border(bottom, single) layout(autofitcontents)
    mata: _tab_docx()
    if `"`notes'"' != "" {
        putdocx paragraph, spacing(before, 4pt)
        putdocx text (`"Notes: `notes'"'), font("Times New Roman", 9)
    }
    putdocx save "$TAB/`fname'.docx", replace
    di as text "tabela gravada: $TAB/`fname'.{tex,docx}"
end

mata:
string rowvector _untok(string rowvector t)
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

void _tab_addrow(string scalar lab, string scalar cells)
{
    external string matrix TAB
    string rowvector c
    real scalar k
    c = _untok(tokens(cells))
    if (cols(c) == 0) c = J(1, cols(TAB) - 1, "")
    k = cols(TAB) - 1
    if (cols(c) < k) c = c, J(1, k - cols(c), "")
    TAB = TAB \ (lab, c[1..k])
}

string scalar _texesc(string scalar s, | real scalar nostars)
{
    string scalar r
    r = subinstr(s, "\", "\textbackslash{}")
    r = subinstr(r, "%", "\%")
    r = subinstr(r, "&", "\&")
    r = subinstr(r, "_", "\_")
    r = subinstr(r, "#", "\#")
    r = subinstr(r, "$", "\$")
    r = subinstr(r, "R2", "\$R^2\$")
    if (nostars == 1) return(r)
    r = subinstr(r, "***", "\sym{***}")
    r = subinstr(r, "**}", "**}")
    if (strpos(r, "\sym{***}") == 0) {
        r = subinstr(r, "**", "\sym{**}")
        if (strpos(r, "\sym{**}") == 0) r = subinstr(r, "*", "\sym{*}")
    }
    return(r)
}

void _tab_tex(string scalar fn, string scalar title, string scalar notes, string scalar lbl)
{
    external string matrix TAB, TABH
    external real colvector TABMID
    real scalar fh, i, j, k
    string scalar line
    k = cols(TAB)
    if (fileexists(fn)) unlink(fn)
    fh = fopen(fn, "w")
    fput(fh, "% gerado por code/00_tabelas.do -- nao editar a mao")
    fput(fh, "\begin{table}[htbp]\centering\footnotesize")
    fput(fh, "\providecommand{\sym}[1]{\ensuremath{^{#1}}}")
    fput(fh, "\caption{" + _texesc(title) + "}\label{tab:" + lbl + "}")
    fput(fh, "\begin{tabular}{l*{" + strofreal(k - 1) + "}{c}}")
    fput(fh, "\toprule")
    for (i = 1; i <= rows(TABH); i++) {
        line = _texesc(TABH[i, 1])
        for (j = 2; j <= k; j++) line = line + " & " + _texesc(TABH[i, j])
        fput(fh, line + " \\")
    }
    if (rows(TABH) > 0) fput(fh, "\midrule")
    for (i = 1; i <= rows(TAB); i++) {
        line = _texesc(TAB[i, 1])
        for (j = 2; j <= k; j++) line = line + " & " + _texesc(TAB[i, j])
        fput(fh, line + " \\")
        if (anyof(TABMID, i)) fput(fh, "\midrule")
    }
    fput(fh, "\bottomrule")
    fput(fh, "\end{tabular}")
    if (notes != "") {
        fput(fh, "\begin{minipage}{0.95\linewidth}\vspace{4pt}\scriptsize \textit{Notes:} " + _texesc(notes, 1) + "\end{minipage}")
    }
    fput(fh, "\end{table}")
    fclose(fh)
}

void _tab_docx()
{
    external string matrix TAB, TABH
    external real colvector TABMID
    real scalar i, j, r, h
    string scalar cmd, txt
    h = rows(TABH)
    for (i = 1; i <= h + rows(TAB); i++) {
        for (j = 1; j <= cols(TAB); j++) {
            txt = (i <= h ? TABH[i, j] : TAB[i - h, j])
            if (txt == "") continue
            txt = subinstr(txt, `"""', "'")
            cmd = "putdocx table T(" + strofreal(i) + "," + strofreal(j) + ") = (" + char(96) + char(34) + txt + char(34) + char(39) + ")"
            if (j > 1) cmd = cmd + ", halign(center)"
            stata(cmd)
        }
        if (i == h & h > 0) stata("putdocx table T(" + strofreal(i) + ",.), border(bottom, single)")
        if (i > h) {
            if (anyof(TABMID, i - h)) stata("putdocx table T(" + strofreal(i) + ",.), border(bottom, single)")
        }
    }
}
end

* ---------------------------------------------------------------- figuras
capture program drop fig_export
program define fig_export
    * fig_export nome, width(90|190) height(mm)
    syntax anything(name=fname), width(integer) height(integer)
    local fname `fname'
    local win = `width' / 25.4
    local hin = `height' / 25.4
    graph display, xsize(`win') ysize(`hin')
    graph export "$FIG/`fname'.pdf", replace
    local px = round(`win' * 600)
    graph export "$FIG/`fname'.png", replace width(`px')
    di as text "figura gravada: $FIG/`fname'.{pdf,png} (`width' x `height' mm)"
end
