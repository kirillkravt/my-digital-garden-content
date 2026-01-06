#!/bin/bash
# Легкий интерфейс для модульной системы

echo "=== Запуск модульной системы UCH ==="

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$SCRIPT_DIR/uch-scripts/main.sh" ]; then
    echo "❌ Ошибка: Модульная система не найдена"
    echo "Текущая директория: $SCRIPT_DIR"
    echo "Ищем: $SCRIPT_DIR/uch-scripts/main.sh"
    echo ""
    echo "Содержимое директории:"
    ls -la "$SCRIPT_DIR/" || echo "Не удалось посмотреть директорию"
    exit 1
fi

# Запускаем модульную систему
"$SCRIPT_DIR/uch-scripts/main.sh" "$@"