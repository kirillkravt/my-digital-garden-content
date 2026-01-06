#!/bin/bash
# fixed_analyze.sh - Исправленный анализ имен файлов

echo "=== ИСПРАВЛЕННЫЙ АНАЛИЗ ИМЕН ФАЙЛОВ ==="
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

# 1. Общая статистика
TOTAL_FILES=$(find . -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')

echo "📊 ОБЩАЯ СТАТИСТИКА:"
echo "  Всего .md файлов в корне: $TOTAL_FILES"
echo ""

# 2. Файлы с правильным форматом (ID тип - Название.md)
CORRECT_COUNT=0
CORRECT_FILES=()
INCORRECT_FILES=()

echo "🔍 АНАЛИЗ ФОРМАТА ИМЕН:"
echo ""

for file in *.md; do
    if [ -f "$file" ]; then
        # Проверяем новый формат: ID тип - Название.md
        # Где ID: 00, 00-01, 00-01-02 и т.д.
        # тип: 2-4 символа (arc, doc, snap, task, analysis и т.д.)
        if [[ "$file" =~ ^[0-9A-F]{2}(-[0-9A-F]{2})*\ [a-z]{2,6}\ -\ .+\.md$ ]]; then
            CORRECT_COUNT=$((CORRECT_COUNT + 1))
            CORRECT_FILES+=("$file")
        else
            INCORRECT_FILES+=("$file")
        fi
    fi
done

echo "  Правильный формат (ID тип - Название): $CORRECT_COUNT"
echo "  Неправильный формат: $((TOTAL_FILES - CORRECT_COUNT))"
echo ""

# 3. Показать примеры правильных файлов
if [ ${#CORRECT_FILES[@]} -gt 0 ]; then
    echo "✅ ПРАВИЛЬНЫЕ ФАЙЛЫ (первые 5):"
    for file in "${CORRECT_FILES[@]:0:5}"; do
        echo "  ✓ $file"
    done
    echo ""
fi

# 4. Анализ неправильных файлов
if [ ${#INCORRECT_FILES[@]} -gt 0 ]; then
    echo "📋 ФАЙЛЫ С НЕПРАВИЛЬНЫМ ФОРМАТОМ (первые 10):"
    for file in "${INCORRECT_FILES[@]:0:10}"; do
        echo "  ✗ $file"
    done
    
    if [ ${#INCORRECT_FILES[@]} -gt 10 ]; then
        echo "  ... и еще $(( ${#INCORRECT_FILES[@]} - 10 ))"
    fi
    echo ""
    
    # Проверим можно ли определить ID из frontmatter
    echo "🔍 ДЕТАЛЬНЫЙ АНАЛИЗ НЕПРАВИЛЬНЫХ ФАЙЛОВ:"
    echo ""
    
    COUNT_WITH_FM_ID=0
    COUNT_WITHOUT_FM_ID=0
    EXAMPLES=()
    
    for file in "${INCORRECT_FILES[@]:0:5}"; do
        if [ -f "$file" ]; then
            # Ищем ID в frontmatter
            FM_ID=$(grep -i "^id:" "$file" 2>/dev/null | head -1 | sed 's/id: *"*\([^"]*\)"*/\1/' | tr -d ' ' | tr -d '"')
            
            if [ -n "$FM_ID" ]; then
                COUNT_WITH_FM_ID=$((COUNT_WITH_FM_ID + 1))
                
                # Определяем тип документа
                TYPE_LINE=$(grep -i "^type:" "$file" 2>/dev/null | head -1)
                TYPE=""
                if [ -n "$TYPE_LINE" ]; then
                    TYPE=$(echo "$TYPE_LINE" | sed 's/type://' | sed 's/"//g' | sed "s/'//g" | tr -d ' ' | tr -d '[:punct:]')
                    
                    # Сокращения
                    case "$TYPE" in
                        "architecture"|"arch") TYPE="arc" ;;
                        "documentation"|"doc") TYPE="doc" ;;
                        "snapshot"|"snap") TYPE="snap" ;;
                        "technicaldebt"|"tdebt") TYPE="tdebt" ;;
                        "analysis"|"analyst"|"analytics") TYPE="analysis" ;;
                        "line") TYPE="line" ;;
                        "project"|"proj") TYPE="proj" ;;
                        "task") TYPE="task" ;;
                        *) TYPE="task" ;;
                    esac
                else
                    TYPE="task"
                fi
                
                # Извлекаем имя файла (часть после " - ")
                NAME_PART=""
                if [[ "$file" == *" - "* ]]; then
                    NAME_PART=$(echo "$file" | sed 's/^[^-]*- //' | sed 's/\.md$//')
                else
                    NAME_PART=$(echo "$file" | sed 's/\.md$//')
                fi
                
                NEW_NAME="${FM_ID} ${TYPE} - ${NAME_PART}.md"
                EXAMPLES+=("$file → $NEW_NAME")
            else
                COUNT_WITHOUT_FM_ID=$((COUNT_WITHOUT_FM_ID + 1))
            fi
        fi
    done
    
    echo "📊 СВОДКА ПО ПЕРЕИМЕНОВАНИЮ:"
    echo "  Всего файлов с неправильным форматом: ${#INCORRECT_FILES[@]}"
    echo "  Из них с ID в frontmatter: $COUNT_WITH_FM_ID"
    echo "  Без ID в frontmatter: $COUNT_WITHOUT_FM_ID"
    echo ""
    
    if [ ${#EXAMPLES[@]} -gt 0 ]; then
        echo "📝 ПРИМЕРЫ ПЕРЕИМЕНОВАНИЯ:"
        for example in "${EXAMPLES[@]}"; do
            echo "  $example"
        done
        echo ""
    fi
fi

echo "🚀 РЕКОМЕНДАЦИИ:"
echo "  1. Запустите fix_rename.sh для автоматического переименования"
echo "  2. Проверьте backup перед массовым переименованием"
echo "  3. Файлы без ID в frontmatter требуют ручной обработки"