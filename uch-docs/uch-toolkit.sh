#!/bin/bash
# uch-toolkit.sh - главный менеджер всех инструментов UCH
# Централизованный доступ к инструментам в uch-scripts/tools/

VERSION="1.0.0"
SCRIPT_NAME=$(basename "$0")
TOOLS_DIR="uch-scripts/tools"

print_help() {
    echo "Использование: $SCRIPT_NAME [КАТЕГОРИЯ] [КОМАНДА]"
    echo ""
    echo "Категории:"
    echo "  analytics    Аналитические инструменты"
    echo "  docs         Инструменты для работы с документами"
    echo "  ids          Инструменты для работы с ID"
    echo "  cleanup      Инструменты очистки"
    echo "  utils        Утилиты"
    echo "  list         Показать все доступные инструменты"
    echo ""
    echo "Примеры:"
    echo "  $SCRIPT_NAME list              # Показать все инструменты"
    echo "  $SCRIPT_NAME analytics debt    # Запустить анализ техдолга"
    echo "  $SCRIPT_NAME docs check        # Проверить frontmatter"
    echo "  $SCRIPT_NAME ids check         # Проверить ID конфликты"
    echo ""
    echo "Для справки по конкретному инструменту:"
    echo "  uch-scripts/tools/<категория>/<скрипт> --help"
}

print_version() {
    echo "$SCRIPT_NAME версия $VERSION"
    echo "Централизованный менеджер инструментов UCH"
}

list_tools() {
    echo "🛠️  ДОСТУПНЫЕ ИНСТРУМЕНТЫ:"
    echo ""
    
    for category in analytics docs ids cleanup utils; do
        if [ -d "$TOOLS_DIR/$category" ]; then
            echo "📁 $category:"
            ls "$TOOLS_DIR/$category/"*.sh 2>/dev/null | while read tool; do
                tool_name=$(basename "$tool")
                echo "  • $tool_name"
            done
            echo ""
        fi
    done
}

run_tool() {
    local category="$1"
    local tool="$2"
    shift 2
    
    if [ ! -d "$TOOLS_DIR/$category" ]; then
        echo "❌ Категория '$category' не найдена"
        return 1
    fi
    
    local tool_path="$TOOLS_DIR/$category/$tool"
    
    if [ ! -f "$tool_path" ]; then
        echo "❌ Инструмент '$tool' не найден в категории '$category'"
        echo "   Доступные инструменты:"
        ls "$TOOLS_DIR/$category/"*.sh 2>/dev/null | basename -a | sed 's/^/     • /'
        return 1
    fi
    
    echo "🚀 Запуск: $category/$tool"
    echo ""
    "$tool_path" "$@"
}

# Основная логика
if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

CATEGORY="$1"

case "$CATEGORY" in
    list)
        list_tools
        ;;
    analytics|docs|ids|cleanup|utils)
        if [ $# -lt 2 ]; then
            echo "❌ Не указан инструмент для категории '$CATEGORY'"
            echo "   Использование: $SCRIPT_NAME $CATEGORY <инструмент>"
            echo ""
            echo "Доступные инструменты в '$CATEGORY':"
            ls "$TOOLS_DIR/$CATEGORY/"*.sh 2>/dev/null | basename -a | sed 's/^/   • /'
            exit 1
        fi
        TOOL="$2"
        shift 2
        run_tool "$CATEGORY" "$TOOL" "$@"
        ;;
    -h|--help)
        print_help
        ;;
    -v|--version)
        print_version
        ;;
    *)
        echo "❌ Неизвестная категория: '$CATEGORY'"
        print_help
        exit 1
        ;;
esac
