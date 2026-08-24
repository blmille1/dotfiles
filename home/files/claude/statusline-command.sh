#!/bin/sh
input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // empty')
tokens=$(echo "$input" | jq -r '.context_window.total_input_tokens // 0')

[ -n "$model" ] && printf '\033[2m%s\033[0m' "$model"

if [ "$tokens" -gt 140000 ]; then
  printf '\033[1;31m in dumb zone (%dk tokens)\033[0m' "$((tokens / 1000))"
elif [ "$tokens" -gt 110000 ]; then
  printf '\033[1;33m %dk tokens\033[0m' "$((tokens / 1000))"
fi
