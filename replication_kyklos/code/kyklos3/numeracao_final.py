"""Tabelas e figuras com a numeracao da versao final do artigo (Kyklos), em output/kyklos3/final/.

Le copias das saidas de output/kyklos (numeracao da versao 3 e Tabelas S19-S28), output/kyklos2 (versao 4) e
output/kyklos3 (versao final); nenhum arquivo de origem e alterado e nenhum numero estimado muda. Para cada tabela final:
- junta a tabela de base e os paineis, linhas ou colunas novos (titulos "continued");
- renumera titulos e referencias cruzadas segundo o esquema de cada arquivo;
- referencias a tabelas e figuras que nao entram na versao final passam a "the replication package";
- troca rotulos internos (T1-T6, "B1 sample", caminhos de arquivo) por descricoes;
- na Tabela A2, o painel B antigo e substituido pelo painel harmonizado; na A17, acrescenta-se o F do calendario eleitoral.
Uso (from the package root): python code/kyklos3/numeracao_final.py
"""
import copy
import csv
import re
import shutil
import sys
from pathlib import Path

import docx

ROOT = Path.cwd()
K1 = ROOT / "output" / "generated" / "kyklos"
K2 = ROOT / "output" / "generated" / "kyklos2"
K3 = ROOT / "output" / "generated" / "kyklos3"
OUT = ROOT / "output" / "final"

# esquema -> mapa de tabelas e de figuras para a numeracao final (None: fora da versao final)
TAB = {
    "v3": {"1": "1", "2": "A11", "3": "2", "A1": None, "A2": "A8", "A3": "A12", "A4": None, "A5": "A10", "S1": "A1", "S2": "A2",
           "S3": None, "S4": None, "S5": None, "S6": None, "S7": None, "S8": None, "S9": None, "S10": None, "S11": None,
           "S12": None, "S13": "A17", "S14": None, "S15": None, "S16": None, "S17": "A14", "S18": None, "S19": "A6",
           "S20": "A3", "S21": "A7", "S22": "A15", "S23": "A16", "S24": "A4", "S25": "A9", "S26": "A13", "S27": None,
           "S28": "A5"},
    "v4": {"1": "1", "2": "A11", "3": "2", "A1": "A1", "A2": "A2", "A3": None, "A4": "A3", "A5": "A4", "A6": "A5", "A7": "A6",
           "A8": "A7", "A9": None, "A10": "A9", "A11": "A8", "A12": "A10", "A13": None, "A14": "A12", "A15": "A13",
           "A16": "A14", "A17": "A15", "A18": "A16", "A19": "A17"},
}
FIG = {
    "v3": {"1": "2", "2": "3", "3": "4", "4": None, "A1": None, "A2": None, "A3": None, "A4": None, "A5": None, "S1": "A1",
           "S2": None, "S3": None, "S4": None, "S5": None, "S6": None, "S7": "1", "S8": "A2"},
    "v4": {"1": "2", "2": None, "3": "3", "4": "4", "A1": None, "A2": "A1", "A3": "1", "A4": "A2", "A5": None, "A6": None},
}
PROTECT = ["Mollick and Vianna, 2024, Table 2", "Mollick and Vianna (2024, Table 2", "Mollick and Vianna (2024), Table 2",
           "equation (1) and Table 2", "their Table 1", "their Table 2", "Penn World Table", "(Table 2, p. 131", "Table 3, p. 134",
           "Tabela 2", "Mollick and Vianna, 2024, Table 2)", "Cabral (2011, Table"]
TOKEN = r"[SA]?\d+(?:[a-c](?:–[a-c])?)?(?:\([a-z]\))?"
SEP = r"(?:, | and |–| to | or )"
RX = re.compile(rf"\b(Tables?|Figures?) ({TOKEN}(?:{SEP}{TOKEN})*)(?![\d])")


def renumber(text, scheme):
    if scheme == "fin":
        return text
    keep = {}
    for i, p in enumerate(PROTECT):
        if p in text:
            k = f"\x00{i}\x00"
            keep[k] = p
            text = text.replace(p, k)

    def f(m):
        kind, lst = m.group(1), m.group(2)
        mp = TAB[scheme] if kind.startswith("Table") else FIG[scheme]
        parts = re.split(rf"({SEP})", lst)
        toks = []
        for p in parts:
            if re.fullmatch(SEP, p):
                continue
            mm = re.match(r"([SA]?\d+)(.*)", p)
            base, rest = mm.group(1), mm.group(2)
            if base not in mp:
                toks.append(p)
            elif mp[base] is not None:
                toks.append(mp[base] + rest)
        if not toks:
            return "a supplementary table in the replication package" if kind.startswith("Table") else "a supplementary figure in the replication package"
        word = kind.rstrip("s") + ("s" if len(toks) > 1 else "")
        return word + " " + (", ".join(toks[:-1]) + " and " + toks[-1] if len(toks) > 1 else toks[0])
    text = RX.sub(f, text)
    for k, p in keep.items():
        text = text.replace(k, p)
    return text


# rotulos internos -> descricoes (ordem importa)
CLEAN = [
    (r"preferred H1 specification \(T3\)", "preferred H1 specification"),
    (r"\(T3: ", "("),
    (r"β\(T3\)", "β(preferred)"), (r"β\(T3 \+", "β(preferred +"),
    (r"T3: preferred", "Preferred"), (r"T3, 3-year", "Preferred, 3-year"),
    (r"T3 timing", "Preferred timing"), (r"\bT3 sample", "preferred-specification sample"),
    (r"\bT3 controls", "controls of the preferred specification"), (r"\bT3 specification", "preferred specification"),
    (r"\bT3 estimation sample", "preferred estimation sample"), (r"\bT3 re-estimated", "the preferred specification re-estimated"),
    (r"\bT3, same observations", "Preferred, same observations"), (r"\(T3\)", "(preferred specification)"),
    (r"with T3\)", "with the preferred timing)"), (r"\bT3 \+ ", "Preferred + "),
    (r"(^|[.;:] )T3\b", lambda m: m.group(1) + "The preferred specification"),
    (r"\bT3\b", "the preferred specification"),
    (r"\bT1\b", "Wage bill in t_p − 1, period-mean controls"), (r"\bT2\b", "Growth excluding the first year"),
    (r"\bT4\b", "Without investment"), (r"\bT5\b", "Over trend GDP"), (r"\bT6\b", "Conventional timing"),
    (r"B1 sample", "baseline sample"), (r"\bB1\b", "baseline"),
    (r"docs/AUDITORIA_DADOS\.md", "the documentation of the replication package"),
    (r"data/raw/\*/\\?_SOURCE\.txt", "the source notes of the replication package"),
    (r"data/raw/[A-Za-z0-9_./*\\]+", "the replication package"),
    (r"\((?:new panels?|new rows|new columns|new version|panel B, harmonized|new panel)\)", "(continued)"),
]


def clean(text):
    for a, b in CLEAN:
        text = re.sub(a, b, text)
    # repeticoes criadas pelas trocas ("Preferred (preferred specification)", "X (X)")
    text = re.sub(r"(?i)\bpreferred \(preferred specification\)", "Preferred specification", text)
    text = re.sub(r"(?i)\b([A-Za-z][\w -]{3,60}) \(\1\)", r"\1", text)
    return text


def fix_docx(d, scheme):
    for t in d.element.body.iter("{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t"):
        if t.text:
            t.text = clean(renumber(t.text, scheme))


def fix_tex(s, scheme):
    s = clean(renumber(s, scheme))
    s = re.sub(r"\\label\{tab:[^}]*\}", "", s)
    return s


# tabelas finais: (numero, nome, [(pasta, arquivo, esquema)])
FINAL = [
    ("1", "measures", [(K1, "Table_1_measures", "v3")]),
    ("2", "employment_relative_pay", [(K1, "Table_3_decomposition", "v3")]),
    ("A1", "data_sources_cleaning", [(K1, "Table_S1_data_sources_cleaning", "v3")]),
    ("A2", "descriptives", [(K1, "Table_S2_descriptives", "v3"), (K2, "Table_A2_panel_B_harmonized", "v4")]),
    ("A3", "spending_items", [(K1, "TabS20_spending_items", "v3")]),
    ("A4", "simulation", [(K2, "Table_A5_simulation", "v4"), (K3, "Table_A4_panel_calibrated", "fin"),
                          (K3, "Table_A4_panel_lags_numerator", "fin")]),
    ("A5", "annual_checks", [(K1, "TabS28_checks", "v3"), (K2, "Table_A6_new_rows", "v4"), (K3, "Table_A5_rows_controls_sources", "fin")]),
    ("A6", "mollick_cabral", [(K1, "TabS19_mollick_cabral", "v3")]),
    ("A7", "five_year_grid", [(K1, "TabS21_five_year_grid", "v3")]),
    ("A8", "preferred_bias_checks", [(K1, "Table_A2_baseline_composition", "v3"), (K3, "Table_A8_panel_bias_common", "fin")]),
    ("A9", "equivalence_influence", [(K1, "TabS25_equivalence", "v3")]),
    ("A10", "robustness_map", [(K1, "Table_A5_robustness_map", "v3")]),
    ("A11", "general_central", [(K1, "Tab2new_coverage", "v3")]),
    ("A12", "institutions_replications", [(K1, "Table_A3_institutions_replications", "v3")]),
    ("A13", "institutions_tests", [(K1, "TabS26_institutions_tests", "v3"), (K2, "Table_A15_new_panels", "v4"),
                                   (K3, "Table_A13_rows_calibrated", "fin")]),
    ("A14", "mollick_vianna_published", [(K1, "Table_S17_mollick_vianna_published", "v3"), (K2, "Table_A16_new_rows", "v4")]),
    ("A15", "h2_strict", [(K1, "TabS22_h2_strict", "v3"), (K2, "Table_A17_new_columns", "v4"), (K3, "Table_A15_panel_size", "fin")]),
    ("A16", "local_projections", [(K1, "TabS23_lp_predetermined", "v3"), (K2, "Table_A18_new_panel", "v4")]),
    ("A17", "hypothesis_verdicts", [(K1, "Table_S13_hypothesis_tests", "v3")]),
]
FIGS = [("1", "simulation", K3, "Figure_1_simulation"), ("2", "five_year_grid", K1, "Fig1new_timing_grid"),
        ("3", "institutions", K1, "Figure_2_institutions"), ("4", "lp_dated_shock", K1, "Fig3new_lp_shock_a"),
        ("A1", "coverage", K1, "Figure_S1_coverage"), ("A2", "influence", K3, "Figure_A2_influence")]


def electoral_note():
    vals = {}
    p = K3 / "tables" / "conferencia_bloco8_final.csv"
    with open(p, encoding="utf-8") as f:
        for r in csv.DictReader(f):
            if "ep_dem_Feff" in r["desc"]:
                vals["dem"] = float(r["value"])
            if "ep_all_Feff" in r["desc"]:
                vals["all"] = float(r["value"])
    return (f" The effective F of the electoral calendar in the first stage of the political-economy check is {vals['dem']:.2f} "
            f"in democracies ({vals['all']:.2f} in all country-years), below the usual threshold for a strong instrument.")


def drop_panel_b(d):
    """Tabela A2: remove do quadro de base as linhas do painel B (substituido pelo painel harmonizado)."""
    tb = d.tables[0]
    rows = tb.rows
    start = None
    for i, r in enumerate(rows):
        if r.cells[0].text.strip().startswith("B."):
            start = i
            break
    if start is None:
        return
    for r in list(rows)[start:]:
        r._tr.getparent().remove(r._tr)


def build():
    (OUT / "tables").mkdir(parents=True, exist_ok=True)
    (OUT / "figures").mkdir(parents=True, exist_ok=True)
    W = "{http://schemas.openxmlformats.org/wordprocessingml/2006/main}"
    for num, name, parts in FINAL:
        base = None
        tex = []
        for i, (folder, fn, sch) in enumerate(parts):
            src = folder / "tables" / f"{fn}.docx"
            d = docx.Document(str(src))
            fix_docx(d, sch)
            if num == "A2" and i == 0:
                drop_panel_b(d)
            if num == "A17":
                for p in d.paragraphs:
                    if p.text.startswith("Notes"):
                        p.runs[-1].text = p.runs[-1].text + electoral_note()
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
            t = fix_tex(t, sch)
            if num == "A2" and i == 0:
                t = re.sub(r"\nB\. Annual panel.*?(?=\\bottomrule)", "\n", t, flags=re.S)
            if num == "A17":
                t = t.replace("\\end{minipage}", electoral_note() + "\\end{minipage}", 1)
            tex.append(t)
        out = OUT / "tables" / f"Table_{num}_{name}"
        base.save(str(out) + ".docx")
        (Path(str(out) + ".tex")).write_text("\n\n".join(tex), encoding="utf-8")
    for num, name, folder, fn in FIGS:
        for ext in ("png", "pdf", "eps"):
            shutil.copy2(folder / "figures" / f"{fn}.{ext}", OUT / "figures" / f"Figure_{num}_{name}.{ext}")


FORBID = [r"\bT[1-6]\b", r"\bB1\b", r"(?i)draft", r"(?i)\brevision\b", r"(?i)\breview\b", r"AUDITORIA", r"data/raw",
          r"docs/", r"Tables? S\d", r"Figures? S\d", r"Tables? A(1[89]|[2-9]\d)\b", r"Tables? [3-9]\b", r"Figures? A[3-9]\b",
          r"Figures? [5-9]\b"]


def verify():
    bad = 0
    for f in sorted((OUT / "tables").glob("*.docx")):
        d = docx.Document(str(f))
        txt = " ".join(p.text for p in d.paragraphs) + " " + " ".join(c.text for t in d.tables for r in t.rows for c in r.cells)
        for pat in FORBID:
            for m in re.finditer(pat, txt):
                s = txt[max(0, m.start() - 50): m.end() + 30]
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
