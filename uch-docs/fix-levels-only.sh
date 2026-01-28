#!/bin/bash
echo "🔧 ИСПРАВЛЕНИЕ УРОВНЕЙ В FRONTMATTER"
echo "===================================="
echo ""
echo "Уровень берется из ПЕРВОГО СИМВОЛА ID:"
echo "  • 1-010000-6 → уровень 1"
echo "  • Z-20260112... → уровень 0 (неиерархический)"
echo ""

fixed_count=0
processed_count=0

# Обрабатываем UCH документы (включая Z-)
find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  processed_count=$((processed_count + 1))
  
  # Извлекаем ID из имени файла
  file_id=$(echo "$filename" | grep -oE '^([0-9]+-[0-9]+-[0-9]+|Z-[0-9]+)' | head -1)
  
  if [ -n "$file_id" ]; then
    # Определяем уровень
    if [[ "$file_id" == Z-* ]]; then
      correct_level=0  # Неиерархический уровень
    else
      correct_level=$(echo "$file_id" | cut -d'-' -f1)
    fi
    
    # Получаем текущий уровень из frontmatter
    current_level=$(grep -m1 "level:" "$f" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' "')
    
    if [ "$current_level" != "$correct_level" ]; then
      echo "📄 Исправляю: $filename"
      echo "   ID: $file_id"
      echo "   Текущий уровень: $current_level"
      echo "   Правильный уровень: $correct_level"
      
      # Создаем временный файл
      temp_file="${f}.tmp"
      
      # Заменяем уровень в frontmatter
      sed "s/level:.*$/level: $correct_level/" "$f" > "$temp_file"
      
      if grep -q "level: $correct_level" "$temp_file"; then
        mv "$temp_file" "$f"
        fixed_count=$((fixed_count + 1))
        echo "   ✅ Исправлено"
      else
        rm "$temp_file"
        echo "   ❌ Ошибка замены"
      fi
      echo ""
    fi
  fi
done

echo "========================================"
echo "📊 ИТОГ:"
echo "   Обработано файлов: $processed_count"
echo "   Исправлено уровней: $fixed_count"
