#!/bin/bash
# uch-tech-debt-fixed.sh - анализ технического долга автоматизации (исправленная версия)

echo "=== АНАЛИЗ ТЕХНИЧЕСКОГО ДОЛГА АВТОМАТИЗАЦИИ UCH ==="
echo "Версия: 1.0.1 (исправленная для macOS)"
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_section() { echo -e "\n${BLUE}=== $1 ===${NC}"; }
print_ok() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

print_section "📁 АНАЛИЗ СКРИПТОВ АВТОМАТИЗАЦИИ"

# 1. Анализ всех скриптов
SCRIPTS=$(find . -maxdepth 1 -name "*.sh" -type f | sort)
TOTAL_SCRIPTS=$(echo "$SCRIPTS" | wc -l | tr -d ' ')

echo "Всего скриптов: $TOTAL_SCRIPTS"
echo ""

# Категоризируем скрипты (без ассоциативных массивов для совместимости)
echo "📊 КАТЕГОРИИ СКРИПТОВ:"
echo ""

# Продакшн скрипты
echo "1. ПРОДАКШН СКРИПТЫ:"
find . -maxdepth 1 -name "uch-(metrics|project-tech|report-generator|generate-full|cron-manager)*.sh" -type f | sed 's|^./||' | sort | while read script; do
    echo "  • $script"
done

echo ""
echo "2. ЭКСПЕРИМЕНТАЛЬНЫЕ СКРИПТЫ:"
find . -maxdepth 1 -name "uch-*.sh" ! -name "uch-(metrics|project-tech|report-generator|generate-full|cron-manager)*.sh" -type f | sed 's|^./||' | sort | while read script; do
    echo "  • $script"
done | head -10

echo ""
echo "3. ВРЕМЕННЫЕ СКРИПТЫ:"
find . -maxdepth 1 -name "step*.sh" -o -name "test*.sh" -o -name "manual*.sh" -o -name "quick*.sh" -o -name "simple*.sh" | sed 's|^./||' | sort | while read script; do
    echo "  • $script"
done | head -10

echo ""
echo "4. УСТАРЕВШИЕ СКРИПТЫ:"
find . -maxdepth 1 -name "*backup*.sh" -o -name "*old*.sh" -o -name "*v[0-9]*.sh" -o -name "*tmp*.sh" | sed 's|^./||' | sort | while read script; do
    echo "  • $script"
done

print_section "🔍 АНАЛИЗ ИСПОЛЬЗОВАНИЯ СКРИПТОВ"

echo "СКРИПТЫ ПО ДАТЕ ПОСЛЕДНЕГО ИЗМЕНЕНИЯ:"
echo ""

# Сортируем по дате изменения (сначала старые)
find . -maxdepth 1 -name "*.sh" -type f -exec stat -f "%m %N" {} \; | sort -n | head -15 | while read -r line; do
    timestamp=$(echo "$line" | awk '{print $1}')
    filename=$(echo "$line" | awk '{print $2}' | sed 's|^\./||')
    date_str=$(date -r "$timestamp" "+%Y-%m-%d %H:%M")
    age_days=$(( ( $(date +%s) - timestamp ) / 86400 ))
    
    if [ $age_days -gt 30 ]; then
        echo "  ⚰️  $filename (изменен: $date_str, $age_days дней назад)"
    elif [ $age_days -gt 7 ]; then
        echo "  🗑️  $filename (изменен: $date_str, $age_days дней назад)"
    else
        echo "  ✅ $filename (изменен: $date_str, $age_days дней назад)"
    fi
done

print_section "📊 АНАЛИЗ ВРЕМЕННЫХ ФАЙЛОВ"

echo "ВРЕМЕННЫЕ ФАЙЛЫ И BACKUP:"
echo ""

TEMP_FILES_COUNT=0
for pattern in "*.backup" "*.tmp*" "*.test*" "backup-*" "test-*" "temp-*" "*~" ".*.swp" "*.old" "*.bak"; do
    files_count=$(find . -maxdepth 2 -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$files_count" -gt 0 ]; then
        echo "  $pattern: $files_count файлов"
        TEMP_FILES_COUNT=$((TEMP_FILES_COUNT + files_count))
    fi
done

if [ $TEMP_FILES_COUNT -eq 0 ]; then
    print_ok "Временных файлов не найдено"
else
    print_warning "Найдено временных файлов: $TEMP_FILES_COUNT"
fi

print_section "📋 РЕКОМЕНДАЦИИ ПО ОЧИСТКЕ"

echo "1. УДАЛИТЬ СРАЗУ:"
echo "   • Файлы старше 30 дней:"
find . -maxdepth 1 -name "*.sh" -type f -mtime +30 | sed 's|^./||' | head -5 | sed 's/^/     - /'

echo ""
echo "2. ПРОВЕРИТЬ И УДАЛИТЬ:"
echo "   • Экспериментальные скрипты старше 7 дней:"
find . -maxdepth 1 -name "uch-*.sh" ! -name "uch-(metrics|project-tech|report-generator)*.sh" -type f -mtime +7 | sed 's|^./||' | head -5 | sed 's/^/     - /'

echo ""
echo "3. СОХРАНИТЬ:"
echo "   • Ключевые системные скрипты:"
for script in "uch-metrics-collector.sh" "uch-project-tech-collector.sh" "uch-report-generator.sh" "uch-generate-full-report.sh"; do
    if [ -f "$script" ]; then
        echo "     - $script"
    fi
done

echo ""
echo "📊 СВОДКА:"
echo "  • Всего скриптов: $TOTAL_SCRIPTS"
echo "  • Временных файлов: $TEMP_FILES_COUNT"
echo "  • Рекомендуется к удалению: $(find . -maxdepth 1 -name "*.sh" -type f -mtime +30 | wc -l | tr -d ' ')"
