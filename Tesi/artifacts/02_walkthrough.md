# Thesis Milestone: Service-Layer Test Execution & Results

**Timeline Details:**
- **Date:** Monday, July 13, 2026
- **Time:** 11:00 AM CEST
- **Milestone:** Chapter 6 (Results and Discussion) Drafting Guide
- **Output Files:**
  - [demand.service.test.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/tests/services/demand.service.test.ts)
  - [supply.service.test.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/tests/services/supply.service.test.ts)

---

## 1. Implementation Walkthrough (Thesis Section 6.X)
Describe how the planned testing structures were realized in the codebase. Use this section of the thesis to discuss the actual code design decisions:
- **Dynamic Endpoint Inspection:** Highlight how `vi.mock` for `supply.service.test.ts` dynamically inspects the argument of `dataforseo.post` to route mocks to either Map or Shopping payloads.
- **Data Fallbacks:** Describe the code logic that translates empty API structures (e.g., empty arrays) into baseline scores instead of crashing.

---

## 2. Test Execution & Verification (Thesis Section 6.X)
Showcase the validation results. You can include these terminal execution runs to demonstrate successful implementation:

```bash
# Vitest Execution Output
✓ tests/core/supply.test.ts (14 tests) 11ms
✓ tests/core/indexCalculator.test.ts (8 tests) 13ms
✓ tests/core/demand.test.ts (22 tests) 18ms
✓ tests/services/supply.service.test.ts (3 tests) 20ms
✓ tests/services/demand.service.test.ts (3 tests) 20ms

Test Files  5 passed (5)
     Tests  50 passed (50)
```

---

## 3. Code Coverage Analysis (Thesis Section 6.X)
Present the coverage metrics to substantiate the quality of the tests.
Here is the coverage breakdown to include in the thesis discussion:

| File | % Statements | % Branch | % Functions | % Lines | Uncovered Lines |
| :--- | :---: | :---: | :---: | :---: | :--- |
| **services/** | **100.00** | **83.33** | **100.00** | **100.00** | |
| &emsp;`demand.service.ts` | 100.00 | 88.88 | 100.00 | 100.00 | [38](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/services/demand.service.ts#L38), [56](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/services/demand.service.ts#L56) |
| &emsp;`supply.service.ts` | 100.00 | 75.00 | 100.00 | 100.00 | [37-43](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/services/supply.service.ts#L37-L43) |

> [!NOTE]
> **Thesis Detail to Explain:** Even though the line and statement coverage is at 100%, explain why branch coverage is slightly lower (88.88% and 75.00%). This is due to optional chaining (`?.`) or logical fallback operators (`||`, `??`) in TypeScript, which generate multiple compiled JavaScript branches that might not all be triggered during service-level testing. This is a very common scenario in modern TypeScript testing to highlight in a thesis.
