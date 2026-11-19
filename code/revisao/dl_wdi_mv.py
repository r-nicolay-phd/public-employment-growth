"""Baixa da API v2 do Banco Mundial as series da replica de Mollick e Vianna (2023).

Uso (na pasta Estimacoes): python3 code/revisao/dl_wdi_mv.py
Saida: data/raw/wdi_rev/wdi_rev_mv.csv (iso3, year, indicator, value). So download, nenhuma estimacao.
"""
import csv
import json
import time
import urllib.request
from pathlib import Path

INDICADORES = ["NY.GDP.MKTP.KD.ZG", "NE.GDI.TOTL.ZS", "NE.CON.GOVT.ZS"]
OUT = Path("data/raw/wdi_rev/wdi_rev_mv.csv")


def baixa(ind):
    linhas, pag, npag = [], 1, 1
    while pag <= npag:
        url = (f"https://api.worldbank.org/v2/country/all/indicator/{ind}"
               f"?format=json&per_page=20000&date=1990:2023&page={pag}")
        with urllib.request.urlopen(url, timeout=120) as r:
            meta, dados = json.load(r)
        npag = meta["pages"]
        for d in dados or []:
            if d["value"] is not None and d["countryiso3code"]:
                linhas.append((d["countryiso3code"], d["date"], ind, d["value"]))
        pag += 1
        time.sleep(0.5)
    return linhas


with OUT.open("w", newline="", encoding="utf-8") as f:
    w = csv.writer(f)
    w.writerow(["iso3", "year", "indicator", "value"])
    for ind in INDICADORES:
        lin = baixa(ind)
        w.writerows(lin)
        print(ind, len(lin))
