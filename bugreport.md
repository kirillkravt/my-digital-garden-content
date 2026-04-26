---
title: "Тест автоматического импорта"
tags: [автоимпорт, тест, watchdog]
category: Тестирование
status: published
---
# Создание редактирвоание файлов

Не срабатвает создание файла если указана директория например
cat > nodes/approval/node.py << 'EOF'
у нас захардкожен путь к корню проекта 
Видимо нужно предусмотреть для таких команд сначала поиск директории по проекту 
и только потом выполнение 
т.е. разбить на 2 шага

2 
Не сработала команда
cat >> /Users/kirillkravcov/UniversalCreativeHub/ai-farm/agents/batuta/api_processes.py << 'EOF'
@router.get("/node-types")
async def get_node_types():
    """Получить список всех доступных типов узлов"""
    from nodes import NodeRegistry
    return {
        "node_types": NodeRegistry.list_all()
    }
EOF

Хотя вывод в буфер скопирован 
с успешным статусом
Ручная проверка показала, что метод не был добавлен




