#!/bin/bash
# uch-toolkit.sh - главный менеджер всех инструментов UCH (версия для macOS)
# Централизованный доступ к инструментам в uch-scripts/tools/

VERSION="1.3.1"
SCRIPT_NAME=$(basename "$0")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TOOLS_DIR="$SCRIPT_DIR/uch-scripts/tools"

print_help() {
    echo "Использование: $SCRIPT_NAME [КАТЕГОРИЯ] [ИНСТРУМЕНТ]"
    echo ""
    echo "Категории и инструменты:"
    echo "  analytics    Аналитика: debt, docs, metrics, basic, project, report, full"
    echo "  docs         Документы: check, fix, migrate"
    echo "  docs-names   Имена документов: analyze, fix"
    echo "  ids          ID: check, check-simple, fix-shift, fix-replace"
    echo "  cleanup      Очистка: remove"
    echo "  utils        Утилиты: rename, analyze"
    echo "  list         Показать все инструменты"
    echo "  run          Запустить любой скрипт напрямую: run <категория> <скрипт>"
    echo ""
    echo "Примеры:"
    echo "  $SCRIPT_NAME list                    # Показать все"
    echo "  $SCRIPT_NAME analytics debt          # Анализ техдолга"
    echo "  $SCRIPT_NAME docs check              # Проверить frontmatter"
    echo "  $SCRIPT_NAME docs-names analyze      # Анализ имен документов"
    echo "  $SCRIPT_NAME docs-names fix          # Исправить имена документов"
    echo "  $SCRIPT_NAME ids check               # Проверить ID конфликты"
    echo "  $SCRIPT_NAME cleanup remove          # Удалить общую информацию"
    echo "  $SCRIPT_NAME run analytics uch-tech-debt-analyzer.sh  # Прямой запуск"
    echo ""
    echo "Все инструменты работают в текущей директории: $(pwd)"
    echo "Утилиты находятся в: $TOOLS_DIR"
}

print_version() {
    echo "$SCRIPT_NAME версия $VERSION (macOS compatible)"
    echo "Централизованный менеджер инструментов UCH"
    echo "База инструментов: $TOOLS_DIR"
}

# Функция для разрешения коротких имен
resolve_tool() {
    local category="$1"
    local tool="$2"
    
    case "$category:$tool" in
        analytics:debt) echo "uch-tech-debt-analyzer.sh" ;;
        analytics:docs) echo "uch-docs-analyzer.sh" ;;
        analytics:metrics) echo "uch-metrics-collector.sh" ;;
        analytics:basic) echo "uch-basic-collector.sh" ;;
        analytics:project) echo "uch-project-tech-collector.sh" ;;
        analytics:report) echo "uch-report-generator.sh" ;;
        analytics:full) echo "uch-generate-full-report.sh" ;;
        
        docs:check) echo "uch-frontmatter-tool.sh" ;;
        docs:fix) echo "fix_frontmatter.sh" ;;
        docs:migrate) echo "migrate_documents.sh" ;;
        
        docs-names:analyze) echo "analyze-doc-names.sh" ;;
        docs-names:fix) echo "fix-doc-names.sh" ;;
        
        ids:check) echo "uch-id-tool.sh" ;;
        ids:check-simple) echo "check-conflicts-simple.sh" ;;
        ids:fix-shift) echo "fix-conflicts-with-shift.sh" ;;
        ids:fix-replace) echo "fix-id-conflicts.sh" ;;
        
        cleanup:remove) echo "remove-general-info.sh" ;;
        
        utils:rename) echo "simple_rename.sh" ;;
        utils:analyze) echo "analyze-file-names.sh" ;;
        
        *) echo "$tool" ;;  # Если полное имя, возвращаем как есть
    esac
}

list_tools() {
    echo "🛠️  ДОСТУПНЫЕ ИНСТРУМЕНТЫ:"
    echo "📁 База инструментов: $TOOLS_DIR"
    echo ""
    
    for category in analytics docs docs-names ids cleanup utils; do
        if [ -d "$TOOLS_DIR/$category" ]; then
            echo "📁 $category:"
            # Перечисляем все файлы в категории
            for tool_path in "$TOOLS_DIR/$category"/*.sh; do
                if [ -f "$tool_path" ]; then
                    tool_name=$(basename "$tool_path")
                    # Находим короткое имя если есть
                    short_name=""
                    for mapping in \
                        "debt:uch-tech-debt-analyzer.sh" \
                        "docs:uch-docs-analyzer.sh" \
                        "metrics:uch-metrics-collector.sh" \
                        "basic:uch-basic-collector.sh" \
                        "project:uch-project-tech-collector.sh" \
                        "report:uch-report-generator.sh" \
                        "full:uch-generate-full-report.sh" \
                        "check:uch-frontmatter-tool.sh" \
                        "fix:fix_frontmatter.sh" \
                        "migrate:migrate_documents.sh" \
                        "analyze:analyze-doc-names.sh" \
                        "fix:fix-doc-names.sh" \
                        "check:uch-id-tool.sh" \
                        "check-simple:check-conflicts-simple.sh" \
                        "fix-shift:fix-conflicts-with-shift.sh" \
                        "fix-replace:fix-id-conflicts.sh" \
                        "remove:remove-general-info.sh" \
                        "rename:simple_rename.sh" \
                        "analyze:analyze-file-names.sh"; do
                        short=$(echo "$mapping" | cut -d: -f1)
                        long=$(echo "$mapping" | cut -d: -f2)
                        if [ "$long" = "$tool_name" ]; then
                            short_name=$short
                            break
                        fi
                    done
                    
                    if [ -n "$short_name" ]; then
                        echo "  • $short_name → $tool_name"
                    else
                        echo "  • $tool_name"
                    fi
                fi
            done
            echo ""
        else
            echo "📁 $category: (папка не найдена)"
            echo ""
        fi
    done
}

run_tool() {
    local category="$1"
    local tool_input="$2"
    shift 2
    
    if [ ! -d "$TOOLS_DIR/$category" ]; then
        echo "❌ Категория '$category' не найдена"
        echo "   Путь: $TOOLS_DIR/$category"
        return 1
    fi
    
    local tool_name=$(resolve_tool "$category" "$tool_input")
    local tool_path="$TOOLS_DIR/$category/$tool_name"
    
    if [ ! -f "$tool_path" ]; then
        echo "❌ Инструмент '$tool_input' не найден в категории '$category'"
        echo "   Путь: $tool_path"
        echo "   Доступные инструменты в '$category':"
        ls "$TOOLS_DIR/$category"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/^/     • /'
        return 1
    fi
    
    echo "🚀 Запуск: $category/$tool_name"
    echo "📁 Рабочая директория: $(pwd)"
    echo "----------------------------------------"
    "$tool_path" "$@"
}

run_direct() {
    local category="$1"
    local tool="$2"
    shift 2
    
    local tool_path="$TOOLS_DIR/$category/$tool"
    
    if [ ! -f "$tool_path" ]; then
        echo "❌ Файл не найден: $tool_path"
        echo "   Доступные в категории '$category':"
        ls "$TOOLS_DIR/$category"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/^/     • /'
        return 1
    fi
    
    echo "🚀 Прямой запуск: $category/$tool"
    echo "📁 Рабочая директория: $(pwd)"
    echo "----------------------------------------"
    "$tool_path" "$@"
}

# Основная логика
if [ $# -eq 0 ]; then
    print_help
    exit 0
fi

COMMAND="$1"
shift

case "$COMMAND" in
    list)
        list_tools
        ;;
    analytics|docs|docs-names|ids|cleanup|utils)
        if [ $# -lt 1 ]; then
            echo "❌ Не указан инструмент для категории '$COMMAND'"
            echo "   Использование: $SCRIPT_NAME $COMMAND <инструмент>"
            echo ""
            echo "Доступные инструменты в '$COMMAND':"
            ls "$TOOLS_DIR/$COMMAND"/*.sh 2>/dev/null | xargs -n1 basename | sed 's/^/   • /'
            exit 1
        fi
        TOOL="$1"
        shift
        run_tool "$COMMAND" "$TOOL" "$@"
        ;;
    run)
        if [ $# -lt 2 ]; then
            echo "❌ Не указана категория и инструмент"
            echo "   Использование: $SCRIPT_NAME run <категория> <скрипт>"
            exit 1
        fi
        CATEGORY="$1"
        TOOL="$2"
        shift 2
        run_direct "$CATEGORY" "$TOOL" "$@"
        ;;
    -h|--help)
        print_help
        ;;
    -v|--version)
        print_version
        ;;
    *)
        echo "❌ Неизвестная команда: '$COMMAND'"
        print_help
        exit 1
        ;;
esac
