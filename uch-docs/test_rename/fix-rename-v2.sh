#!/bin/bash
# fix-rename-v2.sh - Исправленная версия переименования

echo "=== ИСПРАВЛЕННОЕ ПЕРЕИМЕНОВАНИЕ ФАЙЛОВ v2 ==="
echo "Убираем начальные цифры и добавляем ID из frontmatter"
echo ""

# Создаем backup
backup_dir="fixed-rename-backup-v2-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
echo "📁 Backup: $backup_dir"
echo ""

# Функция для получения типа документа (сокращенная форма)
get_doc_type() {
    local file="$1"
    # Ищем type в frontmatter
    local type_line=$(grep -E '^type:' "$file" 2>/dev/null | head -1)
    if [ -z "$type_line" ]; then
        echo "task"  # значение по умолчанию
        return
    fi
    
    # Извлекаем значение type (учитываем кавычки и пробелы)
    local type=$(echo "$type_line" | sed -E 's/^type:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/')
    type=$(echo "$type" | tr -d "'" | tr -d '"')
    
    echo "DEBUG: raw type='$type'" >&2
    
    # Сокращения для типов документов
    case "$type" in
        "architecture"|"arch") echo "arc" ;;
        "documentation"|"doc") echo "doc" ;;
        "snapshot"|"snap") echo "snap" ;;
        "technicaldebt"|"tdebt") echo "tdebt" ;;
        "analysis"|"analyst"|"analytics") echo "analysis" ;;
        "line") echo "line" ;;
        "project"|"proj") echo "proj" ;;
        "task") echo "task" ;;
        "feature") echo "feat" ;;
        "bug") echo "bug" ;;
        "document") echo "doc" ;;  # Добавляем "document" как синоним
        *) echo "task" ;;  # по умолчанию
    esac
}

# Функция для получения ID
get_id() {
    local file="$1"
    # Ищем ID в frontmatter
    local id_line=$(grep -E '^id:' "$file" 2>/dev/null | head -1)
    if [ -z "$id_line" ]; then
        echo ""
        return
    fi
    
    # Извлекаем значение ID (учитываем кавычки и пробелы)
    local id=$(echo "$id_line" | sed -E 's/^id:[[:space:]]*"?([^"]*)"?[[:space:]]*$/\1/')
    id=$(echo "$id" | tr -d "'" | tr -d '"')
    
    echo "$id"
}

# Функция для извлечения имени файла
get_file_name() {
    local file="$1"
    
    # Убираем расширение .md
    local name=$(echo "$file" | sed 's/\.md$//')
    
    # Если есть " - " в имени, берем часть после последнего " - "
    if [[ "$name" == *" - "* ]]; then
        # Разделяем по " - " и берем последнюю часть
        local parts
        IFS=" - " read -ra parts <<< "$name"
        local last_part="${parts[-1]}"
        
        # Если последняя часть не пустая, используем ее
        if [ -n "$last_part" ]; then
            echo "$last_part"
            return
        fi
    fi
    
    # Если не нашли " - " или последняя часть пустая, возвращаем все имя
    echo "$name"
}

count=0
success=0
errors=0
skipped=0

# Обрабатываем все .md файлы в текущей директории
for file in *.md; do
    [ -f "$file" ] || continue
    
    echo "🔍 Обрабатываем: $file"
    
    # Пропускаем если уже начинается с правильного формата (XX-XX type - Name)
    if [[ "$file" =~ ^[0-9A-F]{2}(-[0-9A-F]{2})*\ [a-z]{2,6}\ -\ .+\.md$ ]]; then
        echo "   ⏭️  Пропускаем (уже правильный формат): $file"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi
    
    # Получаем ID
    id=$(get_id "$file")
    
    if [ -z "$id" ]; then
        echo "   ❌ Нет поля id. Пропускаем."
        errors=$((errors + 1))
        echo ""
        continue
    fi
    
    echo "   🆔 ID из frontmatter: '$id'"
    
    # Получаем тип документа
    doc_type=$(get_doc_type "$file")
    echo "   📝 Тип документа: '$doc_type'"
    
    # Получаем имя файла
    file_name=$(get_file_name "$file")
    echo "   📄 Имя файла: '$file_name'"
    
    count=$((count + 1))
    
    # Формируем новое имя
    new_file="${id} ${doc_type} - ${file_name}.md"
    
    echo "   🔧 Новое имя: '$new_file'"
    
    # Проверяем не существует ли уже файл с таким именем
    if [ -f "$new_file" ] && [ "$file" != "$new_file" ]; then
        echo "   ⚠️  Файл уже существует: $new_file"
        # Добавляем суффикс
        base_name=$(basename "$new_file" .md)
        new_file="${base_name}-dup.md"
        echo "   💡 Будет создан как: $new_file"
    fi
    
    # Создаем backup
    cp "$file" "$backup_dir/"
    
    # Переименовываем
    echo "   🔄 $file → $new_file"
    mv "$file" "$new_file"
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Успешно"
        success=$((success + 1))
    else
        echo "   ❌ Ошибка"
        errors=$((errors + 1))
    fi
    
    echo ""
done

echo "=== РЕЗУЛЬТАТ ==="
echo "Всего файлов: $(ls *.md 2>/dev/null | wc -l | tr -d ' ')"
echo "Обработано: $count"
echo "✅ Успешно переименовано: $success"
echo "⏭️  Пропущено (уже правильный формат): $skipped"
echo "❌ Ошибок: $errors"
echo "📁 Backup создан в: $backup_dir"
echo ""

if [ $success -gt 0 ]; then
    echo "🎉 Переименование завершено!"
    echo "Примеры переименованных файлов:"
    echo "------------------------------"
    ls -1 *.md 2>/dev/null | head -10
    echo "------------------------------"
fi