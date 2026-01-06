#!/bin/bash
echo "=== ПРОСТОЕ ИСПРАВЛЕНИЕ ==="
echo ""

for file in *.md; do
    [ -f "$file" ] || continue
    
    echo "📄 $file"
    
    # Если файл содержит более одного " - " - это неправильно
    if [[ "$file" == *" - "*" - "* ]]; then
        echo "   ❌ Два или более ' - ' в имени"
        
        # Берем последнюю часть как имя
        clean_name=$(echo "$file" | sed 's/.* - //' | sed 's/\.md$//')
        echo "   📄 Имя: $clean_name"
        
        # Получаем ID и тип из frontmatter
        id=$(grep '^id:' "$file" | sed 's/^id:[[:space:]]*//' | tr -d '[:space:]' | tr -d '"' | tr -d "'")
        type_raw=$(grep '^type:' "$file" | sed 's/^type:[[:space:]]*//' | tr -d '[:space:]' | tr -d '"' | tr -d "'")
        
        # Сокращаем тип
        case "$type_raw" in
            "documentation"|"doc"|"document") doc_type="doc" ;;
            "project"|"proj") doc_type="proj" ;;
            *) doc_type="task" ;;
        esac
        
        new_name="${id} ${doc_type} - ${clean_name}.md"
        echo "   🔧 Новое имя: $new_name"
        
        # Переименовываем
        mv -v "$file" "$new_name"
    else
        echo "   ✅ OK"
    fi
    echo ""
done

echo "=== РЕЗУЛЬТАТ ==="
ls -la *.md
