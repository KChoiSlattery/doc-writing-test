#!/bin/sh
set -e

TEMPLATE="eisvogel.latex"

if [ -z "$1" ]; then
  echo "Usage: build.sh src/<file>.md"
  exit 1
fi

BASENAME=$(basename $1 .md)

INPUT="./src/${BASENAME}.md"
OUTPUT="./build/${BASENAME}.pdf"

pandoc  "$INPUT" -o "$OUTPUT" \
  --template=./src/templates/template.latex \
  --from markdown+latex_macros \
  --pdf-engine=pdflatex

# pandoc  "$INPUT" -o "$OUTPUT" \
#   --from markdown+latex_macros \
#   --template=./src/templates/template.typ \
#   --pdf-engine=typst \

echo "Generated $OUTPUT."