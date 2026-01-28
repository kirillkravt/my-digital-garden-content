#!/bin/bash
echo "🔍 ПРОВЕРКА НЕСООТВЕТСТВИЙ ID В ФАЙЛАХ"
echo "======================================"
echo ""

total_files=0
mismatch_count=0

find . -name "*.md" -type f | while read f; do
  filename=$(basename "$f")
  
  # Извлекаем ID из имени файла (первые три части до подчеркивания)
  file_id=$(echo "$filename" | grep -oE '^[^-]+-[^-]+-[^-]+' | head -1)
  
  # Извлекаем ID из frontmatter
  frontmatter_id=$(grep -m1 "id:" "$f" 2>/dev/null | head -1 | cut -d: -f2 | tr -d ' "')
  
  if [ -n "$file_id" ] && [ -n "$frontmatter_id" ]; then
    total_files=$((total_files + 1))
    
    if [ "$file_id" != "$frontmatter_id" ]; then
      mismatch_count=$((mismatch_count + 1))
      echo "❌ НЕСОВПАДЕНИЕ:"
      echo "   Файл: $filename"
      echo "   ID в имени: $file_id"
      echo "   ID в frontmatter: $frontmatter_id"
      echo ""
    fi
  fi
done

echo "======================================"
echo "📊 ИТОГИ:"
echo "   Всего проверено файлов: $total_files"
echo "   Файлов с несовпадениями: $mismatch_count"
echo "   Процент проблемных: $((mismatch_count * 100 / total_files))%"
