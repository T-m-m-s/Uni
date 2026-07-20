# Thesis Milestone: Testing Summary and Theoretical Foundations

**Timeline Details:**
- **Date:** Monday, July 20, 2026
- **Time:** 6:00 PM CEST
- **Milestone:** Comprehensive Testing Phase Wrap-up & Academic Discussion
- **Related Chapters:** 
  - Chapter 2: Testing Theory (\ref{chap:testing_theory})
  - Chapter 5: Implementation (\ref{chap:implementation})
  - Chapter 6: Results and Discussion (\ref{chap:results})

---

## 1. Monorepo Test Coverage Summary

Below is the consolidated statement of coverage achieved across both projects in the monorepo, representing the final verified state before commencing full mutation analysis.

### A. Backend Package (Vitest + V8 Coverage)
* **Total Executed Tests:** 64
* **Total Coverage Achieved:**

| File / Directory | % Statements | % Branch | % Functions | % Lines | Critical Analysis |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `src/core/` (Algorithms) | 100.00 | 95.45 | 100.00 | 100.00 | Complete coverage of mathematical and evaluation formulas. |
| `src/services/` (Service Layer) | 100.00 | 83.33 | 100.00 | 100.00 | Full logic validation under mocked HTTP responses. |
| `src/clients/dataforseo.ts` | 90.47 | 80.00 | 100.00 | 90.47 | Error-throws for GET are covered; POST HTTP failures are bypassed. |
| `src/index.ts` (API Routes) | 63.63 | 62.50 | 37.50 | 62.79 | Server startup, port listening, and SIGINT/SIGTERM loops are bypassed. |
| `src/db/schema.ts` (Drizzle) | 50.00 | 100.00 | 0.00 | 50.00 | Schema default initialization callbacks bypassed during mocks. |

### B. Frontend Package (Vitest + V8 Coverage)
* **Total Executed Tests:** 17
* **Total Coverage Achieved:**

| File / Directory | % Statements | % Branch | % Functions | % Lines | Critical Analysis |
| :--- | :---: | :---: | :---: | :---: | :--- |
| `composables/useRest.ts` | 100.00 | 100.00 | 100.00 | 100.00 | Complete coverage of API payload POST operations and HTTP status evaluations. |
| `store/useAnalysisStore.ts` | 98.48 | 78.57 | 100.00 | 100.00 | Complete coverage of active states, resets, and preset calculations. |
| `utils/date.ts` | 100.00 | 100.00 | 100.00 | 100.00 | Edge case dates, padding, and boundary/leap years fully covered. |
| `utils/schemas/analysis.ts` | 100.00 | 100.00 | 100.00 | 100.00 | Zod validators and translated validation messages covered. |

---

## 2. Theoretical Foundations (Relevant for Thesis Chapters)

When writing your thesis chapters, you can directly draw upon the following core theoretical and engineering principles demonstrated during this development phase:

### A. The Testing Pyramid in Monorepo Contexts
In modern web applications (especially monorepos), the test suite follows a structured tier:
1. **Unit Tier (Core & Utils):** Validates pure, deterministic math and string algorithms (e.g. `core/demand.ts` or `utils/date.ts`). These tests run in milliseconds and verify logic isolation.
2. **Service Tier:** Evaluates orchestrations and mapping transformations (e.g. `services/demand.service.ts`). These rely on mock clients to insulate calculations from external changes.
3. **Integration Tier (Routes & Controllers):** Verifies the middleware, parsing, and caching layers (e.g. `index.ts` API route testing).

### B. Socket-free Integration Testing (In-Memory HTTP Injection)
Rather than spinning up real TCP server sockets which introduce flakiness, rate limits, and cross-thread conflicts during execution, the application leverages Fastify's **in-memory HTTP injection** (`fastify.inject()`). 
* **Theoretical Benefit:** Executes the complete HTTP cycle (routing, parsing middlewares, schemas validation, serialization, error catchers) in-memory.
* **Engineering Impact:** Provides execution times comparable to simple unit tests (under 100ms) while checking the full API controller lifecycle.

### C. Structural Coverage (V8 Metrics) vs. Behavioral Robustness
Standard coverage metrics (Lines, Statements, Branches) are **structural checkups**—they only verify if the code was *executed* during testing. 
* **The Line Coverage Illusion:** Having 100% line coverage (as seen in the Pinia store) does not mean all logic paths are verified. If a line contains compound boolean gates (`&&`, `||`) or ternary statements (`? :`), V8 marks the line as covered even if only one branch is evaluated.
* **The Transition to Mutation Testing:** This limitation provides the scientific motivation for Mutation Testing. By executing **StrykerJS** to insert synthetic faults (mutants), we move from measuring *code execution* (structural) to measuring *assertion robustness* (behavioral). If a mutant survives a line with 100% coverage, it proves the tests ran the code but failed to assert its behavior.
