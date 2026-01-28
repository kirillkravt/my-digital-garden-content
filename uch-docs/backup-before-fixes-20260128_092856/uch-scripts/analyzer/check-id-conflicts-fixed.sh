#!/bin/bash

echo "🔍 ПРОВЕРКА КОНФЛИКТОВ ID В ДОКУМЕНТАХ"
echo "======================================"
echo ""

# Временный файл для хранения ID
TEMP_FILE="/tmp/uch_ids_check.tmp"
rm -f "$TEMP_FILE"

echo "📊 Сбор ID из документов..."
echo ""

CONFLICT_COUNT=0
PROCESSED_FILES=0

for file in *.md; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    PROCESSED_FILES=$((PROCESSED_FILES + 1))
    
    # Проверяем наличие YAML frontmatter
    FIRST_LINE=$(head -1 "$file" 2>/dev/null)
    if [ "$FIRST_LINE" != "---" ]; then
        continue
    fi
    
    # Извлекаем ID из YAML
    ID=$(awk '
    /^---$/ { if (++count == 1) next; if (count == 2) exit }
    count == 1 && /^id:/ {
        gsub("^id:[ \t]*[\"]?", "")
        gsub("[\"]?$", "")
        print $0
    }
    ' "$file")
    
    if [ -n "$ID" ]; then
        # Записываем в формате: ID|file
        echo "$ID|$file" >> "$TEMP_FILE"
    fi
done

echo ""
echo "🔎 Анализ конфликтов..."
echo ""

if [ -f "$TEMP_FILE" ]; then
    # Ищем дубликаты ID
    echo "🔍 Поиск дубликатов ID:"
    echo "---------------------"
    
    CONFLICT_FOUND=0
    
    # Сортируем и находим дубликаты
    sort "$TEMP_FILE" | cut -d'|' -f1 | uniq -c | while read count id; do
        if [ "$count" -gt 1 ]; then
            CONFLICT_FOUND=1
            CONFLICT_COUNT=$((CONFLICT_COUNT + 1))
            echo ""
            echo "❌ КОНФЛИКТ: ID '$id' используется $count раз(а)"
            echo "   Файлы:"
            grep "^$id|" "$TEMP_FILE" | cut -d'|' -f2 | sed 's/^/   - /'
        fi
    done
    
    if [ "$CONFLICT_FOUND" -eq 0 ]; then
        echo "✅ Конфликтов ID не найдено"
    fi
    
    # Статистика
    echo ""
    echo "📈 СТАТИСТИКА:"
    echo "-------------"
    TOTAL_IDS=$(wc -l < "$TEMP_FILE" | tr -d ' ')
    UNIQUE_IDS=$(cut -d'|' -f1 "$TEMP_FILE" | sort -u | wc -l | tr -d ' ')
    echo "Всего ID: $TOTAL_IDS"
    echo "Уникальных ID: $UNIQUE_IDS"
    echo "Конфликтов: $CONFLICT_COUNT"
    
    # Очистка
    rm -f "$TEMP_FILE"
else
    echo "⚠️  Не найдено документов с ID"
fi

echo ""
echo "📊 ИТОГИ:"
echo "--------"
echo "Обработано файлов: $PROCESSED_FILES"
echo "Найдено конфликтов: $CONFLICT_COUNT"
