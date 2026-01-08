#!/bin/bash
# Модуль реального создания документов - ТОЛЬКО внешние шаблоны

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
        "project"|"proj") echo "proj" ;;
        "line") echo "line" ;;
        "component"|"comp") echo "comp" ;;
        "module") echo "mod" ;;
        "epic") echo "epic" ;;
        "task") echo "task" ;;
        "feature"|"feat") echo "feat" ;;
        "bug") echo "bug" ;;
        "snapshot"|"snap") echo "snap" ;;
        "solution"|"sol") echo "sol" ;;
        "subtask") echo "subtask" ;;
        "code_block"|"code") echo "code" ;;
        "decision"|"dec") echo "dec" ;;
        "idea") echo "idea" ;;
        "reference"|"ref") echo "ref" ;;
        "meeting") echo "meet" ;;
        *) echo "doc" ;;
    esac
}

# Создать реальный документ
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
    
    # 1. Определяем ID
    if [ "$level" = "N" ]; then
        # Неиерархический документ
        doc_id=$(generate_non_hierarchical_id "$type")
    else
        # Иерархический документ
        if [ -z "$parent_id" ] || [ "$level" -eq 1 ]; then
            # Мастер-документ
            doc_id=$(find_free_master_id)
            echo "🆔 Сгенерирован ID: $doc_id"
        else
            # Дочерний документ
            parent_file=$(find_document_by_id "$parent_id")
            if [ -z "$parent_file" ]; then
                echo "❌ Ошибка: Родительский документ с ID '$parent_id' не найден!"
                return 1
            fi
            
            parent_name=$(get_name_from_frontmatter "$parent_file")
            if [ -z "$parent_name" ]; then
                parent_name=$(basename "$parent_file" .md | sed "s/^${parent_id} - //")
            fi
            
            # Генерируем свободный ID
            child_suffix=$(find_free_child_id "$parent_id")
            doc_id="${parent_id}-${child_suffix}"
            echo "🆔 Сгенерирован ID: $doc_id (свободный: $child_suffix)"
        fi
    fi
    
    # 2. Форматируем теги
    local tags_yaml=$(format_tags_yaml "$tags" "$type")
    echo "🏷️  Сформированные теги:"
    echo "$tags_yaml"
    
    # 3. Создаем имя файла в правильном формате
    local short_type=$(get_short_type "$type")
    local filename="${doc_id} ${short_type} - ${name}.md"
    
    echo "📄 Создаю документ: $filename"
    echo "   🏷️  Тип: $type (сокращенно: $short_type)"
    
    # 4. Создаем документ ТОЛЬКО из внешних шаблонов
    if [ "$level" = "N" ]; then
        # Неиерархический документ - проверяем шаблон
        if [ ! -f "T-NONHIER.md" ]; then
            echo "❌ Ошибка: Не найден шаблон для неиерархических документов T-NONHIER.md"
            echo "   Создайте файл T-NONHIER.md в корневой директории"
            return 1
        fi
        create_from_template "$filename" "$doc_id" "$name" "N" "$type" \
            "" "" "$tags_yaml" "$current_date" "T-NONHIER.md"
    else
        # Иерархический документ - определяем шаблон
        local template_file=""
        if [ "$level" -eq 1 ]; then
            template_file="T-MASTER.md"
        else
            template_file="T-CHILD.md"
        fi
        
        if [ ! -f "$template_file" ]; then
            echo "❌ Ошибка: Не найден шаблон $template_file"
            echo "   Для уровня $level требуется файл: $template_file"
            return 1
        fi
        
        create_from_template "$filename" "$doc_id" "$name" "$level" "$type" \
            "$parent_id" "$parent_name" "$tags_yaml" "$current_date" "$template_file"
    fi
    
    # 5. Обновляем родительский документ (если есть)
    if [ -n "$parent_id" ] && [ -n "$parent_name" ] && [ -n "$parent_file" ]; then
        update_parent_document "$parent_file" "$doc_id" "$name"
    fi
    
    echo "✅ Документ создан: $filename"
    return 0
}

# Создать из шаблона (упрощенная версия)
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
    
    # Обрабатываем родительскую информацию (только для T-CHILD.md)
    local parent_footer=""
    if [ -n "$parent_id" ] && [ -n "$parent_name" ] && [ "$template_file" = "T-CHILD.md" ]; then
        parent_footer="Родитель: ${parent_id}"
    fi
    template_content=${template_content//\{\{parent_footer\}\}/$parent_footer}
    
    # Создаем временный файл с шаблоном
    local temp_file="/tmp/template_$(date +%s).md"
    echo "$template_content" > "$temp_file"
    
    # Теперь вставляем теги в правильное место
    # Ищем строку "tags:" и заменяем ее на наши теги
    if [ -n "$tags_yaml" ] && [ "$tags_yaml" != "tags:" ]; then
        # Создаем новый файл с правильными тегами
        local new_file="/tmp/new_$(date +%s).md"
        
        awk -v new_tags="$tags_yaml" '
        {
            if ($0 ~ /^tags:/) {
                # Заменяем строку tags: на наши теги
                print new_tags
                next
            }
            print $0
        }
        ' "$temp_file" > "$new_file"
        
        mv "$new_file" "$filename"
    else
        # Если тегов нет или только "tags:", просто копируем
        cp "$temp_file" "$filename"
    fi
    
    # Очищаем временный файл
    rm -f "$temp_file"
    
    # Проверяем что файл создан
    if [ ! -f "$filename" ]; then
        echo "❌ Ошибка: Не удалось создать файл из шаблона"
        return 1
    fi
    
    echo "   ✅ Документ создан из шаблона"
}
