#!/bin/bash
echo "🔍 ПРОВЕРКА ЕДИНООБРАЗИЯ FRONTMATTER"
echo "==================================="
echo ""
echo "Проверяемые обязательные поля:"
echo "1. id - ДА"
echo "2. name - ДА"
echo "3. type - ДА"
echo "4. level - ДА"
echo "5. status - ДА"
echo "6. tags - ДА (массив)"
echo "7. created - ДА"
echo "8. updated - ДА"
echo "9. author - ДА"
echo "10. slug - ОПЦИОНАЛЬНО"
echo ""

# Проверяем несколько файлов
echo "📋 ПРИМЕРЫ FRONTMATTER:"
echo "---------------------"

sample_files=(
  "3-010001-1_COMP_Отчеты_и_аналитика_UCH.md"
  "1-010000-6_BRAND_brandbook.md"
  "2-010400-7_ARCH_Documentation-first_подход.md"
  "Z-20260104214521-1_IDEA_Требования к системе автоматической документации.md"
)

for sample in "${sample_files[@]}"; do
  if [ -f "$sample" ]; then
    echo "📄 $sample:"
    echo "---"
    grep -A10 "id:" "$sample" | head -12
    echo "---"
    echo ""
  fi
done

# Считаем поля
echo "📊 СТАТИСТИКА ПОЛЕЙ (первые 10 файлов):"
echo "-------------------------------------"
count=0
find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | head -10 | while read f && [ $count -lt 10 ]; do
  
  echo "Файл: $(basename "$f")"
  
  # Проверяем наличие обязательных полей
  fields=("id" "name" "type" "level" "status" "tags" "created" "updated" "author")
  for field in "${fields[@]}"; do
    if grep -q "^$field:" "$f"; then
      echo "  ✅ $field"
    else
      echo "  ❌ $field - ОТСУТСТВУЕТ"
    fi
  done
  
  # Проверяем slug
  if grep -q "^slug:" "$f"; then
    echo "  ✅ slug"
  else
    echo "  ⚠️  slug - отсутствует"
  fi
  
  echo ""
  count=$((count + 1))
done
