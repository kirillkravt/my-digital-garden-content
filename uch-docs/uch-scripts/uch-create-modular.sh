#!/bin/bash
# Легкий интерфейс для модульной системы

echo "=== Запуск модульной системы UCH ==="

SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

if [ ! -f "$SCRIPT_DIR/uch-scripts/main.sh" ]; then
    echo "❌ Ошибка: Модульная система не найдена"
    echo "Текущая директория: $(pwd)"
    echo "Ищем: $SCRIPT_DIR/uch-scripts/main.sh"
    exit 1
fi

# Запускаем модульную систему
"$SCRIPT_DIR/uch-scripts/main.sh" "$@"