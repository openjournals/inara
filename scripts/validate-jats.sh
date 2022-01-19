#!/bin/sh
validator_url="https://jats-validator.hubmed.org/dtd/"

usage ()
{
    printf "Usage: %s FILENAME\n" "$0"
    printf "Validate a JATS XML file using the online validator tool at\n"
    printf "%s.\n" "$validator_url"
    exit 1
}

filename=$1
[ -f "$filename" ] || usage

printf "Validating file %s\n" "$filename"
json="$(curl --form "xml=@${filename}" --silent "$validator_url")"
err_count="$(printf '%s' "$json" | jq '.errors | length')"

if [ "$err_count" -eq 0 ]; then
    printf "File was validated successfully.\n"
    exit 0
else
    printf "Validator report:\n%s" "$json" >&2
    exit 1
fi
