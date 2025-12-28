#!/bin/bash
# Замена и смещение документов - исправленная версия

# Архивировать документ
archive_document() {
    local source_file="$1"
    local backup_dir="$2"
    
    if [ ! -f "$source_file" ]; then
        echo "❌ Файл для архивации не найден: $source_file"
        return 1
    fi
    
    # Создаем имя архива с датой в начале
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local filename=$(basename "$source_file")
    local archived_name="${timestamp}-${filename}"
    local backup_path="${backup_dir}/${archived_name}"
    
    # Копируем с добавлением отметки об архивации
    echo "  📁 Архивирую: $filename → $archived_name"
    
    # Добавляем пометку об архивации в начало файла
    {
        echo "# АРХИВИРОВАН: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# ИСХОДНЫЙ ФАЙЛ: $filename"
        echo "# ЗАМЕНЕН НА: (будет указано после замены)"
        echo "---"
        cat "$source_file"
    } > "$backup_path"
    
    echo "    ✅ Сохранен в: $backup_path"
    return 0
}

# Найти все связанные документы (родители, дети, ссылки)
find_related_documents() {
    local doc_id="$1"
    local doc_name="$2"
    
    local related_files=()
    
    # 1. Родительский документ
    if [[ "$doc_id" =~ - ]]; then
        local parent_id=$(echo "$doc_id" | sed 's/-[^-]*$//')
        local parent_file=$(find . -maxdepth 1 -name "${parent_id} - *.md" -type f | head -1)
        if [ -n "$parent_file" ]; then
            related_files+=("$parent_file")
        fi
    fi
    
    # 2. Дочерние документы
    local child_pattern="${doc_id}-[0-9A-Fa-f][0-9A-Fa-f]"
    for child_file in $(find . -maxdepth 1 -name "${child_pattern} - *.md" -type f); do
        related_files+=("$child_file")
    done
    
    # 3. Другие документы со ссылками
    for file in *.md; do
        if [ ! -f "$file" ] || [[ "$file" == *"changed-backup"* ]]; then
            continue
        fi
        
        # Пропускаем сам документ и его архив
        if [[ "$file" == "${doc_id} - ${doc_name}.md" ]] || [[ "$(basename "$file")" == "${timestamp}"* ]]; then
            continue
        fi
        
        # Проверяем ссылки
        if grep -q "\\[\\[${doc_id} - ${doc_name}\\]\\]" "$file"; then
            related_files+=("$file")
        fi
    done
    
    # Убираем дубликаты
    printf '%s\n' "${related_files[@]}" | sort -u
}

# Обновить все ссылки на документ
update_all_references() {
    local old_id="$1"
    local old_name="$2"
    local new_id="$3"
    local new_name="$4"
    
    echo "  🔄 Поиск ссылок на: [[$old_id - $old_name]]"
    
    local updated_count=0
    local related_files=$(find_related_documents "$old_id" "$old_name")
    
    for file in $related_files; do
        if [ ! -f "$file" ]; then
            continue
        fi
        
        echo "    Проверяю: $(basename "$file")"
        
        # Создаем временный файл
        temp_file="${file}.tmp"
        
        # Заменяем ссылки
        sed "s/\[\[${old_id} - ${old_name}\]\]/\[\[${new_id} - ${new_name}\]\]/g" "$file" > "$temp_file"
        
        # Проверяем изменения
        if ! diff "$file" "$temp_file" >/dev/null; then
            mv "$temp_file" "$file"
            updated_count=$((updated_count + 1))
            echo "      ✅ Обновлено"
        else
            rm "$temp_file"
        fi
    done
    
    echo "  🔄 Обновлено документов: $updated_count"
    return $updated_count
}

# Замена документа (исправленная)
replace_document_fixed() {
    echo ""
    echo "🔄 ЗАМЕНА ДОКУМЕНТА"
    echo ""
    
    # 1. Документ-источник (которым заменяем)
    echo "=== ДОКУМЕНТ-ИСТОЧНИК ==="
    echo "Введите ID документа, КОТОРЫМ будете заменять:"
    read -p "ID источника: " source_id
    
    if [ -z "$source_id" ]; then
        echo "❌ ID источника не может быть пустым"
        return 1
    fi
    
    # Ищем файл-источник
    local source_file=$(find . -maxdepth 1 -name "${source_id} - *.md" -type f | head -1)
    if [ -z "$source_file" ]; then
        echo "❌ Документ-источник с ID '$source_id' не найден"
        return 1
    fi
    
    local source_name=$(basename "$source_file" .md | sed "s/^${source_id} - //")
    echo "Найден документ-источник: $source_name"
    
    # 2. Документ-цель (который заменяем)
    echo ""
    echo "=== ДОКУМЕНТ-ЦЕЛЬ ==="
    echo "Введите ID документа, КОТОРЫЙ будет заменен:"
    read -p "ID цели: " target_id
    
    if [ -z "$target_id" ]; then
        echo "❌ ID цели не может быть пустым"
        return 1
    fi
    
    # Ищем файл-цель
    local target_file=$(find . -maxdepth 1 -name "${target_id} - *.md" -type f | head -1)
    if [ -z "$target_file" ]; then
        echo "❌ Документ-цель с ID '$target_id' не найден"
        return 1
    fi
    
    local target_name=$(basename "$target_file" .md | sed "s/^${target_id} - //")
    echo "Найден документ-цель: $target_name"
    
    # 3. Параметры замены
    echo ""
    echo "=== ПАРАМЕТРЫ ЗАМЕНЫ ==="
    
    # Определяем уровень по ID источника
    local level=$(echo "$source_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
    # Новое название (можно изменить)
    read -p "Новое название документа [${source_name}]: " new_name
    if [ -z "$new_name" ]; then
        new_name="$source_name"
    fi
    
    # Выбор типа
    if [ -f "$SCRIPT_DIR/types.sh" ]; then
        source "$SCRIPT_DIR/types.sh"
        show_type_menu_for_level "$level"
        type=$(select_type_by_number "$level")
    else
        type=$(get_default_type_for_level "$level")
    fi
    
    # Теги
    echo ""
    read -p "Введите теги через запятую (Enter чтобы оставить как в источнике): " new_tags
    
    # 4. Сводка
    echo ""
    echo "📋 СВОДКА ЗАМЕНЫ:"
    echo "  ИСТОЧНИК (будет использован):"
    echo "    ID: $source_id"
    echo "    Название: $source_name → $new_name"
    echo "    Файл: $(basename "$source_file")"
    echo ""
    echo "  ЦЕЛЬ (будет заменен):"
    echo "    ID: $target_id → $source_id"
    echo "    Название: $target_name → $new_name"
    echo "    Файл: $(basename "$target_file")"
    echo ""
    echo "  ПАРАМЕТРЫ:"
    echo "    Уровень: $level"
    echo "    Тип: $type"
    if [ -n "$new_tags" ]; then
        echo "    Теги: $new_tags"
    fi
    echo ""
    
    read -p "Выполнить замену? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 5. Выполняем замену
    echo ""
    echo "🔄 Выполняю замену..."
    
    # Создаем директорию для бэкапов
    local backup_dir="changed-backup"
    mkdir -p "$backup_dir"
    
    # 5.1 Архивируем целевой документ
    echo "📁 Архивирую целевой документ..."
    if ! archive_document "$target_file" "$backup_dir"; then
        echo "❌ Ошибка при архивации"
        return 1
    fi
    
    # 5.2 Обновляем имя файла источника на имя цели (сохраняя ID источника)
    local new_filename="${source_id} - ${new_name}.md"
    echo "📄 Переименовываю: $(basename "$source_file") → $new_filename"
    
    # Если это один и тот же файл (замена самого себя), просто переименовываем
    if [ "$source_file" = "$target_file" ]; then
        mv "$source_file" "$new_filename"
        source_file="$new_filename"
    else
        # Копируем источник в место цели
        cp "$source_file" "$new_filename"
        # Удаляем оригинальный источник (если он не цель)
        if [ "$source_file" != "$target_file" ]; then
            rm "$source_file"
        fi
        # Удаляем цель (уже заархивирован)
        rm "$target_file"
    fi
    
    # 5.3 Обновляем frontmatter в новом файле
    echo "📝 Обновляю frontmatter..."
    
    # Извлекаем текущие теги если новые не указаны
    local final_tags="$new_tags"
    if [ -z "$final_tags" ]; then
        # Пытаемся извлечь теги из исходного файла
        if [ -f "$new_filename" ]; then
            final_tags=$(grep -A5 '^tags:' "$new_filename" | tail -n +2 | \
                sed 's/^[[:space:]]*-[[:space:]]*"//' | sed 's/"$//' | \
                grep -v "^$type$" | tr '\n' ',' | sed 's/,$//')
        fi
    fi
    
    # Обновляем файл
    temp_file="${new_filename}.tmp"
    
    awk -v new_id="$source_id" -v new_name="$new_name" -v new_type="$type" -v new_level="$level" -v new_tags="$final_tags" '
    BEGIN { 
        in_frontmatter = 0
        frontmatter_done = 0
        tags_updated = 0
    }
    
    /^---$/ {
        in_frontmatter = !in_frontmatter
        if (!in_frontmatter) {
            frontmatter_done = 1
        }
        print $0
        next
    }
    
    in_frontmatter && /^id:/ {
        print "id: \"" new_id "\""
        next
    }
    
    in_frontmatter && /^name:/ {
        print "name: \"" new_name "\""
        next
    }
    
    in_frontmatter && /^type:/ {
        print "type: \"" new_type "\""
        next
    }
    
    in_frontmatter && /^level:/ {
        print "level: " new_level
        next
    }
    
    in_frontmatter && /^tags:/ {
        print "tags:"
        if (new_tags != "") {
            split(new_tags, tags_array, ",")
            for (i in tags_array) {
                print "  - \"" tags_array[i] "\""
            }
        }
        print "  - \"" new_type "\""
        tags_updated = 1
        next
    }
    
    in_frontmatter && tags_updated && /^[[:space:]]*-/ {
        # Пропускаем старые теги после обновления
        next
    }
    
    !in_frontmatter && frontmatter_done && /^### / {
        # Обновляем заголовок
        print "### " new_name
        next
    }
    
    { print $0 }
    ' "$new_filename" > "$temp_file"
    
    mv "$temp_file" "$new_filename"
    
    # 5.4 Обновляем все ссылки в системе
    echo "🔗 Обновляю ссылки..."
    update_all_references "$target_id" "$target_name" "$source_id" "$new_name"
    
    # 5.5 Обновляем бэкап с информацией о замене
    local latest_backup=$(ls -t "${backup_dir}/${timestamp}"* 2>/dev/null | head -1)
    if [ -n "$latest_backup" ]; then
        sed -i '' "s|# ЗАМЕНЕН НА:.*|# ЗАМЕНЕН НА: ${source_id} - ${new_name}.md|" "$latest_backup"
    fi
    
    echo ""
    echo "✅ ЗАМЕНА ВЫПОЛНЕНА!"
    echo "   📁 Архив: $backup_dir/$(basename "$latest_backup")"
    echo "   📄 Новый файл: $new_filename"
    echo "   🔄 ID изменен: $target_id → $source_id"
}

# Функция смещения документа
shift_document() {
    echo ""
    echo "📐 СМЕЩЕНИЕ ДОКУМЕНТА"
    echo ""
    
    echo "⚠️  ВНИМАНИЕ: Эта операция изменит нумерацию связанных документов!"
    echo ""
    
    # 1. Ввод ID для нового документа
    echo "=== НОВЫЙ ДОКУМЕНТ ==="
    echo "Введите ID для нового документа (например: 00-02-01):"
    read -p "ID: " new_id
    
    if [ -z "$new_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # Проверяем формат
    if ! echo "$new_id" | grep -qE '^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*$'; then
        echo "❌ Неверный формат ID"
        return 1
    fi
    
    # 2. Проверяем существование
    local existing_file=$(find . -maxdepth 1 -name "${new_id} - *.md" -type f | head -1)
    
    if [ -z "$existing_file" ]; then
        echo "✅ ID $new_id свободен, можно создать документ без смещения"
        # Здесь можно перейти к обычному созданию
        return 0
    fi
    
    # 3. Существующий документ найден - предлагаем смещение
    local existing_name=$(basename "$existing_file" .md | sed "s/^${new_id} - //")
    echo ""
    echo "❌ Документ с ID $new_id уже существует:"
    echo "   Файл: $(basename "$existing_file")"
    echo "   Название: $existing_name"
    echo ""
    echo "⚠️  Операция СМЕЩЕНИЯ:"
    echo "   - Существующий документ $new_id будет смещен"
    echo "   - Все его дочерние документы будут переименованы"
    echo "   - Все ссылки в системе будут обновлены"
    echo ""
    
    read -p "Выполнить смещение? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    echo ""
    echo "🔄 Начинаю операцию смещения..."
    
    # 4. Определяем новый ID для существующего документа
    local last_part=$(echo "$new_id" | grep -o '[^-]*$')
    local base_part=$(echo "$new_id" | sed "s/-${last_part}$//")
    
    # Конвертируем последнюю часть в decimal, увеличиваем, конвертируем обратно в HEX
    local last_decimal=$((16#$last_part))
    local new_last_decimal=$((last_decimal + 1))
    local new_last_hex=$(printf "%02X" $new_last_decimal)
    local shifted_id="${base_part}-${new_last_hex}"
    
    echo "   Смещаем: $new_id → $shifted_id"
    
    # 5. Находим все документы для смещения (сам документ + все дочерние)
    local documents_to_shift=("$existing_file")
    
    # Находим дочерние документы
    local child_pattern="${new_id}-[0-9A-Fa-f][0-9A-Fa-f]"
    for child_file in $(find . -maxdepth 1 -name "${child_pattern} - *.md" -type f); do
        documents_to_shift+=("$child_file")
    done
    
    echo "   Найдено документов для смещения: ${#documents_to_shift[@]}"
    
    # 6. Создаем временные копии со смещенными именами
    echo "   Создаю временные копии..."
    
    declare -A shift_map  # old_id -> new_id
    
    for file in "${documents_to_shift[@]}"; do
        local old_filename=$(basename "$file")
        local old_id=$(echo "$old_filename" | cut -d' ' -f1)
        local old_name=$(echo "$old_filename" | sed "s/^${old_id} - //" | sed 's/.md$//')
        
        # Вычисляем новый ID
        local new_shifted_id="$old_id"
        if [ "$old_id" = "$new_id" ]; then
            new_shifted_id="$shifted_id"
        elif [[ "$old_id" == "$new_id"-* ]]; then
            # Дочерний документ - заменяем первую часть ID
            new_shifted_id=$(echo "$old_id" | sed "s/^${new_id}/${shifted_id}/")
        fi
        
        shift_map["$old_id"]="$new_shifted_id"
        
        local temp_filename="TEMP-${new_shifted_id} - ${old_name}.md"
        
        echo "     $old_id → $new_shifted_id"
        
        # Копируем с обновлением ID в frontmatter
        awk -v new_id="$new_shifted_id" '
        /^id: / {
            print "id: \"" new_id "\""
            next
        }
        { print $0 }
        ' "$file" > "$temp_filename"
    done
    
    # 7. Обновляем все ссылки в системе
    echo "   🔄 Обновляю ссылки..."
    
    # Сначала собираем все файлы которые могут содержать ссылки
    local all_md_files=$(find . -maxdepth 1 -name "*.md" -type f | grep -v "^\./TEMP-" | grep -v "^\./changed-backup/")
    
    for file in $all_md_files; do
        local updated=0
        temp_file="${file}.tmp"
        cp "$file" "$temp_file"
        
        for old_id in "${!shift_map[@]}"; do
            local new_shifted_id="${shift_map[$old_id]}"
            
            # Находим старое имя документа
            local old_file=$(find . -maxdepth 1 -name "${old_id} - *.md" -type f | head -1)
            if [ -z "$old_file" ]; then
                continue
            fi
            local old_name=$(basename "$old_file" .md | sed "s/^${old_id} - //")
            
            # Заменяем ссылки
            if sed -i '' "s/\[\[${old_id} - ${old_name}\]\]/\[\[${new_shifted_id} - ${old_name}\]\]/g" "$temp_file" 2>/dev/null; then
                updated=1
            fi
        done
        
        if [ $updated -eq 1 ]; then
            mv "$temp_file" "$file"
        else
            rm "$temp_file"
        fi
    done
    
    # 8. Переименовываем временные файлы в постоянные
    echo "   📝 Применяю смещенные имена..."
    
    for temp_file in TEMP-*.md; do
        if [ -f "$temp_file" ]; then
            local permanent_name=$(echo "$temp_file" | sed 's/^TEMP-//')
            mv "$temp_file" "$permanent_name"
            echo "     ✅ $permanent_name"
        fi
    done
    
    # 9. Теперь можно создать новый документ с исходным ID
    echo ""
    echo "📝 Теперь можно создать новый документ с ID: $new_id"
    echo "   Существующий документ смещен на: $shifted_id"
    echo ""
    
    # Здесь можно вызвать функцию создания документа
    # create_document_manual (но уже с уверенностью что ID свободен)
    
    echo "✅ Смещение выполнено!"
    echo "   🔄 ID смещен: $new_id → $shifted_id"
    echo "   📝 Можно создать новый документ с ID: $new_id"
}

# Главное меню замены/смещения
show_replace_shift_menu() {
    echo ""
    echo "=== ОПЕРАЦИИ С ДОКУМЕНТАМИ ==="
    echo "1 - Заменить документ"
    echo "2 - Сместить документ"
    echo "3 - Назад"
    echo ""
    read -p "Ваш выбор (1-3): " choice
    
    case $choice in
        1) replace_document_fixed ;;
        2) shift_document ;;
        3) return 0 ;;
        *) echo "❌ Неверный выбор" ;;
    esac
}
