* 00_lp.do -- projecoes locais (Jorda, 2005) em painel, com erros de Driscoll-Kraay (xtscc)
*
* lpirf, y(var) shocks(varlist) [state(var) h(6) gl(var) controls(varlist) saving(file) cond(string)]
*   resposta acumulada: F^h.y - L.y, h = 0..H
*   regressores: choques em t, duas defasagens de cada choque, duas defasagens de gl (crescimento),
*   controles opcionais, efeitos fixos de pais e de ano.
*   state(): variavel 0/1 medida antes do choque; cada choque entra interagido com estado alto e baixo
*   (as defasagens entram comuns) e o teste de diferenca por horizonte e gravado.
* Grava em saving(): h, choque, b, se, lo, hi (IC 95%), graus de liberdade, N, paises e, com state(), p da diferenca.

capture program drop lpirf
program define lpirf
    syntax , y(varname) shocks(varlist) saving(string) [state(varname) h(integer 6) gl(varname) ///
        controls(varlist) cond(string) lags(integer 2)]
    if "`gl'" == "" local gl g
    if `"`cond'"' == "" local cond "1"
    tempname P
    tempfile out
    postfile `P' int h str32 shock str8 regime double(b se lo hi pdiff df) int(N nc) using `out', replace
    forvalues hh = 0/`h' {
        tempvar dy
        quietly gen double `dy' = F`hh'.`y' - L.`y'
        local rhs ""
        local lagterms ""
        foreach s of local shocks {
            local lagterms `lagterms' L(1/`lags').`s'
        }
        local lagterms `lagterms' L(1/`lags').`gl'
        if "`state'" == "" {
            quietly xtscc `dy' `shocks' `lagterms' `controls' i.year if `cond', fe
            foreach s of local shocks {
                local b = _b[`s']
                local se = _se[`s']
                local df = e(df_r)
                post `P' (`hh') ("`s'") ("all") (`b') (`se') (`b' - invttail(`df', 0.025) * `se') ///
                    (`b' + invttail(`df', 0.025) * `se') (.) (`df') (e(N)) (e(N_g))
            }
        }
        else {
            local inter ""
            foreach s of local shocks {
                tempvar hi lo
                quietly gen double `hi' = `s' * (`state' == 1) if !missing(`state')
                quietly gen double `lo' = `s' * (`state' == 0) if !missing(`state')
                local inter `inter' `hi' `lo'
                local hi_`s' `hi'
                local lo_`s' `lo'
            }
            quietly xtscc `dy' `inter' i.`state' `lagterms' `controls' i.year if `cond', fe
            local df = e(df_r)
            foreach s of local shocks {
                quietly test `hi_`s'' = `lo_`s''
                local pd = r(p)
                foreach r in hi lo {
                    local b = _b[``r'_`s'']
                    local se = _se[``r'_`s'']
                    post `P' (`hh') ("`s'") ("`r'") (`b') (`se') (`b' - invttail(`df', 0.025) * `se') ///
                        (`b' + invttail(`df', 0.025) * `se') (`pd') (`df') (e(N)) (e(N_g))
                }
            }
        }
        drop `dy'
    }
    postclose `P'
    preserve
    use `out', clear
    save "`saving'", replace
    list, sepby(shock regime) noobs
    restore
end
