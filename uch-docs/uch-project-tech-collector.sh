#!/bin/bash
# uch-project-tech-collector.sh - сбор технологий проекта UCH с виртуальным окружением

echo "=== UCH ТЕХНОЛОГИЧЕСКИЙ СТЕК ПРОЕКТА ==="
echo "Версия: 0.5.0"
echo "Дата: $(date)"
echo ""

UCH_BACKEND="/Users/kirillkravcov/UniversalCreativeHub/uch-backend"
UCH_DOCS="/Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs"

echo "🔍 Анализ технологического стека проекта..."
echo ""

# Проверка виртуального окружения проекта
echo "1. Проверка виртуального окружения Django..."
cd "$UCH_BACKEND" || { echo "❌ Не могу перейти в $UCH_BACKEND"; exit 1; }

# Ищем активированное виртуальное окружение
if [ -n "$VIRTUAL_ENV" ]; then
    echo "  ✅ Виртуальное окружение активно: $(basename $VIRTUAL_ENV)"
    VENV_PATH="$VIRTUAL_ENV"
else
    # Ищем venv в проекте
    if [ -d "venv" ]; then
        VENV_PATH="$UCH_BACKEND/venv"
        echo "  ⚠️ Виртуальное окружение найдено (venv), но не активировано"
    elif [ -d ".venv" ]; then
        VENV_PATH="$UCH_BACKEND/.venv"
        echo "  ⚠️ Виртуальное окружение найдено (.venv), но не активировано"
    else
        VENV_PATH="не найден"
        echo "  ❌ Виртуальное окружение не найдено в проекте"
    fi
fi
echo ""

# Сбор версий через requirements.txt
echo "2. Анализ зависимостей проекта..."

if [ -f "requirements.txt" ]; then
    echo "  ✅ requirements.txt найден"
    
    # Основные зависимости
    DJANGO_VERSION=$(grep -i "django==" requirements.txt | head -1 | sed 's/.*==//')
    MARKDOWNX_VERSION=$(grep -i "django-markdownx==" requirements.txt | head -1 | sed 's/.*==//')
    TAGGIT_VERSION=$(grep -i "django-taggit==" requirements.txt | head -1 | sed 's/.*==//')
    SLUGIFY_VERSION=$(grep -i "python-slugify==" requirements.txt | head -1 | sed 's/.*==//')
    
    echo "  • Django: ${DJANGO_VERSION:-не указан}"
    echo "  • django-markdownx: ${MARKDOWNX_VERSION:-не указан}"
    echo "  • django-taggit: ${TAGGIT_VERSION:-не указан}"
    echo "  • python-slugify: ${SLUGIFY_VERSION:-не указан}"
    
    # Подсчет зависимостей
    DEP_COUNT=$(wc -l < requirements.txt)
    echo "  • Всего зависимостей: $DEP_COUNT"
else
    echo "  ❌ requirements.txt не найден"
    DJANGO_VERSION="не найден"
fi
echo ""

# Frontend зависимости
echo "3. Анализ frontend зависимостей..."
FRONTEND_DIR="$UCH_BACKEND/uch/apps/studio/frontend"

if [ -d "$FRONTEND_DIR" ] && [ -f "$FRONTEND_DIR/package.json" ]; then
    echo "  ✅ package.json найден в frontend"
    
    REACT_VERSION=$(grep '"react"' "$FRONTEND_DIR/package.json" | head -1 | sed 's/.*"react": "\([^"]*\)".*/\1/')
    STRUDEL_CORE_VERSION=$(grep '"@strudel/core"' "$FRONTEND_DIR/package.json" | head -1 | sed 's/.*"@strudel/core": "\([^"]*\)".*/\1/')
    STRUDEL_WEBAUDIO_VERSION=$(grep '"@strudel/webaudio"' "$FRONTEND_DIR/package.json" | head -1 | sed 's/.*"@strudel/webaudio": "\([^"]*\)".*/\1/')
    
    echo "  • React: ${REACT_VERSION:-не указан}"
    echo "  • @strudel/core: ${STRUDEL_CORE_VERSION:-не указан}"
    echo "  • @strudel/webaudio: ${STRUDEL_WEBAUDIO_VERSION:-не указан}"
else
    echo "  ⚠️ package.json не найден"
    REACT_VERSION="не найден"
fi
echo ""

# Проверка Docker
echo "4. Проверка Docker конфигурации..."
if [ -f "docker-compose.yml" ]; then
    echo "  ✅ docker-compose.yml найден"
    
    # Проверяем версию Docker Compose
    if command -v docker-compose &> /dev/null; then
        DOCKER_COMPOSE_VERSION=$(docker-compose --version 2>/dev/null | head -1)
        echo "  • Docker Compose: $(echo $DOCKER_COMPOSE_VERSION | head -c 40)"
    fi
fi
echo ""

# Возвращаемся в uch-docs и сохраняем
cd "$UCH_DOCS" || exit 1

TIMESTAMP=$(date -Iseconds)
JSON_FILE="uch-project-tech-stack.json"

cat > "$JSON_FILE" << EOF
{
  "report": {
    "id": "90-04-tech-project",
    "name": "Технологический стек проекта UCH",
    "version": "0.5.0",
    "generated_at": "$TIMESTAMP",
    "type": "tech_stack_project"
  },
  "virtual_environment": {
    "active": "$([ -n "$VIRTUAL_ENV" ] && echo "true" || echo "false")",
    "path": "$VENV_PATH",
    "found_in_project": "$([ "$VENV_PATH" != "не найден" ] && echo "true" || echo "false")"
  },
  "django_dependencies": {
    "django": "$DJANGO_VERSION",
    "django_markdownx": "$MARKDOWNX_VERSION",
    "django_taggit": "$TAGGIT_VERSION",
    "python_slugify": "$SLUGIFY_VERSION",
    "requirements_file_exists": "$([ -f "$UCH_BACKEND/requirements.txt" ] && echo "true" || echo "false")",
    "total_dependencies": "$DEP_COUNT"
  },
  "frontend_dependencies": {
    "react": "$REACT_VERSION",
    "strudel_core": "$STRUDEL_CORE_VERSION",
    "strudel_webaudio": "$STRUDEL_WEBAUDIO_VERSION",
    "package_json_exists": "$([ -f "$FRONTEND_DIR/package.json" ] && echo "true" || echo "false")"
  },
  "containerization": {
    "docker_compose_exists": "$([ -f "$UCH_BACKEND/docker-compose.yml" ] && echo "true" || echo "false")",
    "docker_version": "$(docker --version 2>/dev/null | head -c 50 || echo "не найден")"
  },
  "paths": {
    "project_root": "$UCH_BACKEND",
    "frontend_dir": "$FRONTEND_DIR",
    "docs_dir": "$UCH_DOCS"
  }
}
EOF

echo "✅ Технологический стек проекта сохранен в: $JSON_FILE"
echo ""
echo "📋 ТЕХНОЛОГИЧЕСКАЯ СВОДКА ПРОЕКТА:"
echo "• Django версия: $DJANGO_VERSION"
echo "• React версия: $REACT_VERSION"
echo "• Виртуальное окружение: $([ "$VENV_PATH" != "не найден" ] && echo "✅ найдено" || echo "❌ не найдено")"
echo "• Docker Compose: $([ -f "$UCH_BACKEND/docker-compose.yml" ] && echo "✅ настроен" || echo "⚠️ не настроен")"
echo ""
echo "🚀 СЛЕДУЮЩИЙ ШАГ:"
echo "Запустите оба сборщика для полной картины проекта"