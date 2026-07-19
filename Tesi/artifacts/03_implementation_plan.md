# Thesis Milestone: Integration Testing Strategy & HTTP API Plan

**Timeline Details:**
- **Date:** Monday, July 13, 2026
- **Time:** 11:10 AM CEST
- **Milestone:** Chapter 5 (Implementation) Integration Testing Plan
- **Source Files:**
  - Route Entrypoint: [index.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/index.ts)
  - Services: [demand.service.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/services/demand.service.ts) and [supply.service.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/services/supply.service.ts)
  - DB Schema: [schema.ts](file:///home/tms/Documents/Neeche/main-app/apps/backend/src/db/schema.ts)

---

## 1. Context & Motivation (Thesis Section 5.X)
Explain the shift from service unit testing to HTTP API integration testing in this section:
- **Scope Extension:** Moving up the testing pyramid from pure unit tests of calculation services to testing the Fastify HTTP request lifecycle.
- **Routing & Middleware:** The endpoint `/api/analyze` acts as the coordinator. It manages CORS middlewares, parses request bodies, interacts with the local PostgreSQL cache database, handles API parameters, and orchestrates calls to the scoring services.
- **Verification Goals:** 
  - Ensure request/response schemas conform to shared interfaces (`AnalyzeMarketRequest` and `AnalyzeMarketResponse`).
  - Verify database caching behavior (ensuring no redundant, costly external calls are made on cache hits).
  - Verify location parameter lookups and fallback behaviors.
  - Verify HTTP error-handler boundary safety under service-layer failures.

---

## 2. Test Architecture & Route Mocking (Thesis Section 5.X)
Explain how the HTTP request cycle is simulated cleanly in the test suite:
- **Socket-Free Testing:** Use Fastify's native `fastify.inject()` method. This executes the entire routing pipeline (routing, serialization, parsing, error handling) in-memory, avoiding the overhead and instability of listening on a physical TCP socket.
- **Mocking Chains for Drizzle ORM:**
  - Create chainable mock objects to intercept Drizzle ORM queries:
    ```typescript
    const mockSelectChain = {
      from: vi.fn().mockReturnThis(),
      where: vi.fn().mockReturnThis(),
      limit: vi.fn(),
    };
    ```
  - Intercept queries on the `dataCache` table and verify if records are returned.

### A. Core Integration Scenarios to Explain:
1. **Cache Hit Path:**
   - Mock DB queries to return a cached row.
   - Assert that the service functions (`fetchDemandScore` and `fetchSupplyScore`) are never invoked.
2. **Cache Miss Path:**
   - Mock DB queries to return empty.
   - Mock scoring services to return pre-computed scores.
   - Verify that DB insertion (`db.insert().values()`) is executed with calculated scores.
3. **Location Mapping Resolution:**
   - Verify that names like `"Roma"` map to location code `1014104` via the mocked `dataforseo.getGoogleAdsItalianLocations()`.
   - Verify fallback defaults (e.g. `2380`) are applied when search criteria fail to find matches.
4. **Failure Boundaries:**
   - Verify service errors propagate as HTTP 500 status codes instead of crashing the daemon.

---

## 3. Verification Plan
Outline the command-line execution validation path:
```bash
# Execute integration tests specifically
npx vitest run tests/integration/api.test.ts

# Run the complete test suite to ensure no regressions
npx vitest run
```
