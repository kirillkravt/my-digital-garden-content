#!/bin/bash

echo "=== КОНВЕРТАЦИЯ КОНКРЕТНЫХ ДОКУМЕНТОВ ==="

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
convert_single_file() {
    local file="$1"
    local dry_run="${2:-false}"
    
    echo "Обрабатываю: $file"
    
    # Проверяем существование файла
    if [ ! -f "$file" ]; then
        echo "  ❌ Файл не найден: $file"
        return 1
    fi
    
    # Извлекаем ID и имя из имени файла
    id_name=$(extract_id_and_name "$(basename "$file")")
    if [ -z "$id_name" ]; then
        echo "  ⚠️  Пропускаю: не удалось извлечь ID из имени файла"
        return 1
    fi
    
    id=$(echo "$id_name" | cut -d'|' -f1)
    name=$(echo "$id_name" | cut -d'|' -f2)
    level=$(get_level_from_id "$id")
    type=$(get_type_from_level "$level")
    
    echo "  ID: $id, Имя: $name, Уровень: $level, Тип: $type"
    
    # Проверяем, есть ли уже frontmatter в файле
    if head -1 "$file" | grep -q "^---"; then
        echo "  ℹ️  Файл уже имеет frontmatter, пропускаю"
        return 0
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
        echo "  Оригинальное содержимое будет сохранено"
        return 0
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
    return 0
}

# Функция для поиска файлов по ID
find_files_by_id() {
    local target_id="$1"
    
    # Ищем файлы с указанным ID
    files=$(find . -maxdepth 1 -name "${target_id} - *.md" -type f | sort)
    
    if [ -z "$files" ]; then
        # Попробуем найти без учета регистра
        files=$(find . -maxdepth 1 -iname "${target_id} - *.md" -type f | sort)
    fi
    
    echo "$files"
}

# Основная логика
echo "Доступные действия:"
echo "1 - Конвертировать файл по полному имени"
echo "2 - Конвертировать все файлы с определенным ID"
echo "3 - Показать все документы с ID"
read -p "Выберите действие (1, 2 или 3): " action

case $action in
    1)
        # Конвертация по полному имени файла
        echo ""
        echo "Введите полное имя файла (например: '00 - Мой проект.md'):"
        read filename
        
        if [ -z "$filename" ]; then
            echo "Ошибка: имя файла не может быть пустым"
            exit 1
        fi
        
        echo ""
        echo "Режим работы для файла '$filename':"
        echo "1 - Только показать что будет сделано (dry run)"
        echo "2 - Выполнить конвертацию"
        read -p "Выберите режим (1 или 2): " mode
        
        if [ "$mode" = "1" ]; then
            convert_single_file "$filename" "true"
        elif [ "$mode" = "2" ]; then
            convert_single_file "$filename" "false"
        else
            echo "Ошибка: неверный режим"
            exit 1
        fi
        ;;
    
    2)
        # Конвертация по ID
        echo ""
        echo "Введите ID документа (например: '00' или '00-01'):"
        read target_id
        
        if [ -z "$target_id" ]; then
            echo "Ошибка: ID не может быть пустым"
            exit 1
        fi
        
        # Ищем файлы с таким ID
        files=$(find_files_by_id "$target_id")
        
        if [ -z "$files" ]; then
            echo "Не найдено файлов с ID: $target_id"
            exit 0
        fi
        
        echo ""
        echo "Найдено файлов с ID $target_id: $(echo "$files" | wc -l)"
        echo "Список:"
        for file in $files; do
            echo "  - $(basename "$file")"
        done
        
        echo ""
        echo "Режим работы:"
        echo "1 - Только показать что будет сделано (dry run)"
        echo "2 - Выполнить конвертацию"
        read -p "Выберите режим (1 или 2): " mode
        
        echo ""
        dry_run="true"
        if [ "$mode" = "2" ]; then
            dry_run="false"
            echo "Выполняется конвертация..."
        else
            echo "Предпросмотр конвертации..."
        fi
        
        count=0
        for file in $files; do
            convert_single_file "$file" "$dry_run"
            echo ""
            count=$((count + 1))
        done
        
        if [ "$dry_run" = "false" ]; then
            echo "✅ Конвертировано файлов: $count"
        else
            echo "📋 Будет конвертировано файлов: $count"
        fi
        ;;
    
    3)
        # Показать все документы с ID
        echo ""
        echo "Поиск всех документов с ID в имени..."
        
        files=$(find . -maxdepth 1 -name "*.md" -type f | \
            grep -E '^\./[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})* - ' | \
            sort)
        
        if [ -z "$files" ]; then
            echo "Не найдено документов с ID"
            exit 0
        fi
        
        echo "Найдено документов: $(echo "$files" | wc -l)"
        echo ""
        echo "Список документов:"
        echo "================="
        
        for file in $files; do
            filename=$(basename "$file")
            # Извлекаем ID
            if [[ "$filename" =~ ^([0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*) ]]; then
                id="${BASH_REMATCH[1]}"
                name=$(echo "$filename" | sed -E "s/^${id} - //" | sed 's/\.md$//')
                
                # Проверяем есть ли frontmatter
                if head -1 "$file" | grep -q "^---"; then
                    has_fm="✅"
                else
                    has_fm="❌"
                fi
                
                level=$(get_level_from_id "$id")
                echo "$has_fm ID: $id | Уровень: $level | Файл: $name"
            fi
        done
        
        echo ""
        echo "✅ - имеет frontmatter"
        echo "❌ - не имеет frontmatter (нуждается в конвертации)"
        ;;
    
    *)
        echo "Ошибка: неверное действие"
        exit 1
        ;;
esac