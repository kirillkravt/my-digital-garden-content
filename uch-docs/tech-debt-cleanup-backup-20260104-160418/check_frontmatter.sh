#!/bin/bash
# Скрипт проверки frontmatter без изменений

echo "=== ПРОВЕРКА FRONTMATTER (ТОЛЬКО ЧТЕНИЕ) ==="
echo ""

total=0
good=0
problems=0
no_frontmatter_list=""
bad_frontmatter_list=""

for file in *.md; do
    # Пропускаем backup файлы
    if [[ "$file" == *".backup"* ]] || [[ "$file" == *"backup-"* ]]; then
        continue
    fi
    
    total=$((total + 1))
    
    # Проверяем первую строку
    first_line=$(head -1 "$file" 2>/dev/null)
    
    if [ "$first_line" != "---" ]; then
        problems=$((problems + 1))
        no_frontmatter_list="$no_frontmatter_list\n❌ $file"
    else
        # Проверяем закрывающий ---
        frontmatter_end=$(grep -n "^---$" "$file" | head -2 | tail -1 | cut -d: -f1)
        
        if [ -z "$frontmatter_end" ] || [ "$frontmatter_end" -le 1 ]; then
            problems=$((problems + 1))
            bad_frontmatter_list="$bad_frontmatter_list\n❌ $file - Нет закрывающего ---"
        else
            # Проверяем обязательные поля в frontmatter
            missing_fields=""
            
            for field in id name type; do
                if ! head -$frontmatter_end "$file" | grep -q "^$field:"; then
                    missing_fields="$missing_fields $field"
                fi
            done
            
            if [ -n "$missing_fields" ]; then
                problems=$((problems + 1))
                bad_frontmatter_list="$bad_frontmatter_list\n⚠️  $file - Нет полей:$missing_fields"
            else
                good=$((good + 1))
            fi
        fi
    fi
done

echo "📊 СТАТИСТИКА:"
echo "Всего файлов: $total"
echo "Корректный frontmatter: $good"
echo "Проблемный frontmatter: $problems"
echo ""

if [ $problems -gt 0 ]; then
    echo "=== ФАЙЛЫ С ПРОБЛЕМАМИ: ==="
    echo -e "$no_frontmatter_list"
    echo -e "$bad_frontmatter_list"
    echo ""
    echo "💡 Для исправления запустите: ./fix_frontmatter.sh"
else
    echo "✅ Все файлы имеют корректный frontmatter!"
fi
