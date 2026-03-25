#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

echo "Project root: $ROOT_DIR"

mkdir -p results

echo "Checking Python..."
python --version

echo "Checking R..."
R --version

echo "Installing Python dependencies if needed..."
python - <<'PY'
import importlib, subprocess, sys, pathlib

req_file = pathlib.Path("code/python/requirements.txt")
if req_file.exists():
    subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", str(req_file)])
PY

echo "Ensuring Jupyter is installed..."
python -m pip install jupyter nbconvert

echo "Running Python notebook..."
python -m jupyter nbconvert \
  --to notebook \
  --execute \
  --inplace \
  --ExecutePreprocessor.timeout=3600 \
  code/python/notebook.ipynb

echo "Running R SEM analysis..."
Rscript code/r/sem_analysis.R

echo "Pipeline finished successfully."