#!/bin/bash
# uch-tech-collector.sh - сборщик данных о технологическом стеке

echo "=== UCH СБОРЩИК ТЕХНОЛОГИЧЕСКОГО СТЕКА ==="
echo "Версия: 0.2.0"
echo "Дата: $(date)"
echo ""

# Инициализация переменных
PYTHON_VERSION="не найден"
DJANGO_VERSION="не найден"
NODE_VERSION="не найден"
REACT_VERSION="не найден"
DOCKER_VERSION="не найден"

# 1. Проверяем Python
if command -v python3 &> /dev/null; then
    PYTHON_VERSION=$(python3 --version 2>/dev/null | awk '{print $2}')
    echo "✅ Python найден: $PYTHON_VERSION"
else
    echo "❌ Python3 не найден"
fi

# 2. Проверяем Django (если Python установлен)
if [ "$PYTHON_VERSION" != "не найден" ]; then
    if python3 -c "import django; print(django.__version__)" 2>/dev/null; then
        DJANGO_VERSION=$(python3 -c "import django; print(django.__version__)" 2>/dev/null)
        echo "✅ Django найден: $DJANGO_VERSION"
    else
        echo "⚠️ Django не найден или не установлен"
    fi
fi

# 3. Проверяем Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version 2>/dev/null)
    echo "✅ Node.js найден: $NODE_VERSION"
else
    echo "⚠️ Node.js не найден"
fi

# 4. Проверяем React версию (если есть package.json)
REACT_PATH="/Users/kirillkravcov/UniversalCreativeHub/uch-backend/uch/apps/studio/frontend/package.json"
if [ -f "$REACT_PATH" ]; then
    if grep -q '"react"' "$REACT_PATH"; then
        REACT_VERSION=$(grep '"react"' "$REACT_PATH" | head -1 | sed 's/.*"react": "\([^"]*\)".*/\1/')
        echo "✅ React найден: $REACT_VERSION"
    else
        echo "⚠️ React не указан в package.json"
    fi
else
    echo "⚠️ package.json не найден по пути: $REACT_PATH"
fi

# 5. Проверяем Docker
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version 2>/dev/null | head -1)
    echo "✅ Docker найден: $(echo $DOCKER_VERSION | head -c 30)..."
else
    echo "⚠️ Docker не найден"
fi

# 6. Сохраняем в JSON
TIMESTAMP=$(date -Iseconds)
JSON_FILE="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs/uch-tech-stack.json"

cat > "$JSON_FILE" << EOF
{
  "report": {
    "id": "90-02-tech",
    "name": "Технологический стек UCH",
    "version": "0.2.0",
    "generated_at": "$TIMESTAMP",
    "type": "tech_stack"
  },
  "tech_stack": {
    "python": "$PYTHON_VERSION",
    "django": "$DJANGO_VERSION",
    "nodejs": "$NODE_VERSION",
    "react": "$REACT_VERSION",
    "docker": "$(echo $DOCKER_VERSION | head -c 50)"
  },
  "checks": {
    "python_available": "$(if [ "$PYTHON_VERSION" != "не найден" ]; then echo "true"; else echo "false"; fi)",
    "django_available": "$(if [ "$DJANGO_VERSION" != "не найден" ]; then echo "true"; else echo "false"; fi)",
    "nodejs_available": "$(if [ "$NODE_VERSION" != "не найден" ]; then echo "true"; else echo "false"; fi)",
    "docker_available": "$(if [ "$DOCKER_VERSION" != "не найден" ]; then echo "true"; else echo "false"; fi)"
  },
  "paths": {
    "uch_docs": "/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs",
    "uch_backend": "/Users/kirillkravcov/UniversalCreativeHub/uch-backend",
    "react_package": "$REACT_PATH"
  }
}
EOF

echo ""
echo "✅ Технологический стек сохранен в: $JSON_FILE"
echo ""
echo "📋 ИТОГО СОБРАНО:"
echo "• Python: $PYTHON_VERSION"
echo "• Django: $DJANGO_VERSION"
echo "• Node.js: $NODE_VERSION"
echo "• React: $REACT_VERSION"
echo "• Docker: $(echo $DOCKER_VERSION | head -c 30)..."
echo ""
echo "🚀 СЛЕДУЮЩИЙ ШАГ:"
echo "1. Запустите: ./uch-tech-collector.sh"
echo "2. Проверьте: cat uch-tech-stack.json"
echo "3. Объединим с первой метрикой"