#!/bin/bash
# uch-metrics-collector.sh - сбор метрик из всех частей проекта UCH

echo "=== UCH СБОРЩИК МЕТРИК (полный) ==="
echo "Версия: 0.4.0"
echo "Дата: $(date)"
echo ""

# Основные пути проекта
UCH_BASE="/Users/kirillkravcov/UniversalCreativeHub"
UCH_BACKEND="$UCH_BASE/uch-backend"
UCH_DOCS="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"
UCH_LINE_A="$UCH_BACKEND/uch/apps/blog"
UCH_LINE_B="$UCH_BACKEND/uch/apps/studio"

echo "🔍 Сканирование структуры проекта UCH..."
echo ""

# 1. МЕТРИКИ ДОКУМЕНТАЦИИ (uch-docs)
echo "📚 uch-docs (документация):"
MD_COUNT_DOCS=$(find "$UCH_DOCS" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
SH_COUNT_DOCS=$(find "$UCH_DOCS" -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')
TEMPLATES_COUNT=$(find "$UCH_DOCS/_templates" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
SCRIPTS_COUNT=$(find "$UCH_DOCS/uch-scripts" -name "*.sh" -type f 2>/dev/null | wc -l | tr -d ' ')

echo "  • .md документов: $MD_COUNT_DOCS"
echo "  • .sh скриптов: $SH_COUNT_DOCS"
echo "  • Шаблонов: $TEMPLATES_COUNT"
echo "  • Скриптов uch-scripts: $SCRIPTS_COUNT"
echo ""

# 2. МЕТРИКИ БЭКЕНДА (uch-backend)
echo "🐍 uch-backend (Django):"
if [ -d "$UCH_BACKEND" ]; then
    PY_COUNT_BACKEND=$(find "$UCH_BACKEND" -name "*.py" -type f 2>/dev/null | wc -l | tr -d ' ')
    HTML_COUNT_BACKEND=$(find "$UCH_BACKEND" -name "*.html" -type f 2>/dev/null | wc -l | tr -d ' ')
    MD_COUNT_BACKEND=$(find "$UCH_BACKEND" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    SQL_COUNT_BACKEND=$(find "$UCH_BACKEND" -name "*.sql" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    echo "  • .py файлов: $PY_COUNT_BACKEND"
    echo "  • .html шаблонов: $HTML_COUNT_BACKEND"
    echo "  • .md файлов: $MD_COUNT_BACKEND"
    echo "  • .sql файлов: $SQL_COUNT_BACKEND"
else
    echo "  ❌ uch-backend не найден"
fi
echo ""

# 3. МЕТРИКИ ЛИНИИ А (Блог)
echo "📝 Линия А (Блог):"
if [ -d "$UCH_LINE_A" ]; then
    PY_COUNT_A=$(find "$UCH_LINE_A" -name "*.py" -type f 2>/dev/null | wc -l | tr -d ' ')
    HTML_COUNT_A=$(find "$UCH_LINE_A" -name "*.html" -type f 2>/dev/null | wc -l | tr -d ' ')
    MD_COUNT_A=$(find "$UCH_LINE_A" -name "*.md" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    echo "  • .py файлов: $PY_COUNT_A"
    echo "  • .html шаблонов: $HTML_COUNT_A"
    echo "  • .md файлов: $MD_COUNT_A"
else
    echo "  ⚠️ Линия А не найдена"
fi
echo ""

# 4. МЕТРИКИ ЛИНИИ Б (Студия)
echo "🎵 Линия Б (Студия):"
if [ -d "$UCH_LINE_B" ]; then
    PY_COUNT_B=$(find "$UCH_LINE_B" -name "*.py" -type f 2>/dev/null | wc -l | tr -d ' ')
    JS_COUNT_B=$(find "$UCH_LINE_B" -name "*.js" -type f 2>/dev/null | wc -l | tr -d ' ')
    TS_COUNT_B=$(find "$UCH_LINE_B" -name "*.ts" -type f 2>/dev/null | wc -l | tr -d ' ')
    HTML_COUNT_B=$(find "$UCH_LINE_B" -name "*.html" -type f 2>/dev/null | wc -l | tr -d ' ')
    
    echo "  • .py файлов: $PY_COUNT_B"
    echo "  • .js файлов: $JS_COUNT_B"
    echo "  • .ts файлов: $TS_COUNT_B"
    echo "  • .html файлов: $HTML_COUNT_B"
    
    # Frontend специфичные метрики
    if [ -d "$UCH_LINE_B/frontend" ]; then
        PACKAGE_JSON="$UCH_LINE_B/frontend/package.json"
        if [ -f "$PACKAGE_JSON" ]; then
            DEPENDENCIES_COUNT=$(grep -c '"dependencies"' "$PACKAGE_JSON")
            echo "  • Зависимостей package.json: $DEPENDENCIES_COUNT"
        fi
    fi
else
    echo "  ⚠️ Линия Б не найдена"
fi
echo ""

# 5. ОБЩИЕ МЕТРИКИ ПРОЕКТА
echo "📊 Общие метрики проекта:"

# Размеры директорий
SIZE_DOCS=$(du -sh "$UCH_DOCS" 2>/dev/null | cut -f1)
SIZE_BACKEND=$(du -sh "$UCH_BACKEND" 2>/dev/null | cut -f1)
SIZE_TOTAL=$(du -sh "$UCH_BASE" 2>/dev/null | cut -f1)

echo "  • Размер uch-docs: $SIZE_DOCS"
echo "  • Размер uch-backend: $SIZE_BACKEND"
echo "  • Общий размер UCH: $SIZE_TOTAL"
echo ""

# 6. СОХРАНЕНИЕ В JSON
TIMESTAMP=$(date -Iseconds)
JSON_FILE="$UCH_DOCS/uch-metrics-full.json"

cat > "$JSON_FILE" << EOF
{
  "report": {
    "id": "90-03-metrics",
    "name": "Полные метрики проекта UCH",
    "version": "0.4.0",
    "generated_at": "$TIMESTAMP",
    "type": "full_metrics"
  },
  "project_structure": {
    "base_path": "$UCH_BASE",
    "backend_path": "$UCH_BACKEND",
    "docs_path": "$UCH_DOCS",
    "line_a_path": "$UCH_LINE_A",
    "line_b_path": "$UCH_LINE_B"
  },
  "metrics": {
    "uch_docs": {
      "md_files": $MD_COUNT_DOCS,
      "shell_scripts": $SH_COUNT_DOCS,
      "templates": $TEMPLATES_COUNT,
      "uch_scripts": $SCRIPTS_COUNT,
      "size": "$SIZE_DOCS"
    },
    "uch_backend": {
      "python_files": $PY_COUNT_BACKEND,
      "html_templates": $HTML_COUNT_BACKEND,
      "md_files": $MD_COUNT_BACKEND,
      "sql_files": $SQL_COUNT_BACKEND,
      "size": "$SIZE_BACKEND"
    },
    "line_a": {
      "python_files": $PY_COUNT_A,
      "html_templates": $HTML_COUNT_A,
      "md_files": $MD_COUNT_A,
      "exists": "$([ -d "$UCH_LINE_A" ] && echo "true" || echo "false")"
    },
    "line_b": {
      "python_files": $PY_COUNT_B,
      "js_files": $JS_COUNT_B,
      "ts_files": $TS_COUNT_B,
      "html_files": $HTML_COUNT_B,
      "exists": "$([ -d "$UCH_LINE_B" ] && echo "true" || echo "false")"
    },
    "totals": {
      "total_size": "$SIZE_TOTAL",
      "total_md_files": $((MD_COUNT_DOCS + MD_COUNT_BACKEND + MD_COUNT_A + MD_COUNT_B)),
      "total_python_files": $((PY_COUNT_BACKEND + PY_COUNT_A + PY_COUNT_B))
    }
  },
  "directory_checks": {
    "uch_docs_exists": "$([ -d "$UCH_DOCS" ] && echo "true" || echo "false")",
    "uch_backend_exists": "$([ -d "$UCH_BACKEND" ] && echo "true" || echo "false")",
    "line_a_exists": "$([ -d "$UCH_LINE_A" ] && echo "true" || echo "false")",
    "line_b_exists": "$([ -d "$UCH_LINE_B" ] && echo "true" || echo "false")"
  }
}
EOF

echo "✅ Полные метрики сохранены в: $JSON_FILE"
echo ""
echo "📋 СВОДКА ПО ВСЕМУ ПРОЕКТУ UCH:"
echo "• uch-docs: $MD_COUNT_DOCS .md файлов, $SH_COUNT_DOCS скриптов"
echo "• uch-backend: $PY_COUNT_BACKEND .py файлов"
echo "• Линия А: $PY_COUNT_A .py файлов"
echo "• Линия Б: $PY_COUNT_B .py, $JS_COUNT_B .js, $TS_COUNT_B .ts файлов"
echo "• Общий размер проекта: $SIZE_TOTAL"
echo ""
echo "🚀 СЛЕДУЮЩИЙ ШАГ:"
echo "Запустите: cat $JSON_FILE"