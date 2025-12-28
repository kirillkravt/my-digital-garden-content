#!/bin/bash
# Главный скрипт UCH Document System - Модульная версия

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== UCH CREATE: МОДУЛЬНАЯ СИСТЕМА ==="
echo "Версия: 0.4.0"
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

echo "✅ Загружено модулей: $MODULES_LOADED"
echo ""

# Главное меню
show_main_menu() {
    echo "=== ГЛАВНОЕ МЕНЮ ==="
    echo "1 - Создать документ"
    echo "2 - Проверить систему"
    echo "3 - Протестировать утилиты"
    echo "4 - Пакетное создание (эксперимент)"
    echo "q - Выход"
    echo ""
    read -p "Ваш выбор (1-4/q): " choice
    
    case $choice in
        1) 
            create_document_improved
            echo ""
            show_main_menu 
            ;;
        2)
            echo "✅ СИСТЕМА:"
            echo "📁 Директория: $SCRIPT_DIR"
            echo "📅 Дата: $(get_current_date 2>/dev/null || echo 'N/A')"
            echo "📦 Модулей: $MODULES_LOADED"
            echo ""
            show_main_menu
            ;;
        3)
            echo "🧪 ТЕСТ УТИЛИТ:"
            echo "- Текущая дата: $(get_current_date 2>/dev/null || echo 'Ошибка')"
            echo "- Свободный master ID: $(find_free_master_id 2>/dev/null || echo 'Ошибка')"
            echo "- Тип по умолчанию для уровня 3: $(get_default_type_for_level 3 2>/dev/null || echo 'N/A')"
            echo ""
            show_main_menu
            ;;
        4)
            create_batch_documents
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
