#!/bin/bash
echo "=== АНАЛИЗ ТЕХНИЧЕСКОГО ДОЛГА ==="
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

echo "📊 ОБЩАЯ СТАТИСТИКА:"
TOTAL_SCRIPTS=$(find . -maxdepth 1 -name "*.sh" -type f | wc -l | tr -d ' ')
echo "Всего скриптов: $TOTAL_SCRIPTS"
echo ""

echo "🔍 КАТЕГОРИИ СКРИПТОВ:"
echo ""
echo "1. uch- СКРИПТЫ:"
find . -maxdepth 1 -name "uch-*.sh" -type f | sed 's|^./||' | sort | head -10
echo ""

echo "2. ВРЕМЕННЫЕ СКРИПТЫ:"
find . -maxdepth 1 -name "step*.sh" -o -name "test*.sh" | sed 's|^./||' | sort
echo ""

echo "3. СТАРЫЕ СКРИПТЫ (30+ дней):"
find . -maxdepth 1 -name "*.sh" -type f -mtime +30 | sed 's|^./||' | sort
echo ""

echo "💡 РЕКОМЕНДАЦИИ:"
echo "- Удалить скрипты старше 30 дней"
echo "- Объединить дублирующие uch- скрипты"
echo "- Создать систему lifecycle management"
