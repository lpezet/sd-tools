# sd-tools

Repo with tools to help working with Stable Diffusion.

First tool is `civitai-downloader.sh`, a bash script to help download CivitAI models (Lora, Embeddings, Models, etc.).
It can automatically organize content when used for Stable Diffusion.
For example:

```
# Download DreamShaper model and put it automatically in models/Stable-diffusion folder
civitai-downloader https://civitai.com/api/download/models/128713
# Download using only model version id
civitai-downloader 128713
# Download to specific folder
civitai-downloader 128713 /tmp/
# Download models listed in file models.txt
civitai-downloader models.txt
```

# Prerequisites

This script requires `jq` to be installed.
It uses `jq` to parse JSON responses from CivitAI API.

# Usage

```bash
git clone https://github.com/lpezet/sd-tools.git
cd sd-tools
./civitai-downloader.sh model_version [output folder]
```

You can use the config to automatically store the output to a specific folder.
Each model type from CivitAI API will be assigned a directory.
The following model types are supported rigth now:
- Checkpoint
- LORA
- TextualInversion

Running the following to download the amazing "Zaha Hadid architecture" LORA (model version 37555)
```
./civitai-downloader.sh 37555
```
would download the LORA file and place it in `/workspace/stable-diffusion-webui/models/Lora` folder.


## Within RunPod

The following `.config` file is useful when running in `runpod.io`:
```
CONFIG_MODE=1
# Config for SD on RunPod
DIR_PREFIX=/workspace
OUTPUT_BASE_DIR=${DIR_PREFIX}/stable-diffusion-webui
OUTPUT_DIR_BASE_MODELS=${OUTPUT_BASE_DIR}/models
OUTPUT_DIR_LORA=${OUTPUT_DIR_BASE_MODELS}/Lora
OUTPUT_DIR_MODEL=${OUTPUT_DIR_BASE_MODELS}/Stable-diffusion
OUTPUT_DIR_EMBEDDINGS=${OUTPUT_BASE_DIR}/embeddings
#OUTPUT_DIR_ESRGAN=${OUTPUT_DIR_BASE_MODELS}/ESRGAN
```

This is exactly what `.config.sample.runpod.sd` has so we'll just use it was is.

Once you're Pod is running, connect using Web Terminal.
Then do:

```bash
git clone https://github.com/lpezet/sd-tools.git
cd sd-tools
ln -s `pwd`/civitai-downloader.sh /usr/local/bin/civitai-downloader
cp .config.sample.runpod.sd .config
```

Now, from anywhere you can call `civit-downloader` and pass it a `model version` and it will download and place the model to its right place.
If you need to download a model to a specific directoy, you can always add it at the end of the command like so:
```bash
civit-downloader 37555 /tmp/
```


