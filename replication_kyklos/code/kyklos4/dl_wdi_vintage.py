"""Bloco 5, item 2: baixa as series do WDI usadas por Mollick e Vianna (2024) em safras antigas (WDI Database Archives).

Fonte gratuita: World Bank API, source 57 (WDI Database Archives), versoes 202212 (dez/2022) e 202312 (dez/2023).
Series: NY.GDP.MKTP.KD.ZG, NE.CON.GOVT.ZS, NE.GDI.TOTL.ZS, SP.POP.GROW; anos 1994-2019; todos os paises.
Uso (na pasta Estimacoes): python code/kyklos4/dl_wdi_vintage.py
Grava data/raw/wdi_archives/wdi_<versao>.csv e _SOURCE.txt.
"""
import datetime
import json
import time
import urllib.request
from pathlib import Path

import pandas as pd

OUT = Path("data/raw/wdi_archives")
OUT.mkdir(parents=True, exist_ok=True)
SERIES = ["NY.GDP.MKTP.KD.ZG", "NE.CON.GOVT.ZS", "NE.GDI.TOTL.ZS", "SP.POP.GROW"]
VERSIONS = ["202212", "202312"]
BASE = "https://api.worldbank.org/v2/sources/57/country/all/series/{s}/version/{v}/time/{t}?format=json&per_page=20000&page={p}"
TIME = ";".join(f"YR{y}" for y in range(1994, 2020))


def get(url):
    for k in range(5):
        try:
            with urllib.request.urlopen(url, timeout=180) as r:
                return json.loads(r.read().decode("utf-8"))
        except Exception as e:  # noqa: BLE001
            err = e
            time.sleep(5 * (k + 1))
    raise err


log = []
for v in VERSIONS:
    if (OUT / f"wdi_{v}.csv").exists():
        log.append(f"{v}: arquivo ja baixado")
        continue
    rows = []
    for s in SERIES:
        p, pages = 1, 1
        while p <= pages:
            d = get(BASE.format(s=s, v=v, t=TIME, p=p))
            pages = d.get("pages", 1)
            for o in d["source"]["data"]:
                var = {x["concept"]: x["id"] for x in o["variable"]}
                rows.append(dict(iso3=var["Country"], year=int(var["Time"][2:]), series=s, value=o["value"]))
            p += 1
        log.append(f"{v} {s}: ok")
    df = pd.DataFrame(rows).pivot_table(index=["iso3", "year"], columns="series", values="value").reset_index()
    df.columns = ["iso3", "year"] + [c.replace(".", "_") for c in df.columns[2:]]
    df.to_csv(OUT / f"wdi_{v}.csv", index=False)
    print(v, df.shape)
(OUT / "_SOURCE.txt").write_text(
    f"Data de acesso: {datetime.date.today().isoformat()}\n"
    "Fonte: World Bank, WDI Database Archives (API v2, source 57), gratuito.\n"
    f"URL: {BASE.format(s='<serie>', v='<versao>', t='YR1994;...;YR2019', p=1)}\n"
    f"Versoes: {', '.join(VERSIONS)} (dez/2022 e dez/2023). Series: {', '.join(SERIES)}.\n"
    "Usado no Bloco 5, item 2, do quarto adendo (code/kyklos4/05_inst.do): especificacao publicada de Mollick e Vianna (2024)\n"
    "com safras antigas do WDI. O artigo nao informa a data de acesso dos autores.\n" + "\n".join(log) + "\n", encoding="utf-8")
