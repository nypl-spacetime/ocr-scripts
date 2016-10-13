#!/bin/bash -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
OUTPUT_DIR=$(dirname $1)

NUM_CORES=$(getconf _NPROCESSORS_ONLN)
USE_CORES=$(($NUM_CORES - 1))

mkdir -p $OUTPUT_DIR/temp

# Binarization
ocropus-nlbin -n -t 0.65 -Q $USE_CORES -o "$OUTPUT_DIR/temp" $@

# Page segmentation
ocropus-gpageseg -n --maxlines 1200 --maxseps 2 -b -Q $USE_CORES -d "$OUTPUT_DIR/temp/????.bin.png"

# OCR
ocropus-rpred -Q $USE_CORES -n -m "$SCRIPT_DIR/models/cd_training_gold_master_117000.pyrnn.gz" "$OUTPUT_DIR/temp/????/??????.bin.png"

# Create hOCR file
ocropus-hocr "$OUTPUT_DIR/temp/????.bin.png" -o "$OUTPUT_DIR/hocr.html"

# rm -rf $OUTPUT_DIR/temp
