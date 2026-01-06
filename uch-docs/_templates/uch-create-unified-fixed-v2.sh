#!/bin/bash

echo "=== UCH CREATE UNIFIED FIXED: ПОЛНАЯ СИСТЕМА ТИПОВ ==="

# Получаем текущую дату
CURRENT_DATE=$(date +%Y-%m-%d)

# Существующие функции без изменений
find_free_master_id() {
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E '^\./[0-9A-Fa-f]{2} - ' | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        sort | uniq)
    
    if [ -z "$existing_ids" ]; then
        echo "00"
        return
    fi
    
    declare -a dec_ids=()
    for hex_id in $existing_ids; do
        dec_id=$((16#$hex_id))
        dec_ids+=($dec_id)
    done
    
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
    
    declare -a dec_array=()
    for hex_id in $existing_ids; do
        dec_id=$((16#$hex_id)
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

# ИСПРАВЛЕННАЯ функция для форматирования тегов
format_tags_yaml() {
    local tags_input="$1"
    local type="$2"
    
    # Начинаем с типа документа
    local yaml_tags="tags:"
    yaml_tags="$yaml_tags"$'\n'"  - \"$type\""
    
    # Обрабатываем остальные теги
    if [ -n "$tags_input" ]; then
        # Разделяем теги по запятым
        IFS=',' read -r -a tag_parts <<< "$tags_input"
        
        for tag in "${tag_parts[@]}"; do
            # Убираем пробелы и префиксы @/#
            tag_clean=$(echo "$tag" | xargs | sed 's/^[@#]//')
            if [ -n "$tag_clean" ] && [ "$tag_clean" != "$type" ]; then
                # Добавляем только если тег отличается от типа
                yaml_tags="$yaml_tags"$'\n'"  - \"$tag_clean\""
            fi
        done
    fi
    
    echo "$yaml_tags"
}

# НОВАЯ функция: Выбор типа документа по уровню
select_document_type_by_level() {
    local level=$1
    local default_type=$2
    
    case $level in
        1)
            echo ""
            echo "=== ВЫБОР ТИПА ДОКУМЕНТА (Уровень 1) ==="
            echo "1 - project (Проект)"
            echo "2 - line (Линия развития)"
            echo ""
            read -p "Выберите тип (1-2, по умолчанию: $default_type): " type_choice
            
            case $type_choice in
                1) echo "project" ;;
                2) echo "line" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        
        2)
            echo ""
            echo "=== ВЫБОР ТИПА ДОКУМЕНТА (Уровень 2) ==="
            echo "1 - component (Компонент системы)"
            echo "2 - module (Модуль/Блок)"
            echo "3 - epic (Эпик - крупная функциональность)"
            echo ""
            read -p "Выберите тип (1-3, по умолчанию: $default_type): " type_choice
            
            case $type_choice in
                1) echo "component" ;;
                2) echo "module" ;;
                3) echo "epic" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        
        3)
            echo ""
            echo "=== ВЫБОР ТИПА ДОКУМЕНТА (Уровень 3) ==="
            echo "1 - task (Задача)"
            echo "2 - feature (Функциональность)"
            echo "3 - user_story (Пользовательская история)"
            echo "4 - bug (Ошибка/Баг)"
            echo "5 - инцидент (Инцидент)"
            echo "6 - snapshot (Снимок системы)"
            echo ""
            read -p "Выберите тип (1-6, по умолчанию: $default_type): " type_choice
            
            case $type_choice in
                1) echo "task" ;;
                2) echo "feature" ;;
                3) echo "user_story" ;;
                4) echo "bug" ;;
                5) echo "инцидент" ;;
                6) echo "snapshot" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        
        4)
            echo ""
            echo "=== ВЫБОР ТИПА ДОКУМЕНТА (Уровень 4) ==="
            echo "1 - solution (Техническое решение)"
            echo "2 - subtask (Подзадача)"
            echo "3 - code_block (Блок кода)"
            echo "4 - decision (Архитектурное решение)"
            echo ""
            read -p "Выберите тип (1-4, по умолчанию: $default_type): " type_choice
            
            case $type_choice in
                1) echo "solution" ;;
                2) echo "subtask" ;;
                3) echo "code_block" ;;
                4) echo "decision" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        
        *)
            # Уровень N или неиерархический
            echo ""
            echo "=== ВЫБОР ТИПА НЕИЕРАРХИЧЕСКОГО ДОКУМЕНТА ==="
            echo "1 - idea (Идея/Концепция)"
            echo "2 - reference (Ссылка/Ресурс)"
            echo "3 - meeting (Встреча/Обсуждение)"
            echo ""
            read -p "Выберите тип (1-3, по умолчанию: $default_type): " type_choice
            
            case $type_choice in
                1) echo "idea" ;;
                2) echo "reference" ;;
                3) echo "meeting" ;;
                *) echo "$default_type" ;;
            esac
            ;;
    esac
}

# НОВАЯ функция: Генерация ID для неиерархических документов
generate_non_hierarchical_id() {
    local type=$1
    
    case $type in
        "idea")
            echo "Z-$(date +%Y%m%d%H%M%S)"  # Z-префикс + временная метка
            ;;
        "reference")
            # Генерация случайного 6-символьного HEX в верхнем регистре
            random_hex=$(openssl rand -hex 3 | tr '[:lower:]' '[:upper:]')
            echo "R-$random_hex"
            ;;
        "meeting")
            echo "M-$(date +%Y%m%d)"  # M-префикс + дата
            ;;
        *)
            # По умолчанию идея
            echo "Z-$(date +%Y%m%d%H%M%S)"
            ;;
    esac
}

# Главная функция создания документа
create_document() {
    local mode="$1"
    local parent_id="$2"
    local doc_name="$3"
    local tags_input="$4"
    local type_input="$5"  # Явно указанный тип
    local manual_id="$6"
    
    echo ""
    echo "=== СОЗДАНИЕ ДОКУМЕНТА ==="
    
    # Специальный случай: неиерархический режим
    if [ "$mode" = "non_hierarchical" ]; then
        echo "Создание неиерархического документа"
        
        # Выбор типа
        selected_type=$(select_document_type_by_level "N" "idea")
        
        # Генерация ID
        DOC_ID=$(generate_non_hierarchical_id "$selected_type")
        LEVEL="N"
        
        # Имя файла
        FILENAME="${DOC_ID} - ${doc_name}.md"
        
        echo "ID: $DOC_ID"
        echo "Тип: $selected_type"
        echo "Уровень: $LEVEL"
        echo "Название: $doc_name"
        echo "Файл: $FILENAME"
        echo ""
        
        # Запрашиваем подтверждение
        read -p "Создать документ? (y/n): " CONFIRM
        
        if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
            echo "Отменено."
            return 0
        fi
        
        # Создаем документ с соответствующим шаблоном
        case $selected_type in
            "idea")
                create_idea_document "$DOC_ID" "$doc_name" "$tags_input"
                ;;
            "reference")
                create_reference_document "$DOC_ID" "$doc_name" "$tags_input"
                ;;
            "meeting")
                create_meeting_document "$DOC_ID" "$doc_name" "$tags_input"
                ;;
            *)
                create_idea_document "$DOC_ID" "$doc_name" "$tags_input"
                ;;
        esac
        
        echo "✅ Создан неиерархический документ: $FILENAME"
        return 0
    fi
    
    # Стандартная логика для иерархических документов
    if [ "$mode" = "manual" ] && [ -n "$manual_id" ]; then
        # Ручной режим
        if find . -maxdepth 1 -name "${manual_id} - *.md" -type f | grep -q .; then
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
            if ! find . -maxdepth 1 -name "${parent_id} - *.md" -type f | grep -q .; then
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
    
    # Определяем тип документа
    if [ -n "$type_input" ]; then
        # Используем явно указанный тип
        TYPE="$type_input"
    else
        # Выбираем тип на основе уровня с пользовательским выбором
        case $LEVEL in
            1) default_type="project" ;;
            2) default_type="component" ;;
            3) default_type="task" ;;
            4) default_type="solution" ;;
            *) default_type="task" ;;
        esac
        
        TYPE=$(select_document_type_by_level $LEVEL "$default_type")
    fi
    
    # Форматируем теги
    TAGS_YAML=$(format_tags_yaml "$tags_input" "$TYPE")
    
    # Имя файла
    FILENAME="${DOC_ID} - ${doc_name}.md"
    
    echo "ID: $DOC_ID"
    echo "Уровень: $LEVEL"
    echo "Название: $doc_name"
    echo "Тип: $TYPE"
    echo "Родитель: $parent_id ($PARENT_NAME)"
    echo "Файл: $FILENAME"
    echo ""
    
    # Запрашиваем подтверждение
    read -p "Создать документ? (y/n): " CONFIRM
    
    if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
        echo "Отменено."
        return 0
    fi
    
    # Создаем документ
    create_hierarchical_document "$DOC_ID" "$doc_name" "$LEVEL" "$TYPE" "$parent_id" "$PARENT_NAME" "$TAGS_YAML"
    
    echo ""
    echo "=== ВЫПОЛНЕНО ==="
    echo "Документ: $FILENAME"
    echo "ID: $DOC_ID"
    echo "Уровень: $LEVEL"
    echo "Тип: $TYPE"
}

# НОВАЯ функция: Создание иерархического документа
create_hierarchical_document() {
    local doc_id="$1"
    local doc_name="$2"
    local level="$3"
    local type="$4"
    local parent_id="$5"
    local parent_name="$6"
    local tags_yaml="$7"
    
    local filename="${doc_id} - ${doc_name}.md"
    
    # Базовый frontmatter
    cat > "$filename" << DOC_EOF
---
id: "$doc_id"
name: "$doc_name"
type: "$type"
level: $level
status: "planning"
$(echo "$tags_yaml")
created: "$CURRENT_DATE"
updated: "$CURRENT_DATE"
author: "$USER"
---

### $doc_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Уровень**: $level
DOC_EOF
    
    # Добавляем родительскую информацию для дочерних документов
    if [ -n "$parent_id" ] && [ -n "$parent_name" ]; then
        cat >> "$filename" << DOC_EOF
- **Родитель**: [[$parent_id - $parent_name]]
DOC_EOF
    fi
    
    # Тип-специфичный контент
    case $type in
        "инцидент")
            cat >> "$filename" << INCIDENT_EOF
- **Статус**: Активный
- **Создано**: \`$CURRENT_DATE\`
- **Тип инцидента**: Инцидент

#### 📋 ОПИСАНИЕ ИНЦИДЕНТА

**Время обнаружения**: $(date +"%Y-%m-%d %H:%M")
**Серьезность**: [🔴 Критический/🟡 Высокий/🟢 Средний/⚪ Низкий]
**Влияние**: 
**Ответственный**: 

#### 🔍 ПРИЧИНА
- 

#### 🛠️ РЕШЕНИЕ
- 

#### ✅ ВОССТАНОВЛЕНИЕ
- [ ] Идентифицирована причина
- [ ] Применено решение
- [ ] Проверена работоспособность
- [ ] Документировано решение
- [ ] Обновлены процедуры

#### 📝 КОММЕНТАРИИ
- 
INCIDENT_EOF
            ;;
        
        "snapshot")
            cat >> "$filename" << SNAPSHOT_EOF
- **Статус**: Активный
- **Создано**: \`$CURRENT_DATE\`
- **Тип документа**: Снимок системы

#### 📊 СТАТУС СИСТЕМЫ

### ✅ РАБОТАЕТ:
- 

### ⚠️ ПРОБЛЕМЫ:
- 

### 🔧 ТЕХНИЧЕСКИЕ ДЕТАЛИ:
- **Версия системы**: 
- **Количество документов**: 
- **Активные задачи**: 
- **Завершенные задачи**: 

#### 🎯 МЕТРИКИ
- 

#### 📈 ТЕНДЕНЦИИ
- 

#### 🔮 ПЛАНЫ
- 
SNAPSHOT_EOF
            ;;
        
        "subtask")
            cat >> "$filename" << SUBTASK_EOF
- **Статус**: Планирование
- **Создано**: \`$CURRENT_DATE\`
- **Тип документа**: Подзадача

#### 📝 ОПИСАНИЕ
Добавьте описание подзадачи здесь.

#### 🎯 КРИТЕРИИ ЗАВЕРШЕНИЯ
- [ ] 
- [ ] 
- [ ] 

#### ⏱️ ОЦЕНКА ВРЕМЕНИ
- **Оптимистично**: 
- **Реалистично**: 
- **Пессимистично**: 

#### 🔗 ЗАВИСИМОСТИ
- 

#### 📎 ПРИЛОЖЕНИЯ
- 
SUBTASK_EOF
            ;;
        
        *)
            # Стандартный шаблон для остальных типов
            cat >> "$filename" << STANDARD_EOF
- **Статус**: Планирование
- **Создано**: \`$CURRENT_DATE\`

#### ОПИСАНИЕ
Добавьте описание здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2
STANDARD_EOF
            ;;
    esac
    
    # Общая завершающая часть
    cat >> "$filename" << FOOTER_EOF

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $CURRENT_DATE
Уровень: $level
FOOTER_EOF
    
    # Добавляем родителя в конец для дочерних документов
    if [ -n "$parent_id" ]; then
        echo "Родитель: $parent_id" >> "$filename"
    fi
    
    echo "✅ Документ создан: $filename"
    
    # Обновляем родительский документ (если есть)
    if [ -n "$parent_id" ] && [ -n "$parent_name" ] && [ -n "$parent_file" ]; then
        update_parent_document "$parent_file" "$doc_id" "$doc_name"
    fi
}

# Функции для неиерархических документов
create_idea_document() {
    local doc_id="$1"
    local doc_name="$2"
    local tags_input="$3"
    
    local filename="${doc_id} - ${doc_name}.md"
    
    # Форматируем теги (для неиерархических)
    TAGS_YAML="tags:"
    TAGS_YAML="$TAGS_YAML"$'\n'"  - \"idea\""
    if [ -n "$tags_input" ]; then
        IFS=',' read -r -a tag_parts <<< "$tags_input"
        for tag in "${tag_parts[@]}"; do
            tag_clean=$(echo "$tag" | xargs | sed 's/^[@#]//')
            if [ -n "$tag_clean" ] && [ "$tag_clean" != "idea" ]; then
                TAGS_YAML="$TAGS_YAML"$'\n'"  - \"$tag_clean\""
            fi
        done
    fi
    
    cat > "$filename" << IDEA_EOF
---
id: "$doc_id"
name: "$doc_name"
type: "idea"
level: "N"
status: "planning"
$(echo "$TAGS_YAML")
created: "$CURRENT_DATE"
updated: "$CURRENT_DATE"
author: "$USER"
---

### $doc_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Тип**: Идея/Концепция
- **Уровень**: N (неиерархический)
- **Статус**: Планирование
- **Создано**: \`$CURRENT_DATE\`

#### 💡 ОПИСАНИЕ ИДЕИ

#### 🎯 ЦЕЛЬ
- 

#### 🔍 ПРОБЛЕМА
- 

#### 🛠️ РЕШЕНИЕ
- 

#### 🔗 СВЯЗИ
- Связанные документы: 

#### 📝 ЗАМЕТКИ
- 

---
Создано: $CURRENT_DATE
IDEA_EOF
}

create_reference_document() {
    local doc_id="$1"
    local doc_name="$2"
    local tags_input="$3"
    
    local filename="${doc_id} - ${doc_name}.md"
    
    # Форматируем теги
    TAGS_YAML="tags:"
    TAGS_YAML="$TAGS_YAML"$'\n'"  - \"reference\""
    if [ -n "$tags_input" ]; then
        IFS=',' read -r -a tag_parts <<< "$tags_input"
        for tag in "${tag_parts[@]}"; do
            tag_clean=$(echo "$tag" | xargs | sed 's/^[@#]//')
            if [ -n "$tag_clean" ] && [ "$tag_clean" != "reference" ]; then
                TAGS_YAML="$TAGS_YAML"$'\n'"  - \"$tag_clean\""
            fi
        done
    fi
    
    cat > "$filename" << REFERENCE_EOF
---
id: "$doc_id"
name: "$doc_name"
type: "reference"
level: "N"
status: "planning"
$(echo "$TAGS_YAML")
created: "$CURRENT_DATE"
updated: "$CURRENT_DATE"
author: "$USER"
---

### $doc_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Тип**: Ссылка/Ресурс
- **Уровень**: N (неиерархический)
- **Статус**: Планирование
- **Создано**: \`$CURRENT_DATE\`

#### 🔗 ИСТОЧНИК
- **URL**: 
- **Автор**: 
- **Дата публикации**: 
- **Тип ресурса**: [Статья/Документация/Книга/Видео/Код/Другое]

#### 📝 КРАТКОЕ ОПИСАНИЕ

#### 💡 КЛЮЧЕВЫЕ МОМЕНТЫ
- 

#### 🔗 СВЯЗИ
- Связанные документы: 

#### 📎 ПРИЛОЖЕНИЯ
- 

---
Создано: $CURRENT_DATE
REFERENCE_EOF
}

create_meeting_document() {
    local doc_id="$1"
    local doc_name="$2"
    local tags_input="$3"
    
    local filename="${doc_id} - ${doc_name}.md"
    
    # Форматируем теги
    TAGS_YAML="tags:"
    TAGS_YAML="$TAGS_YAML"$'\n'"  - \"meeting\""
    if [ -n "$tags_input" ]; then
        IFS=',' read -r -a tag_parts <<< "$tags_input"
        for tag in "${tag_parts[@]}"; do
            tag_clean=$(echo "$tag" | xargs | sed 's/^[@#]//')
            if [ -n "$tag_clean" ] && [ "$tag_clean" != "meeting" ]; then
                TAGS_YAML="$TAGS_YAML"$'\n'"  - \"$tag_clean\""
            fi
        done
    fi
    
    cat > "$filename" << MEETING_EOF
---
id: "$doc_id"
name: "$doc_name"
type: "meeting"
level: "N"
status: "planning"
$(echo "$TAGS_YAML")
created: "$CURRENT_DATE"
updated: "$CURRENT_DATE"
author: "$USER"
---

### $doc_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Тип**: Встреча/Обсуждение
- **Уровень**: N (неиерархический)
- **Статус**: Планирование
- **Создано**: \`$CURRENT_DATE\`

#### 📅 ИНФОРМАЦИЯ О ВСТРЕЧЕ
- **Дата**: 
- **Время**: 
- **Место/Платформа**: 
- **Участники**: 

#### 🎯 ЦЕЛИ ВСТРЕЧИ
- 

#### 📝 ПОВЕСТКА
1. 
2. 
3. 

#### ✅ РЕШЕНИЯ И ВЫВОДЫ
- 

#### 📋 ЗАДАЧИ
- [ ] 
- [ ] 
- [ ] 

#### 🔗 СВЯЗАННЫЕ ДОКУМЕНТЫ
- 

#### 📝 ЗАМЕТКИ
- 

---
Создано: $CURRENT_DATE
MEETING_EOF
}

# Улучшенный интерактивный режим
simple_interactive_mode() {
    echo ""
    echo "=== РЕЖИМ СОЗДАНИЯ ДОКУМЕНТА ==="
    echo "1 - Мастер-документ (уровень 1, корневой)"
    echo "2 - Дочерний документ (уровень 2+)"
    echo "3 - Документ с ручным указанием ID"
    echo "4 - Неиерархический документ (идеи, ссылки, встречи)"
    read -p "Ваш выбор (1-4): " choice
    
    case $choice in
        1)
            echo ""
            echo "Введите название документа:"
            read -r doc_name
            
            if [ -z "$doc_name" ]; then
                echo "❌ Ошибка: название не может быть пустым"
                return 1
            fi
            
            echo "Введите теги через запятую (можно оставить пустым):"
            read -r tags_input
            
            create_document "auto" "" "$doc_name" "$tags_input" ""
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
            
            create_document "auto" "$parent_id" "$doc_name" "$tags_input" ""
            ;;
        
        3)
            echo ""
            echo "=== РУЧНОЙ РЕЖИМ ID ==="
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
            
            echo "Введите ID родителя (или оставьте пустым, если ID содержит parent):"
            read -r parent_id
            
            echo "Введите теги через запятую:"
            read -r tags_input
            
            echo "Введите тип документа (оставьте пустым для выбора из меню):"
            read -r doc_type_input
            
            create_document "manual" "$parent_id" "$doc_name" "$tags_input" "$doc_type_input" "$manual_id"
            ;;
        
        4)
            echo ""
            echo "=== НЕИЕРАРХИЧЕСКИЙ ДОКУМЕНТ ==="
            echo "Введите название документа:"
            read -r doc_name
            
            if [ -z "$doc_name" ]; then
                echo "❌ Ошибка: название не может быть пустым"
                return 1
            fi
            
            echo "Введите теги через запятую (можно оставить пустым):"
            read -r tags_input
            
            create_document "non_hierarchical" "" "$doc_name" "$tags_input" "" ""
            ;;
        
        *)
            echo "❌ Неверный выбор"
            return 1
            ;;
    esac
}

# Режим командной строки
if [ $# -gt 0 ]; then
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
            --non-hierarchical|-n)
                MODE="non_hierarchical"
                shift
                ;;
            --interactive|-i)
                simple_interactive_mode
                exit 0
                ;;
            *)
                echo "Неизвестный аргумент: $1"
                echo "Использование:"
                echo "  ./uch-create-unified-fixed.sh --interactive (интерактивный режим)"
                echo "  ./uch-create-unified-fixed.sh --parent ID --name NAME [--tags TAGS] [--type TYPE]"
                echo "  ./uch-create-unified-fixed.sh --manual-id ID --name NAME [--parent ID] [--tags TAGS] [--type TYPE]"
                echo "  ./uch-create-unified-fixed.sh --non-hierarchical --name NAME [--tags TAGS]"
                exit 1
                ;;
        esac
    done
    
    if [ -z "$NAME" ]; then
        echo "❌ Ошибка: необходимо указать --name"
        exit 1
    fi
    
    if [ "$MODE" = "non_hierarchical" ]; then
        create_document "$MODE" "" "$NAME" "$TAGS" "" ""
    else
        create_document "$MODE" "$PARENT_ID" "$NAME" "$TAGS" "$TYPE" "$MANUAL_ID"
    fi
else
    # Интерактивный режим по умолчанию
    simple_interactive_mode
fi