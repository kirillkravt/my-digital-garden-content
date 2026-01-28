#!/bin/bash
echo "📊 АНАЛИЗ ПОЛЕЙ FRONTMATTER ПОСЛЕ ИСПРАВЛЕНИЯ ID"
echo "==============================================="
echo ""

# Берем примеры файлов для анализа
sample_files=$(find . -name "[0-9]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | head -5)

echo "1. ПРИМЕРЫ ПОСЛЕ ИСПРАВЛЕНИЯ ID:"
echo "-------------------------------"
for f in $sample_files; do
  filename=$(basename "$f")
  echo "Файл: $filename"
  
  # Извлекаем информацию из имени файла
  file_id=$(echo "$filename" | grep -oE '^[0-9]+-[0-9]+-[0-9]+' | head -1)
  file_type_code=$(echo "$filename" | grep -oE '_[A-Z]+_' | sed 's/_//g')
  level=$(echo "$file_id" | cut -d'-' -f1)
  
  # Смотрим текущий frontmatter
  echo "   ID из имени: $file_id"
  echo "   Уровень из ID: $level"
  echo "   Тип из имени: $file_type_code"
  
  # Показываем текущий frontmatter
  echo "   Текущий frontmatter:"
  grep -A5 "id:" "$f" | head -6 | sed 's/^/     /'
  echo ""
done

echo "2. СООТВЕТСТВИЕ ТИПОВ ПО НОВОЙ СИСТЕМЕ:"
echo "-------------------------------------"
echo "Согласно документу 3-010402-1:"
echo "  • PROD, VISION, STRAT, ROAD, BUS, BRAND - уровень 1"
echo "  • LINE, PLAT, SERV, TOOL, LIB, APP - уровень 2"
echo "  • COMP, MOD, SYS, API, DB, INFRA - уровень 3"
echo "  • TASK, FEAT, RES, TEST, IMPROV, REF - уровень 4"
echo "  • SOL, CODE, BUG, ALG, CONF, SCRIPT - уровень 5"
echo "  • REPORT, METRIC, ANALYT, LOG, BACKUP, AUDIT - уровень 6"
echo "  • ARCH, DOC, SPEC, DESIGN, PLAN, PROC - общие типы (7-99)"
