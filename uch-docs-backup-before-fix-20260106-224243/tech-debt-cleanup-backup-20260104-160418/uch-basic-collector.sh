#!/bin/bash
# uch-basic-collector.sh - минимальный сборщик метрик для UCH

echo "=== UCH БАЗОВЫЙ СБОРЩИК МЕТРИК ==="
echo "Версия: 0.1.0"
echo "Дата: $(date)"
echo ""

# 1. Собираем базовую метрику: количество документов
MD_COUNT=$(find /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs -name "*.md" -type f | wc -l | tr -d ' ')
echo "📊 Метрика 1: Документы uch-docs"
echo "  Найдено .md файлов: $MD_COUNT"

# 2. Собираем вторую метрику: количество скриптов
SH_COUNT=$(find /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs -name "*.sh" -type f | wc -l | tr -d ' ')
echo "📊 Метрика 2: Скрипты автоматизации"
echo "  Найдено .sh файлов: $SH_COUNT"

# 3. Сохраняем в JSON
TIMESTAMP=$(date -Iseconds)
JSON_FILE="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs/uch-metrics-basic.json"

cat > "$JSON_FILE" << EOF
{
  "report": {
    "id": "90-01-basic",
    "name": "Базовые метрики UCH",
    "version": "0.1.0",
    "generated_at": "$TIMESTAMP",
    "type": "metrics"
  },
  "metrics": {
    "documents": {
      "md_files": $MD_COUNT,
      "collection_time": "$(date)"
    },
    "automation": {
      "shell_scripts": $SH_COUNT
    }
  },
  "system": {
    "uch_docs_path": "/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs",
    "collector": "uch-basic-collector.sh"
  }
}
EOF

echo ""
echo "✅ Данные сохранены в: $JSON_FILE"
echo ""
echo "📋 ЧТО СОБРАНО:"
echo "1. .md файлов: $MD_COUNT"
echo "2. .sh скриптов: $SH_COUNT"
echo ""
echo "🚀 СЛЕДУЮЩИЙ ШАГ:"
echo "Запустите команду для проверки: cat \"$JSON_FILE\""