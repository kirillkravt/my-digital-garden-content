#!/bin/bash
# Замена существующего документа

# Создаем директорию для бэкапов заменяемых документов
ensure_backup_dir() {
    local backup_dir="changed-backup"
    if [ ! -d "$backup_dir" ]; then
        mkdir -p "$backup_dir"
        echo "📁 Создана директория для бэкапов: $backup_dir"
    fi
    echo "$backup_dir"
}

# Замена документа
replace_document() {
    echo ""
    echo "🔄 ЗАМЕНА ДОКУМЕНТА"
    echo ""
    
    # 1. Исходный документ
    echo "=== ИСХОДНЫЙ ДОКУМЕНТ ==="
    read -p "Введите ID заменяемого документа: " source_id
    
    if [ -z "$source_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # Ищем исходный файл
    local source_file=$(find . -maxdepth 1 -name "${source_id} - *.md" -type f | head -1)
    if [ -z "$source_file" ]; then
        echo "❌ Документ с ID '$source_id' не найден"
        return 1
    fi
    
    local source_name=$(basename "$source_file" .md | sed "s/^${source_id} - //")
    echo "Найден документ: $source_name"
    
    # 2. Новый документ
    echo ""
    echo "=== НОВЫЙ ДОКУМЕНТ ==="
    read -p "Введите ID нового документа (Enter чтобы оставить '$source_id'): " new_id
    if [ -z "$new_id" ]; then
        new_id="$source_id"
    fi
    
    read -p "Введите новое название документа (Enter чтобы оставить '$source_name'): " new_name
    if [ -z "$new_name" ]; then
        new_name="$source_name"
    fi
    
    # 3. Определяем уровень по ID
    local level=$(echo "$new_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
    # 4. Выбор типа
    echo ""
    if [ -f "$SCRIPT_DIR/types.sh" ]; then
        source "$SCRIPT_DIR/types.sh"
        show_type_menu_for_level "$level"
        type=$(select_type_by_number "$level")
    else
        type=$(get_default_type_for_level "$level")
    fi
    
    # 5. Теги
    echo ""
    read -p "Введите теги через запятую (Enter чтобы оставить как есть): " new_tags
    
    # 6. Сводка
    echo ""
    echo "📋 СВОДКА ЗАМЕНЫ:"
    echo "  ИСХОДНЫЙ:"
    echo "    ID: $source_id"
    echo "    Название: $source_name"
    echo "    Файл: $(basename "$source_file")"
    echo ""
    echo "  НОВЫЙ:"
    echo "    ID: $new_id"
    echo "    Название: $new_name"
    echo "    Уровень: $level"
    echo "    Тип: $type"
    if [ -n "$new_tags" ]; then
        echo "    Теги: $new_tags"
    else
        echo "    Теги: (оставить как есть)"
    fi
    echo ""
    
    read -p "Выполнить замену? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 7. Выполняем замену
    echo ""
    echo "Выполняю замену..."
    
    # Создаем бэкап
    local backup_dir=$(ensure_backup_dir)
    local backup_file="${backup_dir}/$(basename "$source_file" .md)-$(date +%Y%m%d-%H%M%S).md"
    
    echo "📁 Создаю бэкап: $backup_file"
    cp "$source_file" "$backup_file"
    
    # Создаем новый документ
    local new_filename="${new_id} - ${new_name}.md"
    
    # Если ID изменился, нужно обновить ссылки
    if [ "$source_id" != "$new_id" ] || [ "$source_name" != "$new_name" ]; then
        echo "🔄 Обновляю ссылки в других документах..."
        update_references "$source_id" "$source_name" "$new_id" "$new_name"
    fi
    
    # Определяем родителя (если не уровень 1)
    local parent_id=""
    if [ $level -gt 1 ]; then
        parent_id=$(echo "$new_id" | sed 's/-[^-]*$//')
    fi
    
    # Получаем имя родителя
    local parent_name=""
    if [ -n "$parent_id" ]; then
        local parent_file=$(find . -maxdepth 1 -name "${parent_id} - *.md" -type f | head -1)
        if [ -n "$parent_file" ]; then
            parent_name=$(clean_parent_name "$parent_file")
        fi
    fi
    
    # Получаем теги из исходного файла если новые не указаны
    local final_tags="$new_tags"
    if [ -z "$final_tags" ]; then
        # Извлекаем теги из исходного файла
        if [ -f "$source_file" ]; then
            final_tags=$(grep -A5 '^tags:' "$source_file" | grep -v '^tags:' | \
                sed 's/^[[:space:]]*-[[:space:]]*"//' | sed 's/"$//' | \
                grep -v "^$type$" | tr '\n' ',' | sed 's/,$//')
        fi
    fi
    
    # Создаем новый документ
    echo "📄 Создаю новый документ: $new_filename"
    
    if create_real_document "$new_name" "$level" "$type" "$parent_id" "$final_tags"; then
        # Удаляем старый файл (если ID изменился)
        if [ "$source_id" != "$new_id" ]; then
            echo "🗑️  Удаляю старый файл: $(basename "$source_file")"
            rm "$source_file"
        fi
        
        echo ""
        echo "✅ Замена выполнена успешно!"
        echo "   📁 Бэкап: $backup_file"
        echo "   📄 Новый файл: $new_filename"
    else
        echo "❌ Ошибка при создании нового документа"
        echo "   Старый файл сохранен в: $backup_file"
    fi
}

# Обновление ссылок в других документах
update_references() {
    local old_id="$1"
    local old_name="$2"
    local new_id="$3"
    local new_name="$4"
    
    echo "  Поиск ссылок на: [[$old_id - $old_name]]"
    
    local updated_count=0
    for file in *.md; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        # Пропускаем бэкапы и сам файл
        if [[ "$file" == *"changed-backup"* ]] || [[ "$file" == "${old_id} - ${old_name}.md" ]]; then
            continue
        fi
        
        # Проверяем есть ли ссылка
        if grep -q "\\[\\[${old_id} - ${old_name}\\]\\]" "$file"; then
            echo "  Обновляю ссылки в: $file"
            
            # Создаем временный файл
            temp_file="${file}.tmp"
            
            # Заменяем ссылки
            sed "s/\[\[${old_id} - ${old_name}\]\]/\[\[${new_id} - ${new_name}\]\]/g" "$file" > "$temp_file"
            
            # Проверяем что замена произошла
            if diff "$file" "$temp_file" >/dev/null; then
                rm "$temp_file"
            else
                mv "$temp_file" "$file"
                updated_count=$((updated_count + 1))
                echo "    ✅ Обновлено"
            fi
        fi
    done
    
    echo "  🔄 Обновлено ссылок: $updated_count"
}

# Исправление существующего документа (миграция)
migrate_document() {
    echo ""
    echo "🔧 ИСПРАВЛЕНИЕ ДОКУМЕНТА (МИГРАЦИЯ)"
    echo ""
    
    echo "⚠️  Эта функция в стадии проектирования"
    echo ""
    echo "Планируемые возможности:"
    echo "1. Обновление frontmatter (тип, уровень, статус)"
    echo "2. Исправление ссылок"
    echo "3. Обновление шаблонов"
    echo "4. Массовая миграция по паттернам"
    echo ""
    echo "Для начала работы над этой функцией нужно:"
    echo "1. Определить форматы старых документов"
    echo "2. Создать карту миграции"
    echo "3. Реализовать поэтапное преобразование"
}
