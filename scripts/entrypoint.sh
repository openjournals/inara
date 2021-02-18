#!/bin/sh
# The first argument must always be the path to the main paper
# file. The working directory is switched to the folder that the
# paper file is in.
input=$1
shift

input_file="$(basename $input)"
cd "$(dirname $input)"

/usr/local/bin/pandoc \
    --defaults="$OPENJOURNALS_PATH"/data/shared.yaml \
    --defaults="$OPENJOURNALS_PATH"/data/pdf.yaml \
    --defaults="$OPENJOURNALS_PATH"/"$JOURNAL"/defaults.yaml \
	  --data-dir="$OPENJOURNALS_PATH"/data \
    "$input_file" \
    "$@"
