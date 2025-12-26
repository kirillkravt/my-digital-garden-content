#!/bin/bash

echo "=== ПРОВЕРКА ЦЕЛОСТНОСТИ ССЫЛОК ==="

# Функция для проверки одного файла
check_file_references() {
    local file="$1"
    local fix="${2:-false}"
    
    filename=$(basename "$file")
    echo "Проверяю: $filename"
    
    # Извлекаем ID из имени файла
    if [[ "$filename" =~ ^([0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*) ]]; then
        file_id="${BASH_REMATCH[1]}"
        
        # Проверяем, есть ли у этого файла дочерние документы
        child_files=$(find . -maxdepth 1 -name "${file_id}-*.md" -type f | sort)
        
        if [ -n "$child_files" ]; then
            echo "  Найдено дочерних документов: $(echo "$child_files" | wc -l)"
            
            # Проверяем, все ли дочерние документы есть в списке ссылок
            if grep -q "#### ДОЧЕРНИЕ ДОКУМЕНТЫ" "$file"; then
                # Считаем ссылки в файле
                links_in_file=$(grep -c "\[\[$file_id-" "$file" || true)
                actual_children=$(echo "$child_files" | wc -l | tr -d ' ')
                
                if [ "$links_in_file" -ne "$actual_children" ]; then
                    echo "  ❌ Расхождение: ссылок $links_in_file, реальных дочерних $actual_children"
                    
                    if [ "$fix" = "true" ]; then
                        echo "  Исправляю..."
                        # Создаем новый список ссылок
                        temp_file="${file}.tmp"
                        
                        # Пересоздаем раздел ДОЧЕРНИЕ ДОКУМЕНТЫ
                        awk -v child_files="$child_files" '
                        BEGIN {
                            # Разделяем список файлов по переводам строк
                            split(child_files, files, "\n")
                            rebuilding = 0
                            in_children_section = 0
                        }
                        
                        /#### ДОЧЕРНИЕ ДОКУМЕНТЫ/ {
                            in_children_section = 1
                            rebuilding = 1
                            print $0
                            # Добавляем все ссылки
                            for (i in files) {
                                if (files[i] != "") {
                                    # Извлекаем имя файла без пути
                                    split(files[i], parts, "/")
                                    filename = parts[length(parts)]
                                    # Убираем .md
                                    gsub(/\.md$/, "", filename)
                                    print "- [[" filename "]]"
                                }
                            }
                            next
                        }
                        
                        in_children_section && /^[[:space:]]*Пока нет дочерних документов/ {
                            # Пропускаем
                            next
                        }
                        
                        in_children_section && (/^####/ || /^###/ || /^##/ || /^#/ || /^---/) {
                            in_children_section = 0
                        }
                        
                        { 
                            if (!in_children_section) {
                                print $0
                            }
                        }
                        ' "$file" > "$temp_file"
                        
                        mv "$temp_file" "$file"
                        echo "  ✅ Исправлено"
                    fi
                else
                    echo "  ✅ Все ссылки на месте ($links_in_file)"
                fi
            else
                echo "  ⚠️  Нет раздела ДОЧЕРНИЕ ДОКУМЕНТЫ"
                
                if [ "$fix" = "true" ]; then
                    echo "  Добавляю раздел..."
                    # Добавляем раздел в конец файла (перед --- если есть)
                    if grep -q "^---" "$file"; then
                        # Вставляем перед последним ---
                        awk -v child_files="$child_files" '
                        BEGIN {
                            split(child_files, files, "\n")
                        }
                        /^---/ {
                            if (!added) {
                                print ""
                                print "#### ДОЧЕРНИЕ ДОКУМЕНТЫ"
                                for (i in files) {
                                    if (files[i] != "") {
                                        split(files[i], parts, "/")
                                        filename = parts[length(parts)]
                                        gsub(/\.md$/, "", filename)
                                        print "- [[" filename "]]"
                                    }
                                }
                                added = 1
                            }
                        }
                        { print $0 }
                        ' "$file" > "${file}.tmp"
                    else
                        # Добавляем в конец файла
                        echo "" >> "$file"
                        echo "#### ДОЧЕРНИЕ ДОКУМЕНТЫ" >> "$file"
                        for child in $child_files; do
                            child_name=$(basename "$child" .md)
                            echo "- [[$child_name]]" >> "$file"
                        done
                    fi
                    echo "  ✅ Раздел добавлен"
                fi
            fi
        else
            echo "  ℹ️  Нет дочерних документов"
        fi
    fi
    
    echo ""
}

# Основная логика
echo "Выберите действие:"
echo "1 - Только проверить ссылки"
echo "2 - Проверить и исправить"
read -p "Ваш выбор (1 или 2): " action

fix="false"
if [ "$action" = "2" ]; then
    fix="true"
    echo "Режим: Проверка и исправление"
else
    echo "Режим: Только проверка"
fi

echo ""
echo "Сканирую документы..."

# Ищем все .md файлы с ID
files=$(find . -maxdepth 1 -name "*.md" -type f | \
    grep -E '^\./[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})* - ' | \
    sort)

total_files=$(echo "$files" | wc -l | tr -d ' ')
echo "Найдено документов: $total_files"
echo ""

count=0
for file in $files; do
    check_file_references "$file" "$fix"
    count=$((count + 1))
done

echo "=== ЗАВЕРШЕНО ==="
echo "Проверено документов: $count/$total_files"