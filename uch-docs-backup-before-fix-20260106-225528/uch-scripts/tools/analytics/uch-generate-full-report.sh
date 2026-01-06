#!/bin/bash
# uch-generate-full-report.sh - полный цикл генерации отчета UCH

echo "=== ПОЛНЫЙ ЦИКЛ ГЕНЕРАЦИИ ОТЧЕТА UCH ==="
echo "Версия: 1.0.0"
echo "Дата: $(date)"
echo "========================================"
echo ""

UCH_DOCS="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"
cd "$UCH_DOCS" || { echo "❌ Не могу перейти в uch-docs: $UCH_DOCS"; exit 1; }

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функции логирования
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Создаем backup предыдущего отчета
create_backup() {
    REPORT_FILE="90-01 - Автоматический отчет состояния UCH.md"
    if [ -f "$REPORT_FILE" ]; then
        BACKUP_DIR="report-backup-$(date +%Y%m%d)"
        mkdir -p "$BACKUP_DIR"
        BACKUP_FILE="$BACKUP_DIR/$(date +%Y%m%d-%H%M%S)-90-01.md"
        cp "$REPORT_FILE" "$BACKUP_FILE"
        log_info "Backup отчета создан: $BACKUP_FILE"
    fi
}

# Основная функция
main() {
    log_info "Начало полного цикла генерации отчета UCH"
    echo ""
    
    # Создаем backup
    create_backup
    
    # 1. СБОР МЕТРИК ПРОЕКТА
    log_info "1. Сбор метрик проекта..."
    if [ -f "uch-metrics-collector.sh" ]; then
        ./uch-metrics-collector.sh
        if [ $? -eq 0 ]; then
            log_success "Метрики собраны успешно"
        else
            log_error "Ошибка при сборе метрик"
            exit 1
        fi
    else
        log_error "Файл uch-metrics-collector.sh не найден"
        exit 1
    fi
    echo ""
    
    # 2. СБОР ТЕХНОЛОГИЧЕСКОГО СТЕКА
    log_info "2. Сбор технологического стека..."
    if [ -f "uch-project-tech-collector.sh" ]; then
        ./uch-project-tech-collector.sh
        if [ $? -eq 0 ]; then
            log_success "Технологический стек собран успешно"
        else
            log_warning "Возможны проблемы при сборе технологий (продолжаем)"
        fi
    else
        log_warning "Файл uch-project-tech-collector.sh не найден (продолжаем)"
    fi
    echo ""
    
    # 3. ГЕНЕРАЦИЯ ОТЧЕТА
    log_info "3. Генерация отчета..."
    if [ -f "uch-report-generator.sh" ]; then
        ./uch-report-generator.sh
        if [ $? -eq 0 ]; then
            log_success "Отчет сгенерирован успешно"
        else
            log_error "Ошибка при генерации отчета"
            exit 1
        fi
    else
        log_error "Файл uch-report-generator.sh не найден"
        exit 1
    fi
    echo ""
    
    # 4. ПРОВЕРКА РЕЗУЛЬТАТОВ
    log_info "4. Проверка результатов..."
    
    # Проверяем созданные файлы
    FILES_CREATED=0
    if [ -f "90-01 - Автоматический отчет состояния UCH.md" ]; then
        log_success "✓ Отчет создан: 90-01 - Автоматический отчет состояния UCH.md"
        FILES_CREATED=$((FILES_CREATED + 1))
    else
        log_error "✗ Отчет не создан"
    fi
    
    if [ -f "uch-metrics-full.json" ]; then
        log_success "✓ Данные метрик: uch-metrics-full.json"
        FILES_CREATED=$((FILES_CREATED + 1))
    fi
    
    if [ -f "uch-project-tech-stack.json" ]; then
        log_success "✓ Данные технологий: uch-project-tech-stack.json"
        FILES_CREATED=$((FILES_CREATED + 1))
    fi
    
    # Статистика
    echo ""
    log_info "СТАТИСТИКА ГЕНЕРАЦИИ:"
    echo "  • Создано файлов: $FILES_CREATED/3"
    echo "  • Время выполнения: $(($(date +%s) - ${START_TIME})) секунд"
    echo "  • Дата генерации: $(date)"
    
    # Быстрая сводка из отчета
    echo ""
    log_info "КРАТКАЯ СВОДКА ИЗ ОТЧЕТА:"
    if [ -f "90-01 - Автоматический отчет состояния UCH.md" ]; then
        echo "  $(grep -A2 "### 📁 ФАЙЛОВАЯ СТРУКТУРА" "90-01 - Автоматический отчет состояния UCH.md" | tail -1)"
        echo "  $(grep -A2 "### 🔧 ТЕХНОЛОГИЧЕСКИЙ СТЕК" "90-01 - Автоматический отчет состояния UCH.md" | tail -1)"
    fi
    
    echo ""
    log_success "✅ ПОЛНЫЙ ЦИКЛ ГЕНЕРАЦИИ ОТЧЕТА ЗАВЕРШЕН!"
    echo ""
    log_info "СЛЕДУЮЩИЕ ШАГИ:"
    echo "  1. Посмотреть отчет: cat '90-01 - Автоматический отчет состояния UCH.md'"
    echo "  2. Настроить автоматизацию: добавить в crontab"
    echo "  3. Проверить данные: cat uch-metrics-full.json"
}

# Засекаем время
START_TIME=$(date +%s)

# Запускаем
main "$@"