#!/bin/bash

# 查找所有 .md 檔案，排除無關目錄
find . -type d \( -name node_modules -o -name .git -o -name .turbo -o -name dist -o -name build \) -prune -o -type f -name "*.md" -print | sort
