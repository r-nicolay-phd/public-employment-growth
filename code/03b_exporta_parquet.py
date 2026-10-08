"""Conversao de formato: data/final/*.dta -> *.parquet (chamado por 03_painel.do; nao transforma dados)."""
from pathlib import Path
import pandas as pd
FINAL = Path(__file__).resolve().parents[1] / "data" / "final"
for n in ["painel_anual", "painel_3anos", "painel_5anos"]:
    df = pd.read_stata(FINAL / f"{n}.dta", convert_categoricals=False)
    df.to_parquet(FINAL / f"{n}.parquet", index=False)
    print(n, df.shape)
