#!/bin/bash
# analyze-file-names.sh - анализ имен файлов

echo "=== АНАЛИЗ ИМЕН ФАЙЛОВ UCH-DOCS ==="
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

# 1. Общая статистика
TOTAL_FILES=$(find . -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')

echo "📊 ОБЩАЯ СТАТИСТИКА:"
echo "  Всего .md файлов в корне: $TOTAL_FILES"
echo ""

# 2. Файлы с правильным форматом (XX - Name.md)
CORRECT_COUNT=0
INCORRECT_FILES=()

echo "🔍 АНАЛИЗ ФОРМАТА ИМЕН:"
echo ""

for file in *.md; do
    if [ -f "$file" ]; then
        # Проверяем формат XX - Name.md (XX = HEX 00-FF)
        if [[ "$file" =~ ^[0-9A-F]{2}\ -\ .+\.md$ ]]; then
            CORRECT_COUNT=$((CORRECT_COUNT + 1))
        elif [[ "$file" =~ ^[0-9A-F]{2}-[0-9A-F]{2}\ -\ .+\.md$ ]]; then
            CORRECT_COUNT=$((CORRECT_COUNT + 1))
        elif [[ "$file" =~ ^[0-9A-F]{2}-[0-9A-F]{2}-[0-9A-F]{2}\ -\ .+\.md$ ]]; then
            CORRECT_COUNT=$((CORRECT_COUNT + 1))
        elif [[ "$file" =~ ^[0-9A-F]{2}-[0-9A-F]{2}-[0-9A-F]{2}-[0-9A-F]{2}\ -\ .+\.md$ ]]; then
            CORRECT_COUNT=$((CORRECT_COUNT + 1))
        else
            INCORRECT_FILES+=("$file")
        fi
    fi
done

echo "  Правильный формат (с ID в начале): $CORRECT_COUNT"
echo "  Неправильный формат (без ID): $((TOTAL_FILES - CORRECT_COUNT))"
echo ""

# 3. Примеры неправильных файлов
if [ ${#INCORRECT_FILES[@]} -gt 0 ]; then
    echo "📋 ФАЙЛЫ БЕЗ ID В НАЧАЛЕ (первые 10):"
    for file in "${INCORRECT_FILES[@]:0:10}"; do
        echo "  ✗ $file"
    done
    
    if [ ${#INCORRECT_FILES[@]} -gt 10 ]; then
        echo "  ... и еще $(( ${#INCORRECT_FILES[@]} - 10 ))"
    fi
else
    echo "✅ Все файлы имеют правильный формат!"
fi

echo ""
echo "🔍 ДЕТАЛЬНЫЙ АНАЛИЗ НЕПРАВИЛЬНЫХ ФАЙЛОВ:"
echo ""

# Проверим можно ли определить ID из frontmatter
echo "Проверка frontmatter у файлов без ID в имени:"
echo ""

COUNT_WITH_FM_ID=0
COUNT_WITHOUT_FM_ID=0

for file in "${INCORRECT_FILES[@]:0:5}"; do
    if [ -f "$file" ]; then
        echo "📄 $file"
        
        # Ищем ID в frontmatter
        FM_ID=$(grep -i "^id:" "$file" 2>/dev/null | head -1 | sed 's/id: *"*\([^"]*\)"*/\1/' | tr -d ' ' | tr -d '"')
        
        if [ -n "$FM_ID" ]; then
            echo "  ✅ ID в frontmatter: $FM_ID"
            COUNT_WITH_FM_ID=$((COUNT_WITH_FM_ID + 1))
            
            # Предлагаем новое имя
            NEW_NAME="${FM_ID} - ${file}"
            echo "  💡 Предлагаемое имя: $NEW_NAME"
        else
            echo "  ❌ Нет ID в frontmatter"
            COUNT_WITHOUT_FM_ID=$((COUNT_WITHOUT_FM_ID + 1))
        fi
        echo ""
    fi
done

echo "📊 СВОДКА ПО ПЕРЕИМЕНОВАНИЮ:"
echo "  Всего файлов без ID в имени: ${#INCORRECT_FILES[@]}"
echo "  Из них с ID в frontmatter: $COUNT_WITH_FM_ID"
echo "  Без ID в frontmatter: $COUNT_WITHOUT_FM_ID"
echo ""
echo "🚀 РЕКОМЕНДАЦИИ:"
echo "  1. Файлы с ID в frontmatter можно переименовать автоматически"
echo "  2. Файлы без ID в frontmatter требуют ручной обработки"
echo "  3. Сначала сделать backup всех файлов"