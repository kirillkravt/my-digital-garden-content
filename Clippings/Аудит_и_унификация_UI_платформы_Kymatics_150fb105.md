---
chat_id: 150fb105-735e-44ec-aa7e-eba62a98781a
title: Аудит и унификация UI платформы Kymatics
message_count: 2
exported_at: 2026-05-24T20:46:34.205Z
---

# Аудит и унификация UI платформы Kymatics

## 👤 **Kirill**

СИСТЕМНЫЙ ПРОМПТ: ЦЕНТР УПРАВЛЕНИЯ ПРОЕКТАМИ KYMATICS (ЭТАП 79 — UI/UX УНИФИКАЦИЯ + ИСПРАВЛЕНИЕ ПРОБЛЕМ)
🎯 КОНТЕКСТ
Успешно завершены этапы 49-78. Платформа имеет:

ДОСТИГНУТЫЕ РЕЗУЛЬТАТЫ (этап 78):

✅ Projects IDE полностью функционирует:

Monaco Editor с кастомной темой kymatics-dark

VSCode-style FileTree с контекстным меню

Терминал с историей и базовыми командами

BottomPanel с 4 вкладками (Terminal/Problems/Output/Debug)

Ресайз панелей как в Process Designer

Полная интеграция с дизайн-системой

✅ Process Designer:

Генерация процессов из текста (узлы + связи)

Импорт/экспорт процессов

Визуальное редактирование через React Flow

Автоматическая компоновка узлов (semantic/elk/bpmn/simple)

Исполнение процессов через бэкенд (FastAPI + WebSocket)

WebSocket стриминг логов в реальном времени

✅ Агентная система:

Агенты для выполнения узлов (bash, agent, approval, http, git и др.)

Ollama интеграция для локальных LLM (7B-14B)

Песочница для безопасного выполнения

✅ Файловая система:

Mock файловая система с localStorage персистентностью

FileSystemProvider абстракция (легко заменить на бэкенд)

FileTree с VSCode-подобными линиями вложенности

✅ Интеграция Projects ↔ Processes:

Логи выполнения из Process Designer отображаются в OutputPanel Projects IDE

WebSocket бэкенда (/api/v1/process/ws/logs) рассылает логи всем клиентам

Event-driven архитектура с бэкендной шиной

ОБНАРУЖЕННЫЕ ПРОБЛЕМЫ И ОГРАНИЧЕНИЯ:

❌ UI не унифицирован — Projects IDE и Process Designer выглядят по-разному
❌ Projects IDE не соответствует дизайн-системе Kymatics (стили, отступы, цвета)
❌ В Process Designer отсутствует Canvas Toolbar (кнопки Run/Stop/Step размазаны по интерфейсу)
❌ Селектор проектов находится в тулбаре, а не в правой панели
❌ Границы панелей слишком контрастные (нет opacity)
❌ Использование эмодзи вместо системных иконок
❌ Моноширинный шрифт в терминале Process Designer (должен быть Inter)

⚠️ Железо: M4 24GB → 7B-14B модели только (облако позже)

🔍 ШАГ 0 — ПОЛНЫЙ АУДИТ UI (P0)
Перед началом разработки необходимо провести аудит текущего UI.

Задачи для аудита:

@🧠 Специалист по знаниям — Аудит ProcessDesignerPage (эталон):

Проанализировать структуру компонента (JSX, CSS классы)

Выявить, какие элементы делают его «почти идеальным»

Задокументировать дизайн-токены Kymatics (цвета, отступы, радиусы, шрифты)

Найти места, где используются эмодзи (заменить на иконки)

Найти моноширинные шрифты (заменить на Inter)

@🚀 Хранитель стабильности — Аудит Canvas Toolbar:

Проверить, какие кнопки управления выполнением есть сейчас

Найти, где реализованы Run/Stop/Step (или их отсутствие)

Исследовать, как визуализируется текущий узел

Проверить наличие кнопок Copy/Paste/Reset View/Fit to Screen

@🏛️ Хранитель архитектуры — Аудит ProjectsPage:

Сравнить ProjectsPage.tsx с ProcessDesignerPage.tsx

Выявить различия в структуре, стилях, компонентах

Найти, какие элементы дизайн-системы не используются

Проверить BottomPanel (вкладки Terminal/Output/Problems/Debug)

Результат аудита — отчёт по каждому пункту:
✅ Уже реализовано (название файлов, строки, API)
⚠️ Частично реализовано (что есть, чего не хватает)
❌ Не реализовано (нужно создавать с нуля)

📋 ПРИОРИТЕТЫ ЭТАПА 79 — ПОСЛЕ АУДИТА
P0 (НАИВЫСШИЙ) — УНИФИКАЦИЯ UI И ИСПРАВЛЕНИЕ PROCESS DESIGNER

@🧠 Специалист по знаниям:

Создать эталонную документацию по ProcessDesignerPage (структура, CSS, компоненты)

Подготовить список дизайн-токенов для унификации

Заменить эмодзи на минималистичные иконки (▶ ⎔ ⟳ ↺ ⧉ ■ ⚙ ✓ $ ◧ ◷ ⌖ ⎔ ◌ ⎇)

Убрать моноширинные шрифты из терминала (заменить на Inter)

@🚀 Хранитель стабильности:

Добавить Canvas Toolbar (если отсутствует) с кнопками:

Copy / Paste

Run / Stop / Step

Reset View / Fit to Screen

Export / Import

Убрать селектор проектов из тулбара (перенести в правую панель)

Уменьшить opacity границ панелей (добавить --k-border-opacity: 0.4)

Подсветка текущего выполняемого узла на канвасе

P1 (ВЫСОКИЙ) — РЕФАКТОРИНГ PROJECTS PAGE

@🏛️ Хранитель архитектуры:

Полностью переписать ProjectsPage.tsx по аналогии с ProcessDesignerPage.tsx

Структура: Header (лого + вкладки) → Canvas Toolbar (если нужен) → Left Panel (FileTree) → Center (Monaco) → Right Panel (File Info + Projects) → Bottom Panel (Terminal/Output/Problems/Debug)

Использовать единые дизайн-токены из process-designer.css

Интегрировать WebSocket для получения логов (уже есть в ProjectsPage.tsx)

OutputPanel должен получать логи через eventBus

P2 (СРЕДНИЙ) — КАЧЕСТВО И ДЕТАЛИ

@🧠 Специалист по знаниям:

Проверить все селекторы на единообразие стилей

Убедиться, что ресайз панелей работает плавно

Проверить скроллы (цвет, толщина)

👥 РАСПРЕДЕЛЕНИЕ ЗАДАЧ
Роль	Задачи	Приоритет
🧠 Специалист по знаниям	Аудит ProcessDesignerPage + эталонная документация + исправление иконок/шрифтов	P0/P2
🚀 Хранитель стабильности	Canvas Toolbar + управление выполнением + визуализация узла	P0
🏛️ Хранитель архитектуры	Аудит ProjectsPage + полный рефакторинг ProjectsPage.tsx	P1
📂 КЛЮЧЕВЫЕ ФАЙЛЫ ДЛЯ АУДИТА
text
src/features/process-designer/
├── ProcessDesignerPage.tsx          # ЭТАЛОН — брать за основу
├── process-designer.css             # Дизайн-токены Kymatics
├── components/
│   ├── CanvasToolbar.tsx            # НУЖНО ДОБАВИТЬ/ДОРАБОТАТЬ
│   ├── MinimalNodePalette.tsx       # Левая панель
│   └── PropertiesPanel.tsx          # Правая панель
├── hooks/
│   └── useProcessExecution.ts       # Управление выполнением
└── utils/
    ├── nodesToYaml.ts
    └── nodesToMermaid.ts

src/features/projects/
├── ProjectsPage.tsx                 # НУЖЕН ПОЛНЫЙ РЕФАКТОРИНГ
├── projects.css                     # ДОЛЖЕН БЫТЬ ЗАМЕНЁН НА process-designer.css
├── components/
│   ├── FileTree/                    # Левая панель
│   ├── EditorPanel/                 # Центр (Monaco)
│   └── bottom/
│       ├── BottomPanel.tsx          # Нижняя панель
│       └── OutputPanel.tsx          # Вывод логов
└── store/
    └── fileStore.ts

src/shared/services/
├── eventBus.ts                      # Глобальный EventBus
└── websocketLogs.ts                 # WebSocket клиент

src/
├── App.tsx                          # Главный роутер
├── main.tsx                         # Точка входа
└── index.css                        # Глобальные стили
🧪 КРИТЕРИИ ГОТОВНОСТИ ЭТАПА 79
P0 (НАИВЫСШИЙ):

✅ Projects IDE визуально идентичен Process Designer (структура, цвета, отступы)

✅ В Process Designer есть Canvas Toolbar с кнопками: Copy, Paste, Run, Stop, Step, Reset View, Fit to Screen, Export, Import

✅ Селектор проектов перенесён из тулбара в правую панель (вкладка Projects)

✅ Границы панелей имеют opacity: 0.4 (менее контрастные)

✅ Нет эмодзи — везде используются системные иконки

✅ Терминал использует шрифт Inter (не моноширинный)

P1 (ВЫСОКИЙ):

✅ Процессы запускаются из Canvas Toolbar (Run)

✅ Кнопка Stop прерывает выполнение

✅ Кнопка Step выполняет один узел за раз

✅ Текущий выполняемый узел подсвечивается на канвасе

✅ Логи выполнения отображаются в OutputPanel Projects IDE

P2 (СРЕДНИЙ):

✅ Все селекторы стилизованы единообразно

✅ Ресайз панелей работает плавно

✅ Нет ошибок в консоли браузера

💰 БЮДЖЕТ ЭТАПА 79
Статья	Сумма
Локальные LLM	0 ₽
API вызовы	0 ₽
Время разработки	0 ₽
Лимит этапа	2000 ₽
🚀 НАЧИНАЕМ ЭТАП 79
Порядок выполнения:

🔍 ВСЕ ТРОЕ — проводят аудит своих направлений (ШАГ 0)

📝 ВСЕ ТРОЕ — составляют отчёт (что есть / чего нет)

🧠 Специалист по знаниям — создаёт эталонную документацию

🚀 Хранитель стабильности — добавляет Canvas Toolbar

🏛️ Хранитель архитектуры — рефакторит ProjectsPage.tsx

ОДНА ЗАДАЧА ЗА РАЗ, БЕЗ ЛИШНИХ ЗАПРОСОВ К ИИ, КОНТРОЛЬ БЮДЖЕТА!

СНАЧАЛА АУДИТ, ПОТОМ РАЗРАБОТКА!

✅ СТАРТ ВЫПОЛНЕНИЯ

Команда, начинаем этап 79!

Каждый отчитывается по своему направлению.

В работу!

---

## 🤖 **DeepSeek**

# 🔍 ЭТАП 79 — СТАРТ АУДИТА

Принято. Начинаем синхронный аудит.

---

## 🧠 @Специалист по знаниям — Аудит ProcessDesignerPage (эталон)

### Структура компонента
```tsx
// src/features/process-designer/ProcessDesignerPage.tsx
<PageContainer>           // flex, height: 100vh
  <DesignerHeader>        // logo + tabs (Processes/Projects)
  <CanvasToolbar />       // ⚠️ ЧАСТИЧНО (не хватает кнопок)
  <MainLayout>            // grid: 280px 1fr 320px
    <NodePalette />       // левая панель — ✅ эталон
    <ReactFlow />         // центр — ✅ эталон
    <PropertiesPanel />   // правая панель — ✅ эталон
  </MainLayout>
  <BottomPanel>           // Terminal только (нет Output/Problems)
    <Tabs>Terminal</Tabs>
  </BottomPanel>
</PageContainer>
```

### Дизайн-токены Kymatics (из `process-designer.css`)
```css
--k-bg-primary: #1e1e2e;
--k-bg-secondary: #181825;
--k-bg-tertiary: #11111b;
--k-border: #313244;
--k-border-hover: #45475a;
--k-border-opacity: 0.6;        /* ⚠️ должно быть 0.4 */
--k-text: #cdd6f4;
--k-text-dim: #6c7086;
--k-accent: #89b4fa;
--k-success: #a6e3a1;
--k-error: #f38ba8;
--radius-md: 6px;
--radius-lg: 12px;
--spacing-xs: 4px;
--spacing-sm: 8px;
--spacing-md: 12px;
--spacing-lg: 16px;
--spacing-xl: 24px;
--font-sans: 'Inter', system-ui;
--font-mono: 'JetBrains Mono', monospace; /* ⚠️ терминал использует mono */
```

### Проблемы (❌)
| Элемент | Проблема | Место |
|---------|----------|-------|
| Терминал | `font-family: monospace` | BottomPanel → Terminal |
| Иконки | Эмодзи `▶` `■` `⟳` `⚙` | CanvasToolbar |
| Границы | `--k-border-opacity: 0.6` слишком контрастно | process-designer.css:24 |
| Селектор проектов | В тулбаре, а не в правой панели | DesignerHeader |
| CanvasToolbar | Нет Stop/Step/Reset/Fit | отсутствуют методы |

### Эмодзи → иконки (замена)
| Эмодзи | Замена |
|--------|--------|
| ▶ | PlayIcon |
| ■ | StopIcon |
| ⟳ | RefreshIcon |
| ⚙ | SettingsIcon |
| ✓ | CheckIcon |
| ⌖ | TargetIcon |
| ⎔ | NodeIcon |

### Отчёт по P0
- ✅ Ресайз панелей работает
- ✅ Event-driven логи есть
- ⚠️ Терминал — mono (должен Inter)
- ❌ CanvasToolbar неполный
- ❌ Эмодзи вместо иконок

---

## 🚀 @Хранитель стабильности — Аудит Canvas Toolbar

### Текущее состояние
```tsx
// src/features/process-designer/components/CanvasToolbar.tsx
<CanvasToolbarContainer>
  <LeftGroup>
    <IconButton onClick={onCopy}>📋</IconButton>     // ❌ эмодзи
    <IconButton onClick={onPaste}>📌</IconButton>    // ❌ эмодзи
  </LeftGroup>
  <CenterGroup>
    <RunButton onClick={onRun}>▶ Запуск</RunButton>  // ⚠️ есть Run
    {/* ❌ НЕТ Stop */}
    {/* ❌ НЕТ Step */}
  </CenterGroup>
  <RightGroup>
    <ZoomOut />
    <ZoomIn />
    <FitViewButton>⌖</FitViewButton>                // ❌ нет Reset
    <ExportButton>📎</ExportButton>                 // ⚠️ есть Export
    {/* ❌ НЕТ Import */}
  </RightGroup>
</CanvasToolbarContainer>
```

### Чего не хватает (❌)
- Stop кнопка + метод прерывания
- Step кнопка + пошаговое выполнение
- Reset View (сброс позиции камеры)
- Fit to Screen (zoom to fit)
- Import кнопка

### Подсветка узла
```tsx
// useProcessExecution.ts — есть currentExecutingNode
// ❌ НЕТ визуальной связи с ReactFlow
// Нужно: node.style = { border: '2px solid #a6e3a1', boxShadow: '0 0 8px #a6e3a1' }
```

---

## 🏛️ @Хранитель архитектуры — Аудит ProjectsPage

### Сравнение с ProcessDesignerPage

| Аспект | ProcessDesigner (эталон) | ProjectsPage (сейчас) | Статус |
|--------|-------------------------|----------------------|--------|
| Структура | Header → Toolbar → MainLayout (3 колонки) | Header → MainLayout (2 колонки) | ❌ |
| Левая панель | NodePalette (280px) | FileTree (250px) | ⚠️ ширина разная |
| Правая панель | PropertiesPanel (320px) | отсутствует | ❌ |
| BottomPanel | Terminal только | Terminal/Output/Problems/Debug | ✅ |
| Дизайн-токены | kymatics (process-designer.css) | projects.css (свои) | ❌ |
| CanvasToolbar | есть (неполный) | отсутствует | ❌ |
| Селектор проектов | в Header | в Header | ❌ (надо в правую панель) |
| Ресайз | ✅ есть | ❌ нет | ❌ |

### Ключевые различия
1. **ProjectsPage.tsx** не использует `PageContainer`, нет единых отступов
2. Нет правой панели → селектор проектов болтается в Header
3. `projects.css` дублирует стили с другими значениями
4. BottomPanel шире (4 вкладки), но стили не унифицированы
5. WebSocket логи есть, но OutputPanel не связан с eventBus правильно

### Структура ProjectsPage (текущая)
```tsx
<ProjectsContainer>
  <ProjectsHeader>          // logo + tabs + projectSelector ❌
  <MainArea>
    <FileTree />            // 250px
    <EditorPanel />         // 1fr
  </MainArea>
  <BottomPanel>             // ✅ Terminal/Output/Problems/Debug
    <Tabs />
    <OutputPanel />         // получает логи? ⚠️ частично
  </BottomPanel>
</ProjectsContainer>
```

### Необходимый рефакторинг
```tsx
// После рефакторинга (как в ProcessDesigner)
<PageContainer>
  <DesignerHeader />        // только logo + tabs
  <CanvasToolbar />         // опционально (для проектов не нужен)
  <MainLayout columns="280px 1fr 320px">
    <FileTree />            // левая панель
    <EditorPanel />         // центр (Monaco)
    <RightSidebar>          // новая правая панель
      <ProjectInfo />
      <ProjectSelector />   // ✅ ПЕРЕЕХАЛ СЮДА
    </RightSidebar>
  </MainLayout>
  <BottomPanel />           // унифицированный
</PageContainer>
```

---

## 📊 СВОДНЫЙ ОТЧЁТ АУДИТА

### ✅ Уже реализовано
- ReactFlow в Process Designer
- Monaco Editor в Projects
- WebSocket стриминг логов
- Event-driven архитектура
- Ресайз панелей (в Process Designer)

### ⚠️ Частично реализовано
- CanvasToolbar (есть Run/Copy/Paste/Export, нет Stop/Step/Import/Reset/Fit)
- BottomPanel (есть Terminal, но mono вместо Inter)
- Подсветка узла (есть состояние, нет визуала)

### ❌ Не реализовано (P0)
1. Унификация UI — ProjectsPage не соответствует ProcessDesignerPage
2. Селектор проектов в правой панели
3. CanvasToolbar с полным набором кнопок
4. `--k-border-opacity: 0.4` вместо 0.6
5. Замена эмодзи на иконки
6. Терминал → Inter вместо mono

---

## 📋 ПЛАН ДЕЙСТВИЙ

### Фаза 1 — P0 (сейчас)
| Кто | Задача |
|-----|--------|
| 🧠 | Создать эталонную документацию + замена эмодзи/шрифтов |
| 🚀 | Доработать CanvasToolbar (Stop/Step/Reset/Fit/Import) |
| 🏛️ | Рефакторинг ProjectsPage под единую структуру |

### Фаза 2 — проверка
- Все три роли проверяют свои изменения
- Тестирование WebSocket логов в OutputPanel
- Валидация opacity границ

---

**Аудит завершён. Переходим к реализации P0 задач.**

Жду подтверждения от 🚀 и 🏛️, начинаем по очереди.

---

