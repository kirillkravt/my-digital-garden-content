---
chat_id: 38c170cd-4789-4b79-989e-4a90112273df
title: Настройка OpenCode для локальных и публичных моделей
message_count: 6
exported_at: 2026-05-25T06:46:19.014Z
---

# Настройка OpenCode для локальных и публичных моделей

## 👤 **Kirill**

Пошаговая настройка opencode для использования локальных и публичных моделей через API

---

## 🤖 **DeepSeek**

Я расскажу, как настроить OpenCode для работы с локальными моделями (через Ollama) и публичными API-сервисами. Это пошаговое руководство основано на практическом опыте и официальной документации.

## Что потребуется для настройки

Перед началом убедитесь, что у вас установлены:
- **Node.js** (версия 18 или выше) — среда для запуска OpenCode
- **Ollama** (для локальных моделей) — скачайте с ollama.ai
- **OpenCode CLI** — установим через npm

## Шаг 1: Установка OpenCode

Откройте терминал и выполните глобальную установку:

```bash
npm install -g opencode-ai
```

После установки проверьте, что всё работает:
```bash
opencode --version
```

## Шаг 2: Настройка локальных моделей (Ollama)

### 2.1. Запуск Ollama и загрузка моделей

Сначала запустите сервер Ollama:
```bash
ollama serve
```

В отдельном терминале загрузите нужные модели. **Важный нюанс**: для работы с файлами в OpenCode (создание, редактирование) подходят только модели семейства Qwen3 [citation:1]:

```bash
# Базовая модель для работы с файлами (рекомендуется)
ollama pull qwen3:8b

# Для больших проектов - расширенный контекст
ollama pull qwen3:8b-16k

# Для быстрых простых задач
ollama pull qwen3:4b

# Для анализа кода (только чтение)
ollama pull mistral-nemo:12b-instruct-2407-q4_K_M
```

Проверьте загруженные модели:
```bash
ollama list
```

### 2.2. Создание конфигурации OpenCode для локальных моделей

Теперь нужно создать файл конфигурации. Расположение зависит от вашей ОС [citation:4][citation:8]:
- **macOS/Linux**: `~/.config/opencode/opencode.json`
- **Windows**: `%USERPROFILE%\.config\opencode\opencode.json`

Создайте папку и файл:

**Для macOS/Linux:**
```bash
mkdir -p ~/.config/opencode
nano ~/.config/opencode/opencode.json
```

**Для Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Force -Path "$env:USERPROFILE\.config\opencode"
notepad "$env:USERPROFILE\.config\opencode\opencode.json"
```

Вставьте в файл следующую конфигурацию [citation:1][citation:4]:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Ollama Local",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3:8b": { "name": "Qwen 3 8B (File Ops)" },
        "qwen3:8b-16k": { "name": "Qwen 3 8B 16K (Extended)" },
        "qwen3:4b": { "name": "Qwen 3 4B (Fast)" },
        "mistral-nemo:12b-instruct-2407-q4_K_M": { "name": "Mistral Nemo (Analysis)" }
      }
    }
  }
}
```

## Шаг 3: Настройка публичных моделей через API

### 3.1. Общий шаблон конфигурации

Большинство API-сервисов используют единый подход с адаптером `@ai-sdk/openai-compatible` [citation:4][citation:5]. Вот универсальный шаблон:

```json
"provider_name": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "Понятное название",
  "options": {
    "baseURL": "https://api.сервис.com/v1",
    "apiKey": "{env:VARIABLE_NAME}"  // или прямой ключ
  },
  "models": {
    "model-id": { "name": "Отображаемое имя" }
  }
}
```

### 3.2. Конкретные примеры настройки провайдеров

Добавьте нужные провайдеры в тот же файл `opencode.json`. Вот несколько популярных вариантов:

**OpenRouter (универсальный доступ ко многим моделям):**
```json
"openrouter": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "OpenRouter",
  "options": {
    "baseURL": "https://openrouter.ai/api/v1",
    "apiKey": "{env:OPENROUTER_API_KEY}"
  },
  "models": {
    "anthropic/claude-3.5-sonnet": { "name": "Claude 3.5 Sonnet" },
    "openai/gpt-4o": { "name": "GPT-4o" },
    "google/gemini-pro": { "name": "Gemini Pro" }
  }
}
```

**DeepSeek** [citation:9]:
```json
"deepseek": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "DeepSeek",
  "options": {
    "baseURL": "https://api.deepseek.com/v1",
    "apiKey": "{env:DEEPSEEK_API_KEY}"
  },
  "models": {
    "deepseek-chat": { "name": "DeepSeek Chat" },
    "deepseek-reasoner": { "name": "DeepSeek Reasoner" }
  }
}
```

**Groq** [citation:9]:
```json
"groq": {
  "npm": "@ai-sdk/openai-compatible",
  "name": "Groq",
  "options": {
    "baseURL": "https://api.groq.com/openai/v1",
    "apiKey": "{env:GROQ_API_KEY}"
  },
  "models": {
    "llama3-70b-8192": { "name": "Llama 3 70B" },
    "mixtral-8x7b-32768": { "name": "Mixtral 8x7B" }
  }
}
```

### 3.3. Безопасное хранение API-ключей

Вместо прямого указания ключей в файле используйте переменные окружения [citation:8][citation:10]:

```bash
# Добавьте в ~/.bashrc или ~/.zshrc
export OPENROUTER_API_KEY="sk-or-ваш-ключ"
export DEEPSEEK_API_KEY="sk-ваш-ключ"
export GROQ_API_KEY="gsk-ваш-ключ"
```

После добавления выполните:
```bash
source ~/.bashrc  # или ~/.zshrc
```

## Шаг 4: Проверка и использование

### 4.1. Запуск OpenCode

Убедитесь, что Ollama запущена, и запустите OpenCode:
```bash
opencode
```

### 4.2. Выбор модели

В интерфейсе OpenCode [citation:5][citation:8]:
1. Введите команду `/models` (или `/model`)
2. Вы увидите список всех настроенных провайдеров и моделей
3. Стрелками выберите нужную модель и нажмите Enter

### 4.3. Быстрое переключение между моделями

Чтобы использовать конкретную модель сразу при запуске [citation:1]:
```bash
# Локальная модель
opencode --model ollama/qwen3:8b

# Публичная модель
opencode --model openrouter/anthropic/claude-3.5-sonnet
```

## Шаг 5: Продвинутые настройки

### 5.1. Кастомные модели с расширенным контекстом

Для локальных моделей можно создать варианты с изменёнными параметрами [citation:1]:

```bash
# Запустите модель интерактивно
ollama run qwen3:8b

# Внутри модели установите параметры
>>> /set parameter num_ctx 16384
>>> /save qwen3:8b-16k
>>> /bye
```

Затем добавьте созданную модель в `opencode.json` как описано выше.

### 5.2. Настройка нескольких провайдеров

Вот пример полного файла конфигурации с локальными и публичными моделями [citation:1][citation:10]:

```json
{
  "$schema": "https://opencode.ai/config.json",
  "provider": {
    "ollama": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "Local Ollama",
      "options": {
        "baseURL": "http://localhost:11434/v1"
      },
      "models": {
        "qwen3:8b": { "name": "Qwen 8B (File Ops)" },
        "qwen3:8b-16k": { "name": "Qwen 8B 16K" },
        "mistral-nemo:12b": { "name": "Mistral Nemo" }
      }
    },
    "openrouter": {
      "npm": "@ai-sdk/openai-compatible",
      "name": "OpenRouter",
      "options": {
        "baseURL": "https://openrouter.ai/api/v1",
        "apiKey": "{env:OPENROUTER_API_KEY}"
      },
      "models": {
        "anthropic/claude-3.5-sonnet": { "name": "Claude 3.5 Sonnet" },
        "openai/gpt-4o": { "name": "GPT-4o" }
      }
    }
  }
}
```

## Важные особенности при работе с локальными моделями

Из практики использования OpenCode с локальными моделями нужно учитывать несколько моментов [citation:1]:

### Какие модели что умеют

- **✅ Qwen3**: полноценная работа с файлами (создание, редактирование)
- **❌ Mistral Nemo, Granite**: только анализ кода, но не могут создавать файлы

### Производительность

| Задача | qwen3:8b | qwen3:8b-16k | Claude (облако) |
|--------|----------|--------------|-----------------|
| Создание файла | 15-30 сек | 45-90 сек | 2-5 сек |
| Анализ кода | 20-45 сек | 60-120 сек | 5-15 сек |

### Когда что использовать

**Локальные модели** [citation:1][citation:7]:
- Работа без интернета
- Конфиденциальный код
- Пакетная обработка
- Обучение и эксперименты

**Облачные модели**:
- Сложные задачи с быстрым итерациями
- Огромные кодовые базы
- Когда скорость важнее стоимости

## Решение возможных проблем

### OpenCode не видит локальные модели
```bash
# Проверьте, запущена ли Ollama
curl http://localhost:11434/v1/models

# Если нет - запустите
ollama serve
```

### Ошибка аутентификации API
```bash
# Проверьте переменные окружения
echo $OPENROUTER_API_KEY

# Если пусто - экспортируйте заново
export OPENROUTER_API_KEY="ваш-ключ"
```

### Медленная работа
- Для простых задач используйте `qwen3:4b`
- Для больших проектов, где не нужны изменения — `mistral-nemo`
- Для реальной работы с файлами берите `qwen3:8b` (не расширенную версию, если не нужен большой контекст) [citation:1]

## Что дальше

После настройки вы можете:
- Использовать команду `/agent` для переключения между режимами Build и Plan
- Настроить горячие клавиши для быстрого переключения моделей
- Добавить MCP-серверы для расширения функциональности [citation:10]

Такая конфигурация даёт гибкость: для быстрых задач и конфиденциальной работы используйте локальные модели, а для сложных — подключайте облачные через API.

---

## 👤 **Kirill**

как проверить какие локальные модели установлены сейчас на моем mac

---

## 🤖 **DeepSeek**

На Mac есть несколько способов проверить, какие локальные модели Ollama у вас установлены. Вот все варианты:

## 1. Самая простая команда (основной способ)

```bash
ollama list
```

Эта команда покажет таблицу со всеми установленными моделями:
- **NAME** - название модели
- **ID** - идентификатор
- **SIZE** - размер на диске
- **MODIFIED** - когда обновлялась

Пример вывода:
```
NAME                          ID              SIZE      MODIFIED
qwen3:8b                      5a9c3d9c5b4a    4.7 GB    2 days ago
qwen3:4b                      8b7f2e1c9d3f    2.3 GB    5 days ago
mistral-nemo:latest           f1e2d3c4b5a6    7.2 GB    1 week ago
llama3.2:latest               a1b2c3d4e5f6    3.8 GB    3 days ago
```

## 2. Проверка через файловую систему

Модели Ollama хранятся в директории:
```bash
ls -la ~/.ollama/models/blobs/
```

**Важный нюанс**: здесь файлы имеют хэшированные имена, поэтому этот способ не очень удобен для понимания, какие именно модели у вас есть, но позволяет проверить, сколько места они занимают.

## 3. Проверка через API Ollama (альтернативный способ)

Запустите в терминале:
```bash
curl http://localhost:11434/api/tags
```

Вы получите JSON-ответ со списком моделей:
```json
{
  "models": [
    {
      "name": "qwen3:8b",
      "modified_at": "2024-01-15T10:30:00Z",
      "size": 4700000000
    },
    {
      "name": "mistral-nemo:latest",
      "modified_at": "2024-01-14T15:20:00Z",
      "size": 7200000000
    }
  ]
}
```

## 4. Если хотите узнать больше о конкретной модели

Посмотреть детальную информацию:
```bash
ollama show qwen3:8b
```

Узнать, какая версия модели используется:
```bash
ollama list | grep qwen3
```

## 5. Проверка с сортировкой по размеру или дате

Сортировка по размеру (самые большие внизу):
```bash
ollama list | sort -k 3 -h
```

Сортировка по дате (самые новые внизу):
```bash
ollama list | sort -k 4 -M
```

## 6. Проверка свободного места для новых моделей

Перед установкой новой модели полезно знать, сколько места осталось:
```bash
# Место в директории моделей
du -sh ~/.ollama/models/

# Свободное место на диске
df -h ~
```

## Что делать, если команда `ollama` не найдена?

Если вы видите ошибку `command not found: ollama`, значит Ollama не установлена или не добавлена в PATH:

1. **Установите Ollama** (если ещё не установлена):
```bash
brew install ollama
```
или скачайте с [ollama.ai](https://ollama.ai)

2. **Или добавьте в PATH** (если установлена, но не видна):
```bash
export PATH=$PATH:/usr/local/bin
# или для Homebrew
export PATH=$PATH:/opt/homebrew/bin
```

3. **Запустите сервер**, если он не запущен:
```bash
ollama serve
```

## Полезные сочетания для Mac

На Mac можно использовать Automator или создать алиас для быстрой проверки:

Добавьте в `~/.zshrc` (для Zsh, стандартная оболочка на новых Mac) или `~/.bash_profile`:
```bash
alias models='ollama list'
alias models-size='ollama list | sort -k 3 -h'
```

После этого просто вводите `models` в терминале для быстрой проверки.

**Самый рекомендуемый способ** для повседневного использования — просто `ollama list`. Эта команда даёт всю необходимую информацию в читаемом виде.

---

## 👤 **Kirill**

kirillkravcov@MacBook-Air uch-backend % ollama list
zsh: command not found: ollama
kirillkravcov@MacBook-Air uch-backend %

---

## 🤖 **DeepSeek**

Да, действительно, команда `ollama list` не работает, потому что система не может найти программу `ollama`. Это значит, что Ollama либо не установлена, либо установлена, но её путь не добавлен в переменную окружения `PATH` [citation:1][citation:4].

Для macOS есть два основных способа решения, в зависимости от того, как вы предпочитаете устанавливать программы.

### Вариант 1: Установка через официальный .pkg installer (Рекомендуемый способ)

Этот способ самый надежный, особенно для Mac на Apple Silicon (M1, M2, M3, как у вас), так как он гарантирует установку правильной ARM64-версии и автоматически настраивает все необходимые компоненты, включая Metal для ускорения на GPU [citation:5].

1.  **Скачайте установщик:** Откройте браузер и перейдите на официальный сайт Ollama: [https://ollama.com/download](https://ollama.com/download). Нажмите кнопку загрузки для **macOS** (автоматически предложит нужную версию).
2.  **Установите программу:** Откройте скачанный файл (например, `Ollama-darwin.zip`). В распакованной папке будет файл `Ollama.app`. Перетащите его в папку `Программы` (Applications) [citation:8][citation:9].
3.  **Запустите Ollama:** Откройте папку `Программы` и дважды кликните по `Ollama.app`. В строке меню (вверху экрана, рядом с часами) появится иконка ламы. Это означает, что фоновый сервис (демон) Ollama запущен.
4.  **Перезапустите Терминал:** Закройте окно Терминала (`Cmd+Q`) и откройте его снова. Это нужно, чтобы терминал "узнал" о новой команде [citation:5].
5.  **Проверьте установку:** Теперь снова выполните команду для проверки установленных моделей:
    ```bash
    ollama list
    ```
    Если моделей еще нет, вы увидите сообщение, что список пуст. Если они были установлены ранее, но команда не работала, теперь они должны отобразиться.

### Вариант 2: Установка через Homebrew (Если вы пользуетесь этим менеджером пакетов)

Этот способ удобен для тех, кто уже активно использует Homebrew для управления программами.

1.  **Установите Ollama:** Вставьте в Терминал следующую команду [citation:6]:
    ```bash
    brew install ollama
    ```
2.  **Запустите сервис:** После установки нужно запустить фоновый сервис Ollama. Это можно сделать командой:
    ```bash
    brew services start ollama
    ```
3.  **Проверьте установку:** Выполните команду для проверки:
    ```bash
    ollama list
    ```

### Что делать, если это не помогло?

Если после выполнения одного из вариантов команда `ollama list` снова не работает, попробуйте эти шаги:

*   **Полная перезагрузка Терминала:** Не просто открывайте новую вкладку, а полностью закройте программу Терминал (`Cmd+Q`) и откройте её заново [citation:5].
*   **Ручной поиск:** Можно попробовать вручную найти, куда установился Ollama. Выполните команду:
    ```bash
    which ollama
    ```
    Если команда ничего не выдала, поищите глубже:
    ```bash
    find / -name ollama -type f 2>/dev/null | grep -v "\.app"
    ```
    (Эта команда может работать долго и потребовать ввода пароля для поиска в системных папках).
    Если вы увидите путь, например, `/usr/local/bin/ollama` или `/opt/homebrew/bin/ollama`, значит, проблема именно в `PATH`. Временно добавить его можно так:
    ```bash
    export PATH="$PATH:/usr/local/bin"
    ```
    (или `/opt/homebrew/bin`, в зависимости от того, что нашла команда `find`). Для постоянного решения эту строку нужно добавить в файл `~/.zshrc` [citation:4].

Попробуйте сначала первый способ — он самый прямолинейный и часто решает проблему с "command not found" на Mac [citation:3][citation:5].

---

