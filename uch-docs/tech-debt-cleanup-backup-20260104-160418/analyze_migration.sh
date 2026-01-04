#!/bin/bash

# Создаем директорию для миграции
backup_dir="migration-backup/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$backup_dir"

echo "📊 АНАЛИЗ ТЕКУЩИХ ДОКУМЕНТОВ:" > "$backup_dir/analysis.txt"
echo "=============================" >> "$backup_dir/analysis.txt"

# Счетчики
total_count=0
level1_count=0
level2_count=0
level3_count=0
level4_count=0

# Анализируем каждый .md файл
find . -name "*.md" -type f | while read file; do
    if grep -q "^id:" "$file"; then
        total_count=$((total_count + 1))
        
        # Извлекаем данные из YAML frontmatter
        id=$(grep "^id:" "$file" | head -1 | sed 's/^id: *"\(.*\)"/\1/' | tr -d '"' | xargs)
        type=$(grep "^type:" "$file" 2>/dev/null | head -1 | sed 's/^type: *"\(.*\)"/\1/' | tr -d '"' | xargs || echo "N/A")
        level=$(grep "^level:" "$file" 2>/dev/null | head -1 | sed 's/^level: *\([0-9]*\)/\1/' | xargs || echo "N/A")
        name=$(basename "$file" .md)
        
        # Определяем новый ID по целевой системе
        # Разбираем старый ID по частям
        IFS='-' read -r -a parts <<< "$id"
        
        if [[ "$id" == "00" ]]; then
            # UCH hub - остается как есть
            new_id="00"
            new_level=1
            new_type="hub"
            comment="✅ Хаб UCH"
            level1_count=$((level1_count + 1))
            
        elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 2 ]]; then
            # 00-XX -> должен стать XX (уровень 1)
            new_id="${parts[1]}"
            new_level=1
            
            # Определяем тип по имени или контексту
            if [[ "$name" == *"Линия"* ]] || [[ "$name" == *"Документация"* ]]; then
                new_type="line"
            elif [[ "$name" == *"Блог"* ]]; then
                new_type="line"
            elif [[ "$name" == *"Студия"* ]]; then
                new_type="line"
            else
                new_type="line"  # по умолчанию
            fi
            comment="🔧 Линия в хабе 00 -> уровень 1"
            level1_count=$((level1_count + 1))
            
        elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 3 ]]; then
            # 00-XX-YY -> должен стать XX-YY (уровень 2)
            new_id="${parts[1]}-${parts[2]}"
            new_level=2
            
            # Определяем тип
            if [[ "$type" == "snapshot" ]]; then
                new_type="$type"
            elif [[ "$type" == "epic" || "$type" == "component" || "$type" == "module" ]]; then
                new_type="$type"
            else
                new_type="epic"  # по умолчанию для уровня 2
            fi
            comment="🔧 Компонент -> уровень 2"
            level2_count=$((level2_count + 1))
            
        elif [[ "${parts[0]}" == "00" && "${#parts[@]}" -eq 4 ]]; then
            # 00-XX-YY-ZZ -> должен стать XX-YY-ZZ (уровень 3)
            new_id="${parts[1]}-${parts[2]}-${parts[3]}"
            new_level=3
            
            # Определяем тип
            if [[ "$type" == "task" || "$type" == "feature" || "$type" == "bug" || "$type" == "research" ]]; then
                new_type="$type"
            else
                new_type="task"  # по умолчанию для уровня 3
            fi
            comment="🔧 Задача -> уровень 3"
            level3_count=$((level3_count + 1))
            
        else
            # Другие форматы ID
            new_id="$id"
            new_level="$level"
            new_type="$type"
            comment="⚠️ Неизвестный формат"
            if [[ "$level" == "4" ]]; then
                level4_count=$((level4_count + 1))
            fi
        fi
        
        # Выводим и сохраняем результат
        echo "$file" >> "$backup_dir/analysis.txt"
        echo "  Старый: ID=$id, Type=$type, Level=$level" >> "$backup_dir/analysis.txt"
        echo "  Новый:  ID=$new_id, Type=$new_type, Level=$new_level" >> "$backup_dir/analysis.txt"
        echo "  $comment" >> "$backup_dir/analysis.txt"
        echo "  ---" >> "$backup_dir/analysis.txt"
    fi
done

# Создаем план миграции
echo "📋 ПЛАН МИГРАЦИИ:" > "$backup_dir/migration_plan.txt"
echo "================" >> "$backup_dir/migration_plan.txt"
echo "" >> "$backup_dir/migration_plan.txt"

echo "1. ДОКУМЕНТЫ УРОВНЯ 1 (остаются как есть):" >> "$backup_dir/migration_plan.txt"
grep "ID=00," "$backup_dir/analysis.txt" | head -5 >> "$backup_dir/migration_plan.txt"
echo "" >> "$backup_dir/migration_plan.txt"

echo "2. ДОКУМЕНТЫ УРОВНЯ 1 (00-XX -> XX):" >> "$backup_dir/migration_plan.txt"
grep "Линия в хабе 00 -> уровень 1" "$backup_dir/analysis.txt" | head -10 >> "$backup_dir/migration_plan.txt"
echo "" >> "$backup_dir/migration_plan.txt"

echo "3. ДОКУМЕНТЫ УРОВНЯ 2 (00-XX-YY -> XX-YY):" >> "$backup_dir/migration_plan.txt"
grep "Компонент -> уровень 2" "$backup_dir/analysis.txt" | head -10 >> "$backup_dir/migration_plan.txt"
echo "" >> "$backup_dir/migration_plan.txt"

echo "4. ДОКУМЕНТЫ УРОВНЯ 3 (00-XX-YY-ZZ -> XX-YY-ZZ):" >> "$backup_dir/migration_plan.txt"
grep "Задача -> уровень 3" "$backup_dir/analysis.txt" | head -10 >> "$backup_dir/migration_plan.txt"

echo ""
echo "✅ Анализ завершен!"
echo "📊 Результаты сохранены в: $backup_dir/"
echo "📄 Основной анализ: $backup_dir/analysis.txt"
echo "📋 План миграции: $backup_dir/migration_plan.txt"
echo ""
echo "📈 СТАТИСТИКА:"
echo "Документов найдено: $total_count"
echo "Уровень 1 (хабы/линии): $level1_count"
echo "Уровень 2 (компоненты): $level2_count"
echo "Уровень 3 (задачи): $level3_count"
echo "Уровень 4 (подзадачи): $level4_count"
