* sim2_mata.do -- funcoes Mata das simulacoes (Blocos 1 e 4)
capture mata: mata drop _drawc()
capture mata: mata drop _wsim()
capture mata: mata drop _stat()
capture mata: mata drop _fwlb()
capture mata: mata drop _fwlrecode()
capture mata: mata drop FWLC
mata:
// recodifica uma variavel de grupo em 1..K
real colvector _fwlrecode(real colvector f)
{
    real colvector u, out
    real scalar i
    u = uniqrows(f)
    out = J(rows(f), 1, .)
    for (i = 1; i <= rows(f); i++) {
        out[i] = sum(u :<= f[i])
    }
    return(out)
}
// coeficientes MQO por Frisch-Waugh com projecao guardada (os controles e os efeitos fixos nao mudam entre replicacoes):
// y = X b + Z c, Z = [controles fixos, dummies de fe1 e fe2, constante]; so X muda. A projecao fica em cache por chave e
// e refeita se o padrao de observacoes nao faltantes mudar. Devolve b em st_matrix(outm). Igual a reghdfe (pontual).
void _fwlb(string scalar key, string scalar yv, string scalar xvs, string scalar zvs, string scalar fe1, string scalar fe2, string scalar touse, string scalar outm)
{
    external transmorphic FWLC
    real colvector y, ok, sel, f, My
    real matrix X, Zc, Z, A, MX, D, cached
    real scalar hit
    pointer(real matrix) rowvector pp
    if (rows(FWLC) == 0) FWLC = asarray_create()
    y = st_data(., yv, touse)
    X = st_data(., tokens(xvs), touse)
    Zc = (zvs == "" ? J(rows(y), 0, .) : st_data(., tokens(zvs), touse))
    ok = rowmissing((y, X, Zc)) :== 0
    hit = 0
    if (asarray_contains(FWLC, key)) {
        pp = asarray(FWLC, key)
        if (rows(*pp[1]) == rows(ok)) {
            if (*pp[1] == ok) hit = 1
        }
    }
    sel = selectindex(ok)
    if (!hit) {
        Z = Zc[sel, .]
        f = st_data(., fe1, touse)
        D = designmatrix(_fwlrecode(f[sel]))
        Z = Z, D[., 2..cols(D)]
        if (fe2 != "") {
            f = st_data(., fe2, touse)
            D = designmatrix(_fwlrecode(f[sel]))
            Z = Z, D[., 2..cols(D)]
        }
        Z = Z, J(rows(Z), 1, 1)
        A = invsym(cross(Z, Z)) * Z'
        My = y[sel] - Z * (A * y[sel])
        pp = (&(ok :+ 0), &(Z :+ 0), &(A :+ 0), &(My :+ 0))
        asarray(FWLC, key, pp)
        pp = asarray(FWLC, key)
    }
    X = X[sel, .]
    MX = X - (*pp[2]) * ((*pp[3]) * X)
    st_matrix(outm, (invsym(cross(MX, MX)) * cross(MX, *pp[4]))')
}
// sorteia, com reposicao, um valor do proprio pais (pool = valores nao faltantes de ev) para cada linha com ok == 1
void _drawc(string scalar idv, string scalar ev, string scalar okv, string scalar outv)
{
    real colvector id, e, ok, out, pool, ee
    real matrix info
    real scalar i, p, q, r, n
    id = st_data(., idv)
    e = st_data(., ev)
    ok = st_data(., okv)
    out = J(rows(id), 1, .)
    info = panelsetup(id, 1)
    for (i = 1; i <= rows(info); i++) {
        p = info[i, 1]
        q = info[i, 2]
        ee = e[|p \ q|]
        pool = select(ee, ee :< .)
        n = rows(pool)
        if (n == 0) continue
        for (r = p; r <= q; r++) {
            if (ok[r] == 1) out[r] = pool[ceil(runiform(1, 1) * n)]
        }
    }
    st_store(., outv, out)
}
// variante registrada (Tabela A5 antiga): passeio aleatorio em ln W desde o primeiro ano do pais
void _wsim(string scalar idv, string scalar uv, string scalar dyv, string scalar w0v, string scalar outv, real scalar eps)
{
    real colvector id, u, dy, w0, out, pool, uu
    real matrix info
    real scalar i, a, b, f, r, cur, k, n
    id = st_data(., idv)
    u = st_data(., uv)
    dy = st_data(., dyv)
    w0 = st_data(., w0v)
    out = J(rows(id), 1, .)
    info = panelsetup(id, 1)
    for (i = 1; i <= rows(info); i++) {
        a = info[i, 1]
        b = info[i, 2]
        uu = u[|a \ b|]
        pool = select(uu, uu :< .)
        n = rows(pool)
        if (n == 0) continue
        f = .
        for (r = a; r <= b; r++) {
            if (w0[r] < .) {
                f = r
                break
            }
        }
        if (f >= .) continue
        cur = w0[f]
        out[f] = cur
        for (r = f + 1; r <= b; r++) {
            if (dy[r] >= . | cur >= .) {
                cur = .
            }
            else {
                k = ceil(runiform(1, 1) * n)
                cur = cur + eps * dy[r] + pool[k]
            }
            out[r] = cur
        }
    }
    st_store(., outv, out)
}
// variante estacionaria: ln s_t = mu + rho (ln s_t-1 - mu) - (1 - eps) dy_t + u_t; reinicia no valor observado
void _stat(string scalar idv, string scalar lsv, string scalar dyv, string scalar ev, string scalar muv, string scalar outv, real scalar rho, real scalar eps)
{
    real colvector id, ls, dy, e, mu, out, pool, ee
    real matrix info
    real scalar i, a, b, r, cur, n
    id = st_data(., idv)
    ls = st_data(., lsv)
    dy = st_data(., dyv)
    e = st_data(., ev)
    mu = st_data(., muv)
    out = J(rows(id), 1, .)
    info = panelsetup(id, 1)
    for (i = 1; i <= rows(info); i++) {
        a = info[i, 1]
        b = info[i, 2]
        ee = e[|a \ b|]
        pool = select(ee, ee :< .)
        n = rows(pool)
        if (n == 0) continue
        cur = .
        for (r = a; r <= b; r++) {
            if (cur < . & dy[r] < . & mu[r] < .) {
                cur = mu[r] + rho * (cur - mu[r]) - (1 - eps) * dy[r] + pool[ceil(runiform(1, 1) * n)]
            }
            else {
                cur = ls[r]
            }
            out[r] = cur
        }
    }
    st_store(., outv, out)
}
end
