#!/bin/bash
# remove-all-general-info.sh - удаление блока из всех файлов

echo "=== УДАЛЕНИЕ БЛОКА 'ОБЩАЯ ИНФОРМАЦИЯ' ИЗ ВСЕХ ФАЙЛОВ ==="
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

# Создаем backup
BACKUP_DIR="backup-all-general-info-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Создаю backup в: $BACKUP_DIR"
echo ""

# Функция для удаления одного блока
remove_single_block() {
    local file="$1"
    local start_line="$2"
    
    # Определяем уровень заголовка
    local header_content=$(sed -n "${start_line}p" "$file")
    local header_level=0
    
    if [[ "$header_content" =~ ^##### ]]; then
        header_level=5
    elif [[ "$header_content" =~ ^#### ]]; then
        header_level=4
    elif [[ "$header_content" =~ ^### ]]; then
        header_level=3
    elif [[ "$header_content" =~ ^## ]]; then
        header_level=2
    elif [[ "$header_content" =~ ^# ]]; then
        header_level=1
    fi
    
    # Ищем следующий заголовок того же или более высокого уровня
    local next_line=""
    local total_lines=$(wc -l < "$file")
    
    for ((i=start_line+1; i<=total_lines; i++)); do
        local line_content=$(sed -n "${i}p" "$file")
        local line_level=0
        
        if [[ "$line_content" =~ ^##### ]]; then
            line_level=5
        elif [[ "$line_content" =~ ^#### ]]; then
            line_level=4
        elif [[ "$line_content" =~ ^### ]]; then
            line_level=3
        elif [[ "$line_content" =~ ^## ]]; then
            line_level=2
        elif [[ "$line_content" =~ ^# ]]; then
            line_level=1
        fi
        
        if [ $line_level -gt 0 ] && [ $line_level -le $header_level ]; then
            # Проверяем что это не тот же заголовок
            if [[ ! "$line_content" =~ [Оо]бщая\ [Ии]нформация ]]; then
                next_line=$i
                break
            fi
        fi
    done
    
    if [ -z "$next_line" ]; then
        next_line=$((total_lines + 1))
    fi
    
    # Удаляем блок
    sed -i '' "${start_line},$((next_line - 1))d" "$file"
    
    return $((next_line - start_line))
}

# Основная функция обработки файла
process_file() {
    local file="$1"
    local backup_file="$BACKUP_DIR/$(basename "$file")"
    
    # Создаем backup
    cp "$file" "$backup_file"
    
    local changed=0
    local blocks_removed=0
    local total_removed_lines=0
    
    # Обрабатываем файл пока есть блоки "Общая информация"
    while true; do
        # Ищем следующий заголовок с "Общая информация"
        local header_line=$(grep -n -i "^#\+.*общая информация" "$file" | head -1 | cut -d: -f1)
        
        if [ -z "$header_line" ]; then
            break
        fi
        
        echo "  Удаляю блок на строке $header_line"
        
        # Удаляем блок
        if remove_single_block "$file" "$header_line"; then
            removed_lines=$?
            blocks_removed=$((blocks_removed + 1))
            total_removed_lines=$((total_removed_lines + removed_lines))
            changed=1
        else
            break
        fi
    done
    
    if [ $changed -eq 1 ]; then
        echo "✅ $(basename "$file"): удалено $blocks_removed блоков ($total_removed_lines строк)"
        return 0
    else
        echo "➖ $(basename "$file"): блоков не найдено"
        rm "$backup_file"  # Удаляем backup если файл не изменился
        return 1
    fi
}

# Счетчики
TOTAL_FILES=0
MODIFIED_FILES=0
SKIPPED_FILES=0

echo "🔧 Обработка файлов..."
echo "---------------------"
echo ""

# Обрабатываем все .md файлы
for file in *.md; do
    if [ -f "$file" ]; then
        TOTAL_FILES=$((TOTAL_FILES + 1))
        
        # Проверяем есть ли блок "Общая информация" как заголовок
        if grep -q -i "^#\+.*общая информация" "$file"; then
            echo "📄 $file"
            if process_file "$file"; then
                MODIFIED_FILES=$((MODIFIED_FILES + 1))
            else
                SKIPPED_FILES=$((SKIPPED_FILES + 1))
            fi
            echo ""
        else
            SKIPPED_FILES=$((SKIPPED_FILES + 1))
        fi
    fi
done

echo "📊 РЕЗУЛЬТАТЫ:"
echo "  Всего файлов: $TOTAL_FILES"
echo "  Изменено: $MODIFIED_FILES"
echo "  Пропущено: $SKIPPED_FILES"
echo "  Backup создан в: $BACKUP_DIR"
echo ""

# Проверяем результат
echo "🔍 ПРОВЕРКА РЕЗУЛЬТАТА:"
echo ""

REMAINING_COUNT=$(grep -l -i "^#\+.*общая информация" *.md 2>/dev/null | wc -l | tr -d ' ')

echo "  Файлов с заголовком 'Общая информация' после удаления: $REMAINING_COUNT"

if [ "$REMAINING_COUNT" -eq 0 ]; then
    echo "  ✅ ВСЕ заголовки 'Общая информация' удалены!"
else
    echo "  ⚠️  Осталось файлов: $REMAINING_COUNT"
    echo "  Список:"
    grep -l -i "^#\+.*общая информация" *.md 2>/dev/null | sed 's/^/    • /'
fi

echo ""
echo "📋 ИНСТРУКЦИЯ:"
echo "  1. Проверить изменения: ls -la $BACKUP_DIR"
echo "  2. Для проверки одного файла: diff $BACKUP_DIR/00-04\ -\ Линия\ Г.\ Документация.md 00-04\ -\ Линия\ Г.\ Документация.md"
echo "  3. Для отката: cp $BACKUP_DIR/* ."
echo "  4. Для удаления backup: rm -rf $BACKUP_DIR"
echo ""
echo "✅ ВЫПОЛНЕНО"