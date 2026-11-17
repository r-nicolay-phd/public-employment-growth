"""Confere os numeros citados no RESULTS_MEMO_FINAL.md contra os .csv de output/kyklos2/tables e o kv.csv.

Uso (na pasta Estimacoes): python code/kyklos2/confere_memo.py
Cada linha: (valor no memorando, fonte, valor calculado); falha se o arredondamento nao bater.
"""
import csv
import sys
from pathlib import Path

import pandas as pd

R = Path.cwd()
T = R / "output" / "kyklos2" / "tables"
I = R / "data" / "interim" / "kyklos2"


def kv():
    d = {}
    with open(I / "kv.csv", encoding="utf-8") as f:
        r = csv.reader(f)
        next(r)
        for row in r:
            d[row[0]] = ",".join(row[1:])
    return d


K = kv()
s5 = pd.read_csv(T / "Table_A5_simulation.csv")
sl = pd.read_csv(T / "Table_A5_simulation_slopes.csv")
dec = pd.read_csv(T / "Table_A5_panel_D_decomposition.csv")
vb = pd.read_csv(T / "Table_A11_panel_bias_checks.csv")
gd = pd.read_stata(I / "vies_gd.dta")
gel = pd.read_stata(I / "vies_gelbach.dta")
op = pd.read_csv(T / "Table_A15_panel_triple_interaction.csv")
si = pd.read_csv(T / "Table_A15_panel_simulation.csv")
mv = pd.read_csv(T / "Table_A16_rows_mv_ci.csv")
fy = pd.read_csv(T / "Table_A6_rows_fiscal_year.csv")
fd = pd.read_csv(T / "Table_A6_rows_fiscal_year_differences.csv")
h2 = pd.read_csv(T / "Table_A17_columns_reverse_denominator.csv")
lp = pd.read_csv(T / "Table_A18_panel_cumulative.csv")
cf = pd.read_csv(T / "conferencia_bloco8.csv")


def g(df, col, **c):
    m = pd.Series(True, index=df.index)
    for k, v in c.items():
        m &= (df[k] - v).abs() < 1e-6 if isinstance(v, float) else df[k] == v
    r = df.loc[m, col]
    assert len(r) == 1, (col, c, len(r))
    return float(r.iloc[0])


A = lambda m, e, col="mean": g(s5, col, var="anc", meas=m, eps=float(e))
checks = [
    (-0.208, 3, A("wb", 0)), (-0.233, 3, A("wb", 0.25)), (-0.213, 3, A("wb", 0.48)), (-0.119, 3, A("wb", 0.75)),
    (-0.003, 3, A("wb", 1)), (-0.400, 3, A("wb", 0, "p025")), (-0.334, 3, A("wb", 0.48, "p025")), (-0.074, 3, A("wb", 0.48, "p975")),
    (0.29, 2, A("wb", 0.48, "share")), (-0.211, 3, g(sl, "slope", var="anc", meas="wb")), (-0.399, 3, g(sl, "slo", var="anc", meas="wb")),
    (-0.033, 3, g(sl, "shi", var="anc", meas="wb")), (1.30, 2, A("sdw", 0.48)), (0.88, 2, A("ar1", 0.48)), (0.95, 2, A("rpl", 0.48)),
    (0.13, 2, A("wb_ham", 0.48)), (-0.06, 2, A("wb_hp1", 0.48)), (-0.037, 3, A("T3", 0.48)), (0.870, 3, float(K["sim2_rho"])),
    (-0.180, 3, g(s5, "mean", var="sta", meas="wb")), (-0.094, 3, g(s5, "mean", var="sta", meas="T3")),
    (-0.166, 3, g(s5, "p025", var="sta", meas="T3")), (-0.018, 3, g(s5, "p975", var="sta", meas="T3")),
    (0.66, 2, g(s5, "share", var="sta", meas="T3")), (0.964, 3, g(s5, "mean", var="sta", meas="ar1")),
    (-0.008, 3, g(sl, "slope", var="reg", meas="wb")), (48.7, 1, g(s5, "mean", var="reg", meas="sdw", eps=0.0)),
    (-0.024, 3, g(dec, "b", item="dec_ls1")), (-0.062, 3, g(dec, "b", item="dec_dlW")), (0.003, 3, g(dec, "p", item="dec_dlW")),
    (0.499, 3, g(dec, "b", item="dec_dlY")), (-1.58, 2, g(dec, "b", item="cov")), (-0.09, 2, g(dec, "b", item="corr")),
    (0.39, 2, g(dec, "b", item="w_g2")), (-0.47, 2, g(dec, "b", item="wy_g")), (0.98, 2, g(dec, "b", item="rpl_obs")),
    # Bloco 2
    (-0.143, 3, g(vb, "b", item="i1")), (-0.108, 3, g(vb, "b", item="i2a")), (-0.105, 3, g(vb, "b", item="i2b")),
    (-0.181, 3, g(vb, "b", item="i3")), (0.086, 3, g(vb, "pboot", item="i3")), (0.002, 3, g(vb, "b", item="i4")),
    (461.7, 1, g(vb, "Feff", item="i4")), (0.893, 3, g(vb, "Jp", item="i4")), (-0.081, 3, g(vb, "b", item="a7")),
    (-0.034, 3, g(gel, "d", comp="gG")), (-0.035, 3, g(gel, "d", comp="__TC")), (0.096, 3, g(gd, "est", stat="ga")),
    (-0.032, 3, g(gd, "est", stat="ovb")), (-0.086, 3, g(gd, "lo", stat="ovb")), (0.030, 3, g(gd, "hi", stat="ovb")),
    (0.124, 3, g(vb, "pboot", item="T3")),
    # Bloco 3
    (-0.553, 3, g(op, "b", split="m", smp="all", meas="gc_mean", est="fe")), (0.015, 3, g(op, "pboot", split="m", smp="all", meas="gc_mean", est="fe")),
    (-1.064, 3, g(op, "blo", split="m", smp="all", meas="gc_mean", est="fe")), (-0.103, 3, g(op, "bhi", split="m", smp="all", meas="gc_mean", est="fe")),
    (0.31, 2, g(op, "bE", split="m", smp="all", meas="gc_mean", est="fe")), (-0.24, 2, g(op, "bL", split="m", smp="all", meas="gc_mean", est="fe")),
    (-0.596, 3, g(op, "b", split="r", smp="all", meas="gc_mean", est="fe")), (-0.107, 3, g(mv, "b", inst="ge", meas="lgy_l1", vce="cluster")),
    (-1.174, 3, g(mv, "lo95", inst="ge", meas="lgy_l1", vce="cluster")), (0.961, 3, g(mv, "hi95", inst="ge", meas="lgy_l1", vce="cluster")),
    (-1.255, 3, g(mv, "lo95", inst="ge", meas="lgy_l1", vce="robust")),
    # Bloco 4
    (0.556, 3, float(K["b4_eps0"])), (-0.180, 3, float(K["b4_eps1"])), (-1.328, 3, g(si, "meanG", spec="D", meas="c")),
    (-1.131, 3, g(si, "meanC", spec="D", meas="c")), (0.57, 2, g(si, "shareG", spec="D", meas="c")), (0.49, 2, g(si, "shareC", spec="D", meas="c")),
    (0.08, 2, g(si, "share_net", spec="D", meas="c")), (-2.326, 3, g(si, "bobs", spec="D", meas="c")),
    # Bloco 5
    (-0.701, 3, g(fy, "b", smp="excl", m="wb")), (-0.724, 3, g(fd, "d", smp="excl", dif="lag")), (-0.081, 3, g(fy, "b", smp="excl", m="T3")),
    (-0.073, 3, g(fy, "b", smp="real", m="T3")), (0.061, 3, g(fd, "d", smp="ex-f", dif="T3")), (0.48, 2, g(fd, "p", smp="ex-f", dif="T3")),
    # Bloco 6
    (-5.393, 3, g(h2, "b", smp="H", spec="base")), (-5.201, 3, g(h2, "b", smp="H", spec="m1")), (-5.438, 3, g(h2, "b", smp="H", spec="m12")),
    (-4.303, 3, g(h2, "b", smp="H", spec="m3")), (0.008, 3, g(h2, "pboot", smp="H", spec="m3")), (-3.690, 3, g(h2, "b", smp="S", spec="m3")),
    (0.022, 3, g(h2, "pboot", smp="S", spec="m3")), (-4.699, 3, g(h2, "b", smp="S", spec="m2")), (0.006, 3, float(K["b6_rw_m1"])),
    # Bloco 8
    (0.976, 3, float(cf.loc[cf.desc.str.startswith("A5 (old): within SD"), "value"].iloc[0])),
    (0.970, 3, float(cf.loc[cf.desc.str.startswith("A2: within SD"), "value"].iloc[0])),
    (-5.227, 3, float(cf.loc[cf.desc.str.contains("log wage bill"), "value"].iloc[0])),
]
bad = 0
for want, d, got in checks:
    if round(got, d) != round(want, d) and abs(got - want) > 0.5 * 10 ** (-d) + 1e-12:
        bad += 1
        print(f"NAO CONFERE: memorando {want} x csv {got:.6f}")
print(f"{len(checks)} numeros conferidos; {bad} divergencias")
sys.exit(1 if bad else 0)
