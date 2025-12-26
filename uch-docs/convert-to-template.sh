#!/bin/bash

echo "=== КОНВЕРТАЦИЯ СУЩЕСТВУЮЩИХ ДОКУМЕНТОВ В ШАБЛОН ==="

# Функция для извлечения ID и имени из имени файла
extract_id_and_name() {
    local filename="$1"
    
    # Пытаемся извлечь ID (первые 2, 5, 8, 11 символов до дефиса)
    if [[ "$filename" =~ ^([0-9A-Fa-f]{2})(-[0-9A-Fa-f]{2})* ]]; then
        id="${BASH_REMATCH[0]}"
        # Убираем ID и " - " из начала имени
        name=$(echo "$filename" | sed -E "s/^${id} - //" | sed 's/\.md$//')
        echo "$id|$name"
    else
        echo ""
    fi
}

# Функция для определения уровня по ID
get_level_from_id() {
    local id="$1"
    if [ -z "$id" ]; then
        echo "0"
        return
    fi
    # Считаем количество дефисов в ID
    level=$(echo "$id" | tr -cd '-' | wc -c)
    echo $((level + 1))
}

# Функция для определения типа документа по уровню
get_type_from_level() {
    local level="$1"
    case $level in
        1) echo "project" ;;
        2|3) echo "component" ;;
        *) echo "task" ;;
    esac
}

# Функция для конвертации одного файла
convert_file() {
    local file="$1"
    local dry_run="${2:-false}"
    
    echo "Обрабатываю: $file"
    
    # Извлекаем ID и имя из имени файла
    id_name=$(extract_id_and_name "$(basename "$file")")
    if [ -z "$id_name" ]; then
        echo "  ⚠️  Пропускаю: не удалось извлечь ID из имени файла"
        return
    fi
    
    id=$(echo "$id_name" | cut -d'|' -f1)
    name=$(echo "$id_name" | cut -d'|' -f2)
    level=$(get_level_from_id "$id")
    type=$(get_type_from_level "$level")
    
    echo "  ID: $id, Уровень: $level, Тип: $type"
    
    # Проверяем, есть ли уже frontmatter в файле
    if head -1 "$file" | grep -q "^---"; then
        echo "  ℹ️  Файл уже имеет frontmatter, пропускаю"
        return
    fi
    
    # Читаем существующее содержимое
    existing_content=$(cat "$file")
    current_date=$(date +%Y-%m-%d)
    
    if [ "$dry_run" = "true" ]; then
        echo "  📝 Будет добавлен frontmatter:"
        echo "  ---"
        echo "  id: \"$id\""
        echo "  name: \"$name\""
        echo "  type: \"$type\""
        echo "  level: $level"
        echo "  status: \"active\""
        echo "  tags: [\"@$type\"]"
        echo "  created: \"$current_date\""
        echo "  updated: \"$current_date\""
        echo "  author: \"$USER\""
        echo "  ---"
        return
    fi
    
    # Создаем временный файл с frontmatter
    temp_file="${file}.tmp"
    
    cat > "$temp_file" << EOF
---
id: "$id"
name: "$name"
type: "$type"
level: $level
status: "active"
tags: ["@$type"]
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

$existing_content
EOF
    
    # Заменяем оригинальный файл
    mv "$temp_file" "$file"
    
    echo "  ✅ Конвертирован"
}

# Основная логика
echo "Режим работы:"
echo "1 - Только показать что будет сделано (dry run)"
echo "2 - Выполнить конвертацию"
read -p "Выберите режим (1 или 2): " mode

dry_run="false"
if [ "$mode" = "1" ]; then
    dry_run="true"
    echo "Режим: Только предпросмотр"
elif [ "$mode" = "2" ]; then
    dry_run="false"
    echo "Режим: Выполнение конвертации"
else
    echo "Ошибка: неверный выбор"
    exit 1
fi

# Ищем все .md файлы с ID в начале имени
echo ""
echo "Поиск документов для конвертации..."
files=$(find . -maxdepth 1 -name "*.md" -type f | \
    grep -E '^\./[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})* - ' | \
    sort)

if [ -z "$files" ]; then
    echo "Не найдено документов для конвертации"
    exit 0
fi

echo "Найдено документов: $(echo "$files" | wc -l)"
echo ""

count=0
for file in $files; do
    convert_file "$file" "$dry_run"
    echo ""
    count=$((count + 1))
done

if [ "$dry_run" = "false" ]; then
    echo "✅ Конвертировано документов: $count"
else
    echo "📋 Будет конвертировано документов: $count"
fi