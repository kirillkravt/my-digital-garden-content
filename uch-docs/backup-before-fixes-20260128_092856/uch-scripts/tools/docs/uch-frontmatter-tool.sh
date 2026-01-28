#!/bin/bash
# uch-frontmatter-tool.sh - объединенный инструмент для работы с frontmatter
# Версия 1.2.0 - интеграция с fix_frontmatter.sh

VERSION="1.2.0"
SCRIPT_NAME=$(basename "$0")

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_help() {
    echo "Использование: $SCRIPT_NAME [КОМАНДА] [ОПЦИИ]"
    echo ""
    echo "Команды:"
    echo "  check     Проверить frontmatter (режим чтения)"
    echo "  fix       Исправить frontmatter (запускает fix_frontmatter.sh)"
    echo "  stats     Статистика по frontmatter"
    echo ""
    echo "Опции:"
    echo "  -h, --help     Показать эту справку"
    echo "  -v, --version  Показать версию"
    echo "  --dry-run      Показать что будет исправлено (для fix)"
    echo ""
    echo "Примеры:"
    echo "  $SCRIPT_NAME check          # Проверить все документы"
    echo "  $SCRIPT_NAME fix            # Исправить frontmatter"
    echo "  $SCRIPT_NAME fix --dry-run  # Показать что будет исправлено"
    echo "  $SCRIPT_NAME stats          # Показать статистику"
}

print_version() {
    echo "$SCRIPT_NAME версия $VERSION"
    echo "Объединяет check_frontmatter.sh и интегрирует fix_frontmatter.sh"
}

# ================================
# ФУНКЦИЯ CHECK (из check_frontmatter.sh)
# ================================
check_frontmatter() {
    echo "=== ПРОВЕРКА FRONTMATTER (ТОЛЬКО ЧТЕНИЕ) ==="
    echo ""
    
    TOTAL_FILES=0
    CORRECT_FILES=0
    FILES_WITHOUT_FM=0
    FILES_WITH_ERRORS=0
    
    echo "🔍 Поиск .md файлов..."
    
    # Ищем все .md файлы
    for file in *.md; do
        if [ -f "$file" ]; then
            TOTAL_FILES=$((TOTAL_FILES + 1))
            
            # Проверяем наличие frontmatter
            if head -1 "$file" | grep -q "^---"; then
                # Проверяем что frontmatter закрыт
                if grep -q "^---" <(tail -n +2 "$file"); then
                    CORRECT_FILES=$((CORRECT_FILES + 1))
                else
                    FILES_WITH_ERRORS=$((FILES_WITH_ERRORS + 1))
                    echo "  ⚠️  $file: frontmatter не закрыт"
                fi
            else
                FILES_WITHOUT_FM=$((FILES_WITHOUT_FM + 1))
                echo "  ❌ $file: отсутствует frontmatter"
            fi
        fi
    done
    
    echo ""
    echo "📊 СТАТИСТИКА:"
    echo "  Всего файлов: $TOTAL_FILES"
    echo "  Корректный frontmatter: $CORRECT_FILES"
    
    if [ $FILES_WITHOUT_FM -gt 0 ]; then
        echo "  Без frontmatter: $FILES_WITHOUT_FM"
    fi
    
    if [ $FILES_WITH_ERRORS -gt 0 ]; then
        echo "  С ошибками: $FILES_WITH_ERRORS"
    fi
    
    if [ $CORRECT_FILES -eq $TOTAL_FILES ]; then
        echo ""
        echo "✅ Все файлы в порядке!"
    fi
}

# ================================
# ФУНКЦИЯ FIX (интеграция с fix_frontmatter.sh)
# ================================
fix_frontmatter() {
    echo "=== ИСПРАВЛЕНИЕ FRONTMATTER ==="
    echo "Запуск fix_frontmatter.sh..."
    echo ""
    
    if [ -f "fix_frontmatter.sh" ]; then
        # Передаем аргументы дальше
        ./fix_frontmatter.sh "$@"
    else
        echo "❌ Ошибка: fix_frontmatter.sh не найден!"
        echo ""
        echo "Содержимое fix_frontmatter.sh должно находиться в этой же директории."
        exit 1
    fi
}

# ================================
# ФУНКЦИЯ STATS (заглушка пока)
# ================================
show_stats() {
    echo "📊 Статистика frontmatter..."
    echo "Функция в разработке"
}

# ================================
# ОБРАБОТКА АРГУМЕНТОВ
# ================================
COMMAND="${1:-check}"
shift  # Убираем команду из аргументов

case "$COMMAND" in
    check)
        check_frontmatter
        ;;
    fix)
        fix_frontmatter "$@"
        ;;
    stats)
        show_stats
        ;;
    -h|--help)
        print_help
        ;;
    -v|--version)
        print_version
        ;;
    *)
        echo "Ошибка: неизвестная команда '$COMMAND'"
        print_help
        exit 1
        ;;
esac
