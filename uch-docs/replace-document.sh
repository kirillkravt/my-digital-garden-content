#!/bin/bash
echo "=== UCH REPLACE DOCUMENT ==="

# Параметры
OLD_ID="$1"
NEW_ID="$2"
NEW_NAME="$3"

if [ -z "$OLD_ID" ] || [ -z "$NEW_ID" ] || [ -z "$NEW_NAME" ]; then
    echo "Использование: $0 <old-id> <new-id> \"<new-name>\""
    echo "Пример: $0 00-04-01 00-04-02 \"Новое имя документа\""
    exit 1
fi

echo "Замена документа:"
echo "  Старый ID: $OLD_ID"
echo "  Новый ID:  $NEW_ID"
echo "  Новое имя: $NEW_NAME"

# Найти старый файл
OLD_FILE=$(find . -maxdepth 1 -name "${OLD_ID} - *.md" -type f | head -1)

if [ -z "$OLD_FILE" ]; then
    echo "❌ Не найден документ с ID: $OLD_ID"
    exit 1
fi

echo "Старый файл: $OLD_FILE"

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

echo "2. Обновляем frontmatter в новом файле..."
# Сохраняем всё кроме id и name
TEMP_FILE="${NEW_FILE}.tmp"

awk -v old_id="$OLD_ID" -v new_id="$NEW_ID" -v new_name="$NEW_NAME" '
BEGIN { in_frontmatter = 0; frontmatter_end = 0; }

/^---/ {
    frontmatter_end++;
    if (frontmatter_end == 1) {
        in_frontmatter = 1;
    } else if (frontmatter_end == 2) {
        in_frontmatter = 0;
    }
}

in_frontmatter && /^id:/ {
    print "id: \"" new_id "\"";
    next;
}

in_frontmatter && /^name:/ {
    print "name: \"" new_name "\"";
    next;
}

{ print $0 }
' "$NEW_FILE" > "$TEMP_FILE" && mv "$TEMP_FILE" "$NEW_FILE"

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
        sed "s/\[\[${OLD_ID}\]\]/\[\[${NEW_ID}\]\]/g; \
             s/\[\[${OLD_ID} - /\[\[${NEW_ID} - /g" "$FILE" > "$TEMP_FILE"
        
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
