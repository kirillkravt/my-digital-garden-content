#!/bin/bash
# step3-find-general-info.sh - поиск блока "Общая информация" во всех вариантах

echo "=== ПОИСК БЛОКА 'ОБЩАЯ ИНФОРМАЦИЯ' ВО ВСЕХ ВАРИАНТАХ ==="
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

# Создаем временный файл для результатов
RESULTS_FILE="/tmp/general_info_results_$$.txt"

echo "🔍 Ищем ВСЕ файлы с 'Общая информация' в любом регистре:"
echo ""

# Сначала просто посчитаем сколько файлов содержат эту фразу
TOTAL_FILES=$(find . -maxdepth 1 -name "*.md" -type f | wc -l)
FILES_WITH_PHRASE=0

echo "📊 Статистика поиска:"
echo "---------------------"

for file in *.md; do
    if [ -f "$file" ]; then
        # Ищем в любом регистре
        if grep -qi "общая информация" "$file"; then
            FILES_WITH_PHRASE=$((FILES_WITH_PHRASE + 1))
            
            # Записываем в результаты
            echo "📄 $file" >> "$RESULTS_FILE"
            
            # Находим все строки с этой фразой
            grep -ni "общая информация" "$file" >> "$RESULTS_FILE"
            
            # Определяем точный заголовок
            HEADER_LINE=$(grep -n -i "общая информация" "$file" | head -1 | cut -d: -f1)
            if [ -n "$HEADER_LINE" ]; then
                HEADER=$(sed -n "${HEADER_LINE}p" "$file")
                echo "  Заголовок: $HEADER" >> "$RESULTS_FILE"
            fi
            echo "---" >> "$RESULTS_FILE"
        fi
    fi
done

echo "Всего файлов: $TOTAL_FILES"
echo "С 'Общая информация': $FILES_WITH_PHRASE"
echo ""

# Покажем детали по первым 10 файлам
echo "🔍 Детали по первым 10 файлам:"
echo "------------------------------"

head -50 "$RESULTS_FILE"

echo ""
echo "🔍 АНАЛИЗ УРОВНЕЙ ЗАГОЛОВКОВ:"
echo ""

# Анализируем уровни заголовков
declare -A LEVEL_COUNTS
LEVEL_COUNTS["#"]=0
LEVEL_COUNTS["##"]=0
LEVEL_COUNTS["###"]=0
LEVEL_COUNTS["####"]=0
LEVEL_COUNTS["other"]=0

for file in *.md; do
    if [ -f "$file" ] && grep -qi "общая информация" "$file"; then
        # Находим строку с заголовком
        LINE_NUM=$(grep -n -i "общая информация" "$file" | head -1 | cut -d: -f1)
        if [ -n "$LINE_NUM" ]; then
            HEADER=$(sed -n "${LINE_NUM}p" "$file")
            
            # Определяем уровень
            if [[ "$HEADER" =~ ^####\ .*[Оо]бщая\ информация ]]; then
                LEVEL_COUNTS["####"]=$((LEVEL_COUNTS["####"] + 1))
            elif [[ "$HEADER" =~ ^###\ .*[Оо]бщая\ информация ]]; then
                LEVEL_COUNTS["###"]=$((LEVEL_COUNTS["###"] + 1))
            elif [[ "$HEADER" =~ ^##\ .*[Оо]бщая\ информация ]]; then
                LEVEL_COUNTS["##"]=$((LEVEL_COUNTS["##"] + 1))
            elif [[ "$HEADER" =~ ^#\ .*[Оо]бщая\ информация ]]; then
                LEVEL_COUNTS["#"]=$((LEVEL_COUNTS["#"] + 1))
            else
                LEVEL_COUNTS["other"]=$((LEVEL_COUNTS["other"] + 1))
                echo "⚠️ Нестандартный заголовок в $file: '$HEADER'" >> "$RESULTS_FILE"
            fi
        fi
    fi
done

echo "Распределение по уровням заголовков:"
echo "  #### : ${LEVEL_COUNTS["####"]}"
echo "  ###  : ${LEVEL_COUNTS["###"]}"
echo "  ##   : ${LEVEL_COUNTS["##"]}"
echo "  #    : ${LEVEL_COUNTS["#"]}"
echo "  other: ${LEVEL_COUNTS["other"]}"

echo ""
echo "🔍 ПРОВЕРКА КОНКРЕТНЫХ ФАЙЛОВ С #### и ###:"
echo ""

# Найдем конкретные примеры с #### и ###
echo "Примеры с #### 'Общая информация':"
for file in *.md; do
    if [ -f "$file" ]; then
        if grep -q "^####.*[Оо]бщая информация" "$file"; then
            echo "  📄 $file"
            HEADER=$(grep "^####.*[Оо]бщая информация" "$file" | head -1)
            echo "    Заголовок: $HEADER"
            
            # Покажем контекст
            LINE_NUM=$(grep -n "^####.*[Оо]бщая информация" "$file" | head -1 | cut -d: -f1)
            if [ -n "$LINE_NUM" ]; then
                echo "    Контекст (5 строк после):"
                END=$((LINE_NUM + 5))
                sed -n "${LINE_NUM},${END}p" "$file" | sed 's/^/      /'
            fi
            echo ""
        fi
    fi
done | head -3

echo "Примеры с ### 'Общая информация':"
for file in *.md; do
    if [ -f "$file" ]; then
        if grep -q "^###.*[Оо]бщая информация" "$file"; then
            echo "  📄 $file"
            HEADER=$(grep "^###.*[Оо]бщая информация" "$file" | head -1)
            echo "    Заголовок: $HEADER"
            
            # Покажем контекст
            LINE_NUM=$(grep -n "^###.*[Оо]бщая информация" "$file" | head -1 | cut -d: -f1)
            if [ -n "$LINE_NUM" ]; then
                echo "    Контекст (5 строк после):"
                END=$((LINE_NUM + 5))
                sed -n "${LINE_NUM},${END}p" "$file" | sed 's/^/      /'
            fi
            echo ""
        fi
    fi
done | head -3

echo ""
echo "📁 РУЧНАЯ ПРОВЕРКА НЕСКОЛЬКИХ ФАЙЛОВ:"
echo ""

# Проверим несколько файлов вручную
for i in {1..5}; do
    FILE=$(ls *.md | head -$i | tail -1)
    if [ -f "$FILE" ]; then
        echo "🔍 $FILE:"
        
        # Ищем все заголовки с "общая информация"
        HEADERS=$(grep -n -i "общая информация" "$FILE")
        if [ -n "$HEADERS" ]; then
            echo "  Найдено:"
            echo "$HEADERS" | sed 's/^/    /'
            
            # Покажем точный заголовок
            FIRST_LINE=$(echo "$HEADERS" | head -1 | cut -d: -f1)
            if [ -n "$FIRST_LINE" ]; then
                HEADER=$(sed -n "${FIRST_LINE}p" "$FILE")
                echo "  Заголовок: '$HEADER'"
            fi
        else
            echo "  Не найдено"
        fi
        echo ""
    fi
done

echo "✅ Результаты сохранены в: $RESULTS_FILE"
echo ""
echo "📋 ВЫВОДЫ:"
echo "  Для просмотра всех результатов: cat $RESULTS_FILE"
echo "  Для поиска конкретного уровня: grep '####' $RESULTS_FILE"