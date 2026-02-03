# CHAT SNAPSHOT: 2026-02-03 (Early Evening) - Auto-Dispatcher GOLD Release

## 🏆 Milestone Reached

The **Auto-Dispatcher System** is fully operational and validated. We have successfully automated the entire loop from a voice request to a perfectly formatted Google Calendar event with map links.

---

## 🏗 Technical Configuration (The "Golden" Settings)

### 1. Workflow: `MAIN 2 AUTO` (Data Ingestion & Confirmation)

#### **Logic & Routing**

- **Switch1**: Separates incoming traffic.
  - _Route 0 (Message)_: `{{ $json.message }}` is not empty.
  - _Route 1 (Callback)_: `{{ $json.callback_query }}` is not empty.

#### **Step 1: AI Parser (Voice/Text Processing)**

- **System**: Uses OpenAI + Structured Output Parser.
- **Critical Schema Update**: Added `phone` and `client` fields to ensure extraction.
- **Schema**:

```json
{
  "status": "success",
  "service": "string",
  "address": "string",
  "date": "DD.MM.YYYY",
  "time": "HH:MM",
  "price": "string",
  "client": "string",
  "phone": "string",  <-- CRITICAL ADDITION
  "details": "string",
  "confirmation_text": "..."
}
```

#### **Step 2: Database (Google Sheets)**

- **Append row in sheet**:
  - Mapped explicit columns `Client` -> `{{ $json.client }}` and `Phone` -> `{{ $json.phone }}`.
  - _Fallback_: Full data is always stored in `Raw_JSON` column.

#### **Step 3: Data Preparation (Before Calendar)**

- **Node**: `Prepare Data` (in Callback branch).
- **Critical Formula (Query Construction)**:
  Uses a "Double Check" strategy to support both new (clean) and old (raw) table rows.
  ```javascript
  ... КЛИЕНТ: {{ $json.Client || JSON.parse($json.Raw_JSON).client || "Неизвестен" }}
  ТЕЛЕФОН: {{ $json.Phone || JSON.parse($json.Raw_JSON).phone || "Не указан" }}
  ```

---

### 2. Workflow: `CALENDAR 2 AUTO` (Execution Agent)

#### **Agent Configuration**

- **System Message (PROMPT)**: Optimized for Russian morphology and specific formatting.

```text
# Role
Technical Calendar Manager.
Current Date: {{ $now }} | Time: Europe/Moscow

# Action Rules
1. CREATE: Use tool 'Create Event'.
   - Title: Construct title using Service Name and Address (e.g., "Откачка 8 кубов - Одинцово, Ленина 17").
   - Description:
     "Клиент: [Name]
      Телефон: [Phone]
      Дата: [Date]
      Время: [Time]
      Цена: [Price]
      Детали: [Details]
      Карта: Открыть на карте (https://yandex.ru/maps/?text=[Address])"
   (Populate [Name] and [Phone] from the query data. If Phone is missing, write "Не указан").
   (Important: URL encode the address in the link if possible, or just paste the address text).

2. DELETE: Search for event on requested Date/Address, get ID, then use 'Delete Event'.
3. VIEW: Use 'Get Events' to list items for specific date.

# Rules
- DO NOT ask questions. Execution only.
- Respond ONLY in Russian.
- Conflict: If slot busy, move to next free hour and report.
```

#### **Tool: Create Event**

- **Fields Mapping**:
  - Summary: `{{ $fromAI("summary") }}`
  - Description: `{{ $fromAI("description") }}`
  - Time: `$fromAI("startTime")` / `$fromAI("endTime")`

---

## ✅ Status

- **Parsing**: 100% (Client/Phone extraction fixed).
- **Architecture**: 100% (Single Trigger with Switch).
- **UX**: 100% (Clickable Map Links, Clear formatting).

**Next Steps**: Field testing with real drivers.
