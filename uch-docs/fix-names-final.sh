#!/bin/bash
echo "🔧 ФИНАЛЬНОЕ ИСПРАВЛЕНИЕ ИМЕН"
echo "============================="
echo ""
echo "1. Удаляем лишнюю 'u' в начале имен"
echo "2. Правильно обрабатываем русские символы"
echo "3. Используем slug из имен файлов"
echo ""

fixed_count=0

# Сначала исправим файлы с лишней "u" в начале
echo "🔄 УДАЛЕНИЕ ЛИШНЕЙ 'u' В НАЧАЛЕ ИМЕН..."
echo "---------------------------------------"

find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  # Получаем текущее имя
  current_name=$(grep -m1 "^name:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
  
  # Проверяем, начинается ли имя с "u" (латинской)
  if [[ "$current_name" =~ ^u[^u] ]]; then
    # Удаляем начальную "u"
    corrected_name="${current_name:1}"
    
    echo "📝 $(basename "$f")"
    echo "   Было: '$current_name'"
    echo "   Стало: '$corrected_name'"
    
    # Обновляем имя
    sed -i '' "s/^name:.*$/name: \"$corrected_name\"/" "$f"
    
    fixed_count=$((fixed_count + 1))
    echo ""
  fi
done

echo ""
echo "🔄 ИСПРАВЛЕНИЕ ИМЕН ИЗ SLUG (ПРОСТОЙ ПОДХОД)..."
echo "---------------------------------------------"

# Теперь исправим имена на основе slug простым способом
find . -name "[0-9]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  
  # Простой подход: берем часть после первого _TYPE_
  # Формат: ID_TYPE_slug.md
  if [[ "$filename" =~ _[A-Z]+_(.+)\.md$ ]]; then
    slug_part="${BASH_REMATCH[1]}"
    
    # Преобразуем slug в читаемое имя
    readable_name=$(echo "$slug_part" | \
      sed 's/_/ /g' | \
      sed 's/  / /g' | \
      sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
    )
    
    # Для SNAP документов: ищем дату в конце
    if [[ "$filename" =~ _SNAP_ ]]; then
      if [[ "$readable_name" =~ ([0-9]{8})$ ]]; then
        readable_name="${BASH_REMATCH[1]}"
      fi
    fi
    
    # Получаем текущее имя после первой коррекции
    current_name=$(grep -m1 "^name:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
    
    # Если имена отличаются, обновляем
    if [ "$readable_name" != "$current_name" ] && [ -n "$readable_name" ]; then
      echo "📝 $filename"
      echo "   Slug: $slug_part"
      echo "   Было: '$current_name'"
      echo "   Стало: '$readable_name'"
      
      sed -i '' "s/^name:.*$/name: \"$readable_name\"/" "$f"
      
      fixed_count=$((fixed_count + 1))
      echo ""
    fi
  fi
done

echo "========================================"
echo "📊 ИТОГ: Всего исправлений: $fixed_count"
echo ""
echo "🔍 ФИНАЛЬНАЯ ПРОВЕРКА:"
echo "---------------------"

# Финальная проверка
check_files=(
  "2-010400-7_ARCH_Documentation-first_подход.md"
  "6-010400-004-1_SNAP_20251227.md"
  "6-010200-001-1_SNAP_20251221.md"
  "4-010400-0200-1_TASK_Архитектурная_вилка_UCH-Docs.md"
  "1-010000-6_BRAND_brandbook.md"
  "2-010400-8_DOC_FUNCTION-TREE.md"
)

for check_file in "${check_files[@]}"; do
  if [ -f "$check_file" ]; then
    name=$(grep -m1 "^name:" "$check_file" | cut -d: -f2- | sed 's/^ *//; s/ *$//')
    echo "📄 $check_file:"
    echo "   $name"
    echo ""
  fi
done
