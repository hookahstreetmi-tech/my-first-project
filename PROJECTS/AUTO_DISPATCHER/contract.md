# Data Contract: Auto-Dispatcher System

This document serves as the Single Source of Truth (SSOT) for data structures within the Auto-Dispatcher n8n workflows. All AI prompts and node configurations must adhere to this standard.

## 1. AI Output Schema (from 'Авто АССИСТЕНТ')

**Format**: Flat JSON (no nested objects).
**Field Case**: lowercase.

| Field               | Type   | Description                                       |
| :------------------ | :----- | :------------------------------------------------ |
| `status`            | string | "success" or "error"                              |
| `service`           | string | Normalized service type (e.g., "откачка септика") |
| `address`           | string | Full extracted address                            |
| `date`              | string | **DD.MM.YYYY** (Converted from relative dates)    |
| `time`              | string | **HH:MM** (24h format)                            |
| `price`             | string | Extracted price with currency (e.g., "5000р")     |
| `client`            | string | Name and/or phone number                          |
| `details`           | string | Volume, hose length, access notes                 |
| `confirmation_text` | string | Emoji-rich Russian summary for Telegram           |

## 2. Google Sheets Structure

**Sheet Name**: Usually 'Orders' or 'Sheet1'
**Column Case**: Capitalized (matching n8n internal output keys)

| Column Name  | Row Mapping (Expression)      |
| :----------- | :---------------------------- | -------------------- |
| **ID**       | `{{ $now.toMillis() }}`       |
| **Status**   | Hardcoded: `DRAFT`            |
| **Service**  | `{{ $json.service }}`         |
| **Address**  | `{{ $json.address }}`         |
| **Date**     | `{{ $json.date }}`            | (format: 04.02.2026) |
| **Time**     | `{{ $json.time }}`            |
| **Price**    | `{{ $json.price }}`           |
| **Raw_JSON** | `{{ JSON.stringify($json) }}` |

## 3. Telegram Confirmation (Ask Confirmation Node)

**Message Text**: Uses either `{{ $json.confirmation_text }}` or constructs from Sheet columns:
`📍 {{ $json.Address }}\n⏰ {{ $json.Date }} {{ $json.Time }}\n...`

**Buttons (callback_data)**:

- ✅ Записать: `confirm|{{ $node["Append row in sheet"].json.ID }}`
- ❌ Отмена: `cancel|{{ $node["Append row in sheet"].json.ID }}`
- ✏️ Изменить: `edit|{{ $node["Append row in sheet"].json.ID }}`

## 4. Calendar Integration (Sub-workflow Call)

**Input Query**:
`Запиши заказ: Услуга: {{ $json.Service }}, Адрес: {{ $json.Address }}, Время: {{ $json.Time }}, Цена: {{ $json.Price }}, Детали: {{ $json.Raw_JSON }}`
