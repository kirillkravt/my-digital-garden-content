#!/bin/bash
# uch-tech-debt-analyzer.sh - анализ технического долга автоматизации

echo "=== АНАЛИЗ ТЕХНИЧЕСКОГО ДОЛГА АВТОМАТИЗАЦИИ UCH ==="
echo "Версия: 1.0.0"
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

# Категоризируем скрипты
declare -A CATEGORIES
CATEGORIES["production"]=()    # Продакшн скрипты
CATEGORIES["experimental"]=()  # Экспериментальные
CATEGORIES["temporary"]=()     # Временные
CATEGORIES["deprecated"]=()    # Устаревшие

for script in $SCRIPTS; do
    SCRIPT_NAME=$(basename "$script")
    
    # Определяем категорию по имени
    if [[ "$SCRIPT_NAME" =~ ^uch-(metrics|project-tech|report-generator|generate-full|cron-manager)\.sh$ ]]; then
        CATEGORIES["production"]+=("$SCRIPT_NAME")
    elif [[ "$SCRIPT_NAME" =~ ^uch-.*\.sh$ ]]; then
        CATEGORIES["experimental"]+=("$SCRIPT_NAME")
    elif [[ "$SCRIPT_NAME" =~ ^(step|test|manual|quick|simple).*\.sh$ ]]; then
        CATEGORIES["temporary"]+=("$SCRIPT_NAME")
    elif [[ "$SCRIPT_NAME" =~ (backup|old|v[0-9]+|tmp)\.sh$ ]]; then
        CATEGORIES["deprecated"]+=("$SCRIPT_NAME")
    else
        CATEGORIES["experimental"]+=("$SCRIPT_NAME")
    fi
done

# Выводим категории
for category in "${!CATEGORIES[@]}"; do
    count=${#CATEGORIES[$category][@]}
    echo "$category: $count скриптов"
    
    for script in "${CATEGORIES[$category][@]:0:5}"; do
        echo "  • $script"
    done
    
    if [ $count -gt 5 ]; then
        echo "  ... и еще $((count - 5))"
    fi
    echo ""
done

print_section "🔍 АНАЛИЗ ИСПОЛЬЗОВАНИЯ СКРИПТОВ"

# 2. Проверяем когда скрипты последний раз использовались
echo "Скрипты по дате последнего изменения:"
echo ""

# Сортируем по дате изменения (сначала старые)
find . -maxdepth 1 -name "*.sh" -type f -exec stat -f "%m %N" {} \; | sort -n | head -10 | while read -r line; do
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

# 3. Ищем временные файлы
echo "Временные файлы и backup:"
echo ""

TEMP_FILES_COUNT=0
for pattern in "*.backup" "*.tmp*" "*.test*" "backup-*" "test-*" "temp-*" "*~" ".*.swp" "*.old" "*.bak"; do
    files=$(find . -maxdepth 2 -name "$pattern" -type f 2>/dev/null | wc -l | tr -d ' ')
    if [ "$files" -gt 0 ]; then
        echo "  $pattern: $files файлов"
        TEMP_FILES_COUNT=$((TEMP_FILES_COUNT + files))
        
        # Показываем примеры
        find . -maxdepth 2 -name "$pattern" -type f 2>/dev/null | head -2 | sed 's|^\./|    • |'
    fi
done

if [ $TEMP_FILES_COUNT -eq 0 ]; then
    print_ok "Временных файлов не найдено"
else
    print_warning "Найдено временных файлов: $TEMP_FILES_COUNT"
fi

print_section "📈 АНАЛИЗ ДУБЛИКАТОВ"

# 4. Ищем потенциальные дубликаты
echo "Потенциальные дубликаты файлов (по размеру и имени):"
echo ""

# Ищем файлы с похожими именами
DUPLICATES_FOUND=0
find . -maxdepth 1 -name "*.sh" -type f | while read -r file1; do
    for file2 in *.sh; do
        if [ "$file1" != "$file2" ] && [ -f "$file1" ] && [ -f "$file2" ]; then
            # Сравниваем базовые имена
            base1=$(basename "$file1" .sh | sed 's/-v[0-9]\+$//' | sed 's/-[0-9]\+$//')
            base2=$(basename "$file2" .sh | sed 's/-v[0-9]\+$//' | sed 's/-[0-9]\+$//')
            
            if [ "$base1" = "$base2" ]; then
                size1=$(stat -f%z "$file1")
                size2=$(stat -f%z "$file2")
                
                if [ $size1 -eq $size2 ] || [ $((size1 - size2)) -lt 100 ] || [ $((size2 - size1)) -lt 100 ]; then
                    echo "  🔄 $file1 ($size1 bytes) ↔ $file2 ($size2 bytes)"
                    DUPLICATES_FOUND=$((DUPLICATES_FOUND + 1))
                fi
            fi
        fi
    done
done | head -5

if [ $DUPLICATES_FOUND -eq 0 ]; then
    print_ok "Дубликатов не найдено"
fi

print_section "💡 РЕКОМЕНДАЦИИ ПО ОЧИСТКЕ"

# 5. Рекомендации по очистке
echo "ПРИОРИТЕТ 1 (можно удалить сразу):"
echo ""

# Временные файлы старше 1 дня
echo "1. Временные файлы старше 1 дня:"
find . -maxdepth 2 -name "*.tmp*" -type f -mtime +1 2>/dev/null | head -5 | sed 's|^\./|   • |'

echo ""
echo "2. Test файлы и backup директории:"
find . -maxdepth 2 -name "test*" -type d -mtime +1 2>/dev/null | head -3 | sed 's|^\./|   • |'
find . -maxdepth 2 -name "backup*" -type d -mtime +1 2>/dev/null | head -3 | sed 's|^\./|   • |'

echo ""
echo "ПРИОРИТЕТ 2 (проверить и удалить):"
echo ""

# Экспериментальные скрипты старше 7 дней
echo "3. Экспериментальные скрипты (step*, test*):"
for script in step*.sh test*.sh manual*.sh quick*.sh simple*.sh; do
    if [ -f "$script" ]; then
        age_days=$(( ( $(date +%s) - $(stat -f %m "$script") ) / 86400 ))
        if [ $age_days -gt 7 ]; then
            echo "   • $script ($age_days дней)"
        fi
    fi
done | head -5

print_section "📋 ПЛАН ОЧИСТКИ"

# 6. Создаем план очистки
BACKUP_DIR="cleanup-backup-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$BACKUP_DIR"

cat > "cleanup-plan-$BACKUP_DIR.md" << EOF
# 📋 ПЛАН ОЧИСТКИ ТЕХНИЧЕСКОГО ДОЛГА UCH

**Сгенерировано:** $(date)  
**Всего скриптов:** $TOTAL_SCRIPTS  
**Временных файлов:** $TEMP_FILES_COUNT  

## 🎯 ЦЕЛЬ ОЧИСТКИ

Удалить устаревшие, экспериментальные и временные файлы для уменьшения "технического долга автоматизации".

## 📊 ТЕКУЩЕЕ СОСТОЯНИЕ

### КАТЕГОРИИ СКРИПТОВ:

- **Продакшн:** ${#CATEGORIES["production"][@]} скриптов
- **Экспериментальные:** ${#CATEGORIES["experimental"][@]} скриптов  
- **Временные:** ${#CATEGORIES["temporary"][@]} скриптов
- **Устаревшие:** ${#CATEGORIES["deprecated"][@]} скриптов

### ПРОБЛЕМЫ:

1. Много экспериментальных скриптов от тестирования
2. Временные файлы накапливаются
3. Дублирующаяся функциональность
4. Отсутствие lifecycle management

## 🗑️ РЕКОМЕНДАЦИИ ПО УДАЛЕНИЮ

### БЕЗОПАСНО УДАЛИТЬ СРАЗУ:

\`\`\`bash
# 1. Временные файлы старше 1 дня
find . -name "*.tmp*" -type f -mtime +1 -delete

# 2. Test backup директории старше 3 дней  
find . -name "backup-*" -type d -mtime +3 -exec rm -rf {} \;
find . -name "test-*" -type d -mtime +3 -exec rm -rf {} \;

# 3. Временные скрипты тестирования (step*, test*)
$(for script in step*.sh test*.sh; do 
    if [ -f "$script" ]; then
        age_days=$(( ( $(date +%s) - $(stat -f %m "$script") ) / 86400 ))
        if [ $age_days -gt 7 ]; then
            echo "# rm \"$script\"  # $age_days дней"
        fi
    fi
done | head -5)
\`\`\`

### ПРОВЕРИТЬ И УДАЛИТЬ:

\`\`\`bash
# Экспериментальные uch- скрипты (кроме продакшн):
$(for script in "${CATEGORIES["experimental"][@]:0:5}"; do
    echo "# проверить: $script"
done)
\`\`\`

### ОСТАВИТЬ (ПРОДАКШН):

\`\`\`bash
# Основные скрипты системы отчетов:
$(for script in "${CATEGORIES["production"][@]}"; do
    echo "# сохранить: $script"
done)
\`\`\`

## 📈 МЕТРИКИ ДО И ПОСЛЕ

| Метрика | До очистки | Цель после |
|---------|------------|------------|
| Всего скриптов | $TOTAL_SCRIPTS | ~${#CATEGORIES["production"][@]} |
| Временных файлов | $TEMP_FILES_COUNT | 0 |
| Дубликатов | $DUPLICATES_FOUND | 0 |

## 🚀 СЛЕДУЮЩИЕ ШАГИ

1. **Создать backup** всех удаляемых файлов
2. **Выполнить безопасное удаление** по плану
3. **Добавить в автоматические отчеты** мониторинг техдолга
4. **Создать политику lifecycle** для скриптов

## 🔄 АВТОМАТИЗАЦИЯ В БУДУЩЕМ

1. **Еженедельный отчет** по техдолгу автоматизации
2. **Автоматическая очистка** временных файлов старше N дней
3. **Система версионирования** для экспериментальных скриптов
4. **Архивация** вместо удаления для истории

---

**Backup создан в:** $BACKUP_DIR  
**Для отката:** cp $BACKUP_DIR/* .
EOF

echo "✅ План очистки сохранен: cleanup-plan-$BACKUP_DIR.md"
echo "📁 Backup директория: $BACKUP_DIR"
echo ""
echo "🚀 РЕКОМЕНДАЦИИ:"
echo "  1. Ознакомиться с планом: cat cleanup-plan-$BACKUP_DIR.md"
echo "  2. Создать backup скриптов: cp *.sh $BACKUP_DIR/"
echo "  3. Выполнить безопасное удаление по шагам"
echo "  4. Интегрировать анализ техдолга в автоматические отчеты"