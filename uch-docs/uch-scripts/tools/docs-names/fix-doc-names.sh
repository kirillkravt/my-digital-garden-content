#!/bin/bash
# fix-doc-names.sh - Исправление имен документов в текущей директории
# Использование: ./fix-doc-names.sh

echo "=== ИСПРАВЛЕНИЕ ИМЕН ДОКУМЕНТОВ v2 ==="
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
        *) echo "task" ;;
    esac
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
    
    # 1. Получаем ID из frontmatter
    id_line=$(grep '^id:' "$file" 2>/dev/null)
    if [ -z "$id_line" ]; then
        echo "   ⚠️  Не найден ID в frontmatter. Пропускаем."
        errors=$((errors + 1))
        echo ""
        continue
    fi
    
    id=$(echo "$id_line" | sed 's/^id:[[:space:]]*//' | tr -d '[:space:]' | tr -d '"' | tr -d "'")
    
    # 2. Получаем тип из frontmatter
    type_line=$(grep '^type:' "$file" 2>/dev/null)
    type_raw=""
    if [ -n "$type_line" ]; then
        type_raw=$(echo "$type_line" | sed 's/^type:[[:space:]]*//' | tr -d '[:space:]' | tr -d '"' | tr -d "'")
    fi
    
    # 3. Определяем сокращенный тип
    doc_type=$(get_short_type "$type_raw")
    
    echo "   🆔 ID: $id"
    echo "   📝 Тип: $doc_type (было: ${type_raw:-не указано})"
    
    # 4. Извлекаем чистое имя (последняя часть после " - ")
    if [[ "$file" == *" - "* ]]; then
        # Берем часть после последнего " - "
        clean_name=$(echo "$file" | sed 's/.* - //' | sed 's/\.md$//')
    else
        clean_name=$(echo "$file" | sed 's/\.md$//')
    fi
    
    echo "   📄 Чистое имя: '$clean_name'"
    
    # 5. Формируем новое имя
    new_name="${id} ${doc_type} - ${clean_name}.md"
    
    echo "   🔧 Новое имя: '$new_name'"
    
    # 6. Проверяем не существует ли уже файл с таким именем
    if [ -f "$new_name" ] && [ "$file" != "$new_name" ]; then
        echo "   ⚠️  Файл '$new_name' уже существует"
        # Добавляем суффикс
        base_name=$(basename "$new_name" .md)
        timestamp=$(date +%H%M%S)
        new_name="${base_name}-${timestamp}.md"
        echo "   💡 Используем: '$new_name'"
    fi
    
    # 7. Создаем backup
    cp "$file" "$backup_dir/"
    
    # 8. Переименовываем
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
    ls -1 *.md 2>/dev/null || echo "Нет .md файлов"
    echo "---------------------------"
fi
