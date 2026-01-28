#!/bin/bash
echo "🔍 ПОИСК И ИСПРАВЛЕНИЕ ВСЕХ ДВОЙНЫХ FRONTMATTER"
echo "=============================================="
echo ""

# Сначала найдем ВСЕ файлы с проблемой
echo "1. Поиск файлов с двойным frontmatter..."
echo "---------------------------------------"

problem_files=()
find . -name "[0-9]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  # Более надежная проверка: ищем паттерн "---" после "---"
  content=$(head -30 "$f")
  if [[ "$content" =~ ---.*---.*---.*--- ]]; then
    echo "❌ $(basename "$f") - двойной frontmatter"
    problem_files+=("$f")
  fi
done

echo ""
echo "2. Исправление найденных файлов..."
echo "---------------------------------"

fixed_count=0

for f in "${problem_files[@]}"; do
  filename=$(basename "$f")
  echo "🔄 Исправляю: $filename"
  
  # Извлекаем информацию из имени файла
  file_id=$(echo "$filename" | grep -oE '^[0-9]+-[0-9]+-[0-9]+' | head -1)
  file_type=$(echo "$filename" | grep -oE '_[A-Z]+_' | sed 's/_//g')
  slug=$(echo "$filename" | sed 's/\.md$//')
  
  # Создаем человекочитаемое имя (удаляем ID и тип)
  readable_name=$(echo "$filename" | sed "s/^[0-9]*-[0-9]*-[0-9]*_${file_type}_//" | sed 's/\.md$//' | tr '_' ' ')
  
  # Определяем уровень
  level=$(echo "$file_id" | cut -d'-' -f1)
  
  # Извлекаем существующие теги (берем из ПЕРВОГО frontmatter)
  tags_line=$(grep -m1 "^tags:" "$f")
  
  # Создаем временный файл с ПРАВИЛЬНЫМ frontmatter
  cat > "${f}.fixed" << FRONTMATTER
---
id: "$file_id"
name: "$readable_name"
type: "$file_type"
level: $level
status: "active"
$tags_line
created: "$(date +%Y-%m-%d)"
updated: "$(date +%Y-%m-%d)"
author: "kirillkravcov"
slug: "$slug"
---
FRONTMATTER
  
  # Находим и добавляем ОСНОВНОЕ содержимое (после ВТОРОГО frontmatter)
  # Ищем конец второго frontmatter (третий "---")
  awk '
  BEGIN { frontmatter_count = 0; skip = 0 }
  /^---$/ {
    frontmatter_count++
    if (frontmatter_count == 3) {
      skip = 1  # Пропускаем третий "---"
      next
    }
  }
  frontmatter_count >= 3 && skip == 0 { print }
  ' "$f" >> "${f}.fixed"
  
  # Заменяем оригинальный файл
  mv "${f}.fixed" "$f"
  fixed_count=$((fixed_count + 1))
  echo "   ✅ Исправлено"
  echo ""
done

echo "========================================"
echo "📊 ИТОГ: Найдено и исправлено файлов: ${#problem_files[@]}"
echo ""
echo "3. Проверка исправленных файлов..."
echo "---------------------------------"

# Проверяем несколько исправленных файлов
check_files=(
  "4-010400-0200-1_TASK_Архитектурная_вилка_UCH-Docs.md"
  "4-010400-0600-1_TASK_последовательное_создание_ нескольких_документов.md"
  "6-010000-002-1_SNAP_20251225.md"
)

for check_file in "${check_files[@]}"; do
  if [ -f "$check_file" ]; then
    echo "🔍 Проверка: $check_file"
    echo "Количество '---': $(grep -c "^---$" "$check_file") (должно быть 2)"
    echo "Имя: $(grep -m1 "^name:" "$check_file")"
    echo ""
  fi
done
