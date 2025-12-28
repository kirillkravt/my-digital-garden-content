#!/bin/bash
# Замена и смещение документов - исправлено для macOS

# Простая замена документа
simple_replace_document() {
    echo ""
    echo "🔄 ЗАМЕНА ДОКУМЕНТА"
    echo "Создаем новый документ, который заменит старый"
    echo ""
    
    # 1. ID заменяемого документа
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
    
    # 2. Создаем НОВЫЙ документ (не выбираем существующий)
    echo ""
    echo "=== СОЗДАНИЕ НОВОГО ДОКУМЕНТА ==="
    
    # Определяем уровень
    local level=$(echo "$target_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
    read -p "Введите название для нового документа: " new_name
    if [ -z "$new_name" ]; then
        echo "❌ Название не может быть пустым"
        return 1
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
    read -p "Введите теги через запятую: " new_tags
    
    # 3. Сводка
    echo ""
    echo "📋 СВОДКА ЗАМЕНЫ:"
    echo "  ЗАМЕНЯЕМЫЙ (будет заархивирован):"
    echo "    ID: $target_id"
    echo "    Название: $target_name"
    echo ""
    echo "  НОВЫЙ (займет его место):"
    echo "    ID: $target_id (сохраняется)"
    echo "    Название: $new_name"
    echo "    Тип: $type"
    echo "    Уровень: $level"
    echo ""
    
    read -p "Выполнить замену? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 4. Выполняем замену
    echo ""
    echo "🔄 Выполняю замену..."
    
    # 4.1 Создаем директорию для бэкапов
    local backup_dir="changed-backup"
    mkdir -p "$backup_dir"
    
    # 4.2 Архивируем заменяемый документ
    echo "📁 Архивирую заменяемый документ..."
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file="${backup_dir}/${timestamp}-${target_id}-${target_name}.md"
    
    {
        echo "# АРХИВИРОВАН: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "# ЗАМЕНА: $target_id - $target_name → $target_id - $new_name"
        echo "---"
        cat "$target_file"
    } > "$backup_file"
    
    echo "    ✅ Сохранен в: $backup_file"
    
    # 4.3 Определяем родителя (если не уровень 1)
    local parent_id=""
    if [ $level -gt 1 ]; then
        parent_id=$(echo "$target_id" | sed 's/-[^-]*$//')
    fi
    
    # 4.4 Создаем новый документ через нашу систему
    echo "📝 Создаю новый документ..."
    
    if [ -f "$SCRIPT_DIR/document-creator.sh" ]; then
        # Временно переопределяем генерацию ID
        local original_find_free_master_id=$(declare -f find_free_master_id 2>/dev/null || echo "")
        local original_find_free_child_id=$(declare -f find_free_child_id 2>/dev/null || echo "")
        
        # Функция для принудительного использования target_id
        force_id_generator() {
            echo "$1"  # Просто возвращаем переданный ID
        }
        
        # Создаем временный файл с нужным ID
        local temp_id_file=".temp_id_file"
        echo "$target_id" > "$temp_id_file"
        
        # Создаем документ
        if create_real_document "$new_name" "$level" "$type" "$parent_id" "$new_tags"; then
            # Находим созданный файл (последний созданный)
            local latest_md=$(ls -t *.md | head -1)
            if [ -f "$latest_md" ]; then
                # Извлекаем фактический ID из созданного файла
                local created_id=$(echo "$latest_md" | cut -d' ' -f1)
                local created_name=$(echo "$latest_md" | sed "s/^${created_id} - //" | sed 's/.md$//')
                
                # Если ID не совпадает с целевым, переименовываем
                if [ "$created_id" != "$target_id" ]; then
                    local new_filename="${target_id} - ${created_name}.md"
                    echo "  Переименовываю: $latest_md → $new_filename"
                    mv "$latest_md" "$new_filename"
                    latest_md="$new_filename"
                fi
            fi
        fi
        
        # Удаляем временный файл
        rm -f "$temp_id_file"
        
        echo "    ✅ Новый документ создан"
    else
        echo "❌ Не удалось создать документ"
        return 1
    fi
    
    # 4.5 Обновляем ссылки
    echo "🔗 Обновляю ссылки..."
    
    local updated_count=0
    for file in *.md; do
        if [ ! -f "$file" ] || [[ "$file" == *"changed-backup"* ]] || [[ "$(basename "$file")" == "${target_id} - ${new_name}.md" ]]; then
            continue
        fi
        
        if grep -q "\\[\\[${target_id} - ${target_name}\\]\\]" "$file"; then
            echo "  Обновляю: $(basename "$file")"
            sed -i '' "s/\[\[${target_id} - ${target_name}\]\]/\[\[${target_id} - ${new_name}\]\]/g" "$file"
            updated_count=$((updated_count + 1))
        fi
    done
    
    echo "  🔄 Обновлено ссылок: $updated_count"
    
    # 4.6 Удаляем старый файл
    if [ -f "$target_file" ]; then
        rm "$target_file"
        echo "🗑️  Удален старый файл: $(basename "$target_file")"
    fi
    
    echo ""
    echo "✅ ЗАМЕНА ВЫПОЛНЕНА!"
    echo "   📁 Архив: $backup_file"
    echo "   📄 Новый документ: $target_id - $new_name"
}

# Функция смещения документа (исправлено для macOS)
simple_shift_document() {
    echo ""
    echo "📐 СМЕЩЕНИЕ ДОКУМЕНТА"
    echo ""
    
    # 1. Ввод ID
    echo "=== НОВЫЙ ДОКУМЕНТ ==="
    read -p "Введите ID для нового документа: " desired_id
    
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
        echo "Используйте обычное создание документа"
        return 0
    fi
    
    local existing_name=$(basename "$existing_file" .md | sed "s/^${desired_id} - //")
    echo "⚠️  Документ с ID $desired_id уже существует: $existing_name"
    
    # 3. Параметры нового документа
    echo ""
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
    
    # 4. Подтверждение
    echo ""
    echo "⚠️  ВНИМАНИЕ: Будет выполнено смещение!"
    echo "Новый документ: $desired_id - $new_name"
    echo "Существующий будет смещен на +1"
    echo ""
    
    read -p "Подтвердить смещение? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 5. Выполняем смещение
    echo ""
    echo "🔄 Выполняю смещение..."
    
    # 5.1 Вычисляем смещенный ID
    local last_part=$(echo "$desired_id" | grep -o '[^-]*$')
    local base_part=$(echo "$desired_id" | sed "s/-${last_part}$//")
    
    # Конвертируем HEX в decimal (без ведущего нуля для octal)
    local last_hex_clean=$(echo "$last_part" | sed 's/^0*//')
    if [ -z "$last_hex_clean" ]; then
        last_hex_clean="0"
    fi
    local last_decimal=$(printf "%d" "0x$last_hex_clean")
    local new_last_decimal=$((last_decimal + 1))
    local new_last_hex=$(printf "%02X" $new_last_decimal)
    local shifted_id="${base_part}-${new_last_hex}"
    
    echo "   Существующий: $desired_id → $shifted_id"
    
    # 5.2 Находим все документы для смещения
    local files_to_shift=""
    files_to_shift="$existing_file"
    
    # Дочерние документы
    local child_pattern="${desired_id}-[0-9A-Fa-f][0-9A-Fa-f]"
    for child_file in $(find . -maxdepth 1 -name "${child_pattern} - *.md" -type f); do
        files_to_shift="$files_to_shift $child_file"
    done
    
    echo "   Найдено документов: $(echo "$files_to_shift" | wc -w | tr -d ' ')"
    
    # 5.3 Создаем карту смещения через временные файлы
    for old_file in $files_to_shift; do
        local old_id=$(basename "$old_file" | cut -d' ' -f1)
        local old_name=$(basename "$old_file" .md | sed "s/^${old_id} - //")
        
        # Вычисляем новый ID
        local new_id="$old_id"
        if [ "$old_id" = "$desired_id" ]; then
            new_id="$shifted_id"
        elif [[ "$old_id" == "$desired_id"-* ]]; then
            new_id=$(echo "$old_id" | sed "s/^${desired_id}/${shifted_id}/")
        fi
        
        echo "     $old_id → $new_id"
        
        # Создаем временную копию с новым ID
        local temp_file="TEMP-${new_id}-${old_name}.md"
        
        # Обновляем ID в файле
        sed "s/^id: \"${old_id}\"/id: \"${new_id}\"/" "$old_file" > "$temp_file"
    done
    
    # 5.4 Создаем новый документ с желаемым ID
    echo ""
    echo "📝 Создаю новый документ: $desired_id - $new_name"
    
    # Определяем родителя
    local parent_id=""
    if [ $level -gt 1 ]; then
        parent_id="$base_part"
    fi
    
    # Используем функцию создания документа с принудительным ID
    if [ -f "$SCRIPT_DIR/document-creator.sh" ]; then
        # Создаем временную переменную окружения для ID
        export FORCE_ID="$desired_id"
        
        # Создаем документ
        if create_real_document "$new_name" "$level" "$type" "$parent_id" "$tags"; then
            # Находим и переименовываем если нужно
            sleep 1
            local created_file=$(find . -maxdepth 1 -name "*${new_name}.md" -type f | head -1)
            if [ -n "$created_file" ]; then
                local created_id=$(basename "$created_file" | cut -d' ' -f1)
                if [ "$created_id" != "$desired_id" ]; then
                    mv "$created_file" "${desired_id} - ${new_name}.md"
                fi
            fi
        fi
        
        unset FORCE_ID
    fi
    
    # 5.5 Удаляем оригинальные файлы и переименовываем временные
    echo "📝 Применяю смещенные имена..."
    
    for old_file in $files_to_shift; do
        rm "$old_file"
    done
    
    for temp_file in TEMP-*.md; do
        if [ -f "$temp_file" ]; then
            local perm_name=$(echo "$temp_file" | sed 's/^TEMP-//')
            mv "$temp_file" "$perm_name"
            echo "   ✅ $perm_name"
        fi
    done
    
    # 5.6 Обновляем ссылки
    echo "🔗 Обновляю ссылки..."
    
    local updated_count=0
    for file in *.md; do
        if [ ! -f "$file" ] || [[ "$file" == *"changed-backup"* ]]; then
            continue
        fi
        
        local file_changed=0
        
        # Обновляем ссылки на старый документ
        if grep -q "\\[\\[${desired_id} - ${existing_name}\\]\\]" "$file"; then
            sed -i '' "s/\[\[${desired_id} - ${existing_name}\]\]/\[\[${shifted_id} - ${existing_name}\]\]/g" "$file"
            file_changed=1
        fi
        
        # Обновляем ссылки на дочерние документы
        for child_file in $(find . -maxdepth 1 -name "${shifted_id}-[0-9A-Fa-f][0-9A-Fa-f] - *.md" -type f); do
            local child_id=$(basename "$child_file" | cut -d' ' -f1)
            local child_name=$(basename "$child_file" .md | sed "s/^${child_id} - //")
            local old_child_id=$(echo "$child_id" | sed "s/^${shifted_id}/${desired_id}/")
            
            if grep -q "\\[\\[${old_child_id} - " "$file"; then
                sed -i '' "s/\[\[${old_child_id} - /\[\[${child_id} - /g" "$file"
                file_changed=1
            fi
        done
        
        if [ $file_changed -eq 1 ]; then
            updated_count=$((updated_count + 1))
        fi
    done
    
    echo "   🔄 Обновлено документов: $updated_count"
    
    echo ""
    echo "✅ СМЕЩЕНИЕ ВЫПОЛНЕНО!"
    echo "   📝 Новый документ: $desired_id - $new_name"
    echo "   🔄 Смещенный: $shifted_id - $existing_name"
}

# Главное меню
show_document_operations_menu() {
    echo ""
    echo "=== ОПЕРАЦИИ С ДОКУМЕНТАМИ ==="
    echo "1 - Заменить документ (создать новый на месте старого)"
    echo "2 - Сместить документ (вставить новый, сдвинуть существующий)"
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
