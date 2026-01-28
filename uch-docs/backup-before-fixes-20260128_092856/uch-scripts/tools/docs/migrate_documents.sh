#!/bin/bash

echo "🚀 ЗАПУСК МИГРАЦИИ ДОКУМЕНТОВ UCH-DOCS"
echo "======================================"
echo ""

# Создаем директорию для backup
backup_dir="migration-backup/full-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

# Создаем лог миграции
log_file="$backup_dir/migration_log.txt"
echo "Лог миграции документов UCH-DOCS" > "$log_file"
echo "Дата: $(date)" >> "$log_file"
echo "==========================================" >> "$log_file"

# Счетчики
migrated_count=0
skipped_count=0
error_count=0

# Функция для генерации slug
generate_slug() {
    local hex_id="$1"
    local doc_type="$2"
    
    # Извлекаем последнюю часть HEX
    local last_part="${hex_id##*-}"
    
    # Генерируем slug: HEX-TYPE-LAST_PART
    echo "${hex_id}-${doc_type}-${last_part}"
}

# Мигрируем документы
find . -name "*.md" -type f | while read old_file; do
    # Пропускаем файлы в backup директориях
    if [[ "$old_file" == ./migration-backup/* ]] || [[ "$old_file" == ./archive/* ]] || [[ "$old_file" == ./changed-backup/* ]]; then
        echo "⏩ Пропускаем backup файл: $old_file" >> "$log_file"
        skipped_count=$((skipped_count + 1))
        continue
    fi
    
    if grep -q "^id:" "$old_file"; then
        # Извлекаем данные из YAML frontmatter
        id=$(grep "^id:" "$old_file" | head -1 | sed 's/^id: *"\(.*\)"/\1/' | tr -d '"' | xargs)
        type=$(grep "^type:" "$old_file" 2>/dev/null | head -1 | sed 's/^type: *"\(.*\)"/\1/' | tr -d '"' | xargs || echo "N/A")
        name=$(basename "$old_file" .md)
        
        # Определяем новый ID по целевой системе
        IFS='-' read -r -a parts <<< "$id"
        
        if [[ "$id" == "00" ]]; then
            # UCH hub - остается как есть
            new_id="00"
            new_level=1
            new_type="hub"
            
        elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 2 ]]; then
            # 00-XX -> должен стать XX (уровень 1)
            new_id="${parts[1]}"
            new_level=1
            
            # Определяем тип
            if [[ "$name" == *"Линия"* ]] || [[ "$name" == *"Документация"* ]]; then
                new_type="line"
            elif [[ "$name" == *"Блог"* ]]; then
                new_type="line"
            elif [[ "$name" == *"Студия"* ]]; then
                new_type="line"
            else
                new_type="line"
            fi
            
        elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 3 ]]; then
            # 00-XX-YY -> должен стать XX-YY (уровень 2)
            new_id="${parts[1]}-${parts[2]}"
            new_level=2
            
            # Определяем тип
            if [[ "$type" == "snapshot" ]]; then
                new_type="$type"
            elif [[ "$type" == "epic" || "$type" == "component" || "$type" == "module" ]]; then
                new_type="$type"
            else
                new_type="epic"
            fi
            
        elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 4 ]]; then
            # 00-XX-YY-ZZ -> должен стать XX-YY-ZZ (уровень 3)
            new_id="${parts[1]}-${parts[2]}-${parts[3]}"
            new_level=3
            
            # Определяем тип
            if [[ "$type" == "task" || "$type" == "feature" || "$type" == "bug" || "$type" == "research" ]]; then
                new_type="$type"
            else
                new_type="task"
            fi
            
        else
            # Неизвестный формат или неиерархические документы - пропускаем
            echo "⏩ Пропускаем (неизвестный формат): $old_file" >> "$log_file"
            skipped_count=$((skipped_count + 1))
            continue
        fi
        
        # Генерируем новое имя файла
        if [[ "$id" == "$new_id" ]]; then
            # ID не изменился
            new_file="$old_file"
        else
            # Формируем новое имя файла
            new_filename="${new_id} - ${name#* - }"
            new_file="./$new_filename.md"
            
            # Если новое имя совпадает со старым (без префикса 00-), оставляем как есть
            if [[ "$new_file" == "$old_file" ]]; then
                new_file="$old_file"
            fi
        fi
        
        # Генерируем slug
        slug=$(generate_slug "$new_id" "$new_type")
        
        # Backup старого файла
        cp "$old_file" "$backup_dir/$(basename "$old_file")"
        
        # Обновляем файл с новыми метаданными
        if [[ "$old_file" != "$new_file" ]]; then
            echo "🔄 Миграция: $old_file -> $new_file" | tee -a "$log_file"
            
            # Создаем новый файл с обновленным YAML
            {
                # Копируем YAML frontmatter с обновлениями
                awk '/^---$/{if(++count==1)print; next} 
                     count==1 && /^id:/ {print "id: \"'"$new_id"'\""; next}
                     count==1 && /^type:/ {print "type: \"'"$new_type"'\""; next}
                     count==1 && /^level:/ {print "level: '"$new_level"'"; next}
                     count==1 && /^slug:/ {print "slug: \"'"$slug"'\""; next}
                     count==1 && !/^slug:/ && !/^---$/ {print}
                     count==1 && /^---$/ {print "slug: \"'"$slug"'\""; print "---"; count++; next}
                     count>=2 {print}' "$old_file"
            } > "$new_file"
            
            # Удаляем старый файл, если он отличается от нового
            if [[ "$old_file" != "$new_file" ]]; then
                rm "$old_file"
            fi
            
        else
            echo "✏️  Обновление: $old_file" | tee -a "$log_file"
            
            # Обновляем существующий файл
            temp_file="${old_file}.temp"
            {
                awk '/^---$/{if(++count==1)print; next} 
                     count==1 && /^id:/ {print "id: \"'"$new_id"'\""; next}
                     count==1 && /^type:/ {print "type: \"'"$new_type"'\""; next}
                     count==1 && /^level:/ {print "level: '"$new_level"'"; next}
                     count==1 && /^slug:/ {print "slug: \"'"$slug"'\""; next}
                     count==1 && !/^slug:/ && !/^---$/ {print}
                     count==1 && /^---$/ {print "slug: \"'"$slug"'\""; print "---"; count++; next}
                     count>=2 {print}' "$old_file"
            } > "$temp_file"
            
            mv "$temp_file" "$old_file"
        fi
        
        migrated_count=$((migrated_count + 1))
        echo "   Старый ID: $id -> Новый ID: $new_id" >> "$log_file"
        echo "   Тип: $new_type, Уровень: $new_level, Slug: $slug" >> "$log_file"
        echo "   ---" >> "$log_file"
        
    else
        echo "⏩ Пропускаем (нет ID): $old_file" >> "$log_file"
        skipped_count=$((skipped_count + 1))
    fi
done

echo ""
echo "✅ МИГРАЦИЯ ЗАВЕРШЕНА!"
echo "📊 РЕЗУЛЬТАТЫ:"
echo "   Мигрировано документов: $migrated_count"
echo "   Пропущено документов: $skipped_count"
echo "   Ошибок: $error_count"
echo ""
echo "📁 Backup сохранен в: $backup_dir/"
echo "📄 Лог миграции: $log_file"
echo ""
echo "🔍 ДЛЯ ПРОВЕРКИ выполните:"
echo "   ls -la *.md | head -20"
echo "   grep -l 'slug:' *.md | head -10"
