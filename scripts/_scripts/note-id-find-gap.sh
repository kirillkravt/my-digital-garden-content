#!/bin/bash
# Скрипт для поиска первого свободного ID (заполняет пропуски)

set -e

if [ -z "$1" ]; then
    echo "Использование: $0 <parent_id>"
    exit 1
fi

PARENT_ID="$1"
cd /Users/kirillkravcov/obsidian/my-digital-garden-content/uch-docs

# Собираем все существующие child IDs
declare -a existing_ids=()
for file in *.md; do
    if [[ "$file" =~ ^${PARENT_ID}-([0-9a-fA-F]{2})\ -\ .*\.md$ ]]; then
        existing_ids+=("${BASH_REMATCH[1]}")
    fi
done

# Сортируем hex значения как числа
sorted_ids=($(printf "%s\n" "${existing_ids[@]}" | while read id; do
    printf "%d %s\n" $((16#$id)) "$id"
done | sort -n | awk '{print $2}'))

echo "Существующие IDs для $PARENT_ID: ${sorted_ids[*]}"

# Ищем первый пропуск от 01 до ff
for ((i=1; i<=255; i++)); do
    expected_id=$(printf "%02x" $i)
    found=0
    
    for existing in "${sorted_ids[@]}"; do
        if [ "$existing" = "$expected_id" ]; then
            found=1
            break
        fi
    done
    
    if [ $found -eq 0 ]; then
        echo "Первый свободный ID: $PARENT_ID-$expected_id"
        exit 0
    fi
done

# Если все заняты до ff, берем следующий
last_id=${sorted_ids[-1]}
if [ -n "$last_id" ]; then
    next_val=$((16#$last_id + 1))
    next_id=$(printf "%02x" $next_val)
    echo "Все IDs до $last_id заняты, следующий: $PARENT_ID-$next_id"
else
    echo "Первый ID: $PARENT_ID-01"
fi
