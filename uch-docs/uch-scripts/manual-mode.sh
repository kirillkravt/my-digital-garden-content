#!/bin/bash
# Режим создания по имени (ручной ID)

# Создание документа с ручным указанием ID
create_document_manual() {
    echo ""
    echo "📝 СОЗДАНИЕ ПО ИМЕНИ (РУЧНОЙ ID)"
    echo ""
    
    # 1. Ручной ID
    echo "=== ВВОД ID ДОКУМЕНТА ==="
    echo "Формат: XX, XX-YY, XX-YY-ZZ, XX-YY-ZZ-AA"
    echo "Пример: 00, 00-01, 00-01-AB, 00-01-AB-CD"
    echo ""
    read -p "Введите ID документа: " manual_id
    
    if [ -z "$manual_id" ]; then
        echo "❌ ID не может быть пустым"
        return 1
    fi
    
    # Проверяем формат ID
    if ! echo "$manual_id" | grep -qE '^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*$'; then
        echo "❌ Неверный формат ID. Используйте HEX формат (00, 00-01, 00-AB и т.д.)"
        return 1
    fi
    
    # Проверяем что документ не существует
    if find . -maxdepth 1 -name "${manual_id} - *.md" -type f | grep -q .; then
        echo "❌ Документ с ID '$manual_id' уже существует!"
        return 1
    fi
    
    # 2. Определяем уровень по ID
    local level=$(echo "$manual_id" | tr -cd '-' | wc -c)
    level=$((level + 1))
    
    # 3. Определяем родителя (если не уровень 1)
    local parent_id=""
    if [ $level -gt 1 ]; then
        parent_id=$(echo "$manual_id" | sed 's/-[^-]*$//')
        echo "Определен родитель: $parent_id"
    fi
    
    # 4. Название документа
    echo ""
    read -p "Введите название документа: " name
    if [ -z "$name" ]; then
        echo "❌ Название не может быть пустым"
        return 1
    fi
    
    # 5. Выбор типа
    echo ""
    if [ -f "$SCRIPT_DIR/types.sh" ]; then
        source "$SCRIPT_DIR/types.sh"
        show_type_menu_for_level "$level"
        type=$(select_type_by_number "$level")
    else
        type=$(get_default_type_for_level "$level")
    fi
    
    # 6. Теги
    echo ""
    read -p "Введите теги через запятую (необязательно): " tags
    
    # 7. Сводка
    echo ""
    echo "📋 СВОДКА:"
    echo "  ID: $manual_id"
    echo "  Название: $name"
    echo "  Уровень: $level"
    echo "  Тип: $type"
    if [ -n "$parent_id" ]; then
        echo "  Родитель: $parent_id"
    fi
    echo "  Теги: ${tags:-нет}"
    echo ""
    
    read -p "Создать документ? (y/n): " confirm
    if [[ "$confirm" != "y" && "$confirm" != "Y" ]]; then
        echo "❌ Отменено"
        return 0
    fi
    
    # 8. Создаем документ (используем существующую функцию с модификацией)
    echo ""
    echo "Создаю документ с ручным ID..."
    
    # Временно заменяем генерацию ID
    local original_find_free_master_id=$(declare -f find_free_master_id)
    local original_find_free_child_id=$(declare -f find_free_child_id)
    
    # Переопределяем функции для ручного режима
    find_free_master_id() {
        echo "$manual_id" | grep -qE '^[0-9A-Fa-f]{2}$' && echo "$manual_id" || echo "00"
    }
    
    find_free_child_id() {
        local parent="$1"
        echo "$manual_id" | sed "s/^$parent-//"
    }
    
    # Создаем документ
    if create_real_document "$name" "$level" "$type" "$parent_id" "$tags"; then
        echo ""
        echo "🎉 Документ создан с ручным ID: $manual_id"
    else
        echo "❌ Ошибка при создании документа"
    fi
    
    # Восстанавливаем оригинальные функции
    eval "$original_find_free_master_id"
    eval "$original_find_free_child_id"
}
