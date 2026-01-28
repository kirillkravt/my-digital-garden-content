#!/bin/bash
echo "🔧 ИСПРАВЛЕНИЕ ИМЕН ИЗ SLUG ФАЙЛОВ"
echo "=================================="
echo ""
echo "Берем часть имени файла после ID_TYPE_ и используем как имя"
echo "Пример: 2-010400-7_ARCH_Documentation-first_подход.md → Documentation-first подход"
echo ""

fixed_count=0
processed_count=0

# Обрабатываем все UCH документы
find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  processed_count=$((processed_count + 1))
  
  # Извлекаем ID и TYPE из имени файла
  if [[ "$filename" =~ ^([0-9]+-[0-9]+-[0-9]+)_([A-Z]+)_(.*)\.md$ ]]; then
    file_id="${BASH_REMATCH[1]}"
    file_type="${BASH_REMATCH[2]}"
    file_slug="${BASH_REMATCH[3]}"
    
    # Преобразуем slug в читаемое имя
    # 1. Заменяем подчеркивания на пробелы
    # 2. Заменяем дефисы с пробелами вокруг
    # 3. Убираем лишние пробелы
    readable_name=$(echo "$file_slug" | \
      sed 's/_/ /g' | \
      sed 's/  / /g' | \
      sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | \
      sed 's/\([a-z]\)\([A-Z]\)/\1 \2/g' | \
      sed 's/-/ - /g' | \
      sed 's/^./\u&/'
    )
    
    # Для SNAP документов с датами: оставляем только дату
    if [ "$file_type" = "SNAP" ] && [[ "$readable_name" =~ ([0-9]{8})$ ]]; then
      readable_name="${BASH_REMATCH[1]}"
    fi
    
    # Получаем текущее имя для сравнения
    current_name=$(grep -m1 "^name:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
    
    # Если имя отличается, обновляем
    if [ "$readable_name" != "$current_name" ] && [ -n "$readable_name" ]; then
      echo "📝 $filename"
      echo "   Slug: $file_slug"
      echo "   Было: '$current_name'"
      echo "   Стало: '$readable_name'"
      
      # Обновляем имя в файле (macOS совместимый sed)
      sed -i '' "s/^name:.*$/name: \"$readable_name\"/" "$f"
      
      fixed_count=$((fixed_count + 1))
      echo ""
    fi
  fi
done

echo "========================================"
echo "📊 ИТОГ:"
echo "   Обработано файлов: $processed_count"
echo "   Исправлено имен: $fixed_count"
echo ""
echo "🔍 ПРИМЕРЫ ИСПРАВЛЕНИЙ:"
echo "---------------------"

# Проверяем примеры
example_files=(
  "2-010400-7_ARCH_Documentation-first_подход.md"
  "6-010400-004-1_SNAP_20251227.md"
  "6-010200-001-1_SNAP_20251221.md"
  "4-010400-0200-1_TASK_Архитектурная_вилка_UCH-Docs.md"
  "1-010000-6_BRAND_brandbook.md"
)

for example in "${example_files[@]}"; do
  if [ -f "$example" ]; then
    if [[ "$example" =~ ^([0-9]+-[0-9]+-[0-9]+)_([A-Z]+)_(.*)\.md$ ]]; then
      slug="${BASH_REMATCH[3]}"
      current_name=$(grep -m1 "^name:" "$example" | cut -d: -f2- | sed 's/^ *//; s/ *$//')
      echo "📄 $example"
      echo "   Slug: $slug"
      echo "   Name: $current_name"
      echo ""
    fi
  fi
done
