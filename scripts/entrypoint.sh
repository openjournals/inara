#!/bin/sh
set -e

# Get target formats. Default is to generate both JATS and PDF.
usage()
{
    printf "Usage: %s [-m ARTICLE_INFO_FILE] [-o OUTPUT_FORMATS] INPUT_FILE\n" \
           "$0"
}

args=$(getopt ':o:m:v' "$@")
if [ $? -ne 0 ]; then
    usage && exit 1
fi
set -- $args

outformats=jats,pdf
article_info_file=
verbose=0

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
        (-v)
            verbose=$(($verbose + 1));
            shift 1
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
    # turn into a defaults file if it isn't one.
    if head -n1 "$article_info_file" | grep -q '^metadata:'; then
        article_info_option="--defaults=${article_info_file}"
    else
        tmpmeta="$(mktemp)"
        pandoc --from=markdown-citations \
               --metadata-file="${article_info_file}" \
               --to=markdown-citations \
               --lua-filter=$OPENJOURNALS_PATH/clean-metadata.lua \
               --output="${tmpmeta}" \
               --standalone \
               /dev/null
        sed -i'' -e '/^---$/d' "$tmpmeta"
        article_info_option="--defaults=${tmpmeta}"
        article_info_file="${tmpmeta}"
    fi
fi


printf 'Verbosity: %s\n' "$verbose"
if [ "$verbose" -ge 1 ]; then
    printf 'input_path           : %s\n' "${input_path}"
    printf 'input_file           : %s\n' "${input_file}"
    printf 'input_dir            : %s\n' "${input_dir}"
    printf 'outformats           : %s\n' "${outformats}"
    printf 'article_info_file    : %s\n' "${article_info_file}"
    printf 'article_info_option  : %s\n' "${article_info_option}"
fi
if [ "$verbose" -ge 2 ]; then
    printf "\nContent of metadata defaults file:\n"
    cat "${article_info_file}"
fi

# All paths in the document are expected to be relative to the paper
# file.
cd "${input_dir}"

for format in $(printf "%s" "$outformats" | sed -e 's/,/ /g'); do
    [ "$verbose" -gt 0 ] && printf "Starting conversion to %s...\n" "$format"
    /usr/local/bin/pandoc \
	      --data-dir="$OPENJOURNALS_PATH"/data \
        --defaults=shared \
        --defaults="${format}" \
        --defaults="$OPENJOURNALS_PATH"/"${JOURNAL}"/defaults.yaml \
        ${article_info_option} \
	      --resource-path=.:${input_dir}:${OPENJOURNALS_PATH} \
	      --metadata-file=${OPENJOURNALS_PATH}/${JOURNAL}/journal-metadata.yaml \
	      --variable="${JOURNAL}" \
        --output="paper.${format}" \
        "$input_file" \
        "$@" || exit 1
    [ "$verbose" -gt 0 ] && printf "DONE conversion to %s\n" "$format"
done
