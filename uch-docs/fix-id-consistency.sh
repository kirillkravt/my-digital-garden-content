#!/bin/bash
# fix-id-consistency.sh - Исправление несоответствий ID в frontmatter

set -e

VAULT_PATH="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"
BACKUP_DIR="./backup-id-fix-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="./id-fix-log-$(date +%Y%m%d_%H%M%S).txt"

# Функция для извлечения ID из frontmatter
extract_frontmatter_id() {
    grep -m1 "^id:" "$1" | sed "s/^id: *//" | tr -d "\"'" | tr -d " " | tr -d ":"
}

# Функция для обновления ID в frontmatter
update_frontmatter_id() {
    local file="$1"
    local new_id="$2"
    
    # Создаем временный файл
    tmp_file="${file}.tmp"
    
    # Заменяем строку с id
    sed "s/^id:.*/id: \"$new_id\"/" "$file" > "$tmp_file"
    
    # Проверяем, что замена прошла успешно
    if grep -q "^id: \"$new_id\"" "$tmp_file"; then
        mv "$tmp_file" "$file"
        echo "✅ Обновлен: $file -> id: $new_id"
        return 0
    else
        rm "$tmp_file"
        echo "❌ Ошибка обновления: $file"
        return 1
    fi
}

main() {
    echo "🚀 Запуск исправления ID несоответствий"
    echo "========================================"
    
    # Создаем backup директорию
    mkdir -p "$BACKUP_DIR"
    
    # Счетчики
    total_processed=0
    total_fixed=0
    total_errors=0
    
    # Находим все .md файлы с frontmatter
    find "$VAULT_PATH" -name "*.md" -type f -exec grep -l "id:" {} \; | while read file; do
        total_processed=$((total_processed + 1))
        
        filename=$(basename "$file")
        full_id=$(echo "$filename" | cut -d"_" -f1)
        current_id=$(extract_frontmatter_id "$file")
        
        # Проверяем несоответствие
        if [ "$full_id" != "$current_id" ]; then
            echo "🔍 Найдено несоответствие:" | tee -a "$LOG_FILE"
            echo "   Файл: $filename" | tee -a "$LOG_FILE"
            echo "   Текущий ID: $current_id" | tee -a "$LOG_FILE"
            echo "   Ожидаемый ID: $full_id" | tee -a "$LOG_FILE"
            
            # Проверяем валидность нового ID
            if [[ "$full_id" =~ ^${current_id}-[0-9]+$ ]]; then
                # Создаем backup
                backup_file="$BACKUP_DIR/$(basename "$file")"
                cp "$file" "$backup_file"
                
                # Обновляем frontmatter
                if update_frontmatter_id "$file" "$full_id"; then
                    echo "   ✅ Исправлено" | tee -a "$LOG_FILE"
                    total_fixed=$((total_fixed + 1))
                else
                    echo "   ❌ Ошибка при обновлении" | tee -a "$LOG_FILE"
                    total_errors=$((total_errors + 1))
                fi
            else
                echo "   ⚠️  Странное несоответствие, пропускаем" | tee -a "$LOG_FILE"
                total_errors=$((total_errors + 1))
            fi
            echo "---" | tee -a "$LOG_FILE"
        fi
    done
    
    # Итоговый отчет
    echo "========================================" | tee -a "$LOG_FILE"
    echo "📊 ИТОГИ ИСПРАВЛЕНИЯ:" | tee -a "$LOG_FILE"
    echo "   Обработано файлов: $total_processed" | tee -a "$LOG_FILE"
    echo "   Исправлено файлов: $total_fixed" | tee -a "$LOG_FILE"
    echo "   Ошибок: $total_errors" | tee -a "$LOG_FILE"
    echo "   Backup создан в: $BACKUP_DIR" | tee -a "$LOG_FILE"
    echo "   Лог сохранен в: $LOG_FILE" | tee -a "$LOG_FILE"
}