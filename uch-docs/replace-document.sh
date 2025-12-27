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

# Найти старый файл
OLD_FILE=$(find . -name "$OLD_ID - *.md" -type f | head -1)

if [ -z "$OLD_FILE" ]; then
    echo "❌ Не найден документ с ID: $OLD_ID"
    exit 1
fi

echo "Старый файл: $OLD_FILE"
echo "Новый ID:    $NEW_ID"
echo "Новое имя:   $NEW_NAME"

# Создаем backup
BACKUP_DIR="./replace-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
cp "$OLD_FILE" "$BACKUP_DIR/"

# Новое имя файла
NEW_FILE="$NEW_ID - $NEW_NAME.md"

echo ""
echo "1. Переименовываем файл..."
mv "$OLD_FILE" "$NEW_FILE"

echo "2. Обновляем frontmatter в новом файле..."
sed -i '' "s/^id:.*$/id: \"$NEW_ID\"/" "$NEW_FILE"
sed -i '' "s/^name:.*$/name: \"$NEW_NAME\"/" "$NEW_FILE"

echo "3. Ищем и обновляем ссылки в других документах..."
find . -name "*.md" -type f ! -name "$NEW_FILE" | while read -r FILE; do
    # Считаем количество замен
    COUNT=$(grep -c "\[\[$OLD_ID" "$FILE" 2>/dev/null || echo 0)
    
    if [ "$COUNT" -gt 0 ]; then
        echo "   Обновляем $FILE ($COUNT ссылок)"
        
        # Создаем временный файл
        TEMP_FILE="$FILE.tmp"
        
        # Заменяем ссылки
        sed "s/\[\[$OLD_ID\]\]/\[\[$NEW_ID\]\]/g; \
             s/\[\[$OLD_ID - /\[\[$NEW_ID - /g" "$FILE" > "$TEMP_FILE"
        
        mv "$TEMP_FILE" "$FILE"
    fi
done

echo ""
echo "✅ Замена завершена!"
echo "   Backup создан в: $BACKUP_DIR"
echo "   Новый файл: $NEW_FILE"