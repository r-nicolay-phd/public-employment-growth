"""Fase 0: leitura do arquivo EViews original (.wf1) e exportacao para Stata.

Estrutura binaria verificada (ver prompt do projeto, secao 5):
- tamanho do cabecalho: int64 na posicao 80 (=196)
- registros de variaveis de 70 bytes a partir da posicao 222
- em cada registro: nome nos bytes 22-53, tamanho dos dados int32 na posicao 10,
  posicao dos dados int64 na posicao 14; valores comecam 22 bytes depois, float64 LE
- ausente = 1e-37
"""
import struct, sys
from pathlib import Path
import numpy as np, pandas as pd

ROOT = Path(__file__).resolve().parents[1]
WF1 = ROOT / "inputs" / "painel_consolidado_dissertacao_1996_2023.wf1"
OUT = ROOT / "data" / "interim"
N_OBS, N_UNITS, YEARS = 7392, 264, list(range(1996, 2024))

b = WF1.read_bytes()
hdr = struct.unpack_from("<q", b, 80)[0]
recs = {}
pos = 222
while pos + 70 <= len(b):
    r = b[pos:pos + 70]
    name = r[22:54].split(b"\x00")[0].decode("latin-1").strip()
    if not name or not all(32 <= c < 127 for c in name.encode("latin-1")):
        break
    size = struct.unpack_from("<i", r, 10)[0]
    dpos = struct.unpack_from("<q", r, 14)[0]
    recs[name] = (size, dpos)
    pos += 70
print(f"cabecalho={hdr}; {len(recs)} registros")

cols = {}
for name, (size, dpos) in recs.items():
    start = dpos + 22
    if name in ("COUNTRY_CODE", "COUNTRY_NAME"):
        w = 3 if name == "COUNTRY_CODE" else 73
        raw = b[start:start + w * N_OBS]
        vals = [raw[i * w:(i + 1) * w].split(b"\x00")[0].decode("latin-1").strip() for i in range(N_OBS)]
        cols[name] = vals
        continue
    if size < 8 * N_OBS:
        continue  # objetos que nao sao series do painel (escalar, coeficientes, etc.)
    arr = np.frombuffer(b, dtype="<f8", count=N_OBS, offset=start).copy()
    arr[np.isclose(arr, 1e-37, rtol=0, atol=1e-40)] = np.nan
    cols[name] = arr

df = pd.DataFrame(cols)
skipped = [n for n in recs if n not in cols]
print("series lidas:", [c for c in df.columns])
print("registros ignorados:", skipped)
# ordem do painel: unidade x ano (28 anos por unidade)
df["year"] = np.tile(YEARS, N_UNITS)
chk = df.groupby("COUNTRY_CODE").size()
assert (chk == 28).all() and len(chk) == N_UNITS, "estrutura unidade x ano nao confere"
df.columns = [c.lower() for c in df.columns]
df.to_csv(OUT / "wf1_original.csv", index=False)
print(df.shape)
