#!/bin/bash

# Check for one argument
if [ $# -ne 1 ]; then
    echo "Usage: $0 customname"
    exit 1
fi

customname="$1"

# Find the highest existing number for this customname
lastnum=0
for f in "${customname}"_*.*; do
    [ -f "$f" ] || continue
    num=$(echo "$f" | awk -F'[_.]' '{print $(NF-1)}')
    if [[ "$num" =~ ^[0-9]+$ ]]; then
        (( num > lastnum )) && lastnum=$num
    fi
done

# Start counting from lastnum+1
counter=$((lastnum + 1))

# Process only post_*_*_*.* files
for file in *_*_*.jpg; do
    [ -f "$file" ] || continue

    ext="${file##*.}"
    newname="${customname}_${counter}.${ext}"

    mv -- "$file" "$newname"
    ((counter++))
done

