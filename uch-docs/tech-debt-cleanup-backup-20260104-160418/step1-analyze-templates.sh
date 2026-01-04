#!/bin/bash
# step1-analyze-templates.sh - анализ шаблонов и структуры документов

echo "=== ШАГ 1: АНАЛИЗ ШАБЛОНОВ И СТРУКТУРЫ ==="
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

echo "🔍 Поиск шаблонов (префикс 'T'):"
echo ""

# Ищем файлы с префиксом T (шаблоны)
TEMPLATES=$(find . -maxdepth 2 -name "T*.md" -type f)
TEMPLATE_COUNT=$(echo "$TEMPLATES" | wc -l | tr -d ' ')

if [ "$TEMPLATE_COUNT" -eq 0 ]; then
    echo "❌ Шаблоны с префиксом 'T' не найдены"
    echo ""
    echo "🔍 Ищем другие возможные шаблоны:"
    find . -maxdepth 2 -name "*template*" -type f -o -name "*шаблон*" -type f | head -10
else
    echo "✅ Найдено шаблонов: $TEMPLATE_COUNT"
    echo ""
    echo "📋 Список шаблонов:"
    echo "$TEMPLATES" | sed 's|^\./||' | sed 's/^/  /'
    
    # Покажем содержимое первого шаблона
    FIRST_TEMPLATE=$(echo "$TEMPLATES" | head -1)
    if [ -n "$FIRST_TEMPLATE" ]; then
        echo ""
        echo "📄 Содержимое шаблона $(basename "$FIRST_TEMPLATE"):"
        echo "---"
        head -30 "$FIRST_TEMPLATE"
        echo "---"
    fi
fi

echo ""
echo "🔍 Анализ структуры 'Общая информация' в документах:"
echo ""

# Анализируем 5 случайных документов на наличие "Общая информация"
DOC_COUNT=0
FOUND_COUNT=0

for file in *.md; do
    if [ -f "$file" ]; then
        DOC_COUNT=$((DOC_COUNT + 1))
        
        # Ищем "Общая информация" в разных вариантах
        if grep -i "общая информация" "$file" > /dev/null; then
            FOUND_COUNT=$((FOUND_COUNT + 1))
            
            if [ $FOUND_COUNT -le 3 ]; then
                echo "📄 Найдено в $file:"
                # Покажем контекст
                grep -B2 -A2 -i "общая информация" "$file" | head -10
                echo "---"
                
                # Определяем уровень заголовка
                HEADER_LINE=$(grep -n -i "общая информация" "$file" | head -1 | cut -d: -f1)
                if [ -n "$HEADER_LINE" ]; then
                    HEADER=$(sed -n "${HEADER_LINE}p" "$file")
                    echo "  Уровень заголовка: '$HEADER'"
                    
                    # Ищем следующий заголовок после "Общая информация"
                    NEXT_HEADER_LINE=$((HEADER_LINE + 1))
                    FOUND_NEXT=0
                    for i in $(seq $NEXT_HEADER_LINE $((HEADER_LINE + 20))); do
                        LINE=$(sed -n "${i}p" "$file")
                        if [[ "$LINE" =~ ^#+\  ]]; then
                            echo "  Следующий заголовок (строка $i): '$LINE'"
                            FOUND_NEXT=1
                            break
                        fi
                    done
                    if [ $FOUND_NEXT -eq 0 ]; then
                        echo "  Следующий заголовок не найден в следующих 20 строках"
                    fi
                fi
                echo ""
            fi
        fi
        
        if [ $DOC_COUNT -ge 10 ]; then
            break
        fi
    fi
done

echo "📊 Статистика по первым 10 документам:"
echo "  Всего проверено: $DOC_COUNT"
echo "  С 'Общая информация': $FOUND_COUNT"
echo ""

# Специфический поиск по уровням заголовков
echo "🔍 Поиск по конкретным уровням заголовков:"
echo ""

for level in "####" "###" "##"; do
    echo "  Уровень '$level Общая информация':"
    COUNT=$(grep -l "^${level} Общая информация" *.md 2>/dev/null | wc -l)
    echo "    Найдено в $COUNT файлах"
    
    if [ "$COUNT" -gt 0 ]; then
        FIRST_FILE=$(grep -l "^${level} Общая информация" *.md 2>/dev/null | head -1)
        echo "    Пример: $FIRST_FILE"
        
        # Покажем следующий заголовок после "Общая информация"
        LINE_NUM=$(grep -n "^${level} Общая информация" "$FIRST_FILE" | head -1 | cut -d: -f1)
        if [ -n "$LINE_NUM" ]; then
            echo "    На строке: $LINE_NUM"
            
            # Ищем следующий заголовок
            for i in $(seq $((LINE_NUM + 1)) $((LINE_NUM + 15))); do
                NEXT_LINE=$(sed -n "${i}p" "$FIRST_FILE")
                if [[ "$NEXT_LINE" =~ ^#+\  ]] && [[ ! "$NEXT_LINE" =~ "Общая информация" ]]; then
                    echo "    Следующий заголовок (строка $i): '$NEXT_LINE'"
                    break
                fi
            done
        fi
    fi
    echo ""
done

echo "✅ ШАГ 1 ЗАВЕРШЕН"
echo ""
echo "🚀 СЛЕДУЮЩИЙ ШАГ:"
echo "  На основе анализа создадим безопасный скрипт удаления"