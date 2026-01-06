#!/bin/bash
# Утилиты для UCH Document System

# Получаем текущую дату
get_current_date() {
    date +%Y-%m-%d
}

# Найти свободный ID для мастер-документа
find_free_master_id() {
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E '^\./[0-9A-Fa-f]{2} - ' | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        sort | uniq)
    
    if [ -z "$existing_ids" ]; then
        echo "00"
        return
    fi
    
    declare -a dec_ids=()
    for hex_id in $existing_ids; do
        dec_id=$((16#$hex_id))
        dec_ids+=($dec_id)
    done
    
    sorted_ids=($(printf "%d\n" "${dec_ids[@]}" | sort -n))
    expected=0
    for id in "${sorted_ids[@]}"; do
        if [ $id -gt $expected ]; then
            break
        fi
        expected=$((id + 1))
    done
    
    printf "%02X" $expected
}

# Найти свободный ID для дочернего документа
find_free_child_id() {
    local parent_id="$1"
    
    pattern="${parent_id}-[0-9A-Fa-f][0-9A-Fa-f]"
    
    existing_ids=$(find . -maxdepth 1 -name "*.md" -type f 2>/dev/null | \
        grep -E "^\./${pattern} - " | \
        sed 's/^\.\///' | \
        cut -d' ' -f1 | \
        grep -E "^${parent_id}-[0-9A-Fa-f]{2}$" | \
        awk -F"${parent_id}-" '{print $2}' | \
        sort | uniq)
    
    if [ -z "$existing_ids" ]; then
        echo "01"
        return
    fi
    
    declare -a dec_array=()
    for hex_id in $existing_ids; do
        dec_id=$((16#$hex_id))
        dec_array+=($dec_id)
    done
    
    sorted_array=($(printf "%d\n" "${dec_array[@]}" | sort -n))
    
    expected=1
    for id in "${sorted_array[@]}"; do
        if [ $id -gt $expected ]; then
            break
        fi
        expected=$((id + 1))
    done
    
    printf "%02X" $expected
}

# Очистить имя родителя от ID
clean_parent_name() {
    local full_filename="$1"
    
    filename=$(basename "$full_filename" .md)
    
    OLD_IFS="$IFS"
    IFS=" - "
    parts=($filename)
    IFS="$OLD_IFS"
    
    if [ ${#parts[@]} -eq 0 ]; then
        echo "$filename"
        return
    fi
    
    clean_parts=()
    for part in "${parts[@]}"; do
        if echo "$part" | grep -qE '^[0-9A-Fa-f]{2}(-[0-9A-Fa-f]{2})*$'; then
            continue
        else
            clean_parts+=("$part")
        fi
    done
    
    if [ ${#clean_parts[@]} -eq 0 ]; then
        last_part="${parts[-1]}"
        echo "$last_part"
    else
        clean_name=$(IFS=" - "; echo "${clean_parts[*]}")
        echo "$clean_name"
    fi
}

# Форматировать теги в YAML
format_tags_yaml() {
    local tags_input="$1"
    local type="$2"
    
    # Начинаем с типа документа
    local yaml_tags="tags:"
    yaml_tags="$yaml_tags"$'\n'"  - \"$type\""
    
    # Обрабатываем остальные теги
    if [ -n "$tags_input" ]; then
        # Разделяем теги по запятым
        IFS=',' read -r -a tag_parts <<< "$tags_input"
        
        for tag in "${tag_parts[@]}"; do
            # Убираем пробелы и префиксы @/#
            tag_clean=$(echo "$tag" | xargs | sed 's/^[@#]//')
            if [ -n "$tag_clean" ] && [ "$tag_clean" != "$type" ]; then
                # Добавляем только если тег отличается от типа
                yaml_tags="$yaml_tags"$'\n'"  - \"$tag_clean\""
            fi
        done
    fi
    
    echo "$yaml_tags"
}

# Обновить родительский документ (добавить ссылку на ребенка)
update_parent_document() {
    local parent_file="$1"
    local child_id="$2"
    local child_name="$3"
    
    echo "  Обновляю родительский документ: $(basename "$parent_file")"
    
    if [ ! -f "$parent_file" ]; then
        echo "  ⚠️  Родительский файл не найден, пропускаю обновление"
        return 1
    fi
    
    temp_file="${parent_file}.tmp"
    
    awk -v child_id="$child_id" -v child_name="$child_name" '
    BEGIN { 
        in_children_section = 0
        children_section_found = 0
        link_exists = 0
        link_added = 0
    }
    
    /\[\[.* - .*\]\]/ && in_children_section {
        if ($0 ~ "\\[\\[" child_id " - " child_name "\\]\\]") {
            link_exists = 1
        }
    }
    
    /#### ДОЧЕРНИЕ ДОКУМЕНТЫ/ {
        in_children_section = 1
        children_section_found = 1
        print $0
        next
    }
    
    in_children_section && /^[[:space:]]*Пока нет дочерних документов/ {
        next
    }
    
    in_children_section && (/^####/ || /^###/ || /^##/ || /^#/ || /^---/) {
        in_children_section = 0
    }
    
    in_children_section && /^[[:space:]]*$/ {
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    in_children_section && /^---/ {
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    in_children_section && !/^- \[\[/ && !/^[[:space:]]*$/ {
        if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
            link_added = 1
        }
        in_children_section = 0
        print $0
        next
    }
    
    { print $0 }
    
    END {
        if (!children_section_found) {
            print ""
            print "#### ДОЧЕРНИЕ ДОКУМЕНТЫ"
            print "- [[" child_id " - " child_name "]]"
        } else if (!link_exists && !link_added) {
            print "- [[" child_id " - " child_name "]]"
        }
    }
    ' "$parent_file" > "$temp_file"
    
    mv "$temp_file" "$parent_file"
    
    echo "  ✅ Ссылка добавлена в родительский документ"
}

# Генерация ID для неиерархических документов
generate_non_hierarchical_id() {
    local type=$1
    
    case $type in
        "idea")
            echo "Z-$(date +%Y%m%d%H%M%S)"  # Z-префикс + временная метка
            ;;
        "reference")
            # Генерация случайного 6-символьного HEX в верхнем регистре
            # Используем /dev/urandom для macOS
            random_hex=$(od -x -N 3 /dev/urandom | head -1 | awk '{print $2$3$4}' | tr '[:lower:]' '[:upper:]')
            echo "R-$random_hex"
            ;;
        "meeting")
            echo "M-$(date +%Y%m%d)"  # M-префикс + дата
            ;;
        *)
            # По умолчанию идея
            echo "Z-$(date +%Y%m%d%H%M%S)"
            ;;
    esac
}
