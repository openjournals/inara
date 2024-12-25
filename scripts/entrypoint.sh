#!/bin/sh
# Get target formats. Default is to generate both JATS and PDF.
usage()
{
    printf "Usage: %s [OPTIONS] INPUT_FILE\n" "$0"
    printf 'Options:\n'
    printf '\t-l: create log files for all formats\n'
    printf '\t-m: article info file; YAML file contains article metadata\n'
    printf '\t-o: comma-separated list of output format; defaults to jats,pdf\n'
    printf '\t-p: flag to force the production of a publishing PDF\n'
    printf '\t-r: flag to produce a retraction-notice publishing PDF\n'
    printf '\t-v: increase verbosity; can be given multiple times\n'
}

args=$(getopt 'lo:m:prv' "$@")
if [ $? -ne 0 ]; then
    usage && exit 1
fi
set -- $args
set -e

outformats=jats,pdf
draft=true
retraction=
log=
article_info_file=
verbosity=0

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
        (-l)
            log=true
            shift 1
            ;;
        (-p)
            draft=
            shift 1
            ;;
        (-r)
            retraction=true
            shift 1
            ;;
        (-v)
            verbosity=$(($verbosity + 1));
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
    article_info_option="--metadata=article-info-file=${article_info_file}"
fi


if [ "$verbosity" -ge 1 ]; then
    printf 'verbosity            : %s\n' "$verbosity"
    printf 'input_path           : %s\n' "${input_path}"
    printf 'input_file           : %s\n' "${input_file}"
    printf 'input_dir            : %s\n' "${input_dir}"
    printf 'outformats           : %s\n' "${outformats}"
    printf 'article_info_file    : %s\n' "${article_info_file}"
    printf 'article_info_option  : %s\n' "${article_info_option}"
fi
if [ "$verbosity" -ge 2 ]; then
    if [ -n "${article_info_file}" ] && [ -f "${article_info_file}" ]; then
        printf "\nContent of metadata defaults file:\n"
        cat "${article_info_file}"
    else
        printf "No valid metadata defaults file specified.\n"
    fi
fi

# All paths in the document are expected to be relative to the paper
# file.
cd "${input_dir}"

for format in $(printf "%s" "$outformats" | sed -e 's/,/ /g'); do
    if [ "$verbosity" -gt 0 ]; then
         printf "Starting conversion to %s...\n" "$format"
    fi
    if [ -z "$log" ]; then
        logfile=/dev/null
    else
        logfile=paper.${format}.log
    fi
    extra_args=
    if [ "$format" = "jats" ]; then
        [ "$verbosity" -gt 0 ] && printf 'Creating folder "paper.jats"\n'
        mkdir -p "jats"
    fi

    # Notes:
    # 1. the output file must be defined in the format's defaults file.
    # 2. these assume a different organizational structure than in the
    #    inara git repo that is created in Docker, in which the contents of
    #    the resources/ directory is copied into the root directory
    # 3. assumes pandoc is in a certain location. Switch `/usr/local/bin/pandoc`
    #    to just `pandoc` locally, or symlink with
    #    sudo ln -s $which(pandoc) /usr/local/bin/pandoc
    /usr/local/bin/pandoc \
	      --data-dir="$OPENJOURNALS_PATH"/data \
        --defaults=shared \
        --defaults="${format}" \
        --defaults="$OPENJOURNALS_PATH"/"${JOURNAL}"/defaults.yaml \
        ${article_info_option} \
	      --resource-path=.:${input_dir}:${OPENJOURNALS_PATH} \
	      --variable="${JOURNAL}" \
        --variable=retraction:"$retraction" \
        --variable=draft:"$draft" \
        --metadata=draft:"$draft" \
        --log="$logfile" \
        "$input_file" \
        "$@" || exit 1
    if [ "$verbosity" -gt 0 ]; then
        printf "DONE conversion to %s\n" "$format"
    fi
done
