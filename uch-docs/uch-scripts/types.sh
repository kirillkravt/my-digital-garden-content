#!/bin/bash
# Модуль типов документов для UCH - с цифровым выбором

# Показываем меню типов для уровня
show_type_menu_for_level() {
    local level=$1
    
    case $level in
        1)
            echo ""
            echo "=== ТИПЫ ДОКУМЕНТОВ УРОВНЯ 1 ==="
            echo "1 - project (Проект)"
            echo "2 - line (Линия развития)"
            echo ""
            ;;
        2)
            echo ""
            echo "=== ТИПЫ ДОКУМЕНТОВ УРОВНЯ 2 ==="
            echo "1 - component (Компонент системы)"
            echo "2 - module (Модуль/блок)"
            echo "3 - epic (Эпик)"
            echo ""
            ;;
        3)
            echo ""
            echo "=== ТИПЫ ДОКУМЕНТОВ УРОВНЯ 3 ==="
            echo "1 - task (Задача)"
            echo "2 - feature (Функциональность)"
            echo "3 - bug (Ошибка/баг)"
            echo "4 - snapshot (Снимок системы)"
            # Убрали: инцидент, user_story
            echo ""
            ;;
        4)
            echo ""
            echo "=== ТИПЫ ДОКУМЕНТОВ УРОВНЯ 4 ==="
            echo "1 - solution (Техническое решение)"
            echo "2 - subtask (Подзадача)"
            echo "3 - code_block (Блок кода)"
            echo "4 - decision (Архитектурное решение)"
            echo ""
            ;;
        N)
            echo ""
            echo "=== ТИПЫ НЕИЕРАРХИЧЕСКИХ ДОКУМЕНТОВ ==="
            echo "1 - idea (Идея/концепция)"
            echo "2 - reference (Ссылка/ресурс)"
            echo "3 - meeting (Встреча/обсуждение)"
            echo ""
            ;;
    esac
}

# Выбор типа по цифре
select_type_by_number() {
    local level=$1
    
    case $level in
        1)
            read -p "Выберите тип (1-2) [1]: " type_choice
            case $type_choice in
                1|"") echo "project" ;;
                2) echo "line" ;;
                *) echo "project" ;;
            esac
            ;;
        2)
            read -p "Выберите тип (1-3) [1]: " type_choice
            case $type_choice in
                1|"") echo "component" ;;
                2) echo "module" ;;
                3) echo "epic" ;;
                *) echo "component" ;;
            esac
            ;;
        3)
            read -p "Выберите тип (1-4) [1]: " type_choice
            case $type_choice in
                1|"") echo "task" ;;
                2) echo "feature" ;;
                3) echo "bug" ;;
                4) echo "snapshot" ;;
                # Убрали: инцидент, user_story
                *) echo "task" ;;
            esac
            ;;
        4)
            read -p "Выберите тип (1-4) [1]: " type_choice
            case $type_choice in
                1|"") echo "solution" ;;
                2) echo "subtask" ;;
                3) echo "code_block" ;;
                4) echo "decision" ;;
                *) echo "solution" ;;
            esac
            ;;
        N)
            read -p "Выберите тип (1-3) [1]: " type_choice
            case $type_choice in
                1|"") echo "idea" ;;
                2) echo "reference" ;;
                3) echo "meeting" ;;
                *) echo "idea" ;;
            esac
            ;;
    esac
}

# Получить тип по умолчанию для уровня
get_default_type_for_level() {
    local level=$1
    
    case $level in
        1) echo "project" ;;
        2) echo "component" ;;
        3) echo "task" ;;
        4) echo "solution" ;;
        N) echo "idea" ;;
        *) echo "task" ;;
    esac
}
