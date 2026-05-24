---
chat_id: 5dee1dc6-1508-4f90-a8d7-51063b347800
title: Встраивание Streamlit в блог
message_count: 8
exported_at: 2026-05-24T19:23:00.753Z
---

# Встраивание Streamlit в блог

## 👤 **Kirill**

Как добавлять html в фрейме в блог? Как добавить фрейм streamlit с командным центром в статью блога для демо/превью

---

## 🤖 **DeepSeek**

Чтобы добавить в блог живое демо вашего Streamlit-приложения, нужно пройти два шага: сначала опубликовать само приложение в интернете, а затем встроить его в пост с помощью HTML-кода.

Вот пошаговая инструкция, как это сделать.

---

### Шаг 1: Публикация Streamlit-приложения (Деплой)

Прежде чем встраивать приложение, оно должно быть доступно в интернете. Самый простой и бесплатный способ — использовать **Streamlit Community Cloud**.

1.  **Подготовьте файлы:** Убедитесь, что ваш проект (файл `app.py` и `requirements.txt` со всеми библиотеками) загружен в **публичный** репозиторий на **GitHub** [citation:5].
2.  **Задеплойте приложение:**
    *   Зайдите на [Streamlit Community Cloud](https://streamlit.io/cloud) и войдите через GitHub.
    *   Нажмите **"New app"** и выберите ваш репозиторий, ветку (`main`) и основной файл (`app.py`).
    *   Нажмите **"Deploy"**.
3.  **Скопируйте ссылку:** Через пару минут ваше приложение будет доступно по адресу `https://название_проекта.streamlit.app`. Это и есть ваша ссылка для вставки [citation:5].

### Шаг 2: Встраивание в блог (Добавление HTML)

Большинство современных блогов (WordPress, Wix, Tilda, Hexo) поддерживают вставку HTML-кода напрямую в пост.

#### Способ А: Базовый HTML-код (iframe)

Это универсальный способ, который подходит для 99% платформ. **Обязательно** добавьте параметр `?embed=true` в конец вашей URL. Он убирает лишние элементы интерфейса Streamlit, оставляя чистое приложение [citation:2].

**Скопируйте и вставьте этот код в редактор блога (в режиме "Исходный код" или "HTML"):**

```html
<iframe 
    src="https://ВАША_ССЫЛКА.streamlit.app/?embed=true" 
    height="650" 
    width="100%" 
    style="border: none; border-radius: 12px; box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
</iframe>
```
*Не забудьте заменить `ВАША_ССЫЛКА` на название вашего приложения.*

#### Способ Б: "Суперчистый" вид (продвинутый)

Если вы хотите скрыть даже полосу прокрутки или убрать отступы, используйте параметры `embed_options` [citation:2].

```html
<iframe 
    src="https://ВАША_ССЫЛКА.streamlit.app/?embed=true&embed_options=disable_scrolling&embed_options=light_theme" 
    height="600" 
    width="100%" 
    style="border: none;">
</iframe>
```

#### Способ В: Самый простой (для Medium/Notion)

Если вы ведете блог на **Medium**, **Notion** или **Ghost**, вам не нужен никакой код. Эти платформы поддерживают протокол oEmbed [citation:2].

*   **Что делать:** Просто вставьте чистую ссылку на ваше приложение (`https://название.streamlit.app`) в новый абзац и нажмите Enter. Превью подтянется автоматически.

### Шаг 3: Настройка внешнего вида

Убедитесь, что фрейм выглядит как часть статьи:

*   **Высота (`height`)**: Угадать точную высоту сложно, так как интерактивные элементы могут менять размер. Поставьте `height="650"` или `"750"`. Если внутри будет скролл, пользователь сможет прокрутить само окно фрейма [citation:5].
*   **Стили**: Добавьте в тег `style` параметры `border-radius` (закругление углов) и `box-shadow` (тень), чтобы визуально отделить демо от текста [citation:5].
*   **Ограничения**: Помните, что поисковые системы не индексируют контент внутри фрейма (это не влияет на SEO ни плохо, ни хорошо), а некоторые сайты могут блокировать возможность вставки через заголовки безопасности [citation:1].

### Краткий чек-лист

1.  [ ] Приложение залито на GitHub (публично).
2.  [ ] Приложение задеплоено на `streamlit.app`.
3.  [ ] В ссылку добавлен параметр **`?embed=true`**.
4.  [ ] Код вставлен в блог через блок **"HTML"** (не просто как текст).

---

## 👤 **Kirill**

статьи для блога пишу в obsidian как добавить фрейм в md файлы?

---

## 🤖 **DeepSeek**

В Obsidian ситуация немного сложнее, чем в обычном HTML-редакторе блога. По умолчанию Obsidian не позволяет вставлять произвольные HTML-элементы, такие как `<iframe>`, из соображений безопасности[citation:9][citation:5]. Однако это ограничение можно обойти с помощью плагинов.

Вот два основных способа добавить фрейм с вашим Streamlit-приложением в заметку Obsidian.

### Способ 1: Прямая вставка HTML (без плагинов)

Перед тем как пробовать плагины, стоит проверить, работает ли простой HTML-код в вашей версии Obsidian.

1. Переключите заметку в **Режим источника** (Source mode). В последних версиях Obsidian это может работать и в режиме чтения, но для надежности используйте исходный режим.
2. Вставьте следующий код, заменив URL на ваш:

```html
<iframe src="https://ВАША_ССЫЛКА.streamlit.app/?embed=true&embed_options=light_theme" width="100%" height="500" style="border: none; border-radius: 8px;"></iframe>
```

**Важно:** Этот метод может не сработать, так как Obsidian в целях безопасности фильтрует опасные HTML-теги. Если вместо фрейма вы видите пустое место или просто текст — переходите ко второму способу.

### Способ 2: Плагин Custom Frames (рекомендуемый)

Это самый надежный и удобный способ для встраивания любых веб-страниц (YouTube, Figma, Streamlit и т.д.) в Obsidian[citation:3][citation:7].

#### Шаг 1: Установка плагина
1. Откройте **Настройки Obsidian** → **Сторонние плагины** → **Сообщество**.
2. Снимите галочку "Безопасный режим", если он включен.
3. Нажмите **Обзор** и найдите плагин **Custom Frames**.
4. Установите и включите его.

#### Шаг 2: Настройка фрейма для Streamlit
1. В настройках плагина нажмите **Add new frame**.
2. Заполните поля:
   * **Display Name**: `Streamlit Demo` (или любое другое название).
   * **URL**: Вставьте ссылку на ваше приложение `https://ваш_проект.streamlit.app/`.
   * **Embed/Open in**: Выберите **Markdown** — это позволит встраивать фрейм прямо в текст заметок[citation:3][citation:7].
   * При необходимости вы можете добавить **Custom CSS**, чтобы убрать поля или скрыть скролл.

#### Шаг 3: Вставка в заметку
Теперь в любой заметке напишите следующий код:

````
```custom-frames
frame: Streamlit Demo
style: height: 600px;
```
````

**Как это работает**: Плагин найдет блок кода `custom-frames`, прочитает имя фрейма, которое вы указали в настройках (`Streamlit Demo`), и заменит этот блок на ваш iframe[citation:3][citation:7].

### Важные нюансы и ограничения

1. **Безопасный режим:** Если вы выключите все сторонние плагины, фреймы перестанут отображаться. Это нормально, так как безопасный режим отключает кастомный код[citation:9].
2. **Режимы просмотра:** Фреймы отлично работают в режиме **Чтения** (Reading View) и в **Live Preview**. В режиме "Исходный код" вы будете видеть только сам код[citation:3][citation:9].
3. **Мобильная версия:** Будьте осторожны. На телефонах Obsidian работает не на Electron (как на ПК), а на нативном движке, который часто блокирует iframe из-за политик безопасности[citation:3][citation:7]. Многие сайты, требующие авторизации, на мобильных устройствах работать не будут.
4. **Параметры в URL:** Не забывайте про `?embed=true` в конце ссылки на Streamlit. Это убирает лишние кнопки "Сделать форк", меню и оставляет чистое приложение.

### Альтернативный вариант (продвинутый)

Если вы хотите встроить **локальный** HTML-файл (лежащий у вас на компьютере), плагин `Custom Frames` не подойдет. Для этого существует плагин **Iframe Renderer**. Он позволяет писать в заметке `!iframe[мой_файл.html]`, и такой код заменится на фрейм с содержимым вашего локального файла[citation:1].

### Итог

Для вашей задачи — вставки Streamlit-приложения в заметку — лучший выбор — **Custom Frames**. Установите плагин, создайте в нем один раз фрейм для вашего приложения, а затем вставляйте его в любые заметки с помощью простого блока кода. Это быстро, красиво и не требует постоянного копирования HTML-тегов.

---

## 👤 **Kirill**

Изучи readme paperclip
Как встроить его в командный центр?

---

## 🤖 **DeepSeek**

Прошу прощения за путаницу — оказывается, существует два совершенно разных проекта с одинаковым названием **Paperclip**. Вы спрашиваете о совершенно новом инструменте (AI-оркестрация), а не о старом Ruby-плагине для загрузки файлов!

## Какой Paperclip вас интересует?

Похоже, речь идет о **Paperclip** — новом Open Source фреймворке для оркестрации AI-агентов, который в марте 2026 года набрал 24 000+ звезд на GitHub [citation:8]. Это **Node.js сервер + React UI**, который превращает группу AI-агентов в структурированную компанию с организационной структурой, бюджетами и задачами [citation:2][citation:7].

Если же вы имели в виду старый Ruby-гем Paperclip (для загрузки файлов в Rails) — дайте знать, я дам инструкции для него.

---

## Что такое Paperclip (AI-оркестратор)

Paperclip решает проблему хаоса, когда у вас открыто 10+ терминалов с разными AI-агентами, и никто не знает, кто что делает и сколько тратит [citation:8].

**Ключевые возможности:**
- **Оргструктура** — у каждого агента есть роль, должность, руководитель [citation:10]
- **Бюджетирование** — месячные лимиты на токены, авто-остановка при превышении [citation:7]
- **Heartbeat-механизм** — агенты просыпаются по расписанию, выполняют задачи и "засыпают" [citation:10]
- **Система тикетов** — все задачи как в Jira, с трекингом и аудитом [citation:8]
- **Совместимость** — работает с Claude Code, Codex, Cursor, Gemini CLI, Bash, HTTP [citation:7]

---

## Как встроить Paperclip в командный центр

Вы хотите использовать Paperclip как **командный центр** для управления AI-агентами. Вот пошаговая инструкция:

### Шаг 1: Быстрый запуск (5 минут)

```bash
# Самый простой способ — одной командой
npx paperclipai onboard --yes
```

После выполнения:
- Paperclip запустится на `http://localhost:3100`
- Встроенная PostgreSQL создастся автоматически
- Вы сразу попадете в дашборд [citation:2][citation:10]

**Ручная установка** (если нужно): 
```bash
git clone https://github.com/paperclipai/paperclip.git
cd paperclip
pnpm install
pnpm dev
```

### Шаг 2: Создайте компанию и задайте миссию

В веб-интерфейсе `http://localhost:3100`:
1. Нажмите **"Create Company"**
2. Введите миссию, например: *"Создать API для управления заказами клиентов. Приоритет — корректность над скоростью"*

Эта миссия будет передаваться каждому агенту как контекст [citation:7].

### Шаг 3: Наймите первого агента (CEO)

В дашборде добавьте агента через CLI:
```bash
paperclipai agent local-cli "CEO" --company-id <your-company-id>
```

Настройте для CEO:
- **adapterType**: `claude_local` (если используете Claude) или `codex_local` (OpenAI)
- **model**: `claude-sonnet-4-6` или `claude-opus-4-6` (для стратегических задач)
- **budgetMonthlyCents**: `20000` ($20 в месяц) [citation:7]

### Шаг 4: Создайте организационную структуру

CEO автоматически предложит нанять других агентов. Типовая структура для командного центра [citation:7]:
```
CEO (Sonnet — стратегия)
 └── CTO (Haiku — маршрутизация)
      ├── Backend Engineer (Sonnet — код)
      ├── QA Engineer (Haiku — тесты)
      └── Technical Writer (Haiku — документация)
```

Добавляйте агентов командой:
```bash
paperclipai agent local-cli "Backend Engineer" --company-id <id>
```

### Шаг 5: Создавайте задачи через CLI или UI

**Через CLI:**
```bash
paperclipai issue create \
  --company-id <id> \
  --title "Добавить пагинацию в GET /orders" \
  --assignee-agent-id <backend-engineer-id> \
  --description "Добавить параметры page и limit. Возвращать { data: [], total: 0 }"
```

**Через UI:** Откройте `http://localhost:3100` → Issues → Create [citation:7]

### Шаг 6: Настройте Heartbeat (расписание)

Для каждого агента задайте интервал пробуждения:
- **Coding agents**: `600` секунд (10 минут)
- **On-demand**: `86400` секунд (раз в день) [citation:7]

Это экономит токены — агенты не висят постоянно онлайн.

### Шаг 7: Управляйте бюджетом

Paperclip автоматически:
- Останавливает агента при превышении лимита (`spentMonthlyCents >= budgetMonthlyCents`)
- На 80% использования переводит в режим "только критические задачи"
- Вед

---

## 👤 **Kirill**

Изучи readme paperclip
Как встроить его в командный центр?

<p align="center">
  <img src="doc/assets/header.png" alt="Paperclip — runs your business" width="720" />
</p>

<p align="center">
  <a href="#quickstart"><strong>Quickstart</strong></a> &middot;
  <a href="https://paperclip.ing/docs"><strong>Docs</strong></a> &middot;
  <a href="https://github.com/paperclipai/paperclip"><strong>GitHub</strong></a> &middot;
  <a href="https://discord.gg/m4HZY7xNG3"><strong>Discord</strong></a>
</p>

<p align="center">
  <a href="https://github.com/paperclipai/paperclip/blob/master/LICENSE"><img src="https://img.shields.io/badge/license-MIT-blue" alt="MIT License" /></a>
  <a href="https://github.com/paperclipai/paperclip/stargazers"><img src="https://img.shields.io/github/stars/paperclipai/paperclip?style=flat" alt="Stars" /></a>
  <a href="https://discord.gg/m4HZY7xNG3"><img src="https://img.shields.io/discord/000000000?label=discord" alt="Discord" /></a>
</p>

<br/>

<div align="center">
  <video src="https://github.com/user-attachments/assets/773bdfb2-6d1e-4e30-8c5f-3487d5b70c8f" width="600" controls></video>
</div>

<br/>

## What is Paperclip?

# Open-source orchestration for zero-human companies

**If OpenClaw is an _employee_, Paperclip is the _company_**

Paperclip is a Node.js server and React UI that orchestrates a team of AI agents to run a business. Bring your own agents, assign goals, and track your agents' work and costs from one dashboard.

It looks like a task manager — but under the hood it has org charts, budgets, governance, goal alignment, and agent coordination.

**Manage business goals, not pull requests.**

|        | Step            | Example                                                            |
| ------ | --------------- | ------------------------------------------------------------------ |
| **01** | Define the goal | _"Build the #1 AI note-taking app to $1M MRR."_                    |
| **02** | Hire the team   | CEO, CTO, engineers, designers, marketers — any bot, any provider. |
| **03** | Approve and run | Review strategy. Set budgets. Hit go. Monitor from the dashboard.  |

<br/>

> **COMING SOON: Clipmart** — Download and run entire companies with one click. Browse pre-built company templates — full org structures, agent configs, and skills — and import them into your Paperclip instance in seconds.

<br/>

<div align="center">
<table>
  <tr>
    <td align="center"><strong>Works<br/>with</strong></td>
    <td align="center"><img src="doc/assets/logos/openclaw.svg" width="32" alt="OpenClaw" /><br/><sub>OpenClaw</sub></td>
    <td align="center"><img src="doc/assets/logos/claude.svg" width="32" alt="Claude" /><br/><sub>Claude Code</sub></td>
    <td align="center"><img src="doc/assets/logos/codex.svg" width="32" alt="Codex" /><br/><sub>Codex</sub></td>
    <td align="center"><img src="doc/assets/logos/cursor.svg" width="32" alt="Cursor" /><br/><sub>Cursor</sub></td>
    <td align="center"><img src="doc/assets/logos/bash.svg" width="32" alt="Bash" /><br/><sub>Bash</sub></td>
    <td align="center"><img src="doc/assets/logos/http.svg" width="32" alt="HTTP" /><br/><sub>HTTP</sub></td>
  </tr>
</table>

<em>If it can receive a heartbeat, it's hired.</em>

</div>

<br/>

## Paperclip is right for you if

- ✅ You want to build **autonomous AI companies**
- ✅ You **coordinate many different agents** (OpenClaw, Codex, Claude, Cursor) toward a common goal
- ✅ You have **20 simultaneous Claude Code terminals** open and lose track of what everyone is doing
- ✅ You want agents running **autonomously 24/7**, but still want to audit work and chime in when needed
- ✅ You want to **monitor costs** and enforce budgets
- ✅ You want a process for managing agents that **feels like using a task manager**
- ✅ You want to manage your autonomous businesses **from your phone**

<br/>

## Features

<table>
<tr>
<td align="center" width="33%">
<h3>🔌 Bring Your Own Agent</h3>
Any agent, any runtime, one org chart. If it can receive a heartbeat, it's hired.
</td>
<td align="center" width="33%">
<h3>🎯 Goal Alignment</h3>
Every task traces back to the company mission. Agents know <em>what</em> to do and <em>why</em>.
</td>
<td align="center" width="33%">
<h3>💓 Heartbeats</h3>
Agents wake on a schedule, check work, and act. Delegation flows up and down the org chart.
</td>
</tr>
<tr>
<td align="center">
<h3>💰 Cost Control</h3>
Monthly budgets per agent. When they hit the limit, they stop. No runaway costs.
</td>
<td align="center">
<h3>🏢 Multi-Company</h3>
One deployment, many companies. Complete data isolation. One control plane for your portfolio.
</td>
<td align="center">
<h3>🎫 Ticket System</h3>
Every conversation traced. Every decision explained. Full tool-call tracing and immutable audit log.
</td>
</tr>
<tr>
<td align="center">
<h3>🛡️ Governance</h3>
You're the board. Approve hires, override strategy, pause or terminate any agent — at any time.
</td>
<td align="center">
<h3>📊 Org Chart</h3>
Hierarchies, roles, reporting lines. Your agents have a boss, a title, and a job description.
</td>
<td align="center">
<h3>📱 Mobile Ready</h3>
Monitor and manage your autonomous businesses from anywhere.
</td>
</tr>
</table>

<br/>

## Problems Paperclip solves

| Without Paperclip                                                                                                                     | With Paperclip                                                                                                                         |
| ------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- |
| ❌ You have 20 Claude Code tabs open and can't track which one does what. On reboot you lose everything.                              | ✅ Tasks are ticket-based, conversations are threaded, sessions persist across reboots.                                                |
| ❌ You manually gather context from several places to remind your bot what you're actually doing.                                     | ✅ Context flows from the task up through the project and company goals — your agent always knows what to do and why.                  |
| ❌ Folders of agent configs are disorganized and you're re-inventing task management, communication, and coordination between agents. | ✅ Paperclip gives you org charts, ticketing, delegation, and governance out of the box — so you run a company, not a pile of scripts. |
| ❌ Runaway loops waste hundreds of dollars of tokens and max your quota before you even know what happened.                           | ✅ Cost tracking surfaces token budgets and throttles agents when they're out. Management prioritizes with budgets.                    |
| ❌ You have recurring jobs (customer support, social, reports) and have to remember to manually kick them off.                        | ✅ Heartbeats handle regular work on a schedule. Management supervises.                                                                |
| ❌ You have an idea, you have to find your repo, fire up Claude Code, keep a tab open, and babysit it.                                | ✅ Add a task in Paperclip. Your coding agent works on it until it's done. Management reviews their work.                              |

<br/>

## Why Paperclip is special

Paperclip handles the hard orchestration details correctly.

|                                   |                                                                                                               |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------- |
| **Atomic execution.**             | Task checkout and budget enforcement are atomic, so no double-work and no runaway spend.                      |
| **Persistent agent state.**       | Agents resume the same task context across heartbeats instead of restarting from scratch.                     |
| **Runtime skill injection.**      | Agents can learn Paperclip workflows and project context at runtime, without retraining.                      |
| **Governance with rollback.**     | Approval gates are enforced, config changes are revisioned, and bad changes can be rolled back safely.        |
| **Goal-aware execution.**         | Tasks carry full goal ancestry so agents consistently see the "why," not just a title.                        |
| **Portable company templates.**   | Export/import orgs, agents, and skills with secret scrubbing and collision handling.                          |
| **True multi-company isolation.** | Every entity is company-scoped, so one deployment can run many companies with separate data and audit trails. |

<br/>

## What Paperclip is not

|                              |                                                                                                                      |
| ---------------------------- | -------------------------------------------------------------------------------------------------------------------- |
| **Not a chatbot.**           | Agents have jobs, not chat windows.                                                                                  |
| **Not an agent framework.**  | We don't tell you how to build agents. We tell you how to run a company made of them.                                |
| **Not a workflow builder.**  | No drag-and-drop pipelines. Paperclip models companies — with org charts, goals, budgets, and governance.            |
| **Not a prompt manager.**    | Agents bring their own prompts, models, and runtimes. Paperclip manages the organization they work in.               |
| **Not a single-agent tool.** | This is for teams. If you have one agent, you probably don't need Paperclip. If you have twenty — you definitely do. |
| **Not a code review tool.**  | Paperclip orchestrates work, not pull requests. Bring your own review process.                                       |

<br/>

## Quickstart

Open source. Self-hosted. No Paperclip account required.

```bash
npx paperclipai onboard --yes
```

If you already have Paperclip configured, rerunning `onboard` keeps the existing config in place. Use `paperclipai configure` to edit settings.

Or manually:

```bash
git clone https://github.com/paperclipai/paperclip.git
cd paperclip
pnpm install
pnpm dev
```

This starts the API server at `http://localhost:3100`. An embedded PostgreSQL database is created automatically — no setup required.

> **Requirements:** Node.js 20+, pnpm 9.15+

<br/>

## FAQ

**What does a typical setup look like?**
Locally, a single Node.js process manages an embedded Postgres and local file storage. For production, point it at your own Postgres and deploy however you like. Configure projects, agents, and goals — the agents take care of the rest.

If you're a solo-entreprenuer you can use Tailscale to access Paperclip on the go. Then later you can deploy to e.g. Vercel when you need it.

**Can I run multiple companies?**
Yes. A single deployment can run an unlimited number of companies with complete data isolation.

**How is Paperclip different from agents like OpenClaw or Claude Code?**
Paperclip _uses_ those agents. It orchestrates them into a company — with org charts, budgets, goals, governance, and accountability.

**Why should I use Paperclip instead of just pointing my OpenClaw to Asana or Trello?**
Agent orchestration has subtleties in how you coordinate who has work checked out, how to maintain sessions, monitoring costs, establishing governance - Paperclip does this for you.

(Bring-your-own-ticket-system is on the Roadmap)

**Do agents run continuously?**
By default, agents run on scheduled heartbeats and event-based triggers (task assignment, @-mentions). You can also hook in continuous agents like OpenClaw. You bring your agent and Paperclip coordinates.

<br/>

## Development

```bash
pnpm dev              # Full dev (API + UI, watch mode)
pnpm dev:once         # Full dev without file watching
pnpm dev:server       # Server only
pnpm build            # Build all
pnpm typecheck        # Type checking
pnpm test:run         # Run tests
pnpm db:generate      # Generate DB migration
pnpm db:migrate       # Apply migrations
```

See [doc/DEVELOPING.md](doc/DEVELOPING.md) for the full development guide.

<br/>

## Roadmap

- ✅ Plugin system (e.g. add a knowledge base, custom tracing, queues, etc)
- ✅ Get OpenClaw / claw-style agent employees
- ✅ companies.sh - import and export entire organizations
- ✅ Easy AGENTS.md configurations
- ✅ Skills Manager
- ✅ Scheduled Routines
- ✅ Better Budgeting
- ⚪ Artifacts & Deployments
- ⚪ CEO Chat
- ⚪ MAXIMIZER MODE
- ⚪ Multiple Human Users
- ⚪ Cloud / Sandbox agents (e.g. Cursor / e2b agents)
- ⚪ Cloud deployments
- ⚪ Desktop App

<br/>

## Community & Plugins

Find Plugins and more at [awesome-paperclip](https://github.com/gsxdsm/awesome-paperclip)

## Telemetry

Paperclip collects anonymous usage telemetry to help us understand how the product is used and improve it. No personal information, issue content, prompts, file paths, or secrets are ever collected. Private repository references are hashed with a per-install salt before being sent.

Telemetry is **enabled by default** and can be disabled with any of the following:

| Method | How |
|---|---|
| Environment variable | `PAPERCLIP_TELEMETRY_DISABLED=1` |
| Standard convention | `DO_NOT_TRACK=1` |
| CI environments | Automatically disabled when `CI=true` |
| Config file | Set `telemetry.enabled: false` in your Paperclip config |

## Contributing

We welcome contributions. See the [contributing guide](CONTRIBUTING.md) for details.

<br/>

## Community

- [Discord](https://discord.gg/m4HZY7xNG3) — Join the community
- [GitHub Issues](https://github.com/paperclipai/paperclip/issues) — bugs and feature requests
- [GitHub Discussions](https://github.com/paperclipai/paperclip/discussions) — ideas and RFC

<br/>

## License

MIT &copy; 2026 Paperclip

## Star History

[![Star History Chart](https://api.star-history.com/image?repos=paperclipai/paperclip&type=date&legend=top-left)](https://www.star-history.com/?repos=paperclipai%2Fpaperclip&type=date&legend=top-left)

<br/>

---

<p align="center">
  <img src="doc/assets/footer.jpg" alt="" width="720" />
</p>

<p align="center">
  <sub>Open source under MIT. Built for people who want to run companies, not babysit agents.</sub>
</p>

---

## 🤖 **DeepSeek**

Отлично, я изучил README Paperclip. Это мощная система оркестрации агентов, которая позволяет создать "компанию с нулевым количеством людей".

Внедрить её в ваш командный центр — отличная идея. Вот пошаговое руководство, как это сделать, объединяя подходы для Obsidian, Streamlit и самого Paperclip.

### Основная концепция: Paperclip — это ваш "Командный центр"

По сути, **Paperclip и есть тот самый командный центр**, который вы хотите встроить. Он предоставляет дашборд для управления агентами, целями, задачами и бюджетом. Streamlit-приложение в вашем случае может быть одним из агентов или внешним инструментом, который Paperclip оркестрирует.

Таким образом, у вас есть два пути интеграции:

1.  **Paperclip как командный центр:** Вы встраиваете **интерфейс Paperclip** в Obsidian, чтобы управлять всем прямо из заметок.
2.  **Streamlit как агент:** Вы подключаете ваше существующее Streamlit-приложение к Paperclip в качестве одного из исполнителей (например, "Streamlit Coder").

Я опишу оба подхода, но первый — самый прямой путь к созданию командного центра.

### Способ 1: Встраивание дашборда Paperclip в Obsidian (Рекомендуемый)

Этот способ превратит Obsidian в вашу единую точку управления агентами.

#### Шаг 1. Запуск Paperclip локально
Следуя README, установите и запустите Paperclip:
```bash
npx paperclipai onboard --yes
```
После запуска API сервер будет доступен по адресу `http://localhost:3100`. Вам нужен именно веб-интерфейс Paperclip.

#### Шаг 2. Встраивание через плагин Custom Frames (как обсуждали ранее)
В Obsidian, используя плагин **Custom Frames**, создайте новый фрейм для Paperclip:

*   **Display Name**: `Paperclip HQ`
*   **URL**: `http://localhost:3100` (или внешний URL, если деплоите удаленно)
*   **Embed/Open in**: **Markdown**

После этого в любой заметке вы сможете встроить дашборд Paperclip командой:
````
```custom-frames
frame: Paperclip HQ
style: height: 700px;
```
````

**Результат:** У вас внутри Obsidian появится живой, интерактивный командный центр, где вы сможете:
*   Создавать компании и проекты.
*   Нанимать агентов (CEO, CTO, маркетологов).
*   Ставить цели и задачи (тикет-система).
*   Отслеживать расходы и управлять бюджетом.
*   Наблюдать за "сердцебиениями" (heartbeats) агентов.

### Способ 2: Подключение вашего Streamlit-приложения как агента к Paperclip

Если вы хотите, чтобы ваше Streamlit-приложение **выполняло задачи** под управлением Paperclip (например, генерировало отчеты или демо-дашборды), вам нужно зарегистрировать его в Paperclip как агента.

Paperclip работает с любым агентом, который может принимать сигналы ("heartbeats"). Ваше Streamlit-приложение должно уметь принимать HTTP-запросы от Paperclip.

#### Шаг 1. Добавьте в Streamlit эндпоинт для приема задач
Streamlit не предназначен для обработки веб-хуков "из коробки", но можно создать небольшой сервер-адаптер на FastAPI/Express, который будет:
1.  Принимать POST-запрос от Paperclip с описанием задачи.
2.  Запускать ваше Streamlit-приложение с нужными параметрами.
3.  Возвращать результат в Paperclip.

#### Шаг 2. Настройка агента в Paperclip
Через интерфейс Paperclip создайте нового агента:
*   **Имя**: `Demo Streamlit Builder`
*   **Heartbeat endpoint**: URL вашего адаптера (например, `http://localhost:8502/paperclip-task`)
*   **Skill**: Опишите, что умеет этот агент: *"Creates interactive Streamlit demos for blog posts based on task description"*

#### Шаг 3. Выдача задач
Теперь вы можете в Paperclip создать задачу для этого агента: *"Построить демо-дашборд с командным центром на Streamlit для статьи блога"*. Агент получит задачу, выполнит её (запустит Streamlit) и вернет ссылку на результат.

### Собираем всё вместе: Архитектура "Командного центра"

В итоге ваша система будет выглядеть так:

1.  **Obsidian + Custom Frames**: Центральный интерфейс, где вы пишете статьи и видите дашборд Paperclip.
2.  **Paperclip**: Бэкенд оркестрации. Содержит "компанию" со штатными агентами (включая вашего Streamlit-агента).
3.  **Streamlit App**: Один из агентов-исполнителей, специализирующийся на создании демо-контента.
4.  **Ваш Блог (через iframe)**: Конечный результат, где через HTML-фрейм публикуется готовое демо.

### Ключевые выводы из README для вашей задачи

*   **Paperclip решает вашу проблему:** Если у вас много агентов, вы теряете контроль над ними. Paperclip дает оргструктуру, бюджеты и аудит.
*   **Вы — "Совет директоров":** Вы не пишете код для каждого действия. Вы нанимаете, утверждаете стратегии и ставите цели высокого уровня ("Увеличить MRR до $1M"). Агенты сами разбивают их на задачи.
*   **"Heartbeats" — ключ к автоматизации:** Агенты работают по расписанию или по событию. Ваш Streamlit-агент может сам просыпаться каждые 4 часа, проверять новые задачи и выполнять их без вашего участия.

### Прямой ответ на ваш вопрос

> Как встроить Paperclip в командный центр?

**Вам не нужно встраивать Paperclip. Paperclip и есть ваш командный центр.** Встраивайте его интерфейс в Obsidian через `Custom Frames`, а всё остальное (включая ваше Streamlit-приложение) подключайте к нему как агентов.

Начните с простого:
1.  Запустите `npx paperclipai onboard --yes`.
2.  Встройте локальный Paperclip в Obsidian.
3.  Создайте первую компанию и наймите первого агента (например, "CEO Claude").
4.  Поэкспериментируйте с тикет-системой, поставив цель: *"Создать демо-дашборд в Streamlit для статьи блога"*.

Paperclip сам предложит вашему CEO-агенту разбить эту цель на задачи и нанять нужных исполнителей.

---

