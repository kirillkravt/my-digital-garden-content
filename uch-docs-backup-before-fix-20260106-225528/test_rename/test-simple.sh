#!/bin/bash
echo "=== ТЕСТ НА ОДНОМ ФАЙЛЕ ==="
echo ""

file="01 00-30 doc - Брендбук.md"

echo "Исходный файл: $file"
echo ""

# 1. ID
id_line=$(grep '^id:' "$file")
id=$(echo "$id_line" | sed 's/^id:[[:space:]]*//' | tr -d '[:space:]')
echo "ID из frontmatter: '$id'"

# 2. Type
type_line=$(grep '^type:' "$file")
type_raw=$(echo "$type_line" | sed 's/^type:[[:space:]]*//' | tr -d '[:space:]')
echo "Type из frontmatter: '$type_raw'"

# Сокращаем
case "$type_raw" in
    "documentation"|"doc"|"document") doc_type="doc" ;;
    *) doc_type="task" ;;
esac
echo "Сокращенный тип: '$doc_type'"

# 3. Имя файла
if [[ "$file" == *" - "* ]]; then
    clean_name=$(echo "$file" | sed 's/.* - //' | sed 's/\.md$//')
else
    clean_name=$(echo "$file" | sed 's/\.md$//')
fi
echo "Чистое имя: '$clean_name'"

# 4. Результат
new_file="${id} ${doc_type} - ${clean_name}.md"
echo ""
echo "📝 РЕЗУЛЬТАТ:"
echo "Было: $file"
echo "Стало: $new_file"
