import sqlite3
import os
import glob
import re
from datetime import datetime

print("🔍 Сканируем документы в:", os.getcwd())

# Подключаемся к базе
conn = sqlite3.connect('uch-metadata.db')
cursor = conn.cursor()

# Создаем таблицу
cursor.execute('''
CREATE TABLE IF NOT EXISTS documents (
    id TEXT PRIMARY KEY,
    name TEXT,
    type TEXT,
    level INTEGER,
    status TEXT DEFAULT 'active',
    parent_id TEXT,
    file_path TEXT,
    created TEXT,
    updated TEXT
)
''')

# Очищаем таблицу перед заполнением
cursor.execute("DELETE FROM documents")
print("🧹 Таблица очищена")

# Ищем все .md файлы, исключая backup и temp
md_files = glob.glob("*.md")
print(f"📄 Найдено .md файлов: {len(md_files)}")

# Паттерн для HEX ID: уровни 1-5,6,Z
id_pattern = re.compile(r'^([0-9Z]-[0-9A-F]{6}(?:-[0-9A-F]{4})?(?:-[0-9]+)?(?:-\d+)?)_.*\.md$')

count = 0
skipped = 0
backup_skipped = 0

for file_path in md_files:
    # Пропускаем явные бэкапы
    if 'backup' in file_path.lower() or 'temp' in file_path.lower() or '~' in file_path:
        backup_skipped += 1
        continue
    
    # Парсим ID из имени файла
    match = id_pattern.match(file_path)
    
    if match:
        doc_id = match.group(1)
        
        # Определяем уровень по первой цифре ID
        first_char = doc_id[0]
        if first_char == '1':
            level = 1
        elif first_char == '2':
            level = 2
        elif first_char == '3':
            level = 3
        elif first_char == '4':
            level = 4
        elif first_char == '5':
            level = 5
        elif first_char == '6':
            level = 6
        elif first_char == 'Z':
            level = 0
        else:
            level = -1  # неизвестный
        
        # Пытаемся извлечь тип из имени (часть после последнего _)
        name_parts = file_path.replace('.md', '').split('_')
        if len(name_parts) > 1:
            doc_type = name_parts[-1]  # последняя часть как тип
            name = '_'.join(name_parts[:-1])  # остальное как имя
        else:
            doc_type = 'UNKNOWN'
            name = name_parts[0]
        
        # Определяем родителя (похожий ID, но короче)
        parent_id = None
        if level > 1 and level < 6:
            # Для уровней 2-5 пытаемся найти родителя
            parts = doc_id.split('-')
            if len(parts) >= 3:
                if level == 2:
                    parent_id = f"{parts[0]}-{parts[1]}-1"  # уровень 1
                elif level == 3:
                    parent_id = f"{parts[0]}-{parts[1]}-{parts[2]}"  # уровень 2
                elif level == 4:
                    parent_id = f"{parts[0]}-{parts[1]}-{parts[2]}"  # уровень 3
                elif level == 5:
                    parent_id = f"{parts[0]}-{parts[1]}-{parts[2]}-{parts[3]}"  # уровень 4
        
        # Вставляем в базу
        cursor.execute('''
        INSERT OR REPLACE INTO documents 
        (id, name, type, level, parent_id, file_path, created, updated)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        ''', (
            doc_id,
            name[:100],
            doc_type,
            level,
            parent_id,
            file_path,
            datetime.now().isoformat(),
            datetime.now().isoformat()
        ))
        count += 1
    else:
        skipped += 1

conn.commit()

print(f"\n📊 Результаты:")
print(f"  ✅ Добавлено документов: {count}")
print(f"  ⏭️  Пропущено (не соответствуют формату): {skipped}")
print(f"  💾 Пропущено бэкапов: {backup_skipped}")

# Покажем статистику
print(f"\n📈 Статистика по уровням:")
cursor.execute("SELECT level, COUNT(*) FROM documents GROUP BY level ORDER BY level")
for row in cursor.fetchall():
    level_name = {
        0: "Z (идеи)", 
        1: "Проекты", 
        2: "Линии", 
        3: "Компоненты", 
        4: "Задачи", 
        5: "Решения", 
        6: "Отчеты",
        -1: "Неизвестный"
    }.get(row[0], str(row[0]))
    print(f"  Уровень {row[0]} ({level_name}): {row[1]}")

print(f"\n📑 Статистика по типам (первые 10):")
cursor.execute("SELECT type, COUNT(*) FROM documents GROUP BY type ORDER BY COUNT(*) DESC LIMIT 10")
for row in cursor.fetchall():
    print(f"  {row[0]}: {row[1]}")

conn.close()
print(f"\n✅ База создана: uch-metadata.db")
