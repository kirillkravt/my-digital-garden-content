#!/bin/bash
# fix-incorrect-files.sh - Исправление файлов с неправильным форматом имен

echo "=== ИСПРАВЛЕНИЕ НЕПРАВИЛЬНЫХ ФАЙЛОВ ==="
echo ""

# Создаем backup
backup_dir="incorrect-fix-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
echo "📁 Backup создан: $backup_dir"
echo ""

# Счетчики
processed=0
fixed=0
skipped=0
errors=0

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
        *) echo "task" ;;
    esac
}

# Обрабатываем каждый .md файл
for file in *.md; do
    [ -f "$file" ] || continue
    
    echo "🔍 Анализируем: $file"
    processed=$((processed + 1))
    
    # Проверяем, правильный ли уже формат
    if [[ "$file" =~ ^[0-9A-F]{2}(-[0-9A-F]{2})*\ [a-z]{2,6}\ -\ .+\.md$ ]]; then
        echo "   ⏭️  Уже правильный формат"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi
    
    echo "   ❌ Неправильный формат - исправляем..."
    
    # Извлекаем ID из frontmatter
    id_line=$(grep -E '^id:' "$file" 2>/dev/null | head -1)
    if [ -z "$id_line" ]; then
        echo "   ❌ Нет ID в frontmatter. Пропускаем."
        errors=$((errors + 1))
        echo ""
        continue
    fi
    
    # Обрабатываем ID (убираем "id:", пробелы, кавычки)
    id=$(echo "$id_line" | sed -E 's/^id:[[:space:]]*//' | sed -E 's/[[:space:]]*$//')
    id=$(echo "$id" | tr -d '"' | tr -d "'")
    
    # Извлекаем тип из frontmatter
    type_line=$(grep -E '^type:' "$file" 2>/dev/null | head -1)
    if [ -z "$type_line" ]; then
        doc_type="task"
    else
        type_raw=$(echo "$type_line" | sed -E 's/^type:[[:space:]]*//' | sed -E 's/[[:space:]]*$//')
        type_raw=$(echo "$type_raw" | tr -d '"' | tr -d "'")
        doc_type=$(get_short_type "$type_raw")
    fi
    
    echo "   🆔 ID из frontmatter: $id"
    echo "   📝 Тип: $doc_type (было: ${type_raw:-не указано})"
    
    # Извлекаем чистое имя файла (последняя часть после " - ")
    if [[ "$file" == *" - "* ]]; then
        # Разделяем по " - " и берем последнюю часть
        IFS=" - " read -ra parts <<< "$(basename "$file" .md)"
        clean_name="${parts[-1]}"
        # Убираем возможные пробелы в начале/конце
        clean_name=$(echo "$clean_name" | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+$//')
    else
        clean_name=$(basename "$file" .md)
    fi
    
    echo "   📄 Чистое имя: '$clean_name'"
    
    # Формируем правильное имя
    correct_name="${id} ${doc_type} - ${clean_name}.md"
    
    # Проверяем, не совпадает ли уже имя
    if [ "$file" = "$correct_name" ]; then
        echo "   ⏭️  Имя уже правильное"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi
    
    echo "   🔧 Правильное имя: $correct_name"
    
    # Проверяем, не существует ли уже файл с таким именем
    if [ -f "$correct_name" ]; then
        echo "   ⚠️  Файл '$correct_name' уже существует"
        # Добавляем суффикс
        base_name=$(basename "$correct_name" .md)
        correct_name="${base_name}-fixed.md"
        echo "   💡 Используем: $correct_name"
    fi
    
    # Создаем backup
    cp "$file" "$backup_dir/"
    
    # Переименовываем
    echo "   🔄 Переименовываем: $file → $correct_name"
    mv "$file" "$correct_name"
    
    if [ $? -eq 0 ]; then
        echo "   ✅ Успешно исправлено"
        fixed=$((fixed + 1))
    else
        echo "   ❌ Ошибка при переименовании"
        errors=$((errors + 1))
    fi
    
    echo ""
done

echo "=== РЕЗУЛЬТАТ ==="
echo "Обработано файлов: $processed"
echo "✅ Исправлено: $fixed"
echo "⏭️  Пропущено (уже правильные): $skipped"
echo "❌ Ошибок: $errors"
echo "📁 Backup: $backup_dir"
echo ""

if [ $fixed -gt 0 ]; then
    echo "🎉 Файлы исправлены!"
    echo "Текущие файлы:"
    echo "--------------"
    ls -1 *.md
    echo "--------------"
fi