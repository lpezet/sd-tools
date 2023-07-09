#!/bin/bash
modelVersionOrFilename=$1
outputFolder=$2
DRYRUN=${DRYRUN:-0}
DEBUG=${DEBUG:-0}

prerequisites() {
  local TEST=`(which jq > /dev/null) && echo "Present" || echo "Missing"`
  if [ "$TEST" == "Missing" ]; then
    echo "Program 'jq' missing. Please install it first (like 'apt install jq')."
    exit 1
  fi
}
prerequisites

help() {
  echo -e "Usage:\n"
  echo -e "$0 [model_version | filename] [output_folder]\n"
  echo -e "with\n"
  echo -e " model_version\t# The version of the model you want to download.\n"
  echo -e " filename\t# Path to a file containing model version ids on each line. Lines starting with # will be ignored.\n"
  echo -e " output_folder\t# If provided, download model into that folder.\n"
  echo -e "\n\nIf .config file provided, folder configuration will be loaded from it."
  exit 1
}

if [ -z "$modelVersionOrFilename" ]; then
  help
fi

resolve_script_dir() {
  local SOURCE=${BASH_SOURCE[0]}
  local DIR=""
  while [ -L "$SOURCE" ]; do # resolve $SOURCE until the file is no longer a symlink
    DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
    SOURCE=$(readlink "$SOURCE")
    [[ $SOURCE != /* ]] && SOURCE=$DIR/$SOURCE # if $SOURCE was a relative symlink, we need to resolve it relative to the path where the symlink file was located
  done
  SCRIPT_DIR=$( cd -P "$( dirname "$SOURCE" )" >/dev/null 2>&1 && pwd )
}

resolve_script_dir
if [ -f ${SCRIPT_DIR}/.config ]; then
  . ${SCRIPT_DIR}/.config
fi

if [ -z "$outputFolder" -a -z "$CONFIG_MODE" ]; then
  echo -e "Must provider either output_folder parameter or use .config file."
  help
fi


describe_model() {
  local ver=$1
  [[ $DEBUG -ne 0 ]] && echo "# Getting model info for model version ${ver}..."
  curl -s -o /tmp/civitai_res.json "https://civitai.com/api/v1/model-versions/${ver}"
  if [ $? -eq 1 ]; then
    echo "Error while getting model informaton from CivitAI API. Exiting."
    exit 1
  fi
  MODEL_ID=$(jq -r '.modelId' /tmp/civitai_res.json)
  MODEL_TYPE=$(jq -r '.model.type' /tmp/civitai_res.json)
  MODEL_NAME=$(jq -r '.model.name' /tmp/civitai_res.json)
  BASE_MODEL=$(jq -r '.baseModel' /tmp/civitai_res.json)
  NAME=$(jq -r '.name' /tmp/civitai_res.json)
  DOWNLOAD_URL="https://civitai.com/api/download/models/${ver}"
}


download() {
  local modelVersion=$1
  local outputFolder=$2

  describe_model $modelVersion
  if [ -z "$outputFolder" ]; then
    # Checkpoint, TextualInversion, Hypernetwork, AestheticGradient, LORA, Controlnet, Poses)
    case ${MODEL_TYPE} in
      Checkpoint)
        outputFolder=${OUTPUT_DIR_MODEL}
        ;;
      TextualInversion)
        outputFolder=${OUTPUT_DIR_EMBEDDINGS}
        ;;
      Hypernetwork | AestheticGradient | Controlnet | Poses)
        echo "${MODEL_TYPE} models not yet supported."
        exit 1
        ;;
      LORA)
        outputFolder=${OUTPUT_DIR_LORA}
        ;;
      *)
        echo "${MODEL_TYPE} models not yet supported (2)."
        exit1
    esac
  fi

  if [ ! -z "$outputFolder" -a ! -d "$outputFolder" ]; then
    mkdir -p "$outputFolder"
  fi

  if [ -z "$outputFolder" ]; then
    echo "WARNING: Missing output folder. Will download to current directory."
    outputFolder="./"
  fi

  if [ $DRYRUN -eq 0 ]; then
    echo "# Downloading model version [${modelVersion}] (${MODEL_TYPE})..."
    echo "$modelVersion" >> /tmp/sd-tools.civitai-downloader.replay
    echo wget -P "${outputFolder}" "${DOWNLOAD_URL}" --content-disposition
  else
    echo "# In DRY RUN mode. Not downloading model version [${modelVersion}] (${MODEL_TYPE})."
  fi
}


if [ -f "$modelVersionOrFilename" ]; then
  echo "Reading model versions from file [$modelVersionOrFilename]..."
  while IFS= read -r line
  do
      # display $line or do somthing with $line
      [[ $DEBUG -ne 0 ]] && printf 'line=[%s]\n' "$line"
      if [[ $line =~ ^#.* || -z "$line" ]]; then
        [[ $DEBUG -ne 0 ]] && echo "Skipping line."
        continue
      fi
      download "$line" "$outputFolder"
  done <"$modelVersionOrFilename"
else
  download "$modelVersionOrFilename" "$outputFolder"
fi