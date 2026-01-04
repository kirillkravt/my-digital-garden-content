#!/bin/bash
# generate-function-tree.sh - создает карту всех функций системы

echo "# 🏗️ ДЕРЕВО ФУНКЦИЙ UCH-DOCS СИСТЕМЫ"
echo ""
echo "**Дата генерации:** $(date)"
echo "**Всего инструментов:** $(find uch-scripts/tools -name "*.sh" -type f | wc -l)"
echo ""
echo "## 📁 СТРУКТУРА СИСТЕМЫ"
echo ""
echo "### 🎯 ГЛАВНЫЕ ТОЧКИ ВХОДА:"
echo ""
echo "| Скрипт | Назначение | Команда для запуска |"
echo "|---------|------------|---------------------|"
echo "| \`uch-toolkit.sh\` | Центральный менеджер всех инструментов | \`./uch-toolkit.sh <категория> <инструмент>\` |"
echo "| \`uch-create-modular.sh\` | Меню создания документов | \`./uch-create-modular.sh\` |"
echo "| \`uch-cron-manager.sh\` | Управление автоматическими задачами | \`./uch-cron-manager.sh\` |"
echo ""
echo "## 🔧 КАТАЛОГ ИНСТРУМЕНТОВ"
echo ""
# Функция для анализа категории
analyze_category() {
    local category="$1"
    local category_name="$2"
    
    echo "### $category_name"
    echo ""
    
    if [ ! -d "uch-scripts/tools/$category" ]; then
        echo "⚠️ Директория не найдена"
        echo ""
        return
    fi
    
    echo "| Инструмент | Описание | Команды | Размер |"
    echo "|------------|----------|---------|--------|"
    
    for tool in "uch-scripts/tools/$category"/*.sh; do
        if [ -f "$tool" ]; then
            tool_name=$(basename "$tool")
            
            # Извлекаем описание
            description=$(head -5 "$tool" | grep -E "^# " | head -1 | sed 's/^# //')
            if [ -z "$description" ]; then
                description=$(head -10 "$tool" | grep -E "^echo|^#---" | head -1 | sed 's/^echo "//;s/"$//;s/^#--- //')
            fi
            
            # Определяем доступные команды
            commands=""
            case "$tool_name" in
                uch-frontmatter-tool.sh)
                    commands="check, fix, stats"
                    ;;
                uch-id-tool.sh)
                    commands="check, fix-shift, fix-replace, stats"
                    ;;
                uch-tech-debt-analyzer.sh)
                    commands="анализ техдолга"
                    ;;
                fix_frontmatter.sh)
                    commands="исправление frontmatter"
                    ;;
                migrate_documents.sh)
                    commands="миграция документов"
                    ;;
                *)
                    # Пытаемся извлечь команды из файла
                    cmd_line=$(grep -E "check\|fix\|analyze\|report\|stats" "$tool" | head -1)
                    if [ -n "$cmd_line" ]; then
                        commands="см. --help"
                    else
                        commands="запуск напрямую"
                    fi
                    ;;
            esac
            
            # Размер
            size=$(wc -l < "$tool")
            
            echo "| \`$tool_name\` | $description | $commands | $size строк |"
        fi
    done
    echo ""
}

