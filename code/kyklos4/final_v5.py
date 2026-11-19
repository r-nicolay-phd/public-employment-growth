"""Exibicoes completas na numeracao da versao 5 em output/kyklos4/final/ (Bloco 6 do quarto adendo).

Parte das mesmas fontes de code/kyklos3/numeracao_final.py (output/kyklos, output/kyklos2, output/kyklos3, sem altera-las)
e acrescenta as partes novas de output/kyklos4. Correcoes de consistencia:
- remissoes a tabelas e figuras fora da versao final apontam para a linha do README do pacote de replicacao;
- estatisticas repetidas (diferenca mesmo ano - defasada; p de bootstrap de T3) usam o calculo registrado;
- marcas de revisao ("earlier version", "replaces", ...) e "plan addendum" generico trocados por descricoes neutras e pelo
  adendo especifico; rotulos internos como em numeracao_final.py;
- notas acrescentadas (Tabelas A10, A11, A15, A16, A17) e rotulo da Tabela 2 corrigido.
Nenhum numero estimado muda. Uso (na pasta Estimacoes): python code/kyklos4/final_v5.py
"""
import copy
import csv
import importlib.util
import re
import shutil
import sys
from pathlib import Path

import docx
import pandas as pd

ROOT = Path.cwd()
spec = importlib.util.spec_from_file_location("nf3", ROOT / "code" / "kyklos3" / "numeracao_final.py")
nf3 = importlib.util.module_from_spec(spec)
spec.loader.exec_module(nf3)
K1, K2, K3 = nf3.K1, nf3.K2, nf3.K3
K4 = ROOT / "output" / "kyklos4"
OUT = K4 / "final"
W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"


# ---------------------------------------------------------------- linhas do README do pacote
def readme_rows():
    txt = (ROOT / "replication_kyklos" / "README.md").read_text(encoding="utf-8").splitlines()
    main, extra, sec = {}, {}, None
    for line in txt:
        if line.startswith("## List of tables and programs"):
            sec = "main"
            n = 0
            continue
        if line.startswith("**Additional estimates (code/kyklos/)"):
            sec = "extra"
            n = 0
            continue
        if line.startswith("**Final estimates") or line.startswith("## Numbering"):
            sec = None
        if sec and line.startswith("| ") and not line.startswith("| Kyklos number") and not line.startswith("|---"):
            n += 1
            key = line.split("|")[1].strip()
            (main if sec == "main" else extra)[key] = n
    return main, extra


RM_MAIN, RM_EXTRA = readme_rows()
# numeros fora da versao final, por esquema -> rotulo do README
DROP_T = {"v3": {k: f"Table {k}" for k in ["A1", "A4"] + [f"S{i}" for i in (3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 18, 27)]},
          "v4": {"A3": "Table S3", "A9": "Table A1", "A13": "Table S27"}}
DROP_F = {"v3": {"4": "Figure 4", "A1": "Figure A1", "A2": "Figure A2", "A3": "Figure A3", "A4": "Figure A4", "A5": "Figure A5",
                 "S2": "Figure S2", "S3": "Figure S3", "S4": "Figure S4", "S5": "Figure S5", "S6": "Figure S6"},
          "v4": {"2": "Figure 4", "A1": "Figure A1", "A5": "Figure A3", "A6": "Figure S6"}}


def pkg_ref(label):
    if label in RM_MAIN:
        return f"the replication package (README, list of tables and programs, row {RM_MAIN[label]})"
    if label in RM_EXTRA:
        return f"the replication package (README, additional estimates, row {RM_EXTRA[label]})"
    return "the replication package (README, list of tables and programs)"


def renumber(text, scheme):
    if scheme == "fin":
        return text
    keep = {}
    for i, p in enumerate(nf3.PROTECT):
        if p in text:
            k = f"\x00{i}\x00"
            keep[k] = p
            text = text.replace(p, k)

    def f(m):
        kind, lst = m.group(1), m.group(2)
        isT = kind.startswith("Table")
        mp = nf3.TAB[scheme] if isT else nf3.FIG[scheme]
        drop = (DROP_T if isT else DROP_F)[scheme]
        parts = re.split(rf"({nf3.SEP})", lst)
        toks, dropped = [], []
        for p in parts:
            if re.fullmatch(nf3.SEP, p):
                continue
            mm = re.match(r"([SA]?\d+)(.*)", p)
            base, rest = mm.group(1), mm.group(2)
            if base not in mp:
                toks.append(p)
            elif mp[base] is not None:
                toks.append(mp[base] + rest)
            else:
                dropped.append(drop.get(base, ""))
        out = []
        if toks:
            word = kind.rstrip("s") + ("s" if len(toks) > 1 else "")
            out.append(word + " " + (", ".join(toks[:-1]) + " and " + toks[-1] if len(toks) > 1 else toks[0]))
        for d in dropped:
            out.append(pkg_ref(d))
        return " and ".join(out)
    text = nf3.RX.sub(f, text)
    for k, p in keep.items():
        text = text.replace(k, p)
    return text


# ---------------------------------------------------------------- correcoes de texto (Bloco 6)
ADD = {"v3": "first addendum", "v4": "second addendum", "fin": None}
PRE = [  # antes da renumeracao
    ("so the check of Table S8, row 7, could not be done", "so the corresponding check could not be done (STRUCTROW)"),
]
POST = [  # depois da renumeracao e da limpeza
    ("(STRUCTROW)", f"(structural-explanations table, line 7; replication package README, list of tables and programs, row {RM_MAIN.get('Table S8', '')})"),
    ("A. Anchored on the observed ratio of t − 1 (main)", "A. Anchored on the observed ratio of t − 1, unscaled residuals"),
    ("A (main): ", "A (anchored design, unscaled residuals): "),
    ("C: design of the earlier version of this table", "C: the design registered in the first addendum"),
    ("C. Registered design (random walk in the wage bill), rerun on the same grid", "C. Design registered in the first addendum (random walk in the wage bill), on the same grid"),
    ("Replaces the bias panel of the earlier version. ", ""),
    (" (the earlier panel B used 1,593 country-years, a sample that differs from Table 1 by 28 country-years, which is why its within-country SD of the wage bill, 0.97, differed from the 0.98 reported in Table A4)", ""),
    ("the strict-sample family replaces only the H2 test", "the strict-sample family differs only in the H2 test"),
    ("its own lag replaces lagged WDI growth among the controls", "its own lag is used instead of lagged WDI growth among the controls"),
    ("Price term: effect of 1 within-country SD", "Effect of 1 within-country SD (price term in cols. 2–5; premium in col. 6; wage bill in col. 7)"),
    ("second plan addendum", "second addendum"), ("third plan addendum", "third addendum"), ("fourth plan addendum", "fourth addendum"),
]


def fix_text(t, scheme):
    for a, b in PRE:
        t = t.replace(a, b)
    t = nf3.clean(renumber(t, scheme))
    if ADD[scheme]:
        t = t.replace("pre-registered in the plan addendum", f"pre-registered in the {ADD[scheme]}")
    for a, b in POST:
        t = t.replace(a, b)
    return t


def tex_esc(s):
    return s.replace("−", "$-$")


# valores canonicos (calculo registrado)
def kv(path):
    d = {}
    with open(path, encoding="utf-8") as f:
        r = csv.reader(f)
        next(r)
        for row in r:
            d[row[0]] = row[1]
    return d


KR = kv(ROOT / "data" / "interim" / "revisao" / "kv.csv")
K4V = kv(ROOT / "data" / "interim" / "kyklos4" / "kv.csv")


def f3(x):
    s = f"{float(x):.3f}"
    return s.replace("-", "−")


CANON_CI = f"[{f3(KR['dif_13_lo'])}; {f3(KR['dif_13_hi'])}]"
fs20 = pd.read_csv(K1 / "tables" / "TabS20_spending_items.csv")
r20 = fs20[(fs20["item"] == "wb") & (fs20["meas"] == "bias")].iloc[0]
OLD_A3 = f"[{f3(r20.lo)}; {f3(r20.hi)}]"
fdif = pd.read_csv(K3 / "tables" / "Table_A5_rows_sources_differences.csv")
r5 = fdif[(fdif["ver"] == "o1") & (fdif["dif"] == "lag")].iloc[0]
OLD_A5 = f"[{f3(r5.lo)}; {f3(r5.hi)}]"
T3P = f"{float(KR['T3_own_pboot']):.3f}"
tam = pd.read_csv(K3 / "tables" / "Table_A15_panel_size.csv")
OLD_T3P = f"{float(tam[(tam.smp == 'a') & (tam.x == 'wm')].pboot.iloc[0]):.3f}"
SPEC = {  # tabela final -> trocas especificas (docx; o .tex recebe a mesma troca com $-$)
    "A3": [(OLD_A3, CANON_CI)],
    "A5": [(OLD_A5, CANON_CI)],
    "A15": [(f"−0.142 [−0.284; −0.001]\t{OLD_T3P}", None)],
}


def notes_add(num):
    n = {}
    conf = pd.read_csv(K3 / "tables" / "conferencia_bloco8_final.csv")
    fd = conf[conf.desc.str.contains("ep_dem_Feff", regex=False)].value.iloc[0]
    fa = conf[conf.desc.str.contains("ep_all_Feff", regex=False)].value.iloc[0]
    n["A17"] = (f" The effective F of the electoral calendar in the first stage of the political-economy check is {fd:.2f} in democracies "
                f"({fa:.2f} in all country-years), below the usual threshold for a strong instrument.")
    lp = pd.read_csv(K1 / "tables" / "TabS23_lp_predetermined.csv")
    jk = lp[(lp.shock == "sa") & (lp.h == -2) & (lp.inf == "jk")].iloc[0]
    dk = lp[(lp.shock == "sa") & (lp.h == 2) & (lp.inf == "dk")].iloc[0]
    n["A16"] = (f" Shock (a), h = 2: Driscoll-Kraay p = {dk.p:.4f} (below 0.01). With the half-panel jackknife, the lead at h = −2 is "
                f"{f3(jk.b)} (p = {jk.p:.3f}), significant at 10%.")
    n["A15"] = (" Column (e) uses the strict timing of the premium pair (premium measured in t_p − 1 to t_p − 4), which is available for more "
                "country-periods than the employment pair (220 country-periods, 73 countries, against 152 and 49 in the strict sample). "
                f"Wild-bootstrap p of the preferred specification: {T3P}, the value of Table A17, computed once.")
    n["A11"] = (" The two p-values of 0.066 (general − central difference and unitary countries) belong to different statistics "
                "(−0.169 and −0.241) that are each exceeded in absolute value by 66 of the 999 bootstrap draws.")
    rows = [l for l in (K1 / "tables" / "Table_A5_robustness_map.tex").read_text(encoding="utf-8").splitlines() if "&" in l and not l.strip().startswith("&")]
    nalt, nsig = 0, 0
    for l in rows:
        c = [x.strip() for x in l.rstrip("\ ").split("&")]
        if len(c) < 3 or c[0].startswith("T3") or "Specification curve" in c[0] or "Bayesian" in c[0]:
            continue
        try:
            pv = float(c[2])
        except ValueError:
            continue
        nalt += 1
        nsig += pv < 0.05
    alt = f"{nsig} of the {nalt} alternative specifications are significant at 5%."
    n["A10"] = (" Rows are grouped into the preferred specification, alternative specifications and summaries over many specifications. "
                + (alt + " " if alt else "")
                + "The unitary-country row reports the conventional clustered p (0.029); Table A11 reports a percentile bootstrap CI for the same coefficient "
                "([−0.361; 0.055]), a different inference procedure, which includes zero.")
    return n.get(num, "")


def a10_groups(d):
    """Tabela A10: insere linhas de grupo (alternativas e resumos)."""
    tb = d.tables[0]
    rows = list(tb.rows)

    def insert_before(row, text):
        new = copy.deepcopy(row._tr)
        row._tr.addprevious(new)
        ts = list(new.iter(W + "t"))
        for i, t in enumerate(ts):
            t.text = text if i == 0 else ""
    for r in rows:
        c0 = r.cells[0].text
        if c0.startswith("Conventional timing"):
            insert_before(r, "Alternative specifications")
        if c0.startswith("Specification curve"):
            insert_before(r, "Summaries over many specifications")


def a10_count():
    tex = (OUT / "tables" / "Table_A10_robustness_map.tex").read_text(encoding="utf-8") if (OUT / "tables" / "Table_A10_robustness_map.tex").exists() else ""
    return tex


FINAL = list(nf3.FINAL)
EXTRA = {"A4": [(K4, "Table_A4_part_moment_matched", "fin")], "A6": [(K4, "Table_A6_rows_five_year_tests", "fin")],
         "A7": [(K4, "Table_A7_rows_grid_tests", "fin")], "A8": [(K4, "Table_A8_part_drivers", "fin")],
         "A9": [(K4, "Table_A9_part_common_scale", "fin")], "A12": [(K4, "Table_A12_rows_trend_null", "fin")],
         "A13": [(K4, "Table_A13_part_null_shares", "fin")], "A14": [(K4, "Table_A14_rows_vintage", "fin")]}
FIGS = [("1", "simulation", K4, "Figure_1_simulation"), ("2", "five_year_grid", K1, "Fig1new_timing_grid"),
        ("3", "institutions", K1, "Figure_2_institutions"), ("4", "lp_dated_shock", K1, "Fig3new_lp_shock_a"),
        ("A1", "coverage", K1, "Figure_S1_coverage"), ("A2", "influence", K4, "Figure_A2_influence"),
        ("A3", "common_scale", K4, "Figure_A3_common_scale")]


def build():
    (OUT / "tables").mkdir(parents=True, exist_ok=True)
    (OUT / "figures").mkdir(parents=True, exist_ok=True)
    for num, name, parts in FINAL:
        parts = list(parts) + EXTRA.get(num, [])
        base, tex = None, []
        for i, (folder, fn, sch) in enumerate(parts):
            d = docx.Document(str(folder / "tables" / f"{fn}.docx"))
            for t in d.element.body.iter(W + "t"):
                if t.text:
                    t.text = fix_text(t.text, sch)
            for a, b in SPEC.get(num, []):
                if b is None:
                    continue
                for t in d.element.body.iter(W + "t"):
                    if t.text and a in t.text:
                        t.text = t.text.replace(a, b)
            if num == "A15" and fn == "Table_A15_panel_size":
                for row in d.tables[0].rows:
                    cells = row.cells
                    if cells[0].text.strip().startswith("Wage bill in t_p − 1, level") and cells[1].text.startswith("−0.142"):
                        for t in cells[2]._tc.iter(W + "t"):
                            if t.text.strip() == OLD_T3P:
                                t.text = T3P
            if num == "A15" and fn == "Table_A17_new_columns":
                # p de bootstrap do -1,858 (amostra estrita, folha fixa): o mesmo valor da coluna principal da Tabela A15
                for row in d.tables[0].rows:
                    tx = [c.text.strip() for c in row.cells]
                    if tx[0] == "Bootstrap p" and tx[-2:] == ["0.064", "0.070"] and tx[-3] == "0.022":
                        for t in row.cells[-2]._tc.iter(W + "t"):
                            if t.text.strip() == "0.064":
                                t.text = "0.063"
                # IC do mesmo modelo: o da coluna principal da Tabela A15 (mesmo sorteio do p)
                for t in d.element.body.iter(W + "t"):
                    if t.text and "[−3.741; 0.129]" in t.text:
                        t.text = t.text.replace("[−3.741; 0.129]", "[−3.737; 0.111]")
            if num == "A2" and i == 0:
                nf3.drop_panel_b(d)
            if num == "A10":
                a10_groups(d)
            if i == 0 and notes_add(num):
                for p in d.paragraphs:
                    if p.text.startswith("Notes"):
                        p.runs[-1].text = p.runs[-1].text + notes_add(num)
                        break
            if base is None:
                base = d
                sect = base.element.body[-1]
            else:
                p = base.add_paragraph()
                sect.addprevious(p._p)
                for el in list(d.element.body):
                    if el.tag == W + "sectPr":
                        continue
                    sect.addprevious(copy.deepcopy(el))
            t = (folder / "tables" / f"{fn}.tex").read_text(encoding="utf-8")
            t = fix_text(t, sch)
            t = re.sub(r"\\label\{tab:[^}]*\}", "", t)
            for a, b in SPEC.get(num, []):
                if b is not None:
                    t = t.replace(tex_esc(a), tex_esc(b))
            if num == "A15" and fn == "Table_A15_panel_size":
                t = t.replace(f"$-$0.142 [$-$0.284; $-$0.001] & {OLD_T3P}", f"$-$0.142 [$-$0.284; $-$0.001] & {T3P}")
            if num == "A15" and fn == "Table_A17_new_columns":
                t = t.replace("0.022 & 0.064 & 0.070", "0.022 & 0.063 & 0.070")
                t = t.replace("[$-$3.741; 0.129]", "[$-$3.737; 0.111]")
            if num == "A2" and i == 0:
                t = re.sub(r"\nB\. Annual panel.*?(?=\\bottomrule)", "\n", t, flags=re.S)
            if num == "A10":
                t = t.replace("\nConventional timing", "\nAlternative specifications &  &  &  &  \\\\\nConventional timing", 1)
                t = t.replace("\nSpecification curve", "\nSummaries over many specifications &  &  &  &  \\\\\nSpecification curve", 1)
            if i == 0 and notes_add(num):
                t = t.replace("\\end{minipage}", tex_esc(notes_add(num)) + "\\end{minipage}", 1)
            tex.append(t)
        out = OUT / "tables" / f"Table_{num}_{name}"
        base.save(str(out) + ".docx")
        Path(str(out) + ".tex").write_text("\n\n".join(tex), encoding="utf-8")
    for num, name, folder, fn in FIGS:
        for ext in ("png", "pdf", "eps"):
            shutil.copy2(folder / "figures" / f"{fn}.{ext}", OUT / "figures" / f"Figure_{num}_{name}.{ext}")


FORBID = nf3.FORBID + [r"(?i)earlier round", r"(?i)earlier version", r"(?i)\breplaces\b", r"plan addendum", r"a supplementary (table|figure)",
                       r"(?i)earlier panel"]
FORBID = [p for p in FORBID if p != r"Figures? A[3-9]\b"] + [r"Figures? A[4-9]\b"]
FORBID += [r"\(main\)", r"\bmain design\b"]


def verify():
    bad = 0
    for f in sorted((OUT / "tables").glob("*.docx")):
        d = docx.Document(str(f))
        txt = " ".join(p.text for p in d.paragraphs) + " " + " ".join(c.text for t in d.tables for r in t.rows for c in r.cells)
        for pat in FORBID:
            for m in re.finditer(pat, txt):
                s = txt[max(0, m.start() - 60): m.end() + 40]
                if any(p in s for p in ("Penn World Table", "their Table", "Mollick and Vianna (2024, Table", "Mollick and Vianna, 2024, Table",
                                        "Table 2, p.", "Table 3, p.", "Cabral (2011, Table")):
                    continue
                bad += 1
                print(f"{f.name}: '{m.group(0)}' em ...{s}...")
    print(f"verificacao: {bad} ocorrencias proibidas")
    return bad


if __name__ == "__main__":
    build()
    sys.exit(1 if verify() else 0)
