#!/bin/bash

# Get all .md files, excluding existing _zh_TW.md files
files=$(find . -name "*.md" | grep -v "_zh_TW.md" | grep -v "node_modules")

echo "Translation Status Report"
echo "========================="

total=0
translated=0
missing=0

for file in $files; do
    ((total++))
    dir=$(dirname "$file")
    base=$(basename "$file" .md)
    zh_file="${dir}/${base}_zh_TW.md"
    
    if [ -f "$zh_file" ]; then
        ((translated++))
    else
        ((missing++))
        echo "[MISSING] $file"
    fi
done

echo "========================="
echo "Total .md files (source): $total"
echo "Translated: $translated"
echo "Missing: $missing"
echo "Completion: $(echo "scale=2; $translated * 100 / $total" | bc)%"
