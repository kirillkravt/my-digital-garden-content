#!/bin/bash
# uch-toolkit.sh - главный менеджер всех инструментов UCH

VERSION="1.1.0"
SCRIPT_NAME=$(basename "$0")
TOOLS_DIR="uch-scripts/tools"

# Маппинг коротких имен к полным именам файлов
declare -A TOOL_MAP
TOOL_MAP["analytics"]="debt:uch-tech-debt-analyzer.sh docs:uch-docs-analyzer.sh metrics:uch-metrics-collector.sh basic:uch-basic-collector.sh project:uch-project-tech-collector.sh report:uch-report-generator.sh full:uch-generate-full-report.sh"
TOOL_MAP["docs"]="check:uch-frontmatter-tool.sh fix:fix_frontmatter.sh migrate:migrate_documents.sh"
TOOL_MAP["ids"]="check:uch-id-tool.sh check-simple:check-conflicts-simple.sh fix-shift:fix-conflicts-with-shift.sh fix-replace:fix-id-conflicts.sh"
TOOL_MAP["cleanup"]="remove:remove-general-info.sh"
TOOL_MAP["utils"]="rename:simple_rename.sh analyze:analyze-file-names.sh"

print_help() {
    echo "Использование: $SCRIPT_NAME [КАТЕГОРИЯ] [ИНСТРУМЕНТ]"
    echo ""
    echo "Категории и инструменты:"
    echo "  analytics    Аналитика: debt, docs, metrics, basic, project, report, full"
    echo "  docs         Документы: check, fix, migrate"
    echo "  ids          ID: check, check-simple, fix-shift, fix-replace"
    echo "  cleanup      Очистка: remove"
    echo "  utils        Утилиты: rename, analyze"
    echo "  list         Показать все инструменты"
    echo ""
    echo "Примеры:"
    echo "  $SCRIPT_NAME list                    # Показать все"
    echo "  $SCRIPT_NAME analytics debt          # Анализ техдолга"
    echo "  $SCRIPT_NAME docs check              # Проверить frontmatter"
    echo "  $SCRIPT_NAME ids check               # Проверить ID конфликты"
    echo "  $SCRIPT_NAME cleanup remove          # Удалить общую информацию"
    echo ""
    echo "Для детальной справки:"
    echo "  uch-scripts/tools/<категория>/<скрипт> --help"
}

list_tools() {
    echo "🛠️  ДОСТУПНЫЕ ИНСТРУМЕНТЫ:"
    echo ""
    
    for category in analytics docs ids cleanup utils; do
        if [ -d "$TOOLS_DIR/$category" ]; then
            echo "📁 $category:"
            # Показываем и короткие и полные имена
            echo "$TOOL_MAP[$category]" | tr ' ' '\n' | while IFS=: read short long; do
                if [ -n "$short" ] && [ -n "$long" ]; then
                    if [ -f "$TOOLS_DIR/$category/$long" ]; then
                        echo "  • $short → $long"
                    fi
                fi
            done
            echo ""
        fi
    done
}

resolve_tool_name() {
    local category="$1"
    local tool_input="$2"
    
    # Если ввод уже полное имя с .sh
    if [[ "$tool_input" == *.sh ]] && [ -f "$TOOLS_DIR/$category/$tool_input" ]; then
        echo "$tool_input"
        return 0
    fi
    
    # Ищем в маппинге
    echo "$TOOL_MAP[$category]" | tr ' ' '\n' | while IFS=: read short long; do
        if [ "$short" = "$tool_input" ]; then
            echo "$long"
            return 0
        fi
    done
    
    # Не нашли
    echo ""
    return 1
}

run_tool() {
    local category="$1"
    local tool_input="$2"
    shift 2
    
    if [ ! -d "$TOOLS_DIR/$category" ]; then
        echo "❌ Категория '$category' не найдена"
        return 1
    fi
    
    local tool_name=$(resolve_tool_name "$category" "$tool_input")
    
    if [ -z "$tool_name" ]; then
        echo "❌ Инструмент '$tool_input' не найден в категории '$category'"
        echo "   Доступные инструменты:"
        list_tools | grep -A10 "📁 $category:" | grep "• " | sed 's/^/     /'
        return 1
    fi
    
    local tool_path="$TOOLS_DIR/$category/$tool_name"
    
    if [ ! -f "$tool_path" ]; then
        echo "❌ Файл инструмента не найден: $tool_path"
        return 1
    fi
    
    echo "🚀 Запуск: $category/$tool_name ($tool_input)"
    echo "----------------------------------------"
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
            list_tools | grep -A10 "📁 $category:" | grep "• " | sed 's/^/   /'
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
