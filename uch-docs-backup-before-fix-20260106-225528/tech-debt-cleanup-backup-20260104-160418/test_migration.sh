#!/bin/bash

echo "🧪 ТЕСТ МИГРАЦИИ ОДНОГО ФАЙЛА"
echo "============================"

# Находим первый файл с ID для теста
test_file=$(find . -maxdepth 1 -name "*.md" -type f | while read f; do 
    if grep -q "^id:" "$f" 2>/dev/null; then 
        echo "$f"; 
        break; 
    fi; 
done)

if [ -z "$test_file" ]; then
    echo "❌ Не найдено файлов с ID для теста"
    exit 1
fi

echo "Тестовый файл: $test_file"
echo ""

# Извлекаем данные
id=$(grep "^id:" "$test_file" | head -1 | sed 's/^id: *"\(.*\)"/\1/' | tr -d '"' | xargs)
type=$(grep "^type:" "$test_file" 2>/dev/null | head -1 | sed 's/^type: *"\(.*\)"/\1/' | tr -d '"' | xargs || echo "N/A")
name=$(basename "$test_file" .md)

echo "📊 ТЕКУЩИЕ ДАННЫЕ:"
echo "ID: $id"
echo "Type: $type"
echo "Name: $name"
echo ""

# Определяем новый ID
IFS='-' read -r -a parts <<< "$id"

if [[ "$id" == "00" ]]; then
    new_id="00"
    new_level=1
    new_type="hub"
    echo "✅ Буду хабом (уровень 1)"
    
elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 2 ]]; then
    new_id="${parts[1]}"
    new_level=1
    new_type="line"
    echo "✅ Стану линией (уровень 1): 00-${parts[1]} -> ${parts[1]}"
    
elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 3 ]]; then
    new_id="${parts[1]}-${parts[2]}"
    new_level=2
    new_type="epic"
    echo "✅ Стану эпиком (уровень 2): 00-${parts[1]}-${parts[2]} -> ${parts[1]}-${parts[2]}"
    
elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 4 ]]; then
    new_id="${parts[1]}-${parts[2]}-${parts[3]}"
    new_level=3
    new_type="task"
    echo "✅ Стану задачей (уровень 3): 00-${parts[1]}-${parts[2]}-${parts[3]} -> ${parts[1]}-${parts[2]}-${parts[3]}"
    
else
    new_id="$id"
    new_level="?"
    new_type="$type"
    echo "⚠️  Неизвестный формат"
fi

# Генерируем slug
last_part="${new_id##*-}"
slug="${new_id}-${new_type}-${last_part}"

echo ""
echo "🎯 НОВЫЕ ДАННЫЕ:"
echo "Новый ID: $new_id"
echo "Новый Type: $new_type"
echo "Новый Level: $new_level"
echo "Slug: $slug"
echo ""

# Показываем что будет изменено
echo "📝 ПРЕДПРОСМОТР ИЗМЕНЕНИЙ:"
echo "========================"
echo "Файл: $test_file"
echo ""
echo "БЫЛО:"
grep -A2 -B2 "^id:\|^type:\|^level:" "$test_file" | head -10
echo ""
echo "СТАНЕТ:"
echo "id: \"$new_id\""
echo "type: \"$new_type\""
echo "level: $new_level"
echo "slug: \"$slug\""
