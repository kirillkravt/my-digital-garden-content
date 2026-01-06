#!/bin/bash
# fix-doc-names.sh - Исправление имен документов в текущей директории (финальная версия)

echo "=== ИСПРАВЛЕНИЕ ИМЕН ДОКУМЕНТОВ ==="
echo "Текущая директория: $(pwd)"
echo ""

# Функция проверки правильности формата
is_correct_format() {
    local filename="$1"
    
    # Правильный формат: ID тип - Название.md
    # Где название НЕ содержит " - " внутри себя
    
    if [[ ! "$filename" =~ ^[0-9A-F]{2}(-[0-9A-F]{2})*\ [a-z]{2,6}\ -\ .+\.md$ ]]; then
        return 1  # Неправильный формат
    fi
    
    local name_part=$(echo "$filename" | sed -E 's/^[^-]+ - //' | sed 's/\.md$//')
    
    # Проверяем что имя не содержит " - "
    if [[ "$name_part" == *" - "* ]]; then
        return 1  # Имя содержит " - " - неправильно
    fi
    
    return 0  # Правильный формат
}

# Функция для получения сокращенного типа
get_short_type() {
    local type_raw="$1"
    
    case "$type_raw" in
        "documentation"|"doc"|"document") echo "doc" ;;
        "architecture"|"arch") echo "arc" ;;
        "snapshot"|"snap") echo "snap" ;;
        "technicaldebt"|"tdebt") echo "tdebt" ;;
        "analysis"|"analyst"|"analytics") echo "analysis" ;;
        "line") echo "line" ;;
        "project"|"proj") echo "proj" ;;
        "task") echo "task" ;;
        "feature") echo "feat" ;;
        "bug") echo "bug" ;;
        "epic") echo "epic" ;;
        "report") echo "report" ;;
        "idea") echo "idea" ;;
        "component") echo "comp" ;;
        "solution") echo "sol" ;;
        *) echo "task" ;;  # По умолчанию
    esac
}

# Функция для извлечения значения из frontmatter
get_frontmatter_value() {
    local file="$1"
    local field="$2"
    
    local in_frontmatter=0
    local value=""
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^---$ ]]; then
            if [ $in_frontmatter -eq 0 ]; then
                in_frontmatter=1
                continue
            else
                break
            fi
        fi
        
        if [ $in_frontmatter -eq 1 ]; then
            if [[ "$line" =~ ^$field:[[:space:]]*(.*)$ ]]; then
                value="${BASH_REMATCH[1]}"
                value=$(echo "$value" | sed -E 's/^[[:space:]]*//' | sed -E 's/[[:space:]]*$//')
                value=$(echo "$value" | sed -E 's/^"//' | sed -E 's/"$//')
                value=$(echo "$value" | sed -E "s/^'//" | sed -E "s/'$//")
                echo "$value"
                return 0
            fi
        fi
    done < "$file"
    
    echo ""
}

# Создаем backup директорию
backup_dir="doc-names-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
echo "📁 Backup будет создан в: $backup_dir"
echo ""

# Счетчики
total=0
fixed=0
skipped=0
errors=0

# Обрабатываем все .md файлы в текущей директории
for file in *.md; do
    [ -f "$file" ] || continue
    
    total=$((total + 1))
    echo "📄 Файл $total: $file"
    
    # Проверяем правильный ли формат
    if is_correct_format "$file"; then
        echo "   ✅ Правильный формат"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi
    
    echo "   ❌ Неправильный формат - исправляем..."
    
    # 1. Получаем ID из frontmatter (только из frontmatter!)
    id=$(get_frontmatter_value "$file" "id")
    
    if [ -z "$id" ]; then
        echo "   ⚠️  Не найден ID в frontmatter. Пропускаем."
        errors=$((errors + 1))
        echo ""
        continue
    fi
    
    # 2. Получаем тип из frontmatter
    type_raw=$(get_frontmatter_value "$file" "type")
    
    # 3. Определяем сокращенный тип
    doc_type=$(get_short_type "$type_raw")
    
    echo "   🆔 ID: $id"
    echo "   📝 Тип: $doc_type (было: ${type_raw:-не указано})"
    
    # 4. Извлекаем чистое имя
    if [[ "$file" == *" - "* ]]; then
        clean_name=$(echo "$file" | sed 's/.* - //' | sed 's/\.md$//')
    else
        clean_name=$(echo "$file" | sed 's/\.md$//')
    fi
    
    # Убираем возможные цифры и HEX символы из начала
    clean_name=$(echo "$clean_name" | sed -E 's/^[0-9]{2}(-[0-9A-F]{2})*[[:space:]]*//')
    
    echo "   📄 Чистое имя: '$clean_name'"
    
    # 5. Формируем новое имя
    new_name="${id} ${doc_type} - ${clean_name}.md"
    
    echo "   🔧 Новое имя: '$new_name'"
    
    # 6. Проверяем не совпадает ли имя уже
    if [ "$file" = "$new_name" ]; then
        echo "   ⏭️  Имя уже правильное"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi
    
    # 7. Проверяем не существует ли уже файл с таким именем
    if [ -f "$new_name" ]; then
        echo "   ⚠️  Файл '$new_name' уже существует"
        # Добавляем суффикс
        base_name=$(basename "$new_name" .md)
        timestamp=$(date +%H%M%S)
        new_name="${base_name}-${timestamp}.md"
        echo "   💡 Используем: '$new_name'"
    fi
    
    # 8. Создаем backup
    cp "$file" "$backup_dir/"
    
    # 9. Переименовываем
    echo -n "   🔄 Переименовываем... "
    mv "$file" "$new_name"
    
    if [ $? -eq 0 ]; then
        echo "✅"
        fixed=$((fixed + 1))
    else
        echo "❌"
        errors=$((errors + 1))
    fi
    
    echo ""
done

echo "=== РЕЗУЛЬТАТ ==="
echo "Всего файлов: $total"
echo "✅ Исправлено: $fixed"
echo "⏭️  Пропущено (правильные): $skipped"
echo "❌ Ошибок: $errors"
echo "📁 Backup создан в: $backup_dir"
echo ""

if [ $fixed -gt 0 ]; then
    echo "🎉 Имена документов исправлены!"
    echo ""
    echo "Текущие файлы в директории:"
    echo "---------------------------"
    ls -1 *.md 2>/dev/null | head -20
    echo "---------------------------"
    echo "(показаны первые 20 файлов)"
fi
