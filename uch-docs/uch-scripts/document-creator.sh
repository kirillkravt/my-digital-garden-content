#!/bin/bash
# Модуль реального создания документов - с НОВОЙ системой генерации ID

# Загружаем новый генератор ID
if [ -f "$SCRIPT_DIR/id-generator-v2.sh" ]; then
    source "$SCRIPT_DIR/id-generator-v2.sh"
else
    echo "❌ Ошибка: Модуль id-generator-v2.sh не найден"
    exit 1
fi

# Найти файл документа по ID в frontmatter
find_document_by_id() {
    local target_id="$1"
    
    for file in *.md; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        if head -20 "$file" | grep -q '^id:[[:space:]]*"'"$target_id"'"'; then
            echo "$file"
            return 0
        fi
    done
    
    return 1
}

# Получить имя документа из поля name в frontmatter
get_name_from_frontmatter() {
    local file="$1"
    
    if [ ! -f "$file" ]; then
        return 1
    fi
    
    head -20 "$file" | awk '/^name:[[:space:]]*"/ {
        gsub(/^name:[[:space:]]*"/, "", $0)
        gsub(/"$/, "", $0)
        print $0
        exit
    }'
}

# Получить сокращенный тип для имени файла
get_short_type() {
    local type="$1"
    
    case "$type" in
        "project"|"proj") echo "PROD" ;;
        "line") echo "LINE" ;;
        "component"|"comp") echo "COMP" ;;
        "module") echo "MOD" ;;
        "epic") echo "EPIC" ;;
        "task") echo "TASK" ;;
        "feature"|"feat") echo "FEAT" ;;
        "bug") echo "BUG" ;;
        "snapshot"|"snap") echo "SNAP" ;;
        "solution"|"sol") echo "SOL" ;;
        "subtask") echo "SUBTASK" ;;
        "code_block"|"code") echo "CODE" ;;
        "decision"|"dec") echo "DEC" ;;
        "idea") echo "IDEA" ;;
        "reference"|"ref") echo "REF" ;;
        "meeting") echo "MEET" ;;
        "architecture"|"arch") echo "ARCH" ;;
        "documentation"|"doc") echo "DOC" ;;
        "specification"|"spec") echo "SPEC" ;;
        "design") echo "DESIGN" ;;
        "plan") echo "PLAN" ;;
        *) echo "DOC" ;;
    esac
}

# Создать реальный документ с НОВОЙ системой ID
create_real_document() {
    local name="$1"
    local level="$2"
    local type="$3"
    local parent_id="$4"
    local tags="$5"
    
    local current_date=$(get_current_date)
    local doc_id=""
    local parent_name=""
    local parent_file=""
    
    # 1. Определяем ID по НОВОЙ системе
    if [ "$level" = "N" ]; then
        # Неиерархический документ (используем старую функцию)
        if command -v generate_non_hierarchical_id &> /dev/null; then
            doc_id=$(generate_non_hierarchical_id "$type")
        else
            # Фолбэк
            case "$type" in
                "idea") doc_id="Z-$(date +%Y%m%d%H%M%S)" ;;
                "meeting") doc_id="M-$(date +%Y%m%d)" ;;
                *) doc_id="Z-$(date +%Y%m%d%H%M%S)" ;;
            esac
        fi
        echo "🆔 Сгенерирован неиерархический ID: $doc_id"
    else
        # Иерархический документ - используем НОВУЮ систему
        if ! command -v generate_id &> /dev/null; then
            echo "❌ Ошибка: Функция generate_id не найдена"
            echo "   Убедитесь что id-generator-v2.sh загружен"
            return 1
        fi
        
        # Получаем имя родителя если есть
        if [ -n "$parent_id" ] && [ "$level" -gt 1 ]; then
            parent_file=$(find_document_by_id "$parent_id")
            if [ -z "$parent_file" ]; then
                echo "⚠️  Предупреждение: Родительский документ с ID '$parent_id' не найден!"
                echo "   Создаю документ без информации о родителе"
            else
                parent_name=$(get_name_from_frontmatter "$parent_file")
                if [ -z "$parent_name" ]; then
                    parent_name=$(basename "$parent_file" .md | sed "s/^[^_]*_//" | sed "s/^[^_]*_//")
                fi
            fi
        fi
        
        # Генерируем ID по новой системе
        doc_id=$(generate_id "$level" "$type" "$parent_id")
        if [ $? -ne 0 ] || [ -z "$doc_id" ]; then
            echo "❌ Ошибка генерации ID"
            return 1
        fi
        echo "🆔 Сгенерирован ID по новой системе: $doc_id"
    fi
    
    # 2. Форматируем теги (используем существующую функцию)
    local tags_yaml=""
    if command -v format_tags_yaml &> /dev/null; then
        tags_yaml=$(format_tags_yaml "$tags" "$type")
        if [ -n "$tags_yaml" ]; then
            echo "🏷️  Сформированные теги:"
            echo "$tags_yaml"
        fi
    else
        # Простой фолбэк
        if [ -n "$tags" ]; then
            tags_yaml="tags:"
            IFS=',' read -ra TAG_ARRAY <<< "$tags"
            for tag in "${TAG_ARRAY[@]}"; do
                tags_yaml="$tags_yaml"$'\\n'$'  - "'"${tag// /}"'"'
            done
        fi
    fi
    
    # 3. Создаем имя файла в ПРАВИЛЬНОМ формате
    local filename=""
    if command -v generate_filename &> /dev/null; then
        filename=$(generate_filename "$doc_id" "$type" "$name" "$level")
    else
        # Фолбэк: простой формат
        local short_type=$(get_short_type "$type")
        local slug=$(echo "$name" | tr ' ' '_' | tr '[:upper:]' '[:lower:]' | tr -cd '[:alnum:]_')
        filename="${doc_id}_${short_type}_${slug}.md"
    fi
    
    echo "📄 Создаю документ: $filename"
    
    # 4. Выбираем шаблон
    if [ "$level" = "N" ]; then
        # Неиерархический документ
        if [ ! -f "T-NONHIER.md" ]; then
            echo "❌ Ошибка: Не найден шаблон для неиерархических документов T-NONHIER.md"
            return 1
        fi
        
        create_from_template "$filename" "$doc_id" "$name" "N" "$type" \
            "" "" "$tags_yaml" "$current_date" "T-NONHIER.md"
    else
        # Иерархический документ
        local template_file=""
        if [ "$level" -eq 1 ]; then
            template_file="T-MASTER.md"
        else
            template_file="T-CHILD.md"
        fi
        
        if [ ! -f "$template_file" ]; then
            echo "❌ Ошибка: Не найден шаблон $template_file"
            return 1
        fi
        
        create_from_template "$filename" "$doc_id" "$name" "$level" "$type" \
            "$parent_id" "$parent_name" "$tags_yaml" "$current_date" "$template_file"
    fi
    
    if [ $? -eq 0 ]; then
        echo "✅ Документ успешно создан: $filename"
        
        # Обновить родительский документ (если есть)
        if [ -n "$parent_file" ] && [ "$level" -gt 1 ]; then
            if command -v update_parent_document &> /dev/null; then
                update_parent_document "$parent_file" "$filename"
            fi
        fi
        
        return 0
    else
        echo "❌ Ошибка при создании документа"
        return 1
    fi
}

# Функция создания из шаблона (без изменений)
create_from_template() {
    local filename="$1"
    local doc_id="$2"
    local name="$3"
    local level="$4"
    local type="$5"
    local parent_id="$6"
    local parent_name="$7"
    local tags_yaml="$8"
    local current_date="$9"
    local template_file="${10}"
    
    echo "📋 Использую шаблон: $template_file"
    
    # Читаем шаблон
    local template_content=$(cat "$template_file")
    
    # Заменяем все переменные {{var}} на значения
    template_content=${template_content//\{\{id\}\}/$doc_id}
    template_content=${template_content//\{\{name\}\}/$name}
    template_content=${template_content//\{\{type\}\}/$type}
    template_content=${template_content//\{\{level\}\}/$level}
    template_content=${template_content//\{\{status\}\}/planning}
    template_content=${template_content//\{\{created\}\}/$current_date}
    template_content=${template_content//\{\{updated\}\}/$current_date}
    template_content=${template_content//\{\{author\}\}/$USER}
    
    # Обрабатываем родительскую информацию
    local parent_footer=""
    if [ -n "$parent_id" ] && [ -n "$parent_name" ] && [ "$template_file" = "T-CHILD.md" ]; then
        parent_footer="Родитель: ${parent_id}"
    fi
    
    # Создаем документ
    echo "$template_content" > "$filename"
    
    # Добавляем теги если есть
    if [ -n "$tags_yaml" ]; then
        # Вставляем теги в frontmatter - после строки author:
        local in_frontmatter=false
        local author_found=false
        local temp_file="${filename}.tmp"
        
        while IFS= read -r line || [ -n "$line" ]; do
            echo "$line" >> "$temp_file"
            
            if [[ "$line" == "---" ]]; then
                if [ "$in_frontmatter" = false ]; then
                    in_frontmatter=true
                else
                    in_frontmatter=false
                fi
            elif [ "$in_frontmatter" = true ] && [[ "$line" == author:* ]] && [ "$author_found" = false ]; then
                echo "$tags_yaml" >> "$temp_file"
                author_found=true
            fi
        done < "$filename"
        
        mv "$temp_file" "$filename"
    fi
    
    # Добавляем родительскую информацию если есть
    if [ -n "$parent_footer" ]; then
        echo "" >> "$filename"
        echo "---" >> "$filename"
        echo "$parent_footer" >> "$filename"
    fi
    
    echo "   📝 Заполнен шаблон, добавлены теги"
    return 0
}