# Thesis Milestone: Client Wrapper & Frontend Utilities Testing Plan

**Timeline Details:**
- **Date:** Monday, July 13, 2026
- **Time:** 11:30 AM CEST
- **Milestone:** Chapter 5 (Implementation) Unit Testing Strategy for Untested Core Components
- **Source Files:**
  - Backend Client: [dataforseo.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/clients/dataforseo.ts)
  - Frontend Utility: [date.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/utils/date.ts)
  - Frontend Schema: [analysis.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/utils/schemas/analysis.ts)

---

## 1. Context & Motivation (Thesis Section 5.X)
Explain the expansion of the unit testing scope to cover previously untested parts of the monorepo:
* **Completing the Testing Suite:** While the core scoring logic and controllers are covered, components like the third-party client wrappers and frontend validation schemas represent critical boundary logic that must be unit tested.
* **Backend Client Isolation:** [dataforseo.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/clients/dataforseo.ts) executes raw HTTP requests using global `fetch`. Testing this requires mocking HTTP transport layers to isolate client-side credentials building, base URL selection, and response parsing.
* **Frontend Utilities & Schema Validation:**
  * [date.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/utils/date.ts) needs verification for calendar edge cases (date padding, boundary dates).
  * [analysis.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/utils/schemas/analysis.ts) orchestrates Zod schema validations for client form submissions. It must be tested against localized translator stubs (`t`).

---

## 2. Test Architecture & Design (Thesis Section 5.X)
Outline the testing implementations planned for both backend and frontend applications:

### A. Backend Client Testing
- **File:** [dataforseo.test.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/tests/clients/dataforseo.test.ts)
- **Strategy:** Mock the global `fetch` API using Vitest's `vi.stubGlobal('fetch', ...)` to prevent real outgoing HTTP connections.
- **Drafting Scenarios to Describe:**
  1. **Env-based URL Switching:** Sandbox URL (`sandbox.dataforseo.com`) vs. Live API URL.
  2. **Auth Header Construction:** Base64 credentials formatting verification.
  3. **Error Boundaries:** Verifying custom exception throws when encountering non-200 HTTP statuses or non-20000 DataForSEO status codes.
  4. **Wrapper Methods:** Checking that query payloads map to correct API routes.

### B. Frontend Utilities Testing
Configure Vitest under the `apps/frontend` package directory:
- **Scripts:** Add `"test": "vitest run"` to [package.json](file:///home/tms/Documents/Neeche/main-app/apps/frontend/package.json).
- **Date Utility Test File:** [date.test.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/tests/utils/date.test.ts)
  * Verify formatting for single-digit dates (`2026-01-05`) and leap years (Feb 29).
- **Validation Schema Test File:** [analysis.test.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/tests/utils/schemas/analysis.test.ts)
  * Test validations for empty payloads, short product names, invalid date strings, and inverted date ranges (start date after end date).

---

## 3. Verification Plan
To validate these unit tests, verify that the execution runs cleanly in both packages:
```bash
# Verify backend client tests
npx vitest run tests/clients/dataforseo.test.ts

# Verify frontend utility tests
pnpm --filter frontend test
```
