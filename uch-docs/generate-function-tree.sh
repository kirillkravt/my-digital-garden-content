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

# Генерируем отчет
echo "#### 📊 АНАЛИТИКА"
analyze_category "analytics" "📊 АНАЛИТИКА"

echo "#### 📝 ДОКУМЕНТЫ"
analyze_category "docs" "📝 ДОКУМЕНТЫ"

echo "#### 🔢 ID"
analyze_category "ids" "🔢 ID"

echo "#### 🗑️ ОЧИСТКА"
analyze_category "cleanup" "🗑️ ОЧИСТКА"

echo "#### 🛠️ УТИЛИТЫ"
analyze_category "utils" "🛠️ УТИЛИТЫ"
echo "## 🚀 КАК ИСПОЛЬЗОВАТЬ СИСТЕМУ"
echo ""
echo "### БЫСТРЫЙ СТАРТ:"
echo ""
echo "1. **Просмотреть все инструменты:**"
echo "   \`\`\`bash"
echo "   ./uch-toolkit.sh list"
echo "   \`\`\`"
echo ""
echo "2. **Проверить состояние документации:**"
echo "   \`\`\`bash"
echo "   ./uch-toolkit.sh docs check"
echo "   \`\`\`"
echo ""
echo "3. **Проанализировать технический долг:**"
echo "   \`\`\`bash"
echo "   ./uch-toolkit.sh analytics debt"
echo "   \`\`\`"
echo ""
echo "4. **Проверить ID конфликты:**"
echo "   \`\`\`bash"
echo "   ./uch-toolkit.sh ids check"
echo "   \`\`\`"
echo ""
echo "5. **Создать новый документ:**"
echo "   \`\`\`bash"
echo "   ./uch-create-modular.sh"
echo "   \`\`\`"
echo ""
echo "### КОМАНДЫ ПО КАТЕГОРИЯМ:"
echo ""
echo "| Категория | Короткая команда | Пример |"
echo "|-----------|------------------|--------|"
echo "| Аналитика | \`uch-toolkit.sh analytics <tool>\` | \`./uch-toolkit.sh analytics debt\` |"
echo "| Документы | \`uch-toolkit.sh docs <tool>\` | \`./uch-toolkit.sh docs check\` |"
echo "| ID | \`uch-toolkit.sh ids <tool>\` | \`./uch-toolkit.sh ids check\` |"
echo "| Очистка | \`uch-toolkit.sh cleanup <tool>\` | \`./uch-toolkit.sh cleanup remove\` |"
echo "| Утилиты | \`uch-toolkit.sh utils <tool>\` | \`./uch-toolkit.sh utils rename\` |"
echo ""
echo "## 📞 ПОЛУЧЕНИЕ СПРАВКИ"
echo ""
echo "Для любого инструмента:"
echo "\`\`\`bash"
echo "./uch-toolkit.sh <категория> <инструмент> --help"
echo "# Или напрямую:"
echo "./uch-scripts/tools/<категория>/<инструмент> --help"
echo "\`\`\`"
echo ""
echo "## 🔄 WORKFLOW РЕКОМЕНДАЦИИ"
echo ""
echo "### Ежедневный workflow:"
echo "1. Проверить документацию: \`uch-toolkit.sh docs check\`"
echo "2. Создать задачи: через \`uch-create-modular.sh\`"
echo "3. Проверить конфликты: \`uch-toolkit.sh ids check\`"
echo ""
echo "### Еженедельный аудит:"
echo "1. Анализ техдолга: \`uch-toolkit.sh analytics debt\`"
echo "2. Генерация отчета: \`uch-toolkit.sh analytics report\`"
echo "3. Очистка системы: \`uch-toolkit.sh cleanup remove\`"
echo ""
echo "## ⚠️ ИЗВЕСТНЫЕ ПРОБЛЕМЫ"
echo ""
echo "1. **macOS совместимость:** Некоторые скрипты могут требовать GNU версии утилит"
echo "2. **Пути:** Все пути настроены для конкретной системы пользователя"
echo "3. **Зависимости:** Требуется bash 4+ для некоторых функций"
echo ""
echo "---"
echo "*Сгенерировано автоматически. Для обновления запустите этот скрипт снова.*"
