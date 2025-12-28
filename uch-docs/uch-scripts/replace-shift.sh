#!/bin/bash
# Замена документа - упрощенная и корректная версия

# Простая замена документа
simple_replace_document() {
    echo ""
    echo "🔄 ЗАМЕНА ДОКУМЕНТА"
    echo "Старый документ будет заархивирован, новый займет его ID"
    echo ""
    
    # 1. ID заменяемого документа (который будет заархивирован)
    echo "=== ЗАМЕНЯЕМЫЙ ДОКУМЕНТ ==="
    read -p "Введите ID документа, который будет заменен: " target_id
    
    if [ -z "$target_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # Ищем заменяемый файл
    local target_file=$(find . -maxdepth 1 -name "${target_id} - *.md" -type f | head -1)
    if [ -z "$target_file" ]; then
        echo "❌ Документ с ID '$target_id' не найден"
        return 1
    fi
    
    local target_name=$(basename "$target_file" .md | sed "s/^${target_id} - //")
    echo "Найден документ: $target_name"
    
    # 2. ID нового документа (которым заменяем)
    echo ""
    echo "=== НОВЫЙ ДОКУМЕНТ ==="
    read -p "Введите ID документа, КОТОРЫМ заменяем: " source_id
    
    if [ -z "$source_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # Ищем новый файл
    local source_file=$(find . -maxdepth 1 -name "${source_id} - *.md" -type f | head -1)
    if [ -z "$source_file" ]; then
        echo "❌ Документ с ID '$source_id' не найден"
        return 1
    fi
    
    local source_name=$(basename "$source_file" .md | sed "s/^${source_id} - //")
    echo "Найден документ: $source_name"
    
    # 3. Параметры
    echo ""
    echo "=== ПАРАМЕТРЫ ==="
    read -p "Новое название документа [${source_name}]: " new_name
    if [ -z "$new_name" ]; then
        new_name="$source_name"
    fi
    
    # Определяем уровень
    local level=$(echo "$target_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
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
    echo "  ЗАМЕНЯЕМЫЙ (будет заархивирован):"
    echo "    ID: $target_id"
    echo "    Название: $target_name"
    echo ""
    echo "  НОВЫЙ (займет место заменяемого):"
    echo "    ID: $source_id → $target_id"
    echo "    Название: $source_name → $new_name"
    echo ""
    echo "  РЕЗУЛЬТАТ:"
    echo "    Документ $target_id - $target_name"
    echo "    будет заменен на"
    echo "    Документ $target_id - $new_name"
    echo ""
    
    read -p "Выполнить замену? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 5. Выполняем замену
    echo ""
    echo "🔄 Выполняю замену..."
    
    # 5.1 Создаем директорию для бэкапов
    local backup_dir="changed-backup"
    mkdir -p "$backup_dir"
    
    # 5.2 Архивируем заменяемый документ
    echo "📁 Архивирую заменяемый документ..."
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file="${backup_dir}/${timestamp}-${target_id}-${target_name}.md"
    
    {
        echo "# АРХИВИРОВАН: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# ЗАМЕНА: $target_id - $target_name → $target_id - $new_name"
        echo "# ИСХОДНИК: $source_id - $source_name"
        echo "---"
        cat "$target_file"
    } > "$backup_file"
    
    echo "    ✅ Сохранен в: $backup_file"
    
    # 5.3 Подготавливаем новый документ с ID заменяемого
    local new_filename="${target_id} - ${new_name}.md"
    echo "📄 Создаю новый документ: $new_filename"
    
    # Копируем исходный файл
    cp "$source_file" "$new_filename"
    
    # 5.4 Обновляем frontmatter в новом файле
    temp_file="${new_filename}.tmp"
    
    # Получаем теги если не указаны новые
    local final_tags="$new_tags"
    if [ -z "$final_tags" ]; then
        if [ -f "$source_file" ]; then
            final_tags=$(grep -A5 '^tags:' "$source_file" | tail -n +2 | \
                sed 's/^[[:space:]]*-[[:space:]]*"//' | sed 's/"$//' | \
                grep -v "^$type$" | tr '\n' ',' | sed 's/,$//')
        fi
    fi
    
    awk -v new_id="$target_id" -v new_name="$new_name" -v new_type="$type" -v new_level="$level" -v new_tags="$final_tags" '
    BEGIN { 
        in_frontmatter = 0
        tags_updated = 0
    }
    
    /^---$/ {
        in_frontmatter = !in_frontmatter
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
    
    in_frontmatter && tags_updated && /^[[:space:]]*- "/ {
        # Пропускаем старые теги после обновления
        next
    }
    
    !in_frontmatter && /^### / {
        # Обновляем заголовок
        print "### " new_name
        next
    }
    
    { print $0 }
    ' "$new_filename" > "$temp_file"
    
    mv "$temp_file" "$new_filename"
    
    # 5.5 Обновляем ссылки в системе
    echo "🔗 Обновляю ссылки..."
    
    local updated_count=0
    for file in *.md; do
        if [ ! -f "$file" ] || [[ "$file" == *"changed-backup"* ]] || [[ "$file" == "$new_filename" ]]; then
            continue
        fi
        
        # Проверяем ссылки на старый документ
        if grep -q "\\[\\[${target_id} - ${target_name}\\]\\]" "$file"; then
            echo "  Обновляю: $(basename "$file")"
            
            temp_file2="${file}.tmp"
            sed "s/\[\[${target_id} - ${target_name}\]\]/\[\[${target_id} - ${new_name}\]\]/g" "$file" > "$temp_file2"
            
            if ! diff "$file" "$temp_file2" >/dev/null; then
                mv "$temp_file2" "$file"
                updated_count=$((updated_count + 1))
            else
                rm "$temp_file2"
            fi
        fi
        
        # Также обновляем ссылки на исходный документ (если ID разные)
        if [ "$source_id" != "$target_id" ] && grep -q "\\[\\[${source_id} - ${source_name}\\]\\]" "$file"; then
            echo "  Обновляю ссылки на исходный: $(basename "$file")"
            
            temp_file2="${file}.tmp2"
            sed "s/\[\[${source_id} - ${source_name}\]\]/\[\[${target_id} - ${new_name}\]\]/g" "$file" > "$temp_file2"
            
            if ! diff "$file" "$temp_file2" >/dev/null; then
                mv "$temp_file2" "$file"
                updated_count=$((updated_count + 1))
            else
                rm "$temp_file2"
            fi
        fi
    done
    
    echo "  🔄 Обновлено ссылок: $updated_count"
    
    # 5.6 Удаляем исходные файлы
    echo "🗑️  Удаляю исходные файлы..."
    
    if [ "$source_file" != "$target_file" ] && [ -f "$source_file" ]; then
        rm "$source_file"
        echo "    Удален: $(basename "$source_file")"
    fi
    
    if [ -f "$target_file" ] && [ "$target_file" != "$new_filename" ]; then
        rm "$target_file"
        echo "    Удален: $(basename "$target_file")"
    fi
    
    echo ""
    echo "✅ ЗАМЕНА ВЫПОЛНЕНА!"
    echo "   📁 Архив: $backup_file"
    echo "   📄 Новый документ: $new_filename"
    echo "   🔄 ID: $target_id сохранен"
}

# Функция смещения документа (упрощенная)
simple_shift_document() {
    echo ""
    echo "📐 СМЕЩЕНИЕ ДОКУМЕНТА"
    echo "Все документы сохраняются, меняется только порядок ID"
    echo ""
    
    # 1. Ввод ID для нового документа
    echo "=== НОВЫЙ ДОКУМЕНТ ==="
    echo "Введите ID, который должен занять новый документ:"
    read -p "ID: " desired_id
    
    if [ -z "$desired_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # Проверяем формат
    if ! echo "$desired_id" | grep -qE '^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*$'; then
        echo "❌ Неверный формат ID"
        return 1
    fi
    
    # 2. Проверяем существование
    local existing_file=$(find . -maxdepth 1 -name "${desired_id} - *.md" -type f | head -1)
    
    if [ -z "$existing_file" ]; then
        echo "✅ ID $desired_id свободен"
        echo "Можно создать документ без смещения"
        # Здесь можно предложить создать документ
        return 0
    fi
    
    # 3. Существующий документ найден
    local existing_name=$(basename "$existing_file" .md | sed "s/^${desired_id} - //")
    echo ""
    echo "⚠️  Документ с ID $desired_id уже существует:"
    echo "   $existing_name"
    echo ""
    
    # 4. Параметры нового документа
    echo "=== ПАРАМЕТРЫ НОВОГО ДОКУМЕНТА ==="
    read -p "Введите название для нового документа: " new_name
    
    if [ -z "$new_name" ]; then
        echo "❌ Название не может быть пустым"
        return 1
    fi
    
    # Определяем уровень
    local level=$(echo "$desired_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
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
    read -p "Введите теги через запятую: " tags
    
    # 5. Предупреждение
    echo ""
    echo "⚠️  ⚠️  ⚠️  ВНИМАНИЕ ⚠️  ⚠️  ⚠️"
    echo "Будет выполнено СМЕЩЕНИЕ документов:"
    echo ""
    echo "1. Новый документ создастся с ID: $desired_id"
    echo "2. Существующий документ $desired_id будет смещен"
    echo "3. Все его дочерние документы будут переименованы"
    echo "4. Все ссылки в системе будут обновлены"
    echo ""
    echo "Пример:"
    echo "  Новый: $desired_id - $new_name"
    echo "  Старый: $desired_id - $existing_name → $(get_next_id "$desired_id") - $existing_name"
    echo ""
    
    read -p "ПОДТВЕРДИТЕ смещение? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 6. Выполняем смещение
    echo ""
    echo "�� Выполняю смещение..."
    
    # 6.1 Находим последнюю часть ID для инкремента
    local last_part=$(echo "$desired_id" | grep -o '[^-]*$')
    local base_part=$(echo "$desired_id" | sed "s/-${last_part}$//")
    
    # Конвертируем в decimal, увеличиваем, обратно в HEX
    local last_decimal=$((16#$last_part))
    local new_last_decimal=$((last_decimal + 1))
    local new_last_hex=$(printf "%02X" $new_last_decimal)
    local shifted_id="${base_part}-${new_last_hex}"
    
    echo "   Смещаем существующий: $desired_id → $shifted_id"
    
    # 6.2 Создаем карту смещения для всех связанных документов
    declare -A shift_map
    shift_map["$desired_id"]="$shifted_id"
    
    # Находим все дочерние документы
    local child_pattern="${desired_id}-[0-9A-Fa-f][0-9A-Fa-f]"
    for child_file in $(find . -maxdepth 1 -name "${child_pattern} - *.md" -type f); do
        local child_id=$(basename "$child_file" | cut -d' ' -f1)
        # Вычисляем смещенный ID для дочернего
        local shifted_child_id=$(echo "$child_id" | sed "s/^${desired_id}/${shifted_id}/")
        shift_map["$child_id"]="$shifted_child_id"
        echo "   Дочерний: $child_id → $shifted_child_id"
    done
    
    # 6.3 Сначала создаем новый документ с желаемым ID
    echo ""
    echo "📝 Создаю новый документ: $desired_id - $new_name"
    
    # Используем существующую функцию создания
    if [ -f "$SCRIPT_DIR/document-creator.sh" ]; then
        # Временно отключаем проверку существования ID
        local temp_id="$desired_id"
        desired_id="TEMP-FORCE-ID"
        
        # Создаем документ
        if create_real_document "$new_name" "$level" "$type" "$base_part" "$tags"; then
            # Переименовываем временный файл
            local temp_file=$(find . -maxdepth 1 -name "TEMP-*.md" -type f | head -1)
            if [ -n "$temp_file" ]; then
                mv "$temp_file" "${desired_id} - ${new_name}.md"
            fi
        fi
        
        desired_id="$temp_id"
    else
        echo "⚠️  Не удалось создать документ (модуль не загружен)"
    fi
    
    # 6.4 Смещаем существующие документы
    echo ""
    echo "📐 Смещаю существующие документы..."
    
    for old_id in "${!shift_map[@]}"; do
        local new_id="${shift_map[$old_id]}"
        
        # Находим файл
        local old_file=$(find . -maxdepth 1 -name "${old_id} - *.md" -type f | head -1)
        if [ -z "$old_file" ]; then
            continue
        fi
        
        local old_name=$(basename "$old_file" .md | sed "s/^${old_id} - //")
        local new_filename="${new_id} - ${old_name}.md"
        
        echo "   $old_id - $old_name → $new_filename"
        
        # Переименовываем файл
        mv "$old_file" "$new_filename"
        
        # Обновляем ID внутри файла
        temp_file="${new_filename}.tmp"
        sed "s/^id: \"${old_id}\"/id: \"${new_id}\"/" "$new_filename" > "$temp_file"
        mv "$temp_file" "$new_filename"
    done
    
    # 6.5 Обновляем все ссылки
    echo ""
    echo "🔗 Обновляю ссылки..."
    
    local updated_count=0
    for file in *.md; do
        if [ ! -f "$file" ] || [[ "$file" == *"changed-backup"* ]]; then
            continue
        fi
        
        local file_updated=0
        temp_file="${file}.tmp"
        cp "$file" "$temp_file"
        
        for old_id in "${!shift_map[@]}"; do
            local new_id="${shift_map[$old_id]}"
            
            # Находим старое имя
            # Ищем в смещенных файлах или в исходных данных
            local old_name=""
            if [ -f "${new_id} - *.md" ]; then
                # Если файл уже переименован
                for f in "${new_id} - "*.md; do
                    if [ -f "$f" ]; then
                        old_name=$(basename "$f" .md | sed "s/^${new_id} - //")
                        break
                    fi
                done
            fi
            
            if [ -n "$old_name" ]; then
                # Заменяем ссылки
                if sed -i '' "s/\[\[${old_id} - ${old_name}\]\]/\[\[${new_id} - ${old_name}\]\]/g" "$temp_file" 2>/dev/null; then
                    file_updated=1
                fi
            fi
        done
        
        if [ $file_updated -eq 1 ]; then
            mv "$temp_file" "$file"
            updated_count=$((updated_count + 1))
            echo "   ✅ Обновлен: $(basename "$file")"
        else
            rm "$temp_file"
        fi
    done
    
    echo "   🔄 Обновлено документов: $updated_count"
    
    echo ""
    echo "✅ СМЕЩЕНИЕ ВЫПОЛНЕНО!"
    echo "   📝 Новый документ: $desired_id - $new_name"
    echo "   🔄 Смещенный: $desired_id → $shifted_id"
    echo "   🔗 Обновлено ссылок: $updated_count"
}

# Вспомогательная функция для получения следующего ID
get_next_id() {
    local id="$1"
    local last_part=$(echo "$id" | grep -o '[^-]*$')
    local base_part=$(echo "$id" | sed "s/-${last_part}$//")
    
    local last_decimal=$((16#$last_part))
    local new_last_decimal=$((last_decimal + 1))
    printf "%s-%02X" "$base_part" $new_last_decimal
}

# Главное меню
show_document_operations_menu() {
    echo ""
    echo "=== ОПЕРАЦИИ С ДОКУМЕНТАМИ ==="
    echo "1 - Заменить документ (старый архивируется)"
    echo "2 - Сместить документ (все сохраняются, меняется порядок)"
    echo "3 - Назад"
    echo ""
    read -p "Ваш выбор (1-3): " choice
    
    case $choice in
        1) simple_replace_document ;;
        2) simple_shift_document ;;
        3) return 0 ;;
        *) echo "❌ Неверный выбор" ;;
    esac
}
