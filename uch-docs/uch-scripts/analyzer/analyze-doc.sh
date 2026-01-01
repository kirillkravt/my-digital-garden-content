#!/bin/bash

echo "🔍 АНАЛИЗ ДОКУМЕНТА UCH-DOCS"
echo "============================="
echo ""

if [ -z "$1" ]; then
    echo "Использование: $0 <файл.md>"
    echo "Пример: $0 04-02-08.md"
    exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
    echo "❌ Файл не найден: $FILE"
    exit 1
fi

echo "📄 Файл: $FILE"
echo ""

# Функция для извлечения поля из YAML
get_yaml_field() {
    local field="$1"
    awk -v field="$field" '
    /^---$/ { if (++count == 1) next; if (count == 2) exit }
    count == 1 && $0 ~ "^" field ":" {
        # Удаляем field: и кавычки
        gsub("^" field ":[ \t]*[\"]?", "")
        gsub("[\"]?$", "")
        print $0
    }
    ' "$FILE"
}

# Проверяем наличие YAML frontmatter
FIRST_LINE=$(head -1 "$FILE")
if [ "$FIRST_LINE" != "---" ]; then
    echo "❌ КРИТИЧЕСКОЕ: Нет YAML frontmatter (ожидается --- в первой строке)"
    exit 1
fi

echo "✅ YAML frontmatter присутствует"
echo ""

# Извлекаем основные поля
ID=$(get_yaml_field "id")
SLUG=$(get_yaml_field "slug")
NAME=$(get_yaml_field "name")
TYPE=$(get_yaml_field "type")
LEVEL=$(get_yaml_field "level")
PARENT=$(get_yaml_field "parent")

echo "📊 ОСНОВНЫЕ ПОЛЯ:"
echo "---------------"
echo "ID:     ${ID:-❌ НЕТ}"
echo "Slug:   ${SLUG:-❌ НЕТ}"
echo "Name:   ${NAME:-❌ НЕТ}"
echo "Type:   ${TYPE:-❌ НЕТ}"
echo "Level:  ${LEVEL:-❌ НЕТ}"
echo "Parent: ${PARENT:-—}"
echo ""

# Счетчики проблем
ERRORS=0
WARNINGS=0

# 1. Проверка ID
echo "🔎 ПРОВЕРКА ID:"
echo "--------------"
if [ -z "$ID" ]; then
    echo "❌ ОШИБКА: Отсутствует поле id"
    ERRORS=$((ERRORS + 1))
else
    # Проверяем формат HEX ID
    if [[ "$ID" =~ ^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2}){0,3}$ ]]; then
        echo "✅ Формат HEX ID корректен"
        
        # Определяем уровень по количеству частей
        PARTS=$(echo "$ID" | tr '-' '\n' | wc -l | tr -d ' ')
        EXPECTED_LEVEL=$PARTS
        
        if [ -n "$LEVEL" ]; then
            if [ "$LEVEL" -eq "$EXPECTED_LEVEL" ]; then
                echo "✅ Уровень $LEVEL соответствует длине ID"
            else
                echo "❌ ОШИБКА: Уровень $LEVEL не соответствует длине ID (ожидается $EXPECTED_LEVEL)"
                ERRORS=$((ERRORS + 1))
            fi
        else
            echo "⚠️  ПРЕДУПРЕЖДЕНИЕ: Можно определить уровень как $EXPECTED_LEVEL"
            WARNINGS=$((WARNINGS + 1))
        fi
        
    else
        echo "❌ ОШИБКА: Неверный формат HEX ID"
        ERRORS=$((ERRORS + 1))
    fi
fi
echo ""

# 2. Проверка Slug
echo "🔎 ПРОВЕРКА SLUG:"
echo "----------------"
if [ -z "$SLUG" ]; then
    echo "❌ ОШИБКА: Отсутствует поле slug"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Поле slug присутствует"
    
    # Проверяем соответствие ID и slug
    if [ -n "$ID" ] && [[ "$SLUG" == "$ID"-* ]]; then
        echo "✅ Slug начинается с ID"
    else
        echo "⚠️  ПРЕДУПРЕЖДЕНИЕ: Slug не начинается с ID"
        WARNINGS=$((WARNINGS + 1))
    fi
fi
echo ""

# 3. Проверка Type
echo "🔎 ПРОВЕРКА ТИПА:"
echo "----------------"
if [ -z "$TYPE" ]; then
    echo "❌ ОШИБКА: Отсутствует поле type"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Поле type присутствует: $TYPE"
    
    # Если level не указан, пытаемся определить из ID
    if [ -z "$LEVEL" ] && [ -n "$ID" ]; then
        PARTS=$(echo "$ID" | tr '-' '\n' | wc -l | tr -d ' ')
        LEVEL=$PARTS
        echo "ℹ️  Уровень определен из ID: $LEVEL"
    fi
    
    # Определяем допустимые типы для уровня
    if [ -n "$LEVEL" ]; then
        case "$LEVEL" in
            1)
                ALLOWED_TYPES=("hub" "line" "platform" "project")
                ;;
            2)
                ALLOWED_TYPES=("epic" "component" "module" "snapshot" "department" "subsystem")
                ;;
            3)
                ALLOWED_TYPES=("task" "feature" "bug" "research" "experiment" "analysis" "decision")
                ;;
            4)
                ALLOWED_TYPES=("subtask" "solution" "specification" "test" "review" "code_block")
                ;;
            *)
                ALLOWED_TYPES=()
                ;;
        esac
        
        if [[ " ${ALLOWED_TYPES[@]} " =~ " ${TYPE} " ]]; then
            echo "✅ Тип '$TYPE' допустим для уровня $LEVEL"
        else
            echo "❌ ОШИБКА: Тип '$TYPE' недопустим для уровня $LEVEL"
            echo "   Допустимые типы: ${ALLOWED_TYPES[*]}"
            ERRORS=$((ERRORS + 1))
        fi
    else
        echo "⚠️  ПРЕДУПРЕЖДЕНИЕ: Не могу проверить тип без уровня"
        WARNINGS=$((WARNINGS + 1))
    fi
fi
echo ""

# 4. Проверка родительских связей
echo "🔎 ПРОВЕРКА ИЕРАРХИИ:"
echo "--------------------"
if [ -n "$LEVEL" ] && [ "$LEVEL" -gt 1 ]; then
    if [ -z "$PARENT" ]; then
        echo "❌ ОШИБКА: Уровень $LEVEL, но отсутствует parent"
        ERRORS=$((ERRORS + 1))
    else
        echo "✅ Указан родитель: $PARENT"
    fi
else
    if [ "$LEVEL" -eq 1 ] && [ -n "$PARENT" ]; then
        echo "⚠️  ПРЕДУПРЕЖДЕНИЕ: Уровень 1, но указан родитель"
        WARNINGS=$((WARNINGS + 1))
    fi
fi
echo ""

# 5. Проверка обязательных полей Name
echo "🔎 ПРОВЕРКА ОБЯЗАТЕЛЬНЫХ ПОЛЕЙ:"
echo "-------------------------------"
if [ -z "$NAME" ]; then
    echo "❌ ОШИБКА: Отсутствует поле name"
    ERRORS=$((ERRORS + 1))
else
    echo "✅ Поле name присутствует"
fi
echo ""

# Итоговый отчет
echo "📊 ИТОГОВЫЙ ОТЧЕТ:"
echo "================="
echo "Ошибок:          $ERRORS"
echo "Предупреждений:  $WARNINGS"
echo ""

if [ $ERRORS -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo "🎉 ВСЕ ПРОВЕРКИ ПРОЙДЕНЫ УСПЕШНО!"
elif [ $ERRORS -eq 0 ]; then
    echo "✅ Нет критических ошибок (только предупреждения)"
else
    echo "❌ ЕСТЬ КРИТИЧЕСКИЕ ОШИБКИ"
fi
