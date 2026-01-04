#!/bin/bash
echo "=== АНАЛИЗ РАЗРЫВА КОД ↔ ДОКУМЕНТАЦИЯ ==="
echo ""

PROJECT_PATH="/Users/kirillkravcov/UniversalCreativeHub"
DOCS_PATH="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"

echo "📊 СТАТИСТИКА:"
echo "- Python файлов: $(find "$PROJECT_PATH" -type f -name "*.py" | wc -l)"
echo "- JS/TS файлов: $(find "$PROJECT_PATH" -type f -name "*.js" -o -name "*.ts" | wc -l)"
echo "- MD файлов в доке: $(find "$DOCS_PATH" -type f -name "*.md" | wc -l)"
echo ""

echo "🔗 СВЯЗИ МЕЖДУ СИСТЕМАМИ:"
echo "- Ссылок из документации в код: $(grep -r "UniversalCreativeHub" "$DOCS_PATH" --include="*.md" | wc -l)"
echo "- Ссылок из кода в документацию: $(grep -r "uch-docs" "$PROJECT_PATH" --include="*.py" --include="*.js" --include="*.ts" 2>/dev/null | wc -l)"
echo ""

echo "⚠️ ВЫВОД: Практически нет связей между кодом и документацией"
