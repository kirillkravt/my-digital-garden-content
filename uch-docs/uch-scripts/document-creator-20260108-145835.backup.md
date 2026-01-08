#!/bin/bash
# Модуль реального создания документов

# Создать реальный документ
create_real_document() {
    local name="$1"
    local level="$2"
    local type="$3"
    local parent_id="$4"
    local tags="$5"
    
    local current_date=$(get_current_date)
    local doc_id=""
    local parent_name=""
    local parent_file=""
    
    # 1. Определяем ID
    if [ "$level" = "N" ]; then
        # Неиерархический документ
        doc_id=$(generate_non_hierarchical_id "$type")
    else
        # Иерархический документ
        if [ -z "$parent_id" ] || [ "$level" -eq 1 ]; then
            # Мастер-документ
            doc_id=$(find_free_master_id)
        else
            # Дочерний документ
            if ! find . -maxdepth 1 -name "${parent_id} - *.md" -type f | grep -q .; then
                echo "❌ Ошибка: Родительский документ с ID '$parent_id' не найден!"
                return 1
            fi
            
            # Получаем родительский файл
            parent_file=$(find . -maxdepth 1 -name "${parent_id} - *.md" -type f | head -1)
            if [ -z "$parent_file" ]; then
                echo "❌ Ошибка: Родительский файл не найден!"
                return 1
            fi
            
            # Генерируем ID
            child_suffix=$(find_free_child_id "$parent_id")
            doc_id="${parent_id}-${child_suffix}"
            
            # Получаем имя родителя
            parent_name=$(clean_parent_name "$parent_file")
        fi
    fi
    
    # 2. Форматируем теги
    local tags_yaml=$(format_tags_yaml "$tags" "$type")
    
    # 3. Создаем имя файла
    local filename="${doc_id} - ${name}.md"
    
    # 4. Создаем документ
    echo "Создаю документ: $filename"
    
    if [ "$level" = "N" ]; then
        create_non_hierarchical_document "$filename" "$doc_id" "$name" "$type" "$tags_yaml" "$current_date"
    else
        create_hierarchical_document "$filename" "$doc_id" "$name" "$level" "$type" "$parent_id" "$parent_name" "$tags_yaml" "$current_date"
    fi
    
    # 5. Обновляем родительский документ (если есть)
    if [ -n "$parent_id" ] && [ -n "$parent_name" ] && [ -n "$parent_file" ]; then
        update_parent_document "$parent_file" "$doc_id" "$name"
    fi
    
    echo "✅ Документ создан: $filename"
    return 0
}

# Создать иерархический документ
create_hierarchical_document() {
    local filename="$1"
    local doc_id="$2"
    local name="$3"
    local level="$4"
    local type="$5"
    local parent_id="$6"
    local parent_name="$7"
    local tags_yaml="$8"
    local current_date="$9"
    
    # Базовый frontmatter
    cat > "$filename" << DOC_EOF
---
id: "$doc_id"
name: "$name"
type: "$type"
level: $level
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Уровень**: $level
DOC_EOF
    
    # Добавляем родительскую информацию
    if [ -n "$parent_id" ] && [ -n "$parent_name" ]; then
        cat >> "$filename" << DOC_EOF
- **Родитель**: [[$parent_id - $parent_name]]
DOC_EOF
    fi
    
    # Добавляем тип-специфичный контент
    case $type in
        "snapshot")
            cat >> "$filename" << SNAPSHOT_EOF
- **Статус**: Активный
- **Создано**: \`$current_date\`
- **Тип документа**: Снимок системы

#### 📊 СТАТУС СИСТЕМЫ

### ✅ РАБОТАЕТ:
- 

### ⚠️ ПРОБЛЕМЫ:
- 

### 🔧 ТЕХНИЧЕСКИЕ ДЕТАЛИ:
- **Версия системы**: 
- **Количество документов**: 
- **Активные задачи**: 
- **Завершенные задачи**: 

#### 🎯 МЕТРИКИ
- 

#### 📈 ТЕНДЕНЦИИ
- 

#### 🔮 ПЛАНЫ
- 
SNAPSHOT_EOF
            ;;
            
        "bug")
            cat >> "$filename" << BUG_EOF
- **Статус**: Открыт
- **Создано**: \`$current_date\`
- **Тип документа**: Ошибка/Баг

#### 🐛 ОПИСАНИЕ ОШИБКИ

#### 🔍 ШАГИ ВОСПРОИЗВЕДЕНИЯ
1. 
2. 
3. 

#### ✅ ОЖИДАЕМЫЙ РЕЗУЛЬТАТ
- 

#### ❌ ФАКТИЧЕСКИЙ РЕЗУЛЬТАТ
- 

#### 🖼 СКРИНШОТЫ/ЛОГИ
- 
BUG_EOF
            ;;
            
        *)
            # Стандартный шаблон
            cat >> "$filename" << STANDARD_EOF
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### ОПИСАНИЕ
Добавьте описание здесь.

#### ЗАДАЧИ
- [ ] Задача 1
- [ ] Задача 2
STANDARD_EOF
            ;;
    esac
    
    # Общая завершающая часть
    cat >> "$filename" << FOOTER_EOF

#### ДОЧЕРНИЕ ДОКУМЕНТЫ
Пока нет дочерних документов.

---
Создано: $current_date
Уровень: $level
FOOTER_EOF
    
    # Добавляем родителя в конец для дочерних документов
    if [ -n "$parent_id" ]; then
        echo "Родитель: $parent_id" >> "$filename"
    fi
}

# Создать неиерархический документ
create_non_hierarchical_document() {
    local filename="$1"
    local doc_id="$2"
    local name="$3"
    local type="$4"
    local tags_yaml="$5"
    local current_date="$6"
    
    case $type in
        "idea")
            cat > "$filename" << IDEA_EOF
---
id: "$doc_id"
name: "$name"
type: "idea"
level: "N"
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Тип**: Идея/Концепция
- **Уровень**: N (неиерархический)
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### 💡 ОПИСАНИЕ ИДЕИ

#### 🎯 ЦЕЛЬ
- 

#### 🔍 ПРОБЛЕМА
- 

#### 🛠️ РЕШЕНИЕ
- 

#### 🔗 СВЯЗИ
- Связанные документы: 

#### 📝 ЗАМЕТКИ
- 

---
Создано: $current_date
IDEA_EOF
            ;;
            
        "reference")
            cat > "$filename" << REFERENCE_EOF
---
id: "$doc_id"
name: "$name"
type: "reference"
level: "N"
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Тип**: Ссылка/Ресурс
- **Уровень**: N (неиерархический)
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### 🔗 ИСТОЧНИК
- **URL**: 
- **Автор**: 
- **Дата публикации**: 
- **Тип ресурса**: [Статья/Документация/Книга/Видео/Код/Другое]

#### 📝 КРАТКОЕ ОПИСАНИЕ

#### 💡 КЛЮЧЕВЫЕ МОМЕНТЫ
- 

#### 🔗 СВЯЗИ
- Связанные документы: 

#### 📎 ПРИЛОЖЕНИЯ
- 

---
Создано: $current_date
REFERENCE_EOF
            ;;
            
        "meeting")
            cat > "$filename" << MEETING_EOF
---
id: "$doc_id"
name: "$name"
type: "meeting"
level: "N"
status: "planning"
$(echo "$tags_yaml")
created: "$current_date"
updated: "$current_date"
author: "$USER"
---

### $name

#### ОБЩАЯ ИНФОРМАЦИЯ
- **ID**: \`$doc_id\`
- **Тип**: Встреча/Обсуждение
- **Уровень**: N (неиерархический)
- **Статус**: Планирование
- **Создано**: \`$current_date\`

#### 📅 ИНФОРМАЦИЯ О ВСТРЕЧЕ
- **Дата**: 
- **Время**: 
- **Место/Платформа**: 
- **Участники**: 

#### 🎯 ЦЕЛИ ВСТРЕЧИ
- 

#### 📝 ПОВЕСТКА
1. 
2. 
3. 

#### ✅ РЕШЕНИЯ И ВЫВОДЫ
- 

#### 📋 ЗАДАЧИ
- [ ] 
- [ ] 
- [ ] 

---
Создано: $current_date
MEETING_EOF
            ;;
    esac
}
