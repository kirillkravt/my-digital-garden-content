#!/bin/bash
# correct-rename.sh - Корректное переименование

echo "=== КОРРЕКТНОЕ ПЕРЕИМЕНОВАНИЕ ==="
echo ""

for file in *.md; do
    [ -f "$file" ] || continue
    
    echo "📄 Файл: $file"
    
    # 1. Извлекаем ID (сохраняем дефисы)
    id_line=$(grep '^id:' "$file")
    id=$(echo "$id_line" | sed 's/^id:[[:space:]]*//' | tr -d '[:space:]')
    echo "   🆔 ID: $id"
    
    # 2. Извлекаем и сокращаем тип
    type_line=$(grep '^type:' "$file")
    type_raw=$(echo "$type_line" | sed 's/^type:[[:space:]]*//' | tr -d '[:space:]')
    
    # Определяем короткий тип
    case "$type_raw" in
        "documentation"|"doc"|"document") doc_type="doc" ;;
        "architecture"|"arch") doc_type="arc" ;;
        "snapshot"|"snap") doc_type="snap" ;;
        "line") doc_type="line" ;;
        "project"|"proj") doc_type="proj" ;;
        *) doc_type="task" ;;
    esac
    echo "   📝 Тип: $doc_type (было: $type_raw)"
    
    # 3. Извлекаем чистое имя (после последнего " - ")
    if [[ "$file" == *" - "* ]]; then
        # Берем часть после последнего " - "
        clean_name=$(echo "$file" | sed 's/.* - //' | sed 's/\.md$//')
    else
        clean_name=$(echo "$file" | sed 's/\.md$//')
    fi
    echo "   📄 Чистое имя: $clean_name"
    
    # 4. Формируем новое имя
    new_file="${id} ${doc_type} - ${clean_name}.md"
    echo "   🔧 Новое имя: $new_file"
    
    echo ""
done