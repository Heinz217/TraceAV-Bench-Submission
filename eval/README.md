# `eval/`

Each subfolder holds one evaluator: `eval_<model>.py` + `eval_<model>.sh`.
All paths and keys are passed through environment variables.

### Remote API (`gemini/`)

```bash
export BENCHMARK_DIR=$(pwd)/data
export GEMINI_API_KEY=<your_key>
bash eval/gemini/eval_gemini.sh
```

### OpenAI-compatible server (`minicpm_o/`, `qwen25_omni/`, `qwen3_omni/`)

Host the model yourself (e.g. with vLLM), then:

```bash
export BENCHMARK_DIR=$(pwd)/data
export LVBENCH_BASE_URL=http://127.0.0.1:8000
bash eval/qwen3_omni_instruct/eval_qwen3_omni_instruct.sh
```

### Local HuggingFace (everything else)

```bash
export <PREFIX>_MODEL_PATH=/path/to/weights
export <PREFIX>_CLEANED_DIR=$(pwd)/data
export <PREFIX>_VIDEOS_DIR=/path/to/videos
bash eval/<model>/eval_<model>.sh
```

Each launcher prints the exact environment variables it needs if any are
missing.
