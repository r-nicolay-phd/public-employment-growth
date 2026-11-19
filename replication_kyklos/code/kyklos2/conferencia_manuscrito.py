"""Bloco 8, item 6: confere os numeros citados no manuscrito (versao 4) contra os .csv e registros gerados pelo codigo.

Uso (from the package root):  python code/kyklos2/conferencia_manuscrito.py
Grava output/kyklos2/tables/conferencia_manuscrito.csv e .md (numero x fonte x valor no csv x situacao).
Nenhum numero e digitado: cada valor e lido de output/kyklos/tables/*.csv ou de data/interim/*/kv.csv.
"""
import csv
from pathlib import Path

import pandas as pd

ROOT = Path.cwd()
T1 = ROOT / "output" / "generated" / "kyklos" / "tables"
OUT = ROOT / "output" / "generated" / "kyklos2" / "tables"


def kv(sub):
    d = {}
    with open(ROOT / "data" / "analysis" / {"revisao": "intermediate"}.get(sub, sub) / "kv.csv", encoding="utf-8") as f:
        r = csv.reader(f)
        next(r)
        for row in r:
            if len(row) >= 2:
                d[row[0]] = ",".join(row[1:])
    return d


KR = kv("revisao")
KK = kv("kyklos")


def c(name):
    return pd.read_csv(T1 / name)


def row(df, **cond):
    m = pd.Series(True, index=df.index)
    for k, v in cond.items():
        m &= df[k] == v
    r = df[m]
    assert len(r) == 1, (cond, len(r))
    return r.iloc[0]


s20 = c("TabS20_spending_items.csv")
s21 = c("TabS21_five_year_grid.csv")
s22 = c("TabS22_h2_strict.csv")
s23 = c("TabS23_lp_predetermined.csv")
s25e = c("TabS25_equivalence.csv")
s25i = c("TabS25_influence.csv")
s26d = c("TabS26_inst_differences.csv")
s26m = c("TabS26_inst_mechanism.csv")
s27 = c("TabS27_coverage.csv")
s28 = c("TabS28_checks.csv")

wb = row(s20, item="wb", meas="m1")
loo = s25i[s25i.kind == "loo_c"]
gm = lambda dep, meas, ctrl, swap="none": row(s21, dep=dep, meas=meas, ctrl=ctrl, swap=swap)

# (numero no manuscrito, casas, fonte, valor)
L = [
    ("Tabela 1", "−0,72", 2, "TabS20 (wb, m1) = Tabela 1, mesmo ano: b", wb.b),
    ("Tabela 1", "[−1,01; −0,44]", 2, "idem: IC de 95%", (wb.lo, wb.hi)),
    ("Tabela 1", "−0,02", 2, "TabS20 (wb, m3): Hamilton", row(s20, item="wb", meas="m3").b),
    ("Tabela 1", "−0,001", 3, "TabS20 (wb, m5): defasada", row(s20, item="wb", meas="m5").b),
    ("Tabela 1", "−0,42", 2, "TabS20 (wb, m4): HP unilateral", row(s20, item="wb", meas="m4").b),
    ("Tabela 1", "0,965", 3, "kv revisao corr_lag_ham", float(KR["corr_lag_ham"])),
    ("Tabela A6", "0,86", 2, "kv kyklos ver_corr_hp1", float(KK["ver_corr_hp1"])),
    ("Tabela A6", "0,08", 2, "kv kyklos ver_corr_ham", float(KK["ver_corr_ham"])),
    ("Tabela A6", "−0,40", 2, "TabS28 rec_neg: b", row(s28, chk="rec_neg").b),
    ("Tabela A6", "−0,89", 2, "TabS28 rec_pos: b", row(s28, chk="rec_pos").b),
    ("Tabela A6", "−0,13", 2, "TabS28 antic: b", row(s28, chk="antic").b),
    ("Tabela A5", "−0,20", 2, "kv kyklos sim_logdec_eff", float(KK["sim_logdec_eff"])),
    ("Tabela A5", "[−0,36; −0,04]", 2, "kv kyklos sim_logdec_lo/hi", (float(KK["sim_logdec_lo"]), float(KK["sim_logdec_hi"]))),
    ("Tabela A8", "−0,32", 2, "TabS21 g, wb_mean, controles em t_p − 1", gm("g", "wb_mean", "m1").b),
    ("Tabela A8", "−0,22", 2, "TabS21 g, wb_tp, controles em t_p − 1", gm("g", "wb_tp", "m1").b),
    ("Tabela A8", "−0,16", 2, "TabS21 g, wb_m1, controles em t_p − 1", gm("g", "wb_m1", "m1").b),
    ("Tabela A8", "−0,15", 2, "TabS21 g, wb_ham_m1, controles em t_p − 1", gm("g", "wb_ham_m1", "m1").b),
    ("Tabela A8", "−0,18", 2, "TabS21 g, wb_tp, controles da média", gm("g", "wb_tp", "mean").b),
    ("Tabela A8", "−0,10", 2, "TabS21 g, wb_m1, controles da média", gm("g", "wb_m1", "mean").b),
    ("Tabela A8", "29%", 0, "kv kyklos grid_red (×100)", 100 * float(KK["grid_red"])),
    ("Tabela A8", "45%", 0, "kv kyklos grid_red_meanctrl (×100)", 100 * float(KK["grid_red_meanctrl"])),
    ("Tabela A8", "investimento −0,10 → −0,16", 2, "TabS21 wb_m1 controles da média → troca do investimento",
     (gm("g", "wb_m1", "mean").b, gm("g", "wb_m1", "swap", "inv").b)),
    ("Tabelas A9/A10", "T3 −0,14", 2, "TabS25_equivalence T3: b", row(s25e, spec="T3").b),
    ("Tabelas A9/A10", "EP 0,071", 3, "TabS25_equivalence T3: se", row(s25e, spec="T3").se),
    ("Tabelas A9/A10", "p de bootstrap 0,120", 3, "kv revisao T3_own_pboot", float(KR["T3_own_pboot"])),
    ("Tabelas A9/A10", "Romano-Wolf 0,426", 3, "kv revisao rw_H1", float(KR["rw_H1"])),
    ("Tabelas A9/A10", "[−0,26; −0,02] (IC 90)", 2, "TabS25_equivalence T3: lo90/hi90",
     (row(s25e, spec="T3").lo90, row(s25e, spec="T3").hi90)),
    ("Tabelas A9/A10", "MDE 0,20", 2, "TabS25_equivalence T3: mde", row(s25e, spec="T3").mde),
    ("Tabelas A9/A10", "−0,08 (desde 1994)", 2, "TabS25_influence early (excl. 1979–1993): b", row(s25i, kind="early").b),
    ("Tabelas A9/A10", "32 de 68", 0, "TabS25_influence: amostras sem um país com p < 0,05 (de 68)",
     ((loo.p < 0.05).sum(), len(loo))),
    ("Tabelas 2/A13", "−0,14", 2, "TabS27 b_all_gg: est", row(s27, stat="b_all_gg").est),
    ("Tabelas 2/A13", "[−0,29; 0,03]", 2, "TabS27 b_all_gg: lo/hi", (row(s27, stat="b_all_gg").lo, row(s27, stat="b_all_gg").hi)),
    ("Tabelas 2/A13", "0,03", 2, "TabS27 b_all_cg: est", row(s27, stat="b_all_cg").est),
    ("Tabelas 2/A13", "[−0,20; 0,26]", 2, "TabS27 b_all_cg: lo/hi", (row(s27, stat="b_all_cg").lo, row(s27, stat="b_all_cg").hi)),
    ("Tabelas 2/A13", "−0,17 (p = 0,066)", 3, "TabS27 d_all: est e p", (row(s27, stat="d_all").est, row(s27, stat="d_all").p)),
    ("Tabelas 2/A13", "0,353 (p = 0,226)", 3, "TabS27 did: est e p", (row(s27, stat="did").est, row(s27, stat="did").p)),
    ("Tabelas A14/A15", "−2,33", 2, "kv revisao mvf_ge_full_common_c_bX", float(KR["mvf_ge_full_common_c_bX"])),
    ("Tabelas A14/A15", "−0,04", 2, "kv revisao mvf_ge_full_common_h_bX", float(KR["mvf_ge_full_common_h_bX"])),
    ("Tabelas A14/A15", "−0,11", 2, "kv revisao mvf_ge_full_common_l_bX", float(KR["mvf_ge_full_common_l_bX"])),
    ("Tabelas A14/A15", "−0,20 (p = 0,011)", 3, "TabS26_inst_differences C, lag: d e p",
     (row(s26d, panel="C", dif="lag").d, row(s26d, panel="C", dif="lag").p)),
    ("Tabelas A14/A15", "−0,12 (p = 0,146)", 3, "TabS26_inst_differences C, trend: d e p (texto: −0,12)",
     (row(s26d, panel="C", dif="trend").d, row(s26d, panel="C", dif="trend").p)),
    ("Tabelas A14/A15", "elasticidade −0,18", 2, "TabS26_inst_mechanism a, dlC, inst: b", row(s26m, cond="a", v="dlC", inst="inst").b),
    ("Tabelas A14/A15", "elasticidade −0,16", 2, "TabS26_inst_mechanism a, dlW, inst: b", row(s26m, cond="a", v="dlW", inst="inst").b),
    ("Tabelas 3/A17", "−3,71", 2, "TabS22 reg, lpe: b", row(s22, spec="reg", v="lpe").b),
    ("Tabelas 3/A17", "−5,39", 2, "TabS22 reg, lrw: b", row(s22, spec="reg", v="lrw").b),
    ("Tabelas 3/A17", "−4,38", 2, "TabS22 a, lrw: b", row(s22, spec="a", v="lrw").b),
    ("Tabelas 3/A17", "−4,09", 2, "TabS22 c, lrwh: b", row(s22, spec="c", v="lrwh").b),
    ("Tabelas 3/A17", "−1,86 (p = 0,063)", 3, "TabS22 bW, lrw: b e p de bootstrap", (row(s22, spec="bW", v="lrw").b, row(s22, spec="bW", v="lrw").pboot)),
    ("Tabelas 3/A17", "F 6,6", 1, "TabS22 d: Feff", row(s22, spec="d", v="lrw").Feff),
    ("Tabelas 3/A17", "prêmio −0,08 (p = 0,79)", 2, "TabS22 e, prem01: b e p de bootstrap", (row(s22, spec="e", v="prem01").b, row(s22, spec="e", v="prem01").pboot)),
    ("Tabela A18", "−0,21 (p = 0,028)", 3, "TabS23 sa, h = 1, dk: b e p", (row(s23, shock="sa", h=1, inf="dk").b, row(s23, shock="sa", h=1, inf="dk").p)),
    ("Tabela A18", "−0,34 (p = 0,010)", 3, "TabS23 sa, h = 2, dk: b e p", (row(s23, shock="sa", h=2, inf="dk").b, row(s23, shock="sa", h=2, inf="dk").p)),
]


def fmt(x, d):
    if isinstance(x, tuple):
        return "; ".join(fmt(v, d) for v in x)
    if isinstance(x, (int,)) or (hasattr(x, "is_integer") and d == 0 and float(x).is_integer()):
        return f"{int(x)}"
    s = f"{float(x):.{d}f}"
    return s.replace("-", "−").replace(".", ",")


def nums(txt):
    """numeros do texto do manuscrito: tokens com virgula decimal, percentuais ou contagens 'a de b'."""
    import re
    toks = re.findall(r"[−-]?\d+,\d+|(?<!de )\d+(?=%)|\d+(?= de )|(?<= de )\d+", txt)
    out = []
    for t in toks:
        dec = len(t.split(",")[1]) if "," in t else 0
        out.append((float(t.replace("−", "-").replace(",", ".")), dec))
    return out


rows = []
for tab, ms, d, src, val in L:
    got = fmt(val, d)
    vals = val if isinstance(val, tuple) else (val,)
    want = nums(ms)
    ok = len(want) == len(vals)
    if ok:
        for (w, dec), g in zip(want, vals):
            # arredondamento "meio para cima" nas casas do texto
            gr = float(pd.Series([float(g)]).round(dec).iloc[0])
            if abs(gr - w) > 1e-9 and abs(abs(float(g)) - abs(w)) > 0.5 * 10 ** (-dec) + 1e-12:
                ok = False
    rows.append(dict(tabela=tab, numero_no_texto=ms, fonte=src, valor_no_csv=got, situacao="confere" if ok else f"conferir: {got}"))

OUT.mkdir(parents=True, exist_ok=True)
pd.DataFrame(rows).to_csv(OUT / "conferencia_manuscrito.csv", index=False, encoding="utf-8")
with open(OUT / "conferencia_manuscrito.md", "w", encoding="utf-8") as f:
    f.write("| Tabela | Número no texto | Fonte | Valor no csv | Situação |\n|---|---|---|---|---|\n")
    for r in rows:
        f.write(f"| {r['tabela']} | {r['numero_no_texto']} | {r['fonte']} | {r['valor_no_csv']} | {r['situacao']} |\n")
print(pd.DataFrame(rows)[["numero_no_texto", "valor_no_csv", "situacao"]].to_string())
