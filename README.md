# civitai-downloader

Bash script to help download CivitAI models (Lora, Embeddings, Models, etc.).
It can automatically organize content when used for Stable Diffusion.

# Prerequisites

This script requires `jq` to be installed.
It uses `jq` to parse JSON responses from CivitAI API.

# Usage

```bash
civitai-downloader.sh model_version [output folder]
```

