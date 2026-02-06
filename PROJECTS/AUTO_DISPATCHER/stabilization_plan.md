# TECHNICAL DESIGN: Auto-Dispatcher Stabilization (Phase 2)

## 1. Database Optimization (Supabase)

Переход с Google Sheets на Supabase как основное хранилище настроек (SSOT).

- **Table `drivers`**: Хранит профили, тарифы и `calendar_id`.
- **Table `orders`**: Логирует каждый заказ. Это позволит в Личном Кабинете строить графики прибыли и список заказов.

## 2. Authorization Flow Improvements

Текущая проверка в Google Sheets медленная и трудно масштабируемая.

- **Auth by TG ID**: n8n делает быстрый SELECT к Supabase по `msg.from.id`.
- **Dynamic Context**: Вместо жестко прописанных промптов, мы будем подгружать `settings` водителя прямо из БД (например, какой тип услуги у него по умолчанию).

## 3. Updated User Journey (Путь пользователя)

### Scenario A: Новичок (Первый вход)

1.  Пишет боту `/start`.
2.  Бот видит, что `telegram_id` нет в `drivers`.
3.  Бот запускает цепочку вопросов: "Как вас зовут?", "Ваш Google Email для календаря?".
4.  Сохранение в БД со статусом `trial`.

### Scenario B: Работающий водитель

1.  Шлет голос/текст.
2.  Бот мгновенно узнает его, подтягивает `calendar_id`.
3.  Классическая обработка AI -> Подтверждение.

### Scenario C: Управление тарифом (Будущее)

1.  Команда `/cabinet` выдает инлайн-кнопки для проверки баланса/тарифа (данные из Supabase).

## 4. n8n Implementation Tasks (TODO)

- [ ] Заменить ноду `Lookup Whitelist` на Supabase Node.
- [ ] Добавить ноду `Insert Order` в конце воркфлоу `MAIN 2 AUTO`.
- [ ] Создать ветку `/start` для первичной регистрации.

---

_Сэр, если этот план «Стабилизации» вам подходит, я начну готовить конкретные операции для изменения воркфлоу._
