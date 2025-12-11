# ВАЖНО: Замените VULTUM_PATH на реальный путь к вашему vault
VULTUM_PATH="/Users/kirillkravcov/obsidian/my-digital-garden-content"  # ← ЗАМЕНИТЕ ЭТО!

# Создаем backup текущего settings.py
cp uch/settings.py uch/settings.py.backup_vault_config

# Обновляем настройки Obsidian для вашего vault
cat > /tmp/update_vault_settings.py << EOF
import os
import re

# Читаем текущий settings.py
with open('uch/settings.py', 'r') as f:
    content = f.read()

# Удаляем старые настройки Obsidian (если есть)
content = re.sub(r'# =+[\s\S]*?# Obsidian Integration Settings[\s\S]*?(?=\n# =|\Z)', '', content)

# Добавляем новые настройки для вашего vault
vault_settings = '''
# ==============================================================================
# Obsidian Integration Settings
# ==============================================================================

# Путь к существующему Obsidian vault для мониторинга
OBSIDIAN_WATCH_DIR = r"''' + VULTUM_PATH + '''"

# Автор по умолчанию для импортируемых статей
OBSIDIAN_DEFAULT_AUTHOR = 'admin'

# Директория для архивации обработанных файлов (внутри проекта)
OBSIDIAN_ARCHIVE_DIR = os.path.join(BASE_DIR, 'obsidian_archive')

# Автоматически создаем только архивную директорию
os.makedirs(OBSIDIAN_ARCHIVE_DIR, exist_ok=True)

print(f"✅ Настроен vault: {OBSIDIAN_WATCH_DIR}")
print(f"✅ Архив будет создан: {OBSIDIAN_ARCHIVE_DIR}")
'''

# Добавляем настройки в конец файла
if '# ==============================================================================' in content:
    # Вставляем перед последним разделом
    parts = content.split('# ==============================================================================')
    new_content = parts[0] + vault_settings + '# ==============================================================================' + parts[-1]
else:
    new_content = content + vault_settings

# Записываем обновленный файл
with open('uch/settings.py', 'w') as f:
    f.write(new_content)

print("✅ Настройки обновлены для вашего vault")
EOF

# Запускаем скрипт обновления (после того как замените VULTUM_PATH)
python /tmp/update_vault_settings.py