#!/bin/bash

echo "🔧 РЕШЕНИЕ КОНФЛИКТОВ СО СМЕЩЕНИЕМ"
echo "=================================="
echo ""

# Функция для поиска свободного ID на уровне
find_free_id_at_level() {
    local base_id="$1"  # Например "04-02" для уровня 2
    local level="$2"    # Уровень (количество частей в ID)
    
    # Разбираем base_id на части
    IFS='-' read -r -a parts <<< "$base_id"
    
    if [ "$level" -eq 2 ]; then
        # Для уровня 2 ищем свободный YY
        local prefix="${parts[0]}"
        
        # Проверяем ID от 01 до FF
        for i in {1..255}; do
            hex=$(printf "%02X" "$i")
            test_id="${prefix}-${hex}"
            
            # Проверяем, существует ли документ с таким ID
            if ! grep -r "id: \"$test_id\"" *.md 2>/dev/null | grep -q "id:"; then
                echo "$test_id"
                return 0
            fi
        done
    elif [ "$level" -eq 3 ]; then
        # Для уровня 3 ищем свободный ZZ
        local prefix="${parts[0]}-${parts[1]}"
        
        for i in {1..255}; do
            hex=$(printf "%02X" "$i")
            test_id="${prefix}-${hex}"
            
            if ! grep -r "id: \"$test_id\"" *.md 2>/dev/null | grep -q "id:"; then
                echo "$test_id"
                return 0
            fi
        done
    fi
    
    echo ""
    return 1
}

# Функция для смещения документа
shift_document() {
    local file="$1"
    local reason="$2"
    
    echo "🔄 СМЕЩЕНИЕ: $file"
    echo "   Причина: $reason"
    
    # Извлекаем текущий ID
    current_id=$(grep "^id:" "$file" | head -1 | sed 's/^id:[[:space:]]*"\([^"]*\)".*/\1/')
    
    if [ -z "$current_id" ]; then
        echo "   ❌ Не удалось извлечь ID из файла"
        return 1
    fi
    
    # Определяем уровень
    IFS='-' read -r -a parts <<< "$current_id"
    level=${#parts[@]}
    
    # Ищем свободный ID на том же уровне
    new_id=$(find_free_id_at_level "$current_id" "$level")
    
    if [ -z "$new_id" ]; then
        echo "   ❌ Не удалось найти свободный ID на уровне $level"
        return 1
    fi
    
    # Создаем backup
    BACKUP_DIR="shift-backup-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp "$file" "$BACKUP_DIR/"
    
    # Меняем ID в файле
    echo "   Старый ID: $current_id → Новый ID: $new_id"
    sed -i '' "s/id: \"$current_id\"/id: \"$new_id\"/g" "$file"
    
    # Переименовываем файл
    old_name="$file"
    new_name="${new_id} - ${file#* - }"
    
    if [ "$old_name" != "$new_name" ]; then
        mv "$old_name" "$new_name"
        echo "   📝 Файл переименован: $new_name"
    fi
    
    echo "   ✅ Успешно смещен"
    echo ""
}

# Основная логика
echo "📋 НАЙДЕННЫЕ КОНФЛИКТЫ:"
echo "---------------------"

# Список конфликтов
CONFLICTS=(
    "04-02:04-02 - Снапшот системы создания и нумерации документов.md:04-02 - Снапшот системы документации 20251225.md"
    "04-02-08:04-02-08 - Снапшот системы по итогу проработки задач 20251227.md:04-02-08 - Улучшение системы документации uch-docs.md"
    "04-03:04-03 - Снапшот по итогу проработки задач 20251227.md:04-03 - База данных файлов.md"
    "04-04:04-04 - Снапшот системы после исправления багов 20251228.md:04-04 - Брендбук UCH - UniversalCreativeHub.md"
)

for conflict in "${CONFLICTS[@]}"; do
    IFS=':' read -r conflict_id file1 file2 <<< "$conflict"
    
    echo ""
    echo "🔍 КОНФЛИКТ ID: $conflict_id"
    echo "   Файл 1: $file1"
    echo "   Файл 2: $file2"
    
    # Определяем какой файл смещать (второй)
    if [ -f "$file1" ] && [ -f "$file2" ]; then
        echo ""
        echo "🤔 КАКОЙ ФАЙЛ СМЕСТИТЬ?"
        echo "   1) $file1"
        echo "   2) $file2"
        echo "   3) Пропустить этот конфликт"
        read -p "   Ваш выбор [1-3]: " choice
        
        case $choice in
            1)
                shift_document "$file1" "Конфликт ID с $file2"
                ;;
            2)
                shift_document "$file2" "Конфликт ID с $file1"
                ;;
            3)
                echo "   ⏩ Пропущено"
                ;;
            *)
                echo "   ⏩ Пропущено (неверный выбор)"
                ;;
        esac
    else
        echo "   ⚠️  Один из файлов не найден"
    fi
done

# Исправление шаблонов
echo ""
echo "🔧 ИСПРАВЛЕНИЕ ШАБЛОНОВ:"
echo "----------------------"

TEMPLATES=("child-template-v3.md" "child-template.md" "master-template-v3.md" "master-template.md")

for template in "${TEMPLATES[@]}"; do
    if [ -f "$template" ] && grep -q 'id: "{id}"' "$template"; then
        echo "🔄 Исправление шаблона: $template"
        sed -i '' 's/id: "{id}"/id: "XX"/g' "$template"
        sed -i '' 's/id: "{hex_id}"/id: "XX"/g' "$template"
        echo "   ✅ {id} → XX"
    fi
done

echo ""
echo "✅ ВЫПОЛНЕНО!"
echo ""
echo "🔍 ПРОВЕРКА РЕЗУЛЬТАТА:"
echo "----------------------"
echo "Для проверки выполните:"
echo "  grep -r 'id: \"04-02\"' *.md"
echo "  grep -r 'id: \"04-02-08\"' *.md"
echo "  grep -r 'id: \"04-03\"' *.md"
echo "  grep -r 'id: \"04-04\"' *.md"
echo ""
echo "📊 Все изменения backupированы в shift-backup-*/"
