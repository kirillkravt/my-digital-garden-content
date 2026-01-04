#!/bin/bash

echo "=== UCH CREATE UNIFIED: ЕДИНЫЙ СКРИПТ СОЗДАНИЯ ДОКУМЕНТОВ ==="

# Получаем текущую дату
CURRENT_DATE=$(date +%Y-%m-%d)

# Функции из uch-create.sh (интерактивный режим)
find_free_master_id() {
    # Ищем все мастер-файлы (уровень 1)
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E '^\./[0-9A-Fa-f]{2} - ' | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        sort | uniq)
    
    if [ -z "$existing_ids" ]; then
        echo "00"
        return
    fi
    
    # Конвертируем все ID в десятичные
    declare -a dec_ids=()
    for hex_id in $existing_ids; do
        dec_id=$((16#$hex_id))
        dec_ids+=($dec_id)
    done
    
    # Сортируем и ищем первый пропуск
    sorted_ids=($(printf "%d\n" "${dec_ids[@]}" | sort -n))
    expected=0
    for id in "${sorted_ids[@]}"; do
        if [ $id -gt $expected ]; then
            break
        fi
        expected=$((id + 1))
    done
    
    printf "%02X" $expected
}

find_free_child_id() {
    local parent_id="$1"
    
    pattern="${parent_id}-[0-9A-Fa-f][0-9A-Fa-f]"
    
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E "^\./${pattern} - " | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        grep -E "^${parent_id}-[0-9A-Fa-f]{2}$" | \
        awk -F"${parent_id}-" '{print $2}' | \
        sort | uniq)
    
    if [ -z "$existing_ids" ]; then
        echo "01"
        return
    fi
    
    # Конвертируем hex ID в decimal
    declare -a dec_array=()
    for hex_id in $existing_ids; do
        dec_id=$((16#$hex_id))
        dec_array+=($dec_id)
    done
    
    sorted_array=($(printf "%d\n" "${dec_array[@]}" | sort -n))
    
    expected=1
    for id in "${sorted_array[@]}"; do
        if [ $id -gt $expected ]; then
            break
        fi
        expected=$((id + 1))
    done
    
    printf "%02X" $expected
}

clean_parent_name() {
    local full_filename="$1"
    
    filename=$(basename "$full_filename" .md)
    
    OLD_IFS="$IFS"
    IFS=" - "
    parts=($filename)
    IFS="$OLD_IFS"
    
    if [ ${#parts[@]} -eq 0 ]; then
        echo "$filename"
        return
    fi
    
    clean_parts=()
    for part in "${parts[@]}"; do
        if echo "$part" | grep -qE '^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*$'; then
            continue
        else
            clean_parts+=("$part")
        fi
    done
    
    if [ ${#clean_parts[@]} -eq 0 ]; then
        last_part="${parts[-1]}"
        echo "$last_part"
    else
        clean_name=$(IFS=" - "; echo "${clean_parts[*]}")
        echo "$clean_name"
    fi
}

# Функция для обновления родительского документа (из uch-create.sh)
update_parent_document() {
    local parent_file="$1"
    local child_id="$2"
    local child_name="$3"
    
    echo "  Обновляю родительский документ: $(basename "$parent_file")"
    
    if [ ! -f "$parent_file" ]; then
        echo "  ⚠️  Родительский файл не найден, пропускаю обновление"
        return 1
    fi
    
    temp_file="${parent_file}.tmp"
    
    link_added=0
    
    awk -v child_id="$child_id" -v child_name="$child_name" '
    BEGIN { 
        in_children_section = 0
        children_section_found = 0
        link_exists = 0
        link_added = 0
    }
    
    /\[\[.* - .*\]\]/ && in_children_section {
        if ($0 ~ "\\[\\[" child_id " - " child_name "\\]\\]") {
            link_exists = 1
        }
    }
    
    /#### ДОЧЕРНИЕ ДОКУМЕНТЫ/ {
        in_children_section = 1
        children_section_found = 1
        print $0
        next
    }
    
    in_children_section && /^[[:space:]]*Пока нет дочерних документов/ {
        next
    }
    
    in_children_section && (/^####/ || /^###/ || /^##/ || /^#/ || /^---/) {
        in_children_section = 0
    }
    
    in_children_section && /^[[:space:]]*$/ {
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    in_children_section && /^---/ {
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    in_children_section && !/^- \[\[/ && !/^[[:space:]]*$/ {
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    { print $0 }
    
    END {
        if (!children_section_found) {
            print ""
            print "#### ДОЧЕРНИЕ ДОКУМЕНТЫ"
            print "- [[" child_id " - " child_name "]]"
        } else if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
        }
    }
    ' "$parent_file" > "$temp_file"
    
    mv "$temp_file" "$parent_file"
    
    echo "  ✅ Ссылка добавлена в родительский документ"
}

# Функция для форматирования тегов (из v3)
format_tags_yaml() {
    local tags_input="$1"
    local type="$2"
    
    local temp_file=$(mktemp)
    
    # Добавляем тип как первый тег
    echo "- \"$type\"" > "$temp_file"
    
    # Добавляем остальные теги
    if [ -n "$tags_input" ]; then
        # Разделяем теги по запятым
        IFS=',' read -r -a tag_parts <<< "$tags_input"
        
        for tag in "${tag_parts[@]}"; do
            # Убираем пробелы и префиксы @/#
            tag_clean=$(echo "$tag" | xargs | sed 's/^[@#]//')
            if [ -n "$tag_clean" ]; then
                echo "- \"$tag_clean\"" >> "$temp_file"
            fi
        done
    fi
    
    local yaml_content=$(cat "$temp_file")
    rm "$temp_file"
    
    echo "$yaml_content"
}

# Функция для генерации ID вручную (из v2/v3)
generate_id_for_level() {
    local parent_id="$1"
    local level="$2"
    
    # Если нет parent_id, это уровень 1
    if [ -z "$parent_id" ]; then
        # Ищем максимальный ID уровня 1
        max_id=$(find . -maxdepth 1 -name "?? - *.md" -type f | \
            grep -o '^\./[0-9A-Fa-f]\{2\}' | \
            sort -r | head -1 | \
            sed 's/^\.\///' | \
            tr 'a-f' 'A-F')
        
        if [ -z "$max_id" ]; then
            echo "00"
        else
            next_id=$(printf "%02X" $((0x$max_id + 1)))
            echo "$next_id"
        fi
        return 0
    fi
    
    # Для уровней 2+
    pattern="${parent_id}-[0-9A-Fa-f]\{2\}"
    max_child=$(find . -maxdepth 1 -name "*${parent_id}-?? - *.md" -type f | \
        grep -o "${pattern}" | \
        sort -r | head -1 | \
        tr 'a-f' 'A-F')
    
    if [ -z "$max_child" ]; then
        echo "${parent_id}-00"
    else
        last_segment=$(echo "$max_child" | grep -o '[^-]*$')
        next_segment=$(printf "%02X" $((0x$last_segment + 1)))
        echo "${parent_id}-${next_segment}"
    fi
}

# Функция проверки существования ID
check_id_exists() {
    local id="$1"
    find . -maxdepth 1 -name "${id} - *.md" -type f | grep -q .
    return $?
}

# Главная функция создания документа
create_document() {
    local mode="$1"           # auto или manual
    local parent_id="$2"
    local doc_name="$3"
    local tags_input="$4"
    local type="$5"
    local manual_id="$6"      # только для manual mode
    
    echo ""
    echo "=== СОЗДАНИЕ ДОКУМЕНТА ==="
    
    # Определяем ID
    if [ "$mode" = "manual" ] && [ -n "$manual_id" ]; then
        # Ручной режим
        if check_id_exists "$manual_id"; then
            echo "❌ Ошибка: Документ с ID '$manual_id' уже существует!"
            return 1
        fi
        DOC_ID="$manual_id"
        
        # Определяем уровень
        LEVEL=$(echo "$DOC_ID" | tr -cd '-' | wc -c)
        LEVEL=$((LEVEL + 1))
        
        # Определяем parent_id (если не указан явно)
        if [ -z "$parent_id" ] && [ $LEVEL -gt 1 ]; then
            parent_id=$(echo "$DOC_ID" | sed 's/-[^-]*$//')
        fi
    else
        # Автоматический режим
        if [ -z "$parent_id" ]; then
            # Мастер-документ
            DOC_ID=$(find_free_master_id)
            LEVEL=1
        else
            # Дочерний документ
            if ! check_id_exists "$parent_id"; then
                echo "❌ Ошибка: Родительский документ с ID '$parent_id' не найден!"
                return 1
            fi
            
            # Получаем родительский файл
            parent_file=$(find . -maxdepth 1 -name "${parent_id} - *.md" -type f | head -1)
            if [ -z "$parent_file" ]; then
                echo "❌ Ошибка: Родительский файл не найден!"
                return 1
            fi
            
            # Генерируем ID
            child_suffix=$(find_free_child_id "$parent_id")
            DOC_ID="${parent_id}-${child_suffix}"
            
            # Определяем уровень
            parent_level=$(echo "$parent_id" | tr -cd '-' | wc -c)
            parent_level=$((parent_level + 1))
            LEVEL=$((parent_level + 1))
        fi
    fi
    
    # Получаем имя родителя
    PARENT_NAME=""
    if [ -n "$parent_id" ]; then
        parent_file=$(find . -maxdepth 1 -name "${parent_id} - *.md" -type f | head -1)
        if [ -n "$parent_file" ]; then
            PARENT_NAME=$(clean_parent_name "$parent_file")
        fi
    fi
    
    # Определяем тип документа если не указан
    if [ -z "$type" ]; then
        case $LEVEL in
            1) type="project" ;;
            2|3) type="component" ;;
            *) type="task" ;;
        esac
    fi
    
    # Форматируем теги
    TAGS_YAML=$(format_tags_yaml "$tags_input" "$type")
    
    # Имя файла
    FILENAME="${DOC_ID} - ${doc_name}.md"
    
    echo "ID: $DOC_ID"
    echo "Уровень: $LEVEL"
    echo "Название: $doc_name"
    echo "Тип: $type"
    echo "Родитель: $parent_id ($PARENT_NAME)"
    echo "Файл: $FILENAME"
    echo ""
    
    # Запрашиваем подтверждение
    echo "Создать документ? (y/n)"
    read -r CONFIRM
    
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Отменено."
        return 0
    fi
    
    # Создаем документ
    cat > "$FILENAME" << DOC_EOF
---
id: "$DOC_ID"
name: "$doc_name"
type: "$type"
level: $LEVEL
status: "planning"
$(echo "$TAGS_YAML" | sed 's/^/  /')
created: "$CURRENT_DATE"
updated: "$CURRENT_DATE"
author: "$USER"
---

### $doc_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$DOC_ID\`
- **Уровень**: $LEVEL
DOC_EOF
    
    # Добавляем родительскую информацию для дочерних документов
    if [ -n "$parent_id" ] && [ -n "$PARENT_NAME" ]; then
        cat >> "$FILENAME" << DOC_EOF
- **Родитель**: [[$parent_id - $PARENT_NAME]]
DOC_EOF
    fi
    
    # Завершаем документ
    cat >> "$FILENAME" << DOC_EOF
- **Статус**: Планирование
- **Создано**: \`$CURRENT_DATE\`
- **Теги**: $tags_input

#### ОПИСАНИЕ
Добавьте описание здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $CURRENT_DATE
Уровень: $LEVEL
DOC_EOF
    
    # Добавляем родителя в конец для дочерних документов
    if [ -n "$parent_id" ]; then
        echo "Родитель: $parent_id" >> "$FILENAME"
    fi
    
    echo "✅ Документ создан: $FILENAME"
    
    # Обновляем родительский документ (если есть)
    if [ -n "$parent_id" ] && [ -n "$PARENT_NAME" ] && [ -n "$parent_file" ]; then
        update_parent_document "$parent_file" "$DOC_ID" "$doc_name"
    fi
    
    echo ""
    echo "=== ВЫПОЛНЕНО ==="
    echo "Документ: $FILENAME"
    echo "ID: $DOC_ID"
    echo "Уровень: $LEVEL"
}

# Основная логика - интерактивный режим
interactive_mode() {
    echo ""
    echo "=== РЕЖИМ РАБОТЫ ==="
    echo "1 - Стандартный режим (автоматическая генерация ID)"
    echo "2 - Продвинутый режим (ручное указание ID)"
    echo "3 - Быстрое создание задачи"
    read -p "Ваш выбор (1-3): " work_mode
    
    case $work_mode in
        1)
            # Стандартный режим
            echo ""
            echo "Выберите тип документа:"
            echo "1 - Мастер-документ (уровень 1, корневой)"
            echo "2 - Дочерний документ (уровень 2+)"
            read -p "Ваш выбор (1 или 2): " doc_type
            
            case $doc_type in
                1)
                    echo ""
                    echo "Введите название проекта:"
                    read -r doc_name
                    
                    if [ -z "$doc_name" ]; then
                        echo "❌ Ошибка: название не может быть пустым"
                        return 1
                    fi
                    
                    echo "Введите теги через запятую (можно оставить пустым):"
                    read -r tags_input
                    
                    create_document "auto" "" "$doc_name" "$tags_input" "project"
                    ;;
                
                2)
                    echo ""
                    echo "Введите ID родительского документа (например: 00 или 00-01):"
                    read -r parent_id
                    
                    if [ -z "$parent_id" ]; then
                        echo "❌ Ошибка: ID родителя не может быть пустым"
                        return 1
                    fi
                    
                    echo "Введите название документа:"
                    read -r doc_name
                    
                    if [ -z "$doc_name" ]; then
                        echo "❌ Ошибка: название не может быть пустым"
                        return 1
                    fi
                    
                    echo "Введите теги через запятую (можно оставить пустым):"
                    read -r tags_input
                    
                    echo "Введите тип документа (project, component, task) или оставьте пустым для автоопределения:"
                    read -r doc_type_input
                    
                    create_document "auto" "$parent_id" "$doc_name" "$tags_input" "$doc_type_input"
                    ;;
                
                *)
                    echo "❌ Неверный выбор"
                    return 1
                    ;;
            esac
            ;;
        
        2)
            # Продвинутый режим (ручной ID)
            echo ""
            echo "=== ПРОДВИНУТЫЙ РЕЖИМ ==="
            echo "Введите ID документа вручную (например: 00, 00-01, 00-FF):"
            read -r manual_id
            
            if [ -z "$manual_id" ]; then
                echo "❌ Ошибка: ID не может быть пустым"
                return 1
            fi
            
            echo "Введите название документа:"
            read -r doc_name
            
            if [ -z "$doc_name" ]; then
                echo "❌ Ошибка: название не может быть пустым"
                return 1
            fi
            
            echo "Введите ID родителя (или оставьте пустым для автоопределения по ID):"
            read -r parent_id
            
            echo "Введите теги через запятую:"
            read -r tags_input
            
            echo "Введите тип документа (project, component, task):"
            read -r doc_type_input
            
            if [ -z "$doc_type_input" ]; then
                doc_type_input="component"
            fi
            
            create_document "manual" "$parent_id" "$doc_name" "$tags_input" "$doc_type_input" "$manual_id"
            ;;
        
        3)
            # Быстрое создание задачи
            echo ""
            echo "=== БЫСТРОЕ СОЗДАНИЕ ЗАДАЧИ ==="
            
            # Предлагаем выбрать родителя из существующих
            echo "Доступные родительские документы:"
            find . -maxdepth 1 -name "*.md" -type f | \
                grep -E '^\./[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})* - ' | \
                sed 's/^\.\///' | \
                cut -d' ' -f1 | \
                sort | \
                nl -w2 -s'. '
            
            echo ""
            echo "Введите номер родительского документа (или ID вручную):"
            read -r parent_choice
            
            if [[ "$parent_choice" =~ ^[0-9]+$ ]]; then
                # По номеру
                parent_id=$(find . -maxdepth 1 -name "*.md" -type f | \
                    grep -E '^\./[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})* - ' | \
                    sed 's/^\.\///' | \
                    cut -d' ' -f1 | \
                    sort | \
                    sed -n "${parent_choice}p")
            else
                # По ID
                parent_id="$parent_choice"
            fi
            
            if [ -z "$parent_id" ]; then
                echo "❌ Ошибка: неверный выбор родителя"
                return 1
            fi
            
            echo "Введите название задачи:"
            read -r doc_name
            
            if [ -z "$doc_name" ]; then
                echo "❌ Ошибка: название не может быть пустым"
                return 1
            fi
            
            echo "Введите теги через запятую (можно оставить пустым):"
            read -r tags_input
            
            # Автоматически добавляем тег @task если его нет
            if [ -n "$tags_input" ] && [[ ! "$tags_input" =~ task ]]; then
                tags_input="task,${tags_input}"
            elif [ -z "$tags_input" ]; then
                tags_input="task"
            fi
            
            create_document "auto" "$parent_id" "$doc_name" "$tags_input" "task"
            ;;
        
        *)
            echo "❌ Неверный выбор"
            return 1
            ;;
    esac
}

# Режим командной строки
if [ $# -gt 0 ]; then
    # Парсим аргументы
    MODE="auto"
    PARENT_ID=""
    NAME=""
    TAGS=""
    TYPE=""
    MANUAL_ID=""
    
    while [[ $# -gt 0 ]]; do
        case $1 in
            --manual-id)
                MODE="manual"
                MANUAL_ID="$2"
                shift 2
                ;;
            --parent)
                PARENT_ID="$2"
                shift 2
                ;;
            --name)
                NAME="$2"
                shift 2
                ;;
            --tags)
                TAGS="$2"
                shift 2
                ;;
            --type)
                TYPE="$2"
                shift 2
                ;;
            --interactive|-i)
                interactive_mode
                exit 0
                ;;
            *)
                echo "Неизвестный аргумент: $1"
                echo "Использование:"
                echo "  ./uch-create-unified.sh --interactive (интерактивный режим)"
                echo "  ./uch-create-unified.sh --parent ID --name NAME [--tags TAGS] [--type TYPE]"
                echo "  ./uch-create-unified.sh --manual-id ID --name NAME [--parent ID] [--tags TAGS] [--type TYPE]"
                exit 1
                ;;
        esac
    done
    
    if [ -z "$NAME" ]; then
        echo "❌ Ошибка: необходимо указать --name"
        exit 1
    fi
    
    create_document "$MODE" "$PARENT_ID" "$NAME" "$TAGS" "$TYPE" "$MANUAL_ID"
else
    # Интерактивный режим по умолчанию
    interactive_mode
fi
