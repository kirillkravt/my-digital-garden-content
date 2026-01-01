#!/bin/bash

echo "🔍 ПРОВЕРКА КОНФЛИКТОВ ID В ДОКУМЕНТАХ"
echo "======================================"
echo ""

# Храним ID и файлы в ассоциативном массиве (через временный файл)
TEMP_FILE="/tmp/uch_ids_$$.tmp"

# Собираем все ID из документов
echo "📊 Сбор ID из документов..."
echo ""

CONFLICT_COUNT=0
PROCESSED_FILES=0

for file in *.md; do
    if [ ! -f "$file" ]; then
        continue
    fi
    
    PROCESSED_FILES=$((PROCESSED_FILES + 1))
    
    # Проверяем наличие YAML frontmatter
    FIRST_LINE=$(head -1 "$file" 2>/dev/null)
    if [ "$FIRST_LINE" != "---" ]; then
        continue
    fi
    
    # Извлекаем ID из YAML
    ID=$(awk '
    /^---$/ { if (++count == 1) next; if (count == 2) exit }
    count == 1 && /^id:/ {
        gsub("^id:[ \t]*[\"]?", "")
        gsub("[\"]?$", "")
        print $0
    }
    ' "$file")
    
    if [ -n "$ID" ]; then
        # Записываем в формате: ID|file
        echo "$ID|$file" >> "$TEMP_FILE"
        echo "✅ $file → ID: $ID"
    else
        echo "⚠️  $file → Нет ID в YAML"
    fi
done

echo ""
echo "🔎 Анализ конфликтов..."
echo ""

# Анализируем конфликты
if [ -f "$TEMP_FILE" ]; then
    # Сортируем по ID и ищем дубликаты
    sort "$TEMP_FILE" | awk -F'|' '
    {
        if (last_id == $1) {
            if (!conflict_reported[$1]) {
                print "❌ КОНФЛИКТ ID: " $1
                print "   Файлы:"
                conflict_reported[$1] = 1
                conflict_count++
                # Печатаем предыдущий файл
                print "   - " last_file
            }
            print "   - " $2
        }
        last_id = $1
        last_file = $2
    }
    END {
        if (conflict_count == 0) {
            print "✅ Конфликтов ID не найдено"
        } else {
            print ""
            print "📊 Найдено конфликтов: " conflict_count
        }
    }
    
    # Также покажем статистику по ID
    echo ""
    echo "📈 СТАТИСТИКА ПО ID:"
    echo "-------------------"
    
    # Подсчет уникальных ID
    UNIQUE_IDS=$(cut -d'|' -f1 "$TEMP_FILE" | sort -u | wc -l | tr -d ' ')
    TOTAL_IDS=$(wc -l < "$TEMP_FILE" | tr -d ' ')
    
    echo "Уникальных ID: $UNIQUE_IDS"
    echo "Всего ID в файлах: $TOTAL_IDS"
    
    if [ "$UNIQUE_IDS" -ne "$TOTAL_IDS" ]; then
        CONFLICT_COUNT=$((TOTAL_IDS - UNIQUE_IDS))
        echo "❌ Есть дубликаты: $CONFLICT_COUNT"
        
        # Покажем самые частые ID
        echo ""
        echo "📋 ЧАСТОТА ID:"
        echo "-------------"
        cut -d'|' -f1 "$TEMP_FILE" | sort | uniq -c | sort -rn | head -20 | while read count id; do
            if [ "$count" -gt 1 ]; then
                echo "⚠️  $id встречается $count раз(а):"
                grep "^$id|" "$TEMP_FILE" | cut -d'|' -f2 | sed 's/^/   - /'
            fi
        done
    else
        echo "✅ Все ID уникальны"
    fi
    
    # Покажем распределение по уровням
    echo ""
    echo "📊 РАСПРЕДЕЛЕНИЕ ПО УРОВНЯМ:"
    echo "---------------------------"
    
    cut -d'|' -f1 "$TEMP_FILE" | while read id; do
        PARTS=$(echo "$id" | tr '-' '\n' | wc -l | tr -d ' ')
        echo "$PARTS" >> "/tmp/levels_$$.tmp"
    done
    
    if [ -f "/tmp/levels_$$.tmp" ]; then
        echo "Уровень 1 (XX):     $(grep -c '^1$' "/tmp/levels_$$.tmp")"
        echo "Уровень 2 (XX-YY):  $(grep -c '^2$' "/tmp/levels_$$.tmp")"
        echo "Уровень 3 (XX-YY-ZZ): $(grep -c '^3$' "/tmp/levels_$$.tmp")"
        echo "Уровень 4 (XX-YY-ZZ-AA): $(grep -c '^4$' "/tmp/levels_$$.tmp")"
        rm "/tmp/levels_$$.tmp"
    fi
    
    # Проверка на валидность HEX формата
    echo ""
    echo "🔧 ПРОВЕРКА ФОРМАТА HEX ID:"
    echo "--------------------------"
    
    INVALID_COUNT=0
    cut -d'|' -f1 "$TEMP_FILE" | while read id; do
        if [[ ! "$id" =~ ^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2}){0,3}$ ]]; then
            if [ "$INVALID_COUNT" -eq 0 ]; then
                echo "❌ Некорректные HEX ID:"
            fi
            INVALID_COUNT=$((INVALID_COUNT + 1))
            echo "   $id"
        fi
    done
    
    if [ "$INVALID_COUNT" -eq 0 ]; then
        echo "✅ Все ID в корректном HEX формате"
    fi
    
    # Проверка специальных случаев
    echo ""
    echo "🎯 СПЕЦИАЛЬНЫЕ ПРОВЕРКИ:"
    echo "----------------------"
    
    # Проверка ID "00"
    ID_00_FILES=$(grep "^00|" "$TEMP_FILE" | cut -d'|' -f2 | wc -l)
    if [ "$ID_00_FILES" -gt 1 ]; then
        echo "❌ ID '00' используется в нескольких файлах:"
        grep "^00|" "$TEMP_FILE" | cut -d'|' -f2 | sed 's/^/   - /'
    elif [ "$ID_00_FILES" -eq 1 ]; then
        echo "✅ ID '00' используется в одном файле"
    else
        echo "⚠️  ID '00' не найден"
    fi
    
    # Проверка на FF (зарезервировано)
    if grep -q "^FF|" "$TEMP_FILE" || grep -q ".*-FF|" "$TEMP_FILE"; then
        echo "⚠️  Обнаружен ID с 'FF' (зарезервировано):"
        grep -E "^(.*-)?FF|" "$TEMP_FILE" | cut -d'|' -f1,2 | sed 's/|/ → /' | sed 's/^/   /'
    fi
    
    # Очистка временного файла
    rm "$TEMP_FILE"
else
    echo "⚠️  Не найдено документов с ID"
fi

echo ""
echo "📊 ИТОГИ:"
echo "--------"
echo "Обработано файлов: $PROCESSED_FILES"
echo "Конфликтов ID: $CONFLICT_COUNT"

if [ "$CONFLICT_COUNT" -gt 0 ]; then
    echo ""
    echo "🚨 РЕКОМЕНДАЦИИ ПО ИСПРАВЛЕНИЮ КОНФЛИКТОВ:"
    echo "========================================="
    echo "1. Проверьте файлы с одинаковыми ID"
    echo "2. Определите, какой документ основной"
    echo "3. Для дубликатов:"
    echo "   - Либо переименуйте файл с новым ID"
    echo "   - Либо объедините содержимое"
    echo "   - Либо удалите дубликат"
    echo "4. Используйте скрипт uch-create-modular.sh для создания"
    echo "   документов с автоматической генерацией ID"
fi
