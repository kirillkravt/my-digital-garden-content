#!/bin/bash

echo "=== СОЗДАНИЕ МАСТЕР-ДОКУМЕНТА С ПОИСКОМ СВОБОДНОГО ID ==="

# Функция для поиска первого свободного HEX ID
find_first_free_id() {
    # Получаем список всех ID в текущей папке
    # Ищем файлы с паттерном: две hex цифры, пробел, дефис, пробел
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E '^\./[0-9A-Fa-f]{2} - ' | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        sort | uniq)
    
    # Если нет файлов, возвращаем 00
    if [ -z "$existing_ids" ]; then
        echo "00"
        return
    fi
    
    # Конвертируем все ID в десятичные
    declare -a dec_ids=()
    for hex_id in $existing_ids; do
        # Конвертируем hex в decimal
        dec_id=$((16#$hex_id))
        dec_ids+=($dec_id)
    done
    
    # Сортируем decimal ID
    sorted_ids=($(printf "%d\n" "${dec_ids[@]}" | sort -n))
    
    # Ищем первый пропуск, начиная с 0
    expected=0
    for id in "${sorted_ids[@]}"; do
        if [ $id -gt $expected ]; then
            # Нашли пропуск
            break
        fi
        expected=$((id + 1))
    done
    
    # Конвертируем обратно в hex с лидирующим нулем
    printf "%02X" $expected
}

# Получаем свободный ID
free_id=$(find_first_free_id)
echo "Найден свободный ID: $free_id"

# Запрашиваем остальные данные
echo "Введите название проекта:"
read doc_name

if [ -z "$doc_name" ]; then
    echo "Ошибка: название не может быть пустым"
    exit 1
fi

echo "Введите теги через пробел (например: music studio):"
read doc_tags

# Текущая дата
current_date=$(date +%Y-%m-%d)

# Имя файла
filename="${free_id} - ${doc_name}.md"

echo "Создаю файл: $filename"

# Создаем массив тегов
tags_array="[\"@project\""
if [ -n "$doc_tags" ]; then
    for tag in $doc_tags; do
        tags_array="${tags_array}, \"@$tag\""
    done
fi
tags_array="${tags_array}]"

# Создаем файл
cat > "$filename" << EOF
---
id: "$free_id"
name: "$doc_name"
type: "project"
level: 1
status: "active"
tags: $tags_array
parent: null
created: "$current_date"
updated: "$current_date"
author: "$USER"
---
### $doc_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$free_id\` (свободный номер)
- **Статус**: Активная разработка
- **Уровень**: 1
- **Создано**: \`$current_date\`
- **Теги**: $doc_tags

#### ОПИСАНИЕ
Добавьте описание проекта здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $current_date
Система документирования UCH
EOF

echo "✅ Документ создан: $filename"