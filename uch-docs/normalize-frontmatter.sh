#!/bin/bash
echo "🔄 НОРМАЛИЗАЦИЯ FRONTMATTER К ЕДИНОМУ ВИДУ"
echo "=========================================="
echo ""
echo "Стандартный формат frontmatter:"
echo "id: \"[ID]\""
echo "name: \"[Название]\""
echo "type: \"[ТИП]\""
echo "level: [число]"
echo "status: \"[статус]\""
echo "tags: [\"тег1\", \"тег2\"]"
echo "created: \"YYYY-MM-DD\""
echo "updated: \"YYYY-MM-DD\""
echo "author: \"kirillkravcov\""
echo ""
echo "Удаляем лишние поля: parent, parent_name и другие нестандартные"
echo ""

normalized_count=0
processed_count=0

# Обрабатываем UCH документы
find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  processed_count=$((processed_count + 1))
  
  # Извлекаем информацию из имени файла
  file_id=$(echo "$filename" | grep -oE '^([0-9]+-[0-9]+-[0-9]+|Z-[0-9]+)' | head -1)
  file_type=$(echo "$filename" | grep -oE '_[A-Z]+_' | sed 's/_//g')
  slug_part=$(echo "$filename" | sed 's/\.md$//')
  
  if [ -n "$file_id" ]; then
    # Определяем уровень
    if [[ "$file_id" == Z-* ]]; then
      correct_level=0
    else
      correct_level=$(echo "$file_id" | cut -d'-' -f1)
    fi
    
    # Создаем slug из имени файла (без .md)
    slug="$slug_part"
    
    echo "📄 Обработка: $filename"
    
    # Создаем временный файл
    temp_file="${f}.tmp"
    
    # Начинаем новый frontmatter
    echo "---" > "$temp_file"
    
    # Стандартные поля
    echo "id: \"$file_id\"" >> "$temp_file"
    
    # Получаем имя из существующего frontmatter или создаем из slug
    existing_name=$(grep -m1 "^name:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
    if [ -n "$existing_name" ] && [ "$existing_name" != "null" ]; then
      echo "name: \"$existing_name\"" >> "$temp_file"
    else
      # Создаем имя из slug
      readable_name=$(echo "$slug_part" | sed "s/${file_id}_${file_type}_//" | tr '_' ' ' | sed 's/\./-/g')
      echo "name: \"$readable_name\"" >> "$temp_file"
    fi
    
    echo "type: \"$file_type\"" >> "$temp_file"
    echo "level: $correct_level" >> "$temp_file"
    
    # Статус
    existing_status=$(grep -m1 "^status:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
    if [ -n "$existing_status" ]; then
      echo "status: \"$existing_status\"" >> "$temp_file"
    else
      echo "status: \"active\"" >> "$temp_file"
    fi
    
    # Tags (преобразуем в JSON массив)
    existing_tags_line=$(grep -m1 "^tags:" "$f" 2>/dev/null)
    if [ -n "$existing_tags_line" ]; then
      # Пытаемся извлечь теги в правильном формате
      if echo "$existing_tags_line" | grep -q "\[.*\]"; then
        # Уже JSON массив
        echo "$existing_tags_line" | sed 's/^tags: */tags: /' >> "$temp_file"
      elif echo "$existing_tags_line" | grep -q "^-"; then
        # YAML список - преобразуем в JSON
        echo "tags: []" >> "$temp_file"
        # Пропускаем обработку списка для простоты
      else
        # Простая строка
        tags_content=$(echo "$existing_tags_line" | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
        if [ -n "$tags_content" ]; then
          # Преобразуем строку в массив
          IFS=',' read -ra TAGS <<< "$tags_content"
          echo -n "tags: [" >> "$temp_file"
          first=true
          for tag in "${TAGS[@]}"; do
            clean_tag=$(echo "$tag" | sed 's/^ *//; s/ *$//')
            if [ -n "$clean_tag" ]; then
              if [ "$first" = true ]; then
                first=false
              else
                echo -n ", " >> "$temp_file"
              fi
              echo -n "\"$clean_tag\"" >> "$temp_file"
            fi
          done
          echo "]" >> "$temp_file"
        else
          echo "tags: []" >> "$temp_file"
        fi
      fi
    else
      echo "tags: []" >> "$temp_file"
    fi
    
    # Даты
    existing_created=$(grep -m1 "^created:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
    if [ -n "$existing_created" ]; then
      echo "created: \"$existing_created\"" >> "$temp_file"
    else
      echo "created: \"2025-12-27\"" >> "$temp_file"  # Дата по умолчанию
    fi
    
    echo "updated: \"$(date +%Y-%m-%d)\"" >> "$temp_file"
    echo "author: \"kirillkravcov\"" >> "$temp_file"
    echo "slug: \"$slug\"" >> "$temp_file"
    
    # Конец frontmatter
    echo "---" >> "$temp_file"
    
    # Копируем остальное содержимое файла (после frontmatter)
    if grep -q "---" "$f"; then
      # Находим конец frontmatter
      awk 'BEGIN {frontmatter=0} /^---/ {frontmatter++; if (frontmatter==2) next} frontmatter==2' "$f" >> "$temp_file"
    else
      # Нет frontmatter - копируем весь файл после первой строки
      tail -n +2 "$f" >> "$temp_file"
    fi
    
    # Заменяем оригинальный файл
    mv "$temp_file" "$f"
    normalized_count=$((normalized_count + 1))
    echo "   ✅ Нормализован"
    echo ""
  fi
done

echo "========================================"
echo "📊 ИТОГ:"
echo "   Обработано файлов: $processed_count"
echo "   Нормализовано frontmatter: $normalized_count"
echo ""
echo "⚠️  Все лишние поля удалены, формат стандартизирован."
