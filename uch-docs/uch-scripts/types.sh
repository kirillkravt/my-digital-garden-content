#!/bin/bash
# Модуль типов документов для UCH

# Показываем меню типов для уровня ДО выбора
show_type_info_for_level() {
    local level=$1
    
    case $level in
        1)
            echo ""
            echo "📋 ТИПЫ ДОКУМЕНТОВ УРОВНЯ 1:"
            echo "  project   - Проект (основной контейнер)"
            echo "  line      - Линия развития (направление работы)"
            echo ""
            ;;
        2)
            echo ""
            echo "📋 ТИПЫ ДОКУМЕНТОВ УРОВНЯ 2:"
            echo "  component - Компонент системы"
            echo "  module    - Модуль/блок функциональности"
            echo "  epic      - Эпик (крупная функциональность)"
            echo ""
            ;;
        3)
            echo ""
            echo "📋 ТИПЫ ДОКУМЕНТОВ УРОВНЯ 3:"
            echo "  task      - Задача (что нужно сделать)"
            echo "  feature   - Функциональность (что должно работать)"
            echo "  user_story- Пользовательская история"
            echo "  bug       - Ошибка/баг"
            echo "  инцидент  - Инцидент (проблема в работе)"
            echo "  snapshot  - Снимок состояния системы"
            echo ""
            ;;
        4)
            echo ""
            echo "📋 ТИПЫ ДОКУМЕНТОВ УРОВНЯ 4:"
            echo "  solution  - Техническое решение"
            echo "  subtask   - Подзадача"
            echo "  code_block- Блок кода"
            echo "  decision  - Архитектурное решение"
            echo ""
            ;;
        N)
            echo ""
            echo "📋 ТИПЫ НЕИЕРАРХИЧЕСКИХ ДОКУМЕНТОВ:"
            echo "  idea      - Идея/концепция (Z-префикс)"
            echo "  reference - Ссылка/ресурс (R-префикс)"
            echo "  meeting   - Встреча/обсуждение (M-префикс)"
            echo ""
            ;;
    esac
}

# Выбор типа с показом информации
select_type_interactive() {
    local level=$1
    local default_type=$2
    
    # Сначала показываем информацию
    show_type_info_for_level "$level"
    
    # Потом запрашиваем выбор
    case $level in
        1)
            read -p "Введите тип (project/line) [$default_type]: " type_input
            case "$type_input" in
                project|line) echo "$type_input" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        2)
            read -p "Введите тип (component/module/epic) [$default_type]: " type_input
            case "$type_input" in
                component|module|epic) echo "$type_input" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        3)
            read -p "Введите тип (task/feature/user_story/bug/инцидент/snapshot) [$default_type]: " type_input
            case "$type_input" in
                task|feature|user_story|bug|инцидент|snapshot) echo "$type_input" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        4)
            read -p "Введите тип (solution/subtask/code_block/decision) [$default_type]: " type_input
            case "$type_input" in
                solution|subtask|code_block|decision) echo "$type_input" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        N)
            read -p "Введите тип (idea/reference/meeting) [$default_type]: " type_input
            case "$type_input" in
                idea|reference|meeting) echo "$type_input" ;;
                *) echo "$default_type" ;;
            esac
            ;;
        *)
            echo "$default_type"
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

# Проверить валидность типа для уровня
is_valid_type_for_level() {
    local type=$1
    local level=$2
    
    case $level in
        1) [[ "$type" =~ ^(project|line)$ ]] ;;
        2) [[ "$type" =~ ^(component|module|epic)$ ]] ;;
        3) [[ "$type" =~ ^(task|feature|user_story|bug|инцидент|snapshot)$ ]] ;;
        4) [[ "$type" =~ ^(solution|subtask|code_block|decision)$ ]] ;;
        N) [[ "$type" =~ ^(idea|reference|meeting)$ ]] ;;
        *) false ;;
    esac
}
