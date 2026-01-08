#!/bin/bash
# Модуль реального создания документов - исправленная версия

# Найти файл документа по ID в frontmatter
find_document_by_id() {
    local target_id="$1"
    
    for file in *.md; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        # Ищем id: "target_id" в frontmatter
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
            
            # Проверяем что файл с таким ID не существует
            if ls -1 "${doc_id}"*.md 2>/dev/null | grep -q .; then
                echo "⚠️  Предупреждение: Найден файл с ID $doc_id, но продолжаем..."
            fi
        fi
    fi
    
    # 2. Форматируем теги
    local tags_yaml=$(format_tags_yaml "$tags" "$type")
    
    # 3. Создаем имя файла в правильном формате
    local short_type=$(get_short_type "$type")
    local filename="${doc_id} ${short_type} - ${name}.md"
    
    echo "📄 Создаю документ: $filename"
    echo "   🏷️  Тип: $type (сокращенно: $short_type)"
    
    # 4. Создаем документ
    if [ "$level" = "N" ]; then
        create_non_hierarchical_document "$filename" "$doc_id" "$name" "$type" "$tags_yaml" "$current_date"
    else
        create_hierarchical_document "$filename" "$doc_id" "$name" "$level" "$type" "$parent_id" "$parent_name" "$tags_yaml" "$current_date"
    fi
    
    # 5. Обновляем родительский документ (если есть)
    if [ -n "$parent_id" ] && [ -n "$parent_name" ] && [ -n "$parent_file" ]; then
        update_parent_document "$parent_file" "$doc_id" "$name"
    fi
    
    echo "✅ Документ создан: $filename"
    return 0
}

# Создать иерархический документ - УПРОЩЕННАЯ версия (без шаблонов)
create_hierarchical_document() {
    local filename="$1"
    local doc_id="$2"
    local name="$3"
    local level="$4"
    local type="$5"
    local parent_id="$6"
    local parent_name="$7"
    local tags_yaml="$8"
    local current_date="$9"
    
    # ИСПРАВЛЕНО: Используем упрощенный подход без шаблонов
    echo "📝 Создаю документ без шаблона"
    
    cat > "$filename" << DOC_EOF
---
id: "$doc_id"
name: "$name"
type: "$type"
level: $level
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Уровень**: $level
DOC_EOF
    
    if [ -n "$parent_id" ] && [ -n "$parent_name" ]; then
        cat >> "$filename" << DOC_EOF
- **Родитель**: [[$parent_id - $parent_name]]
DOC_EOF
    fi
    
    cat >> "$filename" << DOC_EOF
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### ОПИСАНИЕ
Добавьте описание здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $current_date
Уровень: $level
DOC_EOF
    
    if [ -n "$parent_id" ]; then
        echo "Родитель: $parent_id" >> "$filename"
    fi
}

# Создать неиерархический документ - УПРОЩЕННАЯ версия
create_non_hierarchical_document() {
    local filename="$1"
    local doc_id="$2"
    local name="$3"
    local type="$4"
    local tags_yaml="$5"
    local current_date="$6"
    
    echo "📝 Создаю неиерархический документ без шаблона"
    
    cat > "$filename" << DOC_EOF
---
id: "$doc_id"
name: "$name"
type: "$type"
level: "N"
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Тип**: $type
- **Уровень**: N (неиерархический)
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### СОДЕРЖАНИЕ

---

Создано: $current_date
DOC_EOF
}
