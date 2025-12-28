#!/bin/bash
# Главный скрипт UCH Document System - Модульная версия

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=== UCH CREATE: МОДУЛЬНАЯ СИСТЕМА ==="
echo "Версия: 0.1.0"
echo ""

# Подключаем модули
if [ -f "$SCRIPT_DIR/utils.sh" ]; then
    source "$SCRIPT_DIR/utils.sh"
    echo "✅ Модуль utils.sh загружен"
else
    echo "⚠️  Модуль utils.sh не найден"
fi

# Главное меню
show_main_menu() {
    echo "=== ГЛАВНОЕ МЕНЮ ==="
    echo "1 - Создать документ"
    echo "2 - Показать справку по типам"
    echo "3 - Проверить систему"
    echo "4 - Протестировать утилиты"
    echo "q - Выход"
    echo ""
    read -p "Ваш выбор (1-4/q): " choice
    
    case $choice in
        1) 
            echo "⚠️  Функция в разработке"
            show_main_menu 
            ;;
        2)
            echo "📚 Справка по типам документов:"
            echo "- project, line (уровень 1)"
            echo "- component, module, epic (уровень 2)"
            echo "- task, feature, user_story, bug, инцидент, snapshot (уровень 3)"
            echo "- solution, subtask, code_block, decision (уровень 4)"
            echo "- idea, reference, meeting (неиерархические)"
            echo ""
            show_main_menu
            ;;
        3)
            echo "✅ Базовая система загружена"
            echo "�� Директория: $SCRIPT_DIR"
            echo "📅 Дата: $(get_current_date 2>/dev/null || echo 'функция не доступна')"
            echo ""
            show_main_menu
            ;;
        4)
            echo "🧪 Тест утилит:"
            echo "- Текущая дата: $(get_current_date 2>/dev/null || echo 'Ошибка')"
            echo "- Свободный master ID: $(find_free_master_id 2>/dev/null || echo 'Ошибка')"
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
