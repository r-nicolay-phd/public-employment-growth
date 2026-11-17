"""Confere os numeros do RESULTS_MEMO_FINAL2.md contra os .csv de output/kyklos3/tables e o kv.csv (extensao de
code/kyklos2/confere_memo.py). Uso (na pasta Estimacoes): python code/kyklos3/confere_memo3.py
"""
import csv
import sys
from pathlib import Path

import pandas as pd

R = Path.cwd()
T = R / "output" / "kyklos3" / "tables"
K = {}
with open(R / "data" / "interim" / "kyklos3" / "kv.csv", encoding="utf-8") as f:
    r = csv.reader(f)
    next(r)
    for row in r:
        K[row[0]] = row[1]


def g(df, col, **c):
    m = pd.Series(True, index=df.index)
    for k, v in c.items():
        m &= (df[k] - v).abs() < 1e-6 if isinstance(v, float) else df[k] == v
    x = df.loc[m, col]
    assert len(x) == 1, (col, c, len(x))
    return float(x.iloc[0])


tam = pd.read_csv(T / "Table_A15_panel_size.csv")
tdf = pd.read_csv(T / "Table_A15_panel_size_differences.csv")
sim = pd.read_csv(T / "Table_A4_panel_calibrated.csv")
dl = pd.read_csv(T / "Table_A4_panel_lags_numerator.csv")
ctl = pd.read_csv(T / "Table_A5_rows_predetermined_controls.csv")
ctd = pd.read_csv(T / "Table_A5_rows_predetermined_controls_differences.csv")
fon = pd.read_csv(T / "Table_A5_rows_sources.csv")
fod = pd.read_csv(T / "Table_A5_rows_sources_differences.csv")
vc = pd.read_csv(T / "Table_A8_panel_bias_common_sample.csv")
lopo = pd.read_csv(T / "Table_A8_leave_one_period_out.csv")
si = pd.read_csv(T / "Table_A13_panel_F_rows_calibrated.csv")
cells = pd.read_csv(T / "Table_A13_panel_E_cell_count.csv")
cf = pd.read_csv(T / "conferencia_bloco8_final.csv")
S = lambda v, e, m="wb", col="mean": g(sim, col, var=v, eps=float(e), meas=m)
C = lambda key: float(cf.loc[cf.desc.str.contains(key, regex=False), "value"].iloc[0])
I = lambda d, s, col="share": g(si, col, des=d, spec=s, meas="c")

checks = [
    # Bloco 1
    (-0.142, 3, g(tam, "b", smp="a", x="wm")), (0.125, 3, g(tam, "pboot", smp="a", x="wm")), (-0.042, 3, g(tam, "conv", smp="a", x="lwm")),
    (-0.218, 3, g(tam, "b", smp="b", x="wm")), (-0.175, 3, g(tam, "conv", smp="b", x="lwm")),
    (-0.334, 3, g(tam, "b", smp="c", x="wm")), (0.030, 3, g(tam, "pboot", smp="c", x="wm")), (-0.599, 3, g(tam, "lo", smp="c", x="wm")),
    (-0.264, 3, g(tam, "conv", smp="c", x="lwm")), (0.076, 3, g(tam, "pboot", smp="c", x="lwm")),
    (-0.646, 3, g(tam, "b", smp="c", x="ws")), (-0.565, 3, g(tam, "conv", smp="c", x="lws")), (-5.227, 3, g(tam, "b", smp="c", x="lws")),
    (-0.382, 3, g(tam, "b", smp="d", x="wm")), (0.036, 3, g(tam, "pboot", smp="d", x="wm")), (-0.294, 3, g(tam, "conv", smp="d", x="lwm")),
    (-0.497, 3, g(tam, "b", smp="d", x="ws")), (-0.423, 3, g(tam, "conv", smp="d", x="lws")),
    (-0.422, 3, g(tdf, "est", stat="tot")), (-0.301, 3, g(tdf, "est", stat="st5")), (0.71, 2, g(tdf, "share", stat="st5")),
    (0.100, 3, g(tdf, "est", stat="st2")), (-0.133, 3, g(tdf, "est", stat="st3")), (-0.089, 3, g(tdf, "est", stat="st4")),
    (0.192, 3, g(tdf, "est", stat="ac_lev")), (0.221, 3, g(tdf, "est", stat="ac_log")),
    # Bloco 2
    (-0.419, 3, S("csd", 0.48)), (-0.481, 3, S("csd", 0.48, col="p025")), (-0.343, 3, S("csd", 0.48, col="p975")),
    (0.58, 2, S("csd", 0.48, col="share")), (0.33, 2, S("csd", 0.71, col="share")), (-0.238, 3, S("csd", 0.71)),
    (0.000, 3, S("csd", 1)), (0.99, 2, S("csd", 0, col="share")), (0.80, 2, S("csd", 0.25, col="share")), (0.28, 2, S("csd", 0.75, col="share")),
    (0.971, 3, S("csd", 0.48, "sdw")), (0.962, 3, S("csd", 0.48, "ar1")), (0.29, 2, S("anc", 0.48, col="share")), (0.19, 2, S("anc", 0.71, col="share")),
    (0.05, 2, S("reg", 0.48, col="share")), (0.04, 2, S("reg", 0.71, col="share")), (0.25, 2, g(sim, "share", var="sta", eps=0.48, meas="wb")),
    (1.02, 2, float(K["b2_placebo_share"])), (-0.056, 3, S("csd", 0.48, "T3")), (-0.094, 3, g(sim, "mean", var="sta", eps=0.48, meas="T3")),
    # Bloco 3
    (-0.635, 3, g(ctd, "d", ver="a", dif="lag")), (-0.642, 3, g(ctd, "d", ver="b", dif="lag")), (-0.628, 3, g(ctd, "d", ver="c", dif="lag")),
    (-0.716, 3, g(ctl, "b", ver="0", m="wb")), (-0.633, 3, g(ctl, "b", ver="a", m="wb")), (-0.559, 3, g(ctl, "b", ver="b", m="wb")),
    # Bloco 4
    (-0.054, 3, g(dl, "b", item="A_sum")), (-0.325, 3, g(dl, "lo", item="A_sum")), (0.218, 3, g(dl, "hi", item="A_sum")),
    (-0.067, 3, g(dl, "b", item="A_lr")), (0.026, 3, g(dl, "b", item="D2_dlW")), (0.16, 2, g(dl, "p", item="D2_dlW")),
    (0.004, 3, g(dl, "b", item="D2_ls1")), (0.022, 3, g(dl, "b", item="D3_dlW")), (-0.069, 3, g(dl, "b", item="D4_dlW")),
    (4.2, 1, g(dl, "F", item="D4_dlW")), (0.353, 3, g(dl, "b", item="ix")), (0.022, 3, g(dl, "b", item="wp")),
    # Bloco 5
    (-0.019, 3, g(vc, "b", item="T3")), (0.832, 3, g(vc, "pboot", item="T3")), (-0.109, 3, g(vc, "adj_sta", item="T3")),
    (-0.337, 3, g(vc, "adj_sta_lo", item="T3")), (0.097, 3, g(vc, "adj_sta_hi", item="T3")), (0.018, 3, g(vc, "dT3", item="i1")),
    (-0.002, 3, g(vc, "b", item="i4")), (311, 0, float(K["b5_Ncommon"])), (2, 0, float((lopo.p < 0.05).sum())),
    # Bloco 6
    (0.39, 2, I("cal556G", "C")), (0.24, 2, I("cal556G", "C", "sh_lo")), (0.53, 2, I("cal556G", "C", "sh_hi")), (0.49, 2, I("anc556C", "D")),
    (0.73, 2, I("cal556G", "D")), (0.43, 2, I("anc701G", "D")), (1.39, 2, I("anc556C", "D", "share_pub")), (13, 0, float(cells.sig.sum())),
    # Bloco 7
    (-0.794, 3, g(fon, "b", ver="p1", m="same")), (-0.731, 3, g(fon, "b", ver="w2", m="same")), (0.098, 3, float(K["b7_change_pwt"])),
    # Bloco 8
    (51, 0, C("estimated annual panel")), (132, 0, C("own sample, ge")), (2.35, 2, C("full period and subperiods, min")),
    (3.15, 2, C("full period and subperiods, max")), (168, 0, C("with growth and all controls")), (0.246, 3, C("registered sample (Table 2): coefficient")),
    (-0.075, 3, C("strict sample (pairs in t_p - 1 to t_p - 4): coefficient")), (2.33, 2, C("ep_dem_Feff")), (-0.314, 3, C("reduced form, change")),
    (-0.244, 3, C("excluding negative-growth years (Table A5)")),
]
bad = 0
for want, d, got in checks:
    if round(got, d) != round(want, d) and abs(got - want) > 0.5 * 10 ** (-d) + 1e-9:
        bad += 1
        print(f"NAO CONFERE: memorando {want} x csv {got:.6f}")
print(f"{len(checks)} numeros conferidos; {bad} divergencias")
sys.exit(1 if bad else 0)
