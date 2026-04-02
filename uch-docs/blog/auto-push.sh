#!/bin/bash
cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs/blog

# Проверяем, есть ли изменения
if git status --porcelain | grep -q .; then
    git add .
    git commit -m "Auto sync $(date '+%Y-%m-%d %H:%M:%S')"
    git push
    echo "✅ Pushed to GitHub"
else
    echo "ℹ️ No changes to commit"
fi
