# 📊 АУДИТ СИСТЕМ ДОКУМЕНТАЦИИ UCH
Дата: Sun Jan  4 15:12:30 MSK 2026

## 📈 СТАТИСТИКА ДОКУМЕНТОВ

## 📈 СТАТИСТИКА ДОКУМЕНТОВ

## 📈 СТАТИСТИКА ДОКУМЕНТОВ

Всего .md файлов: 490

### Распределение по уровням:
  23 level: 3
  22 level: 2
  12 level: 1
  11 level: 4
   6 level: "N"
   3 level: {level}
   2 level: "2"
   1 level: 3         # вычисляется автоматически
   1 # Автоматическое определение type по level:

### Распределение по типам:
  22 type: "task"
  17 type: "component"
  10 type: "line"
   7 type: "snapshot"
   6 type: "solution"
   6 type: "idea"
   4     type: "project"
   3     type: "line"
   2 type: "test"
   2 type: "project"

### Распределение по статусам:
  49 status: "active"
  26 status: "planning"
   1 status: published  # или draft, archived
   1 status: done
   1 status: "done"
   1 status: "active" # или planning, in_progress, done, archived
   1 3. Для черновиков использовать `status: draft`

## 🛠️ СИСТЕМЫ АВТОМАТИЗАЦИИ

Всего скриптов .sh: 56

### Категоризация скриптов:

#### uch-* скрипты (основные):
uch-basic-collector.sh
uch-create-modular.sh
uch-create-simple.sh
uch-create-unified-fixed-backup-20251228-085210.sh
uch-create-unified-fixed-v2.sh
uch-create-unified-fixed.sh
uch-create-unified.sh
uch-create-v2.sh
uch-create-v3.sh
uch-create.sh
uch-cron-manager.sh
uch-docs-analyzer.sh
uch-generate-full-report.sh
uch-metrics-collector.sh
uch-project-tech-collector.sh
uch-report-generator.sh
uch-tech-debt-analyzer.sh
uch-tech-debt-analyzer.sh

#### step-* скрипты (временные):
step1-analyze-templates.sh
step3-analyze-random-docs.sh
step3-correct-search.sh
step3-find-general-info.sh
step4-safe-remove-general-info.sh
step5-test-simple.sh

#### test-* скрипты (тестовые):
test_migration.sh
test-general-info-removal.sh

#### Другие скрипты:
add_slug_simple.sh
add_slugs.sh
analyze_migration_fixed.sh
analyze_migration.sh
analyze-all.sh
analyze-doc.sh
analyze-file-names.sh
batch-mode.sh
check_frontmatter.sh
check-conflicts-simple.sh
check-id-conflicts-fixed.sh
check-id-conflicts.sh
convert-specific.sh
create.sh
document-creator.sh
fix_frontmatter.sh
fix-conflicts-with-shift.sh
fix-id-conflicts.sh
main.sh
manual-mode.sh
migrate_documents.sh
remove-all-general-info.sh
remove-general-info-final.sh
replace-document-v2.sh
replace-document.sh
replace-shift-fixed.sh
replace-shift.sh
simple_rename.sh
types.sh
utils.sh

## 🔗 АНАЛИЗ СВЯЗЕЙ МЕЖДУ ДОКУМЕНТАМИ

### Документы без родителя (уровень 1):
00 - UCH.md
01 - ТЕКУЩИЙ ПРОГРЕСС.md
04 - Линия Г. Документация.md
04-01-03 - Documentation-first подход.md
04-02-01 - Улучшение системы документации uch-docs.md
05 - UCH Music concept.md
50 - CURRENT.md
51 - КАНБАН-ЗАДАЧ.md
52 - АРХИТЕКТУРА.md
53 - TECH-DEBT.md
55 - Системный промпт.md
90 - Проект Отчеты и аналитика UCH.md

### Документы с родителем (иерархические):
Всего документов с parent: 27


## 🔢 ПРОВЕРКА HEX-НУМЕРАЦИИ

### Документы с HEX ID в имени файла:
Количество: 283

### Документы БЕЗ HEX ID в имени файла:
Z-20251228113837 - Задача архивации.md
T-MASTER.md
20251228-125312-00-04-09 - Тест ручного создания.md
20251228-142443-00-04-06 - Тест замены с созданием документа.md
20251229-131917-05-03 - Тестовый модуль 3.md
20251228-132026-00-04-08-Тест правильных тегов.md
20251228-135910-00-04-08-Тест Замены.md
Z-20251228113756 - Добавить смещение документов при ручном создании с существующим id.md
02-КАНБАН-ЗАДАЧ.md
5-301 Системный промпт.md


## 📊 СИСТЕМА ОТЧЕТОВ (ПРОЕКТ 90)

### Файлы проекта 90:
90
90-01
90-01

### Скрипты генерации отчётов:
uch-basic-collector.sh
analyze-doc.sh
check-id-conflicts.sh
analyze-all.sh
uch-generate-full-report.sh
uch-report-generator.sh
uch-docs-analyzer.sh
uch-project-tech-collector.sh
uch-tech-debt-analyzer.sh
uch-cron-manager.sh
uch-tech-debt-analyzer.sh
uch-metrics-collector.sh
