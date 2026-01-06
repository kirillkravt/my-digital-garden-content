#!/bin/bash
# test-logic.sh - Тест логики переименования

echo "=== ТЕСТ ЛОГИКИ ПЕРЕИМЕНОВАНИЯ ==="
echo ""

# Создаем тестовый файл с правильным frontmatter
cat > test-file.md << 'EOF'
---
id: "00-03"
name: "Брендбук"
type: "documentation"
level: 1
status: "active"
tags: []
created: "2026-01-02"
updated: "2026-01-02"
author: "kirillkravcov"
---

Содержимое документа
EOF

test_file="01 00-30 doc - Брендбук.md"

echo "Тестируем файл: $test_file"
echo ""

# 1. Извлекаем ID (симулируем из реального файла)
id="00-03"
echo "1. ID: '$id'"

# 2. Извлекаем тип (симулируем из реального файла)
type="documentation"
echo "2. Raw type: '$type'"

# 3. Определяем сокращенный тип
case "$type" in
    "architecture"|"arch") short_type="arc" ;;
    "documentation"|"doc") short_type="doc" ;;
    "snapshot"|"snap") short_type="snap" ;;
    "technicaldebt"|"tdebt") short_type="tdebt" ;;
    "analysis"|"analyst"|"analytics") short_type="analysis" ;;
    "line") short_type="line" ;;
    "project"|"proj") short_type="proj" ;;
    "task") short_type="task" ;;
    "feature") echo "feat" ;;
    "bug") echo "bug" ;;
    "document") short_type="doc" ;;
    *) short_type="task" ;;
esac
echo "3. Short type: '$short_type'"

# 4. Извлекаем имя файла
name=$(echo "$test_file" | sed 's/\.md$//')
echo "4. Full name: '$name'"

if [[ "$name" == *" - "* ]]; then
    # Разделяем по " - " и берем последнюю часть
    IFS=" - " read -ra parts <<< "$name"
    last_part="${parts[-1]}"
    echo "5. Last part: '$last_part'"
    file_name="$last_part"
else
    file_name="$name"
fi

echo "6. Final file name: '$file_name'"

# 5. Формируем новое имя
new_file="${id} ${short_type} - ${file_name}.md"
echo ""
echo "📝 РЕЗУЛЬТАТ:"
echo "Было: $test_file"
echo "Стало: $new_file"

# Очистка
rm test-file.md