#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR=$(dirname $1)

NUM_CORES=$(getconf _NPROCESSORS_ONLN)
USE_CORES=$(($NUM_CORES - 1))

for f in $@
do
  b=${f##*/}
  b=${b%.*}
  echo "Processing $b:"

  dir=$OUTPUT_DIR/ocr/$b

  mkdir -p $dir

  # Binarization
  ocropus-nlbin -n -t 0.65 -Q $USE_CORES -o "$dir" $f

  # Page segmentation
  ocropus-gpageseg -n --maxlines 1200 --maxseps 2 -b -Q 1 -d "$dir/????.bin.png"

  # OCR
  ocropus-rpred -Q $USE_CORES -n -m "$SCRIPT_DIR/models/cd_training_gold_master_117000.pyrnn.gz" "$dir/????/??????.bin.png" || true

  # Create hOCR file
  ocropus-hocr "$dir/????.bin.png" -o "$dir/hocr.html" || true
done
