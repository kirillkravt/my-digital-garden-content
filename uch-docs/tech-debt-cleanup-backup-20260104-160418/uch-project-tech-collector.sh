#!/bin/bash
# uch-project-tech-collector.sh - сбор технологического стека проекта UCH

echo "=== UCH ТЕХНОЛОГИЧЕСКИЙ СТЕК ПРОЕКТА ==="
echo "Версия: 0.6.0"
echo "Дата: $(date)"
echo ""

UCH_BACKEND="/Users/kirillkravcov/UniversalCreativeHub/uch-backend"
UCH_DOCS="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"

echo "🔍 Анализ технологического стека проекта..."
echo ""

cd "$UCH_BACKEND" || { echo "❌ Не могу перейти в $UCH_BACKEND"; exit 1; }

# 1. Сбор версий через requirements.txt
echo "1. Анализ зависимостей проекта..."

if [ -f "requirements.txt" ]; then
    echo "  ✅ requirements.txt найден"
    
    DJANGO_VERSION=$(grep -i "django==" requirements.txt | head -1 | cut -d'=' -f3)
    MARKDOWNX_VERSION=$(grep -i "django-markdownx==" requirements.txt | head -1 | cut -d'=' -f3)
    TAGGIT_VERSION=$(grep -i "django-taggit==" requirements.txt | head -1 | cut -d'=' -f3)
    
    echo "  • Django: ${DJANGO_VERSION:-не указан}"
    echo "  • django-markdownx: ${MARKDOWNX_VERSION:-не указан}"
    echo "  • django-taggit: ${TAGGIT_VERSION:-не указан}"
    
    DEP_COUNT=$(grep -v "^#" requirements.txt | grep -v "^$" | wc -l | tr -d ' ')
    echo "  • Всего зависимостей: $DEP_COUNT"
else
    echo "  ❌ requirements.txt не найден"
    DJANGO_VERSION="не найден"
fi
echo ""

# 2. Frontend зависимости
echo "2. Анализ frontend зависимостей..."
FRONTEND_DIR="$UCH_BACKEND/uch/apps/studio/frontend"

if [ -d "$FRONTEND_DIR" ] && [ -f "$FRONTEND_DIR/package.json" ]; then
    echo "  ✅ package.json найден в frontend"
    
    REACT_VERSION=$(grep '"react"' "$FRONTEND_DIR/package.json" | head -1 | sed 's/.*"react"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
    echo "  • React: ${REACT_VERSION:-не указан}"
else
    echo "  ⚠️ package.json не найден"
    REACT_VERSION="не найден"
fi
echo ""

# 3. Проверка Docker
echo "3. Проверка Docker конфигурации..."
if [ -f "docker-compose.yml" ]; then
    echo "  ✅ docker-compose.yml найден"
    DOCKER_COMPOSE="найден"
else
    echo "  ⚠️ docker-compose.yml не найден"
    DOCKER_COMPOSE="не найден"
fi
echo ""

# 4. Возвращаемся и сохраняем
cd "$UCH_DOCS" || exit 1

TIMESTAMP=$(date -Iseconds)
JSON_FILE="uch-project-tech-stack.json"

cat > "$JSON_FILE" << JSON_EOF
{
  "report": {
    "id": "90-04-tech-project",
    "name": "Технологический стек проекта UCH",
    "version": "0.6.0",
    "generated_at": "$TIMESTAMP",
    "type": "tech_stack_project"
  },
  "django_dependencies": {
    "django": "$DJANGO_VERSION",
    "django_markdownx": "$MARKDOWNX_VERSION",
    "django_taggit": "$TAGGIT_VERSION",
    "requirements_file_exists": "$([ -f "$UCH_BACKEND/requirements.txt" ] && echo "true" || echo "false")",
    "total_dependencies": $DEP_COUNT
  },
  "frontend_dependencies": {
    "react": "$REACT_VERSION",
    "package_json_exists": "$([ -f "$FRONTEND_DIR/package.json" ] && echo "true" || echo "false")"
  },
  "containerization": {
    "docker_compose_exists": "$([ -f "$UCH_BACKEND/docker-compose.yml" ] && echo "true" || echo "false")",
    "docker_version": "$(docker --version 2>/dev/null | head -c 50 || echo "не найден")"
  }
}
JSON_EOF

echo "✅ Технологический стек проекта сохранен в: $JSON_FILE"
echo ""
echo "📋 ТЕХНОЛОГИЧЕСКАЯ СВОДКА ПРОЕКТА:"
echo "• Django версия: $DJANGO_VERSION"
echo "• React версия: $REACT_VERSION"
echo "• Docker Compose: $([ -f "$UCH_BACKEND/docker-compose.yml" ] && echo "✅ настроен" || echo "⚠️ не настроен")"