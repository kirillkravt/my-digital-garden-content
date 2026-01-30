#!/bin/bash
# ================================
# ПРОВЕРКА: check-frontmatter.sh
# ================================
#
# 🎯 ЦЕЛЬ: Проверить состояние frontmatter
# 📋 ИНСТРУКЦИЯ:
# 1. Скопировать весь блок
# 2. pbpaste > check.sh
# 3. chmod +x check.sh  
# 4. ./check.sh
#
# ================================

echo "🔍 ПРОВЕРКА FRONTMATTER ПОСЛЕ МИГРАЦИИ"
echo "====================================="

echo ""
echo "📊 1. СТАТИСТИКА ДОКУМЕНТОВ:"
find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | wc -l | xargs echo "Всего UCH документов:"

echo ""
echo "✅ 2. ПРОВЕРКА КЛЮЧЕВЫХ ФАЙЛОВ:"
check_files=(
  "1-010000-1_PROJ_universal_creative_hub.md"
  "2-010400-7_ARCH_Documentation-first_подход.md"
  "3-010402-1_COMP_Система_нумерации_документов_UCH.md"
  "6-010402-001-1_REPORT_20260128.md"
)

for file in "${check_files[@]}"; do
  if [ -f "$file" ]; then
    echo -n "📄 $file: "
    if grep -q "^---$" "$file"; then
      echo "✅ фронтматтер есть"
    else
      echo "❌ фронтматтер отсутствует"
    fi
  fi
done

echo ""
echo "🎉 ПРОВЕРКА ЗАВЕРШЕНА!"