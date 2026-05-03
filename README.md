# TraceAV-Bench

**TraceAV-Bench: Benchmarking Multi-Hop Trajectory Reasoning over Long Audio-Visual Videos.**

TraceAV-Bench is the benchmark to jointly stress **multi-hop reasoning
over long audio-visual trajectories** and **multimodal hallucination
robustness**. 

This repository contains everything you need to 
(1) reproduce the dataset construction pipeline, 
(2) browse the intermediate outputs of each stage, and 
(3) evaluate your own audio-visual model against TraceAV-Bench.

```
TraceAV-Bench/
├── data/              Final benchmark.
├── src/               Benchmark construction pipeline.
├── intermediate/      Per-stage intermediate outputs.
├── eval/              Evaluation scripts.
├── requirements.txt
└── README.md
```

## Benchmark at a Glance

Dimensions are encoded as a two-letter prefix in every `task_type` and every
filename under `data/`:

- `a_*` — **AR** (Audio-Centric Reasoning)
- `v_*` — **VR** (Visual-Centric Reasoning)
- `av_*` — **AVR** (Audio-Visual Joint Reasoning)
- `mh_*` — **MH** (Multimodal Hallucination)

| Dim | Task file (= `task_type`)               | Paper sub-task (abbreviation)           | Videos | Questions |
|-----|-----------------------------------------|-----------------------------------------|-------:|----------:|
| AR  | `a_background_music.json`               | Background Music (BM)                    | 120 | 131 |
| AR  | `a_environmental_sound.json`            | Environmental Sound (ES)                 |  88 |  88 |
| AR  | `a_speech_context.json`                 | Speech Context (SC)                      | 121 | 130 |
| VR  | `v_spatial_reasoning.json`              | Spatial Reasoning (SR)                   | 165 | 165 |
| VR  | `v_visual_counting.json`                | Visual Counting (VC)                     | 219 | 226 |
| AVR | `av_information_retrieval.json`         | Information Retrieval (IR)               | 140 | 140 |
| AVR | `av_temporal_sequencing.json`           | Temporal Sequencing (TS)                 |  95 |  97 |
| AVR | `av_entity_tracking.json`               | Entity Tracking (ET)                     | 116 | 124 |
| AVR | `av_forward_causal_reasoning.json`      | Forward Causal Reasoning (FCR)           |  73 |  73 |
| AVR | `av_backward_causal_reasoning.json`     | Backward Causal Reasoning (BCR)          |  84 |  89 |
| AVR | `av_cross_modality_matching.json`       | Cross-Modality Matching (CMM)            |  84 |  85 |
| AVR | `av_spatiotemporal_localization.json`   | Spatiotemporal Localization (SL)         | 225 | 227 |
| MH  | `mh_visual_to_audio_deception.json`     | Visual-to-Audio Deception (V2A)          | 218 | 230 |
| MH  | `mh_audio_to_visual_deception.json`     | Audio-to-Visual Deception (A2V)          | 220 | 229 |
| MH  | `mh_temporal_splicing_fallacy.json`     | Temporal Splicing Fallacy (TSF)          | 151 | 166 |

## Data Format

Each task file in `data/` is a single JSON with the following shape:

```json
{
  "task_type": "v_visual_counting",
  "video_count": 219,
  "question_count": 226,
  "items": [
    {
      "question_id": 1,
      "video_id": "video2",
      "question": "...",
      "options": {"A": "...", "B": "...", "C": "...", "D": "..."},
      "question_type": "single",              // "single" or "multiple"
      "correct_options": ["C"],
      "answer_text": "...",
      "minute_hop_count": 40,                 // temporal span in minutes
      "hop_length_label": "long",             // "short" | "medium" | "long"
      "trajectory_with_timestamps": [
        {
          "event_id": 6,
          "evidence": "...",
          "label": "visual",                  // "visual" | "audio"| "audio-visual"
          "reason": "...",
          "timestamp_minute": 42,
          "event_time_range": {"start_minute": 41, "end_minute": 44}
        }
      ],

      "difficulty": "medium"                  // "easy" | "medium" | "hard"
    }
  ]
}
```

## Data Preparation

The source videos in TraceAV-Bench are not hosted in this repository.
Every video referenced in `data/*.json` is
resolved through [`data/video_name_mapping.json`](data/video_name_mapping.json).

For each entry in that mapping:

- If `source` is `"omnivideobench"`, the video must be downloaded from the
  official [OmniVideoBench](https://github.com/NJU-LINK/OmniVideoBench)
  release. The accompanying `id` (e.g. `video_168`) matches their internal
  file name.
- Otherwise, the `id` is a **YouTube video id** and the file can be fetched
  directly via `https://www.youtube.com/watch?v=<id>`.

Save all video files into a single local directory (e.g. `~/traceav_videos/`),
named `<video_id>.mp4` (`video1.mp4`, `video2.mp4`, …). Every evaluator
locates videos by this flat layout via a `*_VIDEOS_DIR` environment
variable (see the launcher `.sh` for the exact name).

A minimal resolver:

```python
import json, os

VIDEOS_DIR = os.path.expanduser("~/traceav_videos")
MAP = json.load(open("data/video_name_mapping.json"))

def resolve(video_id: str) -> str:
    return os.path.join(VIDEOS_DIR, f"{video_id}.mp4")
```

## Quick Start

### Evaluate a model

Every model evaluator lives in `eval/<model>/` with a matching `.sh` launcher.

```bash
# Example: evaluate Gemini model.
export BENCHMARK_DIR=$(pwd)/data
export GEMINI_API_KEY=<your_key>
bash eval/gemini/eval_gemini.sh

# Example: evaluate a local Qwen3-VL checkpoint.
export QWEN3VL_MODEL_PATH=/path/to/Qwen3-VL-32B-Instruct
export QWEN3VL_CLEANED_DIR=$(pwd)/data
export QWEN3VL_VIDEOS_DIR=/path/to/videos
bash eval/qwen3_vl/eval_qwen3_vl.sh

# Example: evaluate a vLLM-hosted omni model.
# First start your own vLLM server, then:
export BENCHMARK_DIR=$(pwd)/data
export LVBENCH_BASE_URL=http://127.0.0.1:8000
bash eval/qwen3_omni_instruct/eval_qwen3_omni_instruct.sh
```

See [`eval/README.md`](eval/README.md) for the full list of evaluators and
their environment variables.

### Reproduce the benchmark construction

| Stage | Folder |
|-------|--------|
| 1. Visual captioning     | `src/step1_visual_captioning/` |
| 2. Audio-visual fusion   | `src/step2_audio_visual_fusion/` |
| 3. Agentic QA generation | `src/step3_agentic_question_generation/` |
| 4. Quality assurance     | `src/step4_quality_assurance/` |

All stages read their paths and API credentials from environment variables;
see each script's header for the exact variable names.

## Directory Reference

| Path | Description |
|------|-------------|
| `data/`                                           | Per-task benchmark JSON files + `video_name_mapping.json`. |
| `src/step1_visual_captioning/`                    | Minute-level visual captioning with entity tracking. |
| `src/step2_audio_visual_fusion/`                  | Audio-visual caption fusion. |
| `src/step3_agentic_question_generation/`          | Agentic pipeline: event segmentation, trajectory proposal, MCQ generation. |
| `src/step4_quality_assurance/`                    | LLM-based verification and filtering. |
| `intermediate/step1_visual_captioning/`           | Per-minute visual caption files. |
| `intermediate/step2_audio_visual_fusion/`         | Per-minute audio-visual fused captions. |
| `intermediate/step3_agentic_question_generation/` | Per-video event blocks and candidate QAs. |
| `intermediate/step4_quality_assurance/`           | Per-task benchmark JSON files before final deduplication. |
| `eval/`                                           | One subfolder per evaluator, each with `eval_<model>.py` + `eval_<model>.sh`. |