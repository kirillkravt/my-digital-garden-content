---
title: "Полный тест пайплайна публикации"
tags: [test, pipeline, full]
category: Тестирование
status: draft
---
# Полный тест автоматического пайплайна
## Что проверяем:
1. ✅ fswatch детектирует файл
2. ✅ Автоматический git commit и push
3. ✅ GitHub webhook на VPS
4. ✅ Импорт статьи с автоматической генерацией slug
5. ✅ Принудительная публикация (игнорируя draft)
## Ожидаемый результат:
Статья должна появиться по URL:
`http://109.196.98.128/articles/polnyy-test-payplayna-publikatsii/`
Создано: $(date)