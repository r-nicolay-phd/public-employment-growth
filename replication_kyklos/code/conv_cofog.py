"""Converte a exportacao completa do IMF GFS COFOG (formato largo, ~530 MB) num arquivo longo e pequeno.

Uso (na pasta Estimacoes): python3 code/conv_cofog.py
Entrada: data/raw/imf_cofog/dataset_*_IMF.STA_GFS_COFOG_*.csv (download manual, data.imf.org)
Saida:   data/raw/imf_cofog/gfs_cofog_saude_educ.csv (iso3, year, sector, cofog, unit, value)
Mantem: governo geral (S13) e central com seguridade (S1321); saude (GF07), educacao (GF09) e desembolso
total (TOTOUT); em % do PIB e em % do desembolso total. So conversao de formato, nenhuma estimacao.
"""
import csv
import glob
from pathlib import Path

SETORES = {"S13", "S1321"}
FUNCOES = {"GF07_T", "GF09_T", "TOTOUT_T"}
UNIDADES = {"POGDP_PT", "POTO_PT"}

src = glob.glob("data/raw/imf_cofog/dataset_*GFS_COFOG*.csv")
assert len(src) == 1, src
out = Path("data/raw/imf_cofog/gfs_cofog_saude_educ.csv")
n = 0
with open(src[0], encoding="utf-8-sig", newline="") as fi, out.open("w", encoding="utf-8", newline="") as fo:
    r = csv.DictReader(fi)
    anos = [c for c in r.fieldnames if c.isdigit()]
    w = csv.writer(fo)
    w.writerow(["iso3", "year", "sector", "cofog", "unit", "value"])
    for row in r:
        iso3, setor, _, funcao, unidade, freq = row["SERIES_CODE"].split(".")[:6]
        if setor in SETORES and funcao in FUNCOES and unidade in UNIDADES and freq == "A":
            for a in anos:
                v = row[a].strip()
                if v:
                    w.writerow([iso3, a, setor, funcao.replace("_T", ""), unidade.replace("_PT", ""), v])
                    n += 1
print(src[0], "->", out, n, "observacoes")
