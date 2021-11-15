#!/bin/sh
# Get target formats. Default is to generate both JATS and PDF.
outformats=jats,pdf

usage()
{
    printf "Usage: $0 [-o OUTPUT_FORMATS] <INPUT_FILE>"
}

# args=$(getopt ':')
set -- $(getopt ':o:' "$@")
if [ $? -ne 0 ]; then
    usage && exit 1
fi
while true; do
    case "$1" in
        (-o) outformats="${2}"; shift 2;;
        (--) shift; break;;
        (*) usage; exit 1;;
    esac
done
# shift $((OPTIND - 1))

# The first argument must always be the path to the main paper
# file. The working directory is switched to the folder that the
# paper file is in.
input_file="$(basename "$1")"
input_dir="$(dirname "$1")"

# The second argument is optional, it may be the path to the article
# info (metadata) file.
if [ -z "$2" ]; then
    article_info_file=/dev/null
else
    # we switch the directory later, so get the absolute path.
    article_info_file="$(realpath $2)"
fi

# All paths in the document are expected to be relative to the paper
# file.
cd "${input_dir}"

for format in $(printf "%s" "$outformats" | sed -e 's/,/ /g'); do
    /usr/local/bin/pandoc \
	      --data-dir="$OPENJOURNALS_PATH"/data \
        --defaults=shared \
        --defaults="${format}" \
        --defaults="$OPENJOURNALS_PATH"/"${JOURNAL}"/defaults.yaml \
	      --resource-path=.:${OPENJOURNALS_PATH} \
	      --metadata-file=${OPENJOURNALS_PATH}/${JOURNAL}/journal-metadata.yaml \
	      --variable="${JOURNAL}" \
        --output="paper.${format}" \
        "$@" || exit 1
done
