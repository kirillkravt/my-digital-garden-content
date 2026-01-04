#!/bin/bash
# Скрипт добавления slug к документам без slug

echo "=== ДОБАВЛЕНИЕ SLUG К ДОКУМЕНТАМ ==="

processed=0
skipped=0
errors=0

for file in *.md; do
    # Пропускаем файлы без YAML frontmatter
    if ! head -1 "$file" | grep -q "---"; then
        echo "⚠️  Пропускаем: $file (нет YAML frontmatter)"
        skipped=$((skipped + 1))
        continue
    fi
    
    # Проверяем есть ли уже slug
    if grep -q "^slug:" "$file"; then
        echo "✅ Уже есть: $file"
        skipped=$((skipped + 1))
        continue
    fi
    
    # Получаем ID документа
    id_line=$(grep -E '^id:' "$file" | head -1)
    if [ -z "$id_line" ]; then
        echo "❌ Ошибка: $file (нет ID)"
        errors=$((errors + 1))
        continue
    fi
    
    # Извлекаем ID
    id=$(echo "$id_line" | sed 's/id: *//' | tr -d '"' | tr -d "'" | tr -d ' ')
    
    # Получаем тип документа
    type_line=$(grep -E '^type:' "$file" | head -1)
    type=""
    if [ -n "$type_line" ]; then
        type=$(echo "$type_line" | sed 's/type: *//' | tr -d '"' | tr -d "'" | tr -d ' ')
    fi
    
    # Получаем имя файла без расширения
    filename=$(basename "$file" .md)
    # Берем последнюю часть имени (после последнего дефиса)
    last_part=$(echo "$filename" | sed 's/.* - //' | tr ' ' '-' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]-')
    
    # Формируем slug
    if [ -n "$type" ]; then
        slug="$id-$type-$last_part"
    else
        slug="$id-$last_part"
    fi
    
    # Очищаем slug от лишних символов
    slug=$(echo "$slug" | sed 's/--/-/g' | sed 's/^-//' | sed 's/-$//')
    
    # Добавляем slug в файл (после поля id)
    echo "🔧 Добавляем slug к: $file"
    echo "   Slug: $slug"
    
    # Создаем временный файл
    temp_file="${file}.tmp"
    
    # Копируем файл с добавлением slug
    awk -v slug="$slug" '
    /^id:/ && !slug_added {
        print $0
        print "slug: \"" slug "\""
        slug_added = 1
        next
    }
    { print }
    ' "$file" > "$temp_file"
    
    # Заменяем оригинальный файл
    mv "$temp_file" "$file"
    
    processed=$((processed + 1))
done

echo ""
echo "=== РЕЗУЛЬТАТ ==="
echo "Обработано: $processed"
echo "Пропущено: $skipped"
echo "Ошибок: $errors"
echo ""

if [ $processed -gt 0 ]; then
    echo "✅ Slug добавлены к $processed документам"
else
    echo "⚠️  Нечего добавлять"
fi
