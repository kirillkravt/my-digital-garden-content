#!/bin/bash
# fix_rename.sh - Исправленное переименование файлов с учетом текущей структуры

echo "=== ИСПРАВЛЕННОЕ ПЕРЕИМЕНОВАНИЕ ФАЙЛОВ ==="
echo "Убираем начальные цифры и добавляем ID из frontmatter"
echo ""

# Создаем backup
backup_dir="fixed-rename-backup-$(date +%Y%m%d-%H%M%S)"
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
    
    local type=$(echo "$type_line" | sed 's/type://' | sed 's/"//g' | sed "s/'//g" | tr -d ' ' | tr -d '[:punct:]')
    
    # Сокращения для типов документов
    case "$type" in
        "architecture"|"arch") echo "arc" ;;
        "documentation"|"doc") echo "doc" ;;
        "snapshot"|"snap") echo "snap" ;;
        "technicaldebt"|"tdebt") echo "tdebt" ;;
        "analysis"|"analyst"|"analytics") echo "analysis" ;; # Полностью, не сокращаем
        "line") echo "line" ;;
        "project"|"proj") echo "proj" ;;
        "task") echo "task" ;;
        "feature") echo "feat" ;;
        "bug") echo "bug" ;;
        *) echo "task" ;; # по умолчанию
    esac
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
    if [[ "$file" =~ ^[0-9A-F]{2}(-[0-9A-F]{2})*\ [a-z]+\ -\ .+\.md$ ]]; then
        echo "   ⏭️  Пропускаем (уже правильный формат): $file"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi
    
    # Ищем ID в frontmatter
    id_line=$(grep -E '^id:' "$file" 2>/dev/null | head -1)
    
    if [ -z "$id_line" ]; then
        echo "   ❌ Нет поля id. Пропускаем."
        errors=$((errors + 1))
        echo ""
        continue
    fi
    
    # Извлекаем ID
    id=$(echo "$id_line" | sed 's/id://' | sed 's/"//g' | sed "s/'//g" | tr -d ' ')
    
    if [ -z "$id" ]; then
        echo "   ❌ Пустой ID. Пропускаем."
        errors=$((errors + 1))
        echo ""
        continue
    fi
    
    count=$((count + 1))
    
    # Получаем тип документа
    doc_type=$(get_doc_type "$file")
    echo "   📝 Тип документа: $doc_type"
    
    # Извлекаем имя файла (часть после " - ")
    if [[ "$file" == *" - "* ]]; then
        # Убираем все до первого " - " (включая начальные цифры)
        name_part=$(echo "$file" | sed 's/^[^-]*- //')
        # Убираем расширение .md
        name_part=$(echo "$name_part" | sed 's/\.md$//')
    else
        # Если нет " - ", берем все имя без .md
        name_part=$(echo "$file" | sed 's/\.md$//')
    fi
    
    # Формируем новое имя
    new_file="${id} ${doc_type} - ${name_part}.md"
    
    echo "   📊 Исходное имя: '$name_part'"
    echo "   🔧 Новое имя: '$new_file'"
    
    # Проверяем не существует ли уже файл с таким именем
    if [ -f "$new_file" ] && [ "$file" != "$new_file" ]; then
        echo "   ⚠️  Файл уже существует: $new_file"
        # Добавляем суффикс с timestamp
        base_name=$(basename "$new_file" .md)
        timestamp=$(date +%H%M%S)
        new_file="${base_name}-${timestamp}.md"
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
echo "Всего файлов: $(ls *.md | wc -l)"
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
    ls -1 | grep -E "^[0-9A-F]{2}(-[0-9A-F]{2})*\ [a-z]+\ -\ " | head -5
    echo "------------------------------"
    echo "Проверьте результат и при необходимости исправьте вручную."
fi