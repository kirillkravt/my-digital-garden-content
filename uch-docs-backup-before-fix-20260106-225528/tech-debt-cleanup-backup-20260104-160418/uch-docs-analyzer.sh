#!/bin/bash
# uch-docs-analyzer.sh - анализ состояния документов uch-docs

echo "=== АНАЛИЗ UCH-DOCS (КОРНЕВАЯ ПАПКА) ==="
echo "Версия: 1.0.0"
echo "Дата: $(date)"
echo ""

UCH_DOCS="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"
cd "$UCH_DOCS" || { echo "❌ Не могу перейти в $UCH_DOCS"; exit 1; }

# Цвета для вывода
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Функции
print_section() { echo -e "\n${BLUE}== $1 ==${NC}"; }
print_ok() { echo -e "${GREEN}✓${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

print_section "📁 АНАЛИЗ ИМЕН ФАЙЛОВ"

# 1. Анализ имен файлов
TOTAL_FILES=$(find . -maxdepth 1 -name "*.md" -type f | wc -l | tr -d ' ')

# Правильный формат: XX - Name.md (HEX формат)
CORRECT_FORMAT_COUNT=$(find . -maxdepth 1 -name "*.md" -type f | grep -E '^\./[0-9A-F]{2} - ' | wc -l | tr -d ' ')

# Файлы без ID в начале
NO_ID_COUNT=$(find . -maxdepth 1 -name "*.md" -type f | grep -v -E '^\./[0-9A-F]{2} - ' | wc -l | tr -d ' ')

echo "Всего файлов в корне: $TOTAL_FILES"
echo "Правильный формат (XX - Name): $CORRECT_FORMAT_COUNT"
echo "Неправильный формат: $NO_ID_COUNT"
echo ""

# Примеры правильных файлов
echo "Примеры правильных файлов:"
find . -maxdepth 1 -name "*.md" -type f | grep -E '^\./[0-9A-F]{2} - ' | head -3 | sed 's|^\./||' | sed 's/^/  ✓ /'

echo ""
echo "Примеры неправильных файлов:"
find . -maxdepth 1 -name "*.md" -type f | grep -v -E '^\./[0-9A-F]{2} - ' | head -5 | sed 's|^\./||' | sed 's/^/  ✗ /'

print_section "🔢 АНАЛИЗ HEX ID"

# Анализ HEX ID (уровни)
echo "Распределение по уровням HEX ID:"
echo ""

LEVEL_1_COUNT=$(find . -maxdepth 1 -name "*.md" -type f | grep -E '^\./[0-9A-F]{2} - ' | wc -l | tr -d ' ')
LEVEL_2_COUNT=$(find . -maxdepth 1 -name "*.md" -type f | grep -E '^\./[0-9A-F]{2}-[0-9A-F]{2} - ' | wc -l | tr -d ' ')
LEVEL_3_COUNT=$(find . -maxdepth 1 -name "*.md" -type f | grep -E '^\./[0-9A-F]{2}-[0-9A-F]{2}-[0-9A-F]{2} - ' | wc -l | tr -d ' ')
LEVEL_4_COUNT=$(find . -maxdepth 1 -name "*.md" -type f | grep -E '^\./[0-9A-F]{2}-[0-9A-F]{2}-[0-9A-F]{2}-[0-9A-F]{2} - ' | wc -l | tr -d ' ')

echo "  Уровень 1 (X0/0X): $LEVEL_1_COUNT"
echo "  Уровень 2 (XX-XX): $LEVEL_2_COUNT"
echo "  Уровень 3 (XX-XX-XX): $LEVEL_3_COUNT"
echo "  Уровень 4 (XX-XX-XX-XX): $LEVEL_4_COUNT"

print_section "📄 АНАЛИЗ FRONTMATTER"

# 2. Анализ frontmatter
FILES_WITH_FRONTMATTER=$(grep -l "^---$" *.md 2>/dev/null | wc -l | tr -d ' ')
FILES_WITHOUT_FRONTMATTER=$((TOTAL_FILES - FILES_WITH_FRONTMATTER))

echo "Файлов с frontmatter: $FILES_WITH_FRONTMATTER"
echo "Файлов без frontmatter: $FILES_WITHOUT_FRONTMATTER"
echo ""

# Проверка обязательных полей
echo "Наличие обязательных полей (в файлах с frontmatter):"

for field in id name type level status created updated; do
    COUNT=$(grep -l "^$field:" *.md 2>/dev/null | wc -l | tr -d ' ')
    PERCENTAGE=$((COUNT * 100 / FILES_WITH_FRONTMATTER))
    STATUS=""
    
    if [ $PERCENTAGE -eq 100 ]; then
        STATUS="✓"
    elif [ $PERCENTAGE -ge 80 ]; then
        STATUS="⚠"
    else
        STATUS="✗"
    fi
    
    echo "  $STATUS $field: $COUNT/$FILES_WITH_FRONTMATTER ($PERCENTAGE%)"
done

print_section "🔍 ДЕТАЛЬНЫЙ АНАЛИЗ ПРОБЛЕМ"

# Детальный анализ проблем
echo "Файлы с потенциальными проблемами:"
echo ""

# 1. ID в имени не совпадает с ID в frontmatter
echo "1. Несоответствие ID в имени и frontmatter:"
for file in *.md; do
    if [ -f "$file" ]; then
        # Извлекаем ID из имени файла
        FILE_ID=$(echo "$file" | grep -o '^[0-9A-F]\{2\}')
        
        # Извлекаем ID из frontmatter
        FRONTMATTER_ID=$(grep -i "^id:" "$file" 2>/dev/null | head -1 | sed 's/id: *"*\([^"]*\)"*/\1/' | tr -d ' ' | tr -d '"')
        
        if [ -n "$FILE_ID" ] && [ -n "$FRONTMATTER_ID" ] && [ "$FILE_ID" != "$FRONTMATTER_ID" ]; then
            echo "  ✗ $file: имя='$FILE_ID', frontmatter='$FRONTMATTER_ID'"
        fi
    fi
done | head -5

# 2. Файлы без frontmatter
echo ""
echo "2. Файлы без frontmatter (первые 5):"
grep -L "^---$" *.md 2>/dev/null | head -5 | sed 's/^/  ✗ /'

print_section "📊 СВОДКА И РЕКОМЕНДАЦИИ"

# Сводка
echo "ОБЩАЯ СВОДКА:"
echo "  Всего файлов: $TOTAL_FILES"
echo "  Правильный формат имен: $CORRECT_FORMAT_COUNT/$TOTAL_FILES ($((CORRECT_FORMAT_COUNT * 100 / TOTAL_FILES))%)"
echo "  С frontmatter: $FILES_WITH_FRONTMATTER/$TOTAL_FILES ($((FILES_WITH_FRONTMATTER * 100 / TOTAL_FILES))%)"
echo ""

echo "ПРИОРИТЕТНЫЕ ЗАДАЧИ:"
echo "  1. Переименовать $NO_ID_COUNT файлов (добавить ID в начало)"
echo "  2. Добавить frontmatter к $FILES_WITHOUT_FRONTMATTER файлам"
echo "  3. Стандартизировать frontmatter ($FILES_WITH_FRONTMATTER файлов)"
echo ""

# Сохранение в JSON для отчетов
JSON_FILE="uch-docs-analysis-$(date +%Y%m%d-%H%M%S).json"

cat > "$JSON_FILE" << EOF
{
  "analysis": {
    "date": "$(date -Iseconds)",
    "version": "1.0.0",
    "total_files": $TOTAL_FILES
  },
  "file_names": {
    "correct_format": $CORRECT_FORMAT_COUNT,
    "incorrect_format": $NO_ID_COUNT,
    "correct_percentage": $((CORRECT_FORMAT_COUNT * 100 / TOTAL_FILES))
  },
  "hex_levels": {
    "level_1": $LEVEL_1_COUNT,
    "level_2": $LEVEL_2_COUNT,
    "level_3": $LEVEL_3_COUNT,
    "level_4": $LEVEL_4_COUNT
  },
  "frontmatter": {
    "with_frontmatter": $FILES_WITH_FRONTMATTER,
    "without_frontmatter": $FILES_WITHOUT_FRONTMATTER,
    "percentage_with_frontmatter": $((FILES_WITH_FRONTMATTER * 100 / TOTAL_FILES))
  },
  "tasks": {
    "rename_files": $NO_ID_COUNT,
    "add_frontmatter": $FILES_WITHOUT_FRONTMATTER,
    "standardize_frontmatter": $FILES_WITH_FRONTMATTER
  },
  "recommendations": [
    "Добавить ID в начало имен $NO_ID_COUNT файлов",
    "Добавить стандартный frontmatter к $FILES_WITHOUT_FRONTMATTER файлам",
    "Проверить соответствие ID в именах и frontmatter"
  ]
}
EOF

echo "✅ Анализ сохранен в: $JSON_FILE"
echo ""
echo "🚀 СЛЕДУЮЩИЕ ШАГИ:"
echo "  1. Запустить: ./uch-docs-analyzer.sh"
echo "  2. Создать скрипт переименования"
echo "  3. Создать скрипт добавления frontmatter"
echo "  4. Обновить шаблоны"
echo "  5. Отслеживать прогресс через автоматические отчеты"