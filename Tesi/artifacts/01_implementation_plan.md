# Thesis Milestone: Service-Layer Testing Strategy & Implementation Plan

**Timeline Details:**
- **Date:** Monday, July 13, 2026
- **Time:** 10:00 AM CEST
- **Milestone:** Chapter 5 (Implementation) Drafting Guide
- **Source Files:** 
  - Service logic: [demand.service.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/services/demand.service.ts) and [supply.service.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/services/supply.service.ts)
  - Core calculation logic: [demand.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/core/demand.ts) and [supply.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/core/supply.ts)

---

## 1. Context & Motivation (Thesis Section 5.X)
When writing this section of your thesis, explain **why** testing the service layer is critical:
- The backend application interacts with the external **DataForSEO API** (via the `dataforseo` client singleton).
- Direct network calls to third-party APIs during testing are anti-patterns (flaky, slow, rate-limited, and expensive).
- **Goal:** Design hermetic unit tests that isolate the service logic, verify calculations under simulated API conditions (successful, empty, and failing payloads), and ensure robust error propagation.

---

## 2. Test Architecture & Mocking Strategy (Thesis Section 5.X)
Detail the implementation strategy for mocking the external clients:
- **Test Framework:** Vitest.
- **Mocking Client:** Use `vi.mock` to intercept imports of `../../src/clients/dataforseo.js`.
- **Target Services & Core Integration:**
  - Verify that the core mathematical models defined in `core/demand.ts` and `core/supply.ts` are correctly applied to the mapped API responses in the service layer.

### A. Demand Service Test Structure
- **File:** [demand.service.test.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/tests/services/demand.service.test.ts)
- **Unit under test:** `fetchDemandScore`
- **Mocking Targets:** 
  - `getGoogleAdsSearchVolumeLive`
  - `getGoogleKeywordIdeasLive`
  - `getGoogleSearchIntentLive`
- **Drafting Scenarios to Describe:**
  1. **Success Path:** Verify standard scoring computations.
  2. **Edge Cases:** Handle empty array/missing responses gracefully via fallback values.
  3. **Error Path:** Verify that API errors propagate cleanly to the caller.

### B. Supply Service Test Structure
- **File:** [supply.service.test.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/tests/services/supply.service.test.ts)
- **Unit under test:** `fetchSupplyScore`
- **Mocking Targets:** 
  - Mock the dynamic `.post` method of the `dataforseo` client.
  - Must return different simulated payloads based on the requested endpoint:
    - `/serp/google/maps/live/advanced` (Local competitor strength)
    - `/merchant/google_shopping/products/live/advanced` (Shopping product price listing)
- **Drafting Scenarios to Describe:**
  1. **Success Path:** Compute competitor mapping and verify price competitiveness.
  2. **Edge Cases:** Empty responses (no local competitors, empty shopping search lists).
  3. **Error Path:** Verify exception handling.

---

## 3. Verification Plan & Execution
To validate the implementation, outline the testing pipeline:
```bash
# Run unit tests specifically for the services
pnpm --filter backend test -- run

# Generate code coverage reports
pnpm --filter backend test -- run --coverage
```
