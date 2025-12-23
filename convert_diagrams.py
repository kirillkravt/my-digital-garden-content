#!/usr/bin/env python3
"""
Скрипт для преобразования ASCII диаграмм в Mermaid в Obsidian заметках
"""

import os
import re
import sys
from pathlib import Path

def convert_note(file_path):
    """Конвертирует диаграммы в одной заметке"""
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # Регулярные выражения для поиска диаграмм
    patterns = [
        # Для блоков с подчеркиванием
        (r'```(?:text|plaintext)?\n([A-Z_].*?)\n```', convert_ascii_block),
        # Для таблиц
        (r'\|.*?\|\n\|[-:|]+\|.*?\n(\|.*?\|\n?)+', convert_table_block),
    ]
    
    converted = content
    for pattern, converter in patterns:
        matches = list(re.finditer(pattern, content, re.DOTALL))
        for match in matches:
            original = match.group(0)
            converted_block = converter(original)
            converted = converted.replace(original, converted_block)
    
    return converted

def convert_ascii_block(block):
    """Конвертирует ASCII блок в Mermaid"""
    # Убираем обратные кавычки
    lines = block.strip('`').strip().split('\n')
    
    # Определяем тип диаграммы
    nodes = []
    for line in lines:
        # Ищем слова с заглавных букв или с подчеркиванием
        words = re.findall(r'[A-Z][a-zA-Z0-9_]+', line)
        nodes.extend(words)
    
    if not nodes:
        return block
    
    # Создаем Mermaid диаграмму
    mermaid = "```mermaid\ngraph TD\n"
    for node in set(nodes):
        mermaid += f'    {node}["{node}"]\n'
    
    # Простые связи (можно улучшить логику)
    for i in range(len(nodes)-1):
        mermaid += f'    {nodes[i]} --> {nodes[i+1]}\n'
    
    mermaid += "```"
    return mermaid

def convert_table_block(table):
    """Конвертирует таблицу в Mermaid"""
    lines = table.strip().split('\n')
    if len(lines) < 3:
        return table
    
    headers = [h.strip() for h in lines[0].split('|')[1:-1]]
    mermaid = "```mermaid\ngraph TD\n"
    
    for line in lines[2:]:
        if '|' not in line:
            continue
        cells = [c.strip() for c in line.split('|')[1:-1]]
        if cells:
            node_id = cells[0].replace(' ', '_').replace('-', '_')
            label = cells[0]
            if len(cells) > 1:
                label += f"<br>{cells[1]}"
            mermaid += f'    {node_id}["{label}"]\n'
    
    mermaid += "```"
    return mermaid

def main():
    if len(sys.argv) > 1:
        # Конвертировать указанный файл
        file_path = sys.argv[1]
        if os.path.exists(file_path):
            converted = convert_note(file_path)
            
            # Создаем резервную копию
            backup_path = file_path + '.bak'
            with open(backup_path, 'w', encoding='utf-8') as f:
                with open(file_path, 'r', encoding='utf-8') as original:
                    f.write(original.read())
            
            # Записываем конвертированную версию
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(converted)
            
            print(f"Конвертировано: {file_path}")
            print(f"Резервная копия: {backup_path}")
    else:
        print("Использование: python convert_diagrams.py <путь_к_файлу.md>")

if __name__ == "__main__":
    main()