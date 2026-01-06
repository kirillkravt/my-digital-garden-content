#!/bin/bash
# Скрипт исправления frontmatter в документах

echo "=== ИСПРАВЛЕНИЕ FRONTMATTER ==="
echo "1. Добавление отсутствующего frontmatter"
echo "2. Исправление некорректного frontmatter"
echo "3. Добавление обязательных полей"
echo ""

backup_dir="frontmatter-fixed-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
echo "📁 Backup будет создан в: $backup_dir"
echo ""

processed=0
fixed_no_frontmatter=0
fixed_bad_frontmatter=0
added_id=0
errors=0

for file in *.md; do
    # Пропускаем backup файлы и шаблоны
    if [[ "$file" == *".backup"* ]] || [[ "$file" == *"backup-"* ]] || \
       [[ "$file" == *"template"* ]] || [[ "$file" == T-* ]]; then
        continue
    fi
    
    # Создаем backup
    cp "$file" "$backup_dir/"
    
    # Получаем текущую дату
    current_date=$(date +%Y-%m-%d)
    
    # Читаем первую строку
    first_line=$(head -1 "$file" 2>/dev/null)
    
    if [ "$first_line" != "---" ]; then
        echo "🔧 $file - Добавляем frontmatter"
        
        # Создаем временный файл с новым frontmatter
        temp_file="${file}.tmp"
        
        # Извлекаем возможный ID из имени файла
        filename_id=""
        if [[ "$file" =~ ^([0-9A-F]{2}(-[0-9A-F]{2}){0,3})\ -\ .*\.md$ ]]; then
            filename_id="${BASH_REMATCH[1]}"
        fi
        
        # Определяем тип документа по уровню ID
        if [ -n "$filename_id" ]; then
            dashes=$(echo "$filename_id" | tr -cd '-' | wc -c)
            level=$((dashes + 1))
            
            case $level in
                1) doc_type="line" ;;
                2) doc_type="component" ;;
                3) doc_type="task" ;;
                4) doc_type="solution" ;;
                *) doc_type="document" ;;
            esac
        else
            doc_type="document"
        fi
        
        # Создаем базовый frontmatter
        cat > "$temp_file" << FRONTMATTER
---
id: "${filename_id:-XX}"
name: "$(basename "$file" .md | sed 's/^[^-]*- //')"
type: "$doc_type"
level: ${level:-1}
status: "active"
tags: []
created: "$current_date"
updated: "$current_date"
author: "kirillkravcov"
---

FRONTMATTER
        
        # Добавляем оригинальное содержимое
        cat "$file" >> "$temp_file"
        
        # Заменяем оригинальный файл
        mv "$temp_file" "$file"
        
        fixed_no_frontmatter=$((fixed_no_frontmatter + 1))
        processed=$((processed + 1))
        
    else
        # Проверяем существующий frontmatter
        echo "🔍 $file - Проверяем frontmatter"
        
        # Ищем закрывающий ---
        frontmatter_end=$(grep -n "^---$" "$file" | head -2 | tail -1 | cut -d: -f1)
        
        if [ -z "$frontmatter_end" ] || [ "$frontmatter_end" -le 1 ]; then
            echo "  ❌ Нет закрывающего ---, пропускаем"
            errors=$((errors + 1))
            continue
        fi
        
        # Проверяем обязательные поля
        needs_fix=0
        temp_file="${file}.tmp"
        
        # Копируем frontmatter
        head -$frontmatter_end "$file" > "$temp_file"
        
        # Проверяем и добавляем отсутствующие обязательные поля
        for field in id name type level status tags created updated author; do
            if ! grep -q "^$field:" "$temp_file"; then
                echo "  ⚠️  Добавляем поле: $field"
                needs_fix=1
                
                # Добавляем значение по умолчанию
                case $field in
                    id)
                        # Пытаемся извлечь из имени файла
                        if [[ "$file" =~ ^([0-9A-F]{2}(-[0-9A-F]{2}){0,3})\ -\ .*\.md$ ]]; then
                            value="${BASH_REMATCH[1]}"
                        else
                            value="XX"
                        fi
                        ;;
                    name)
                        value="$(basename "$file" .md | sed 's/^[^-]*- //')"
                        ;;
                    type)
                        # Определяем по уровню
                        if [[ "$file" =~ ^([0-9A-F]{2}(-[0-9A-F]{2}){0,3})\ -\ .*\.md$ ]]; then
                            id_part="${BASH_REMATCH[1]}"
                            dashes=$(echo "$id_part" | tr -cd '-' | wc -c)
                            level=$((dashes + 1))
                            
                            case $level in
                                1) value="line" ;;
                                2) value="component" ;;
                                3) value="task" ;;
                                4) value="solution" ;;
                                *) value="document" ;;
                            esac
                        else
                            value="document"
                        fi
                        ;;
                    level)
                        if [[ "$file" =~ ^([0-9A-F]{2}(-[0-9A-F]{2}){0,3})\ -\ .*\.md$ ]]; then
                            id_part="${BASH_REMATCH[1]}"
                            dashes=$(echo "$id_part" | tr -cd '-' | wc -c)
                            value=$((dashes + 1))
                        else
                            value=1
                        fi
                        ;;
                    status) value="active" ;;
                    tags) value="[]" ;;
                    created|updated) value="$current_date" ;;
                    author) value="kirillkravcov" ;;
                    *) value="" ;;
                esac
                
                # Добавляем поле в конец frontmatter (перед закрывающим ---)
                sed -i '' "/^---$/i\\
$field: \"$value\"
" "$temp_file"
            fi
        done
        
        if [ $needs_fix -eq 1 ]; then
            # Добавляем оставшуюся часть файла
            tail -n +$((frontmatter_end + 1)) "$file" >> "$temp_file"
            
            # Заменяем оригинальный файл
            mv "$temp_file" "$file"
            
            fixed_bad_frontmatter=$((fixed_bad_frontmatter + 1))
            processed=$((processed + 1))
            echo "  ✅ Исправлен"
        else
            echo "  ✅ Уже корректный"
            rm "$temp_file"
        fi
    fi
    echo ""
done

echo "=== РЕЗУЛЬТАТ ИСПРАВЛЕНИЙ ==="
echo "Обработано файлов: $processed"
echo "  - Добавлен frontmatter: $fixed_no_frontmatter"
echo "  - Исправлен frontmatter: $fixed_bad_frontmatter"
echo "Ошибок: $errors"
echo "Backup: $backup_dir"
echo ""

if [ $processed -gt 0 ]; then
    echo "✅ Frontmatter исправлен в $processed документах"
    echo ""
    echo "⚠️  РЕКОМЕНДАЦИЯ:"
    echo "1. Проверьте исправленные файлы"
    echo "2. При необходимости отредактируйте поля вручную"
    echo "3. Затем запустите скрипт переименования файлов"
else
    echo "⚠️  Нечего исправлять"
fi
