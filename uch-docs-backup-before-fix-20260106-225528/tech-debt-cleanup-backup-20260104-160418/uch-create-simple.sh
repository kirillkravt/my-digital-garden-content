#!/bin/bash

echo "=== UCH CREATE SIMPLE: СОЗДАНИЕ ДОКУМЕНТОВ С ПРАВИЛЬНЫМИ ТЕГАМИ ==="

CURRENT_DATE=$(date +%Y-%m-%d)

# Базовые параметры
PARENT_ID="$1"
NAME="$2"
TAGS="$3"
TYPE="${4:-component}"
AUTHOR="kirillkravcov"

if [ -z "$PARENT_ID" ] || [ -z "$NAME" ]; then
    echo "Использование: ./uch-create-simple.sh <parent_id> <name> [tags] [type]"
    echo "Пример: ./uch-create-simple.sh 00-04 \"Новая задача\" \"bug,test\" task"
    exit 1
fi

# Генерируем ID (простой вариант)
if [[ "$PARENT_ID" =~ ^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*$ ]]; then
    # Находим следующий дочерний ID
    last_child=$(find . -maxdepth 1 -name "${PARENT_ID}-*.md" -type f | \
        grep -o "${PARENT_ID}-[0-9A-Fa-f]\{2\}" | \
        sort -r | head -1)
    
    if [ -z "$last_child" ]; then
        DOC_ID="${PARENT_ID}-00"
    else
        last_num=$(echo "$last_child" | grep -o '[^-]*$')
        # Конвертируем HEX в десятичное, увеличиваем, обратно в HEX
        dec_num=$((0x$last_num + 1))
        next_num=$(printf "%02X" $dec_num)
        DOC_ID="${PARENT_ID}-${next_num}"
    fi
else
    echo "❌ Неверный формат parent_id: $PARENT_ID"
    exit 1
fi

# Получаем имя родителя
PARENT_NAME=""
PARENT_FILE=$(find . -maxdepth 1 -name "${PARENT_ID} - *.md" -type f | head -1)
if [ -n "$PARENT_FILE" ]; then
    PARENT_NAME=$(basename "$PARENT_FILE" .md | sed "s/^${PARENT_ID} - //")
fi

# Определяем уровень
LEVEL=$(echo "$DOC_ID" | tr -cd '-' | wc -c)
LEVEL=$((LEVEL + 1))

# Форматируем теги
YAML_TAGS=""
if [ -n "$TAGS" ]; then
    # Разделяем теги
    IFS=',' read -ra TAG_ARRAY <<< "$TAGS"
    
    # Создаем YAML блок
    YAML_TAGS="tags:"
    YAML_TAGS="$YAML_TAGS"$'\n'"  - \"$TYPE\""
    
    for tag in "${TAG_ARRAY[@]}"; do
        tag_clean=$(echo "$tag" | xargs | sed 's/^[@#]//')
        if [ -n "$tag_clean" ]; then
            YAML_TAGS="$YAML_TAGS"$'\n'"  - \"$tag_clean\""
        fi
    done
else
    YAML_TAGS="tags:"$'\n'"  - \"$TYPE\""
fi

# Имя файла
FILENAME="${DOC_ID} - ${NAME}.md"

echo "Создаю документ: $FILENAME"
echo "ID: $DOC_ID"
echo "Уровень: $LEVEL"
echo "Тип: $TYPE"
echo "Родитель: $PARENT_ID ($PARENT_NAME)"
echo ""

# Создаем документ
cat > "$FILENAME" << DOC_EOF
---
id: "$DOC_ID"
name: "$NAME"
type: "$TYPE"
level: $LEVEL
status: "planning"
$(echo "$YAML_TAGS")
parent: "$PARENT_ID"
parent_name: "$PARENT_NAME"
created: "$CURRENT_DATE"
updated: "$CURRENT_DATE"
author: "$AUTHOR"
---

### ОПИСАНИЕ
Добавьте описание здесь.

### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.
DOC_EOF

echo "✅ Документ создан: $FILENAME"

# Обновляем родительский документ
if [ -f "$PARENT_FILE" ]; then
    echo "Обновляю родительский документ: $PARENT_FILE"
    
    # Убираем "Пока нет дочерних документов"
    sed -i '' '/Пока нет дочерних документов/d' "$PARENT_FILE"
    
    # Добавляем ссылку
    if grep -q "#### ДОЧЕРНИЕ ДОКУМЕНТЫ" "$PARENT_FILE"; then
        sed -i '' "/#### ДОЧЕРНИЕ ДОКУМЕНТЫ/a\\
- [[$DOC_ID - $NAME]]" "$PARENT_FILE"
    else
        echo "" >> "$PARENT_FILE"
        echo "#### ДОЧЕРНИЕ ДОКУМЕНТЫ" >> "$PARENT_FILE"
        echo "- [[$DOC_ID - $NAME]]" >> "$PARENT_FILE"
    fi
    
    echo "✅ Родитель обновлен"
fi

echo ""
echo "=== ВЫПОЛНЕНО ==="
