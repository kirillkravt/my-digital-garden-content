#!/bin/bash

echo "=== UCH - УНИВЕРСАЛЬНЫЙ СКРИПТ СОЗДАНИЯ ДОКУМЕНТОВ ==="

# Функция для поиска первого свободного ID для мастер-документов
find_free_master_id() {
    # Ищем все мастер-файлы (уровень 1)
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E '^\./[0-9A-Fa-f]{2} - ' | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        sort | uniq)
    
    # Если нет файлов, начинаем с 00
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

# Функция для поиска первого свободного дочернего ID
find_free_child_id() {
    local parent_id="$1"
    
    # Ищем все файлы, которые начинаются с parent_id-
    pattern="${parent_id}-[0-9A-Fa-f][0-9A-Fa-f]"
    
    # Получаем список всех дочерних ID
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E "^\./${pattern} - " | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        grep -E "^${parent_id}-[0-9A-Fa-f]{2}$" | \
        awk -F"${parent_id}-" '{print $2}' | \
        sort | uniq)
    
    # Если нет дочерних файлов, начинаем с 01
    if [ -z "$existing_ids" ]; then
        echo "01"
        return
    fi
    
    # Конвертируем hex ID в decimal и находим пропуски
    declare -a dec_array=()
    for hex_id in $existing_ids; do
        dec_id=$((16#$hex_id))
        dec_array+=($dec_id)
    done
    
    # Сортируем массив чисел
    sorted_array=($(printf "%d\n" "${dec_array[@]}" | sort -n))
    
    # Ищем первый пропуск, начиная с 1
    expected=1
    for id in "${sorted_array[@]}"; do
        if [ $id -gt $expected ]; then
            break
        fi
        expected=$((id + 1))
    done
    
    printf "%02X" $expected
}

# Функция для добавления ссылки в родительский документ (ИСПРАВЛЕННАЯ)
update_parent_document() {
    local parent_file="$1"
    local child_id="$2"
    local child_name="$3"
    
    echo "  Обновляю родительский документ: $(basename "$parent_file")"
    
    if [ ! -f "$parent_file" ]; then
        echo "  ⚠️  Родительский файл не найден, пропускаю обновление"
        return 1
    fi
    
    # Создаем временный файл
    temp_file="${parent_file}.tmp"
    
    # Флаг для отслеживания, добавили ли мы ссылку
    link_added=0
    
    # Читаем файл построчно и обрабатываем
    awk -v child_id="$child_id" -v child_name="$child_name" '
    BEGIN { 
        in_children_section = 0
        children_section_found = 0
        link_exists = 0
        link_added = 0
    }
    
    # Проверяем, не существует ли уже такая ссылка
    /\[\[.* - .*\]\]/ && in_children_section {
        if ($0 ~ "\\[\\[" child_id " - " child_name "\\]\\]") {
            link_exists = 1
            print "  ℹ️  Ссылка уже существует, пропускаю" > "/dev/stderr"
        }
    }
    
    # Если находим начало раздела ДОЧЕРНИЕ ДОКУМЕНТЫ
    /#### ДОЧЕРНИЕ ДОКУМЕНТЫ/ {
        in_children_section = 1
        children_section_found = 1
        print $0
        next
    }
    
    # Если мы внутри раздела и находим "Пока нет дочерних документов" - пропускаем
    in_children_section && /^[[:space:]]*Пока нет дочерних документов/ {
        # Пропускаем эту строку
        next
    }
    
    # Если мы внутри раздела и находим новый раздел - выходим из раздела
    in_children_section && (/^####/ || /^###/ || /^##/ || /^#/ || /^---/) {
        in_children_section = 0
    }
    
    # Если мы внутри раздела и это пустая строка
    in_children_section && /^[[:space:]]*$/ {
        # Если ссылка еще не добавлена и не существует
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    # Если мы внутри раздела и это конец файла
    in_children_section && /^---/ {
        # Если ссылка еще не добавлена и не существует
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    # Если мы в конце раздела ДОЧЕРНИЕ ДОКУМЕНТЫ (последняя строка раздела)
    in_children_section && !/^- \[\[/ && !/^[[:space:]]*$/ {
        # Если это не ссылка и не пустая строка, значит конец списка ссылок
        # Добавляем новую ссылку перед выходом из раздела
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    # Печатаем текущую строку
    { print $0 }
    
    END {
        # Если раздел не найден, добавляем его
        if (!children_section_found) {
            print ""
            print "#### ДОЧЕРНИЕ ДОКУМЕНТЫ"
            print "- [[" child_id " - " child_name "]]"
        } else if (!link_exists && !link_added) {
            # Если раздел найден, но ссылка не добавлена (случай когда нет пустой строки в конце)
            print "- [[" child_id " - " child_name "]]"
        }
    }
    ' "$parent_file" > "$temp_file"
    
    # Заменяем оригинальный файл
    mv "$temp_file" "$parent_file"
    
    echo "  ✅ Ссылка добавлена в родительский документ"
}

# Функция для создания мастер-документа
create_master_document() {
    local doc_name="$1"
    local tags="$2"
    
    echo "Создание мастер-документа (уровень 1)"
    
        # Генерируем ID
    if [ -n "$MANUAL_ID" ]; then
        doc_id="$MANUAL_ID"
        echo "Используется ручной ID: $doc_id"
    else
        doc_id=$(find_free_master_id)
    fi
    echo "Сгенерирован ID: $doc_id"
    
    current_date=$(date +%Y-%m-%d)
    filename="${doc_id} - ${doc_name}.md"
    
    # Создаем массив тегов
    tags_array="[\"@project\""
    if [ -n "$tags" ]; then
        for tag in $tags; do
            tags_array="${tags_array}, \"@$tag\""
        done
    fi
    tags_array="${tags_array}]"
    
    # Создаем файл
    cat > "$filename" << EOF
---
id: "$doc_id"
name: "$doc_name"
type: "project"
level: 1
status: "active"
tags: $tags_array
parent: null
created: "$current_date"
updated: "$current_date"
author: "$USER"
---
### $doc_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Статус**: Активная разработка
- **Уровень**: 1
- **Создано**: \`$current_date\`
- **Теги**: $tags

#### ОПИСАНИЕ
Добавьте описание проекта здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $current_date
Система документирования UCH
EOF
    
    echo "✅ Создан мастер-документ: $filename"
}

# НОВАЯ функция для надежной очистки имени файла от ID
clean_parent_name() {
    local full_filename="$1"
    
    # Убираем расширение .md
    filename=$(basename "$full_filename" .md)
    
    echo "  Очистка имени из: $filename" >&2
    
    # Разделяем по " - " и берем все части кроме первой (ID)
    # Пример: "00-01 - 00-01 - Компонент" -> ["00-01", "00-01", "Компонент"]
    
    # Используем IFS для разделения
    OLD_IFS="$IFS"
    IFS=" - "
    parts=($filename)
    IFS="$OLD_IFS"
    
    # Проверяем сколько частей получилось
    if [ ${#parts[@]} -eq 0 ]; then
        echo "$filename"
        return
    fi
    
    # Первая часть - это всегда ID (или первый ID если их несколько)
    # Нам нужно проверить все части и оставить только те, которые НЕ являются ID
    
    clean_parts=()
    for part in "${parts[@]}"; do
        # Проверяем, является ли часть ID (hex формат с дефисами)
        if echo "$part" | grep -qE '^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*$'; then
            # Это ID - пропускаем
            continue
        else
            # Это не ID - добавляем в результат
            clean_parts+=("$part")
        fi
    done
    
    # Если после очистки ничего не осталось, возвращаем последний ID как имя
    if [ ${#clean_parts[@]} -eq 0 ]; then
        # Берем последнюю часть (последний ID) как имя
        last_part="${parts[-1]}"
        echo "$last_part"
    else
        # Собираем оставшиеся части обратно в строку
        clean_name=$(IFS=" - "; echo "${clean_parts[*]}")
        echo "$clean_name"
    fi
}

    # Генерируем ID
    if [ -n "$MANUAL_ID" ]; then
        doc_id="$MANUAL_ID"
        echo "Используется ручной ID: $doc_id"
        
        # Проверяем что manual-id начинается с parent_id
        if [[ ! "$doc_id" =~ ^$parent_id- ]]; then
            echo "⚠️  Внимание: manual-id '$doc_id' не начинается с parent-id '$parent_id'"
        fi
    else
        child_suffix=$(find_free_child_id "$parent_id")
        doc_id="${parent_id}-${child_suffix}"
    fi
    
    echo "Создание дочернего документа"
    
    # Проверяем существование родительского файла
    parent_file=$(find . -maxdepth 1 -name "${parent_id} - *.md" -type f | head -1)
    if [ -z "$parent_file" ]; then
        echo "❌ Ошибка: родительский файл с ID $parent_id не найден"
        exit 1
    fi
    
    # Получаем очищенное имя родителя
    parent_name=$(clean_parent_name "$parent_file")
    
    echo "Родительский файл: $(basename "$parent_file")"
    echo "Очищенное имя родителя: $parent_name"
    
    # Определяем уровень
    level=$(echo "$parent_id" | tr -cd '-' | wc -c)
    level=$((level + 2))
    
    # Генерируем ID
    child_suffix=$(find_free_child_id "$parent_id")
    doc_id="${parent_id}-${child_suffix}"
    
    echo "Родитель: $parent_name ($parent_id)"
    echo "Уровень: $level"
    echo "Сгенерирован ID: $doc_id"
    
    current_date=$(date +%Y-%m-%d)
    filename="${doc_id} - ${doc_name}.md"
    
    # Определяем тип по уровню
    case $level in
        2|3) doc_type="component" ;;
        *) doc_type="task" ;;
    esac
    
    # Создаем массив тегов
    tags_array="[\"@$doc_type\""
    if [ -n "$tags" ]; then
        for tag in $tags; do
            tags_array="${tags_array}, \"@$tag\""
        done
    fi
    tags_array="${tags_array}]"
    
    # Создаем файл
    cat > "$filename" << EOF
---
id: "$doc_id"
name: "$doc_name"
type: "$doc_type"
level: $level
status: "active"
tags: $tags_array
parent: "$parent_id"
parent_name: "$parent_name"
created: "$current_date"
updated: "$current_date"
author: "$USER"
---
### $doc_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Уровень**: $level
- **Родитель**: [[$parent_id - $parent_name]]
- **Статус**: Активная разработка
- **Создано**: \`$current_date\`
- **Теги**: $tags

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
Родитель: $parent_id
EOF
    
    # Обновляем родительский документ
    echo "Обновляю родительский документ..."
    update_parent_document "$parent_file" "$doc_id" "$doc_name"
    
    echo "✅ Создан дочерний документ: $filename"
}

# Парсинг аргументов командной строки
MANUAL_ID=""
FORCE_PARENT=""
DOC_NAME=""
PARENT_ID=""
DOC_TAGS=""
DOC_TYPE=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            DOC_NAME="$2"
            shift 2
            ;;
        --parent)
            PARENT_ID="$2"
            shift 2
            ;;
        --tags)
            DOC_TAGS="$2"
            shift 2
            ;;
        --manual-id)
            MANUAL_ID="$2"
            shift 2
            ;;
        --force-parent)
            FORCE_PARENT="$2"
            shift 2
            ;;
        *)
            echo "Неизвестный параметр: $1"
            exit 1
            ;;
    esac
done

# Определяем тип документа на основе параметров
if [ -n "$DOC_NAME" ]; then
    if [ -n "$PARENT_ID" ]; then
        DOC_TYPE="2"  # Дочерний
    else
        DOC_TYPE="1"  # Мастер (даже если есть MANUAL_ID без PARENT_ID)
    fi
    echo "Автоматически определен тип: $DOC_TYPE"
fi

# Основная логика
echo "=== ДЕБАГ ПЕРЕД ЛОГИКОЙ ==="
echo "DOC_NAME='$DOC_NAME'"
echo "PARENT_ID='$PARENT_ID'" 
echo "MANUAL_ID='$MANUAL_ID'"
echo "DOC_TYPE='$DOC_TYPE'"
echo "DOC_TAGS='$DOC_TAGS'"
echo "=== КОНЕЦ ДЕБАГА ==="

if [ -n "$DOC_NAME" ]; then
    # Режим с параметрами
    echo "Создание документа с параметрами"
    
    if [ "$DOC_TYPE" = "1" ]; then
        # Мастер-документ
        create_master_document "$DOC_NAME" "$DOC_TAGS"
    elif [ "$DOC_TYPE" = "2" ]; then
        # Дочерний документ
        create_child_document "$PARENT_ID" "$DOC_NAME" "$DOC_TAGS"
    else
        echo "❌ Ошибка: неопределённый тип документа"
        exit 1
    fi
else
    # Интерактивный режим (старый)
    echo ""
    echo "Выберите тип документа:"
    echo "1 - Мастер-документ (уровень 1, корневой)"
    echo "2 - Дочерний документ (уровень 2+)"
    read -p "Ваш выбор (1 или 2): " doc_type

case $doc_type in
    1)
        # Создание мастер-документа
        echo ""
        echo "--- СОЗДАНИЕ МАСТЕР-ДОКУМЕНТА ---"
        echo ""
        echo "Введите название проекта:"
        read doc_name
        
        if [ -z "$doc_name" ]; then
            echo "Ошибка: название не может быть пустым"
            exit 1
        fi
        
        echo "Введите теги через пробел (можно оставить пустым):"
        read doc_tags
        
        echo ""
        create_master_document "$doc_name" "$doc_tags"
        ;;
    
    2)
        # Создание дочернего документа
        echo ""
        echo "--- СОЗДАНИЕ ДОЧЕРНЕГО ДОКУМЕНТА ---"
        echo ""
        echo "Введите ID родительского документа (например: 00 или 00-01):"
        read parent_id
        
        if [ -z "$parent_id" ]; then
            echo "Ошибка: ID родителя не может быть пустым"
            exit 1
        fi
        
        echo "Введите название документа:"
        read doc_name
        
        if [ -z "$doc_name" ]; then
            echo "Ошибка: название не может быть пустым"
            exit 1
        fi
        
        echo "Введите теги через пробел (можно оставить пустым):"
        read doc_tags
        
        echo ""
        create_child_document "$parent_id" "$doc_name" "$doc_tags"
        ;;
    
    *)
        echo "Ошибка: неверный выбор"
        exit 1
        ;;
esac

echo ""
echo "=== ВЫПОЛНЕНО ==="