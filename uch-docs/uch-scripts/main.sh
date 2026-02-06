#!/bin/bash
# Главный скрипт UCH Document System - исправленная версия

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== UCH CREATE: МОДУЛЬНАЯ СИСТЕМА ==="
echo "Версия: 1.1.0"
echo ""

# Подключаем модули
MODULES_LOADED=0
if [ -f "$SCRIPT_DIR/utils.sh" ]; then
    source "$SCRIPT_DIR/utils.sh"
    MODULES_LOADED=$((MODULES_LOADED + 1))
fi

if [ -f "$SCRIPT_DIR/types.sh" ]; then
    source "$SCRIPT_DIR/types.sh"
    MODULES_LOADED=$((MODULES_LOADED + 1))
fi

if [ -f "$SCRIPT_DIR/create.sh" ]; then
    source "$SCRIPT_DIR/create.sh"
    MODULES_LOADED=$((MODULES_LOADED + 1))
fi

if [ -f "$SCRIPT_DIR/document-creator.sh" ]; then
    source "$SCRIPT_DIR/document-creator.sh"
    MODULES_LOADED=$((MODULES_LOADED + 1))
fi

if [ -f "$SCRIPT_DIR/manual-mode.sh" ]; then
    source "$SCRIPT_DIR/manual-mode.sh"
    MODULES_LOADED=$((MODULES_LOADED + 1))
fi

if [ -f "$SCRIPT_DIR/batch-mode.sh" ]; then
    source "$SCRIPT_DIR/batch-mode.sh"
    MODULES_LOADED=$((MODULES_LOADED + 1))
fi

if [ -f "$SCRIPT_DIR/replace-shift.sh" ]; then
    source "$SCRIPT_DIR/replace-shift.sh"
    MODULES_LOADED=$((MODULES_LOADED + 1))
fi

# Добавляем загрузку нового генератора в main.sh
if ! grep -q "id-generator-v2.sh" ./uch-scripts/main.sh; then
    # Добавляем после загрузки других модулей
    sed -i '' '/source.*utils.sh/a\
if [ -f "$SCRIPT_DIR/id-generator-v2.sh" ]; then\
    source "$SCRIPT_DIR/id-generator-v2.sh"\
    MODULES_LOADED=$((MODULES_LOADED + 1))\
fi' ./uch-scripts/main.sh
    
    echo "✅ Обновлен main.sh для загрузки id-generator-v2.sh"
else
    echo "⚠️  main.sh уже загружает id-generator-v2.sh"


echo "✅ Загружено модулей: $MODULES_LOADED"
echo ""

# Главное меню
show_main_menu() {
    echo "=== ГЛАВНОЕ МЕНЮ ==="
    echo "1 - Создать документ (авто-ID)"
    echo "2 - Создать по имени (ручной ID)"
    echo "3 - Пакетное создание"
    echo "4 - Операции с документами (замена/смещение)"
    echo "5 - Проверить систему"
    echo "6 - Протестировать утилиты"
    echo "q - Выход"
    echo ""
    read -p "Ваш выбор (1-6/q): " choice
    
    case $choice in
        1) 
            create_document_improved
            echo ""
            show_main_menu 
            ;;
        2)
            create_document_manual
            echo ""
            show_main_menu
            ;;
        3)
            create_batch_documents
            echo ""
            show_main_menu
            ;;
        4)
            if command -v show_simple_operations_menu &> /dev/null; then
                show_simple_operations_menu
            elif command -v show_document_operations_menu &> /dev/null; then
                show_document_operations_menu
            else
                echo "❌ Функция операций с документами не найдена"
            fi
            echo ""
            show_main_menu
            ;;
        5)
            echo "✅ СИСТЕМА:"
            echo "📁 Директория: $SCRIPT_DIR"
            echo "📅 Дата: $(get_current_date 2>/dev/null || echo 'N/A')"
            echo "📦 Модулей: $MODULES_LOADED"
            echo ""
            show_main_menu
            ;;
        6)
            echo "🧪 ТЕСТ УТИЛИТ:"
            echo "- Текущая дата: $(get_current_date 2>/dev/null || echo 'Ошибка')"
            echo "- Свободный master ID: $(find_free_master_id 2>/dev/null || echo 'Ошибка')"
            echo "- Тип по умолчанию для уровня 3: $(get_default_type_for_level 3 2>/dev/null || echo 'N/A')"
            echo ""
            show_main_menu
            ;;
        q|Q) 
            echo "Выход" 
            exit 0 
            ;;
        *) 
            echo "❌ Неверный выбор" 
            show_main_menu 
            ;;
    esac
}

# Проверяем аргументы
if [ $# -eq 0 ]; then
    show_main_menu
else
    echo "⚠️  Командный режим пока не поддерживается"
    show_main_menu
fi
