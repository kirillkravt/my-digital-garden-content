#!/bin/bash

echo "=== СОЗДАНИЕ МАСТЕР-ДОКУМЕНТА ==="

# Запрашиваем данные
echo "Введите ID документа (например: 01):"
read doc_id

echo "Введите название проекта:"
read doc_name

echo "Введите теги через пробел (например: project test):"
read doc_tags

# Текущая дата
current_date=$(date +%Y-%m-%d)

# Имя файла
filename="${doc_id} - ${doc_name}.md"

echo "Создаю файл: $filename"

# Создаем содержимое файла
cat > "$filename" << EOF
---
id: "$doc_id"
name: "$doc_name"
type: "project"
level: 1
status: "active"
tags: ["@project"
EOF

# Добавляем теги
for tag in $doc_tags; do
    echo ", \"@$tag\"" >> "$filename"
done

# Продолжаем остальную часть файла
cat >> "$filename" << EOF
]
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