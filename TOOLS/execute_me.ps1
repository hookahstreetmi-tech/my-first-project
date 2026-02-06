# Очистка устаревших снапшотов
Remove-Item "AI_HISTORY/SNAPSHOTS/2026-02-05_Multi-tenant_Strategy.md" -ErrorAction SilentlyContinue
Remove-Item "AI_HISTORY/SNAPSHOTS/SNAPSHOT_31.01.26.md" -ErrorAction SilentlyContinue
Remove-Item "AI_HISTORY/SNAPSHOTS/SNAPSHOT_03.02.26-FINAL_AUTO.md" -ErrorAction SilentlyContinue

# Git операции
git add .
git commit -m "feat(calendar): внедрение Multi-tenant архитектуры ✅

- Исправлен проброс Calendar ID через системный промпт и `$fromAI`.
- Устранена ошибка null в триггере под-воркфлоу (очистка схемы).
- Оптимизирован промпт диспетчера (удалено дублирование).
- Обновлен MASTER_TASKS.md: этап Multi-tenant завершен.
- Проведена чистка устаревших снапшотов в AI_HISTORY."
git push
