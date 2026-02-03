#!/bin/bash
# fix-id-consistency.sh - Исправление несоответствий ID в frontmatter

set -e

DRY_RUN=false
TEST_MODE=false
LIMIT=0

# Парсинг аргументов
while [[ $# -gt 0 ]]; do
    case $1 in
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --test)
            TEST_MODE=true
            LIMIT=5
            shift
            ;;
        --limit=*)
            LIMIT="${1#*=}"
            shift
            ;;
        --help)
            echo "Использование: $0 [OPTIONS]"
            echo "  --dry-run     Показать что будет исправлено, но не изменять файлы"
            echo "  --test        Протестировать на 5 файлах"
            echo "  --limit=N     Ограничить количество обрабатываемых файлов"
            echo "  --help        Показать эту справку"
            exit 0
            ;;
        *)
            echo "Неизвестный аргумент: $1"
            echo "Используйте --help для справки"
            exit 1
            ;;
    esac
done

VAULT_PATH="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"
BACKUP_DIR="./backup-id-fix-$(date +%Y%m%d_%H%M%S)"
LOG_FILE="./id-fix-log-$(date +%Y%m%d_%H%M%S).txt"

# Функция для извлечения ID из frontmatter
extract_frontmatter_id() {
    grep -m1 "^id:" "$1" | sed -e "s/^id: *//" -e "s/[\"']//g" -e "s/^[[:space:]]*//" -e "s/[[:space:]]*$//"
}

# Функция для обновления ID в frontmatter
update_frontmatter_id() {
    local file="$1"
    local new_id="$2"
    
    if [ "$DRY_RUN" = true ]; then
        echo "   🧪 DRY RUN: Был бы обновлен $file -> id: \"$new_id\""
        return 0
    fi
    
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
        rm -f "$tmp_file"
        echo "❌ Ошибка обновления: $file"
        return 1
    fi
}

main() {
    echo "🚀 Запуск исправления ID несоответствий"
    [ "$DRY_RUN" = true ] && echo "🧪 РЕЖИМ DRY RUN - файлы не будут изменены"
    [ "$TEST_MODE" = true ] && echo "🧪 ТЕСТОВЫЙ РЕЖИМ - ограничение: $LIMIT файлов"
    echo "========================================"
    
    # Создаем backup директорию только если не dry-run
    if [ "$DRY_RUN" = false ]; then
        mkdir -p "$BACKUP_DIR"
    fi
    
    # Счетчики
    total_processed=0
    total_fixed=0
    total_errors=0
    
    # Находим все .md файлы с frontmatter
    find "$VAULT_PATH" -name "*.md" -type f -exec grep -l "id:" {} \; | while read file; do
        # Проверяем лимит для тестового режима
        if [ $LIMIT -gt 0 ] && [ $total_processed -ge $LIMIT ]; then
            echo "Достигнут лимит в $LIMIT файлов, останавливаемся..."
            break
        fi
        
        total_processed=$((total_processed + 1))
        
        filename=$(basename "$file")
        full_id=$(echo "$filename" | cut -d"_" -f1)
        current_id=$(extract_frontmatter_id "$file")
        
        # Проверяем несоответствие
        if [ "$full_id" != "$current_id" ]; then
            echo "🔍 Найдено несоответствие #$((total_fixed + total_errors + 1)):"
            echo "   Файл: $filename"
            echo "   Текущий ID: '$current_id'"
            echo "   Ожидаемый ID: '$full_id'"
            
            # Проверяем валидность нового ID
            if [[ "$full_id" =~ ^${current_id}-[0-9]+$ ]]; then
                if [ "$DRY_RUN" = false ]; then
                    # Создаем backup
                    backup_file="$BACKUP_DIR/$(basename "$file")"
                    cp "$file" "$backup_file"
                fi
                
                # Обновляем frontmatter
                if update_frontmatter_id "$file" "$full_id"; then
                    echo "   ✅ Исправлено"
                    total_fixed=$((total_fixed + 1))
                else
                    echo "   ❌ Ошибка при обновлении"
                    total_errors=$((total_errors + 1))
                fi
            else
                echo "   ⚠️  Странное несоответствие, пропускаем"
                total_errors=$((total_errors + 1))
            fi
            echo "---"
        fi
    done
    
    # Итоговый отчет
    echo "========================================"
    echo "📊 ИТОГИ ИСПРАВЛЕНИЯ:"
    echo "   Обработано файлов: $total_processed"
    echo "   Найдено несоответствий: $((total_fixed + total_errors))"
    echo "   Исправлено файлов: $total_fixed"
    echo "   Ошибок: $total_errors"
    
    if [ "$DRY_RUN" = false ]; then
        echo "   Backup создан в: $BACKUP_DIR"
        echo "   Лог сохранен в: $LOG_FILE"
    fi
}

# Запуск
main "$@"