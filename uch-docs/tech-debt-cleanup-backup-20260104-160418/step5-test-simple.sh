#!/bin/bash
# step5-test-simple.sh - простой тест удаления

echo "=== ПРОСТОЙ ТЕСТ УДАЛЕНИЯ ==="
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

# Тестовый файл
TEST_FILE="00-04 - Линия Г. Документация.md"

if [ ! -f "$TEST_FILE" ]; then
    echo "❌ Файл не найден: $TEST_FILE"
    exit 1
fi

# Показываем исходное состояние
echo "📄 ИСХОДНЫЙ ФАЙЛ ($TEST_FILE):"
echo "----------------------------"
echo "Строки 14-25:"
sed -n '14,25p' "$TEST_FILE"
echo ""

# Копируем файл для теста
cp "$TEST_FILE" "test-original.md"

# Находим строку с заголовком
HEADER_LINE=$(grep -n "#### ОБЩАЯ ИНФОРМАЦИЯ" "test-original.md" | head -1 | cut -d: -f1)

if [ -z "$HEADER_LINE" ]; then
    echo "❌ Заголовок '#### ОБЩАЯ ИНФОРМАЦИЯ' не найден"
    exit 1
fi

echo "Заголовок найден на строке: $HEADER_LINE"

# Ищем следующий заголовок ####, ### или ##
NEXT_HEADER_LINE=""
TOTAL_LINES=$(wc -l < "test-original.md")

for ((i=HEADER_LINE+1; i<=TOTAL_LINES; i++)); do
    line=$(sed -n "${i}p" "test-original.md")
    if [[ "$line" =~ ^####\  ]] || [[ "$line" =~ ^###\  ]] || [[ "$line" =~ ^##\  ]]; then
        if [[ ! "$line" =~ ОБЩАЯ\ ИНФОРМАЦИЯ ]]; then
            NEXT_HEADER_LINE=$i
            break
        fi
    fi
done

if [ -z "$NEXT_HEADER_LINE" ]; then
    echo "❌ Следующий заголовок не найден"
    rm test-original.md
    exit 1
fi

echo "Следующий заголовок на строке: $NEXT_HEADER_LINE"
echo "Будет удалено строк: $((NEXT_HEADER_LINE - HEADER_LINE))"
echo ""

# Удаляем блок
sed "${HEADER_LINE},$((NEXT_HEADER_LINE - 1))d" "test-original.md" > "test-modified.md"

echo "📄 ФАЙЛ ПОСЛЕ УДАЛЕНИЯ:"
echo "----------------------"
echo "Строки 14-25 (после удаления):"
sed -n '14,25p' "test-modified.md"

echo ""
echo "🔍 ПРОВЕРКА:"
echo "Есть ли еще 'ОБЩАЯ ИНФОРМАЦИЯ' в новом файле?"
grep -n "ОБЩАЯ ИНФОРМАЦИЯ" "test-modified.md" && echo "❌ Осталось" || echo "✅ Удалено"

echo ""
echo "📋 СРАВНЕНИЕ:"
echo "Исходный файл: $(wc -l < test-original.md) строк"
echo "Новый файл: $(wc -l < test-modified.md) строк"
echo "Удалено строк: $(( $(wc -l < test-original.md) - $(wc -l < test-modified.md) ))"

# Очистка
rm test-original.md test-modified.md

echo ""
echo "✅ ТЕСТ ЗАВЕРШЕН"
