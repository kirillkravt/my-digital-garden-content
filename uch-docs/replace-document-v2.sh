#!/bin/bash
echo "=== UCH REPLACE DOCUMENT v2 ==="

# Параметры
OLD_ID="$1"
NEW_ID="$2"
NEW_NAME="$3"
NEW_PARENT_ID="$4"  # опционально
NEW_PARENT_NAME="$5" # опционально

if [ -z "$OLD_ID" ] || [ -z "$NEW_ID" ] || [ -z "$NEW_NAME" ]; then
    echo "Использование: $0 <old-id> <new-id> \"<new-name>\" [new-parent-id] [new-parent-name]"
    echo "Пример 1: $0 00-04-01 00-04-02 \"Новое имя\""
    echo "Пример 2: $0 00-04-01 00-05-01 \"Новое имя\" 00-05 \"Новый родитель\""
    exit 1
fi

echo "Замена документа:"
echo "  Старый ID: $OLD_ID"
echo "  Новый ID:  $NEW_ID"
echo "  Новое имя: $NEW_NAME"
[ -n "$NEW_PARENT_ID" ] && echo "  Новый родитель ID: $NEW_PARENT_ID"
[ -n "$NEW_PARENT_NAME" ] && echo "  Новый родитель имя: $NEW_PARENT_NAME"

# Найти старый файл
OLD_FILE=$(find . -maxdepth 1 -name "${OLD_ID} - *.md" -type f | head -1)

if [ -z "$OLD_FILE" ]; then
    echo "❌ Не найден документ с ID: $OLD_ID"
    exit 1
fi

# Извлекаем старое имя из файла
OLD_NAME=$(grep "^name:" "$OLD_FILE" | head -1 | cut -d'"' -f2)
if [ -z "$OLD_NAME" ]; then
    OLD_NAME=$(basename "$OLD_FILE" .md | cut -d'-' -f2- | sed 's/^ //' | cut -d'-' -f2- | sed 's/^ //')
fi

echo "Старый файл: $OLD_FILE"
echo "Старое имя:  $OLD_NAME"

# Создаем backup
BACKUP_DIR="./replace-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$OLD_FILE" "$BACKUP_DIR/"
echo "Backup создан в: $BACKUP_DIR"

# Новое имя файла
NEW_FILE="${NEW_ID} - ${NEW_NAME}.md"

echo ""
echo "1. Переименовываем файл..."
mv "$OLD_FILE" "$NEW_FILE"

echo "2. Обновляем frontmatter и содержимое..."

# Создаем временный файл
TEMP_FILE="${NEW_FILE}.tmp"

awk -v old_id="$OLD_ID" -v new_id="$NEW_ID" -v old_name="$OLD_NAME" -v new_name="$NEW_NAME" -v new_parent_id="$NEW_PARENT_ID" -v new_parent_name="$NEW_PARENT_NAME" '
BEGIN { 
    in_frontmatter = 0
    frontmatter_end = 0
    old_parent_id = ""
    old_parent_name = ""
}

# Запоминаем старые parent значения при чтении frontmatter
in_frontmatter && /^parent:/ {
    split($0, parts, "\"")
    if (length(parts) >= 2) {
        old_parent_id = parts[2]
    }
}

in_frontmatter && /^parent_name:/ {
    split($0, parts, "\"")
    if (length(parts) >= 2) {
        old_parent_name = parts[2]
    }
}

# Обрабатываем frontmatter
/^---/ {
    frontmatter_end++
    if (frontmatter_end == 1) {
        in_frontmatter = 1
    } else if (frontmatter_end == 2) {
        in_frontmatter = 0
    }
    print $0
    next
}

in_frontmatter && /^id:/ {
    print "id: \"" new_id "\""
    next
}

in_frontmatter && /^name:/ {
    print "name: \"" new_name "\""
    next
}

# Обновляем parent если указан новый
in_frontmatter && /^parent:/ && new_parent_id != "" {
    print "parent: \"" new_parent_id "\""
    next
}

in_frontmatter && /^parent_name:/ && new_parent_name != "" {
    print "parent_name: \"" new_parent_name "\""
    next
}

# Обновляем уровень если изменился parent
in_frontmatter && /^level:/ && new_parent_id != "" {
    # Вычисляем новый уровень на основе new_id
    level = split(new_id, parts, "-")
    print "level: " level
    next
}

# Обрабатываем содержимое документа
!in_frontmatter || frontmatter_end < 2 {
    line = $0
    
    # Заменяем заголовок
    if (line ~ "^### " old_name "$") {
        line = "### " new_name
    }
    
    # Заменяем ID в описании
    gsub("- \\*\\*ID\\*\\*: `" old_id "`", "- **ID**: `" new_id "`", line)
    
    # Заменяем ссылки на старый документ
    gsub("\\[\\[" old_id "\\]\\]", "[[" new_id "]]", line)
    gsub("\\[\\[" old_id " - " old_name "\\]\\]", "[[" new_id " - " new_name "]]", line)
    
    # Заменяем ссылки на старый документ (общий случай)
    gsub("\\[\\[" old_id " - ", "[[" new_id " - ", line)
    
    # Заменяем родителя если нужно
    if (new_parent_id != "" && old_parent_id != "") {
        gsub("\\[\\[" old_parent_id " - " old_parent_name "\\]\\]", "[[" new_parent_id " - " new_parent_name "]]", line)
        gsub("- \\*\\*Родитель\\*\\*: \\[\\[" old_parent_id, "- **Родитель**: [[" new_parent_id, line)
    }
    
    print line
}
' "$NEW_FILE" > "$TEMP_FILE"

mv "$TEMP_FILE" "$NEW_FILE"

echo "3. Ищем и обновляем ссылки в других документах..."
FILES_UPDATED=0
LINKS_UPDATED=0

find . -maxdepth 1 -name "*.md" -type f ! -name "$NEW_FILE" | while read -r FILE; do
    # Проверяем есть ли ссылки на старый документ
    if grep -q "\[\[${OLD_ID}" "$FILE"; then
        echo "   Обновляю ссылки в: $(basename "$FILE")"
        
        # Считаем количество замен
        COUNT=$(grep -c "\[\[${OLD_ID}" "$FILE")
        LINKS_UPDATED=$((LINKS_UPDATED + COUNT))
        
        # Создаем временный файл
        TEMP_FILE="${FILE}.tmp"
        
        # Заменяем ссылки
        awk -v old_id="$OLD_ID" -v new_id="$NEW_ID" -v old_name="$OLD_NAME" -v new_name="$NEW_NAME" '{
            line = $0
            gsub("\\[\\[" old_id "\\]\\]", "[[" new_id "]]", line)
            gsub("\\[\\[" old_id " - " old_name "\\]\\]", "[[" new_id " - " new_name "]]", line)
            gsub("\\[\\[" old_id " - ", "[[" new_id " - ", line)
            print line
        }' "$FILE" > "$TEMP_FILE"
        
        mv "$TEMP_FILE" "$FILE"
        FILES_UPDATED=$((FILES_UPDATED + 1))
    fi
done

echo ""
echo "✅ Замена завершена!"
echo "   Создан новый файл: $NEW_FILE"
echo "   Обновлено файлов: $FILES_UPDATED"
echo "   Обновлено ссылок: $LINKS_UPDATED"
echo "   Backup: $BACKUP_DIR"
