#!/bin/sh
# Get target formats. Default is to generate both JATS and PDF.
usage()
{
    printf "Usage: %s [-m ARTICLE_INFO_FILE] [-o OUTPUT_FORMATS] INPUT_FILE" \
           "$0"
}

# args=$(getopt ':')
set -- $(getopt ':o:m:' "$@")
if [ $? -ne 0 ]; then
    usage && exit 1
fi

outformats=jats,pdf
article_info_file=

while true; do
    case "$1" in
        (-o)
            outformats="${2}";
            shift 2
            ;;
        (-m)
            # we switch the directory later, so get the absolute path.
            article_info_file="$(realpath "$2")";
            shift 2
            ;;
        (--) shift; break;;
        (*) usage; exit 1;;
    esac
done

# The first argument must always be the path to the main paper
# file. The working directory is switched to the folder that the
# paper file is in.
input_path="$(realpath "$1")"
input_file="$(basename "$input_path")"
input_dir="$(dirname "$input_path")"
shift 1

# Option passed to pandoc so the article metadata is included (if given).
if [ ! -z "$article_info_file" ]; then
    article_info_option="--defaults=${article_info_file}"
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
        --defaults="$OPENJOURNALS_PATH"/"${JOURNAL}"/defaults.yaml \
        $article_info_option \
	      --resource-path=.:${input_dir}:${OPENJOURNALS_PATH} \
	      --metadata-file=${OPENJOURNALS_PATH}/${JOURNAL}/journal-metadata.yaml \
	      --variable="${JOURNAL}" \
        --output="paper.${format}" \
        "$input_file" \
        "$@" || exit 1
done
