---
chat_id: 2142203e-bee9-49f4-9f18-882be0af1bef
title: как использовать spotify backsta
message_count: 10
exported_at: 2026-05-24T19:27:37.257Z
---

# как использовать spotify backsta

## 👤 **Kirill**

как использовать spotify backstage для yaml документа?

---

## 🤖 **DeepSeek**

Spotify Backstage использует YAML-файлы для описания **Software Templates** и **Entity дескрипторов** (систем, компонентов, API и т.д.). Вот как использовать YAML в Backstage:

## 1. **Entity Descriptor YAML (основной формат)**

Пример компонента (`catalog-info.yaml`):
```yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: web-app
  description: Веб-приложение компании
  annotations:
    github.com/project-slug: org/web-app
    backstage.io/techdocs-ref: dir:.
spec:
  type: website
  lifecycle: production
  owner: team-a
  system: e-commerce-platform
```

## 2. **Типы Entity в YAML**

```yaml
# Система
apiVersion: backstage.io/v1alpha1
kind: System
metadata:
  name: payments-system
spec:
  owner: payments-team

# API
apiVersion: backstage.io/v1alpha1
kind: API
metadata:
  name: payments-api
spec:
  type: openapi
  lifecycle: production
  owner: payments-team
  definition: |
    openapi: 3.0.0
    info:
      title: Payments API

# Ресурс
apiVersion: backstage.io/v1alpha1
kind: Resource
metadata:
  name: postgres-payments
spec:
  type: database
  owner: dba-team
  system: payments-system
```

## 3. **Software Template YAML**

```yaml
apiVersion: scaffolder.backstage.io/v1beta3
kind: Template
metadata:
  name: react-app-template
  title: React приложение
  description: Создает новое React приложение
spec:
  owner: frontend-guild
  type: website

  parameters:
    - title: Заполните информацию
      properties:
        component_id:
          title: Название компонента
          type: string
        description:
          title: Описание
          type: string

  steps:
    - id: fetch-base
      name: Fetch Base
      action: fetch:template
      input:
        url: ./templates/react-template
        values:
          name: ${{ parameters.component_id }}

    - id: publish
      action: publish:github
      input:
        repoUrl: ${{ parameters.repoUrl }}

  output:
    links:
      - title: Репозиторий
        url: ${{ steps.publish.output.remoteUrl }}
```

## 4. **Работа с YAML файлами**

### **Размещение

---

## 👤 **Kirill**

нужно вытащить из yaml таблицы с параметрами это можно в нем сделать?

---

## 🤖 **DeepSeek**

В Backstage YAML-файлах **нельзя напрямую создавать таблицы для отображения параметров**. Однако есть несколько способов организовать и представить параметры:

## 1. **Использование групп параметров (sections)**

```yaml
parameters:
  - title: Основная информация
    properties:
      component_id:
        title: Имя компонента
        type: string
        description: Уникальное имя компонента
        ui:field: EntityNamePicker
  
  - title: Настройки репозитория
    properties:
      repoUrl:
        title: URL репозитория
        type: string
        ui:field: RepoUrlPicker
```

## 2. **Массивы параметров (для табличных данных)**

```yaml
parameters:
  properties:
    environment_vars:
      title: Переменные окружения
      type: array
      items:
        type: object
        properties:
          name:
            title: Имя
            type: string
          value:
            title: Значение
            type: string
          secret:
            title: Секретная?
            type: boolean
      ui:options:
        orderable: false
```

## 3. **Custom UI Field Extensions**

Создайте кастомный компонент для отображения таблиц:

```yaml
# template.yaml
parameters:
  properties:
    dependencies:
      title: Зависимости
      type: array
      items:
        type: object
        properties:
          package:
            title: Пакет
            type: string
          version:
            title: Версия
            type: string
      ui:field: TableField  # ваш кастомный компонент
```

## 4. **Backstage TechDocs для документации**

Для сложных таблиц параметров лучше использовать TechDocs:

```yaml
# catalog-info.yaml
apiVersion: backstage.io/v1alpha1
kind: Component
metadata:
  name: my-service
  annotations:
    backstage.io/techdocs-ref: dir:.
spec:
  type: service
```

```markdown
# docs/index.md
## Параметры конфигурации

| Параметр | Тип | Обязательный | Описание |
|----------|-----|--------------|----------|
| `apiKey` | string | Да | Ключ API |
| `timeout` | number | Нет | Таймаут в ms |
```

## 5. **Встроенные UI Options**

```yaml
parameters:
  properties:
    deployment_config:
      title: Конфигурация деплоя
      type: object
      properties:
        replicas:
          title: Реплики
          type: number
        resources:
          title: Ресурсы
          type: object
          properties:
            cpu:
              title: CPU
              type: string
            memory:
              title: Память
              type: string
      ui:options:
        order: ['replicas', 'resources']
```

## **Рекомендации**

1. **Для простых параметров** - используйте группы (sections)
2. **Для табличных данных** - используйте массивы объектов
3. **Для документации** - используйте TechDocs
4. **Для сложного UI** - создавайте кастомные расширения

**Пример комплексного использования:**

```yaml
parameters:
  - title: "Основные настройки"
    properties:
      name:
        title: "Название сервиса"
        type: "string"
  
  - title: "Таблица переменных"
    properties:
      env_vars:
        title: "Переменные окружения"
        type: "array"
        items:
          type: "object"
          properties:
            key: { title: "Ключ", type: "string" }
            value: { title: "Значение", type: "string" }
            type: { 
              title: "Тип", 
              type: "string",
              enum: ["plain", "secret"]
            }
```

Backstage сам рендерит формы на основе этой YAML-структуры, но для настоящих таблиц (grid view) потребуется кастомная разработка UI-расширений.

---

## 👤 **Kirill**

какие еще есть варианты, чтобы вытащить табличку параметров из api yaml?

---

## 🤖 **DeepSeek**

В Backstage есть несколько подходов для извлечения и отображения таблиц параметров из YAML API:

## 1. **Entity Cards & Widgets в Overview**

Используйте `EntityTable` в собственных компонентах:

```tsx
// plugins/my-plugin/src/components/ParametersTable.tsx
import { Table, TableColumn } from '@backstage/core-components';

export const ParametersTable = ({ entity }: { entity:

---

## 👤 **Kirill**

не обязательно backstage. Ye;ty cfvsq ghjcnjq cgjcj,\

---

## 🤖 **DeepSeek**

Понял, речь о **YAML вообще**, не только в контексте Backstage. Вот все основные способы извлечения таблиц/структурированных данных из YAML:

## 1. **YAML + Jinja2/Templating** (Python)

```yaml
# config.yaml
parameters:
  table_data: |
    | Параметр | Тип | Описание |
    |----------|-----|----------|
    | host     | string | Хост API |
    | port     | int | Порт |
    | timeout  | int | Таймаут |
```

```python
import yaml
from jinja2 import Template

with open('config.yaml') as f:
    data = yaml.safe_load(f)
    
# Извлекаем markdown таблицу
table_markdown = data['parameters']['table_data']
print(table_markdown)
```

## 2. **YAML с массивом объектов** (самый чистый)

```yaml
parameters:
  - name: api_key
    type: string
    required: true
    description: Ключ для доступа к API
    default: null
  
  - name: timeout
    type: integer
    required: false
    description: Таймаут запроса
    default: 30
  
  - name: retries
    type: integer
    required: false
    description: Количество повторов
    default: 3
```

## 3. **YAML Anchor & Alias** для табличных данных

```yaml
# Определяем структуру таблицы
table_columns: &columns
  - name
  - type
  - description
  - default

# Данные таблицы
parameters:
  columns: *columns
  rows:
    - [api_key, string, "API ключ", null]
    - [timeout, integer, "Таймаут", 30]
    - [retries, integer, "Повторы", 3]
```

## 4. **Multi-line strings с разделителями**

```yaml
parameters_table: |
  Параметр;Тип;Обязательный;Описание
  apiKey;string;Да;Ключ API
  timeout;int;Нет;Таймаут в ms
  endpoint;string;Да;URL эндпоинта
  
  # Затем парсим как CSV
```

## 5. **YAML + JSON Schema для валидации**

```yaml
# config.yaml
api_spec:
  parameters:
    $schema: "http://json-schema.org/draft-07/schema#"
    type: array
    items:
      type: object
      properties:
        name:
          type: string
        type:
          type: string
          enum: [string, integer, boolean]
        required:
          type: boolean
    examples:
      - name: "apiKey"
        type: "string"
        required: true
        description: "API ключ"
```

## 6. **GitHub Flavored Markdown в YAML**

```yaml
documentation: |
  ## Параметры API
  
  | Параметр | Тип | Описание |
  |----------|-----|----------|
  | `limit` | `integer` | Лимит записей |
  | `offset` | `integer` | Смещение |
  | `sort` | `string` | Поле сортировки |
  
  **Пример:**
  ```json
  {"limit": 100, "offset": 0}
  ```
```

## 7. **Custom YAML Tags** (продвинутый вариант)

```yaml
# Определяем кастомный тег !table
!table
columns: [name, type, required, default]
data:
  - [api_key, string, true, null]
  - [timeout, integer, false, 30]
  - [retries, integer, false, 3]
```

```python
import yaml

def table_constructor(loader, node):
    data = loader.construct_mapping(node)
    # Конвертируем в pandas DataFrame или список словарей
    return {
        'columns': data['columns'],
        'rows': data['data']
    }

yaml.add_constructor('!table', table_constructor)
```

## 8. **YAML + OpenAPI/Swagger формат**

```yaml
openapi: 3.0.0
info:
  title: Example API
  version: 1.0.0

paths:
  /users:
    get:
      parameters:
        - name: limit
          in: query
          schema:
            type: integer
          description: Лимит записей
        - name: offset
          in: query
          schema:
            type: integer
          description: Смещение
```

## 9. **Использование комментариев для генерации таблиц**

```yaml
parameters:
  # name: api_key, type: string, required: true, desc: API ключ
  api_key: 
    type: string
    required: true
  
  # name: timeout, type: integer, required: false, desc: Таймаут
  timeout: 30
  
  # name: endpoint, type: string, required: true, desc: Базовый URL
  endpoint: "https://api.example.com"
```

## 10. **YAML → Python/Pandas** (для анализа)

```python
import yaml
import pandas as pd
from io import StringIO

with open('config.yaml') as f:
    data = yaml.safe_load(f)

# Если данные в markdown таблице
if 'markdown_table' in data:
    # Убираем markdown разметку
    lines = data['markdown_table'].strip().split('\n')
    # Преобразуем в CSV
    csv_data = '\n'.join([line.replace('|', ',') for line in lines])
    df = pd.read_csv(StringIO(csv_data))
    
# Или если данные структурированы
if 'parameters' in data:
    df = pd.DataFrame(data['parameters'])
    
print(df.to_markdown(index=False))
```

## **Рек

---

## 👤 **Kirill**

у меня есть 2 спецификации в yaml в новой добавлены некоторые параметры. Мне нужно определить как-то что это за параметры

---

## 🤖 **DeepSeek**

Есть несколько эффективных способов определить новые параметры при сравнении двух YAML-спецификаций:

## 1. **Diff инструменты** (быстрый просмотр)

### **yq + diff**
```bash
# Установка yq (обработка YAML как jq для JSON)
brew install yq

# Сравнение структур
yq eval '.parameters' old.yaml > old_params.yaml
yq eval '.parameters' new.yaml > new_params.yaml
diff old_params.yaml new_params.yaml

# Или с выделением
diff -u old_params.yaml new_params.yaml | colordiff
```

### **Python скрипт для сравнения**
```python
import yaml
import deepdiff

with open('old.yaml') as f:
    old_spec = yaml.safe_load(f)

with open('new.yaml') as f:
    new_spec = yaml.safe_load(f)

# Используем deepdiff для детального сравнения
diff = deepdiff.DeepDiff(old_spec, new_spec)
print(diff.pretty())

# Только новые параметры
if 'dictionary_item_added' in diff:
    print("Новые параметры:")
    for item in diff['dictionary_item_added']:
        print(f"  {item}")
```

## 2. **Структурированный анализ новых параметров**

```python
def find_new_parameters(old_yaml, new_yaml):
    """Находит новые параметры с их путями"""
    def extract_params(data, prefix=''):
        params = {}
        if isinstance(data, dict):
            for key, value in data.items():
                new_prefix = f"{prefix}.{key}" if prefix else key
                if isinstance(value, (dict, list)):
                    params.update(extract_params(value, new_prefix))
                else:
                    params[new_prefix] = {
                        'value': value,
                        'type': type(value).__name__
                    }
        elif isinstance(data, list):
            for i, item in enumerate(data):
                params.update(extract_params(item, f"{prefix}[{i}]"))
        return params
    
    old_params = extract_params(old_yaml)
    new_params = extract_params(new_yaml)
    
    new_only = {k: v for k, v in new_params.items() if k not in old_params}
    modified = {k: v for k, v in new_params.items() 
                if k in old_params and old_params[k]['value'] != v['value']}
    
    return {
        'new_parameters': new_only,
        'modified_parameters': modified,
        'total_new': len(new_only),
        'total_modified': len(modified)
    }

# Использование
result = find_new_parameters(old_spec, new_spec)
for param, info in result['new_parameters'].items():
    print(f"🆕 Новый: {param} = {info['value']} (тип: {info['type']})")
```

## 3. **OpenAPI-specific сравнение** (если это OpenAPI спецификации)

```python
import yaml
from openapi_diff import OpenAPICompare

def compare_openapi_specs(old_file, new_file):
    with open(old_file) as f:
        old = yaml.safe_load(f)
    with open(new_file) as f:
        new = yaml.safe_load(f)
    
    changes = {
        'new_paths': [],
        'new_parameters': [],
        'modified_parameters': []
    }
    
    # Сравнение путей
    old_paths = old.get('paths', {})
    new_paths = new.get('paths', {})
    
    for path in new_paths:
        if path not in old_paths:
            changes['new_paths'].append(path)
        else:
            # Сравнение параметров для каждого метода
            for method in ['get', 'post', 'put', 'delete']:
                if method in new_paths[path]:
                    old_params = old_paths[path].get(method, {}).get('parameters', [])
                    new_params = new_paths[path][method].get('parameters', [])
                    
                    # Находим новые параметры
                    old_param_names = {p['name'] for p in old_params if 'name' in p}
                    for param in new_params:
                        if param.get('name') not in old_param_names:
                            changes['new_parameters'].append({
                                'path': path,
                                'method': method.upper(),
                                'parameter': param
                            })
    
    return changes
```

## 4. **Инструменты командной строки**

### **yamldiff** (специализированный инструмент)
```bash
# Установка
pip install yamldiff

# Использование
yamldiff old.yaml new.yaml --output=json

# С фильтром только новых элементов
yamldiff old.yaml new.yaml --filter=added
```

### **jd** (JSON Diff)
```bash
# Конвертируем YAML в JSON и сравниваем
yq eval -o=json old.yaml > old.json
yq eval -o=json new.yaml > new.json

# Используем jd для сравнения
jd old.json new.json

# Только новые поля
jd -set old.json new.json
```

## 5. **Визуальное сравнение**

### **VSCode/IDE**
- Откройте оба файла в VSCode
- ПКМ → "Select for Compare"
- ПКМ → "Compare with Selected"
- Или используйте расширение "Partial Diff"

### **Online инструменты**
- [**Diffchecker**](https://www.diffchecker.com/) - загрузите оба YAML
- [**JSON/YAML Diff Online**](http://www.jsondiff.com/)
- [**yamllint**](https://yamllint.com/) для проверки синтаксиса

## 6. **Git-based сравнение**

Если файлы в Git:
```bash
# Добавьте оба файла в Git временно
git add old.yaml new.yaml

# Сравнение через git diff
git diff --no-index old.yaml new.yaml

# Создайте патч с новыми параметрами
git diff --no-index old.yaml new.yaml | grep -A5 -B5 "^+"
```

## 7. **Генерация отчета о изменениях**

```python
import yaml
from datetime import datetime

def generate_change_report(old_file, new_file, output_file='changes.md'):
    with open(old_file) as f:
        old = yaml.safe_load(f)
    with open(new_file) as f:
        new = yaml.safe_load(f)
    
    report = f"""# Отчет об изменениях в спецификации

**Дата сравнения:** {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
**Старая версия:** {old_file}
**Новая версия:** {new_file}

## Новые параметры
"""
    
    def find_new_keys(old_dict, new_dict, path=''):
        new_items = []
        for key in new_dict:
            full_path = f"{path}.{key}" if path else key
            if key not in old_dict:
                new_items.append((full_path, new_dict[key]))
            elif isinstance(new_dict[key], dict) and isinstance(old_dict.get(key), dict):
                new_items.extend(find_new_keys(old_dict[key], new_dict[key], full_path))
        return new_items
    
    new_params = find_new_keys(old, new)
    
    if new_params:
        for path, value in new_params:
            report += f"\n- `{path}`: `{value}`"
    else:
        report += "\nНовых параметров не найдено."
    
    with open(output_file, 'w') as f:
        f.write(report)
    
    return report
```

## **Рекомендация:**

Для разового анализа используйте **yamldiff** или **Python скрипт**.
Для регулярного отслеживания изменений создайте **скрипт сравнения** с выводом в markdown.

```bash
# Быстрый одноразовый анализ
python -c "
import sys, yaml
old = yaml.safe_load(open(sys.argv[1]))
new = yaml.safe_load(open(sys.argv[2]))

def find_new(d1, d2, path=''):
    for k in d2:
        p = f'{path}.{k}' if path else k
        if k not in d1:
            print(f'NEW: {p} = {d2[k]}')
        elif isinstance(d2[k], dict) and isinstance(d1.get(k), dict):
            find_new(d1[k], d2[k], p)

find_new(old, new)
" old.yaml new.yaml
```

---

