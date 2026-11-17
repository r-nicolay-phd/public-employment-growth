"""Bloco 7: baixa as series gratuitas usadas no denominador alternativo.

- IMF GFS (Statement of Operations), G21 compensacao de empregados, governo geral (S13), em moeda nacional (XDC).
- IMF WEO, PIB nominal em moeda nacional (NGDP).
Uso (na pasta Estimacoes): python code/kyklos3/dl_fontes.py
Grava data/raw/imf_gfs_xdc/g21_xdc.csv e data/raw/imf_weo_ngdp/weo_ngdp.csv, com _SOURCE.txt.
"""
import datetime
import subprocess
from pathlib import Path

import pandas as pd

HDR = "Accept: application/vnd.sdmx.data+csv;version=2.0.0"
SRC = {
    "imf_gfs_xdc": ("https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.STA/GFS_SOO/+/*.S13.G2M.G21_T.XDC.A",
                    "g21_xdc.csv",
                    "IMF Government Finance Statistics, Statement of Operations (dataflow IMF.STA/GFS_SOO): G21_T "
                    "(compensation of employees), sector S13 (general government), national currency (XDC), annual."),
    "imf_weo_ngdp": ("https://api.imf.org/external/sdmx/3.0/data/dataflow/IMF.RES/WEO/+/*.NGDP.A",
                     "weo_ngdp.csv",
                     "IMF World Economic Outlook (dataflow IMF.RES/WEO): NGDP (gross domestic product, current prices, "
                     "national currency), annual."),
}
today = datetime.date.today().isoformat()
for folder, (url, fname, desc) in SRC.items():
    out = Path("data/raw") / folder
    out.mkdir(parents=True, exist_ok=True)
    tmp = out / ("_raw_" + fname)
    subprocess.run(["curl", "-s", "-m", "600", "-H", HDR, url, "-o", str(tmp)], check=True)
    d = pd.read_csv(tmp, low_memory=False)
    keep = [c for c in ("COUNTRY", "INDICATOR", "SECTOR", "TYPE_OF_TRANSFORMATION", "TIME_PERIOD", "OBS_VALUE", "UNIT", "SCALE")
            if c in d.columns]
    d = d[keep]
    d.to_csv(out / fname, index=False)
    tmp.unlink()
    (out / "_SOURCE.txt").write_text(
        f"Data de acesso: {today}\nAPI (SDMX 3.0, SDMX-CSV): {url}\n{desc}\nArquivo: {fname} ({len(d)} linhas). "
        "Gratuito. Usado no Bloco 7 do terceiro adendo (code/kyklos3/08_fontes.do).\n", encoding="utf-8")
    print(folder, len(d), d.head(2).to_dict("records"))
