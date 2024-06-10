#!/bin/sh
echo -ne '\033c\033]0;BoomBatting\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/BoomBatting.x86_64" "$@"
