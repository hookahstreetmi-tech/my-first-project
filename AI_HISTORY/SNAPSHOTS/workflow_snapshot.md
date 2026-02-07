# n8n Workflow Snapshot - Auto-Dispatcher (Feb 6, 2026 - 21:23)

## 1. ONBOARDING PHASE 2 (ID: DVG-bNLqAbJOLSlExNS2x)

**Status:** ✅ Functional & Production Ready
**Purpose:** Primary entry point for new users. Handles registration and whitelist entry.

### Core Logic:

- **Trigger:** Telegram Trigger (Messages).
- **Greeting:** Descriptive message advising users to send their `@gmail.com`. Buttons removed for simplicity.
- **Routing (Switch):**
  - Text contains `@gmail.com` -> Validates and sends a ticket to the Admin Group.
  - Callback contains `activate_driver` -> Admin action: Moves driver to Google Sheets Whitelist.
  - Callback contains `setup_done` -> Driver action: Verifies Google Calendar permissions and provides feedback.

### Key Fixes:

- Consolidated multiple triggers into one.
- Corrected `Chat ID` references to use `{{ $('Telegram Trigger').item.json.message.from.id }}`.
- Removed confusing "Send ID" buttons to highlight a single action (sending email).

---

## 2. MAIN 2 AUTO (ID: el5R22gFowzVSAfQ)

**Status:** ✅ Functional & Optimized
**Purpose:** Core dispatching logic using AI for transcription and calendar creation.

### Core Logic:

- **Authorization:** Checks `Whitelist` Google Sheet. Now issues a helpful "Access Denied" message guiding users to `/start`.
- **Switch Node:** Routes based on `Voice` vs `Text`.
  - **Voice:** Checks duration using `{{ $('Telegram Trigger').item.json.message.voice.duration }}`.
  - **Filter (If1):** Limit set to **60 seconds** (Is Greater Than logic corrected).
- **Processing:** Transcribes voice -> AI Agent -> Calls `CALENDAR AUTO 2` -> Feedback to Driver.

### Key Fixes:

- Fixed the "Too Many Requests" conflict with the Onboarding workflow by adding filters in `Switch2`.
- Resolved the `[object Object]` error in Switch by targeting `.voice.file_id`.
- Fixed data loss issues caused by the "Typing" node by using `.item` to reference the original trigger data.

---

## 3. Data Layer (Google Sheets)

- **File:** `auto_dispatcher`
- **Sheet:** `Whitelist`
- **State:** Cleaned. Duplicate IDs removed. `calendar_id` for current driver manually set to a specific email for stability.

---

## 🚀 Next Steps / To-Do:

1. **SMM-Agent Design:** Plan the automated social media posting triggered by successful calendar events.
2. **Calendar ID Optimization:** Update Google Sheets `calendar_id` from `primary` to specific emails for multi-driver support.
3. **Internal Stress Test:** Simulate multiple simultaneous orders to verify stability.
4. **Master Consolidation:** (Long term) Merge Onboarding and Main workflows for ultimate maintenance ease.
