#!/bin/bash
# Упрощенные функции замены и смещения

# ПРОСТАЯ ЗАМЕНА: создать новый документ с указанным ID
simple_replace() {
    echo ""
    echo "🔄 ПРОСТАЯ ЗАМЕНА"
    echo ""
    
    # 1. ID заменяемого документа
    echo "=== ЗАМЕНЯЕМЫЙ ДОКУМЕНТ ==="
    read -p "Введите ID документа, который будет заменен: " target_id
    
    if [ -z "$target_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # Ищем файл
    local target_file=$(ls -1 "${target_id} - "*.md 2>/dev/null | head -1)
    if [ -z "$target_file" ]; then
        echo "❌ Документ с ID '$target_id' не найден"
        return 1
    fi
    
    local target_name=$(basename "$target_file" .md | sed "s/^${target_id} - //")
    echo "Найден: $target_name"
    
    # 2. Параметры нового документа
    echo ""
    echo "=== НОВЫЙ ДОКУМЕНТ ==="
    read -p "Введите название нового документа: " new_name
    
    if [ -z "$new_name" ]; then
        echo "❌ Название не может быть пустым"
        return 1
    fi
    
    # Уровень
    local level=$(echo "$target_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
    # Тип
    if [ -f "$SCRIPT_DIR/types.sh" ]; then
        source "$SCRIPT_DIR/types.sh"
        show_type_menu_for_level "$level"
        type=$(select_type_by_number "$level")
    else
        type="task"
    fi
    
    # Теги
    echo ""
    read -p "Введите теги через запятую: " tags
    
    # 3. Подтверждение
    echo ""
    echo "📋 СВОДКА:"
    echo "  Заменяем: $target_id - $target_name"
    echo "  Новый:    $target_id - $new_name"
    echo "  Тип: $type, Уровень: $level"
    echo ""
    
    read -p "Выполнить замену? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 4. Выполняем замену
    echo ""
    echo "🔄 Выполняю замену..."
    
    # 4.1 Создаем бэкап
    local backup_dir="changed-backup"
    mkdir -p "$backup_dir"
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file="${backup_dir}/${timestamp}-$(basename "$target_file")"
    
    cp "$target_file" "$backup_file"
    echo "📁 Архив: $backup_file"
    
    # 4.2 Определяем родителя
    local parent_id=""
    local parent_name=""
    if [ $level -gt 1 ]; then
        parent_id=$(echo "$target_id" | sed 's/-[^-]*$//')
        local parent_file=$(ls -1 "${parent_id} - "*.md 2>/dev/null | head -1)
        if [ -n "$parent_file" ]; then
            parent_name=$(basename "$parent_file" .md | sed "s/^${parent_id} - //")
        fi
    fi
    
    # 4.3 Создаем новый документ ВРУЧНУЮ
    local new_filename="${target_id} - ${new_name}.md"
    local current_date=$(date +%Y-%m-%d)
    
    echo "📝 Создаю: $new_filename"
    
    # Форматируем теги
    local tags_yaml="tags:"
    tags_yaml="$tags_yaml"$'\n'"  - \"$type\""
    if [ -n "$tags" ]; then
        IFS=',' read -r -a tag_array <<< "$tags"
        for tag in "${tag_array[@]}"; do
            tag_clean=$(echo "$tag" | xargs)
            if [ -n "$tag_clean" ]; then
                tags_yaml="$tags_yaml"$'\n'"  - \"$tag_clean\""
            fi
        done
    fi
    
    # Создаем файл
    cat > "$new_filename" << DOC_EOF
---
id: "$target_id"
name: "$new_name"
type: "$type"
level: $level
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $new_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$target_id\`
- **Уровень**: $level
DOC_EOF
    
    if [ -n "$parent_id" ] && [ -n "$parent_name" ]; then
        cat >> "$new_filename" << DOC_EOF
- **Родитель**: [[$parent_id - $parent_name]]
DOC_EOF
    fi
    
    cat >> "$new_filename" << DOC_EOF
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### ОПИСАНИЕ
Добавьте описание здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $current_date
Уровень: $level
DOC_EOF
    
    if [ -n "$parent_id" ]; then
        echo "Родитель: $parent_id" >> "$new_filename"
    fi
    
    # 4.4 Удаляем старый файл
    rm "$target_file"
    echo "🗑️  Удален: $(basename "$target_file")"
    
    # 4.5 Обновляем ссылки (простая замена)
    echo "🔗 Обновляю ссылки..."
    local updated=0
    
    for file in *.md; do
        if [ ! -f "$file" ] || [[ "$file" == "$new_filename" ]] || [[ "$file" == *"changed-backup"* ]]; then
            continue
        fi
        
        if grep -q "\\[\\[${target_id} - ${target_name}\\]\\]" "$file"; then
            sed -i '' "s/\[\[${target_id} - ${target_name}\]\]/\[\[${target_id} - ${new_name}\]\]/g" "$file"
            updated=$((updated + 1))
            echo "  ✅ $(basename "$file")"
        fi
    done
    
    echo "  🔄 Обновлено: $updated"
    
    echo ""
    echo "✅ ЗАМЕНА ВЫПОЛНЕНА!"
    echo "   📁 Архив: $backup_file"
    echo "   📄 Новый: $new_filename"
}

# ПРОСТОЕ СМЕЩЕНИЕ
simple_shift() {
    echo ""
    echo "📐 ПРОСТОЕ СМЕЩЕНИЕ"
    echo ""
    
    # 1. Желаемый ID
    echo "=== ЖЕЛАЕМЫЙ ID ==="
    read -p "Введите ID для нового документа: " desired_id
    
    if [ -z "$desired_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # Проверяем существование
    local existing_file=$(ls -1 "${desired_id} - "*.md 2>/dev/null | head -1)
    
    if [ -z "$existing_file" ]; then
        echo "✅ ID $desired_id свободен"
        echo "Используйте обычное создание"
        return 0
    fi
    
    local existing_name=$(basename "$existing_file" .md | sed "s/^${desired_id} - //")
    echo "⚠️  Существует: $existing_name"
    
    # 2. Параметры нового
    echo ""
    echo "=== НОВЫЙ ДОКУМЕНТ ==="
    read -p "Название нового документа: " new_name
    
    if [ -z "$new_name" ]; then
        echo "❌ Название не может быть пустым"
        return 1
    fi
    
    # Уровень
    local level=$(echo "$desired_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
    # Тип
    if [ -f "$SCRIPT_DIR/types.sh" ]; then
        source "$SCRIPT_DIR/types.sh"
        show_type_menu_for_level "$level"
        type=$(select_type_by_number "$level")
    else
        type="task"
    fi
    
    # Теги
    echo ""
    read -p "Теги через запятую: " tags
    
    # 3. Вычисляем смещенный ID
    local last_part=$(echo "$desired_id" | grep -o '[^-]*$')
    local base_part=$(echo "$desired_id" | sed "s/-${last_part}$//")
    
    # HEX → decimal → +1 → HEX
    local last_decimal=$((16#${last_part}))
    local new_last_decimal=$((last_decimal + 1))
    local new_last_hex=$(printf "%02X" $new_last_decimal)
    local shifted_id="${base_part}-${new_last_hex}"
    
    echo ""
    echo "📋 ПЛАН СМЕЩЕНИЯ:"
    echo "  Новый документ: $desired_id - $new_name"
    echo "  Существующий:   $desired_id → $shifted_id"
    echo "  Название:       $existing_name"
    echo ""
    
    read -p "Подтвердить? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 4. Выполняем смещение
    echo ""
    echo "🔄 Выполняю смещение..."
    
    # 4.1 Смещаем существующий документ
    echo "  📝 Смещаем: $existing_file → $shifted_id - $existing_name.md"
    
    # Обновляем ID внутри файла
    sed "s/^id: \"${desired_id}\"/id: \"${shifted_id}\"/" "$existing_file" > "${shifted_id} - ${existing_name}.md"
    rm "$existing_file"
    
    # 4.2 Создаем новый документ с desired_id
    echo "  📝 Создаем новый: $desired_id - $new_name.md"
    
    # Определяем родителя
    local parent_id=""
    local parent_name=""
    if [ $level -gt 1 ]; then
        parent_id="$base_part"
        local parent_file=$(ls -1 "${parent_id} - "*.md 2>/dev/null | head -1)
        if [ -n "$parent_file" ]; then
            parent_name=$(basename "$parent_file" .md | sed "s/^${parent_id} - //")
        fi
    fi
    
    # Создаем новый файл
    local new_filename="${desired_id} - ${new_name}.md"
    local current_date=$(date +%Y-%m-%d)
    
    # Форматируем теги
    local tags_yaml="tags:"
    tags_yaml="$tags_yaml"$'\n'"  - \"$type\""
    if [ -n "$tags" ]; then
        IFS=',' read -r -a tag_array <<< "$tags"
        for tag in "${tag_array[@]}"; do
            tag_clean=$(echo "$tag" | xargs)
            if [ -n "$tag_clean" ]; then
                tags_yaml="$tags_yaml"$'\n'"  - \"$tag_clean\""
            fi
        done
    fi
    
    cat > "$new_filename" << DOC_EOF
---
id: "$desired_id"
name: "$new_name"
type: "$type"
level: $level
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $new_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$desired_id\`
- **Уровень**: $level
DOC_EOF
    
    if [ -n "$parent_id" ] && [ -n "$parent_name" ]; then
        cat >> "$new_filename" << DOC_EOF
- **Родитель**: [[$parent_id - $parent_name]]
DOC_EOF
    fi
    
    cat >> "$new_filename" << DOC_EOF
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### ОПИСАНИЕ
Добавьте описание здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $current_date
Уровень: $level
DOC_EOF
    
    if [ -n "$parent_id" ]; then
        echo "Родитель: $parent_id" >> "$new_filename"
    fi
    
    # 4.3 Обновляем ссылки
    echo "  🔗 Обновляю ссылки..."
    local updated=0
    
    for file in *.md; do
        if [ ! -f "$file" ] || [[ "$file" == *"changed-backup"* ]]; then
            continue
        fi
        
        local file_updated=0
        
        # Ссылки на старый документ
        if grep -q "\\[\\[${desired_id} - ${existing_name}\\]\\]" "$file"; then
            sed -i '' "s/\[\[${desired_id} - ${existing_name}\]\]/\[\[${shifted_id} - ${existing_name}\]\]/g" "$file"
            file_updated=1
        fi
        
        if [ $file_updated -eq 1 ]; then
            updated=$((updated + 1))
            echo "    ✅ $(basename "$file")"
        fi
    done
    
    echo "  🔄 Обновлено: $updated"
    
    echo ""
    echo "✅ СМЕЩЕНИЕ ВЫПОЛНЕНО!"
    echo "   📝 Новый: $desired_id - $new_name"
    echo "   🔄 Смещенный: $shifted_id - $existing_name"
}

# Меню
show_simple_operations_menu() {
    echo ""
    echo "=== ПРОСТЫЕ ОПЕРАЦИИ ==="
    echo "1 - Заменить документ (создать новый с тем же ID)"
    echo "2 - Сместить документ (вставить новый, сдвинуть существующий)"
    echo "3 - Назад"
    echo ""
    read -p "Выбор (1-3): " choice
    
    case $choice in
        1) simple_replace ;;
        2) simple_shift ;;
        3) return 0 ;;
        *) echo "❌ Неверный выбор" ;;
    esac
}
#!/bin/bash
# Улучшенное смещение с рекурсивной цепочкой

# Найти следующий свободный ID для смещения
find_next_free_id() {
    local base_id="$1"
    local last_part=$(echo "$base_id" | grep -o '[^-]*$')
    local base_part=$(echo "$base_id" | sed "s/-${last_part}$//")
    
    local current_decimal=$((16#${last_part}))
    local try_decimal=$((current_decimal + 1))
    
    # Ищем свободный ID, увеличивая на 1 пока не найдем свободный
    while true; do
        local try_hex=$(printf "%02X" $try_decimal)
        local try_id="${base_part}-${try_hex}"
        
        # Проверяем существует ли документ с таким ID
        if ! ls -1 "${try_id} - "*.md 2>/dev/null | grep -q .; then
            echo "$try_id"
            return 0
        fi
        
        # Если существует, пробуем следующий
        try_decimal=$((try_decimal + 1))
        
        # Защита от бесконечного цикла (максимум 255 попыток)
        if [ $try_decimal -gt 255 ]; then
            echo "❌ Не удалось найти свободный ID"
            return 1
        fi
    done
}

# Создать цепочку смещения
create_shift_chain() {
    local start_id="$1"
    
    echo "  �� Создаю цепочку смещения начиная с: $start_id"
    
    local current_id="$start_id"
    local shift_map=""
    
    # Собираем все существующие ID на этом уровне
    local base_part=$(echo "$start_id" | sed 's/-[^-]*$//')
    local existing_ids=$(ls -1 "${base_part}-"*.md 2>/dev/null | \
        grep -E "^${base_part}-[0-9A-Fa-f]{2} " | \
        cut -d' ' -f1 | \
        sort)
    
    # Находим последнюю часть start_id в decimal
    local start_last=$(echo "$start_id" | grep -o '[^-]*$')
    local start_decimal=$((16#${start_last}))
    
    # Проходим по всем ID начиная с start_id
    for id in $existing_ids; do
        local last_part=$(echo "$id" | grep -o '[^-]*$')
        local current_decimal=$((16#${last_part}))
        
        # Если ID >= start_id, добавляем в цепочку смещения
        if [ $current_decimal -ge $start_decimal ]; then
            local new_decimal=$((current_decimal + 1))
            local new_hex=$(printf "%02X" $new_decimal)
            local new_id="${base_part}-${new_hex}"
            
            shift_map="$shift_map $id:$new_id"
            echo "    $id → $new_id"
        fi
    done
    
    echo "$shift_map"
}

# Улучшенное смещение с цепочкой
improved_shift() {
    echo ""
    echo "📐 УЛУЧШЕННОЕ СМЕЩЕНИЕ"
    echo "Все документы будут сдвинуты по цепочке"
    echo ""
    
    # 1. Желаемый ID
    echo "=== ЖЕЛАЕМЫЙ ID ==="
    read -p "Введите ID для нового документа: " desired_id
    
    if [ -z "$desired_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # 2. Проверяем что ID не занят (но это нормально для смещения)
    local existing_file=$(ls -1 "${desired_id} - "*.md 2>/dev/null | head -1)
    local existing_name=""
    
    if [ -n "$existing_file" ]; then
        existing_name=$(basename "$existing_file" .md | sed "s/^${desired_id} - //")
        echo "⚠️  Документ с ID $desired_id уже существует: $existing_name"
    else
        echo "✅ ID $desired_id свободен (простое создание)"
        # Можно предложить просто создать документ
    fi
    
    # 3. Параметры нового документа
    echo ""
    echo "=== НОВЫЙ ДОКУМЕНТ ==="
    read -p "Название нового документа: " new_name
    
    if [ -z "$new_name" ]; then
        echo "❌ Название не может быть пустым"
        return 1
    fi
    
    # Уровень
    local level=$(echo "$desired_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
    # Тип
    if [ -f "$SCRIPT_DIR/types.sh" ]; then
        source "$SCRIPT_DIR/types.sh"
        show_type_menu_for_level "$level"
        type=$(select_type_by_number "$level")
    else
        type="task"
    fi
    
    # Теги
    echo ""
    read -p "Теги через запятую: " tags
    
    # 4. Создаем цепочку смещения
    echo ""
    echo "=== ЦЕПОЧКА СМЕЩЕНИЯ ==="
    
    local shift_chain=$(create_shift_chain "$desired_id")
    if [ -z "$shift_chain" ]; then
        echo "❌ Не удалось создать цепочку смещения"
        return 1
    fi
    
    # Считаем сколько документов будет смещено
    local shift_count=$(echo "$shift_chain" | tr ' ' '\n' | grep -c ':')
    echo "  📊 Будет смещено документов: $shift_count"
    
    # 5. Предупреждение
    echo ""
    echo "⚠️  ВНИМАНИЕ: Будут смещены следующие документы:"
    for pair in $shift_chain; do
        local old_id=$(echo "$pair" | cut -d: -f1)
        local new_id=$(echo "$pair" | cut -d: -f2)
        local old_name=""
        
        # Находим имя документа
        local old_file=$(ls -1 "${old_id} - "*.md 2>/dev/null | head -1)
        if [ -n "$old_file" ]; then
            old_name=$(basename "$old_file" .md | sed "s/^${old_id} - //")
            echo "    $old_id - $old_name → $new_id"
        else
            echo "    $old_id → $new_id"
        fi
    done
    
    echo ""
    read -p "Подтвердить смещение ВСЕХ документов? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 6. Выполняем смещение в обратном порядке (с конца)
    echo ""
    echo "🔄 Выполняю смещение..."
    
    # Сначала смещаем существующие документы (с конца чтобы не перезаписать)
    echo "  📝 Смещаю существующие документы..."
    
    # Сортируем пары в обратном порядке (по ID)
    local reverse_pairs=$(echo "$shift_chain" | tr ' ' '\n' | sort -r)
    
    for pair in $reverse_pairs; do
        local old_id=$(echo "$pair" | cut -d: -f1)
        local new_id=$(echo "$pair" | cut -d: -f2)
        
        local old_file=$(ls -1 "${old_id} - "*.md 2>/dev/null | head -1)
        if [ -n "$old_file" ]; then
            local old_name=$(basename "$old_file" .md | sed "s/^${old_id} - //")
            local new_filename="${new_id} - ${old_name}.md"
            
            echo "    $old_id → $new_id"
            
            # Копируем и обновляем ID
            sed "s/^id: \"${old_id}\"/id: \"${new_id}\"/" "$old_file" > "$new_filename"
            
            # Удаляем старый файл
            rm "$old_file"
        fi
    done
    
    # 7. Создаем новый документ с desired_id
    echo ""
    echo "  📝 Создаю новый документ: $desired_id - $new_name"
    
    # Определяем родителя
    local parent_id=""
    local parent_name=""
    if [ $level -gt 1 ]; then
        parent_id=$(echo "$desired_id" | sed 's/-[^-]*$//')
        local parent_file=$(ls -1 "${parent_id} - "*.md 2>/dev/null | head -1)
        if [ -n "$parent_file" ]; then
            parent_name=$(basename "$parent_file" .md | sed "s/^${parent_id} - //")
        fi
    fi
    
    # Создаем новый файл
    local new_filename="${desired_id} - ${new_name}.md"
    local current_date=$(date +%Y-%m-%d)
    
    # Форматируем теги
    local tags_yaml="tags:"
    tags_yaml="$tags_yaml"$'\n'"  - \"$type\""
    if [ -n "$tags" ]; then
        IFS=',' read -r -a tag_array <<< "$tags"
        for tag in "${tag_array[@]}"; do
            tag_clean=$(echo "$tag" | xargs)
            if [ -n "$tag_clean" ]; then
                tags_yaml="$tags_yaml"$'\n'"  - \"$tag_clean\""
            fi
        done
    fi
    
    cat > "$new_filename" << DOC_EOF
---
id: "$desired_id"
name: "$new_name"
type: "$type"
level: $level
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $new_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$desired_id\`
- **Уровень**: $level
DOC_EOF
    
    if [ -n "$parent_id" ] && [ -n "$parent_name" ]; then
        cat >> "$new_filename" << DOC_EOF
- **Родитель**: [[$parent_id - $parent_name]]
DOC_EOF
    fi
    
    cat >> "$new_filename" << DOC_EOF
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### ОПИСАНИЕ
Добавьте описание здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $current_date
Уровень: $level
DOC_EOF
    
    if [ -n "$parent_id" ]; then
        echo "Родитель: $parent_id" >> "$new_filename"
    fi
    
    # 8. Обновляем ссылки
    echo ""
    echo "  🔗 Обновляю ссылки..."
    local updated=0
    
    for pair in $shift_chain; do
        local old_id=$(echo "$pair" | cut -d: -f1)
        local new_id=$(echo "$pair" | cut -d: -f2)
        
        # Находим имя документа
        local new_file=$(ls -1 "${new_id} - "*.md 2>/dev/null | head -1)
        if [ -n "$new_file" ]; then
            local doc_name=$(basename "$new_file" .md | sed "s/^${new_id} - //")
            
            # Обновляем ссылки во всех документах
            for file in *.md; do
                if [ ! -f "$file" ] || [[ "$file" == *"changed-backup"* ]]; then
                    continue
                fi
                
                if grep -q "\\[\\[${old_id} - ${doc_name}\\]\\]" "$file"; then
                    sed -i '' "s/\[\[${old_id} - ${doc_name}\]\]/\[\[${new_id} - ${doc_name}\]\]/g" "$file"
                    updated=$((updated + 1))
                fi
            done
        fi
    done
    
    echo "    🔄 Обновлено ссылок: $updated"
    
    echo ""
    echo "✅ СМЕЩЕНИЕ ВЫПОЛНЕНО!"
    echo "   📝 Новый документ: $desired_id - $new_name"
    echo "   🔄 Смещено документов: $shift_count"
    echo "   🔗 Обновлено ссылок: $updated"
}

# Объединяем обе функции
show_simple_operations_menu() {
    echo ""
    echo "=== ОПЕРАЦИИ С ДОКУМЕНТАМИ ==="
    echo "1 - Заменить документ (простая замена)"
    echo "2 - Сместить документ (цепочное смещение)"
    echo "3 - Назад"
    echo ""
    read -p "Выбор (1-3): " choice
    
    case $choice in
        1) 
            # Используем существующую simple_replace из replace-shift.sh
            if command -v simple_replace &> /dev/null; then
                simple_replace
            else
                echo "❌ Функция замены не найдена"
            fi
            ;;
        2) 
            improved_shift 
            ;;
        3) 
            return 0 
            ;;
        *) 
            echo "❌ Неверный выбор" 
            ;;
    esac
}
