#!/bin/bash
# remove-general-info-final.sh - окончательное удаление блока

echo "=== ОКОНЧАТЕЛЬНОЕ УДАЛЕНИЕ БЛОКА 'ОБЩАЯ ИНФОРМАЦИЯ' ==="
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

# Создаем backup
BACKUP_DIR="backup-final-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📁 Создаю backup в: $BACKUP_DIR"
echo ""

# Функция для удаления блока
remove_block() {
    local file="$1"
    local changed=0
    
    # Создаем временный файл
    local temp_file="${file}.tmp_remove"
    
    # Копируем оригинал в temp
    cp "$file" "$temp_file"
    
    # Ищем ВСЕ заголовки "Общая информация" в файле
    while true; do
        # Находим строку с заголовком "Общая информация" (любой уровень)
        header_line=$(grep -n -i "^#\+.*общая информация" "$temp_file" | head -1 | cut -d: -f1)
        
        if [ -z "$header_line" ]; then
            # Больше заголовков нет
            break
        fi
        
        # Определяем уровень заголовка
        header_content=$(sed -n "${header_line}p" "$temp_file")
        header_level=0
        
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
        
        echo "  Найден заголовок уровня $header_level на строке $header_line"
        
        # Ищем следующий заголовок того же или более высокого уровня
        next_header_line=""
        total_lines=$(wc -l < "$temp_file")
        
        for ((i=header_line+1; i<=total_lines; i++)); do
            line_content=$(sed -n "${i}p" "$temp_file")
            line_level=0
            
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
                # Нашли заголовок того же или более высокого уровня
                if [[ ! "$line_content" =~ [Оо]бщая\ [Ии]нформация ]]; then
                    next_header_line=$i
                    break
                fi
            fi
        done
        
        if [ -z "$next_header_line" ]; then
            # Если следующий заголовок не найден, удаляем до конца файла
            next_header_line=$((total_lines + 1))
        fi
        
        # Удаляем блок
        echo "  Удаляю строки $header_line-$((next_header_line - 1))"
        sed -i '' "${header_line},$((next_header_line - 1))d" "$temp_file"
        changed=1
        
        # Обновляем total_lines после удаления
        total_lines=$(wc -l < "$temp_file")
    done
    
    if [ $changed -eq 1 ]; then
        # Файл изменился
        cp "$file" "$BACKUP_DIR/"  # Делаем backup оригинала
        mv "$temp_file" "$file"
        echo "✅ Изменен: $(basename "$file")"
        return 0
    else
        # Файл не изменился
        rm "$temp_file"
        echo "➖ Без изменений: $(basename "$file")"
        return 1
    fi
}

# Счетчики
total_files=0
modified_files=0
skipped_files=0

echo "🔧 Обработка файлов..."
echo "---------------------"
echo ""

# Обрабатываем только файлы с "Общая информация"
for file in *.md; do
    if [ -f "$file" ] && grep -qi "общая информация" "$file"; then
        total_files=$((total_files + 1))
        echo "📄 Обрабатываю: $file"
        
        if remove_block "$file"; then
            modified_files=$((modified_files + 1))
        else
            skipped_files=$((skipped_files + 1))
        fi
        
        echo ""
    fi
done

echo "📊 РЕЗУЛЬТАТЫ:"
echo "  Всего файлов с блоком: $total_files"
echo "  Изменено файлов: $modified_files"
echo "  Без изменений: $skipped_files"
echo "  Backup создан в: $BACKUP_DIR"
echo ""

# Проверяем результат
echo "🔍 ПРОВЕРКА РЕЗУЛЬТАТА:"
echo ""

remaining_count=$(grep -l -i "общая информация" *.md 2>/dev/null | wc -l | tr -d ' ')
echo "  Файлов с 'Общая информация' после удаления: $remaining_count"

if [ "$remaining_count" -eq 0 ]; then
    echo "  ✅ ВСЕ блоки удалены!"
else
    echo "  ⚠️  Осталось файлов: $remaining_count"
    echo "  Список:"
    grep -l -i "общая информация" *.md 2>/dev/null | sed 's/^/    • /'
fi

echo ""
echo "📋 ИНСТРУКЦИЯ:"
echo "  1. Проверить изменения: diff $BACKUP_DIR/00-04\ -\ Линия\ Г.\ Документация.md 00-04\ -\ Линия\ Г.\ Документация.md"
echo "  2. Если что-то пошло не так: cp $BACKUP_DIR/* ."
echo "  3. Удалить backup когда все ок: rm -rf $BACKUP_DIR"