# Thesis Milestone: Frontend State Store (Pinia) Unit Testing Plan

**Timeline Details:**
- **Date:** Monday, July 20, 2026
- **Time:** 10:00 AM CEST
- **Milestone:** Chapter 5 (Implementation) Frontend Pinia Store Unit Testing Plan
- **Source Files:**
  - State Store: [useAnalysisStore.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/store/useAnalysisStore.ts)

---

## 1. Context & Motivation (Thesis Section 5.X)
When writing this section of your thesis, explain **why** testing the state management layer is crucial:
- **Orchestration Verification:** The Pinia store is the brain of the frontend. It holds active user form states, manages visual loading flags, coordinates validation schemas, calculates date presets, and routes parameters to the API client.
- **State Cleanliness:** In single-page applications, verifying that state resets (`$reset`) work perfectly prevents memory leakage or stale parameters from persisting across searches.
- **Mocking Boundaries:** Because the store depends on external composables (like `useRest` and `useI18n`) and Vue's reactivity system (`ref`, `computed`), testing it in isolation requires mocking the Vue environment and intercepting imports.

---

## 2. Test Architecture & Mocking Strategy (Thesis Section 5.X)
Detail the implementation strategy for mock configurations:
- **Test Framework:** Vitest + Pinia.
- **Active Pinia Root:** Instantiate a fresh Pinia instance before each test case to prevent state bleeding:
  ```typescript
  import { createPinia, setActivePinia } from 'pinia';
  beforeEach(() => {
    setActivePinia(createPinia());
  });
  ```
- **Vue & Pinia Global Stubbing:** Since ES Module imports hoist in JavaScript, stub all global variables (like `ref`, `computed`, and `defineStore`) *before* executing the store import.
- **Import Interception (`vi.mock`):** Mock the backend client import `~/composables/useRest` to prevent fetch operations:
  ```typescript
  vi.mock('~/composables/useRest', () => ({
    useRest: () => ({
      analyze: mockAnalyze,
    }),
  }));
  ```

### Test Cases to Describe:
1. **Initial State Verification:** Ensure all form fields, lists, errors, and loading statuses initialize with correct empty/false values.
2. **Date Preset Mathematics (`setPreset`):** Verify calculation boundaries for dynamic presets (e.g. mapping `7d`, `30d`, `this_month`, and `this_year` to correct start and end date objects).
3. **Location Options Fetching (`fetchLocations`):** Verify fallback mappings load correctly.
4. **Happy Path Submission:** Assert correct parameter mappings (city, lat, lng, radius, defaults) are sent to the REST client, and verify store variables update appropriately.
5. **Rejection & Failure Paths:** Assert correct validation failure catches when location IDs do not match, and verify error propagation when the network client rejects.

---

## 3. Verification Plan
Outline the command-line execution validation path:
```bash
# Execute the frontend test suite
pnpm --filter frontend test
```
