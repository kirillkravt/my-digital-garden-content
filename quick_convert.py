#!/usr/bin/env python3
"""
Быстрая конвертация с предустановками для Mac
"""

import subprocess
import sys
import os

PRESETS = {
    'small': {'width': 600, 'font': 12, 'compact': True},
    'medium': {'width': 900, 'font': 14, 'compact': False},
    'large': {'width': 1200, 'font': 16, 'compact': False},
    'wide': {'width': 1500, 'font': 14, 'orientation': 'LR'},
}

def get_python_command():
    """Определяем команду для запуска Python"""
    # Пробуем python3
    try:
        subprocess.run(['python3', '--version'], capture_output=True, check=True)
        return 'python3'
    except:
        # Пробуем python
        try:
            subprocess.run(['python', '--version'], capture_output=True, check=True)
            return 'python'
        except:
            # Ищем python в PATH
            for path in ['/usr/bin/python3', '/usr/local/bin/python3', '/opt/homebrew/bin/python3']:
                if os.path.exists(path):
                    return path
            return None

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Использование: python3 quick_convert.py <файл> <пресет>")
        print("Доступные пресеты:", ', '.join(PRESETS.keys()))
        sys.exit(1)
    
    file_path = sys.argv[1]
    preset = sys.argv[2].lower()
    
    if preset not in PRESETS:
        print(f"Неизвестный пресет: {preset}")
        sys.exit(1)
    
    # Проверяем существование файла
    if not os.path.exists(file_path):
        print(f"Ошибка: файл '{file_path}' не найден")
        sys.exit(1)
    
    # Определяем команду Python
    python_cmd = get_python_command()
    if not python_cmd:
        print("Ошибка: Python не найден")
        sys.exit(1)
    
    # Проверяем существование основного скрипта
    main_script = 'convert_diagrams.py'
    if not os.path.exists(main_script):
        print(f"Ошибка: файл '{main_script}' не найден")
        print("Убедитесь, что он в той же папке")
        sys.exit(1)
    
    config = PRESETS[preset]
    cmd = [python_cmd, main_script, file_path]
    
    if 'width' in config:
        cmd.extend(['--width', str(config['width'])])
    if 'font' in config:
        cmd.extend(['--font-size', str(config['font'])])
    if 'orientation' in config:
        cmd.extend(['--orientation', config['orientation']])
    if config.get('compact'):
        cmd.append('--compact')
    
    print(f"Запуск: {' '.join(cmd)}")
    print(f"Пресет: {preset}")
    print(f"Настройки: {config}")
    print("-" * 40)
    
    result = subprocess.run(cmd)
    
    if result.returncode == 0:
        print("\n✅ Конвертация завершена успешно!")
    else:
        print("\n❌ Произошла ошибка при конвертации")