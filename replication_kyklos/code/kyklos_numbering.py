"""Copy the tables and figures produced by the Stata code to the file names and numbering of the Kyklos
submission. Only labels change: table titles and cross-references to tables and figures are renumbered;
no number estimated by the code is touched.

Usage (from the package root, after code/master.do):
    python code/kyklos_numbering.py output/generated output
Writes output/tables/Table_<n>_<name>.{docx,tex} and output/figures/Figure_<n>_<name>.{png,pdf,eps}.
Requires python-docx (pip install python-docx).
"""
import re
import shutil
import sys
from pathlib import Path

# code file name -> (Kyklos number, Kyklos file name)
TABLES = {
    "Tab1_measures": ("1", "Table_1_measures"),
    "Tab4_coverage": ("2", "Table_2_coverage"),
    "Tab5_decomposition": ("3", "Table_3_decomposition"),
    "Tab2_timing": ("A1", "Table_A1_timing"),
    "Tab3_baseline_composition": ("A2", "Table_A2_baseline_composition"),
    "Tab6_replications": ("A3", "Table_A3_institutions_replications"),
    "Tab7_political_economy": ("A4", "Table_A4_political_economy"),
    "Tab8_robustness_map": ("A5", "Table_A5_robustness_map"),
    "TabS1_data_cleaning": ("S1", "Table_S1_data_sources_cleaning"),
    "TabS2_descriptives": ("S2", "Table_S2_descriptives"),
    "TabS_bias_decomposition": ("S3", "Table_S3_bias_decomposition"),
    "TabS_lags_leads": ("S4", "Table_S4_lags_leads"),
    "TabS_gg_cg_ratio": ("S5", "Table_S5_general_central_ratio"),
    "TabS_decomposition_bias": ("S6", "Table_S6_decomposition_bias"),
    "TabS_cyclicality": ("S7", "Table_S7_cyclicality"),
    "TabS_structural": ("S8", "Table_S8_structural"),
    "TabS_moderation": ("S9", "Table_S9_merit_moderation"),
    "TabS_exogenous": ("S10", "Table_S10_narrative_consolidations"),
    "TabS_bond_longrun": ("S11", "Table_S11_bond_longrun"),
    "TabS_mechanisms": ("S12", "Table_S12_mechanisms"),
    "TabS_inference_summary": ("S13", "Table_S13_hypothesis_tests"),
    "TabS_lp_horizons": ("S14", "Table_S14_lp_horizons"),
    "TabS_bma": ("S15", "Table_S15_bma"),
    "TabS16_countries": ("S16", "Table_S16_countries"),
    "TabS_mv_faithful": ("S17", "Table_S17_mollick_vianna_published"),
    "TabS_opra_xconst": ("S18", "Table_S18_oto_peralias_polity5"),
}
FIGURES = {
    "Fig3_timing": "Figure_1_timing",
    "Fig4_reconciliation": "Figure_2_institutions",
    "Fig7_lp_level_leads": "Figure_3_local_projections",
    "Fig9_specification_curve": "Figure_4_specification_curve",
    "Fig1_wagebill_income": "Figure_A1_wagebill_income",
    "Fig2_measures": "Figure_A2_measures",
    "Fig5_employment_relwage": "Figure_A3_employment_relative_pay",
    "Fig6_marginal_merit": "Figure_A4_marginal_effect_merit",
    "Fig8_lp_merit": "Figure_A5_lp_merit",
    "FigS1_coverage": "Figure_S1_coverage",
    "FigS_structural": "Figure_S2_structural",
    "FigS_interflex_binning": "Figure_S3_interflex_binning",
    "FigS_exogenous": "Figure_S4_narrative_consolidations",
}
# exhibits of the additional Kyklos estimates (code/kyklos), already numbered for Kyklos: copied, not renumbered.
# The single-inference Table 2 and the new Figures 1 and 3 are proposed replacements; they keep their own names so
# that the current versions are not overwritten.
NEW_TABLES = {
    "Tab2new_coverage": "Table_2_coverage_single_inference_proposed",
    "TabS19_mollick_cabral": "Table_S19_mollick_cabral",
    "TabS20_spending_items": "Table_S20_spending_items",
    "TabS21_five_year_grid": "Table_S21_five_year_grid",
    "TabS22_h2_strict": "Table_S22_h2_strict_timing",
    "TabS23_lp_predetermined": "Table_S23_lp_predetermined_shocks",
    "TabS24_simulation": "Table_S24_simulation",
    "TabS25_equivalence": "Table_S25_equivalence_influence",
    "TabS26_institutions_tests": "Table_S26_institutions_tests",
    "TabS27_coverage": "Table_S27_coverage_did",
    "TabS28_checks": "Table_S28_checks",
}
NEW_FIGURES = {
    "Fig1new_timing_grid": "Figure_1_timing_grid_proposed",
    "Fig3new_lp_shock_a": "Figure_3_lp_shock_dated_t-1_proposed",
    "FigS5_mollick_cabral": "Figure_S5_mollick_cabral",
    "FigS6_lp_shocks": "Figure_S6_lp_shocks",
    "FigS7_simulation": "Figure_S7_simulation",
    "FigS8_influence": "Figure_S8_influence",
}
# exhibits of the final estimates (code/kyklos2), already written with the numbering of version 4 of the article:
# copied, not renumbered. Table A5 and Figure A3 replace the earlier versions (Table_S24_simulation, Figure_S7_simulation,
# which are kept); the other files are new panels, rows or columns of existing appendix tables.
NEW2_TABLES = ["Table_A5_simulation", "Table_A2_panel_B_harmonized", "Table_A6_new_rows", "Table_A11_panel_bias_checks",
               "Table_A15_new_panels", "Table_A16_new_rows", "Table_A17_new_columns", "Table_A18_new_panel"]
NEW2_FIGURES = ["Figure_A3_simulation"]
# numbering produced by the code -> Kyklos numbering
TAB_REF = {"1": "1", "2": "A1", "3": "A2", "4": "2", "5": "3", "6": "A3", "7": "A4", "8": "A5"}
FIG_REF = {"1": "A1", "2": "A2", "3": "1", "4": "2", "5": "A3", "6": "A4", "7": "3", "8": "A5", "9": "4",
           "S1": "S1", "S2": "S2", "S3": "S4", "S4": "S3"}

TOKEN = r"S?\d+(?:[a-c](?:–[a-c])?)?(?:\([a-z]\))?"
LIST = rf"{TOKEN}(?:(?:, | and |–| to | or ){TOKEN})*"
RX = re.compile(rf"\b(Tables?|Figures?)( )({LIST})(?![\d])")


def _map_token(kind, tok):
    m = re.match(r"(S?\d+)(.*)", tok)
    base, rest = m.group(1), m.group(2)
    table = TAB_REF if kind.startswith("Table") else FIG_REF
    if kind.startswith("Table") and base.startswith("S"):
        return tok
    return table.get(base, base) + rest


# references to tables of other works, which keep their own numbers
PROTECT = ["Mollick and Vianna, 2024, Table 2", "Mollick and Vianna (2024, Table 2", "equation (1) and Table 2",
           "their Table 1", "Penn World Table"]


def renumber(text):
    keep = {}
    for i, p in enumerate(PROTECT):
        if p in text:
            key = f"\x00{i}\x00"
            keep[key] = p
            text = text.replace(p, key)
    text = _renumber(text)
    for key, p in keep.items():
        text = text.replace(key, p)
    return text


def _renumber(text):
    def f(m):
        kind, sp, lst = m.group(1), m.group(2), m.group(3)
        parts = re.split(r"(, | and |–| to | or )", lst)
        out = []
        for p in parts:
            out.append(p if re.fullmatch(r", | and |–| to | or ", p) else _map_token(kind, p))
        return kind + sp + "".join(out)
    return RX.sub(f, text)


def do_docx(src, dst):
    import docx
    d = docx.Document(str(src))
    for t in d.element.body.iter("{http://schemas.openxmlformats.org/wordprocessingml/2006/main}t"):
        if t.text:
            t.text = renumber(t.text)
    d.save(str(dst))


def main(gen, out):
    gen, out = Path(gen), Path(out)
    (out / "tables").mkdir(parents=True, exist_ok=True)
    (out / "figures").mkdir(parents=True, exist_ok=True)
    n = 0
    for code_name, (num, new) in TABLES.items():
        for ext in ("docx", "tex"):
            src = gen / "tables" / f"{code_name}.{ext}"
            if not src.exists():
                print("missing:", src)
                continue
            dst = out / "tables" / f"{new}.{ext}"
            if ext == "docx":
                do_docx(src, dst)
            else:
                tex = renumber(src.read_text(encoding="utf-8"))
                tex = re.sub(r"^% generated by code\S* \(Stata 17\)", "% generated by the Stata code of the replication package", tex, flags=re.M)
                tex = tex.replace(f"\\label{{tab:{code_name}}}", f"\\label{{tab:{new}}}")
                dst.write_text(tex, encoding="utf-8")
            n += 1
    m = 0
    for code_name, new in FIGURES.items():
        for ext in ("png", "pdf", "eps"):
            src = gen / "figures" / f"{code_name}.{ext}"
            if not src.exists():
                print("missing:", src)
                continue
            shutil.copy2(src, out / "figures" / f"{new}.{ext}")
            m += 1
    k = 0
    for sub, mapa, exts in (("tables", NEW_TABLES, ("docx", "tex", "csv")), ("figures", NEW_FIGURES, ("png", "pdf", "eps"))):
        for code_name, new in mapa.items():
            for ext in exts:
                src = gen / "kyklos" / sub / f"{code_name}.{ext}"
                if src.exists():
                    shutil.copy2(src, out / sub / f"{new}.{ext}")
                    k += 1
    j = 0
    for sub, names, exts in (("tables", NEW2_TABLES, ("docx", "tex", "csv")), ("figures", NEW2_FIGURES, ("png", "pdf", "eps"))):
        for nm in names:
            for ext in exts:
                src = gen / "kyklos2" / sub / f"{nm}.{ext}"
                if src.exists():
                    shutil.copy2(src, out / sub / f"{nm}_v4.{ext}")
                    j += 1
    print(f"{n} table files and {m} figure files written to {out}; {k} files of the additional estimates and "
          f"{j} files of the final estimates (version 4 numbering, suffix _v4) copied")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
