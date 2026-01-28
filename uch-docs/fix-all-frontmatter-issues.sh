#!/bin/bash
echo "🔧 ИСПРАВЛЕНИЕ ВСЕХ ПРОБЛЕМ FRONTMATTER"
echo "======================================="
echo ""
echo "Исправляем:"
echo "1. Двойной frontmatter"
echo "2. Имена с ID (оставляем только человекочитаемое)"
echo "3. Удаляем лишние поля (parent, parent_name)"
echo ""

fixed_count=0
name_fixed_count=0

# Исправляем конкретные проблемные файлы из примера
problem_files=(
  "4-010400-0600-1_TASK_последовательное_создание_ нескольких_документов.md"
  "6-010000-002-1_SNAP_20251225.md"
  "3-010201-4_API_Интеграция_Strudel.md"
)

for file in "${problem_files[@]}"; do
  if [ -f "$file" ]; then
    echo "🔄 Исправляю: $file"
    
    # Извлекаем информацию из имени файла
    filename=$(basename "$file")
    file_id=$(echo "$filename" | grep -oE '^[0-9]+-[0-9]+-[0-9]+' | head -1)
    file_type=$(echo "$filename" | grep -oE '_[A-Z]+_' | sed 's/_//g')
    slug=$(echo "$filename" | sed 's/\.md$//')
    
    # Создаем человекочитаемое имя (удаляем ID и тип из начала)
    readable_name=$(echo "$filename" | sed "s/^[0-9]*-[0-9]*-[0-9]*_${file_type}_//" | sed 's/\.md$//' | tr '_' ' ' | sed 's/-\{1,\}/ - /g')
    
    # Определяем уровень
    level=$(echo "$file_id" | cut -d'-' -f1)
    
    # Создаем правильный frontmatter
    cat > "${file}.tmp" << FRONTMATTER
---
id: "$file_id"
name: "$readable_name"
type: "$file_type"
level: $level
status: "active"
tags: []
created: "2025-12-26"
updated: "$(date +%Y-%m-%d)"
author: "kirillkravcov"
slug: "$slug"
---
FRONTMATTER
    
    # Добавляем содержимое из оригинального файла (после ВТОРОГО frontmatter если есть)
    if grep -q "^---$" "$file"; then
      # Пропускаем все до второго frontmatter
      awk 'BEGIN {count=0} /^---$/ {count++; if (count>=3) print}' "$file" >> "${file}.tmp"
    else
      # Если нет разделителей, берем все после первых 10 строк
      tail -n +10 "$file" >> "${file}.tmp"
    fi
    
    # Заменяем файл
    mv "${file}.tmp" "$file"
    fixed_count=$((fixed_count + 1))
    echo "   ✅ Исправлен frontmatter"
    echo ""
  fi
done

# Теперь исправляем имена во ВСЕХ файлах (удаляем ID из имени)
echo "🔄 Исправляю имена во всех файлах..."
find . -name "[0-9]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  
  # Извлекаем текущее имя из frontmatter
  current_name=$(grep -m1 "^name:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
  
  # Проверяем, содержит ли имя ID (цифры и дефисы в начале)
  if [[ "$current_name" =~ ^[0-9]+-[0-9]+-[0-9]+ ]]; then
    # Извлекаем информацию для создания нового имени
    file_id=$(echo "$filename" | grep -oE '^[0-9]+-[0-9]+-[0-9]+' | head -1)
    file_type=$(echo "$filename" | grep -oE '_[A-Z]+_' | sed 's/_//g')
    
    # Создаем человекочитаемое имя
    readable_name=$(echo "$filename" | sed "s/^[0-9]*-[0-9]*-[0-9]*_${file_type}_//" | sed 's/\.md$//' | tr '_' ' ' | sed 's/-\{1,\}/ - /g')
    
    # Обновляем имя в файле
    sed -i '' "s/name:.*$/name: \"$readable_name\"/" "$f"
    
    name_fixed_count=$((name_fixed_count + 1))
    echo "   📝 $filename: исправлено имя"
  fi
done

echo ""
echo "========================================"
echo "📊 ИТОГ:"
echo "   Исправлено двойных frontmatter: $fixed_count"
echo "   Исправлено имен с ID: $name_fixed_count"
echo ""
echo "⚠️  Проверьте несколько файлов чтобы убедиться в корректности:"
echo "   grep '^name:' 4-010400-0600-1_TASK_*.md"
echo "   grep '^name:' 6-010000-002-1_SNAP_*.md"
echo "   grep '^name:' 3-010201-4_API_*.md"
