#!/bin/bash

echo "📊 МАССОВЫЙ АНАЛИЗ ДОКУМЕНТОВ UCH-DOCS"
echo "======================================"
echo ""

# Создаем директорию для отчетов
REPORT_DIR="analysis-reports/$(date +%Y%m%d-%H%M%S)"
mkdir -p "$REPORT_DIR"

# Файлы для отчетов
SUMMARY_FILE="$REPORT_DIR/summary.txt"
ERRORS_FILE="$REPORT_DIR/errors.txt"
WARNINGS_FILE="$REPORT_DIR/warnings.txt"
VALID_FILES="$REPORT_DIR/valid_files.txt"

# Счетчики
TOTAL_FILES=0
FILES_WITH_YAML=0
FILES_WITH_ERRORS=0
FILES_WITH_WARNINGS=0
VALID_FILES_COUNT=0

TOTAL_ERRORS=0
TOTAL_WARNINGS=0

echo "🔍 Поиск и анализ документов..."
echo ""

# Анализируем каждый .md файл
for file in *.md; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    TOTAL_FILES=$((TOTAL_FILES + 1))
    
    # Проверяем наличие YAML frontmatter
    FIRST_LINE=$(head -1 "$file" 2>/dev/null)
    if [ "$FIRST_LINE" != "---" ]; then
        echo "⏩ Пропускаем (нет YAML): $file"
        continue
    fi
    
    FILES_WITH_YAML=$((FILES_WITH_YAML + 1))
    
    echo "📄 Анализ: $file"
    
    # Запускаем анализатор и захватываем вывод
    ANALYSIS_OUTPUT=$(uch-scripts/analyzer/analyze-doc.sh "$file" 2>&1)
    
    # Извлекаем количество ошибок и предупреждений
    ERRORS=$(echo "$ANALYSIS_OUTPUT" | grep "Ошибок:" | awk '{print $2}')
    WARNINGS=$(echo "$ANALYSIS_OUTPUT" | grep "Предупреждений:" | awk '{print $2}')
    
    # Сохраняем полный отчет
    echo "=== $file ===" > "$REPORT_DIR/${file}.report.txt"
    echo "$ANALYSIS_OUTPUT" >> "$REPORT_DIR/${file}.report.txt"
    
    # Анализируем результаты
    if [ -n "$ERRORS" ] && [ "$ERRORS" -gt 0 ]; then
        echo "❌ Ошибок: $ERRORS, Предупреждений: ${WARNINGS:-0}"
        FILES_WITH_ERRORS=$((FILES_WITH_ERRORS + 1))
        TOTAL_ERRORS=$((TOTAL_ERRORS + ERRORS))
        echo "$file - $ERRORS ошибок" >> "$ERRORS_FILE"
    elif [ -n "$WARNINGS" ] && [ "$WARNINGS" -gt 0 ]; then
        echo "⚠️  Ошибок: 0, Предупреждений: $WARNINGS"
        FILES_WITH_WARNINGS=$((FILES_WITH_WARNINGS + 1))
        TOTAL_WARNINGS=$((TOTAL_WARNINGS + WARNINGS))
        echo "$file - $WARNINGS предупреждений" >> "$WARNINGS_FILE"
    else
        echo "✅ Валиден"
        VALID_FILES_COUNT=$((VALID_FILES_COUNT + 1))
        echo "$file" >> "$VALID_FILES"
    fi
    
    echo ""
done

# Создаем суммарный отчет
echo "📈 СВОДНЫЙ ОТЧЕТ"
echo "================" > "$SUMMARY_FILE"
echo "📈 СВОДНЫЙ ОТЧЕТ АНАЛИЗА UCH-DOCS" >> "$SUMMARY_FILE"
echo "Дата: $(date)" >> "$SUMMARY_FILE"
echo "================" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

echo "📊 СТАТИСТИКА:" >> "$SUMMARY_FILE"
echo "-------------" >> "$SUMMARY_FILE"
echo "Всего файлов:          $TOTAL_FILES" >> "$SUMMARY_FILE"
echo "Файлов с YAML:         $FILES_WITH_YAML" >> "$SUMMARY_FILE"
echo "Валидных файлов:       $VALID_FILES_COUNT" >> "$SUMMARY_FILE"
echo "Файлов с ошибками:     $FILES_WITH_ERRORS" >> "$SUMMARY_FILE"
echo "Файлов с предупреждениями: $FILES_WITH_WARNINGS" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"
echo "Всего ошибок:          $TOTAL_ERRORS" >> "$SUMMARY_FILE"
echo "Всего предупреждений:  $TOTAL_WARNINGS" >> "$SUMMARY_FILE"
echo "" >> "$SUMMARY_FILE"

# Статистика по типам проблем
echo "🔍 РАСПРЕДЕЛЕНИЕ ПРОБЛЕМ:" >> "$SUMMARY_FILE"
echo "------------------------" >> "$SUMMARY_FILE"

if [ -f "$ERRORS_FILE" ]; then
    echo "" >> "$SUMMARY_FILE"
    echo "📋 ФАЙЛЫ С ОШИБКАМИ ($FILES_WITH_ERRORS):" >> "$SUMMARY_FILE"
    echo "--------------------------------------" >> "$SUMMARY_FILE"
    cat "$ERRORS_FILE" >> "$SUMMARY_FILE"
fi

if [ -f "$WARNINGS_FILE" ]; then
    echo "" >> "$SUMMARY_FILE"
    echo "⚠️  ФАЙЛЫ С ПРЕДУПРЕЖДЕНИЯМИ ($FILES_WITH_WARNINGS):" >> "$SUMMARY_FILE"
    echo "---------------------------------------------" >> "$SUMMARY_FILE"
    cat "$WARNINGS_FILE" >> "$SUMMARY_FILE"
fi

if [ -f "$VALID_FILES" ]; then
    echo "" >> "$SUMMARY_FILE"
    echo "✅ ВАЛИДНЫЕ ФАЙЛЫ ($VALID_FILES_COUNT):" >> "$SUMMARY_FILE"
    echo "--------------------------------" >> "$SUMMARY_FILE"
    cat "$VALID_FILES" >> "$SUMMARY_FILE"
fi

# Выводим сводный отчет на экран
cat "$SUMMARY_FILE"

echo ""
echo "📁 Отчеты сохранены в: $REPORT_DIR/"
echo "📄 Сводный отчет: $SUMMARY_FILE"
echo ""
echo "🔧 РЕКОМЕНДАЦИИ ПО ИСПРАВЛЕНИЮ:"
echo "================================"

# Проверяем наиболее частые проблемы
echo ""
echo "1. Добавить поле slug в документы без него:"
grep -l "^slug:" *.md 2>/dev/null | wc -l | xargs echo "   Документов со slug:"
grep -L "^slug:" *.md 2>/dev/null | wc -l | xargs echo "   Документов без slug:"

echo ""
echo "2. Проверить соответствие типов и уровней:"
echo "   Используйте: uch-scripts/analyzer/analyze-doc.sh <файл.md> для детального анализа"

echo ""
echo "3. Исправить иерархию (level 1 с parent):"
find . -name "*.md" -exec grep -l "level: 1" {} \; | xargs grep -l "parent:" 2>/dev/null | wc -l | xargs echo "   Документов уровня 1 с parent:"

echo ""
echo "🔍 ПРОВЕРКА КОНФЛИКТОВ ID:"
echo "=========================="
uch-scripts/analyzer/check-id-conflicts.sh | tail -20

# Добавляем информацию о конфликтах в отчет
echo "" >> "$SUMMARY_FILE"
echo "🔍 ПРОВЕРКА КОНФЛИКТОВ ID:" >> "$SUMMARY_FILE"
echo "==========================" >> "$SUMMARY_FILE"
uch-scripts/analyzer/check-id-conflicts.sh >> "$SUMMARY_FILE"
