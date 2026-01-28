#!/bin/bash
echo "🔧 УДАЛЕНИЕ ВТОРОГО FRONTMATTER ИЗ ВСЕХ ФАЙЛОВ"
echo "============================================="
echo ""

fixed_count=0

# Обрабатываем все UCH документы
find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  
  # Проверяем наличие двойного frontmatter (более 2 разделителей ---)
  dash_count=$(grep -c "^---$" "$f")
  
  if [ "$dash_count" -gt 2 ]; then
    echo "🔄 Исправляю: $filename ($dash_count разделителей)"
    
    # Создаем временный файл
    temp_file="${f}.tmp"
    
    # Копируем ПЕРВЫЙ frontmatter (до второго ---)
    awk '
    BEGIN { frontmatter_end = 0 }
    /^---$/ {
      frontmatter_end++
      if (frontmatter_end == 2) {
        print $0
        exit
      }
    }
    { print }
    ' "$f" > "$temp_file"
    
    # Добавляем содержимое ПОСЛЕ ВТОРОГО frontmatter
    # Ищем начало после третьего --- (конец второго frontmatter)
    awk '
    BEGIN { skip_until = 0; dash_count = 0 }
    /^---$/ {
      dash_count++
      if (dash_count >= 3) {
        skip_until = 1
      }
      if (dash_count == 3) {
        next  # Пропускаем третий ---
      }
    }
    skip_until == 1 { print }
    ' "$f" >> "$temp_file"
    
    # Проверяем результат
    new_dash_count=$(grep -c "^---$" "$temp_file")
    if [ "$new_dash_count" -eq 2 ]; then
      mv "$temp_file" "$f"
      fixed_count=$((fixed_count + 1))
      echo "   ✅ Исправлено (осталось $new_dash_count разделителей)"
    else
      echo "   ❌ Ошибка: в результате $new_dash_count разделителей"
      rm -f "$temp_file"
    fi
    echo ""
  fi
done

echo "========================================"
echo "📊 ИТОГ: Исправлено файлов: $fixed_count"
echo ""
echo "🔍 ПРОВЕРКА НЕСКОЛЬКИХ ФАЙЛОВ:"
echo "-----------------------------"

# Проверяем исправленные файлы
check_files=(
  "4-010400-0200-1_TASK_Архитектурная_вилка_UCH-Docs.md"
  "4-010400-0600-1_TASK_последовательное_создание_ нескольких_документов.md"
  "6-010000-002-1_SNAP_20251225.md"
  "2-010400-7_ARCH_Documentation-first_подход.md"
)

for check_file in "${check_files[@]}"; do
  if [ -f "$check_file" ]; then
    dash_count=$(grep -c "^---$" "$check_file")
    name=$(grep -m1 "^name:" "$check_file" | cut -d: -f2- | sed 's/^ *//; s/ *$//')
    echo "📄 $check_file:"
    echo "   Разделителей: $dash_count"
    echo "   Имя: $name"
    echo ""
  fi
done
