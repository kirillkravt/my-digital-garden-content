#!/bin/bash

echo "=== СОЗДАНИЕ МАСТЕР-ДОКУМЕНТА v2 ==="

# Запрашиваем данные
echo "Введите ID документа (например: 01):"
read doc_id

echo "Введите название проекта:"
read doc_name

echo "Введите теги через пробел (например: test automation):"
read doc_tags

# Текущая дата
current_date=$(date +%Y-%m-%d)

# Имя файла
filename="${doc_id} - ${doc_name}.md"

echo "Создаю файл: $filename"

# Создаем массив тегов правильно
tags_array="[\"@project\""
for tag in $doc_tags; do
    tags_array="${tags_array}, \"@$tag\""
done
tags_array="${tags_array}]"

# Создаем весь файл сразу
cat > "$filename" << EOF
---
id: "$doc_id"
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
- **ID**: \`$doc_id\`
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

echo "Документ создан: $filename"