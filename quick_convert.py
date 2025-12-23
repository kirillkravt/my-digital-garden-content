#!/usr/bin/env python3
"""
Быстрая конвертация с предустановками
"""

import subprocess
import sys

PRESETS = {
    'small': {'width': 600, 'font': 12, 'compact': True},
    'medium': {'width': 900, 'font': 14, 'compact': False},
    'large': {'width': 1200, 'font': 16, 'compact': False},
    'wide': {'width': 1500, 'font': 14, 'orientation': 'LR'},
}

if __name__ == "__main__":
    if len(sys.argv) < 3:
        print("Использование: python quick_convert.py <файл> <пресет>")
        print("Доступные пресеты:", ', '.join(PRESETS.keys()))
        sys.exit(1)
    
    file_path = sys.argv[1]
    preset = sys.argv[2].lower()
    
    if preset not in PRESETS:
        print(f"Неизвестный пресет: {preset}")
        sys.exit(1)
    
    config = PRESETS[preset]
    cmd = ['python', 'convert_diagrams.py', file_path]
    
    if 'width' in config:
        cmd.extend(['--width', str(config['width'])])
    if 'font' in config:
        cmd.extend(['--font-size', str(config['font'])])
    if 'orientation' in config:
        cmd.extend(['--orientation', config['orientation']])
    if config.get('compact'):
        cmd.append('--compact')
    
    subprocess.run(cmd)