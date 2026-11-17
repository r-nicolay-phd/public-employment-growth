"""Confere os numeros do output/kyklos4/RESULTS_MEMO_V5.md contra os .csv de output/kyklos4/tables e o kv.csv do quarto
adendo (extensao de code/kyklos3/confere_memo3.py). Cada item: (valor no memorando, casas decimais, valor calculado).
Alem da igualdade numerica, confere que o numero formatado (virgula decimal, sinal de menos tipografico) aparece no memorando.
Uso (na pasta Estimacoes): python code/kyklos4/confere_memo4.py
"""
import csv
import sys
from pathlib import Path

import pandas as pd

R = Path.cwd()
T = R / "output" / "kyklos4" / "tables"
MEMO = (R / "output" / "kyklos4" / "RESULTS_MEMO_V5.md").read_text(encoding="utf-8")
K = {}
with open(R / "data" / "interim" / "kyklos4" / "kv.csv", encoding="utf-8") as f:
    r = csv.reader(f)
    next(r)
    for row in r:
        K[row[0]] = row[1]
kv = lambda k: float(K[k])


def g(df, col, **c):
    m = pd.Series(True, index=df.index)
    for k, v in c.items():
        m &= (df[k] - v).abs() < 1e-6 if isinstance(v, float) else df[k] == v
    x = df.loc[m, col]
    assert len(x) == 1, (col, c, len(x))
    return float(x.iloc[0])


mc = pd.read_csv(T / "Table_A4_part_moment_choice.csv")
psi = pd.read_csv(T / "Table_A4_part_psi_chosen.csv")
desc = pd.read_csv(T / "Table_A8_part_lost_description.csv")
grp = pd.read_csv(T / "Table_A8_part_groups.csv")
fch = pd.read_csv(T / "Table_A8_part_full_checks.csv")
nul = pd.read_csv(T / "Table_A8_part_null_adjusted.csv")
esc = pd.read_csv(T / "Table_A9_part_common_scale.csv")
tst = pd.read_csv(T / "Table_A9_part_common_scale_tests.csv")
hol = pd.read_csv(T / "Table_A9_part_holm_wwbi.csv")
gt = pd.read_csv(T / "Table_A7_rows_grid_tests.csv")
m6 = pd.read_csv(T / "Table_A6_rows_five_year_tests.csv")
ish = pd.read_csv(T / "Table_A13_part_null_shares_full.csv")
vin = pd.read_csv(T / "Table_A14_rows_vintage.csv")

M = lambda e, col: g(mc, col, des="anc", eps=float(e))
E = lambda it, col="b": g(esc, col, item=it)
TS = lambda pr, col="d": g(tst, col, pair=pr)
GT = lambda c, d, col="d": g(gt, col, ctrl=c, dif=d)
N8 = lambda d, col: g(nul, col, des=d)
c_d = ish[(ish.spec == "D") & (ish.meas == "c")]
c_c = ish[(ish.spec == "C") & (ish.meas == "c")]

checks = [
    # Bloco 1
    (1.00, 2, M(0.48, "kstar")), (0.29, 2, M(0.48, "share")), (0.40, 2, M(0.48, "sharehi")),
    (-0.057, 3, M(0.48, "lag_mean")), (-0.160, 3, M(0.48, "lag_lo")), (0.032, 3, M(0.48, "lag_hi")),
    (0.133, 3, M(0.48, "ham_mean")), (0.031, 3, M(0.48, "ham_lo")), (0.223, 3, M(0.48, "ham_hi")),
    (0.33, 2, M(0.25, "share")), (0.28, 2, M(0.52, "share")), (0.19, 2, M(0.71, "share")),
    (0.249, 3, M(0.71, "ham_mean")), (-0.049, 3, M(0.25, "lag_mean")),
    (-0.001, 3, g(psi, "bobs", eps=0.48, meas="wb_l1")), (-0.016, 3, g(psi, "bobs", eps=0.48, meas="wb_ham")),
    (-0.3, 1, kv("b1_psistar48")), (0.45, 2, kv("b1_psi_share48")),
    (-0.066, 3, g(psi, "mean", eps=0.48, meas="wb_l1")), (0.028, 3, g(psi, "mean", eps=0.48, meas="wb_ham")),
    (0.137, 3, kv("b1_an_048_lambda")), (0.68, 2, kv("b1_an_048_share")),
    (0.043, 3, kv("b1_an_071_lambda")), (0.38, 2, kv("b1_an_071_share")),
    (0.230, 3, kv("b1_eps_real")), (0.184, 3, kv("b1_eps_real_se")), (0.754, 3, kv("b1_eps_price")), (0.071, 3, kv("b1_eps_price_se")),
    # Bloco 2
    (-0.142, 3, kv("b2_b355")), (-0.019, 3, kv("b2_b311")), (-0.123, 3, kv("b2_dif")),
    (1.05, 2, kv("b2_share_firstrep")), (-0.02, 2, kv("b2_share_trans99")), (0.61, 2, kv("b2_share_early")), (13, 0, kv("b2_Lg_recovered")),
    (0.82, 2, g(desc, "m_lost", v="firstrep")), (0.09, 2, g(desc, "m_kept", v="firstrep")),
    (2.04, 2, g(desc, "m_lost", v="g")), (2.17, 2, g(desc, "m_kept", v="g")), (0.748, 3, g(desc, "p", v="g")),
    (9.25, 2, g(desc, "m_lost", v="wb_m1")), (9.59, 2, g(desc, "m_kept", v="wb_m1")), (0.511, 3, g(desc, "p", v="wb_m1")),
    (8.86, 2, g(desc, "m_lost", v="lny0")), (9.75, 2, g(desc, "m_kept", v="lny0")),
    (-0.150, 3, g(grp, "b0", grp="firstrep")), (0.007, 3, g(grp, "bint", grp="firstrep")), (0.921, 3, g(grp, "pboot_int", grp="firstrep")),
    (0.627, 3, g(grp, "bint", grp="trans99")), (0.387, 3, g(grp, "pboot_int", grp="trans99")),
    (-0.143, 3, g(fch, "b", item="gap")), (0.145, 3, g(fch, "pboot", item="gap")),
    (-0.117, 3, g(fch, "b", item="Lg_f")), (0.025, 3, g(fch, "d", item="Lg_f")), (0.110, 3, g(fch, "pboot", item="Lg_f")),
    (-0.112, 3, g(fch, "b", item="Lgf_ga")), (0.030, 3, g(fch, "d", item="Lgf_ga")), (0.082, 3, g(fch, "pboot", item="Lgf_ga")),
    (-0.093, 3, N8("sta", "null355")), (0.094, 3, N8("sta", "null311")),
    (-0.050, 3, N8("sta", "adj355")), (-0.228, 3, N8("sta", "lo355")), (0.069, 3, N8("sta", "hi355")),
    (-0.113, 3, N8("sta", "adj311")), (-0.381, 3, N8("sta", "lo311")), (0.081, 3, N8("sta", "hi311")),
    (-0.104, 3, N8("anc", "adj355")), (-0.103, 3, N8("cal", "adj355")), (-0.224, 3, N8("cal", "lo355")), (0.056, 3, N8("cal", "hi355")),
    # Bloco 3
    (-0.002, 3, E("ann_dl")), (-0.318, 3, E("ann_dl", "lo")), (0.314, 3, E("ann_dl", "hi")), (1377, 0, E("ann_dl", "N")),
    (0.030, 3, E("ann_ma")), (-0.176, 3, E("ann_ma", "lo")), (0.236, 3, E("ann_ma", "hi")),
    (0.008, 3, kv("b3_lp_F")),
    (0.140, 3, TS("ann − t3")), (0.473, 3, TS("ann − t3", "p")), (0.332, 3, TS("ann − ww")), (0.148, 3, TS("ann − ww", "p")),
    (0.192, 3, TS("t3 − ww")), (0.155, 3, TS("t3 − ww", "p")),
    (0.481, 3, kv("b3_p_ann_014")), (0.094, 3, kv("b3_p_ann_033")),
    (38, 0, kv("b3_holm_family")), (0.876, 3, kv("b3_holm_p_334")),
    (0.030, 3, g(hol, "p", tab="A15", lab="sample c, wm")),
    # Bloco 4
    (0.082, 3, GT("m1", "trend")), (0.018, 3, GT("m1", "trend", "lo")), (0.185, 3, GT("m1", "trend", "hi")), (0.005, 3, GT("m1", "trend", "p")),
    (0.097, 3, GT("mean", "trend")), (-0.163, 3, GT("m1", "mean − (t_p")), (-0.065, 3, GT("m1", "t_p − (t_p")),
    (-0.098, 3, GT("m1", "mean − t_p")), (0.067, 3, GT("m1", "mean − t_p", "p")), (-0.193, 3, GT("mean", "mean − (t_p")),
    (-0.078, 3, g(m6, "b", per=8604, est="fe", meas="lg_p")), (0.081, 3, g(m6, "p", per=8604, est="fe", meas="lg_p")),
    (-0.117, 3, g(m6, "b", per=8604, est="fe", meas="lg_m")),
    # Bloco 5
    (0.05, 2, kv("b5_share_C_min")), (0.39, 2, kv("b5_share_C_max")), (0.36, 2, kv("b5_share_D_min")), (0.73, 2, kv("b5_share_D_max")),
    (1.02, 2, kv("b5_sharepub_min")), (2.08, 2, kv("b5_sharepub_max")),
    (-0.121, 3, kv("b5_Ch_obs")), (-0.021, 3, kv("b5_Ch_null_min")), (0.048, 3, kv("b5_Ch_null_max")),
    (2.03, 2, kv("b5_vintage_ratio_min")), (1, 0, kv("b5_holm_sig")), (24, 0, kv("b5_holm_cells")),
    (0.36, 2, c_d[c_d.des.str.endswith("C")].share.min()), (0.65, 2, c_d[c_d.des.str.endswith("C")].share.max()),
    (0.32, 2, c_c[c_c.des.str.endswith("G")].share.min()), (0.39, 2, c_c[c_c.des.str.endswith("G")].share.max()),
    (2.86, 2, g(vin, "ratio", vint="current", inst="ge")), (132, 0, g(vin, "nc", vint="current", inst="ge")),
]

# itens com 3 casas: conferidos tambem como texto no memorando; percentuais e contagens, so numericamente
bad = []
for i, (memo, d, calc) in enumerate(checks):
    if round(calc, d) != round(memo, d) and abs(round(calc, d) - memo) > 10 ** (-d) / 2 + 1e-12:
        bad.append((i, memo, calc))
        continue
    if d == 3:
        s = f"{abs(memo):.3f}".replace(".", ",")
        s = ("−" if memo < 0 else "") + s
        if s not in MEMO and s.lstrip("−") not in MEMO:
            bad.append((i, memo, "ausente no memorando: " + s))
print(f"{len(checks)} itens conferidos; {len(bad)} divergencias")
for b in bad:
    print("  DIVERGE", b)
sys.exit(1 if bad else 0)
