#!/bin/bash
# uch-cron-manager.sh - управление автоматической генерацией

echo "=== UCH CRON МЕНЕДЖЕР ==="
echo ""

case "$1" in
    install)
        echo "📅 Устанавливаю ежедневную генерацию в 9:00..."
        echo "# UCH Automatic Report Generation" > /tmp/uch-cron
        echo "0 9 * * * cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs && ./uch-generate-full-report.sh >> /tmp/uch-report-\$(date +\\\\%Y\\\\%m\\\\%d).log 2>&1" >> /tmp/uch-cron
        crontab /tmp/uch-cron
        echo "✅ Установлено: ежедневно в 9:00"
        crontab -l
        ;;
        
    remove)
        echo "🗑️ Удаляю автоматическую генерацию..."
        crontab -r 2>/dev/null
        echo "✅ Удалено"
        ;;
        
    status)
        echo "📋 Статус crontab:"
        if crontab -l 2>/dev/null; then
            echo ""
            echo "✅ Crontab настроен"
        else
            echo "❌ Crontab не настроен"
        fi
        ;;
        
    test)
        echo "🧪 Тестовый запуск..."
        cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs
        ./uch-generate-full-report.sh
        ;;
        
    *)
        echo "Использование: $0 {install|remove|status|test}"
        echo ""
        echo "  install - установить ежедневную генерацию в 9:00"
        echo "  remove  - удалить все cron задачи"
        echo "  status  - показать текущие cron задачи"
        echo "  test    - тестовый запуск генерации"
        ;;
esac