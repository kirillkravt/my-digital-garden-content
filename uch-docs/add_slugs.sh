#!/bin/bash

echo "🚀 ДОБАВЛЕНИЕ SLUG И ИСПРАВЛЕНИЕ ТИПОВ"
echo "====================================="
echo ""

# Создаем backup
backup_dir="slug-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

# Счетчики
updated_count=0
skipped_count=0

# Функция для определения типа по уровню и имени
get_doc_type() {
    local level="$1"
    local id="$2"
    local name="$3"
    local current_type="$4"
    
    case "$level" in
        1)
            # Уровень 1: XX
            if [[ "$id" == "00" ]]; then
                echo "hub"
            elif [[ "$name" == *"Линия"* ]] || [[ "$name" == *"Документация"* ]] || 
                 [[ "$name" == *"Блог"* ]] || [[ "$name" == *"Студия"* ]] || 
                 [[ "$name" == *"Процессы"* ]]; then
                echo "line"
            else
                echo "line"  # по умолчанию
            fi
            ;;
        2)
            # Уровень 2: XX-YY
            if [[ "$current_type" == "snapshot" ]]; then
                echo "snapshot"
            elif [[ "$current_type" == "epic" || "$current_type" == "component" || "$current_type" == "module" ]]; then
                echo "$current_type"
            elif [[ "$name" == *"Снапшот"* ]] || [[ "$name" == *"snapshot"* ]]; then
                echo "snapshot"
            else
                echo "epic"  # по умолчанию
            fi
            ;;
        3)
            # Уровень 3: XX-YY-ZZ
            if [[ "$current_type" == "task" || "$current_type" == "feature" || "$current_type" == "bug" || "$current_type" == "research" ]]; then
                echo "$current_type"
            elif [[ "$name" == *"Исследование"* ]] || [[ "$name" == *"исследование"* ]]; then
                echo "research"
            elif [[ "$name" == *"Задача"* ]] || [[ "$name" == *"задача"* ]]; then
                echo "task"
            else
                echo "task"  # по умолчанию
            fi
            ;;
        4)
            # Уровень 4: XX-YY-ZZ-AA
            if [[ "$current_type" == "subtask" || "$current_type" == "solution" || "$current_type" == "decision" ]]; then
                echo "$current_type"
            else
                echo "subtask"  # по умолчанию
            fi
            ;;
        *)
            echo "$current_type"
            ;;
    esac
}

# Функция для генерации slug
generate_slug() {
    local id="$1"
    local doc_type="$2"
    
    # Извлекаем последнюю часть HEX
    local last_part="${id##*-}"
    
    # Генерируем slug: HEX-TYPE-LAST_PART
    echo "${id}-${doc_type}-${last_part}"
}

# Обрабатываем файлы по уровням
process_file() {
    local file="$1"
    
    # Backup файла
    cp "$file" "$backup_dir/$(basename "$file")"
    
    # Извлекаем текущие данные
    id=$(grep "^id:" "$file" 2>/dev/null | head -1 | sed 's/^id: *"\(.*\)"/\1/' | tr -d '"' | xargs)
    current_type=$(grep "^type:" "$file" 2>/dev/null | head -1 | sed 's/^type: *"\(.*\)"/\1/' | tr -d '"' | xargs || echo "")
    current_level=$(grep "^level:" "$file" 2>/dev/null | head -1 | sed 's/^level: *\([0-9]*\)/\1/' | xargs || echo "")
    name=$(basename "$file" .md)
    
    # Определяем уровень по ID
    IFS='-' read -r -a parts <<< "$id"
    case "${#parts[@]}" in
        1) level=1 ;;
        2) level=2 ;;
        3) level=3 ;;
        4) level=4 ;;
        *) level=0 ;;
    esac
    
    # Определяем правильный тип
    correct_type=$(get_doc_type "$level" "$id" "$name" "$current_type")
    
    # Генерируем slug
    slug=$(generate_slug "$id" "$correct_type")
    
    # Обновляем файл
    temp_file="${file}.temp"
    
    awk -v id="$id" \
        -v correct_type="$correct_type" \
        -v level="$level" \
        -v slug="$slug" '
    BEGIN { in_frontmatter = 0; frontmatter_end = 0; slug_added = 0 }
    
    /^---$/ {
        if (in_frontmatter == 0) {
            in_frontmatter = 1
            print
            next
        } else {
            frontmatter_end = 1
            # Добавляем slug перед закрытием frontmatter если его еще нет
            if (!slug_added) {
                print "slug: \"" slug "\""
            }
            print "---"
            next
        }
    }
    
    in_frontmatter && !frontmatter_end {
        if (/^id:/) {
            print "id: \"" id "\""
            next
        }
        if (/^type:/) {
            print "type: \"" correct_type "\""
            next
        }
        if (/^level:/) {
            print "level: " level
            next
        }
        if (/^slug:/) {
            print "slug: \"" slug "\""
            slug_added = 1
            next
        }
        print
        next
    }
    
    {
        print
    }
    ' "$file" > "$temp_file"
    
    # Заменяем оригинальный файл
    mv "$temp_file" "$file"
    
    echo "✅ Обновлен: $file"
    echo "   ID: $id, Type: $correct_type, Level: $level, Slug: $slug"
    
    updated_count=$((updated_count + 1))
}

# Специальная обработка для 00 - UCH.md
if [ -f "00 - UCH.md" ]; then
    echo "🔄 ОБРАБОТКА 00 - UCH.md:"
    cp "00 - UCH.md" "$backup_dir/"
    
    # Создаем обновленную версию
    cat > "00 - UCH.md.new" << 'YAMLEOF'
---
id: "00"
slug: "00-hub-00"
name: "UNIVERSAL CREATIVE HUB"
type: "hub"
level: 1
status: "active"
created: "2025-12-25"
updated: "'$(date +%Y-%m-%d)'"
author: "kirillkravcov"
---
YAMLEOF
    
    # Добавляем остальное содержимое (после первого ---)
    awk '/^---$/{if(++count==2) exit} count>=1 {next} {print}' "00 - UCH.md" | tail -n +2 >> "00 - UCH.md.new"
    
    mv "00 - UCH.md.new" "00 - UCH.md"
    echo "✅ Обновлен: 00 - UCH.md (hub, level 1, slug: 00-hub-00)"
    updated_count=$((updated_count + 1))
fi

# Обрабатываем остальные файлы
echo ""
echo "🔄 ОБРАБОТКА ОСТАЛЬНЫХ ФАЙЛОВ:"
echo "=============================="

# Обрабатываем файлы по уровням
for level in 1 2 3 4; do
    case $level in
        1) pattern="[0-9A-F][0-9A-F] - *.md" ;;
        2) pattern="[0-9A-F][0-9A-F]-[0-9A-F][0-9A-F] - *.md" ;;
        3) pattern="[0-9A-F][0-9A-F]-[0-9A-F][0-9A-F]-[0-9A-F][0-9A-F] - *.md" ;;
        4) pattern="[0-9A-F][0-9A-F]-[0-9A-F][0-9A-F]-[0-9A-F][0-9A-F]-[0-9A-F][0-9A-F] - *.md" ;;
    esac
    
    for file in $pattern; do
        if [ -f "$file" ] && [ "$file" != "00 - UCH.md" ]; then
            process_file "$file"
        fi
    done
done

echo ""
echo "✅ ОБНОВЛЕНИЕ ЗАВЕРШЕНО!"
echo "📊 РЕЗУЛЬТАТЫ:"
echo "   Обновлено файлов: $updated_count"
echo "   Пропущено файлов: $skipped_count"
echo "   Backup сохранен в: $backup_dir/"
echo ""
echo "🔍 ДЛЯ ПРОВЕРКИ:"
echo "   grep -l 'slug:' *.md | wc -l"
echo "   grep -h '^type:' *.md | sort | uniq -c"
