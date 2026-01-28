#!/bin/bash
echo "🔄 ПОЛНОЕ ОБНОВЛЕНИЕ FRONTMATTER ПО НОВОЙ СИСТЕМЕ"
echo "================================================"
echo ""
echo "Обновляем: уровень, тип, статус согласно документу 3-010402-1"
echo ""

# Таблица соответствия типов по уровням
declare -A type_to_level
type_to_level[PROD]=1
type_to_level[VISION]=1
type_to_level[STRAT]=1
type_to_level[ROAD]=1
type_to_level[BUS]=1
type_to_level[BRAND]=1
type_to_level[LINE]=2
type_to_level[PLAT]=2
type_to_level[SERV]=2
type_to_level[TOOL]=2
type_to_level[LIB]=2
type_to_level[APP]=2
type_to_level[COMP]=3
type_to_level[MOD]=3
type_to_level[SYS]=3
type_to_level[API]=3
type_to_level[DB]=3
type_to_level[INFRA]=3
type_to_level[TASK]=4
type_to_level[FEAT]=4
type_to_level[RES]=4
type_to_level[TEST]=4
type_to_level[IMPROV]=4
type_to_level[REF]=4
type_to_level[SOL]=5
type_to_level[CODE]=5
type_to_level[BUG]=5
type_to_level[ALG]=5
type_to_level[CONF]=5
type_to_level[SCRIPT]=5
type_to_level[REPORT]=6
type_to_level[METRIC]=6
type_to_level[ANALYT]=6
type_to_level[LOG]=6
type_to_level[BACKUP]=6
type_to_level[AUDIT]=6

# Общие типы (всегда доступны)
general_types="ARCH DOC SPEC DESIGN PLAN PROC REV TUT GUIDE KANBAN DEBT MIG OTHER"

updated_count=0
processed_count=0

# Обрабатываем UCH документы
find . -name "[0-9]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  filename=$(basename "$f")
  processed_count=$((processed_count + 1))
  
  # Извлекаем информацию из имени файла
  file_id=$(echo "$filename" | grep -oE '^[0-9]+-[0-9]+-[0-9]+' | head -1)
  file_type=$(echo "$filename" | grep -oE '_[A-Z]+_' | sed 's/_//g')
  slug=$(echo "$filename" | sed 's/^[0-9]*-[0-9]*-[0-9]*_[A-Z]*_//' | sed 's/\.md$//')
  
  if [ -n "$file_id" ] && [ -n "$file_type" ]; then
    # Определяем уровень из ID
    level_from_id=$(echo "$file_id" | cut -d'-' -f1)
    
    # Определяем правильный тип и уровень
    correct_level=${type_to_level[$file_type]}
    
    # Если тип не найден в таблице уровневых типов, проверяем общие типы
    if [ -z "$correct_level" ]; then
      # Проверяем, является ли это общим типом
      if echo "$general_types" | grep -qw "$file_type"; then
        correct_level=$level_from_id  # Общие типы используют уровень из ID
      else
        # Неизвестный тип - используем уровень из ID
        correct_level=$level_from_id
        echo "⚠️  Неизвестный тип: $file_type в файле $filename"
      fi
    fi
    
    # Получаем человекочитаемое имя из slug
    readable_name=$(echo "$slug" | tr '_' ' ' | sed 's/\./-/g')
    
    echo "📄 Обработка: $filename"
    echo "   ID: $file_id"
    echo "   Тип из имени: $file_type"
    echo "   Уровень из ID: $level_from_id"
    echo "   Правильный уровень: $correct_level"
    echo "   Имя: $readable_name"
    
    # Создаем временный файл с обновленным frontmatter
    temp_file="${f}.tmp"
    
    # Обрабатываем файл построчно
    in_frontmatter=false
    frontmatter_updated=false
    
    while IFS= read -r line || [ -n "$line" ]; do
      # Начало frontmatter
      if [[ "$line" == "---" ]] && [ "$in_frontmatter" = false ]; then
        in_frontmatter=true
        echo "$line" >> "$temp_file"
        continue
      fi
      
      # Конец frontmatter
      if [[ "$line" == "---" ]] && [ "$in_frontmatter" = true ]; then
        in_frontmatter=false
        echo "$line" >> "$temp_file"
        continue
      fi
      
      # Внутри frontmatter
      if [ "$in_frontmatter" = true ]; then
        # Обновляем поля
        case "$line" in
          id:*)
            echo "id: \"$file_id\"" >> "$temp_file"
            frontmatter_updated=true
            ;;
          name:*)
            echo "name: \"$readable_name\"" >> "$temp_file"
            frontmatter_updated=true
            ;;
          type:*)
            echo "type: \"$file_type\"" >> "$temp_file"
            frontmatter_updated=true
            ;;
          level:*)
            echo "level: $correct_level" >> "$temp_file"
            frontmatter_updated=true
            ;;
          status:*)
            # Оставляем текущий статус или ставим active по умолчанию
            echo "$line" >> "$temp_file"
            ;;
          *)
            # Все остальные поля оставляем как есть
            echo "$line" >> "$temp_file"
            ;;
        esac
      else
        # Вне frontmatter - копируем как есть
        echo "$line" >> "$temp_file"
      fi
    done < "$f"
    
    if [ "$frontmatter_updated" = true ]; then
      mv "$temp_file" "$f"
      updated_count=$((updated_count + 1))
      echo "   ✅ Обновлено"
    else
      rm -f "$temp_file"
      echo "   ⚠️  Не было frontmatter для обновления"
    fi
    
    echo ""
  fi
done

echo "========================================"
echo "📊 ИТОГ:"
echo "   Обработано файлов: $processed_count"
echo "   Обновлено frontmatter: $updated_count"
echo ""
echo "⚠️  ВАЖНО: Некоторые типы (SNAP) не соответствуют новой системе."
echo "   Нужно решить, как их преобразовать (например, в REPORT или LOG)."
