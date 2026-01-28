#!/bin/bash
echo "🔧 ИСПРАВЛЕНИЕ ФАЙЛОВ С ДВОЙНЫМ FRONTMATTER"
echo "==========================================="
echo ""

fixed_count=0

# Исправляем конкретный файл из примера
if [ -f "3-010201-4_API_Интеграция_Strudel.md" ]; then
  echo "🔄 Исправляю: 3-010201-4_API_Интеграция_Strudel.md"
  
  # Создаем правильный frontmatter
  cat > temp_fix.md << 'INNER'
---
id: "3-010201-4"
name: "Интеграция Strudel"
type: "API"
level: 3
status: "active"
tags: []
created: "2026-01-02"
updated: "2026-01-28"
author: "kirillkravcov"
slug: "3-010201-4_API_Интеграция_Strudel"
---

### ОПИСАНИЕ

## 🎯 Базовая интеграция Strudel в UCH Studio

### ЦЕЛЬ
Интеграция Strudel REPL в UCH Studio для live coding музыки.

### СТАТУС
✅ Базовая интеграция работает

### ПРОБЛЕМЫ
⚠️ Autoplay policy браузеров
⚠️ Глобальные функции `s()`, `sound()`
⚠️ Загрузка семплов

### РЕШЕНИЯ
1. [[5-010201-0003-1_SOL_Autoplay_policy_AudioContext]]
2. [[5-010201-0004-1_SOL_Глобальные_функции_s()_sound()]]
INNER
  
  mv temp_fix.md "3-010201-4_API_Интеграция_Strudel.md"
  fixed_count=1
  echo "✅ Исправлено"
  echo ""
fi

# Общий скрипт для поиска и исправления других файлов
echo "🔍 Поиск других файлов с проблемами..."
find . -name "[0-9Z]-*.md" -type f \
  -not -path "./backup*" \
  -not -path "./frontmatter-fixed-backup*" \
  -not -path "./archive*" \
  -not -path "./audit*" \
  -not -path "./uch-scripts/scripts-backup*" \
  -not -path "./blog*" | while read f; do
  
  # Проверяем количество разделителей
  count=$(grep -c "^---$" "$f")
  
  if [ "$count" -gt 2 ]; then
    echo "🔄 Исправляю: $(basename "$f")"
    
    # Извлекаем правильный frontmatter (первый блок)
    awk '/^---$/ {count++; if (count==2) exit} {print}' "$f" > "${f}.frontmatter"
    
    # Извлекаем основное содержимое (после второго frontmatter)
    awk 'BEGIN {skip=0} /^---$/ {skip++; if (skip==3) next} skip>=3 {print}' "$f" > "${f}.content"
    
    # Объединяем
    cat "${f}.frontmatter" "${f}.content" > "${f}.fixed"
    
    # Проверяем что получился один frontmatter
    new_count=$(grep -c "^---$" "${f}.fixed")
    if [ "$new_count" -eq 2 ]; then
      mv "${f}.fixed" "$f"
      rm -f "${f}.frontmatter" "${f}.content"
      echo "   ✅ Исправлено"
      fixed_count=$((fixed_count + 1))
    else
      echo "   ❌ Ошибка исправления"
      rm -f "${f}.frontmatter" "${f}.content" "${f}.fixed"
    fi
    echo ""
  fi
done

echo "========================================"
echo "📊 ИТОГ: Исправлено файлов: $fixed_count"
