#!/bin/bash

echo "=== СОЗДАНИЕ ДОЧЕРНЕГО ДОКУМЕНТА ==="

# Функция для поиска первого свободного дочернего ID
find_free_child_id() {
    local parent_id="$1"
    local level="$2"
    
    # Ищем все дочерние файлы для данного родителя
    pattern="${parent_id}-[0-9A-Fa-f]\{2\}"
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E "^\./${pattern} - " | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        cut -d'-' -f$((level + 1)) | \
        sort | uniq)
    
    # Если нет дочерних файлов, начинаем с 01
    if [ -z "$existing_ids" ]; then
        echo "01"
        return
    fi
    
    # Конвертируем все ID в десятичные
    declare -a dec_ids=()
    for hex_id in $existing_ids; do
        dec_id=$((16#$hex_id))
        dec_ids+=($dec_id)
    done
    
    # Сортируем decimal ID
    sorted_ids=($(printf "%d\n" "${dec_ids[@]}" | sort -n))
    
    # Ищем первый пропуск, начиная с 1
    expected=1
    for id in "${sorted_ids[@]}"; do
        if [ $id -gt $expected ]; then
            break
        fi
        expected=$((id + 1))
    done
    
    # Конвертируем обратно в hex с лидирующим нулем
    printf "%02X" $expected
}

# Запрашиваем ID родителя
echo "Введите ID родительского документа (например: 00 или 00-01):"
read parent_id

if [ -z "$parent_id" ]; then
    echo "Ошибка: ID родителя не может быть пустым"
    exit 1
fi

# Проверяем существование родительского файла
parent_file=$(find . -maxdepth 1 -name "${parent_id} - *.md" -type f | head -1)
if [ -z "$parent_file" ]; then
    echo "Ошибка: родительский файл с ID $parent_id не найден"
    exit 1
fi

# Получаем имя родителя из названия файла
parent_name=$(basename "$parent_file" .md | sed 's/^[^-]*- //')

# Определяем уровень дочернего документа
# Считаем количество дефисов в parent_id + 1
level=$(echo "$parent_id" | tr -cd '-' | wc -c)
level=$((level + 2))

echo "Уровень нового документа: $level"

# Генерируем дочерний ID
child_suffix=$(find_free_child_id "$parent_id" "$level")
child_id="${parent_id}-${child_suffix}"

echo "Сгенерирован дочерний ID: $child_id"

# Запрашиваем остальные данные
echo "Введите название дочернего документа:"
read child_name

if [ -z "$child_name" ]; then
    echo "Ошибка: название не может быть пустым"
    exit 1
fi

echo "Введите теги через пробел:"
read child_tags

# Текущая дата
current_date=$(date +%Y-%m-%d)

# Имя файла
filename="${child_id} - ${child_name}.md"

echo "Создаю файл: $filename"

# Создаем массив тегов
tags_array="[\"@component\""
if [ -n "$child_tags" ]; then
    for tag in $child_tags; do
        tags_array="${tags_array}, \"@$tag\""
    done
fi
tags_array="${tags_array}]"

# Создаем файл
cat > "$filename" << EOF
---
id: "$child_id"
name: "$child_name"
type: "component"
level: $level
status: "active"
tags: $tags_array
parent: "$parent_id"
parent_name: "$parent_name"
created: "$current_date"
updated: "$current_date"
author: "$USER"
---
### $child_name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$child_id\`
- **Уровень**: $level
- **Родитель**: [[$parent_id - $parent_name]]
- **Статус**: Активная разработка
- **Создано**: \`$current_date\`
- **Теги**: $child_tags

#### ОПИСАНИЕ
Добавьте описание компонента здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $current_date
Уровень: $level
Родитель: $parent_id
EOF

echo "✅ Дочерний документ создан: $filename"
echo "📁 Родитель: $parent_name ($parent_id)"