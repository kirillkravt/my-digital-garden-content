#!/bin/bash
# analyze-doc-names.sh - Анализ имен документов в текущей директории

echo "=== АНАЛИЗ ИМЕН ДОКУМЕНТОВ ==="
echo "Директория: $(pwd)"
echo "Дата: $(date)"
echo ""

# Общая статистика
total_files=$(ls *.md 2>/dev/null | wc -l | tr -d ' ')
echo "📊 ОБЩАЯ СТАТИСТИКА:"
echo "  Всего .md файлов: $total_files"
echo ""

# Анализ формата
correct=0
incorrect=0
incorrect_list=()

echo "🔍 АНАЛИЗ ФОРМАТА ИМЕН:"
echo ""

for file in *.md; do
    [ -f "$file" ] || continue
    
    # Проверяем правильный формат: ID тип - Название.md
    # И название НЕ должно содержать " - " внутри
    
    if [[ "$file" =~ ^[0-9A-F]{2}(-[0-9A-F]{2})*\ [a-z]{2,6}\ -\ .+\.md$ ]] && [[ ! "$file" == *" - "*" - "* ]]; then
        correct=$((correct + 1))
    else
        incorrect=$((incorrect + 1))
        incorrect_list+=("$file")
    fi
done

echo "  ✅ Правильный формат: $correct"
echo "  ❌ Неправильный формат: $incorrect"
echo ""

# Показать проблемные файлы
if [ ${#incorrect_list[@]} -gt 0 ]; then
    echo "📋 ФАЙЛЫ С НЕПРАВИЛЬНЫМ ФОРМАТОМ:"
    for file in "${incorrect_list[@]}"; do
        echo "  ✗ $file"
    done
    echo ""
    
    echo "🚀 РЕКОМЕНДАЦИИ:"
    echo "  Запустите fix-doc-names.sh для исправления:"
    echo "  /Users/kirillkravcov/UniversalCreativeHub/utils/fix-doc-names.sh"
else
    echo "🎉 Все файлы имеют правильный формат!"
fi
