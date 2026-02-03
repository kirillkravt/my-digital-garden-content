#!/bin/bash
# verify-id-consistency.sh - Проверка соответствия ID в frontmatter и имени файла

set -e

VAULT_PATH="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"
MISMATCH_LOG="./id-mismatch-log-$(date +%Y%m%d_%H%M%S).txt"

# Функция для извлечения ID из frontmatter
extract_frontmatter_id() {
    awk '/^id:/ {
        # Убираем "id:", кавычки, пробелы
        gsub(/^id: *["'\'']*/, "", $0)
        gsub(/["'\'']*$/, "", $0)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
        print $0
        exit
    }' "$1"
}

main() {
    echo "🔍 Запуск проверки соответствия ID"
    echo "=================================="
    
    # Счетчики
    total_processed=0
    total_mismatch=0
    
    # Находим все .md файлы с frontmatter
    find "$VAULT_PATH" -name "*.md" -type f -exec grep -l "id:" {} \; | while read file; do
        total_processed=$((total_processed + 1))
        
        filename=$(basename "$file")
        id_from_name=$(echo "$filename" | cut -d"_" -f1)
        id_from_frontmatter=$(extract_frontmatter_id "$file")
        
        # Сравниваем
        if [ "$id_from_name" != "$id_from_frontmatter" ]; then
            total_mismatch=$((total_mismatch + 1))
            echo "❌ НЕСООТВЕТСТВИЕ #$total_mismatch:" | tee -a "$MISMATCH_LOG"
            echo "   Файл: $filename" | tee -a "$MISMATCH_LOG"
            echo "   ID в имени:    '$id_from_name'" | tee -a "$MISMATCH_LOG"
            echo "   ID в frontmatter: '$id_from_frontmatter'" | tee -a "$MISMATCH_LOG"
            echo "   Путь: $file" | tee -a "$MISMATCH_LOG"
            echo "---" | tee -a "$MISMATCH_LOG"
        fi
    done
    
    # Итоговый отчет
    echo "=================================="
    echo "📊 ИТОГИ ПРОВЕРКИ:"
    echo "   Проверено файлов: $total_processed"
    echo "   Найдено несоответствий: $total_mismatch"
    if [ $total_mismatch -gt 0 ]; then
        echo "   Лог сохранен в: $MISMATCH_LOG"
    fi
}

main "$@"