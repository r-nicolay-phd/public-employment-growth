* wsim_mata.do -- funcao Mata da folha sintetica (Bloco 6)
capture mata: mata drop _wsim()
mata:
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
end
