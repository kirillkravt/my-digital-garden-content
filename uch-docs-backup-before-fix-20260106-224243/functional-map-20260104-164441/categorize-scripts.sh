#!/bin/bash
echo "## 🔧 КАТЕГОРИЗАЦИЯ ПО ФУНКЦИОНАЛЬНОСТИ"
echo ""

declare -A categories
categories["FRONTMATTER"]="frontmatter|metadata|проверк|исправлен"
categories["MIGRATION"]="миграц|migrate|convert|конверт"
categories["CONFLICTS"]="конфликт|conflict|сдвиг|shift"
categories["ANALYTICS"]="анализ|analyze|отчет|report|метри|collector"
categories["DOC_CREATION"]="создан|create|документ"
categories["CLEANUP"]="удален|remove|очистк|cleanup"
categories["RENAME"]="переимен|rename"
categories["CRON"]="cron|расписан|schedule"
categories["OTHER"]=""

echo "### Категории и скрипты:"
echo ""

for category in "${!categories[@]}"; do
    pattern=${categories[$category]}
    echo "#### $category:"
    if [ -n "$pattern" ]; then
        for script in ../*.sh; do
            if [ -f "$script" ]; then
                filename=$(basename "$script")
                # Ищем в первых 10 строках (описание) и во всем файле
                if head -10 "$script" | grep -qiE "$pattern" || grep -qiE "$pattern" "$script"; then
                    echo "- $filename"
                fi
            fi
        done | sort | uniq
    fi
    echo ""
done
