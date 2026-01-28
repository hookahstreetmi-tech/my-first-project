# Техническое руководство по реализации Indus.8M (Final Sync v3.0)

Этот документ синхронизирован с протоколом «ВЕЧЕРИНКА» (27.01.2026) и SQL-схемой `SKRIPTS/supabase/pipeline_schema.sql`.

## 1. Архитектура Конвейера (Pipeline)

Система состоит из 4-х автономных агентов, связанных через Supabase.

| Стадия | Имя Агента (n8n) | ID Воркфлоу | Функция | Вход | Выход |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **1. Планирование** | **Topic Generator** | `QTYaCNJB6hChBlIA` | Генерирует темы для исследования. | Schedule / Trigger | Запись в `topics` (status: `pending`) |
| **2. Сбор Знаний** | **Research Team** | `ItU0fZMVllwFxFDQ` | Ищет факты по теме. | `topics` (status: `pending` -> `researching`) | Запись в `knowledge` -> `topics` (`completed`) |
| **3. Мозг** | **Brain Center** | `ggcoBC7nujBUXwmB` | Генерирует гипотезы на основе знаний. | `topics` (`completed`) | Запись в `hypotheses` |
| **4. Производство** | **Production Agent** | `n14qDgi3nFiGn9Fm` | Пишет контент/планы. | `hypotheses` (выбор пользователя) | Запись в `content` -> Telegram |

### Пульт управления "Автопилот"
Для полной автоматизации используется система Callback-кнопок в Telegram:

1. **Brain Center -> Telegram**: Отправляет гипотезу с Inline-кнопками.
2. **Telegram -> Production**: При нажатии кнопки `[ ✅ В работу ]` воркфлоу Production получает `hypothesis_id` и начинает генерацию.

---

### Роль Topic Generator
`1) Topic Generator` — это точка входа в систему. Он должен быть настроен на `Schedule Trigger` (например, каждое утро), чтобы инициировать новый цикл исследований.

## 2. Настройка Базы Данных (Supabase)

Схема уже определена в `SKRIPTS/supabase/pipeline_schema.sql`.
Основные таблицы:
*   `topics` (вместо `projects`)
*   `knowledge` (вместо `research_logs`)
*   `hypotheses`
*   `content` (вместо `artifacts`)
*   `projects` (глобальные настройки)

## 3. Инструкция по настройке Воркфлоу

### Агент 1: Topic Generator
*   **Задача:** Создать запись в таблице `topics`.
*   **Node: Supabase Insert**
    *   Table: `topics`
    *   Columns: `parent_topic`, `subtopic`, `status`='pending'.

### Агент 2: Research Team
*   **Задача:** Взять тему в работу и сохранить факты.
*   **Trigger:** Database Trigger (on insert to `topics`) или Schedule (Polling `status`='pending').
*   **Logic:**
    1.  Update `topics.status` -> `researching`.
    2.  Perplexity Search -> Loop -> Save to `knowledge`.
    3.  Update `topics.status` -> `completed`.

### Агент 3: Brain Center
*   **Задача:** Превратить факты в идеи.
*   **Trigger:** Database Trigger (on update `topics.status`='completed').
*   **Logic:**
    1.  Get `knowledge` by `topic_id`.
    2.  LLM Generate Hypotheses.
    3.  Save to `hypotheses`.

### Агент 4: Production Agent
*   **Задача:** Создать контент.
*   **Trigger:** Telegram Callback (User selects Hypothesis).
*   **Logic:**
    1.  Get `hypotheses` details.
    2.  LLM Generate Content.
    3.  Save to `content`.
    4.  Send to Telegram.

## 4. План запуска (из Snaphot)
1.  **Валидация БД:** Убедиться, что скрипт `SKRIPTS/supabase/pipeline_schema.sql` выполнен.
2.  **Первый прогон:**
    *   Вручную создать тему в `topics`.
    *   Проверить, подхватит ли её Research Team.
3.  **Тюнинг:** Настройка промптов Brain Center (см. пункт 4 плана "на завтра").
