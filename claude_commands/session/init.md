---
description: Initialize project with document indexes, CLAUDE.md master file, and session management for AI-assisted development
---

You are now acting as a **Project Initialization Specialist** responsible for setting up comprehensive project documentation, session management infrastructure, and AI-assisted development workflows with strict TDD enforcement.

# YOUR MISSION

Initialize a software project for AI-assisted development by:
1. Creating optimal directory structure for session management
2. Generating lightweight indexes of large documents (PRD, SRS, UI Plans)
3. Auto-detecting technology stack and environment details
4. Creating CLAUDE.md master file (<500 lines) with all engineering rules
5. Setting up session state management for context recovery

# CORE PRINCIPLES

**Context Optimization**: Minimize token usage through reference-based approach, not content duplication
**Line Number Precision**: All references use L[X]-L[Y] format for exact navigation
**Lazy Loading**: Master file stays lean, detailed content in separate indexed files
**Auto-Detection**: Infer tech stack from project files, ask user only when needed
**Recoverable State**: Session files enable seamless recovery after context resets
**TDD Enforcement**: Build quality gates (80% coverage, 100% pass rate) from day 1

---

# PHASE 1: DIRECTORY STRUCTURE SETUP

## Step 1A: Create Directory Structure

Create the following directory structure if it doesn't exist:

### Spec-Kit Structure (Primary)

```bash
# Create spec-kit structure
mkdir -p .specify/memory
mkdir -p .specify/specs

# Create legacy compatibility directories
mkdir -p state/indexes
mkdir -p DECISIONS
mkdir -p REPORTS
```

**Spec-Kit Directories Created:**
- `.specify/memory/` - Project-wide documents (constitution.md)
- `.specify/specs/` - Per-feature specifications (each feature gets its own subdirectory)
  - `.specify/specs/{feature}/spec.md` - Feature specification (PRD equivalent)
  - `.specify/specs/{feature}/plan.md` - Implementation plan (SRS equivalent)
  - `.specify/specs/{feature}/data-model.md` - Database schemas
  - `.specify/specs/{feature}/contracts/` - API specifications
  - `.specify/specs/{feature}/tasks.md` - Sprint tasks (SCRUM output)
  - `.specify/specs/{feature}/research.md` - Technology investigation
  - `.specify/specs/{feature}/quickstart.md` - Validation scenarios

**Legacy/Support Directories:**
- `state/` - Session management files (current_state.md, next_session_plan.md)
- `state/indexes/` - Document indexes for quick reference
- `DECISIONS/` - Architecture decision records (ADRs)
- `REPORTS/` - Test coverage reports, performance benchmarks, validation/audit reports

**Verification:**
```bash
ls -la .specify/
# Should show: memory/, specs/

ls -la state/
# Should show: indexes/, current_state.md (to be created)
```

If directories already exist, skip creation and note in output.

### Initialize Beads for Task Tracking

```bash
# Initialize beads if not already present
if [ ! -d ".beads" ]; then
    echo "Initializing beads for task tracking..."
    bd init
    bd setup claude  # Install Claude Code hooks
    echo "✅ Beads initialized"
else
    echo "✅ Beads already initialized"
fi

# Verify beads health
bd doctor
```

**Beads Provides:**
- Hash-based IDs prevent merge conflicts in multi-agent mode
- `bd ready` auto-computes tasks with no blocking dependencies
- Git-backed JSONL for audit trail
- `BEADS_NO_DAEMON=1` enables worktree compatibility for parallel execution

### Check for Constitution

```bash
# Check if project constitution exists
if [ -f ".specify/memory/constitution.md" ]; then
  echo "✅ Project constitution found"
else
  echo "⚠️ No project constitution found"
  echo "   Run /project:constitution to establish project principles"
fi
```

## Step 1B: Git Repository Initialization ⚠️ CRITICAL

**This is a MUST NOT MISS step - required for sprint summary reporting**

### Check for Existing Git Repository

```bash
# Check if git repository already exists
if [ -d ".git" ]; then
  echo "✅ Git repository already initialized"
  git status
else
  echo "📦 Initializing new git repository..."
  git init
  echo "✅ Git repository initialized"
fi
```

### Create .gitignore File

Create `.gitignore` file with common patterns (will be enhanced based on tech stack detected in Phase 3):

```gitignore
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
*.egg-info/
.installed.cfg
*.egg
venv/
ENV/
env/
.venv/
htmlcov/
.coverage
.coverage.*
.pytest_cache/
.mypy_cache/
.ruff_cache/

# JavaScript/Node
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.npm
.eslintcache
dist/
build/
coverage/
.next/
out/
.cache/

# IDEs
.vscode/
.idea/
*.swp
*.swo
*~
.DS_Store

# Environment files
.env
.env.local
.env.*.local
*.secret

# Project-specific
REPORTS/
*.log
tmp/
temp/
```

### Initial Commit

```bash
# Stage directory structure (including spec-kit structure)
git add .specify/ state/ DECISIONS/ REPORTS/ .gitignore

# Check what will be committed
git status

# Make initial commit
git commit -m "chore: initialize project structure from /session:init command

- Created .specify/memory/ for project constitution
- Created .specify/specs/ for feature specifications (spec-kit format)
- Created state/ directory for session management
- Created state/indexes/ for document indexes
- Created DECISIONS/ for architecture decision records
- Created REPORTS/ for test coverage and benchmarks
- Added .gitignore with common patterns

Spec-kit structure ready for:
- /project:constitution - Establish project principles
- /project:prd - Create feature spec.md
- /project:srs - Create feature plan.md, data-model.md, contracts/
- /project:scrum - Create feature tasks.md

Generated by: /session:init command"
```

**Verification:**
```bash
# Verify git repository is initialized
git log --oneline
# Should show: initial commit

git branch
# Should show: * main (or master)

git status
# Should show: clean working tree or pending files to add
```

**⚠️ CRITICAL NOTE**: Git repository initialization is the foundation for sprint summary reporting. All sprint work will be committed to this repository, enabling:
- Sprint retrospective commit analysis
- Velocity tracking via commit history
- Code review and change tracking
- Rollback capabilities if sprint work needs reverting

## Step 1C: Create Module Registry

**Purpose**: Create a module registry file that tracks all project modules and their public interfaces. This reduces grepping during sessions by providing a quick reference for module locations and function signatures.

### Create Registry Template

```bash
# Get current date
CURRENT_DATE=$(date +%Y-%m-%d)

# Create module registry file
cat > state/modules_registry.md << EOF
# Module Registry
Version: 1.0.0 | Updated: ${CURRENT_DATE} | Language: {DETECTED}
Project: {PROJECT_NAME}
Last Scan: ${CURRENT_DATE}

---

## Quick Stats
- Total Modules: 0
- Public Interfaces: 0
- Last Modified Module: None

---

## Module Index

| Module | Path | Public Functions | Last Updated |
|--------|------|------------------|--------------|
| *(No modules registered yet)* | | | |

---

## Module Details

<!--
Modules will be automatically added here by /session:end after each sprint.
Each module section includes:
- Path to the module
- Public interface with full type signatures
- Dependencies on other modules
- Changelog of recent changes
-->

---

## Type Definitions

### Shared Types

<!--
Common types used across modules will be documented here.
Python: dataclasses, TypedDicts, Enums
TypeScript: interfaces, types, enums
-->

---

## Dependency Graph

<!--
ASCII diagram showing module dependencies will be generated here.
Example:
    config
       │
  ┌────┼────┐
  ▼    ▼    ▼
users cache logging
  │    │
  └──┬─┘
     ▼
   auth
-->

---

## Registry Maintenance Log

| Date | Action | Module | By |
|------|--------|--------|-----|
| ${CURRENT_DATE} | Created | registry | /session:init |
EOF

echo "✅ Created: state/modules_registry.md"
```

### Initial Module Scan (If Source Code Exists)

If a `src/` directory exists, perform an initial scan to populate the registry with discovered modules:

```python
# Pseudocode for initial module scan
import os
import ast
from pathlib import Path
from datetime import datetime

def scan_python_module(module_path: Path) -> dict | None:
    """Extract public interface from Python module's __init__.py"""
    init_file = module_path / "__init__.py"
    if not init_file.exists():
        return None

    exports = []
    with open(init_file) as f:
        try:
            tree = ast.parse(f.read())
        except SyntaxError:
            return None

    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef):
            # Skip private functions
            if node.name.startswith('_'):
                continue

            # Extract signature with types
            args = []
            for arg in node.args.args:
                if arg.arg == 'self':
                    continue
                arg_type = ast.unparse(arg.annotation) if arg.annotation else "Any"
                args.append(f"{arg.arg}: {arg_type}")

            return_type = ast.unparse(node.returns) if node.returns else "None"
            docstring = ast.get_docstring(node) or ""

            exports.append({
                "name": node.name,
                "type": "function",
                "signature": f"def {node.name}({', '.join(args)}) -> {return_type}",
                "docstring": docstring.split('\n')[0][:100] if docstring else ""
            })

        elif isinstance(node, ast.ClassDef):
            if node.name.startswith('_'):
                continue

            fields = []
            for item in node.body:
                if isinstance(item, ast.AnnAssign) and isinstance(item.target, ast.Name):
                    field_type = ast.unparse(item.annotation) if item.annotation else "Any"
                    fields.append(f"{item.target.id}: {field_type}")

            exports.append({
                "name": node.name,
                "type": "class",
                "fields": fields,
                "docstring": ast.get_docstring(node) or ""
            })

    return {
        "name": module_path.name,
        "path": str(module_path),
        "language": "python",
        "exports": exports
    }

def scan_typescript_module(module_path: Path) -> dict | None:
    """Extract public interface from TypeScript module's index.ts"""
    index_file = module_path / "index.ts"
    if not index_file.exists():
        index_file = module_path / "index.tsx"
    if not index_file.exists():
        return None

    # For TypeScript, use regex patterns to extract exports
    # (Full AST parsing would require a TS parser)
    import re

    content = index_file.read_text()
    exports = []

    # Match exported functions
    func_pattern = r'export\s+(?:async\s+)?function\s+(\w+)\s*(<[^>]+>)?\s*\(([^)]*)\)\s*:\s*([^{]+)'
    for match in re.finditer(func_pattern, content):
        name, generics, params, return_type = match.groups()
        generics = generics or ""
        exports.append({
            "name": name,
            "type": "function",
            "signature": f"function {name}{generics}({params.strip()}): {return_type.strip()}"
        })

    # Match exported interfaces
    interface_pattern = r'export\s+interface\s+(\w+)\s*(<[^>]+>)?\s*\{([^}]+)\}'
    for match in re.finditer(interface_pattern, content):
        name, generics, body = match.groups()
        generics = generics or ""
        exports.append({
            "name": name,
            "type": "interface",
            "signature": f"interface {name}{generics}"
        })

    return {
        "name": module_path.name,
        "path": str(module_path),
        "language": "typescript",
        "exports": exports
    } if exports else None

# Scan src/ directory for modules
src_path = Path("src")
modules_found = []

if src_path.exists():
    for item in src_path.iterdir():
        if item.is_dir():
            # Try Python first
            module_info = scan_python_module(item)
            if module_info:
                modules_found.append(module_info)
                continue

            # Try TypeScript
            module_info = scan_typescript_module(item)
            if module_info:
                modules_found.append(module_info)

if modules_found:
    print(f"📦 Found {len(modules_found)} modules:")
    for m in modules_found:
        print(f"   - {m['name']} ({m['language']}): {len(m['exports'])} exports")
    # Update registry file with discovered modules
    # (Implementation: append module sections to registry)
else:
    print("ℹ️  No source modules found (registry will be populated by /session:end)")
```

### Registry File Format Reference

Each module in the registry follows this format:

```markdown
### {module_name}
**Path**: `src/{module_name}/`
**Language**: Python | TypeScript
**Last Updated**: {DATE}
**Stability**: {0.0-1.0} (0=experimental, 1=stable)

#### Public Interface

```python
# For Python modules:
def function_name(param1: Type1, param2: Type2 = default) -> ReturnType:
    """Brief description of what the function does."""

async def async_function(param: Type) -> Awaitable[ReturnType]:
    """Async function description."""

@dataclass
class ClassName:
    field1: Type1
    field2: Type2
```

```typescript
// For TypeScript modules:
function functionName(param1: Type1, param2?: Type2): ReturnType

async function asyncFunction(param: Type): Promise<ReturnType>

interface InterfaceName {
  field1: Type1;
  field2: Type2;
}
```

#### Dependencies
- `{other_module}` (internal)
- `{external_package}` (external)

#### Changelog
- {DATE}: {Description of change} ({User Story ID})
```

**Verification:**
```bash
# Verify registry file was created
ls -la state/modules_registry.md
# Should show the file exists

# Check file content
head -n 30 state/modules_registry.md
# Should show version header and empty structure
```

---

# PHASE 2: DOCUMENT DISCOVERY & INDEXING

## Step 2A: Discover Project Documents

**PRD (Product Requirements Document) Discovery:**

Search for files matching these patterns (case-insensitive):
1. `prd*.md` (e.g., prd.md, prd-ecommerce.md, PRD_v2.md)
2. `*-prd.md` (e.g., ecommerce-prd.md)
3. `product-requirements*.md`
4. `requirements*.md` (if "product" or "business" in content)

Search locations:
- Project root
- `docs/` folder
- `documentation/` folder
- `.` (current directory)

**SRS (Software Requirements Specification) Discovery:**

Search for files matching these patterns:
1. `srs*.md` (e.g., srs.md, srs-ecommerce.md)
2. `*-srs.md`
3. `software-requirements*.md`
4. `technical-requirements*.md`
5. `system-requirements*.md`

**UI Plan Discovery:**

Search for files matching these patterns:
1. `ui*.md` (e.g., ui.md, ui-plan.md, UI_Implementation.md)
2. `*-ui.md`
3. `ui-implementation*.md`
4. `design-plan*.md`
5. `ux-plan*.md`

**UX Research Discovery:**

Search for files matching these patterns:
1. `ux-research*.md` (e.g., ux-research.md, ux-research-ecommerce.md)
2. `*-ux-research.md`
3. `uxcanvas*.md` (e.g., uxcanvas.md, uxcanvas-ecommerce.md)
4. `*-uxcanvas.md`
5. `ux*.md` (broader pattern, e.g., UX.md, ux.md)
6. `*-ux.md`

**If Documents Not Found:**

Ask user for file paths:

```markdown
## Document Discovery Results

PRD: ❌ Not found automatically
SRS: ❌ Not found automatically
UX Research: ❌ Not found automatically
UI Plan: ❌ Not found automatically

Please provide the paths to your project documents:

**PRD path** (leave blank if none):
[Wait for user input]

**SRS path** (leave blank if none):
[Wait for user input]

**UX Research path** (leave blank if none):
[Wait for user input]

**UI Plan path** (leave blank if none):
[Wait for user input]
```

**If Documents Found:**

```markdown
## Document Discovery Results

✅ PRD found: docs/prd-ecommerce.md (2,850 lines)
✅ SRS found: docs/srs-ecommerce.md (1,820 lines)
✅ UX Research found: docs/ux-research-ecommerce.md (750 lines)
✅ UI Plan found: docs/ui-implementation-plan.md (980 lines)

Proceeding with index generation...
```

## Step 2B: Generate Document Indexes

For each discovered document (PRD, SRS, UX Research, UI Plan), generate a comprehensive index.

### Index Generation Algorithm

**For each document:**

1. **Read the entire document** to get total line count
2. **Parse all headers** at three levels:
   - H1 headers: `# Header` (line number, text)
   - H2 headers: `## Header` (line number, text, parent H1)
   - H3 headers: `### Header` (line number, text, parent H2)
3. **Calculate line ranges** for each section:
   - Section starts at header line
   - Section ends at next header of same or higher level (or EOF)
4. **Generate 1-2 sentence summary** for each section:
   - Read first 3-5 lines of section content (skip empty lines)
   - Extract key information: metrics, counts, technologies, goals
   - Focus on actionable information, not generic descriptions
5. **Count subsections** for nested sections (e.g., "[12 subsections]")
6. **Format hierarchically** with indentation

### PRD Index Template

```markdown
# PRD_INDEX.md
Version: 1.0.0 | Updated: {CURRENT_DATE} | Total Lines: {TOTAL_LINES}
Source: {PRD_FILE_PATH}

## Quick Navigation
- Full Document: {PRD_FILE_PATH} (L1-{TOTAL_LINES})
- Sections: {SECTION_COUNT}
- Features: {FEATURE_COUNT} (estimated)
- Last Modified: {FILE_MTIME}

---

## L{START}-L{END} {H1_TITLE}
{1-2 sentence summary with key metrics, goals, or technologies}

### L{START}-L{END} {H2_TITLE} [{SUBSECTION_COUNT} subsections]
{1-2 sentence summary}

  #### L{START}-L{END} {H3_TITLE}
  {1 sentence summary}

---

## Example Sections

## L1-45 Overview
Project vision, objectives, success metrics. E-commerce platform MVP targeting Q2 2026 launch, $500K budget.

## L46-120 Problem Statement
Customer pain points and market analysis. Current 43% cart abandonment rate, 8min avg checkout vs industry 3min.

### L121-210 Target Users [3 personas, 8 user journeys]
  #### L121-150 Persona 1: Online Buyer
  Primary user persona. Makes 2-5 purchases/month, values speed (checkout <3min) and security (PCI-DSS).

  #### L151-180 Persona 2: Product Seller
  Lists products, manages inventory (500-5000 SKUs), tracks sales analytics, prefers bulk operations.

  #### L181-210 Persona 3: Platform Administrator
  Manages users, handles disputes, monitors system health, requires audit logs and reporting.

## L211-890 Functional Requirements [38 features: P0=18, P1=12, P2=8]
Core product features organized by priority. Authentication, product catalog, cart, checkout, orders.

### L211-340 Authentication & Authorization [9 requirements]
OAuth2 + SSO integration. Session management (24h TTL), MFA support (TOTP), role-based access control (RBAC).

  #### L211-240 OAuth2 Flow
  Authorization code grant with PKCE. Supports Google, GitHub, Microsoft providers. Refresh tokens (30-day expiry).

  #### L241-280 Session Management
  Redis-backed sessions, 24-hour TTL, sliding expiration. Concurrent session limit: 3 devices per user.

  #### L281-320 Multi-Factor Authentication
  TOTP-based (Google Authenticator compatible), backup codes (10 per user), SMS fallback optional.

  #### L321-340 Role-Based Access Control
  3 roles: buyer, seller, admin. Permission matrix defines 24 actions across 8 resources.

### L341-560 Product Catalog [12 requirements]
CRUD operations, search (Elasticsearch), filtering, categories (hierarchical), images (CDN), inventory tracking.

### L561-890 Cart & Checkout [8 requirements]
Session-based cart (30-day persistence), Stripe integration, shipping calculation, tax computation (Avalara API).

## L891-1200 Non-Functional Requirements [Performance, Security, Compliance]
99.9% uptime SLA, <2s p95 latency, GDPR/PCI-DSS compliance, automated backups (daily, 30-day retention).

### L891-980 Performance Requirements
Response times: API <500ms p95, page load <2s p95. Throughput: 1000 req/s sustained, 5000 req/s peak (Black Friday).

### L981-1100 Security Requirements
OWASP Top 10 mitigation, penetration testing (quarterly), encryption at rest (AES-256) and in transit (TLS 1.3).

### L1101-1200 Compliance Requirements
GDPR (EU users), PCI-DSS Level 1 (payment data), SOC 2 Type II (enterprise customers), WCAG 2.1 AA (accessibility).

## L1201-1350 Out of Scope [Explicitly excluded features]
Mobile apps (Phase 2), cryptocurrency payments, internationalization (non-English), B2B features (bulk pricing).

## L1351-1580 Assumptions & Dependencies [Technical, Business, User]
AWS us-east-1 deployment, Postgres 14+ database, existing Stripe account, 100K MAU by month 6.

### L1351-1450 Technical Assumptions
Kubernetes cluster (EKS), managed Postgres (RDS), Redis (ElastiCache), CDN (CloudFront), object storage (S3).

### L1451-1520 Business Assumptions
PMF validated (1000 beta users), funding secured ($500K seed), legal entity established (Delaware C-Corp).

### L1521-1580 User Assumptions
Desktop-first usage (80% traffic), credit card payment preference (90%), English language (100%), US market (95%).

## L1581-1750 Success Metrics [KPIs, Baselines, Targets]
Customer acquisition cost (CAC) <$50, lifetime value (LTV) >$500, LTV:CAC ratio >10:1, churn rate <5%/mo.

## L1751-2850 Appendices [Research, Mockups, Technical Specs]
User research findings (50 interviews), competitor analysis (10 platforms), wireframes (Figma links), API specs.

---

## Usage Instructions

**Loading Specific Sections:**
```markdown
# To load Authentication requirements:
Read prd-ecommerce.md from line 211 to line 340

# To load Performance NFRs:
Read prd-ecommerce.md from line 891 to line 980
```

**Cross-References:**
- Auth implementation → SRS.md L1200-1350 (OAuth2 technical spec)
- Payment flow → SRS.md L1450-1600 (Stripe integration)
- Cart persistence → SRS.md L650-720 (Redis schema)
```

Save this to: `state/indexes/prd_index.md`

### SRS Index Template

```markdown
# SRS_INDEX.md
Version: 1.0.0 | Updated: {CURRENT_DATE} | Total Lines: {TOTAL_LINES}
Source: {SRS_FILE_PATH}

## Quick Navigation
- Full Document: {SRS_FILE_PATH} (L1-{TOTAL_LINES})
- Sections: {SECTION_COUNT}
- API Endpoints: {ENDPOINT_COUNT} (estimated)
- Database Tables: {TABLE_COUNT} (estimated)
- Last Modified: {FILE_MTIME}

---

## L1-280 System Architecture [Microservices, Event-Driven, K8s]
High-level system design. 6 microservices (auth, products, cart, orders, payment, notifications), event bus (RabbitMQ), service mesh (Istio).

### L1-80 Service Boundaries
Bounded contexts per DDD. Auth service (users, sessions, tokens), Product service (catalog, inventory), Order service (fulfillment).

### L81-180 Communication Patterns
Synchronous: REST APIs (HTTP/2) for read operations. Asynchronous: Event-driven (RabbitMQ) for write operations, saga pattern for distributed transactions.

### L181-280 Deployment Architecture
Kubernetes (EKS), 3 availability zones, auto-scaling (CPU >70%), blue-green deployments, canary releases (10% → 50% → 100%).

## L281-650 Data Models [24 entities, 3NF normalization]
Database schema design. Entity-Relationship Diagrams (ERD), table definitions, indexes, foreign keys, constraints.

### L281-380 User Domain [5 tables]
users, user_profiles, user_addresses, user_payment_methods, user_sessions.

  #### L281-320 users Table
  Primary user entity. Fields: id (UUID), email (unique), password_hash (bcrypt), created_at, updated_at, deleted_at (soft delete).

  #### L321-360 user_sessions Table
  Redis-backed session store. Fields: session_id (UUID), user_id (FK), ip_address, user_agent, created_at, expires_at (24h TTL).

### L381-550 Product Domain [8 tables]
products, product_categories, product_images, product_variants, inventory, price_history, product_reviews, product_tags.

### L551-650 Order Domain [6 tables]
orders, order_items, order_status_history, payments, refunds, shipments.

## L651-1200 API Specifications [RESTful, OpenAPI 3.2]
Complete API reference. Endpoints, request/response schemas, authentication, error codes, rate limits (100 req/s per user).

### L651-800 Authentication APIs [6 endpoints]
POST /auth/register, POST /auth/login, POST /auth/logout, POST /auth/refresh, GET /auth/me, POST /auth/verify-email.

  #### L651-700 POST /auth/register
  Create new user account. Request: {email, password, firstName, lastName}. Response: {userId, accessToken, refreshToken}. Errors: 400 (validation), 409 (email exists).

### L801-1000 Product APIs [12 endpoints]
GET /products (list, pagination, filtering), GET /products/:id, POST /products, PUT /products/:id, DELETE /products/:id, GET /products/:id/variants.

### L1001-1200 Order APIs [10 endpoints]
POST /orders (create), GET /orders (list user orders), GET /orders/:id, PUT /orders/:id/cancel, GET /orders/:id/status.

## L1201-1500 Integration Points [External Services, APIs, Dependencies]
Third-party integrations. Stripe (payments), SendGrid (email), Twilio (SMS), Auth0 (SSO), Elasticsearch (search), Avalara (tax).

### L1201-1350 Stripe Payment Integration
PaymentIntent API, webhook handling (payment.succeeded, payment.failed), idempotency keys, retry logic (exponential backoff).

### L1351-1450 SendGrid Email Integration
Transactional emails (order confirmation, shipping notifications), templates (dynamic content), bounce handling, unsubscribe management.

### L1451-1500 Auth0 SSO Integration
OAuth2 provider integration. Social logins (Google, GitHub, Microsoft), SAML for enterprise customers, MFA enforcement.

## L1501-1680 Error Handling [Retry Policies, Circuit Breakers, Fallbacks]
Resilience patterns. Exponential backoff (1s, 2s, 4s, 8s, 16s max), circuit breaker (50% error rate threshold), timeouts (5s API, 30s batch).

## L1681-1820 Security Controls [Threat Model, OWASP Top 10, Compliance]
Security architecture. WAF (AWS WAF), DDoS protection (CloudFlare), SQL injection prevention (parameterized queries), XSS sanitization (DOMPurify).

---

## Usage Instructions

**Loading Specific Sections:**
```markdown
# To load Auth API specs:
Read srs-ecommerce.md from line 651 to line 800

# To load Database schema:
Read srs-ecommerce.md from line 281 to line 650
```

**Cross-References:**
- Auth requirements ← PRD.md L211-340
- Payment requirements ← PRD.md L561-890
- Performance targets ← PRD.md L891-980
```

Save this to: `state/indexes/srs_index.md`

### UI Plan Index Template

```markdown
# UI_INDEX.md
Version: 1.0.0 | Updated: {CURRENT_DATE} | Total Lines: {TOTAL_LINES}
Source: {UI_FILE_PATH}

## Quick Navigation
- Full Document: {UI_FILE_PATH} (L1-{TOTAL_LINES})
- Screens: {SCREEN_COUNT} (estimated)
- Components: {COMPONENT_COUNT} (estimated)
- Last Modified: {FILE_MTIME}

---

## L1-180 Design System [Tailwind, shadcn/ui, Dark Mode]
Visual design language. Colors (primary, secondary, accent), typography (Inter font), spacing scale (4px base), components (42 reusable).

### L1-60 Color Palette
Primary: #3B82F6 (blue-500), Secondary: #10B981 (green-500), Accent: #F59E0B (amber-500), Neutrals: gray-50 to gray-900.

### L61-120 Typography Scale
Headings: font-bold (H1: 36px, H2: 30px, H3: 24px). Body: font-normal (16px base, 14px small, 12px tiny). Line-height: 1.5 (body), 1.2 (headings).

### L121-180 Component Library
42 reusable components built with shadcn/ui. Buttons, forms, modals, tables, cards, navigation, badges, tooltips.

## L181-450 Wireframes [18 screens, Figma]
Screen layouts and user flows. Authentication (login, register, forgot password), product browsing, cart, checkout (3-step), order history.

### L181-250 Authentication Screens [3 screens]
Login (email + password, social logins), Register (email, password, name), Forgot Password (email verification, reset link).

### L251-350 Product Browsing [5 screens]
Product List (grid view, filters, sorting, pagination), Product Detail (images, description, variants, reviews), Search Results, Category Browse.

### L351-450 Checkout Flow [3-step wizard]
Step 1: Shipping Address (autocomplete, validation), Step 2: Payment Method (Stripe Elements, saved cards), Step 3: Review & Confirm (order summary).

## L451-720 Component Specifications [42 reusable components]
Detailed component specs. Props, state, events, accessibility (WCAG 2.1 AA), responsive breakpoints (sm, md, lg, xl).

### L451-500 Button Component
Props: variant (primary, secondary, ghost, danger), size (sm, md, lg), disabled, loading, icon (optional). ARIA: role="button", aria-busy, aria-disabled.

### L501-560 Form Input Component
Props: type (text, email, password, number), label, placeholder, error, required, validation. Accessibility: aria-label, aria-invalid, aria-describedby.

### L561-620 Modal Component
Props: isOpen, onClose, title, children, size (sm, md, lg, full). Keyboard nav: ESC to close, Tab trap, focus management. ARIA: role="dialog", aria-modal.

### L621-720 Data Table Component
Props: columns, data, sortable, paginated, filterable, selectable. Features: client-side or server-side pagination, column sorting, row selection (checkbox).

## L721-980 User Interactions [Animations, Loading States, Error Handling]
Interactive behaviors. Transitions (200ms ease-in-out), loading spinners, skeleton screens, error messages (inline, toast, modal).

### L721-800 Loading States
Skeleton screens for initial load (gray rectangles, pulsing animation). Spinners for actions (button loading, form submission). Progress bars for uploads.

### L801-880 Error Handling
Inline errors (form validation, red text below field). Toast notifications (success, error, info, 5s auto-dismiss). Error pages (404, 500, network error).

### L881-980 Animations & Transitions
Page transitions (fade-in 200ms), modal open/close (scale + fade 300ms), dropdown (slide-down 150ms), hover effects (color change 100ms).

---

## Usage Instructions

**Loading Specific Sections:**
```markdown
# To load Component specs:
Read ui-implementation-plan.md from line 451 to line 720

# To load Checkout flow:
Read ui-implementation-plan.md from line 351 to line 450
```

**Cross-References:**
- Auth screens → SRS.md L651-800 (Auth APIs)
- Payment UI → SRS.md L1201-1350 (Stripe integration)
- Product listing → SRS.md L801-1000 (Product APIs)
```

Save this to: `state/indexes/ui_index.md`

### UX Research Index Template

```markdown
# UX_INDEX.md
Version: 1.0.0 | Updated: {CURRENT_DATE} | Total Lines: {TOTAL_LINES}
Source: {UX_FILE_PATH}

## Quick Navigation
- Full Document: {UX_FILE_PATH} (L1-{TOTAL_LINES})
- Sections: {SECTION_COUNT}
- User Personas: {PERSONA_COUNT} (estimated)
- User Flows: {FLOW_COUNT} (estimated)
- Last Modified: {FILE_MTIME}

---

## L1-150 User Research [Personas, Interviews, Pain Points]
User research findings. 4 primary personas (Admin, Power User, Regular User, Guest), 12 interviews conducted, key insights from user testing.

### L1-50 User Personas [4 personas]
Detailed persona profiles. Demographics, goals, motivations, pain points, tech proficiency, usage patterns.

  #### L1-25 Persona 1: Admin User
  IT administrator managing system. Age: 35-50, tech-savvy, needs: bulk operations, audit logs, user management. Pain points: complex UI, lack of automation.

  #### L26-50 Persona 2: Power User
  Frequent user with advanced needs. Age: 25-40, comfortable with tech, needs: keyboard shortcuts, advanced filters, batch processing. Pain points: repetitive tasks.

### L51-100 User Interviews [12 interviews]
Key findings from user interviews. Common themes: navigation confusion (8/12), slow load times (10/12), missing export functionality (6/12).

### L101-150 Pain Points Analysis [Top 10]
Ranked pain points. 1. Checkout takes too many steps (severity: critical), 2. Search doesn't find relevant results (high), 3. Mobile experience poor (high).

## L151-350 Information Architecture [Site Map, Navigation, Content Strategy]
Site structure and organization. 3-level navigation hierarchy, 18 main sections, breadcrumb navigation, global search, contextual help.

### L151-230 Site Map [18 sections, 3 levels deep]
Complete site structure. Home → Product Catalog (Categories, Search, Filters) → Product Details → Cart → Checkout → Order History.

### L231-300 Navigation Patterns
Primary nav (top bar, 7 items), secondary nav (sidebar, contextual), breadcrumbs (all pages), footer nav (legal, support).

### L301-350 Search & Filters
Search functionality. Autocomplete (3-char min), filters (category, price, rating, availability), faceted search, recent searches, popular searches.

## L351-580 User Flows [12 complete flows, Happy Path + Error States]
Detailed user journey maps. Each flow includes: entry point, steps, decision points, error handling, success criteria, metrics.

### L351-420 Flow 1: User Registration [7 steps]
New user account creation. Entry: Homepage CTA → Email input → Password → Email verification → Profile setup → Welcome → Dashboard. Error states: Email exists, weak password, verification timeout.

### L421-490 Flow 2: Product Discovery [5 steps]
Finding and evaluating products. Entry: Search or Browse → Filters → Product List → Product Details → Add to Cart. Metrics: time to first product view (target: <30s).

### L491-560 Flow 3: Checkout [6-step wizard]
Purchase flow. Cart Review → Guest/Login → Shipping Address → Payment Method → Order Review → Confirmation. Abandonment points: payment (40%), shipping form (25%).

### L561-580 Flow 4-12: Additional Flows
Order tracking, returns, account settings, wishlist, product reviews, customer support, password reset, social login, guest checkout.

## L581-800 Wireframes & Mockups [32 screens, Low-fi → High-fi]
Visual design mockups. Mobile-first approach, responsive breakpoints (sm: 640px, md: 768px, lg: 1024px, xl: 1280px), dark mode variants.

### L581-650 Authentication Screens [5 screens]
Login, Registration, Forgot Password, Email Verification, Social Login callbacks. Accessibility: WCAG 2.1 AA compliant, screen reader tested.

### L651-740 Product Screens [8 screens]
Product List (grid + list views), Product Details (image gallery, specs, reviews), Quick View modal, Comparison tool.

### L741-800 Checkout Screens [6 screens]
Cart, Shipping Form, Payment (Stripe Elements), Order Review, Confirmation, Order Tracking.

## L801-950 Interaction Design [Micro-interactions, Animations, Feedback]
UI behavior specifications. Loading states (skeleton screens, 1-2s), button states (default, hover, active, disabled, loading), form validation (inline, real-time).

### L801-850 Loading States
Skeleton screens for content loading. Product cards: shimmer effect (200ms), infinite scroll: spinner (bottom), page transitions: fade (150ms).

### L851-900 Form Validation
Real-time validation. Email: regex pattern, on blur. Password: strength meter, on input. Credit card: Luhn algorithm, on blur. Error messages: inline, accessible (ARIA).

### L901-950 Micro-interactions
Button clicks: ripple effect (300ms). Tooltips: fade in (200ms), on hover. Notifications: toast (slide from top, auto-dismiss 5s). Modal: fade + scale (250ms).

## L951-1100 Accessibility Requirements [WCAG 2.1 AA]
Accessibility compliance specifications. Keyboard navigation (all interactive elements), screen reader support (semantic HTML, ARIA labels), color contrast (4.5:1 text, 3:1 UI components).

### L951-1000 Keyboard Navigation
Tab order logical, Enter activates buttons/links, Escape closes modals, Arrow keys navigate menus/dropdowns, Space checks checkboxes.

### L1001-1050 Screen Reader Support
All images have alt text, form labels associated, headings hierarchical (H1→H2→H3), landmarks (header, nav, main, footer), live regions for dynamic content.

### L1051-1100 Color & Contrast
Text contrast 4.5:1 minimum (normal text), 3:1 (large text, UI components). Don't rely on color alone (icons + text). Link underlines or bold. Focus indicators visible (2px outline).

---

## Usage Instructions

**Loading Specific Sections:**
```markdown
# To load User Personas:
Read ux-research-ecommerce.md from line 1 to line 50

# To load User Flows:
Read ux-research-ecommerce.md from line 351 to line 580
```

**Cross-References:**
- User flows → UI Plan L181-450 (wireframes match flows)
- Personas → PRD L121-250 (target users)
- Accessibility → UI Plan L451-720 (component specs include WCAG)
```

Save this to: `state/indexes/ux_index.md`

## Step 2C: Verify Index Generation

After generating all indexes, verify:

```bash
# Check index files exist
ls -la state/indexes/
# Should show: prd_index.md, srs_index.md, ui_index.md (if docs found)

# Check file sizes (should be reasonable, not huge)
du -h state/indexes/*
# Target: 20-100 KB per index (not megabytes)

# Verify indexes are readable
head -n 50 state/indexes/prd_index.md
# Should show: version, navigation, first few sections
```

**Output Summary:**

```markdown
## Document Indexing Complete ✅

Indexes created:
- ✅ state/indexes/prd_index.md (185 lines, ~8 KB)
- ✅ state/indexes/srs_index.md (142 lines, ~6 KB)
- ✅ state/indexes/ui_index.md (98 lines, ~4 KB)

Total indexed lines: 5,650 (PRD: 2,850 + SRS: 1,820 + UI: 980)
Index overhead: 425 lines (~7.5% of original documents)
Context savings: Reading all indexes (~18 KB) vs all documents (~250 KB) = 93% reduction

Next: Environment detection...
```

---

# PHASE 3: ENVIRONMENT DETECTION

## Step 3A: Detect Technology Stack

Auto-detect technologies from project files to populate TECH_STACK.md and CLAUDE.md.

### Python Detection

**Check for files:**
- `pyproject.toml` (Poetry, modern Python projects)
- `requirements.txt` (pip, traditional Python)
- `setup.py` (legacy packaging)
- `Pipfile` (Pipenv)
- `conda.yml` or `environment.yml` (Conda)
- `.python-version` (pyenv version pinning)

**Extract information:**

```python
# From pyproject.toml:
[tool.poetry.dependencies]
python = "^3.11"          → Python 3.11+
fastapi = "^0.104.0"      → Framework: FastAPI
sqlalchemy = "^2.0"       → ORM: SQLAlchemy
alembic = "^1.12"         → Migrations: Alembic
pydantic = "^2.4"         → Validation: Pydantic
redis = "^5.0"            → Cache: Redis client
pytest = "^7.4"           → Testing: pytest
pytest-cov = "^4.1"       → Coverage: pytest-cov

[tool.pytest.ini_options]
addopts = "--cov=src --cov-fail-under=80"  → Coverage threshold: 80%
```

**Detection script pseudocode:**
1. If `pyproject.toml` exists: Parse with TOML parser, extract dependencies
2. If `requirements.txt` exists: Parse line by line, extract package names + versions
3. If `.python-version` exists: Read Python version
4. Identify framework: FastAPI | Django | Flask | Other (check dependencies)
5. Identify ORM: SQLAlchemy | Django ORM | Tortoise | Other
6. Identify testing: pytest | unittest | nose
7. Extract coverage threshold from pytest config

### JavaScript/TypeScript Detection

**Check for files:**
- `package.json` (npm, yarn, pnpm, bun)
- `package-lock.json` (npm)
- `yarn.lock` (Yarn)
- `pnpm-lock.yaml` (pnpm)
- `bun.lockb` (Bun)

**Extract information:**

```json
// From package.json:
{
  "name": "ecommerce-frontend",
  "engines": {"node": ">=20.0.0"},     → Node 20+
  "dependencies": {
    "next": "^14.0.4",                 → Framework: Next.js 14
    "react": "^18.2.0",                → UI: React 18
    "@tanstack/react-query": "^5.0"   → State: TanStack Query
  },
  "devDependencies": {
    "vitest": "^1.0.4",                → Testing: Vitest
    "typescript": "^5.2.2"             → Language: TypeScript 5.2
  },
  "scripts": {
    "test": "vitest --coverage"        → Test command
  }
}

// From jest.config.js or vitest.config.ts:
export default {
  coverage: {
    lines: 80,                         → Coverage threshold: 80%
    functions: 80,
    branches: 80,
    statements: 80
  }
}
```

**Detection script pseudocode:**
1. Parse `package.json`
2. Extract Node version from `engines.node`
3. Identify framework: Next.js | React | Vue | Angular | Svelte (check dependencies)
4. Identify build tool: Vite | Webpack | Turbopack | esbuild (check devDependencies)
5. Identify testing: Vitest | Jest | Mocha | Cypress (check devDependencies)
6. Determine package manager: Check lock file (package-lock.json → npm, yarn.lock → Yarn, etc.)
7. Extract test command from `scripts.test`

### Docker Detection

**Check for files:**
- `Dockerfile`
- `docker-compose.yml` or `docker-compose.yaml`
- `.dockerignore`

**Extract information:**

```yaml
# From docker-compose.yml:
services:
  app:
    build: .
    ports: ["8000:8000"]               → App port: 8000
  postgres:
    image: postgres:15                 → Database: Postgres 15
    ports: ["5432:5432"]
    volumes: ["pgdata:/var/lib/postgresql/data"]
  redis:
    image: redis:7-alpine              → Cache: Redis 7
    ports: ["6379:6379"]
```

**Detection script pseudocode:**
1. Parse `docker-compose.yml` (YAML format)
2. Extract services: app, postgres, redis, nginx, etc.
3. For each service: Image name, version, ports, volumes
4. Build service map: {name: postgres, version: 15, port: 5432}

### CI/CD Detection

**Check for files:**
- `.github/workflows/*.yml` (GitHub Actions)
- `.gitlab-ci.yml` (GitLab CI)
- `.circleci/config.yml` (CircleCI)
- `.travis.yml` (Travis CI)
- `Jenkinsfile` (Jenkins)
- `azure-pipelines.yml` (Azure Pipelines)

**Extract information:**

```yaml
# From .github/workflows/test.yml:
name: Test & Coverage
on: [push, pull_request]               → Triggers: push, PR
jobs:
  test:
    runs-on: ubuntu-latest             → Runner: Ubuntu
    steps:
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'       → Python 3.11
      - run: pytest --cov=src --cov-fail-under=80  → Coverage gate: 80%
```

**Detection script pseudocode:**
1. Check for CI/CD config files
2. Identify platform: GitHub Actions | GitLab CI | CircleCI | Other
3. Extract triggers: push, pull_request, schedule
4. Extract jobs: test, build, deploy
5. Identify deployment targets: AWS | Vercel | Heroku | Other (check deploy scripts)

### Build Tools Detection

**Check for files:**
- `Makefile` (Make)
- `webpack.config.js` (Webpack)
- `vite.config.ts` (Vite)
- `rollup.config.js` (Rollup)
- `tsconfig.json` (TypeScript compiler)
- `babel.config.js` (Babel transpiler)
- `tailwind.config.js` (Tailwind CSS)

**Detection script pseudocode:**
1. Check for build tool configs
2. Identify bundler: Vite | Webpack | Rollup | esbuild
3. Identify compiler: TypeScript | Babel | SWC
4. Identify CSS framework: Tailwind | styled-components | Sass

## Step 3B: Generate TECH_STACK.md

Create `TECH_STACK.md` with auto-detected information.

```markdown
# TECHNOLOGY STACK (Auto-Detected)
Last Updated: {CURRENT_DATE_TIME}
Auto-Detection Version: 1.0.0

## Languages & Versions
- **Python:** 3.11.6 (Source: pyproject.toml, .python-version)
- **JavaScript:** Node 20.10.0 (Source: package.json engines)
- **TypeScript:** 5.2.2 (Source: package.json devDependencies)

## Frameworks
- **Backend:** FastAPI 0.104.0 (Source: pyproject.toml)
- **Frontend:** Next.js 14.0.4 (Source: package.json)
- **UI Library:** React 18.2.0 (Source: package.json)
- **ORM:** SQLAlchemy 2.0.23 (Source: pyproject.toml)

## Databases
- **Primary:** PostgreSQL 15 (Source: docker-compose.yml, postgres service)
  - Port: 5432
  - Volume: pgdata
- **Cache:** Redis 7.2.3 (Source: docker-compose.yml, redis service)
  - Port: 6379
  - Purpose: Session storage, caching

## Infrastructure
- **Containerization:** Docker 24.0.6, Docker Compose 2.23.0
- **Services:** 3 containers (app, postgres, redis)
- **Orchestration:** None detected (no Kubernetes configs found)

## Build Tools
- **Python Build:** Poetry 1.7.0 (Source: poetry.lock)
- **JavaScript Build:** npm 10.2.4 (Source: package-lock.json)
- **Bundler:** Vite 5.0.0 (Source: vite.config.ts)
- **TypeScript Compiler:** tsc 5.2.2 (Source: tsconfig.json)

## Testing
- **Python Testing:** pytest 7.4.3 + pytest-cov 4.1.0
  - Config: pyproject.toml [tool.pytest.ini_options]
  - Command: `pytest --cov=src --cov-fail-under=80`
  - Coverage Threshold: 80%
  - Coverage Report: htmlcov/index.html

- **JavaScript Testing:** Vitest 1.0.4
  - Config: vitest.config.ts
  - Command: `npm test -- --coverage`
  - Coverage Threshold: 80% (lines, functions, branches, statements)
  - Coverage Report: coverage/lcov-report/index.html

## CI/CD
- **Platform:** GitHub Actions
- **Workflows:**
  - `.github/workflows/test.yml` - Run tests + coverage on push/PR
  - `.github/workflows/deploy.yml` - Deploy to staging/production
- **Triggers:** push, pull_request
- **Deployment:** (Not detected - manual inspection required)

## Package Management
- **Python:** Poetry (pyproject.toml, poetry.lock present)
  - Install: `poetry install`
  - Add dependency: `poetry add <package>`
  - Update: `poetry update`

- **JavaScript:** npm (package.json, package-lock.json present)
  - Install: `npm install`
  - Add dependency: `npm install <package>`
  - Update: `npm update`

## Code Quality
- **Python Linting:** Ruff (Source: pyproject.toml devDependencies)
- **Python Formatting:** Black (Source: pyproject.toml devDependencies)
- **Python Type Checking:** mypy (Source: pyproject.toml devDependencies)

- **JavaScript Linting:** ESLint (Source: package.json devDependencies)
- **JavaScript Formatting:** Prettier (Source: package.json devDependencies)
- **TypeScript:** Strict mode enabled (Source: tsconfig.json)

## Pre-Commit Hooks
- **Tool:** Husky (Source: .husky/ directory)
- **Hooks:**
  - `.husky/pre-commit` - Run tests with coverage enforcement
  - `.husky/pre-push` - Run full test suite

## Environment Variables
- **File:** .env.local (gitignored, see .env.example)
- **Required Variables:** 12 detected
  - DATABASE_URL (Postgres connection string)
  - REDIS_URL (Redis connection string)
  - SECRET_KEY (Session encryption)
  - STRIPE_SECRET_KEY (Payment processing)
  - STRIPE_PUBLISHABLE_KEY (Frontend integration)
  - SENDGRID_API_KEY (Email service)
  - (6 more variables in .env.example)

## Port Mappings (Local Development)
- **Backend API:** 8000 (FastAPI)
- **Frontend:** 3000 (Next.js dev server)
- **Database:** 5432 (Postgres)
- **Cache:** 6379 (Redis)
- **(Optional) DB Admin:** 5050 (pgAdmin, if configured)

## Detection Commands Used
```bash
# Python version
python --version                 # 3.11.6
cat .python-version              # 3.11

# Node version
node --version                   # v20.10.0
grep '"node":' package.json      # ">=20.0.0"

# Docker info
docker --version                 # 24.0.6
docker-compose --version         # 2.23.0

# Package manager versions
poetry --version                 # 1.7.0
npm --version                    # 10.2.4
```

## Development Commands Quick Reference

### Setup
```bash
# Start services
docker-compose up -d

# Install Python dependencies
poetry install

# Install JavaScript dependencies
npm install

# Run database migrations
poetry run alembic upgrade head
```

### Development
```bash
# Run backend (with hot reload)
poetry run uvicorn src.main:app --reload --port 8000

# Run frontend (with hot reload)
npm run dev
```

### Testing
```bash
# Python tests with coverage
pytest --cov=src --cov-report=html --cov-fail-under=80

# JavaScript tests with coverage
npm test -- --coverage

# Run both test suites
make test  # (if Makefile exists)
```

### Database
```bash
# Create migration
poetry run alembic revision --autogenerate -m "description"

# Apply migrations
poetry run alembic upgrade head

# Rollback migration
poetry run alembic downgrade -1
```

### Code Quality
```bash
# Python linting + formatting
poetry run ruff check src/
poetry run black src/
poetry run mypy src/

# JavaScript linting + formatting
npm run lint
npm run format
```

---

## Notes
- Auto-detection accuracy: ~90% (manual verification recommended)
- Missing information: Deployment targets, production URLs, monitoring tools
- Manual updates needed: As project evolves, re-run `/init` to refresh
- Last auto-detected: {CURRENT_DATE_TIME}
```

Save this to: `TECH_STACK.md`

## Step 3C: Confirm Detected Technologies

After generating TECH_STACK.md, show summary to user for confirmation:

```markdown
## Technology Stack Detection Complete ✅

**Detected Stack:**
- Languages: Python 3.11, JavaScript (Node 20), TypeScript 5.2
- Backend: FastAPI 0.104
- Frontend: Next.js 14 + React 18
- Database: Postgres 15 + Redis 7
- Testing: pytest (80% threshold), Vitest (80% threshold)
- Package Managers: Poetry (Python), npm (JavaScript)
- Containerization: Docker + Docker Compose (3 services)
- CI/CD: GitHub Actions

**Is this correct?**
- ✅ YES - Proceed with CLAUDE.md generation
- 🔧 UPDATE - I need to correct some details
- ➕ ADD - Missing technologies not detected

[Wait for user response]
```

If user selects "UPDATE" or "ADD", allow them to provide corrections:

```markdown
Please provide corrections or additions:

**Languages:** [Current: Python 3.11, JavaScript/TypeScript]
Update: _______

**Frameworks:** [Current: FastAPI, Next.js]
Update: _______

**Databases:** [Current: Postgres 15, Redis 7]
Update: _______

**Additional Technologies:** (e.g., Elasticsearch, RabbitMQ, etc.)
_______

[Wait for user input, then update TECH_STACK.md and continue]
```

---

# PHASE 4: CLAUDE.md CREATION

## Step 4A: Generate CLAUDE.md Master File

Create the authoritative master file for AI-assisted development. This file MUST stay under 500 lines.

**CLAUDE.md Template:**

```markdown
# PROJECT MASTER (v1.0.0) | Updated: {CURRENT_DATE}
Lines: {LINE_COUNT}/500 | Context Budget: {PERCENTAGE}%

**IMPORTANT: This file MUST remain under 500 lines. Reference other documents, don't duplicate content.**

---

## 1. MUST DO RULES OF ENGINEERING (Non-Negotiable)

### Rule 1: Test-Driven Development (TDD)
**80% Coverage Minimum | 100% Pass Rate Required | Quality-First Methodology**

**Before moving to next sprint:**
- ✅ Overall code coverage ≥80% (verified by coverage tool)
- ✅ Module-specific coverage ≥80% (no modules below threshold)
- ✅ 100% test pass rate (0 failing tests)
- ✅ No skipped tests without documented reason
- ✅ Architectural tests passing (no layer/boundary violations)
- ✅ Contract tests passing (if inter-module communication exists)

**Coverage Commands:**
```bash
# Python
pytest --cov=src --cov-report=term-missing --cov-fail-under=80

# JavaScript/TypeScript (Vitest)
npx vitest run --coverage

# JavaScript/TypeScript (Jest)
npm test -- --coverage --coverageThreshold='{"global":{"lines":80}}'

# View HTML reports
open htmlcov/index.html              # Python
open coverage/lcov-report/index.html # JavaScript
```

---

#### TDD Schools of Thought (Know When to Apply Each)

| Context | School | Approach | Mock? |
|---------|--------|----------|-------|
| Module boundary (API, gateway) | London | Verify interaction protocol | ✅ YES |
| Domain logic (inside module) | Chicago | Verify state/output | ❌ NO |
| Cross-module communication | Contract | Consumer-driven contracts | N/A |
| Database/external service | Integration | Use TestContainers | Real service |

**Hybrid Strategy (RECOMMENDED):**
- Mock at module BOUNDARIES (external APIs, other modules)
- Use REAL collaborators INSIDE modules (domain objects, value objects)
- This enables refactoring freedom while verifying integration

---

#### Test Type Selection Guide

```
Module behavior        → Component Test (module as black box via API)
Domain logic           → Sociable Unit Test (real internal collaborators)
Inter-module API       → Contract Test (Pact)
Database/IO            → Narrow Integration Test (TestContainers)
Full user flow         → Subcutaneous Test (bypass browser, test API layer)
Architecture rules     → import-linter / dependency-cruiser
```

**Sociable vs Solitary:**
- **Sociable (DEFAULT)**: Test behavior of aggregate + real collaborators within module
- **Solitary**: Only for pure functions with zero dependencies

---

#### TDD MUST DOs ✅

1. **Use Sociable Unit Tests as Default**
   - Test module behavior, not individual classes
   - Allow real collaborators within module boundaries
   - Mock ONLY external modules, databases, and APIs

2. **Apply Hybrid TDD Strategy**
   - London-style mocks at module BOUNDARIES (APIs, gateways)
   - Chicago-style state verification INSIDE modules (domain logic)

3. **Test at the Right Level**
   - Component tests for module behavior (treat module as black box)
   - Contract tests for inter-module communication
   - Narrow integration tests for infrastructure (use TestContainers)

4. **Write Architectural Tests**
   - Enforce module isolation programmatically
   - Python: Use `import-linter` or custom pytest fixtures
   - JavaScript: Use `eslint-plugin-boundaries` or `dependency-cruiser`
   - Fail builds on layer violations or circular dependencies

5. **Follow Parallel Change for API Changes**
   - **Expand**: Add new method/endpoint alongside old
   - **Migrate**: Move consumers to new API
   - **Contract**: Remove old only when all consumers migrated

6. **Use Polling for Async Tests**
   ```python
   # Python - use tenacity or polling
   from tenacity import retry, stop_after_delay, wait_fixed

   @retry(stop=stop_after_delay(10), wait=wait_fixed(0.5))
   def wait_for_event():
       assert event_store.has_event("OrderCreated")
   ```
   ```javascript
   // JavaScript - use waitFor from testing-library
   await waitFor(() => {
     expect(eventStore.hasEvent("OrderCreated")).toBe(true);
   }, { timeout: 10000 });
   ```

---

#### TDD MUST NOTs ❌

1. **NEVER mock internal module collaborators**
   - Creates brittle tests coupled to implementation
   - Prevents safe refactoring
   - If refactoring breaks tests, tests were over-specified

2. **NEVER assert on interaction sequences within modules**
   - `verify(mock).called()` inside module = FRAGILE
   - Assert on STATE or OUTPUT instead
   - Exception: boundary classes (gateways, adapters)

3. **NEVER use sleep() for async tests**
   ```python
   # ❌ BAD
   time.sleep(5)
   assert result.is_ready

   # ✅ GOOD
   await wait_for(lambda: result.is_ready, timeout=5)
   ```

4. **NEVER skip contract tests for module communication**
   - Even in modular monolith
   - Catches breaking changes at BUILD time, not runtime

5. **NEVER rely solely on E2E tests**
   - Slow, flaky, hard to debug
   - Use subcutaneous tests (API-level) instead where possible
   - E2E for critical happy paths only

6. **NEVER test implementation details**
   ```python
   # ❌ BAD - Testing that discount calculator was called
   mock_calc = Mock()
   order.apply_discount(mock_calc)
   mock_calc.calculate.assert_called_once()

   # ✅ GOOD - Testing the behavior
   order.apply_discount("SUMMER20")
   assert order.total == 80.00
   ```

---

#### Architectural Testing Setup

**Python (import-linter):**
```toml
# pyproject.toml
[tool.importlinter]
root_package = "src"

[[tool.importlinter.contracts]]
name = "Domain should not import infrastructure"
type = "forbidden"
source_modules = ["src.domain"]
forbidden_modules = ["src.infrastructure", "src.api"]

[[tool.importlinter.contracts]]
name = "No circular dependencies between modules"
type = "independence"
modules = ["src.orders", "src.users", "src.payments"]
```

**JavaScript (dependency-cruiser):**
```javascript
// .dependency-cruiser.js
module.exports = {
  forbidden: [
    {
      name: 'no-domain-to-infra',
      from: { path: '^src/domain' },
      to: { path: '^src/infrastructure' }
    },
    {
      name: 'no-circular',
      from: { path: '^src/modules' },
      to: { circular: true }
    }
  ]
};
```

**Enforcement Points:**
- Pre-commit hook: `.husky/pre-commit` blocks commits if coverage <80%
- CI/CD: GitLab/GitHub fails build if tests fail or coverage <80%
- Sprint gate: Cannot mark sprint complete without meeting thresholds
- Architectural tests: Run on every commit

**⚠️ CRITICAL: Claude cannot proceed to next sprint without 80% coverage + 100% pass rate + Architectural tests passing**

### Rule 2: PRD is King
**Product Requirements Document is the Source of Truth**

If there's ANY deviation from PRD:
1. **STOP** - Do not proceed with implementation
2. **ASK** - Explicitly ask the user for a decision
3. **DOCUMENT** - Record the decision in DECISIONS/ folder
4. **UPDATE** - Update PRD if user approves the change

**Examples of deviations:**
- Adding features not in PRD
- Changing API contracts defined in PRD
- Modifying user flows or acceptance criteria
- Altering success metrics or KPIs
- Removing requirements without user approval

**Acceptable deviations (still ask user):**
- Technical implementation details not specified in PRD
- Database schema choices (if PRD only specifies requirements)
- Internal code organization
- Performance optimizations

**Documentation Reference:**
- PRD Index: state/indexes/prd_index.md
- PRD Full: {PRD_FILE_PATH}

### Rule 3: Session Start Protocol (ALWAYS)
**Every session MUST begin with these 3 steps:**

**Step 1: Read Session Plan & References**
```bash
# Read next session plan
cat state/next_session_plan.md

# Read referenced materials (line numbers will be specified)
# Example: "Read PRD L211-340 (Authentication requirements)"
# Example: "Read sprints/sprint_03/sprint_plan.md L145-190 (US-023 details)"
```

**Step 2: Do Research**
Research how to implement the sprint features:
- Which expert agents to use? (backend-systems-architect, fastapi-expert, etc.)
- Which skills to use? (if applicable)
- Technical approach (libraries, patterns, architectures)
- Dependencies and prerequisites

Document in: `sprints/sprint_{NN}/research.md` (if doesn't exist)
Format:
- Problem statement (what we're solving)
- Solution options (2-3 alternatives evaluated)
- Technical decisions
- Expert agents/skills to use
- Risks and mitigations

**Step 3: Plan Implementation**
Plan HOW features will be implemented in code:
- Breakdown of tasks (file-level granularity)
- Where to use expert agents (specific tasks)
- Where to use skills (specific operations)
- Test strategy (what to test, how to achieve 80% coverage)
- Estimated time per task

Document in: `sprints/sprint_{NN}/implementation_plan.md`
Format:
- User story breakdown
- File changes required
- Expert agent assignments
- Test coverage strategy
- Order of implementation

### Rule 4: During Session - Document State Every 5 Minutes
**Active Documentation is Critical for Recovery**

Update `state/current_state.md` at least every 5 minutes with:
- Last completed task (file, line numbers, what was done)
- Current task in progress (what you're working on now)
- Active file being edited (path + line numbers)
- Test status (passing/failing, coverage percentage)
- Blockers or questions (what's stuck)

**Why 5 minutes?**
- Context window can reset unexpectedly
- Sessions can be interrupted
- Detailed trail enables seamless recovery

**Template for updates:**
```markdown
## Last Update: {TIMESTAMP}

**Last Completed:** Implemented webhook retry logic in src/payment/webhooks.py L220-245
**Current Task:** Adding idempotency key storage (Redis vs Postgres - decision pending)
**Active File:** src/payment/idempotency.py L1-80 (in progress)
**Tests:** 156/158 passing (98.7%), coverage 81.2%
**Blocker:** Idempotency storage strategy needs user decision

**Next Step:** Wait for user decision on Redis vs Postgres for idempotency keys
```

**Set a timer:** Use system timer or mental checkpoint every 5 minutes to update state

### Rule 5: Session End Protocol (ALWAYS)
**Every session MUST end with these 3 steps:**

**Step 1: Validate Research & Plan Match Delivery**
Compare what was planned vs. what was delivered:
- All planned tasks complete? (checklist in implementation_plan.md)
- All tests passing? (pytest, npm test)
- Coverage ≥80%? (coverage reports)
- Any deviations from plan? (document why)

Document in: `sprints/sprint_{NN}/validation.md`
Format:
- Planned vs. Actual comparison
- Test results (pass rate, coverage)
- Deviations explained
- Remaining work (if any)

**If mismatch exists:**
- ⚠️ DO NOT end session
- ✅ MUST finish all prescribed work in plan
- 📝 Update plan if scope changed (with user approval)

**Step 2: Document Next Session Plan**
Create/update `state/next_session_plan.md`:
- Where we left off (last completed work)
- What's next (from current sprint plan)
- Immediate steps (3-5 specific tasks)
- Dependencies (what's needed before starting)
- Recovery commands (git status, pytest, etc.)

Informed by: `sprints/sprint_{NN}/sprint_plan.md` (next sprint if current is complete)

**Step 3: Update CLAUDE.md Current Status & Roadmap**
Update THIS FILE with:
- Current sprint and progress (Section 2)
- Active user story and status (Section 2)
- Recent work completed (Section 2)
- Next immediate steps (Section 2)
- Roadmap progress (Section 3: mark completed items with ✅)

**⚠️ CRITICAL: CLAUDE.md MUST be in sync with actual sprint status**
- If sprint complete: Mark sprint ✅ in roadmap
- If user story complete: Update current status
- If blocked: Document blocker in current status

### Rule 6: When in Doubt, Ask
**User is the ultimate decision maker**

**ALWAYS ASK if you're uncertain about:**
- Deviation from PRD
- Technical approach choice (multiple valid options)
- Priority decisions (what to work on next)
- Scope changes (adding/removing features)
- Architecture decisions with tradeoffs
- Resource allocation (time, effort, complexity)
- Security or compliance decisions
- Any business logic or user experience questions

**How to ask:**
- Be specific about the decision needed
- Present options with pros/cons
- Recommend a choice (but defer to user)
- Explain impact of each option

**Example:**
```markdown
## Decision Needed: Idempotency Key Storage

**Question:** Where should we store idempotency keys for webhook processing?

**Option 1: Redis (recommended)**
- Pros: Fast, auto-expiration (24h TTL), lower DB load
- Cons: Data loss risk if Redis crashes, not queryable
- Impact: Better performance, simpler cleanup

**Option 2: Postgres**
- Pros: Durable, queryable, no data loss risk
- Cons: Requires manual cleanup job, DB load increase
- Impact: More reliable, higher complexity

**Recommendation:** Redis for simplicity and performance (Stripe webhooks are idempotent anyway)

**Your decision:** ___________
```

**Never guess on important decisions - ask the user!**

### Rule 7: Modular Architecture
**Package by Feature | Minimize Coupling | Information Hiding**

**ALWAYS follow these structural principles:**

**1. Package by Feature, NOT by Layer**
- Group code by business capability (e.g., `auth/`, `billing/`, `products/`)
- NEVER use layer-based folders at top level (`controllers/`, `services/`, `models/`)
- Each feature folder is a self-contained module with its own tests

**2. Functional Cohesion**
- Each module serves ONE business capability owned by ONE stakeholder
- Ask: "Which department would fire me if this module broke?" (SRP Actor Rule)
- If the answer is multiple departments, split the module

**3. Information Hiding (Explicit Public APIs)**
- Every module MUST have a public API file (`__init__.py` for Python, `index.ts` for TypeScript)
- Export ONLY what consumers need - internal helpers stay private
- NEVER import from another module's internal/private folders

**4. Minimal Coupling**
- Use dependency injection for external services
- Prefer Connascence of Name (weakest coupling) over tighter forms
- NO train wreck code: `obj.a.b.c.method()` violates Law of Demeter
- Wrap exceptions at module boundaries (no leaky abstractions)

**5. Acyclic Dependencies**
- NO circular dependencies between modules (will be enforced at session end)
- If Module A imports from Module B, Module B cannot import from Module A
- Tool check: `npx madge --circular src/` or `pydeps --check-circular`

**6. Stable Dependencies Principle**
- Dependencies flow from UNSTABLE → STABLE modules
- UI components (unstable) can depend on domain logic (stable), NOT reverse
- Track module stability using Instability metric: I = FanOut/(FanIn+FanOut)

**7. Bounded Contexts**
- Each module has its own domain language (Ubiquitous Language)
- A `Product` in Sales differs from `InventoryItem` in Warehouse
- Share only: IDs, Value Objects, and very stable abstractions (Shared Kernel)

**Code Quality in Modules:**
- Prefer pure functions for domain logic (no side effects)
- Pass immutable data between modules
- No global state or singletons

**The Deletion Test**: If you can delete a feature folder and cleanly remove that capability with no orphaned code, your architecture is modular.

⚠️ **Modularity is ENFORCED at session end (`/session:end`)** - circular dependencies, layer-based structure, and boundary violations will BLOCK closeout.

### Rule 8: Beads Task Management
**Distributed Task Tracking for Multi-Agent Development**

Beads (bd) provides collision-free task coordination for multi-agent sessions. All task tracking uses beads instead of GitLab issues.

**Key Commands:**
```bash
# View tasks ready for work (no blockers)
bd ready --json

# Create task from user story
bd create "US-001: Implement login" --type story --priority 2

# Claim task for worker
bd update bd-xxxx --status in_progress --assignee "worker-1"

# Complete task
bd close bd-xxxx --reason "Implementation complete"

# Sync changes to git (required after parallel work)
bd sync
```

**Session Workflow Integration:**
- `/session:init` → Runs `bd init` if `.beads/` doesn't exist
- `/session:plan` → Creates beads issues from task graph
- `/session:parallel` → Workers use `bd ready` to claim tasks, `bd sync` on completion
- `/session:end` → Runs `bd doctor` for orphan detection

**Dependency Types:**
- `blocks` → Task cannot start until dependency completes
- `parent-child` → Hierarchical (epic → story → subtask)
- `related` → Informational link (doesn't block)

**Parallel Worker Protocol:**
```bash
# Workers run in worktrees with daemon disabled
export BEADS_NO_DAEMON=1

# Claim task
bd update $TASK_ID --status in_progress

# Work...

# Complete and sync
bd close $TASK_ID --reason "Done"
bd sync
```

**Task Hierarchy:**
- `bd-epic` → Feature/Epic level
- `bd-epic.1` → User Story level
- `bd-epic.1.1` → Subtask level

**Traceability:**
- Link to PRD via: `bd update bd-xxxx --external-ref "FR-001"`
- All task history tracked in git via `.beads/issues.jsonl`

---

## 2. CURRENT STATUS (Authoritative Source)

**Sprint:** S{SPRINT_NUMBER} "{SPRINT_NAME}" (Day {DAY}/{TOTAL_DAYS}, {PROGRESS}% complete)
**Ref:** sprints/sprint_{NN}/sprint_plan.md L1-{LINES}

**Active User Story:** US-{ID} "{STORY_TITLE}" ({STORY_POINTS} pts)
**Ref:** sprints/sprint_{NN}/sprint_plan.md L{START}-L{END}
**Status:** {STATUS} ({PERCENTAGE}% complete)

**Last Completed Work:**
- {TIMESTAMP}: {TASK_DESCRIPTION}
- File: {FILE_PATH} L{START}-L{END}
- Tests: {PASSING}/{TOTAL} passing ({PERCENTAGE}%)
- Coverage: {PERCENTAGE}%

**Current Work:**
- Task: {CURRENT_TASK}
- File: {FILE_PATH} L{START}-L{END} (in progress)
- Estimated completion: {TIME}

**Next Immediate Steps:**
1. {STEP_1}
2. {STEP_2}
3. {STEP_3}

**Blockers:**
- {BLOCKER_1} (severity: CRITICAL/MEDIUM/LOW, waiting on: {WHO/WHAT})
- {BLOCKER_2}

**Test Status:**
- Overall: {PASSING}/{TOTAL} tests ({PERCENTAGE}% pass rate)
- Coverage: {COVERAGE}% (threshold: 80%)
- Last run: {TIMESTAMP}
- Command: pytest --cov=src / npm test

**Quality Gates:**
- ✅/❌ Test pass rate 100%: {STATUS}
- ✅/❌ Code coverage ≥80%: {STATUS}
- ✅/❌ All planned tasks complete: {STATUS}

---

## 3. HIGH-LEVEL ROADMAP (Project Compass)

**Overall Progress:** Phase {CURRENT}/{TOTAL} ({PERCENTAGE}% complete)

### Phase 1: Foundation ✅ (100% complete)
**Duration:** {WEEKS} weeks | {START_DATE} - {END_DATE}

- ✅ Epic 1.1: User Authentication (2 sprints: S1-S2)
  - Ref: sprints/sprint_01/sprint_plan.md, sprints/sprint_02/sprint_plan.md
- ✅ Epic 1.2: Database Setup (1 sprint: S3)
  - Ref: sprints/sprint_03/sprint_plan.md

### Phase 2: Core Features ⏳ ({PERCENTAGE}% complete)
**Duration:** {WEEKS} weeks | {START_DATE} - {END_DATE}

- ✅ Epic 2.1: Payment Processing (3 sprints: S4-S6)
  - S4: Stripe integration ✅
  - S5: Refund processing ✅
  - S6: Payment analytics ⏳ (current, 45% complete)
    - Ref: sprints/sprint_06/sprint_plan.md
- 📅 Epic 2.2: Product Catalog (4 sprints: S7-S10)
- 📅 Epic 2.3: Shopping Cart (2 sprints: S11-S12)

### Phase 3: Advanced Features 📅
**Duration:** {WEEKS} weeks | {START_DATE} - {END_DATE}

- 📅 Epic 3.1: Order Management (3 sprints: S13-S15)
- 📅 Epic 3.2: User Profiles (2 sprints: S16-S17)

### Phase 4: Launch Prep 📅
**Duration:** {WEEKS} weeks | {START_DATE} - {END_DATE}

- 📅 Epic 4.1: Performance & Security (2 sprints: S18-S19)
- 📅 Epic 4.2: Production Readiness (1 sprint: S20)

**Legend:** ✅ Complete | ⏳ In Progress | 📅 Planned | ⏸️ On Hold | ❌ Cancelled

**Full Roadmap:** docs/ROADMAP.md (updated every sprint completion)

---

## 4. KEY ENVIRONMENT DETAILS (Essential Commands)

**Tech Stack:** {SUMMARY_FROM_TECH_STACK_MD}
**Full Details:** TECH_STACK.md ({LINES} lines)

**Package Managers:**
- Python: {POETRY/PIP/PIPENV} → `{INSTALL_COMMAND}`
- JavaScript: {NPM/YARN/PNPM} → `{INSTALL_COMMAND}`

**Container Management:**
```bash
# Start all services
docker-compose up -d

# Stop all services
docker-compose down

# View logs
docker-compose logs -f {SERVICE_NAME}

# Restart service
docker-compose restart {SERVICE_NAME}
```

**Testing Commands:**
```bash
# Python tests with coverage
pytest --cov=src --cov-fail-under=80 --cov-report=html

# JavaScript tests with coverage
npm test -- --coverage

# Run specific test file
pytest tests/payment/test_webhooks.py
npm test tests/checkout.test.ts

# Run tests matching pattern
pytest -k "webhook"
npm test -- --testNamePattern="checkout"
```

**Database Commands:**
```bash
# Create migration
{MIGRATION_CREATE_COMMAND}

# Apply migrations
{MIGRATION_APPLY_COMMAND}

# Rollback migration
{MIGRATION_ROLLBACK_COMMAND}

# Connect to DB
{DB_CONNECT_COMMAND}
```

**Development Servers:**
```bash
# Backend (port: {PORT})
{BACKEND_START_COMMAND}

# Frontend (port: {PORT})
{FRONTEND_START_COMMAND}
```

---

## 5. KEY FILES REFERENCE (Quick Navigation)

**Project Documentation:**
- PRD: {PRD_PATH} ({LINES} lines) | Index: state/indexes/prd_index.md
- SRS: {SRS_PATH} ({LINES} lines) | Index: state/indexes/srs_index.md
- UI Plan: {UI_PATH} ({LINES} lines) | Index: state/indexes/ui_index.md
- Tech Stack: TECH_STACK.md ({LINES} lines)
- Roadmap: docs/ROADMAP.md ({LINES} lines)

**Session Management:**
- Current State: state/current_state.md (updated every 5 min)
- Next Session Plan: state/next_session_plan.md (updated at session end)

**Sprint Plans:**
- Current Sprint: sprints/sprint_{NN}/sprint_plan.md
- Sprint Research: sprints/sprint_{NN}/research.md
- Implementation Plan: sprints/sprint_{NN}/implementation_plan.md
- Sprint Validation: sprints/sprint_{NN}/validation.md
- All Sprints: sprints/ folder

**Decisions & Reports:**
- Architecture Decisions: DECISIONS/ folder (ADRs)
- Test Coverage Reports: REPORTS/coverage_*.{json,html}
- Performance Reports: REPORTS/performance_*.json

**How to Load Specific Content:**
```markdown
# Example: Load authentication requirements from PRD
Read {PRD_PATH} from line 211 to line 340

# Example: Load current sprint plan
Read sprints/sprint_06/sprint_plan.md from line 1 to line 280

# Example: Load specific API spec from SRS
Read {SRS_PATH} from line 651 to line 800
```

---

## 6. QUALITY GATES (Enforced Thresholds)

### Test Coverage: 80% Minimum (ENFORCED)
**Command:** pytest --cov=src --cov-fail-under=80 (Python)
**Command:** npm test -- --coverage (JavaScript)

**Reports:**
- Python: htmlcov/index.html
- JavaScript: coverage/lcov-report/index.html
- Archived: REPORTS/coverage_{DATE}.json

**Enforcement:**
- ✅ Pre-commit hook: .husky/pre-commit (blocks <80%)
- ✅ CI/CD: .github/workflows/test.yml L{LINE} (fails build <80%)
- ✅ Sprint gate: Cannot mark sprint complete <80%

### Test Pass Rate: 100% Required (ENFORCED)
**Command:** pytest --maxfail=1 (Python)
**Command:** npm test -- --bail (JavaScript)

**Enforcement:**
- ✅ Pre-push hook: .husky/pre-push (blocks any failures)
- ✅ CI/CD: Fails build on any test failure
- ✅ Sprint gate: Cannot mark sprint complete with failing tests

### Code Quality (Optional but Recommended)
**Linting:** ruff (Python), ESLint (JavaScript)
**Formatting:** black (Python), Prettier (JavaScript)
**Type Checking:** mypy (Python), TypeScript (JavaScript)

**Commands:**
```bash
# Python
poetry run ruff check src/
poetry run black --check src/
poetry run mypy src/

# JavaScript
npm run lint
npm run format:check
npm run type-check
```

---

## 7. ABBREVIATIONS & SYMBOLS

**Standard Acronyms:**
- US = User Story
- AC = Acceptance Criteria
- NFR = Non-Functional Requirement
- TDD = Test-Driven Development
- CI/CD = Continuous Integration/Deployment
- SRS = Software Requirements Specification
- PRD = Product Requirements Document
- API = Application Programming Interface
- DB = Database
- CRUD = Create, Read, Update, Delete

**Status Symbols:**
- ✅ = Complete / Passing
- ⏳ = In Progress
- 📅 = Planned / Not Started
- ☐ = Todo / Unchecked
- ⚠️ = Warning / Attention Needed
- 🔴 = Critical / Blocker
- 🟡 = Medium Priority
- 🟢 = Low Priority
- ⏸️ = On Hold / Paused
- ❌ = Cancelled / Failed

**File References:**
- L{N} = Line number {N}
- L{N}-L{M} = Line range from {N} to {M}
- → = See also / Reference
- ← = Referenced by / Depends on

---

## 8. MODULE BOUNDARIES (Bounded Contexts)

Track module ownership, public APIs, and dependencies to enforce modular architecture.

| Module | Owner (Actor) | Public API | Dependencies | Stability (I) |
|--------|--------------|------------|--------------|---------------|
| {module_name} | {team/stakeholder} | {exported_functions} | {list_dependencies} | {0.0-1.0} |

**Example:**
| Module | Owner (Actor) | Public API | Dependencies | Stability (I) |
|--------|--------------|------------|--------------|---------------|
| auth | Security Team | login(), logout(), verify_token() | shared_kernel | 0.1 (Stable) |
| billing | Finance | create_invoice(), process_payment() | auth, shared_kernel | 0.3 (Stable) |
| products | Catalog Team | list_products(), get_product() | shared_kernel | 0.4 (Medium) |
| ui_components | Frontend | <Button>, <Modal>, <Form> | None | 0.8 (Unstable) |

**Dependency Rules:**
- Dependencies flow from unstable → stable (high I → low I)
- NO circular dependencies allowed (enforced at /session:end)
- Shared Kernel is immutable, requires full system re-test for changes
- New modules must be added to this table before implementation

**Instability Formula:** I = FanOut / (FanIn + FanOut)
- FanOut = modules this module depends on
- FanIn = modules that depend on this module
- I = 0: Maximally stable (everyone depends on it)
- I = 1: Maximally unstable (depends on everything)

---

**END OF CLAUDE.md**
**Current Line Count:** {LINE_COUNT}/500 lines
**Context Budget Used:** {PERCENTAGE}%

⚠️ **IMPORTANT:** If this file exceeds 500 lines, move detailed content to separate files and reference them here.
```

Save this to: `CLAUDE.md` in project root

## Step 4B: Populate CLAUDE.md with Project-Specific Data

Replace all template placeholders with actual project data:

**Replacements needed:**
- `{CURRENT_DATE}` → Current date (YYYY-MM-DD format)
- `{LINE_COUNT}` → Actual line count of generated CLAUDE.md
- `{PERCENTAGE}` → (LINE_COUNT / 500) * 100
- `{SPRINT_NUMBER}`, `{SPRINT_NAME}` → From most recent sprint or "Not Started"
- `{PRD_PATH}`, `{SRS_PATH}`, `{UI_PATH}` → Actual file paths from Phase 2
- `{LINES}` → Actual line counts
- `{SUMMARY_FROM_TECH_STACK_MD}` → One-line summary from TECH_STACK.md
- All package manager/command placeholders from detected tech stack

**For new projects (no sprints yet):**
- Current Status: "Sprint 0: Project initialization complete, Sprint 1 planned"
- Active User Story: "None (awaiting Sprint 1 start)"
- Roadmap: Show all as 📅 Planned

**Output:**
```markdown
## CLAUDE.md Generation Complete ✅

**File created:** CLAUDE.md (385 lines, 77% of 500 line budget)
**Sections populated:**
- ✅ MUST DO Rules (7 rules documented, including modular architecture)
- ✅ Current Status (Sprint 1 Day 0 - ready to start)
- ✅ Roadmap (4 phases, 8 epics, 20 sprints planned)
- ✅ Environment Details (Python 3.11 + FastAPI, Next.js 14)
- ✅ Key Files Reference (7 document references)
- ✅ Quality Gates (80% coverage, 100% pass rate enforced)
- ✅ Abbreviations (25 terms defined)
- ✅ Module Boundaries (bounded contexts, stability tracking)

**Context Impact:** 385 lines (~16 KB) - within target (<500 lines, <20 KB)

Next: Session management initialization...
```

---

# PHASE 5: SESSION MANAGEMENT INITIALIZATION

## Step 5A: Create state/current_state.md

For new projects, create a blank placeholder file with template structure as comment.

```markdown
# SESSION STATE (Auto-Updated Every 5 Minutes)
Last Updated: {TIMESTAMP}
Session ID: {SESSION_ID}
Duration: {HH}h {MM}m

_This file will be populated during development sessions._
_It tracks: active sprint, current user story, last completed task, test status, blockers._
_Update frequency: Every 5 minutes during active development._

---

## Template Structure (For Reference)

### Active Sprint
Sprint: S{N} "{NAME}"
Timeline: {START_DATE} - {END_DATE} (Day {D}/{TOTAL}, {PERCENT}% complete)
Velocity: {COMPLETED} points / {PLANNED} points ({PERCENT}%)

### Current User Story
US-{ID}: {TITLE}
Status: IN_PROGRESS ({PERCENT}% complete)
Started: {TIMESTAMP}
Estimated Completion: {TIMESTAMP}

Acceptance Criteria Status:
✅ {COMPLETED_AC}
⏳ {IN_PROGRESS_AC} (IN PROGRESS)
☐ {PENDING_AC}

### Last Completed Task ({TIMESTAMP})
Task: {DESCRIPTION}
Files Modified:
- {FILE_PATH} (L{START}-L{END}, +{ADDED}/-{REMOVED} lines)

Git Status:
- Branch: {BRANCH_NAME}
- Commits: {N} commits ahead of main
- Last Commit: "{MESSAGE}"
- Uncommitted Changes: {N} files

### Open Questions & Blockers
{BLOCKER_1} [CRITICAL/MEDIUM/LOW]
- Question: {QUESTION}
- Blocking: {WHAT_IS_BLOCKED}
- Decision needed by: {WHEN}
- Stakeholder: {WHO}

### Test Coverage Status
Overall: {PERCENT}% (threshold=80%) ✅/⚠️
{MODULE}: {PERCENT}% (threshold=80%) ✅/⚠️

Recent Test Results:
- Total Tests: {N}
- Passing: {N} ({PERCENT}%)
- Failing: {N}
- Duration: {SECONDS}s

### Working Memory (Last 30 Minutes)
{TIMESTAMP} - {ACTIVITY_DESCRIPTION}
{TIMESTAMP} - ✅ {COMPLETED_TASK}
{TIMESTAMP} - {ACTIVITY_DESCRIPTION}

### Next Immediate Steps
1. NEXT: {STEP_1}
2. THEN: {STEP_2}
3. FINALLY: {STEP_3}

### Environment Snapshot
- Branch: {BRANCH}
- Python Venv: {PATH}
- Node Version: v{VERSION}
- Docker Containers: {CONTAINER_1} (running), {CONTAINER_2} (running)
- DB Migrations: Up to date (latest: {MIGRATION})
```

Save this to: `state/current_state.md`

## Step 5B: Create state/next_session_plan.md

Generate lightweight plan for next session. Content depends on project state:

**For new projects (no sprints exist yet):**

```markdown
# NEXT SESSION PLAN (Sprint 0 → Sprint 1)
Generated: {CURRENT_DATE_TIME}
For Session: First development session (estimated)

## Session Resumption Checklist
☐ 1. Review CLAUDE.md (master file with all rules)
☐ 2. Review PRD index (state/indexes/prd_index.md)
☐ 3. Review SRS index (state/indexes/srs_index.md)
☐ 4. Verify environment setup (Docker, dependencies)
☐ 5. Check if sprint plans exist (sprints/ folder)

## Where We Left Off
Project: Just initialized
Status: Sprint 0 complete (project structure created)
Next: Sprint 1 planning and execution

## Immediate Next Steps (First Session)

### Step 1: Create Sprint 1 Plan (2 hours)
If Sprint 1 doesn't exist yet:
1. Review PRD requirements (identify P0 features)
2. Research Sprint 1 scope (typical: authentication, database setup)
3. Create `sprints/sprint_01/research.md`
4. Create `sprints/sprint_01/sprint_plan.md`
5. Break down into 8-12 user stories
6. Estimate story points (30-50 total)

### Step 2: Sprint 1 Research & Planning (2 hours)
Read and analyze:
- PRD sections relevant to Sprint 1
  - Example: Read {PRD_PATH} L{START}-L{END} (Authentication requirements)
- SRS technical specifications
  - Example: Read {SRS_PATH} L{START}-L{END} (Auth API specs)

Research:
- Authentication approach (OAuth2 vs JWT vs both)
- Database setup (migrations, ORM configuration)
- Testing strategy (fixtures, mocks, coverage targets)
- Expert agents needed (backend-systems-architect, etc.)

Document findings in: `sprints/sprint_01/research.md`

### Step 3: Implementation Planning (1 hour)
Create `sprints/sprint_01/implementation_plan.md`:
- Break user stories into file-level tasks
- Assign expert agents to specific tasks
- Plan test coverage strategy
- Estimate time per task

### Step 4: Begin Sprint 1 Execution (remaining time)
Start with first user story (likely US-001: User registration)
- Follow TDD: Write test first, then implementation
- Update `state/current_state.md` every 5 minutes
- Document decisions in DECISIONS/ folder

Total Estimated Time: 5-6 hours for planning + first story

## Sprint Context (Reference)
First Sprint: sprints/sprint_01/sprint_plan.md (to be created)
Typical Sprint 1 Goals:
- User authentication (registration, login, logout)
- Database setup (migrations, models, connections)
- Testing infrastructure (fixtures, factories, coverage)

## Dependencies & Prerequisites
Before Starting:
- ✅ Docker services running (docker-compose up -d)
- ✅ Python environment activated (poetry shell or source .venv/bin/activate)
- ✅ Node dependencies installed (npm install)
- ✅ Database accessible (psql connection test)
- ✅ Environment variables set (.env.local from .env.example)

External Dependencies:
- None (Sprint 1 typically has no external blockers)

## Recovery Plan (If Context Lost)
1. Read CLAUDE.md (master file, {LINES} lines)
2. Read state/indexes/prd_index.md (PRD navigation)
3. Check git status: `git status`
4. Check running services: `docker ps`
5. Read this file (state/next_session_plan.md)
```

**For existing projects (sprints exist):**

```markdown
# NEXT SESSION PLAN
Generated: {CURRENT_DATE_TIME}
For Session: {NEXT_SESSION_DATE} (estimated)

## Session Resumption Checklist
☐ 1. Review state/current_state.md (last updated: {TIMESTAMP})
☐ 2. Check for PRD/SRS changes since last session
☐ 3. Verify test suite passing: pytest --cov=src
☐ 4. Review open blockers ({N} items pending)
☐ 5. Pull latest from main: git pull origin main

## Where We Left Off
Sprint: S{N} "{SPRINT_NAME}" (Day {D}/{TOTAL}, {PERCENT}% complete)
Active Story: US-{ID} "{TITLE}" ({PERCENT}% complete)
Last File Edited: {FILE_PATH} L{START}-L{END}
Last Commit: "{MESSAGE}"

Critical Blocker: {BLOCKER_DESCRIPTION}
  - Needs decision before proceeding
  - Stakeholder: {WHO}
  - If unblocked: Resume at Step 1 below

## Immediate Next Steps (Next Session)

### Step 1: Resolve Blocker (30 min)
- Review blocker decision (check Slack/email/user)
- If decision made: Implement solution
- If still blocked: Escalate to user again

### Step 2: Complete Active User Story (90 min)
Continue work on US-{ID}:
- {TASK_1_DESCRIPTION}
  - File: {FILE_PATH}
  - Tests: {TEST_FILE_PATH}
- {TASK_2_DESCRIPTION}
  - File: {FILE_PATH}
  - Tests: {TEST_FILE_PATH}

Acceptance Criteria to Complete:
☐ {PENDING_AC_1}
☐ {PENDING_AC_2}

### Step 3: Fix Failing Tests (30 min)
- {TEST_FILE}::{TEST_NAME} (reason: {FAILURE_REASON})
- {TEST_FILE}::{TEST_NAME} (reason: {FAILURE_REASON})
- Target: 100% test pass rate

### Step 4: Manual Testing (45 min)
Test scenarios:
- {SCENARIO_1}
- {SCENARIO_2}
- {SCENARIO_3}

### Step 5: Code Review & Merge (30 min)
- Push to {BRANCH_NAME}
- Create PR: "{PR_TITLE}"
- Request review from @{REVIEWER}
- Merge to main after approval

Total Estimated Time: {HOURS} hours

## Sprint Context (Reference)
Current Sprint: sprints/sprint_{NN}/sprint_plan.md L1-{LINES}
Remaining Stories in S{N}: {COUNT} stories (US-{IDS})
Next Story After US-{ID}: US-{NEXT_ID} "{NEXT_TITLE}"

Full Sprint Plan: sprints/sprint_{NN}/sprint_plan.md
Sprint Research: sprints/sprint_{NN}/research.md
Implementation Plan: sprints/sprint_{NN}/implementation_plan.md

## Dependencies & Prerequisites
Before Starting Next Session:
- ✅ Docker services running
- ✅ Database migrations up to date ({LATEST_MIGRATION})
- ⏳ Blocker resolution from {STAKEHOLDER} (pending)
- ✅ Test environment configured

External Dependencies:
- {SERVICE_1} API (status: {STATUS})
- {SERVICE_2} Integration (status: {STATUS})

## Risk Assessment
🟢 Low Risk:
- {LOW_RISK_ITEM}

🟡 Medium Risk:
- {MEDIUM_RISK_ITEM}

🔴 High Risk:
- {HIGH_RISK_ITEM}

## Checkpoints & Milestones
Checkpoint 1: {DESCRIPTION}
Checkpoint 2: {DESCRIPTION}
Milestone: {DESCRIPTION} → S{N} {PERCENT}% complete

## Recovery Plan (If Context Lost)
1. Read CLAUDE.md (master file, {LINES} lines)
2. Read state/current_state.md (session snapshot)
3. Read sprints/sprint_{NN}/sprint_plan.md L{START}-L{END} (US-{ID} details)
4. Check git log: `git log --oneline -10`
5. Check git status: `git status`
6. Run tests: `pytest --cov=src` / `npm test`

## Session Exit Checklist (For End of This Session)
☐ Update state/current_state.md with latest progress
☐ Commit all changes with meaningful message
☐ Update state/next_session_plan.md for following session
☐ Update sprint velocity in sprints/sprint_{NN}/sprint_plan.md
☐ Document any new decisions in DECISIONS/
☐ Push branch to remote (backup)
```

Save this to: `state/next_session_plan.md`

## Step 5C: Verify Session Management Setup

After creating session management files, verify:

```bash
# Check files exist
ls -la state/
# Should show: indexes/, current_state.md, next_session_plan.md

# Check file sizes
du -h state/*
# Target: current_state.md ~1 KB (template), next_session_plan.md ~5-8 KB

# Verify files are readable
head -n 20 state/current_state.md
head -n 50 state/next_session_plan.md
```

**Output Summary:**

```markdown
## Session Management Initialization Complete ✅

Files created:
- ✅ state/current_state.md (blank with template, ~1 KB)
- ✅ state/next_session_plan.md (Sprint 1 plan, ~6 KB)

Session management ready:
- Current state tracking: Every 5 minutes during development
- Next session recovery: Detailed plan with recovery commands
- Context loss resilience: Self-contained files for seamless recovery

Next: Final verification and summary...
```

---

# EXECUTION SUMMARY

When you invoke this `/init` command, you will:

1. **Initialize git repository and create directory structure** ⚠️ CRITICAL:
   - Initialize git repository (if not already initialized)
   - Create .gitignore file with common patterns
   - Make initial commit with project structure
   - Create state/ (session management)
   - Create state/indexes/ (document indexes)
   - Create sprints/ (if doesn't exist)
   - Create DECISIONS/, REPORTS/ (if don't exist)

2. **Discover and index documents**:
   - Auto-search for PRD, SRS, UI Plan files
   - Ask user if not found automatically
   - Generate comprehensive indexes with line numbers and summaries
   - Save indexes to state/indexes/ folder

3. **Auto-detect technology stack**:
   - Scan project files (pyproject.toml, package.json, docker-compose.yml, etc.)
   - Extract languages, frameworks, databases, testing tools
   - Generate TECH_STACK.md with development commands
   - Confirm detected technologies with user

4. **Generate CLAUDE.md master file**:
   - 7 MUST DO rules of engineering (TDD, PRD authority, session protocols, modular architecture)
   - Current status (sprint, story, blockers, next steps)
   - High-level roadmap (phases, epics, sprints)
   - Environment details (commands, ports, services)
   - Key files reference (indexes, sprint plans, decisions)
   - Quality gates (80% coverage, 100% pass rate)
   - Abbreviations and symbols
   - Target: <500 lines (~16-20 KB)

5. **Initialize session management**:
   - state/current_state.md (blank template for new projects)
   - state/next_session_plan.md (Sprint 1 plan for new, or current for existing)
   - Recovery commands and checklists

## Output Files

After running `/init`, you will have:

```
📁 Project Root
├─ .git/ (initialized, CRITICAL for sprint reporting) ⚠️
├─ .gitignore (created, Python/JS/IDE patterns)
├─ CLAUDE.md (created, 350-450 lines, <20 KB)
├─ TECH_STACK.md (created, 150-200 lines, ~8 KB)
│
📁 state/
├─ current_state.md (created, initially template/blank, ~1 KB)
├─ next_session_plan.md (created, 150-250 lines, ~6-8 KB)
│
📁 state/indexes/
├─ prd_index.md (created if PRD found, 100-300 lines, ~5-15 KB)
├─ srs_index.md (created if SRS found, 100-200 lines, ~4-10 KB)
└─ ui_index.md (created if UI plan found, 80-150 lines, ~3-8 KB)

📁 sprints/
└─ (verified exists, created if missing)

📁 DECISIONS/
└─ (created if missing)

📁 REPORTS/
└─ (created if missing)

Git Repository:
├─ Initial commit: "chore: initialize project structure from /init command"
└─ Branch: main (or master)
```

## Success Criteria

✅ **Git repository initialized** (.git/ directory exists, initial commit made) ⚠️ CRITICAL
✅ **.gitignore file created** with Python/JS/IDE/environment patterns
✅ Directory structure created (state/, state/indexes/, sprints/, DECISIONS/, REPORTS/)
✅ Document indexes generated with H1/H2/H3 headers + line numbers + summaries
✅ TECH_STACK.md created with auto-detected technologies
✅ CLAUDE.md created with all 7 sections (<500 lines)
✅ Session management files initialized (current_state.md, next_session_plan.md)
✅ Total context impact <50 KB across all generated files
✅ All files use reference-based approach (no content duplication)
✅ User can immediately start development with clear session protocol
✅ Sprint summary reporting foundation in place (git commit history)

## Total Context Impact

**Generated Files:**
- CLAUDE.md: ~350-450 lines (~15-20 KB)
- TECH_STACK.md: ~150-200 lines (~6-10 KB)
- state/current_state.md: ~50 lines (~1 KB, template)
- state/next_session_plan.md: ~150-250 lines (~6-10 KB)
- Document indexes (3 files): ~300-600 lines (~15-30 KB)

**Total:** ~1,000-1,500 lines (~40-70 KB)

**Comparison to reading full documents:**
- PRD + SRS + UI Plan: ~5,650 lines (~250 KB)
- **Context savings: ~75-85% reduction**

**Loading CLAUDE.md only:** ~350-450 lines (~15-20 KB) gives complete project overview

---

**END OF /init SLASH COMMAND**
**Ready to initialize projects for AI-assisted development with strict TDD enforcement!**
