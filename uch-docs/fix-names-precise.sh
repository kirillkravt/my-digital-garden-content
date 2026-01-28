#!/bin/bash
echo "🔧 ТОЧНОЕ ИСПРАВЛЕНИЕ ИМЕН В FRONTMATTER"
echo "========================================"
echo ""
echo "Удаляем ВСЕ цифровые паттерны из начала имени"
echo "Пример: '6 - 010400 - 004 - 1 SNAP 20251227' → '20251227'"
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
  
  # Получаем текущее имя из frontmatter
  current_name=$(grep -m1 "^name:" "$f" 2>/dev/null | cut -d: -f2- | sed 's/^ *//; s/ *$//; s/^"//; s/"$//')
  
  if [ -n "$current_name" ]; then
    # Извлекаем информацию из имени файла
    file_id=$(echo "$filename" | grep -oE '^[0-9]+-[0-9]+-[0-9]+' | head -1)
    file_type=$(echo "$filename" | grep -oE '_[A-Z]+_' | sed 's/_//g')
    
    # 1. Для SNAP документов: оставляем только дату в конце
    if [ "$file_type" = "SNAP" ]; then
      # Ищем дату в формате YYYYMMDD или подобном
      if [[ "$current_name" =~ ([0-9]{8}) ]]; then
        readable_name="${BASH_REMATCH[1]}"
      else
        # Если нет даты, берем часть после последнего пробела
        readable_name=$(echo "$current_name" | rev | cut -d' ' -f1 | rev)
      fi
    # 2. Для других документов: удаляем все цифровые паттерны в начале
    else
      # Удаляем паттерны типа "X - XXXX - XXX - X TYPE"
      readable_name=$(echo "$current_name" | sed -E 's/^[0-9]+[[:space:]]*-[[:space:]]*[0-9]+[[:space:]]*-[[:space:]]*[0-9]+[[:space:]]*-[[:space:]]*[0-9]+[[:space:]]+[A-Z]+[[:space:]]+//')
      
      # Если не удалилось, удаляем только ID паттерн
      if [ "$readable_name" = "$current_name" ]; then
        readable_name=$(echo "$current_name" | sed -E 's/^[0-9]+-[0-9]+-[0-9]+[[:space:]]*-[[:space:]]*[0-9]+[[:space:]]+[A-Z]+[[:space:]]+//')
      fi
      
      # Если все еще не изменилось, берем slug из имени файла
      if [ "$readable_name" = "$current_name" ] || [ -z "$readable_name" ]; then
        slug_part=$(echo "$filename" | sed "s/^${file_id}_${file_type}_//" | sed 's/\.md$//')
        readable_name=$(echo "$slug_part" | sed 's/_/ /g' | sed 's/  / /g')
      fi
    fi
    
    # Очищаем имя от лишних пробелов и делаем первую букву заглавной
    readable_name=$(echo "$readable_name" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^./\u&/')
    
    # Проверяем, изменилось ли имя
    if [ "$readable_name" != "$current_name" ] && [ -n "$readable_name" ]; then
      echo "📝 $filename"
      echo "   Было: '$current_name'"
      echo "   Стало: '$readable_name'"
      
      # Обновляем имя в файле (macOS совместимая версия sed)
      sed -i '' "s/name:.*/name: \"$readable_name\"/" "$f"
      
      fixed_count=$((fixed_count + 1))
      echo ""
    fi
  fi
done

echo "========================================"
echo "📊 ИТОГ: Исправлено имен: $fixed_count"
echo ""
echo "🔍 ПРОВЕРКА ИСПРАВЛЕННЫХ ФАЙЛОВ:"
echo "-------------------------------"

# Проверяем конкретные файлы
check_files=(
  "6-010400-004-1_SNAP_20251227.md"
  "4-010400-0200-1_TASK_Архитектурная_вилка_UCH-Docs.md"
  "4-010400-0600-1_TASK_последовательное_создание_ нескольких_документов.md"
  "6-010000-002-1_SNAP_20251225.md"
  "2-010400-7_ARCH_Documentation-first_подход.md"
  "1-010000-6_BRAND_brandbook.md"
)

for check_file in "${check_files[@]}"; do
  if [ -f "$check_file" ]; then
    name=$(grep -m1 "^name:" "$check_file" | cut -d: -f2- | sed 's/^ *//; s/ *$//')
    echo "📄 $check_file:"
    echo "   $name"
    echo ""
  fi
done
