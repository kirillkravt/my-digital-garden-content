#!/bin/bash
# Легкий интерфейс для модульной системы

echo "=== Запуск модульной системы UCH ==="

if [ ! -f "uch-scripts/main.sh" ]; then
    echo "❌ Ошибка: Модульная система не найдена"
    echo "Создайте структуру командой: ./setup-modular.sh"
    exit 1
fi

# Запускаем модульную систему
./uch-scripts/main.sh "$@"