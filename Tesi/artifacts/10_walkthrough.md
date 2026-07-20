# Thesis Milestone: Frontend State Store Walkthrough & Results

**Timeline Details:**
- **Date:** Monday, July 20, 2026
- **Time:** 10:15 AM CEST
- **Milestone:** Chapter 6 (Results and Discussion) Pinia Store Unit Testing Walkthrough
- **Output Files:**
  - Test Suite: [useAnalysisStore.test.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/tests/store/useAnalysisStore.test.ts)
  - Coverage Report: `coverage/index.html`

---

## 1. Implementation Walkthrough (Thesis Section 6.X)
Explain how the test logic was implemented inside the Vitest framework:
- **Avoiding ESM Hoisting issues:** Discuss the necessity of loading the store module dynamically using `await import(...)` after stubbing the globals (`defineStore`, `ref`, `computed`). This is a crucial JavaScript runtime pattern to highlight in your implementation chapter.
- **Active Pinia Binding:** Discuss how `setActivePinia` configures the global Vue reactivity scope to handle Pinia store hooks.
- **Dynamic Composable Mocking:** Explain how the test mock-intercepts the `useRest` composable to assert the integration between state fields and backend-directed HTTP parameters.

---

## 2. Test Execution & Verification Logs (Thesis Section 6.X)
Showcase the Vitest execution logs indicating all frontend unit tests are passing successfully:

```bash
# Frontend Vitest Execution Output
 RUN  v4.1.5 /home/tms/Documents/Neeche/main-app/apps/frontend

 ✓ tests/utils/date.test.ts (2 tests) 7ms
 ✓ tests/composables/useRest.test.ts (2 tests) 21ms
 ✓ tests/utils/schemas/analysis.test.ts (6 tests) 16ms
 ✓ tests/store/useAnalysisStore.test.ts (7 tests) 34ms

 Test Files  4 passed (4)
      Tests  17 passed (17)
   Duration  665ms
```

---

## 3. Code Coverage Analysis (Thesis Section 6.X)
Present the coverage metrics to substantiate the completeness of the frontend unit testing phase:

| File | % Statements | % Branch | % Functions | % Lines | Uncovered Lines |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **composables/** | **100.00** | **100.00** | **100.00** | **100.00** | |
| &emsp;[useRest.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/composables/useRest.ts) | 100.00 | 100.00 | 100.00 | 100.00 | *None* |
| **store/** | **98.48** | **78.57** | **100.00** | **100.00** | |
| &emsp;[useAnalysisStore.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/store/useAnalysisStore.ts) | 98.48 | 78.57 | 100.00 | 100.00 | *None* |
| **utils/** | **100.00** | **100.00** | **100.00** | **100.00** | |
| &emsp;[date.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/utils/date.ts) | 100.00 | 100.00 | 100.00 | 100.00 | *None* |
| **utils/schemas/** | **100.00** | **100.00** | **100.00** | **100.00** | |
| &emsp;[analysis.ts](file:///home/tms/Documents/Neeche/main-app/apps/frontend/app/utils/schemas/analysis.ts) | 100.00 | 100.00 | 100.00 | 100.00 | *None* |

> [!NOTE]
> **Thesis Discussion Highlight:** 
> Even with 100% line coverage, some statement segments (like the ternary expressions and double fetches in location list updates) remain partially uncovered at the statement/branch level. This is standard in JS/TS coverage tooling due to nested conditional expressions, and can be highlighted as a reason for subsequent mutation testing to ensure all logical branches behave securely.

---

## 4. Development Iterations & Engineering Resolution (Thesis Section 6.X)
Including the debugging and resolution steps in your thesis adds practical engineering value. Here is the log of the incremental changes made to resolve environment bottlenecks during development:

### Iteration A: Resolving ES Modules Hoisting
* **Issue:** Initial test execution resulted in `ReferenceError: defineStore is not defined` inside the store module. This occurred because static `import` statements are hoisted by the JavaScript engine and executed prior to global stubs like `vi.stubGlobal('defineStore', ...)`.
* **Resolution:** Swapped the static import statement for a dynamic `await import('../../app/store/useAnalysisStore.js')` expression, ensuring it executes after all global stubs are established.

### Iteration B: Injecting Vue Reactivity Primitives
* **Issue:** Once hoisting was resolved, testing outside the Nuxt wrapper compiler resulted in `ReferenceError: ref is not defined` when executing the store's setup function.
* **Resolution:** Imported Vue's native reactivity exports (`ref`, `computed`) and registered them globally using `vi.stubGlobal('ref', ref)` and `vi.stubGlobal('computed', computed)`.

### Iteration C: Intercepting ES Module Imports vs. Globals
* **Issue:** Stubbing `useRest` globally failed to intercept the real function call. The imported module was still executing its original implementation and triggering live `fetch` calls, which threw a `fetch failed` error.
* **Resolution:** Swapped `vi.stubGlobal('useRest', ...)` for a modular mock: `vi.mock('~/composables/useRest', ...)`. This successfully intercepted the import request at compile time.

### Iteration D: Maximizing Statement Coverage
* **Issue:** The initial coverage run returned **96.82%** line coverage due to the `ThirtyDays` preset case not being triggered in the tests.
* **Resolution:** Added a dedicated assertion verifying that `setPreset(AnalysisPreset.ThirtyDays)` successfully computes the 30-day date subtraction, achieving **100% line coverage**.

