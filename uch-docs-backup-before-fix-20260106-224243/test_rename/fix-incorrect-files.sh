#!/bin/bash
# fix-incorrect-files.sh - Исправление с более строгой проверкой

echo "=== ИСПРАВЛЕНИЕ НЕПРАВИЛЬНЫХ ФАЙЛОВ v2 ==="
echo ""

# Создаем backup
backup_dir="incorrect-fix-backup-v2-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"
echo "📁 Backup создан: $backup_dir"
echo ""

# Функция проверки правильности формата
is_correct_format() {
    local filename="$1"
    
    # Правильный формат: ID тип - Название.md
    # Где название НЕ содержит " - " внутри себя
    
    if [[ ! "$filename" =~ ^([0-9A-F]{2}(-[0-9A-F]{2})*)\ ([a-z]{2,6})\ -\ (.+)\.md$ ]]; then
        return 1  # Неправильный формат
    fi
    
    local id_part="${BASH_REMATCH[1]}"
    local type_part="${BASH_REMATCH[2]}"
    local name_part="${BASH_REMATCH[3]}"
    
    # Проверяем что имя не содержит " - "
    if [[ "$name_part" == *" - "* ]]; then
        return 1  # Имя содержит " - " - неправильно
    fi
    
    # Проверяем что тип правильный (допустимые типы)
    case "$type_part" in
        "arc"|"doc"|"snap"|"tdebt"|"analysis"|"line"|"proj"|"task"|"feat"|"bug")
            return 0  # Правильный формат
            ;;
        *)
            return 1  # Неизвестный тип
            ;;
    esac
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

# Счетчики
processed=0
fixed=0
skipped=0
errors=0

# Обрабатываем каждый .md файл
for file in *.md; do
    [ -f "$file" ] || continue
    
    echo "🔍 Анализируем: $file"
    processed=$((processed + 1))
    
    # Проверяем правильность формата
    if is_correct_format "$file"; then
        echo "   ✅ Правильный формат"
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
    
    # Обрабатываем ID
    id=$(echo "$id_line" | sed -E 's/^id:[[:space:]]*//' | sed -E 's/[[:space:]]*$//')
    id=$(echo "$id" | tr -d '"' | tr -d "'")
    
    # Извлекаем тип из frontmatter
    type_line=$(grep -E '^type:' "$file" 2>/dev/null | head -1)
    if [ -z "$type_line" ]; then
        doc_type="task"
        type_raw="не указано"
    else
        type_raw=$(echo "$type_line" | sed -E 's/^type:[[:space:]]*//' | sed -E 's/[[:space:]]*$//')
        type_raw=$(echo "$type_raw" | tr -d '"' | tr -d "'")
        doc_type=$(get_short_type "$type_raw")
    fi
    
    echo "   🆔 ID из frontmatter: '$id'"
    echo "   📝 Тип: '$doc_type' (было: '$type_raw')"
    
    # Определяем чистое имя файла
    # Убираем все до последнего " - " если оно есть
    if [[ "$file" == *" - "* ]]; then
        # Берем часть после последнего " - "
        name_without_ext=$(basename "$file" .md)
        # Разделяем по " - " и берем последнюю часть
        IFS=" - " read -ra parts <<< "$name_without_ext"
        
        # Ищем часть, которая НЕ содержит цифр и дефисов в начале (скорее всего настоящее имя)
        clean_name=""
        for part in "${parts[@]}"; do
            # Если часть не похожа на ID (не начинается с HEX-цифр) и не короткое слово
            if [[ ! "$part" =~ ^[0-9A-F] ]] && [[ ${#part} -gt 3 ]]; then
                clean_name="$part"
                break
            fi
        done
        
        # Если не нашли, берем последнюю часть
        if [ -z "$clean_name" ]; then
            clean_name="${parts[-1]}"
        fi
        
        # Убираем возможные пробелы
        clean_name=$(echo "$clean_name" | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+$//')
    else
        clean_name=$(basename "$file" .md)
    fi
    
    # Если clean_name все еще содержит " - ", берем последнюю часть
    if [[ "$clean_name" == *" - "* ]]; then
        clean_name=$(echo "$clean_name" | rev | cut -d'-' -f1 | rev | sed -E 's/^[[:space:]]+//' | sed -E 's/[[:space:]]+$//')
    fi
    
    echo "   📄 Чистое имя: '$clean_name'"
    
    # Формируем правильное имя
    correct_name="${id} ${doc_type} - ${clean_name}.md"
    
    echo "   🔧 Правильное имя: '$correct_name'"
    
    # Проверяем, не совпадает ли уже имя
    if [ "$file" = "$correct_name" ]; then
        echo "   ⏭️  Имя уже правильное"
        skipped=$((skipped + 1))
        echo ""
        continue
    fi
    
    # Проверяем, не существует ли уже файл с таким именем
    if [ -f "$correct_name" ]; then
        echo "   ⚠️  Файл '$correct_name' уже существует"
        # Добавляем суффикс
        base_name=$(basename "$correct_name" .md)
        timestamp=$(date +%H%M%S)
        correct_name="${base_name}-${timestamp}.md"
        echo "   💡 Используем: '$correct_name'"
    fi
    
    # Создаем backup
    cp "$file" "$backup_dir/"
    
    # Переименовываем
    echo "   🔄 Переименовываем: '$file' → '$correct_name'"
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