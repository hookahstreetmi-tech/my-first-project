-- ===========================================
-- INDUS.8M PIPELINE - DATABASE SCHEMA
-- ===========================================
-- Версия: 1.0
-- Дата: 2026-01-27
-- Автор: ДЖАРВИС
-- ===========================================

-- 1. ТАБЛИЦА TOPICS (Генератор тем для ресерча)
-- Ежедневно генерируемые темы для исследования
CREATE TABLE IF NOT EXISTS topics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    parent_topic TEXT NOT NULL,           -- Основная тема (напр. "ИИ в России")
    subtopic TEXT NOT NULL,               -- Подтема (напр. "Аудитория", "Потребности")
    description TEXT,                     -- Описание что исследовать
    status TEXT DEFAULT 'pending',        -- pending, researching, completed, archived
    priority TEXT DEFAULT 'medium',       -- low, medium, high
    deep_search BOOLEAN DEFAULT false,    -- Флаг глубокого исследования
    source_workflow TEXT DEFAULT 'auto',  -- auto, manual
    scheduled_date DATE DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы для быстрого поиска
CREATE INDEX IF NOT EXISTS idx_topics_status ON topics(status);
CREATE INDEX IF NOT EXISTS idx_topics_date ON topics(scheduled_date);

-- ===========================================

-- 2. ТАБЛИЦА KNOWLEDGE (База знаний из ресерча)
-- Результаты исследований от Research Team
CREATE TABLE IF NOT EXISTS knowledge (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    topic_id UUID REFERENCES topics(id) ON DELETE SET NULL,
    title TEXT NOT NULL,                  -- Заголовок знания
    content TEXT NOT NULL,                -- Полный текст исследования
    source TEXT,                          -- Источник (URL, название)
    source_type TEXT DEFAULT 'perplexity', -- perplexity, web, youtube, manual
    tags TEXT[],                          -- Теги для поиска
    summary TEXT,                         -- Краткое резюме
    relevance_score FLOAT DEFAULT 0.5,    -- Оценка релевантности 0-1
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_knowledge_topic ON knowledge(topic_id);
CREATE INDEX IF NOT EXISTS idx_knowledge_tags ON knowledge USING GIN(tags);

-- Полнотекстовый поиск
CREATE INDEX IF NOT EXISTS idx_knowledge_search ON knowledge 
    USING GIN (to_tsvector('russian', title || ' ' || content));

-- ===========================================

-- 3. ТАБЛИЦА HYPOTHESES (Гипотезы от Brain Center)
-- Гипотезы и решения на основе знаний
CREATE TABLE IF NOT EXISTS hypotheses (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    knowledge_ids UUID[],                 -- Связь с источниками знаний
    statement TEXT NOT NULL,              -- Формулировка гипотезы
    problem TEXT,                         -- Проблема которую решает
    solution TEXT,                        -- Предлагаемое решение
    reasoning TEXT,                       -- Обоснование
    status TEXT DEFAULT 'pending',        -- pending, validated, rejected, in_progress
    confidence FLOAT DEFAULT 0.5,         -- Уверенность 0-1
    validated_by TEXT,                    -- Кто валидировал (user_id или "auto")
    validated_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_hypotheses_status ON hypotheses(status);

-- ===========================================

-- 4. ТАБЛИЦА CONTENT (Готовый контент)
-- Результаты работы SMM и Business агентов
CREATE TABLE IF NOT EXISTS content (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    hypothesis_id UUID REFERENCES hypotheses(id) ON DELETE SET NULL,
    type TEXT NOT NULL,                   -- post, article, script, business_plan, code
    platform TEXT,                        -- telegram, instagram, linkedin, etc
    title TEXT,
    body TEXT NOT NULL,                   -- Основной контент
    media_urls TEXT[],                    -- Ссылки на медиа
    status TEXT DEFAULT 'draft',          -- draft, pending_review, approved, published, rejected
    reviewed_by TEXT,
    reviewed_at TIMESTAMPTZ,
    published_at TIMESTAMPTZ,
    metadata JSONB,                       -- Доп. данные (hashtags, mentions, etc)
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Индексы
CREATE INDEX IF NOT EXISTS idx_content_type ON content(type);
CREATE INDEX IF NOT EXISTS idx_content_status ON content(status);
CREATE INDEX IF NOT EXISTS idx_content_hypothesis ON content(hypothesis_id);

-- ===========================================

-- 5. ТАБЛИЦА PROJECTS (Проекты - уже существует?)
-- Если нет, создаём
CREATE TABLE IF NOT EXISTS projects (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    status TEXT DEFAULT 'active',          -- active, paused, completed, archived
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ===========================================

-- ТРИГГЕРЫ ДЛЯ ОБНОВЛЕНИЯ updated_at
-- ===========================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Применяем к каждой таблице
DO $$
DECLARE
    tbl TEXT;
BEGIN
    FOR tbl IN SELECT unnest(ARRAY['topics', 'knowledge', 'hypotheses', 'content', 'projects'])
    LOOP
        EXECUTE format('
            DROP TRIGGER IF EXISTS update_%s_updated_at ON %s;
            CREATE TRIGGER update_%s_updated_at
            BEFORE UPDATE ON %s
            FOR EACH ROW
            EXECUTE FUNCTION update_updated_at_column();
        ', tbl, tbl, tbl, tbl);
    END LOOP;
END $$;

-- ===========================================
-- ROW LEVEL SECURITY (опционально)
-- ===========================================

-- ALTER TABLE topics ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE knowledge ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE hypotheses ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE content ENABLE ROW LEVEL SECURITY;

-- ===========================================
-- ПРИМЕРЫ ЗАПРОСОВ
-- ===========================================

-- Получить все pending темы на сегодня:
-- SELECT * FROM topics WHERE status = 'pending' AND scheduled_date = CURRENT_DATE;

-- Найти знания по тегу:
-- SELECT * FROM knowledge WHERE 'AI' = ANY(tags);

-- Полнотекстовый поиск:
-- SELECT * FROM knowledge WHERE to_tsvector('russian', title || ' ' || content) @@ plainto_tsquery('russian', 'искусственный интеллект');

-- Получить утверждённые гипотезы:
-- SELECT * FROM hypotheses WHERE status = 'validated';

-- Контент на ревью:
-- SELECT * FROM content WHERE status = 'pending_review';
