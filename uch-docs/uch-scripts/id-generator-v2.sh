#!/bin/bash
# id-generator-v2.sh - Генерация ID по системе 3-010402-1
# Для создания новых документов в существующей системе

# ============================================================================
# КОНФИГУРАЦИЯ
# ============================================================================

# Иерархии из существующей системы
HIERARCHY_UCH_PROJECT="010000"    # Проект UCH
HIERARCHY_DOCS_LINE="010400"      # Линия документации
HIERARCHY_BLOG_LINE="010100"      # Линия блога
HIERARCHY_STUDIO_LINE="010200"    # Линия студии
HIERARCHY_NUMBERING="010401"      # Компонент системы нумерации

# ============================================================================
# ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
# ============================================================================

# Преобразовать тип в номер по системе 3-010402-1
get_type_number() {
    local type="$1"
    local level="$2"
    
    # Приводим к lowercase для сравнения
    type_lower=$(echo "$type" | tr '[:upper:]' '[:lower:]')
    
    # Уровневые типы (номера 1-6)
    case "$level" in
        1)
            # Уровень 1: Проекты/Стратегия
            case "$type_lower" in
                "project"|"prod"|"proj") echo "1" ;;
                "vision") echo "2" ;;
                "strategy"|"strat") echo "3" ;;
                "roadmap"|"road") echo "4" ;;
                "business"|"bus") echo "5" ;;
                "brand") echo "6" ;;
                *) echo "1" ;; # По умолчанию PROJ
            esac
            ;;
        2)
            # Уровень 2: Линии развития
            case "$type_lower" in
                "line") echo "1" ;;
                "platform"|"plat") echo "2" ;;
                "service"|"serv") echo "3" ;;
                "tool") echo "4" ;;
                "library"|"lib") echo "5" ;;
                "application"|"app") echo "6" ;;
                *) echo "1" ;; # По умолчанию LINE
            esac
            ;;
        3)
            # Уровень 3: Компоненты
            case "$type_lower" in
                "component"|"comp") echo "1" ;;
                "module"|"mod") echo "2" ;;
                "system"|"sys") echo "3" ;;
                "api") echo "4" ;;
                "database"|"db") echo "5" ;;
                "infrastructure"|"infra") echo "6" ;;
                *) echo "1" ;; # По умолчанию COMP
            esac
            ;;
        4)
            # Уровень 4: Задачи
            case "$type_lower" in
                "task") echo "1" ;;
                "feature"|"feat") echo "2" ;;
                "research"|"res") echo "3" ;;
                "test") echo "4" ;;
                "improvement"|"improv") echo "5" ;;
                "refactoring"|"ref") echo "6" ;;
                *) echo "1" ;; # По умолчанию TASK
            esac
            ;;
        5)
            # Уровень 5: Решения
            case "$type_lower" in
                "solution"|"sol") echo "1" ;;
                "code") echo "2" ;;
                "bug") echo "3" ;;
                "algorithm"|"alg") echo "4" ;;
                "configuration"|"conf") echo "5" ;;
                "script") echo "6" ;;
                *) echo "1" ;; # По умолчанию SOL
            esac
            ;;
        6)
            # Уровень 6: Отчеты
            case "$type_lower" in
                "report") echo "1" ;;
                "metric") echo "2" ;;
                "analytics"|"analyt") echo "3" ;;
                "log") echo "4" ;;
                "backup") echo "5" ;;
                "audit") echo "6" ;;
                *) echo "1" ;; # По умолчанию REPORT
            esac
            ;;
        *)
            # Общие типы (номера 7-99) - для любого уровня
            case "$type_lower" in
                "architecture"|"arch") echo "7" ;;
                "documentation"|"doc") echo "8" ;;
                "specification"|"spec") echo "9" ;;
                "design") echo "10" ;;
                "plan") echo "11" ;;
                "process"|"proc") echo "12" ;;
                "review"|"rev") echo "13" ;;
                "tutorial"|"tut") echo "14" ;;
                "guide") echo "15" ;;
                "kanban") echo "16" ;;
                "tech-debt"|"debt") echo "17" ;;
                "migration"|"mig") echo "18" ;;
                *) echo "99" ;; # OTHER
            esac
            ;;
    esac
}

# Определить иерархию по контексту
determine_hierarchy() {
    local parent_id="$1"
    local level="$2"
    local type="$3"
    
    # Если есть родитель - берем его иерархию
    if [ -n "$parent_id" ]; then
        echo "$parent_id" | cut -d'-' -f2
        return 0
    fi
    
    # Если нет родителя - определяем по уровню и типу
    case "$level" in
        1)
            # Уровень 1: всегда проект UCH
            echo "$HIERARCHY_UCH_PROJECT"
            ;;
        2)
            # Уровень 2: линии развития
            case "$type" in
                "line"|"documentation") echo "$HIERARCHY_DOCS_LINE" ;;
                "blog"|"platform") echo "$HIERARCHY_BLOG_LINE" ;;
                "studio"|"audio") echo "$HIERARCHY_STUDIO_LINE" ;;
                *) echo "$HIERARCHY_DOCS_LINE" ;; # По умолчанию
            esac
            ;;
        3|4|5|6)
            # Уровни 3-6: по умолчанию документация
            echo "$HIERARCHY_DOCS_LINE"
            ;;
        *)
            echo "$HIERARCHY_DOCS_LINE" # Фолбэк
            ;;
    esac
}

# Найти следующий доступный номер в иерархии
find_next_available_number() {
    local level="$1"
    local hierarchy="$2"
    local pattern_type="$3"  # "single" или "double"
    
    case "$level" in
        1|2|3)
            # Уровни 1-3: ищем максимальный номер типа X в X-XXXXXX-X
            find . -name "${level}-${hierarchy}-*.md" -type f ! -path "*/backup-*" 2>/dev/null | \
                sed "s/.*${level}-${hierarchy}-//" | cut -d'_' -f1 | \
                while read id_part; do
                    # Извлекаем номер (последние цифры)
                    echo "$id_part" | grep -o '[0-9]*$'
                done | sort -n | tail -1
            ;;
        4)
            # Уровень 4: ищем максимальный 4-значный номер в 4-XXXXXX-XXXX-X
            find . -name "4-${hierarchy}-*.md" -type f ! -path "*/backup-*" 2>/dev/null | \
                sed "s/.*4-${hierarchy}-//" | cut -d'-' -f1 | \
                sort -n | tail -1
            ;;
        5)
            # Уровень 5: ищем максимальный 2-значный номер решения
            # Нужен parent_id чтобы знать задачу
            echo "01"  # По умолчанию
            ;;
        6)
            # Уровень 6: ищем максимальный 3-значный номер отчета
            find . -name "6-${hierarchy}-*.md" -type f ! -path "*/backup-*" 2>/dev/null | \
                sed "s/.*6-${hierarchy}-//" | cut -d'-' -f1 | \
                sort -n | tail -1
            ;;
        *)
            echo "1"
            ;;
    esac
}

# ============================================================================
# ОСНОВНЫЕ ФУНКЦИИ ГЕНЕРАЦИИ
# ============================================================================

# Генерация ID для нового документа
generate_id() {
    local level="$1"
    local type="$2"
    local parent_id="$3"
    
    # 1. Определяем иерархию
    local hierarchy=$(determine_hierarchy "$parent_id" "$level" "$type")
    
    # 2. Определяем номер типа
    local type_number=$(get_type_number "$type" "$level")
    
    # 3. Определяем следующий доступный номер
    local next_number=""
    
    case "$level" in
        1|2|3)
            # Уровни 1-3: X-XXXXXX-X
            local last_num=$(find_next_available_number "$level" "$hierarchy" "single")
            if [ -z "$last_num" ]; then
                next_number="1"
            else
                next_number=$((last_num + 1))
            fi
            echo "${level}-${hierarchy}-${next_number}${type_number}"
            ;;
        4)
            # Уровень 4: X-XXXXXX-XXXX-X
            local last_task=$(find_next_available_number "4" "$hierarchy" "double")
            if [ -z "$last_task" ]; then
                next_number="0100"
            else
                next_number=$(printf "%04d" $((last_task + 100)))
            fi
            echo "4-${hierarchy}-${next_number}-${type_number}"
            ;;
        5)
            # Уровень 5: X-XXXXXX-XXXX-X (наследует номер задачи)
            if [ -z "$parent_id" ]; then
                echo "Ошибка: для уровня 5 нужен parent_id (задача)"
                return 1
            fi
            
            # Извлекаем номер задачи из parent_id
            local task_number=$(echo "$parent_id" | cut -d'-' -f3)
            local solution_num="01"  # По умолчанию первое решение
            
            # Можно улучшить: искать существующие решения для этой задачи
            echo "5-${hierarchy}-${task_number}${solution_num}-${type_number}"
            ;;
        6)
            # Уровень 6: X-XXXXXX-XXXX-X
            local last_report=$(find_next_available_number "6" "$hierarchy" "triple")
            if [ -z "$last_report" ]; then
                next_number="001"
            else
                next_number=$(printf "%03d" $((last_report + 1)))
            fi
            echo "6-${hierarchy}-${next_number}-${type_number}"
            ;;
        *)
            echo "Ошибка: Неизвестный уровень $level"
            return 1
            ;;
    esac
}

# Генерация имени файла в правильном формате
generate_filename() {
    local id="$1"
    local type="$2"
    local name="$3"
    local level="$4"
    
    # Преобразуем тип в короткий формат
    local short_type=""
    case "$type" in
        "project"|"prod"|"proj") short_type="PROD" ;;
        "line") short_type="LINE" ;;
        "component"|"comp") short_type="COMP" ;;
        "task") short_type="TASK" ;;
        "feature"|"feat") short_type="FEAT" ;;
        "solution"|"sol") short_type="SOL" ;;
        "code") short_type="CODE" ;;
        "architecture"|"arch") short_type="ARCH" ;;
        "documentation"|"doc") short_type="DOC" ;;
        "specification"|"spec") short_type="SPEC" ;;
        "report") short_type="REPORT" ;;
        "metric") short_type="METRIC" ;;
        "snapshot"|"snap") short_type="SNAP" ;;
        "idea") short_type="IDEA" ;;
        *) short_type="DOC" ;; # Фолбэк
    esac
    
    # Преобразуем имя в slug
    local slug=$(echo "$name" | \
        tr '[:upper:]' '[:lower:]' | \
        tr ' ' '_' | \
        sed 's/[^a-zA-Z0-9_]//g' | \
        sed 's/__*/_/g' | \
        sed 's/^_//' | sed 's/_$//')
    
    # Формируем имя файла
    if [ "$level" -eq 6 ]; then
        # Уровень 6: с датой
        local date_part=$(date +%Y%m%d)
        echo "${id}_${short_type}_${date_part}.md"
    else
        # Уровни 1-5: со slug
        echo "${id}_${short_type}_${slug}.md"
    fi
}

# ============================================================================
# ТЕСТОВЫЕ ФУНКЦИИ
# ============================================================================

# Протестировать генерацию
test_id_generation() {
    echo "🧪 ТЕСТ ГЕНЕРАЦИИ ID ПО СИСТЕМЕ 3-010402-1"
    echo "=========================================="
    
    echo "1. Проект UCH (уровень 1, PROJ):"
    id1=$(generate_id 1 "project" "")
    echo "   ID: $id1"
    echo "   Имя файла: $(generate_filename "$id1" "project" "Universal Creative Hub" 1)"
    
    echo ""
    echo "2. Линия документации (уровень 2, LINE):"
    id2=$(generate_id 2 "line" "")
    echo "   ID: $id2"
    echo "   Имя файла: $(generate_filename "$id2" "line" "Documentation System" 2)"
    
    echo ""
    echo "3. Компонент системы нумерации (уровень 3, COMP):"
    id3=$(generate_id 3 "component" "2-010400-1")
    echo "   ID: $id3"
    echo "   Имя файла: $(generate_filename "$id3" "component" "Numbering System" 3)"
    
    echo ""
    echo "4. Задача аудита (уровень 4, TASK):"
    id4=$(generate_id 4 "task" "3-010401-1")
    echo "   ID: $id4"
    echo "   Имя файла: $(generate_filename "$id4" "task" "Аудит несоответствий" 4)"
    
    echo ""
    echo "5. Решение (уровень 5, SOL):"
    id5=$(generate_id 5 "solution" "4-010400-0100-1")
    echo "   ID: $id5"
    echo "   Имя файла: $(generate_filename "$id5" "solution" "Алгоритм корректировки" 5)"
    
    echo ""
    echo "✅ Тест завершен"
}