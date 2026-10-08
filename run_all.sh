#!/usr/bin/env bash
# Refaz o projeto inteiro: coleta (Python, so download), limpeza/estimacao/saidas (Stata) e conversao para parquet.
# Uso:  bash run_all.sh            (reaproveita downloads ja feitos)
#       bash run_all.sh --force    (baixa todas as fontes de novo)
set -euo pipefail
cd "$(dirname "$0")"
STATA="${STATA:-/c/Program Files/Stata17/StataMP-64.exe}"
python code/01_coleta_wf1.py
python code/01_coleta_fontes.py "$@"
"$STATA" //e do run_all.do
grep -q "^r([0-9]*);" run_all.log && { echo "ERRO no Stata: ver run_all.log"; exit 1; }
python code/03b_exporta_parquet.py
echo "Pipeline concluido."
