# Thesis Milestone: Frontend HTTP Composable Unit Testing Plan

**Timeline Details:**
- **Date:** Sunday, July 19, 2026
- **Time:** 10:00 PM CEST
- **Milestone:** Chapter 5 (Implementation) Frontend HTTP Client Unit Testing Plan
- **Source Files:**
  - HTTP Composable: [useRest.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/composables/useRest.ts)

---

## 1. Context & Motivation (Thesis Section 5.X)
When writing this section of your thesis, explain **why** testing the HTTP composable is important:
- **Boundary Validation:** The frontend application communicates with the backend API via the `useRest` hook. Validating this hook ensures that payloads are structured correctly before transmission and responses are cleanly parsed.
- **Isolating Nuxt Modules:** Standard unit tests run outside Nuxt's server environment. We must prove that utility functions relying on Nuxt configuration utilities (like `useRuntimeConfig()`) can be isolated and tested.
- **Handling Network States:** Unit tests must confirm how the frontend reacts under normal response situations vs. unexpected server failures (e.g., HTTP 500 errors).

---

## 2. Test Architecture & Mocking Strategy (Thesis Section 5.X)
Detail the implementation strategy for mock configurations:
- **Test Framework:** Vitest.
- **Global Runtime Config Mocking:** Intercept calls to `useRuntimeConfig` using Vitest's `vi.stubGlobal()` utility:
  ```typescript
  vi.stubGlobal('useRuntimeConfig', () => ({
    public: { apiUrl: 'http://mock-api.local' }
  }));
  ```
- **Fetch API Interception:** Since `fetch` is a global browser API, stub it globally with a mocked function:
  ```typescript
  const mockFetch = vi.fn();
  vi.stubGlobal('fetch', mockFetch);
  ```

### Test Cases to Describe:
1. **Happy Path Request:**
   - Inject a mock successful response payload.
   - Assert that `fetch` is called with the correct parameters (POST method, `Content-Type: application/json`, and stringified payload).
   - Assert that the return value matches the mocked API response.
2. **Error Handling Path:**
   - Mock the `fetch` API to resolve with a status code of `500` and `ok: false`.
   - Assert that the client throws a standard descriptive error (`Failed to analyze market`).

---

## 3. Verification Plan
Outline the command-line execution validation path:
```bash
# Execute the frontend test suite
pnpm --filter frontend test
```
