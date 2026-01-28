#!/bin/bash
echo "🔧 ИСПРАВЛЕНИЕ ОСТАВШИХСЯ ФАЙЛОВ"
echo "================================"
echo ""
echo "Исправляем файлы с 4-5 уровнями в ID:"
echo "• Формат: X-XXXXXX-XXXX или X-XXXXXX-XXXXX"
echo "• Пример: 5-010201-0003"
echo ""

fixed_count=0

# Ищем файлы с паттерном X-XXXXXX-XXXX (4 уровня)
find . -name "[0-9]-[0-9]*-[0-9][0-9][0-9][0-9]*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  
  # Извлекаем slug простым способом: удаляем всё до последнего _TYPE_
  # Ищем паттерн _TYPE_ где TYPE = SOL, TASK, COMP и т.д.
  if [[ "$filename" =~ _([A-Z]+)_(.+)\.md$ ]]; then
    file_type="${BASH_REMATCH[1]}"
    slug_part="${BASH_REMATCH[2]}"
    
    # Преобразуем slug в читаемое имя
    readable_name=$(echo "$slug_part" | \
      sed 's/_/ /g' | \
      sed 's/  / /g' | \
      sed 's/^[[:space:]]*//; s/[[:space:]]*$//'
    )
    
    # Получаем текущее имя
    current_name=$(grep -m1 "^name:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
    
    # Если имя содержит паттерн ID (цифры-дефисы в начале)
    if [[ "$current_name" =~ ^[0-9]+[[:space:]]*-[[:space:]]*[0-9]+ ]]; then
      echo "📝 $filename"
      echo "   Тип: $file_type"
      echo "   Slug: $slug_part"
      echo "   Было: '$current_name'"
      echo "   Стало: '$readable_name'"
      
      # Обновляем имя
      sed -i '' "s/^name:.*$/name: \"$readable_name\"/" "$f"
      
      fixed_count=$((fixed_count + 1))
      echo ""
    fi
  fi
done

echo "========================================"
echo "📊 ИТОГ: Исправлено файлов: $fixed_count"
echo ""
echo "🔍 ПРОВЕРКА ИСПРАВЛЕННЫХ ФАЙЛОВ:"
echo "-------------------------------"

# Проверяем конкретные проблемные файлы
check_files=(
  "5-010201-0003-1_SOL_Autoplay_policy_AudioContext.md"
  "5-010201-0001-1_SOL_MIDI_поддержка.md"
  "5-010201-0002-1_SOL_Проблема_с_семплами.md"
  "5-010201-0004-1_SOL_Глобальные_функции_s()_sound().md"
  "4-010401-0100-1_TASK_create_decimal_generator.md"
  "5-010401-0101-1_SOL_decimal_algorithm.md"
)

for check_file in "${check_files[@]}"; do
  if [ -f "$check_file" ]; then
    name=$(grep -m1 "^name:" "$check_file" | cut -d: -f2- | sed 's/^ *//; s/ *$//')
    echo "📄 $check_file:"
    echo "   $name"
    echo ""
  fi
done
