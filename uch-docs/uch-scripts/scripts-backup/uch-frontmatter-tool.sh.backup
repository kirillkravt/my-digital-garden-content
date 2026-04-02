#!/bin/bash
# uch-frontmatter-tool.sh - объединенный инструмент для работы с frontmatter
# Объединяет функциональность fix_frontmatter.sh и check_frontmatter.sh

VERSION="1.0.0"
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
    echo "  fix       Исправить frontmatter"
    echo "  stats     Статистика по frontmatter"
    echo ""
    echo "Опции:"
    echo "  -h, --help     Показать эту справку"
    echo "  -v, --version  Показать версию"
    echo ""
    echo "Примеры:"
    echo "  $SCRIPT_NAME check          # Проверить все документы"
    echo "  $SCRIPT_NAME fix --dry-run  # Показать что будет исправлено"
    echo "  $SCRIPT_NAME stats          # Показать статистику"
}

print_version() {
    echo "$SCRIPT_NAME версия $VERSION"
    echo "Объединяет fix_frontmatter.sh и check_frontmatter.sh"
}

# Основная логика будет добавлена из существующих скриптов
# Пока создаем каркас

COMMAND="${1:-check}"

case "$COMMAND" in
    check)
        echo "🔍 Режим проверки frontmatter..."
        # Здесь будет код из check_frontmatter.sh
        echo "TODO: имплементировать проверку"
        ;;
    fix)
        echo "🔧 Режим исправления frontmatter..."
        # Здесь будет код из fix_frontmatter.sh
        echo "TODO: имплементировать исправление"
        ;;
    stats)
        echo "📊 Статистика frontmatter..."
        echo "TODO: имплементировать статистику"
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
