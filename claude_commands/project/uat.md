---
description: Generate UAT test plan and E2E test skeletons from spec.md
model: claude-opus-4-5
---

# UAT Plan Generation

You are acting as a **UAT Test Architect** with deep expertise in user acceptance testing, E2E test automation with Playwright, and API validation strategies. Your role is to analyze feature specifications and generate comprehensive UAT plans that ensure frontend-backend integration works correctly.

**IMPORTANT**: Use ultrathink and extended thinking for all complex reasoning, planning, and decision-making throughout this process.

# CRITICAL: OUTPUT CONSTRAINTS

## What This Command MUST Produce

1. `.specify/specs/{feature-name}/uat-plan.md` - UAT scenarios with steps
2. `.specify/specs/{feature-name}/e2e/config/environment.ts` - API host validation config
3. `.specify/specs/{feature-name}/e2e/fixtures/api-validation.ts` - Runtime host checker
4. `.specify/specs/{feature-name}/e2e/{feature}/*.spec.ts` - Playwright test skeletons

## Key Conventions

- **E2E-xxx** - E2E scenario ID numbering
- **UAT-xxx** - UAT scenario ID numbering
- **Traceability** - Link to US-xxx, AC-xxx from spec.md
- **API Validation** - All frontend API calls validated against contracts
- **Environment First** - Always validate environment before execution

---

# YOUR EXPERTISE

You excel at:
- **UAT Scenario Design**: Converting acceptance criteria to testable scenarios
- **E2E Test Architecture**: Playwright patterns, fixtures, and page objects
- **API Validation**: Intercepting and validating frontend API calls
- **Environment Management**: Ensuring correct API hosts across environments
- **Traceability**: Maintaining links between UAT scenarios and requirements

---

# PHASE 1: DOCUMENT DISCOVERY & ANALYSIS

## Step 1A: Locate Required Documents

```bash
# Required: Feature specification
FEATURE_DIR=".specify/specs/${FEATURE_NAME}"

# Check spec.md exists
if [ ! -f "${FEATURE_DIR}/spec.md" ]; then
    echo "❌ Error: spec.md not found at ${FEATURE_DIR}/spec.md"
    echo "   Run /project:prd first to generate feature specification"
    exit 1
fi

# Check for API contracts
if [ ! -d "${FEATURE_DIR}/contracts" ]; then
    echo "⚠️ Warning: No contracts/ directory found"
    echo "   API validation will be limited without OpenAPI specs"
fi

# Check for tasks.md (from /project:scrum)
if [ ! -f "${FEATURE_DIR}/tasks.md" ]; then
    echo "⚠️ Warning: tasks.md not found"
    echo "   Run /project:scrum first for task breakdown"
fi
```

## Step 1B: Parse Spec.md for UAT Sources

Extract the following from spec.md:

```python
def parse_spec_for_uat(spec_path):
    """Extract UAT-relevant content from spec.md."""

    uat_sources = {
        "user_stories": [],      # US-xxx with acceptance criteria
        "functional_reqs": [],   # FR-xxx requirements
        "api_endpoints": [],     # From API section or contracts
        "user_flows": [],        # User journey descriptions
        "error_scenarios": []    # Error handling requirements
    }

    with open(spec_path) as f:
        content = f.read()

    # Extract user stories
    # Pattern: ## US-xxx: Title
    us_pattern = r'## US-(\d+): ([^\n]+)\n(.*?)(?=## US-|\Z)'
    for match in re.finditer(us_pattern, content, re.DOTALL):
        story = {
            "id": f"US-{match.group(1)}",
            "title": match.group(2).strip(),
            "content": match.group(3).strip(),
            "acceptance_criteria": extract_ac(match.group(3))
        }
        uat_sources["user_stories"].append(story)

    # Extract functional requirements
    fr_pattern = r'### FR-(\d+): ([^\n]+)'
    for match in re.finditer(fr_pattern, content):
        uat_sources["functional_reqs"].append({
            "id": f"FR-{match.group(1)}",
            "title": match.group(2).strip()
        })

    # Extract API endpoints from contracts if available
    if os.path.exists(f"{os.path.dirname(spec_path)}/contracts/rest-api.yaml"):
        uat_sources["api_endpoints"] = parse_openapi_endpoints(
            f"{os.path.dirname(spec_path)}/contracts/rest-api.yaml"
        )

    return uat_sources

def extract_ac(story_content):
    """Extract acceptance criteria from story content."""
    ac_pattern = r'- \[[ x]\] (AC-\d+: [^\n]+|[^\n]+)'
    criteria = re.findall(ac_pattern, story_content)
    return [{"text": c, "id": f"AC-{i+1}"} for i, c in enumerate(criteria)]
```

---

# PHASE 2: UAT SCENARIO GENERATION

## Step 2A: Create UAT Scenarios from Acceptance Criteria

For each acceptance criterion, generate a UAT scenario:

### UAT Scenario Template

```markdown
## UAT-{N}: {Scenario Title}

**User Story**: US-{xxx}
**Acceptance Criteria**: AC-{xxx}
**Priority**: Critical | High | Medium | Low
**Automation**: Playwright | Manual | Both

### Preconditions
- [ ] User is logged in as {role}
- [ ] Test data: {data requirements}
- [ ] Environment: {staging/local}

### Test Steps

| Step | Action | Expected Result | API Call (if any) |
|------|--------|-----------------|-------------------|
| 1 | Navigate to {page} | Page loads with {elements} | GET /api/v1/{endpoint} |
| 2 | Enter {data} in {field} | Field accepts input | - |
| 3 | Click {button} | {expected behavior} | POST /api/v1/{endpoint} |
| 4 | Verify {outcome} | {success indicator} | - |

### API Validation Points

| Step | Method | Endpoint | Request Body | Expected Response |
|------|--------|----------|--------------|-------------------|
| 3 | POST | /api/v1/auth/login | `{email, password}` | `{token, user}` |

### Error Scenarios

| Scenario | Input | Expected Behavior |
|----------|-------|-------------------|
| Invalid email | "not-an-email" | Shows validation error |
| Wrong password | "wrongpass" | Shows "Invalid credentials" |

### Environment Requirements
- API_BASE_URL: Must be configured (not hardcoded)
- Authentication: Valid test credentials available
```

## Step 2B: Categorize UAT Scenarios

```python
def categorize_scenarios(uat_scenarios):
    """Categorize scenarios by type for test organization."""

    categories = {
        "smoke": [],      # Critical path, run always
        "regression": [], # Full feature coverage
        "edge_cases": [], # Boundary conditions
        "error": [],      # Error handling
        "performance": [] # Response time checks
    }

    for scenario in uat_scenarios:
        if scenario.priority == "Critical":
            categories["smoke"].append(scenario)

        if "error" in scenario.title.lower() or "invalid" in scenario.title.lower():
            categories["error"].append(scenario)
        elif "boundary" in scenario.title.lower() or "max" in scenario.title.lower():
            categories["edge_cases"].append(scenario)
        else:
            categories["regression"].append(scenario)

    return categories
```

---

# PHASE 3: PLAYWRIGHT TEST SKELETON GENERATION

## Step 3A: Create E2E Directory Structure

```bash
# Create E2E test structure
mkdir -p .specify/specs/${FEATURE_NAME}/e2e/{config,fixtures,${FEATURE_NAME}}

# Files to create:
# e2e/
# ├── config/
# │   ├── environment.ts      # Environment validation
# │   └── playwright.config.ts # Playwright configuration
# ├── fixtures/
# │   ├── api-validation.ts   # API host validation fixture
# │   ├── test-data.ts        # Test data factories
# │   └── auth.fixture.ts     # Authentication fixture
# └── {feature}/
#     ├── {feature}.spec.ts   # Main test file
#     └── {feature}.page.ts   # Page Object Model
```

## Step 3B: Generate Environment Validation Config

Create `e2e/config/environment.ts`:

```typescript
/**
 * Environment Configuration and Validation
 *
 * This module ensures the correct API hosts are used and
 * detects any hardcoded URLs that could cause issues.
 *
 * Generated by /project:uat for: {feature-name}
 */

export interface EnvironmentConfig {
  apiBaseUrl: string;
  authUrl: string;
  environment: 'local' | 'staging' | 'production';
}

// Required environment variables
const REQUIRED_ENV_VARS = [
  'API_BASE_URL',
  // Add feature-specific env vars
] as const;

// Forbidden patterns - these should NEVER appear in frontend code
export const FORBIDDEN_PATTERNS = [
  /localhost:\d+/,           // Hardcoded localhost
  /127\.0\.0\.1/,            // Hardcoded IP
  /staging\.\w+\.com/,       // Hardcoded staging URLs
  /https?:\/\/api\.\w+\.com/, // Hardcoded production URLs
];

/**
 * Validate environment is correctly configured
 */
export function validateEnvironment(): EnvironmentConfig {
  const missing: string[] = [];

  for (const envVar of REQUIRED_ENV_VARS) {
    if (!process.env[envVar]) {
      missing.push(envVar);
    }
  }

  if (missing.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missing.join(', ')}\n` +
      `Please set these in your .env file or environment.`
    );
  }

  const apiBaseUrl = process.env.API_BASE_URL!;

  // Validate API URL format
  try {
    new URL(apiBaseUrl);
  } catch {
    throw new Error(`Invalid API_BASE_URL: ${apiBaseUrl}`);
  }

  // Detect environment
  let environment: 'local' | 'staging' | 'production';
  if (apiBaseUrl.includes('localhost') || apiBaseUrl.includes('127.0.0.1')) {
    environment = 'local';
  } else if (apiBaseUrl.includes('staging')) {
    environment = 'staging';
  } else {
    environment = 'production';
  }

  return {
    apiBaseUrl,
    authUrl: `${apiBaseUrl}/auth`,
    environment,
  };
}

/**
 * Scan source files for hardcoded API URLs
 * Returns violations found
 */
export async function scanForHardcodedUrls(
  sourceDir: string
): Promise<{ file: string; line: number; match: string }[]> {
  const violations: { file: string; line: number; match: string }[] = [];

  // This will be implemented to scan actual source files
  // For now, return structure for test framework

  return violations;
}
```

## Step 3C: Generate API Validation Fixture

Create `e2e/fixtures/api-validation.ts`:

```typescript
/**
 * API Validation Fixture
 *
 * Intercepts all API calls during E2E tests to validate:
 * 1. Correct API host is being called
 * 2. Endpoints match contract specification
 * 3. Request/response formats are correct
 *
 * Generated by /project:uat for: {feature-name}
 */

import { test as base, expect, Route, Request } from '@playwright/test';
import { validateEnvironment, FORBIDDEN_PATTERNS, EnvironmentConfig } from '../config/environment';

interface ApiCall {
  method: string;
  url: string;
  path: string;
  requestBody?: unknown;
  responseStatus?: number;
  responseBody?: unknown;
  timestamp: Date;
}

interface ApiValidationFixtures {
  apiCalls: ApiCall[];
  env: EnvironmentConfig;
  validateApiHost: (request: Request) => void;
  assertNoForbiddenUrls: () => void;
  assertEndpointCalled: (method: string, pathPattern: string | RegExp) => void;
}

export const test = base.extend<ApiValidationFixtures>({
  env: async ({}, use) => {
    const env = validateEnvironment();
    await use(env);
  },

  apiCalls: async ({}, use) => {
    const calls: ApiCall[] = [];
    await use(calls);
  },

  validateApiHost: async ({ env }, use) => {
    const validator = (request: Request) => {
      const url = request.url();

      // Check for forbidden patterns
      for (const pattern of FORBIDDEN_PATTERNS) {
        if (pattern.test(url)) {
          throw new Error(
            `Forbidden URL pattern detected: ${url}\n` +
            `Pattern: ${pattern}\n` +
            `Frontend should use environment variable API_BASE_URL instead.`
          );
        }
      }

      // Validate API calls go to correct host
      if (url.includes('/api/')) {
        const expectedHost = new URL(env.apiBaseUrl).host;
        const actualHost = new URL(url).host;

        if (actualHost !== expectedHost && !url.includes('localhost')) {
          throw new Error(
            `API call to wrong host!\n` +
            `Expected: ${expectedHost}\n` +
            `Actual: ${actualHost}\n` +
            `URL: ${url}`
          );
        }
      }
    };

    await use(validator);
  },

  assertNoForbiddenUrls: async ({ apiCalls }, use) => {
    const assertFn = () => {
      const violations = apiCalls.filter(call =>
        FORBIDDEN_PATTERNS.some(pattern => pattern.test(call.url))
      );

      if (violations.length > 0) {
        throw new Error(
          `Found ${violations.length} API calls with forbidden URL patterns:\n` +
          violations.map(v => `  - ${v.method} ${v.url}`).join('\n')
        );
      }
    };

    await use(assertFn);
  },

  assertEndpointCalled: async ({ apiCalls }, use) => {
    const assertFn = (method: string, pathPattern: string | RegExp) => {
      const regex = typeof pathPattern === 'string'
        ? new RegExp(pathPattern.replace(/\//g, '\\/'))
        : pathPattern;

      const found = apiCalls.some(
        call => call.method === method && regex.test(call.path)
      );

      expect(found,
        `Expected ${method} ${pathPattern} to be called, but it wasn't.\n` +
        `Actual calls:\n${apiCalls.map(c => `  ${c.method} ${c.path}`).join('\n')}`
      ).toBe(true);
    };

    await use(assertFn);
  },
});

// Re-export expect for convenience
export { expect } from '@playwright/test';

/**
 * Setup API interception for a page
 */
export async function setupApiInterception(
  page: import('@playwright/test').Page,
  apiCalls: ApiCall[],
  validateApiHost: (request: Request) => void
) {
  await page.route('**/api/**', async (route: Route) => {
    const request = route.request();

    // Validate the host
    validateApiHost(request);

    // Record the call
    const call: ApiCall = {
      method: request.method(),
      url: request.url(),
      path: new URL(request.url()).pathname,
      requestBody: request.postDataJSON(),
      timestamp: new Date(),
    };

    // Continue with the request
    const response = await route.fetch();

    call.responseStatus = response.status();
    try {
      call.responseBody = await response.json();
    } catch {
      // Response might not be JSON
    }

    apiCalls.push(call);

    await route.fulfill({ response });
  });
}
```

## Step 3D: Generate Playwright Test Skeleton

Create `e2e/{feature}/{feature}.spec.ts`:

```typescript
/**
 * E2E Tests: {Feature Name}
 *
 * Generated by /project:uat
 * UAT Plan: ../uat-plan.md
 *
 * These tests validate:
 * - User acceptance criteria from spec.md
 * - Correct API host usage (no hardcoded URLs)
 * - Frontend-backend integration
 */

import { test, expect, setupApiInterception } from '../fixtures/api-validation';

// Page Object import (generate separately)
// import { {Feature}Page } from './{feature}.page';

test.describe('{Feature Name}', () => {

  test.beforeEach(async ({ page, apiCalls, validateApiHost }) => {
    // Setup API interception for all tests
    await setupApiInterception(page, apiCalls, validateApiHost);
  });

  test.afterEach(async ({ assertNoForbiddenUrls }) => {
    // Verify no forbidden URLs were called
    assertNoForbiddenUrls();
  });

  // ==========================================================================
  // Smoke Tests (Critical Path)
  // ==========================================================================

  test.describe('Smoke Tests', () => {

    /**
     * UAT-001: {First Critical Scenario}
     * User Story: US-{xxx}
     * Acceptance Criteria: AC-{xxx}
     */
    test('UAT-001: {scenario title}', async ({
      page,
      env,
      assertEndpointCalled
    }) => {
      // Arrange
      // TODO: Setup test data

      // Act
      await page.goto(`${env.apiBaseUrl}/{path}`);
      // TODO: Perform user actions

      // Assert
      // TODO: Verify expected outcomes

      // Verify correct API endpoints were called
      // assertEndpointCalled('POST', '/api/v1/{endpoint}');
    });

  });

  // ==========================================================================
  // Regression Tests
  // ==========================================================================

  test.describe('Regression Tests', () => {

    // TODO: Generate from UAT-plan.md scenarios

  });

  // ==========================================================================
  // Error Handling
  // ==========================================================================

  test.describe('Error Handling', () => {

    /**
     * UAT-ERR-001: {Error Scenario}
     * Validates proper error handling for {scenario}
     */
    test('UAT-ERR-001: {error scenario title}', async ({ page, env }) => {
      // TODO: Implement error scenario test
    });

  });

  // ==========================================================================
  // API Host Validation (CRITICAL)
  // ==========================================================================

  test.describe('API Host Validation', () => {

    test('All API calls use configured API_BASE_URL', async ({
      page,
      env,
      apiCalls,
      assertNoForbiddenUrls
    }) => {
      // Navigate through the feature
      await page.goto(`${env.apiBaseUrl}/{main-path}`);

      // Trigger various API calls by interacting with the page
      // TODO: Add interactions that trigger API calls

      // Verify all calls went to correct host
      for (const call of apiCalls) {
        const callHost = new URL(call.url).host;
        const expectedHost = new URL(env.apiBaseUrl).host;

        expect(callHost,
          `API call went to wrong host: ${call.url}`
        ).toBe(expectedHost);
      }

      // Final check for any forbidden patterns
      assertNoForbiddenUrls();
    });

    test('No hardcoded localhost URLs in API calls', async ({
      page,
      env,
      apiCalls
    }) => {
      await page.goto(`${env.apiBaseUrl}/{main-path}`);
      // TODO: Add interactions

      const localhostCalls = apiCalls.filter(
        call => call.url.includes('localhost') || call.url.includes('127.0.0.1')
      );

      expect(localhostCalls,
        'Found hardcoded localhost URLs in API calls'
      ).toHaveLength(0);
    });

  });

});
```

---

# PHASE 4: UAT-PLAN.MD GENERATION

## Step 4A: Generate UAT Plan Document

Create `.specify/specs/{feature}/uat-plan.md`:

```markdown
# UAT Plan: {Feature Name}

**Generated**: {DATE}
**Feature**: {feature-name}
**Spec Reference**: ./spec.md
**E2E Tests**: ./e2e/

## Summary

**Total Scenarios**: {N}
**Automated**: {X} (Playwright)
**Manual**: {Y}
**Priority Distribution**: {Critical: N, High: M, Medium: P}

## Environment Requirements

### Required Environment Variables

| Variable | Description | Example |
|----------|-------------|---------|
| API_BASE_URL | Base URL for API calls | `https://api.staging.example.com` |
| AUTH_TEST_USER | Test user email | `test@example.com` |
| AUTH_TEST_PASSWORD | Test user password | (from Vault) |

### Pre-execution Checklist

- [ ] Environment variables configured
- [ ] Test data seeded in database
- [ ] API server running and healthy
- [ ] Frontend build completed
- [ ] Browser automation tools installed

## Traceability Matrix

| UAT Scenario | User Story | Acceptance Criteria | Status |
|--------------|------------|---------------------|--------|
| UAT-001 | US-001 | AC-001 | Not Started |
| UAT-002 | US-001 | AC-002 | Not Started |
| UAT-003 | US-002 | AC-001 | Not Started |

## Test Scenarios

### Critical (Smoke Tests)

These scenarios must pass for any release.

{Generated UAT scenarios for critical priority}

### High Priority

{Generated UAT scenarios for high priority}

### Medium Priority

{Generated UAT scenarios for medium priority}

## API Validation Requirements

### Endpoints Under Test

| Endpoint | Method | Used By | Contract Reference |
|----------|--------|---------|-------------------|
| /api/v1/auth/login | POST | LoginForm | rest-api.yaml#login |
| /api/v1/users/me | GET | Dashboard | rest-api.yaml#current-user |

### Validation Rules

1. **No Hardcoded URLs**: Frontend must use `API_BASE_URL` environment variable
2. **Contract Compliance**: All requests/responses must match OpenAPI spec
3. **Error Handling**: API errors must be displayed appropriately to users

## Execution Instructions

### Automated (Playwright)

```bash
# Install dependencies
npm install

# Run all E2E tests
npx playwright test

# Run specific feature tests
npx playwright test e2e/{feature}/

# Run with UI mode for debugging
npx playwright test --ui

# Run only smoke tests
npx playwright test --grep "@smoke"
```

### Interactive (Chrome DevTools)

For exploratory testing or debugging failed scenarios:

```bash
# Use /session:uat command with interactive mode
/session:uat {feature-name} --mode interactive

# This will:
# 1. Load UAT scenarios from this plan
# 2. Use Chrome DevTools Protocol for real-time interaction
# 3. Capture screenshots and API calls
# 4. Generate evidence report
```

## Evidence Collection

### Required Evidence

- [ ] Screenshot at each major step
- [ ] API request/response logs
- [ ] Console error logs (if any)
- [ ] Network waterfall for performance

### Output Location

```
.specify/specs/{feature}/uat-results/
├── uat_{timestamp}.json      # Machine-readable results
├── uat_{timestamp}.md        # Human-readable report
├── screenshots/              # Step screenshots
└── api-logs/                 # API call recordings
```

## Integration Reality Tests (MANDATORY - No Mocks)

**Purpose**: Standard E2E tests often mock API responses, which hides integration failures. Integration Reality tests verify that buttons actually work, pages actually load data, and the frontend correctly communicates with the backend.

### Why Integration Reality Tests?

| Test Type | Mocks Allowed | What It Verifies | Catches |
|-----------|---------------|------------------|---------|
| Unit Tests | Yes | Component logic in isolation | Logic bugs |
| E2E (Behavior) | Yes | UI renders correctly with data | UI bugs |
| **Integration Reality** | **NO** | Buttons work, data loads, auth works | **Wiring bugs** |

**Wiring bugs** are when:
- Handlers are `console.log()` instead of real actions
- Pages don't call `loadData()` on mount
- API endpoints are hardcoded or wrong
- Auth tokens aren't passed correctly

### Integration Reality Test Requirements

For each feature with frontend components, generate BOTH:

**1. Standard E2E Tests (with mocks)** - Test UI behavior predictably:
```typescript
test.describe('Standard E2E: Login', () => {
  test('displays login form correctly', async ({ page }) => {
    // Mock the API to return predictable data
    await page.route('**/api/v1/auth/login', async route => {
      await route.fulfill({
        status: 200,
        json: { token: 'mock-token', user: mockUser }
      });
    });

    await page.goto('/login');
    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // Verify UI behavior
    await expect(page).toHaveURL('/dashboard');
  });
});
```

**2. Integration Reality Tests (NO mocks)** - Test actual wiring:
```typescript
test.describe('@integration-reality Login', () => {
  test.beforeEach(async ({ page }) => {
    // NO MOCKS - hit real API
  });

  test('login button actually calls API', async ({ page }) => {
    await page.goto('/login');

    // Wait for and capture the actual API call
    const responsePromise = page.waitForResponse('**/api/v1/auth/login');

    await page.fill('[name="email"]', 'test@example.com');
    await page.fill('[name="password"]', 'password123');
    await page.click('button[type="submit"]');

    // Verify REAL API was called
    const response = await responsePromise;
    expect(response.ok()).toBe(true);

    // Verify we navigated (not just console.log'd)
    await expect(page).toHaveURL(/dashboard/);
  });

  test('dashboard loads data on mount', async ({ page }) => {
    // Login first (real auth)
    await loginAsTestUser(page);

    // Navigate to dashboard
    const apiPromise = page.waitForResponse('**/api/v1/dashboard');
    await page.goto('/dashboard');

    // Verify API was actually called
    const response = await apiPromise;
    expect(response.ok()).toBe(true);

    // Verify data actually renders (not empty array)
    await expect(page.getByTestId('dashboard-metrics')).toBeVisible();
    await expect(page.getByTestId('task-card')).toHaveCount.greaterThan(0);
  });

  test('task checkbox actually calls API', async ({ page }) => {
    await loginAsTestUser(page);
    await page.goto('/tasks');

    // Wait for initial data load
    await page.waitForResponse('**/api/v1/tasks');

    // Get a task checkbox
    const checkbox = page.getByTestId('task-checkbox').first();

    // Capture the API call when clicking
    const patchPromise = page.waitForResponse(resp =>
      resp.url().includes('/api/v1/tasks/') &&
      resp.request().method() === 'PATCH'
    );

    await checkbox.click();

    // Verify REAL API call happened
    const patchResponse = await patchPromise;
    expect(patchResponse.ok()).toBe(true);
  });
});
```

### Integration Reality Test Categories

Generate tests for these categories:

#### 1. Navigation Tests (buttons actually navigate)
```typescript
test.describe('@integration-reality Navigation', () => {
  test('Start button navigates to task detail', async ({ page }) => {
    await loginAsTestUser(page);
    await page.goto('/dashboard');

    // Click the Start button
    const startButton = page.getByRole('button', { name: 'Start' }).first();
    await startButton.click();

    // Verify REAL navigation happened
    await expect(page).toHaveURL(/\/tasks\/[a-z0-9-]+/);
  });

  test('Review Goals button navigates to goals page', async ({ page }) => {
    await loginAsTestUser(page);
    await page.goto('/dashboard');

    await page.getByRole('button', { name: 'Review Goals' }).click();
    await expect(page).toHaveURL('/goals');
  });
});
```

#### 2. Data Loading Tests (pages fetch on mount)
```typescript
test.describe('@integration-reality Data Loading', () => {
  test('Tasks page loads tasks on mount', async ({ page }) => {
    await loginAsTestUser(page);

    const apiPromise = page.waitForResponse('**/api/v1/tasks');
    await page.goto('/tasks');

    // API must be called
    const response = await apiPromise;
    expect(response.ok()).toBe(true);

    // Data must render
    const tasks = await response.json();
    if (tasks.data.length > 0) {
      await expect(page.getByTestId('task-card')).toHaveCount.greaterThan(0);
    } else {
      await expect(page.getByTestId('empty-state')).toBeVisible();
    }
  });
});
```

#### 3. Form Submission Tests (forms call API)
```typescript
test.describe('@integration-reality Forms', () => {
  test('Create task form actually creates task', async ({ page }) => {
    await loginAsTestUser(page);
    await page.goto('/tasks/new');

    const createPromise = page.waitForResponse(resp =>
      resp.url().includes('/api/v1/tasks') &&
      resp.request().method() === 'POST'
    );

    await page.fill('[name="title"]', 'Test Task');
    await page.click('button[type="submit"]');

    const response = await createPromise;
    expect(response.status()).toBe(201);
  });
});
```

### Integration Reality Test Template

Add this section to the generated `{feature}.spec.ts`:

```typescript
// ==========================================================================
// INTEGRATION REALITY TESTS (NO MOCKS - REAL API)
// ==========================================================================
// These tests verify that the frontend is properly wired to the backend.
// If these fail, buttons might be console.log() instead of real actions,
// or pages might not be loading data on mount.
//
// Run with: npx playwright test --grep @integration-reality
// ==========================================================================

test.describe('@integration-reality {Feature Name}', () => {

  // Helper to login with real credentials
  async function loginAsTestUser(page: Page) {
    await page.goto('/login');
    await page.fill('[name="email"]', process.env.TEST_USER_EMAIL!);
    await page.fill('[name="password"]', process.env.TEST_USER_PASSWORD!);
    await page.click('button[type="submit"]');
    await page.waitForURL(/dashboard|home/);
  }

  test('page loads data on mount (not empty)', async ({ page }) => {
    await loginAsTestUser(page);

    // Navigate and wait for API call
    const apiPromise = page.waitForResponse('**/api/v1/{endpoint}');
    await page.goto('/{page-path}');

    // Verify API was called
    const response = await apiPromise;
    expect(response.ok()).toBe(true);

    // Verify data rendered (not just empty array)
    await expect(page.getByTestId('{data-element}')).toBeVisible();
  });

  test('button click performs action (not console.log)', async ({ page }) => {
    await loginAsTestUser(page);
    await page.goto('/{page-path}');

    // Click the button
    await page.getByRole('button', { name: '{Button Text}' }).click();

    // Verify the action happened (navigation, modal, API call)
    await expect(page).toHaveURL(/{expected-url}/);
    // OR
    await expect(page.getByRole('dialog')).toBeVisible();
    // OR
    const response = await page.waitForResponse('**/api/v1/{endpoint}');
    expect(response.ok()).toBe(true);
  });

});
```

### Running Integration Reality Tests

```bash
# Run only integration reality tests
npx playwright test --grep @integration-reality

# Run with real API (no mock server)
DISABLE_MOCKS=true npx playwright test --grep @integration-reality

# Run against staging environment
API_BASE_URL=https://staging.api.example.com npx playwright test --grep @integration-reality
```

### Integration Reality Gate

Before a feature can be marked complete, Integration Reality tests must pass:

```python
def verify_integration_reality(feature_name):
    """Verify integration reality tests pass before feature completion."""

    result = subprocess.run(
        ["npx", "playwright", "test", "--grep", "@integration-reality", "--reporter=json"],
        capture_output=True,
        text=True,
        env={**os.environ, "DISABLE_MOCKS": "true"}
    )

    if result.returncode != 0:
        print("❌ INTEGRATION REALITY CHECK FAILED")
        print("")
        print("Your mocked E2E tests pass, but real integration fails.")
        print("Common causes:")
        print("  - Handlers are console.log() instead of real actions")
        print("  - Pages don't load data on mount (missing useEffect)")
        print("  - API endpoints are wrong or missing")
        print("")
        print("Fix the integration issues and re-run.")
        return False

    return True
```

## Definition of Done

- [ ] All Critical (smoke) scenarios PASS
- [ ] All High priority scenarios PASS
- [ ] Medium priority scenarios: 90% PASS
- [ ] No hardcoded API URLs detected
- [ ] All API calls match contract specification
- [ ] Evidence collected and stored
- [ ] **Integration Reality tests pass (NO MOCKS)**
  - [ ] All navigation buttons actually navigate
  - [ ] All pages load data on mount (not empty arrays)
  - [ ] All forms actually call APIs on submit
  - [ ] No `console.log()` stub handlers remain

---

**END OF UAT PLAN**
```

---

# PHASE 5: OUTPUT GENERATION

## Step 5A: Create All Output Files

```python
def generate_uat_outputs(feature_name, uat_scenarios, api_endpoints):
    """Generate all UAT-related output files."""

    feature_dir = f".specify/specs/{feature_name}"
    e2e_dir = f"{feature_dir}/e2e"

    # 1. Create directory structure
    os.makedirs(f"{e2e_dir}/config", exist_ok=True)
    os.makedirs(f"{e2e_dir}/fixtures", exist_ok=True)
    os.makedirs(f"{e2e_dir}/{feature_name}", exist_ok=True)

    # 2. Generate uat-plan.md
    uat_plan = generate_uat_plan(feature_name, uat_scenarios, api_endpoints)
    with open(f"{feature_dir}/uat-plan.md", "w") as f:
        f.write(uat_plan)

    # 3. Generate environment.ts
    env_config = generate_environment_config(feature_name, api_endpoints)
    with open(f"{e2e_dir}/config/environment.ts", "w") as f:
        f.write(env_config)

    # 4. Generate api-validation.ts
    api_fixture = generate_api_validation_fixture(feature_name)
    with open(f"{e2e_dir}/fixtures/api-validation.ts", "w") as f:
        f.write(api_fixture)

    # 5. Generate test skeleton
    test_skeleton = generate_test_skeleton(feature_name, uat_scenarios)
    with open(f"{e2e_dir}/{feature_name}/{feature_name}.spec.ts", "w") as f:
        f.write(test_skeleton)

    return {
        "uat_plan": f"{feature_dir}/uat-plan.md",
        "environment_config": f"{e2e_dir}/config/environment.ts",
        "api_validation": f"{e2e_dir}/fixtures/api-validation.ts",
        "test_skeleton": f"{e2e_dir}/{feature_name}/{feature_name}.spec.ts"
    }
```

## Step 5B: Validate Outputs

```bash
# Verify all files created
echo "Validating UAT outputs..."

FILES=(
    ".specify/specs/${FEATURE_NAME}/uat-plan.md"
    ".specify/specs/${FEATURE_NAME}/e2e/config/environment.ts"
    ".specify/specs/${FEATURE_NAME}/e2e/fixtures/api-validation.ts"
    ".specify/specs/${FEATURE_NAME}/e2e/${FEATURE_NAME}/${FEATURE_NAME}.spec.ts"
)

for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "✅ Created: $file"
    else
        echo "❌ Missing: $file"
    fi
done
```

---

# EXECUTION SUMMARY

When you invoke this `/project:uat` command, you will:

1. **Parse spec.md** for user stories, acceptance criteria, and API endpoints
2. **Generate UAT scenarios** from acceptance criteria with full traceability
3. **Create E2E directory structure** with Playwright configuration
4. **Generate environment validation** config for API host checking
5. **Generate API validation fixture** for intercepting and validating calls
6. **Generate Playwright test skeletons** with TODO markers
7. **Create uat-plan.md** with execution instructions

## Output Files

```
.specify/
└── specs/
    └── {feature-name}/
        ├── spec.md                          # ← Input (from /project:prd)
        ├── uat-plan.md                      # ← OUTPUT (UAT scenarios)
        └── e2e/                             # ← OUTPUT (E2E test framework)
            ├── config/
            │   └── environment.ts           # Environment validation
            ├── fixtures/
            │   └── api-validation.ts        # API host validation
            └── {feature}/
                └── {feature}.spec.ts        # Playwright test skeleton
```

## Success Criteria

✅ All user stories mapped to UAT scenarios
✅ All acceptance criteria have corresponding test steps
✅ API endpoints mapped to validation points
✅ Environment validation config generated
✅ API validation fixture generated
✅ Playwright test skeleton generated
✅ Traceability matrix complete
✅ Ready for `/session:uat` execution

## Integration with Session Commands

The generated UAT plan is consumed by:

- **`/session:uat`** - Executes UAT scenarios (automated or interactive)
- **`/session:implement`** - Phase 4 uses API validation for frontend tasks
- **`/session:end`** - UAT gate validates all scenarios passed

---

**END OF /project:uat COMMAND**
