#!/bin/bash

echo "=== UCH CREATE v2: СОЗДАНИЕ ДОКУМЕНТОВ С РУЧНЫМ ID ==="

# Получаем текущую дату
CURRENT_DATE=$(date +%Y-%m-%d)

# Функция для проверки существующего ID
check_id_exists() {
    local id="$1"
    find . -maxdepth 1 -name "${id} - *.md" -type f | grep -q .
    return $?
}

# Функция для генерации HEX ID
generate_hex() {
    local length="$1"
    local hex=""
    for ((i=0; i<length; i++)); do
        hex="${hex}$(printf "%02X" $((RANDOM % 256)))"
    done
    echo "$hex" | cut -c1-2
}

# Функция для генерации ID уровня
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
            # Первый документ
            echo "00"
        else
            # Увеличиваем HEX на 1
            next_id=$(printf "%02X" $((0x$max_id + 1)))
            echo "$next_id"
        fi
        return 0
    fi
    
    # Для уровней 2+
    # Ищем максимальный дочерний ID
    pattern="${parent_id}-[0-9A-Fa-f]\{2\}"
    max_child=$(find . -maxdepth 1 -name "*${parent_id}-?? - *.md" -type f | \
        grep -o "${pattern}" | \
        sort -r | head -1 | \
        tr 'a-f' 'A-F')
    
    if [ -z "$max_child" ]; then
        # Первый дочерний
        echo "${parent_id}-00"
    else
        # Извлекаем последний сегмент и увеличиваем
        last_segment=$(echo "$max_child" | grep -o '[^-]*$')
        next_segment=$(printf "%02X" $((0x$last_segment + 1)))
        echo "${parent_id}-${next_segment}"
    fi
}

# Функция для корректного форматирования тегов
format_tags() {
    local tags_input="$1"
    local type="$2"
    
    # Начинаем с типа документа как первого тега
    local tags_array="[\"@${type}\""
    
    if [ -n "$tags_input" ]; then
        # Разделяем теги по запятым
        IFS=',' read -r -a tag_parts <<< "$tags_input"
        
        for tag in "${tag_parts[@]}"; do
            # Убираем пробелы и добавляем @ если нет
            tag_clean=$(echo "$tag" | xargs)
            if [ -n "$tag_clean" ]; then
                if [[ "$tag_clean" != @* ]]; then
                    tags_array="${tags_array}, \"@${tag_clean}\""
                else
                    tags_array="${tags_array}, \"${tag_clean}\""
                fi
            fi
        done
    fi
    
    tags_array="${tags_array}]"
    echo "$tags_array"
}

# Функция для извлечения имени родителя
get_parent_name() {
    local parent_id="$1"
    if [ -z "$parent_id" ]; then
        echo ""
        return
    fi
    
    parent_file=$(find . -maxdepth 1 -name "${parent_id} - *.md" -type f | head -1)
    if [ -n "$parent_file" ]; then
        # Извлекаем имя из frontmatter или имени файла
        if grep -q "name:" "$parent_file"; then
            grep "name:" "$parent_file" | head -1 | sed 's/^name:[[:space:]]*//' | sed 's/^"//' | sed 's/"$//'
        else
            # Из имени файла
            basename "$parent_file" .md | sed "s/^${parent_id} - //"
        fi
    else
        echo ""
    fi
}

# Парсим аргументы
MANUAL_ID=""
PARENT_ID=""
NAME=""
TAGS=""
AUTHOR="kirillkravcov"
TYPE="component"

while [[ $# -gt 0 ]]; do
    case $1 in
        --manual-id)
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
        --author)
            AUTHOR="$2"
            shift 2
            ;;
        --type)
            TYPE="$2"
            shift 2
            ;;
        *)
            echo "Неизвестный аргумент: $1"
            exit 1
            ;;
    esac
done

# Определяем режим работы
if [ -n "$MANUAL_ID" ]; then
    # Ручной режим
    echo "Режим: Ручное указание ID"
    
    # Проверяем, существует ли уже такой ID
    if check_id_exists "$MANUAL_ID"; then
        echo "❌ Ошибка: Документ с ID '$MANUAL_ID' уже существует!"
        exit 1
    fi
    
    DOC_ID="$MANUAL_ID"
    
    # Определяем уровень по ID
    LEVEL=$(echo "$DOC_ID" | tr -cd '-' | wc -c)
    LEVEL=$((LEVEL + 1))
    
    # Определяем parent_id (если не указан явно)
    if [ -z "$PARENT_ID" ] && [ $LEVEL -gt 1 ]; then
        PARENT_ID=$(echo "$DOC_ID" | sed 's/-[^-]*$//')
    fi
    
else
    # Автоматический режим
    echo "Режим: Автоматическая генерация ID"
    
    if [ -z "$PARENT_ID" ]; then
        echo "Для автоматического режима необходимо указать --parent"
        exit 1
    fi
    
    # Проверяем существование родителя
    if ! check_id_exists "$PARENT_ID"; then
        echo "❌ Ошибка: Родительский документ с ID '$PARENT_ID' не найден!"
        exit 1
    fi
    
    # Генерируем ID
    PARENT_LEVEL=$(echo "$PARENT_ID" | tr -cd '-' | wc -c)
    PARENT_LEVEL=$((PARENT_LEVEL + 1))
    LEVEL=$((PARENT_LEVEL + 1))
    
    DOC_ID=$(generate_id_for_level "$PARENT_ID" "$LEVEL")
fi

# Получаем имя родителя
PARENT_NAME=$(get_parent_name "$PARENT_ID")

# Если имя не указано, запрашиваем
if [ -z "$NAME" ]; then
    echo "Введите название документа:"
    read -r NAME
    
    if [ -z "$NAME" ]; then
        echo "❌ Ошибка: Название документа обязательно!"
        exit 1
    fi
fi

# Форматируем теги
FORMATTED_TAGS=$(format_tags "$TAGS" "$TYPE")

# Определяем шаблон
if [ -z "$PARENT_ID" ]; then
    # Мастер-документ
    TEMPLATE="master-template.md"
else
    # Дочерний документ
    TEMPLATE="child-template.md"
fi

if [ ! -f "$TEMPLATE" ]; then
    echo "❌ Ошибка: Шаблон '$TEMPLATE' не найден!"
    exit 1
fi

# Имя файла
FILENAME="${DOC_ID} - ${NAME}.md"

echo ""
echo "=== ПОДТВЕРЖДЕНИЕ ==="
echo "ID: $DOC_ID"
echo "Уровень: $LEVEL"
echo "Название: $NAME"
echo "Тип: $TYPE"
echo "Теги: $FORMATTED_TAGS"
echo "Родитель: $PARENT_ID ($PARENT_NAME)"
echo "Файл: $FILENAME"
echo ""

echo "Создать документ? (y/n)"
read -r CONFIRM

if [[ "$CONFIRM" != "y" && "$CONFIRM" != "Y" ]]; then
    echo "Отменено."
    exit 0
fi

# Создаем документ
cp "$TEMPLATE" "$FILENAME"

# Заменяем переменные в шаблоне
sed -i '' "s/{id}/$DOC_ID/g" "$FILENAME"
sed -i '' "s/{name}/$NAME/g" "$FILENAME"
sed -i '' "s/{type}/$TYPE/g" "$FILENAME"
sed -i '' "s/{level}/$LEVEL/g" "$FILENAME"
sed -i '' "s/{tags}/$FORMATTED_TAGS/g" "$FILENAME"
sed -i '' "s/{parent}/$PARENT_ID/g" "$FILENAME"
sed -i '' "s/{parent_name}/$PARENT_NAME/g" "$FILENAME"
sed -i '' "s/{date}/$CURRENT_DATE/g" "$FILENAME"
sed -i '' "s/{author}/$AUTHOR/g" "$FILENAME"

# Для мастер-документов обновляем раздел ДОЧЕРНИЕ ДОКУМЕНТЫ
if [ -z "$PARENT_ID" ]; then
    # Убираем строку "Пока нет дочерних документов" если есть
    sed -i '' '/Пока нет дочерних документов/d' "$FILENAME"
fi

echo "✅ Документ создан: $FILENAME"

# Обновляем родительский документ (если есть)
if [ -n "$PARENT_ID" ] && [ -n "$PARENT_NAME" ]; then
    PARENT_FILE="${PARENT_ID} - ${PARENT_NAME}.md"
    
    if [ -f "$PARENT_FILE" ]; then
        echo "Обновляю родительский документ: $PARENT_FILE"
        
        # Убираем строку "Пока нет дочерних документов" если есть
        sed -i '' '/Пока нет дочерних документов/d' "$PARENT_FILE"
        
        # Добавляем ссылку на новый документ в раздел ДОЧЕРНИЕ ДОКУМЕНТЫ
        if grep -q "#### ДОЧЕРНИЕ ДОКУМЕНТЫ" "$PARENT_FILE"; then
            # Раздел существует, добавляем ссылку
            sed -i '' "/#### ДОЧЕРНИЕ ДОКУМЕНТЫ/a\\
- [[$DOC_ID - $NAME]]" "$PARENT_FILE"
        else
            # Раздела нет, создаем его
            echo "" >> "$PARENT_FILE"
            echo "#### ДОЧЕРНИЕ ДОКУМЕНТЫ" >> "$PARENT_FILE"
            echo "- [[$DOC_ID - $NAME]]" >> "$PARENT_FILE"
        fi
        
        echo "✅ Родительский документ обновлен"
    fi
fi

echo ""
echo "=== ВЫПОЛНЕНО ==="
echo "Документ: $FILENAME"
echo "ID: $DOC_ID"
echo "Уровень: $LEVEL"
echo "Теги: $FORMATTED_TAGS"
