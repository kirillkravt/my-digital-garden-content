#!/bin/bash
echo "🔧 ИСПРАВЛЕНИЕ FRONTMATTER ДЛЯ UCH ДОКУМЕНТОВ"
echo "============================================"
echo ""
echo "Обрабатываем только UCH документы (префиксы 0-9, Z-)"
echo "Исключаем backup и архивные директории"
echo ""

fixed_count=0
total_processed=0

# Находим только UCH документы
find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  total_processed=$((total_processed + 1))
  
  # Извлекаем ID из имени файла (формат: X-XXXXXX-X)
  file_id=$(echo "$filename" | grep -oE '^[0-9Z]+-[0-9A-Z]+-[0-9A-Z]+' | head -1)
  
  if [ -n "$file_id" ]; then
    # Проверяем frontmatter
    if grep -q "id:" "$f"; then
      frontmatter_id=$(grep -m1 "id:" "$f" | head -1 | cut -d: -f2 | tr -d ' "')
      
      # Если ID не совпадают
      if [ "$file_id" != "$frontmatter_id" ]; then
        echo "🔄 Исправляю: $filename"
        echo "   Старый ID: $frontmatter_id"
        echo "   Новый ID: $file_id"
        
        # Создаем временный файл
        temp_file="${f}.tmp"
        
        # Заменяем ID в frontmatter
        sed "s/id:.*$/id: \"$file_id\"/" "$f" > "$temp_file"
        
        # Проверяем что замена произошла
        if grep -q "id: \"$file_id\"" "$temp_file"; then
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
  fi
done

echo "========================================"
echo "📊 ИТОГ:"
echo "   Обработано документов: $total_processed"
echo "   Исправлено frontmatter: $fixed_count"
echo ""
echo "⚠️  СЛЕДУЮЩИЙ ШАГ:"
echo "   Проверить исправления через: ./check-id-mismatch.sh"
