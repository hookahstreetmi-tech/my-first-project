-- ===========================================
-- AUTO-DISPATCHER: DRIVERS & SETTINGS
-- ===========================================

-- 1. ТАБЛИЦА DRIVERS (Профили водителей)
CREATE TABLE IF NOT EXISTS drivers (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    telegram_id BIGINT UNIQUE NOT NULL,    -- ID пользователя в Telegram
    username TEXT,                         -- @username
    full_name TEXT,                        -- Имя для отображения
    phone TEXT,                            -- Контактный телефон
    calendar_id TEXT,                      -- ID Google Календаря (пр: user@gmail.com)
    status TEXT DEFAULT 'trial',           -- trial, active, paused, blocked
    tariff TEXT DEFAULT 'base',            -- base, pro, premium
    settings JSONB DEFAULT '{
        "auto_confirm": false,
        "notify_customer": true,
        "default_service": "откачка",
        "working_hours": {"start": "08:00", "end": "20:00"}
    }',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. ТАБЛИЦА ORDERS (Журнал заказов для аналитики и кабинета)
CREATE TABLE IF NOT EXISTS orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    driver_id UUID REFERENCES drivers(id) ON DELETE CASCADE,
    client_name TEXT,
    client_phone TEXT,
    service_type TEXT,
    address TEXT,
    order_date DATE,
    order_time TIME,
    price TEXT,
    raw_text TEXT,                        -- Исходный текст/транскрипция
    status TEXT DEFAULT 'pending',        -- pending, confirmed, cancelled, completed
    calendar_event_id TEXT,               -- ID события в Google Calendar
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_drivers_tg ON drivers(telegram_id);
CREATE INDEX IF NOT EXISTS idx_orders_driver ON orders(driver_id);
CREATE INDEX IF NOT EXISTS idx_orders_date ON orders(order_date);

-- Триггер для updated_at
CREATE TRIGGER update_drivers_updated_at
BEFORE UPDATE ON drivers
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
