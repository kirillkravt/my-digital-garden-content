#!/bin/bash
# step3-correct-search.sh - правильный поиск всех вариантов "Общая информация"

echo "=== ПРАВИЛЬНЫЙ ПОИСК ВСЕХ ВАРИАНТОВ 'ОБЩАЯ ИНФОРМАЦИЯ' ==="
echo "Дата: $(date)"
echo ""

cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs || exit 1

echo "🔍 1. Поиск ВСЕХ файлов с любым упоминанием:"
echo "---------------------------------------------"
grep -l -i "общая информация" *.md 2>/dev/null | wc -l
echo ""

echo "🔍 2. Поиск по конкретным уровням ЗАГОЛОВКОВ:"
echo "---------------------------------------------"

# Создаем массив для хранения результатов
declare -a files_with_hashes
declare -a files_with_double_hashes
declare -a files_with_triple_hashes
declare -a files_with_quad_hashes

# Анализируем каждый файл
for file in *.md; do
    if [ -f "$file" ]; then
        # Ищем строки с "общая информация" в любом регистре
        while IFS= read -r line_info; do
            line_num=$(echo "$line_info" | cut -d: -f1)
            line_content=$(echo "$line_info" | cut -d: -f2-)
            
            # Проверяем является ли эта строка заголовком
            if [[ "$line_content" =~ ^#+\ .* ]]; then
                # Определяем уровень заголовка
                if [[ "$line_content" =~ ^####\ .* ]]; then
                    files_with_quad_hashes+=("$file (строка $line_num: $line_content)")
                elif [[ "$line_content" =~ ^###\ .* ]]; then
                    files_with_triple_hashes+=("$file (строка $line_num: $line_content)")
                elif [[ "$line_content" =~ ^##\ .* ]]; then
                    files_with_double_hashes+=("$file (строка $line_num: $line_content)")
                elif [[ "$line_content" =~ ^#\ .* ]]; then
                    files_with_hashes+=("$file (строка $line_num: $line_content)")
                fi
            fi
        done < <(grep -ni "общая информация" "$file" 2>/dev/null)
    fi
done

echo "📊 Результаты поиска:"
echo ""
echo "#### 'Общая информация': ${#files_with_quad_hashes[@]} файлов"
for item in "${files_with_quad_hashes[@]:0:5}"; do
    echo "  • $item"
done
if [ ${#files_with_quad_hashes[@]} -gt 5 ]; then
    echo "  ... и еще $(( ${#files_with_quad_hashes[@]} - 5 ))"
fi
echo ""

echo "### 'Общая информация': ${#files_with_triple_hashes[@]} файлов"
for item in "${files_with_triple_hashes[@]:0:5}"; do
    echo "  • $item"
done
if [ ${#files_with_triple_hashes[@]} -gt 5 ]; then
    echo "  ... и еще $(( ${#files_with_triple_hashes[@]} - 5 ))"
fi
echo ""

echo "## 'Общая информация': ${#files_with_double_hashes[@]} файлов"
for item in "${files_with_double_hashes[@]:0:5}"; do
    echo "  • $item"
done
if [ ${#files_with_double_hashes[@]} -gt 5 ]; then
    echo "  ... и еще $(( ${#files_with_double_hashes[@]} - 5 ))"
fi
echo ""

echo "🔍 3. РУЧНАЯ ПРОВЕРКА СЛУЧАЙНЫХ ФАЙЛОВ:"
echo "---------------------------------------"
echo ""

# Возьмем 5 случайных файлов и посмотрим их структуру
echo "Анализ 5 случайных файлов:"
echo ""

shuf -n 5 <(ls *.md) | while read -r file; do
    if [ -f "$file" ]; then
        echo "📄 $file:"
        echo "Заголовки (первые 20):"
        grep -n "^#\+" "$file" | head -20 | while read -r header_line; do
            echo "  $header_line"
        done
        
        # Проверяем есть ли "общая информация"
        if grep -qi "общая информация" "$file"; then
            echo "  ✅ Содержит 'Общая информация'"
            grep -ni "общая информация" "$file" | while read -r match; do
                echo "    • $match"
            done
        else
            echo "  ❌ Не содержит 'Общая информация'"
        fi
        echo ""
    fi
done

echo "🔍 4. ПРЯМОЙ ПОИСК С ОПРЕДЕЛЕНИЕМ УРОВНЕЙ:"
echo "-----------------------------------------"
echo ""

# Прямой поиск с awk для точного определения
echo "Поиск с awk (более точный):"
echo ""

for file in *.md; do
    if [ -f "$file" ]; then
        # Используем awk для поиска заголовков с "общая информация"
        awk -v filename="$file" '
        /^#+\s+.*[Оо]бщая\s+[Ии]нформация/ {
            printf "📄 %s: строка %d: %s\n", filename, NR, $0
        }
        ' "$file" | head -3
    fi
done | head -20

echo ""
echo "✅ Поиск завершен"