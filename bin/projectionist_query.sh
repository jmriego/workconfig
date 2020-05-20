#!/usr/bin/env bash

file="$1"
key="$2"
index="${3:-[0][0]}"

function generate_query_vimscript {

cat << EOF
let g:query_result=projectionist#query_raw("$key", "$file")$index
let g:result_string = type(g:query_result)==1 ? g:query_result : string(g:query_result)
call writefile([g:result_string], "$TMPFILE")
quit!
EOF

}

trap 'rm -f "$TMPFILE"' EXIT
TMPFILE=$(mktemp) || exit 1
vim -n -E -S <(generate_query_vimscript) "$file" >/dev/null 2>&1
cat "$TMPFILE"
