#!/bin/bash
# test-fix-single.sh - Тест исправления одного файла

if [ $# -ne 1 ]; then
    echo "Использование: $0 <файл.md>"
    exit 1
fi

file="$1"

if [ ! -f "$file" ]; then
    echo "Файл не найден: $file"
    exit 1
fi

echo "=== ТЕСТ ИСПРАВЛЕНИЯ: $file ==="

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

# Извлекаем ID
id=$(get_frontmatter_value "$file" "id")
echo "ID из frontmatter: '$id'"

# Извлекаем тип
type_raw=$(get_frontmatter_value "$file" "type")
echo "Type из frontmatter: '$type_raw'"

# Определяем сокращенный тип
case "$type_raw" in
    "documentation"|"doc"|"document") doc_type="doc" ;;
    "architecture"|"arch") doc_type="arc" ;;
    "snapshot"|"snap") doc_type="snap" ;;
    "technicaldebt"|"tdebt") doc_type="tdebt" ;;
    "analysis"|"analyst"|"analytics") doc_type="analysis" ;;
    "line") doc_type="line" ;;
    "project"|"proj") doc_type="proj" ;;
    "task") doc_type="task" ;;
    "feature") doc_type="feat" ;;
    "bug") doc_type="bug" ;;
    "epic") doc_type="epic" ;;
    "report") doc_type="report" ;;
    "idea") doc_type="idea" ;;
    "component") doc_type="comp" ;;
    "solution") doc_type="sol" ;;
    *) doc_type="$type_raw" ;;
esac
echo "Сокращенный тип: '$doc_type'"

# Извлекаем чистое имя
if [[ "$file" == *" - "* ]]; then
    clean_name=$(echo "$file" | sed 's/.* - //' | sed 's/\.md$//')
else
    clean_name=$(echo "$file" | sed 's/\.md$//')
fi

# Убираем цифры и тире из начала
clean_name=$(echo "$clean_name" | sed -E 's/^[0-9A-F-]+[[:space:]]*//')
clean_name=$(echo "$clean_name" | sed -E 's/^[[:space:]]+//')

echo "Чистое имя: '$clean_name'"

# Новое имя
new_name="${id} ${doc_type} - ${clean_name}.md"
echo "Новое имя: '$new_name'"
