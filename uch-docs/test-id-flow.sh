#!/bin/bash
# Тестирование flow генерации ID

SCRIPT_DIR="./uch-scripts"
source "$SCRIPT_DIR/utils.sh"
source "$SCRIPT_DIR/document-creator.sh"

echo "Тест 1: Генерация неиерархического ID"
test_id=$(generate_non_hierarchical_id "idea")
echo "Сгенерированный ID: $test_id"

echo -e "\nТест 2: Проверка функций из utils.sh"
echo "Текущая дата: $(get_current_date)"

echo -e "\nТест 3: Симуляция создания документа"
echo "Предполагаемый ID для уровня 1: 00 (свободный мастер ID)"
free_master=$(find_free_master_id)
echo "Свободный мастер ID: $free_master"

echo -e "\nТест 4: Проверка формата вывода"
echo "Если создается документ с ID '00-01-AB-1', то:"
echo "  - Имя файла: 00-01-AB-1_TYPE_slug.md"
echo "  - Frontmatter должен содержать: id: \"00-01-AB-1\""