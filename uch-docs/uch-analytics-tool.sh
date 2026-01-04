#!/bin/bash
# uch-analytics-tool.sh - единый инструмент аналитики UCH
# Объединяет все аналитические скрипты

VERSION="1.0.0"
SCRIPT_NAME=$(basename "$0")

print_help() {
    echo "Использование: $SCRIPT_NAME [КОМАНДА] [ОПЦИИ]"
    echo ""
    echo "Команды:"
    echo "  collect    Собрать все метрики"
    echo "  analyze    Проанализировать данные"
    echo "  report     Сгенерировать отчет"
    echo "  full       Полный цикл (collect → analyze → report)"
    echo "  debt       Анализ технического долга"
    echo "  docs       Анализ документации"
    echo ""
    echo "Опции:"
    echo "  -h, --help     Показать эту справку"
    echo "  -v, --version  Показать версию"
    echo "  --output DIR   Директория для результатов"
    echo ""
    echo "Примеры:"
    echo "  $SCRIPT_NAME collect          # Собрать метрики"
    echo "  $SCRIPT_NAME full --output reports/  # Полный цикл в директорию"
    echo "  $SCRIPT_NAME debt             # Анализ техдолга"
}

print_version() {
    echo "$SCRIPT_NAME версия $VERSION"
    echo "Объединяет аналитические инструменты UCH"
}

# ================================
# ФУНКЦИИ (интеграция с существующими)
# ================================
collect_metrics() {
    echo "📊 СБОР МЕТРИК..."
    echo ""
    
    # Запускаем все сборщики
    if [ -f "uch-metrics-collector.sh" ]; then
        echo "1. Сбор общих метрик:"
        ./uch-metrics-collector.sh
        echo ""
    fi
    
    if [ -f "uch-project-tech-collector.sh" ]; then
        echo "2. Сбор технологического стека:"
        ./uch-project-tech-collector.sh
        echo ""
    fi
    
    echo "✅ Сбор метрик завершен"
    echo "Файлы: uch-metrics-full.json, uch-project-tech-stack.json"
}

analyze_data() {
    echo "🔍 АНАЛИЗ ДАННЫХ..."
    echo ""
    
    if [ -f "uch-docs-analyzer.sh" ]; then
        echo "1. Анализ документации:"
        ./uch-docs-analyzer.sh
        echo ""
    fi
    
    echo "✅ Анализ завершен"
}

generate_report() {
    echo "📈 ГЕНЕРАЦИЯ ОТЧЕТА..."
    echo ""
    
    if [ -f "uch-report-generator.sh" ]; then
        echo "Запуск генератора отчета:"
        ./uch-report-generator.sh
        echo ""
        echo "✅ Отчет сгенерирован: 90-01 - Автоматический отчет состояния UCH.md"
    else
        echo "❌ uch-report-generator.sh не найден"
    fi
}

full_cycle() {
    echo "🔄 ПОЛНЫЙ ЦИКЛ АНАЛИТИКИ..."
    echo ""
    
    collect_metrics
    analyze_data
    generate_report
    
    echo "✅ Полный цикл завершен!"
}

analyze_debt() {
    echo "🗑️  АНАЛИЗ ТЕХНИЧЕСКОГО ДОЛГА..."
    echo ""
    
    if [ -f "uch-tech-debt-analyzer.sh" ]; then
        ./uch-tech-debt-analyzer.sh
    else
        echo "❌ uch-tech-debt-analyzer.sh не найден"
    fi
}

analyze_docs() {
    echo "📚 АНАЛИЗ ДОКУМЕНТАЦИИ..."
    echo ""
    
    if [ -f "uch-docs-analyzer.sh" ]; then
        ./uch-docs-analyzer.sh
    else
        echo "❌ uch-docs-analyzer.sh не найден"
    fi
}

# ================================
# ОСНОВНАЯ ЛОГИКА
# ================================
COMMAND="${1:-full}"
shift

case "$COMMAND" in
    collect)
        collect_metrics "$@"
        ;;
    analyze)
        analyze_data "$@"
        ;;
    report)
        generate_report "$@"
        ;;
    full)
        full_cycle "$@"
        ;;
    debt)
        analyze_debt "$@"
        ;;
    docs)
        analyze_docs "$@"
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
