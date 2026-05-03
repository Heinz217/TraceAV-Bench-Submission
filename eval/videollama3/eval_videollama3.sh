#!/bin/bash
# LV-Bench eval launcher. Set required paths via environment before running.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PY_SCRIPT="$SCRIPT_DIR/eval_videollama3.py"

# Required:
: "${VL3_MODEL_PATH:?Set VL3_MODEL_PATH to the model weights directory.}"
: "${VL3_CLEANED_DIR:?Set VL3_CLEANED_DIR to the cleaned/ JSON directory.}"
: "${VL3_VIDEOS_DIR:?Set VL3_VIDEOS_DIR to the videos directory.}"

# Optional:
VL3_OUTPUT_DIR="${VL3_OUTPUT_DIR:-$SCRIPT_DIR/runs}"
mkdir -p "$VL3_OUTPUT_DIR"

export CUDA_VISIBLE_DEVICES="${CUDA_VISIBLE_DEVICES:-0}"
export VL3_MODEL_PATH
export VL3_CLEANED_DIR
export VL3_VIDEOS_DIR
export VL3_OUTPUT_DIR
export TOKENIZERS_PARALLELISM=false
export OMP_NUM_THREADS=1
export PYTORCH_CUDA_ALLOC_CONF=expandable_segments:True

python3 "$PY_SCRIPT"
