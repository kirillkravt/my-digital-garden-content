#!/bin/bash

echo "🔍 ПРОСТАЯ ПРОВЕРКА КОНФЛИКТОВ ID"
echo "================================"
echo ""

echo "📋 ДУБЛИРУЮЩИЕСЯ ID:"
echo "-------------------"

# Создаем временный файл с ID и именами файлов
rm -f /tmp/ids_list.txt

for file in *.md; do
    if [ -f "$file" ]; then
        # Пытаемся извлечь ID разными способами
        ID=$(grep "^id:" "$file" 2>/dev/null | head -1 | sed 's/^id:[ \t]*"\(.*\)"/\1/' | tr -d '"' | xargs)
        if [ -n "$ID" ]; then
            echo "$ID -> $file" >> /tmp/ids_list.txt
        fi
    fi
done

# Ищем дубликаты
echo "Конфликты (ID используется в нескольких файлах):"
echo ""

awk -F' -> ' '{
    ids[$1] = ids[$1] " " $2
} 
END {
    for (id in ids) {
        count = split(ids[id], files, " ")
        if (count > 2) {  # +1 потому что split включает пустой элемент
            print "❌ " id " используется " (count-1) " раз(а):"
            for (i=2; i<=count; i++) {
                print "   - " files[i]
            }
            print ""
        }
    }
}' /tmp/ids_list.txt

# Показываем все ID для ручной проверки
echo ""
echo "📊 ВСЕ ID ИЗ ДОКУМЕНТОВ:"
echo "----------------------"
sort /tmp/ids_list.txt | while read line; do
    echo "  $line"
done

rm -f /tmp/ids_list.txt
