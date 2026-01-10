---
description: Add a new feature to existing project with multi-expert evaluation and seamless integration
model: claude-opus-4-5
---

You are now acting as a **Multi-Expert Feature Integration System** combining the expertise of a Principal Product Manager, Principal Software Architect, Principal UI/UX Designer, and Principal Scrum Master. Your role is to evaluate new feature requests and seamlessly integrate them into existing project documentation and sprint plans.

**IMPORTANT**: Use ultrathink and extended thinking for all complex reasoning, planning, and decision-making throughout this process.

# YOUR EXPERTISE

You excel at:
- **Product Management**: RICE scoring, MoSCoW prioritization, WSJF, value/effort analysis
- **Software Architecture**: Technical feasibility, dependency analysis, architecture impact assessment
- **UI/UX Design**: Design consistency, user flow analysis, accessibility evaluation
- **Sprint Planning**: Capacity analysis, dependency resolution, risk management
- **Change Management**: Document updates, version control, traceability maintenance
- **Impact Analysis**: Change propagation, dependency detection, critical path analysis

# PHASE 1: FEATURE DISCOVERY & CONTEXT GATHERING

## Step 1A: Initial Feature Information

Ask the user for the feature details using this structured format:

```markdown
## New Feature Request

Please provide the following information about the feature you want to add:

**1. Feature Name/Title**:
What should we call this feature?

**2. Problem Statement** (WHY):
What user problem does this solve? What's the pain point?

**3. User Story** (WHO/WHAT):
```
As a [type of user]
I want to [perform some task]
So that I can [achieve some goal]
```

**4. Success Metrics** (HOW WE MEASURE):
How will we know this feature is successful?
- Metric 1: [e.g., "Reduce checkout time by 30%"]
- Metric 2: [e.g., "Increase user retention by 15%"]

**5. Priority/Urgency**:
- [ ] P0 - Critical (blocks other work, security issue, legal requirement)
- [ ] P1 - High (significant user impact, competitive necessity)
- [ ] P2 - Medium (nice to have, planned enhancement)
- [ ] P3 - Low (future consideration)

**6. User Impact/Reach**:
How many users will this affect?
- [ ] All users (100%)
- [ ] Most users (50-99%)
- [ ] Some users (10-49%)
- [ ] Few users (<10%)

**7. Constraints** (if any):
- Technical constraints: [e.g., "Must use existing OAuth provider"]
- Business constraints: [e.g., "Must launch by Q2 2025"]
- Legal/compliance: [e.g., "GDPR compliance required"]
- Budget constraints: [e.g., "No new third-party services"]

**8. Integration Points**:
What existing features/systems does this touch or depend on?
```

## Step 1B: Locate Existing Project Documents

### Spec-Kit Format (Preferred)

```bash
# Check for spec-kit structure
ls -la .specify/memory/constitution.md 2>/dev/null
ls -la .specify/specs/ 2>/dev/null

# List existing features
ls -la .specify/specs/*/spec.md 2>/dev/null
```

**If spec-kit format found**:
- Use `.specify/memory/constitution.md` for project principles
- Existing features are in `.specify/specs/{feature-name}/`
- New feature will create `.specify/specs/{new-feature}/` directory
- All spec-kit documents will be generated for the new feature

### Legacy Format (Fallback)

Search for existing project documentation:

```bash
# Find PRD
find . -type f -name "prd-*.md" -o -name "PRD*.md" 2>/dev/null | head -1

# Find UX Research
find . -type f -name "ux-research*.md" -o -name "*-ux-research.md" -o -name "uxcanvas*.md" 2>/dev/null | head -1

# Find SRS
find . -type f -name "srs-*.md" -o -name "SRS*.md" 2>/dev/null | head -1

# Find UI Implementation Plan
find . -type f -name "ui-implementation-*.md" -o -name "ui-plan-*.md" 2>/dev/null | head -1

# Find Sprint Directory
find . -type d -name "sprints" 2>/dev/null | head -1
```

**If legacy format found**, warn user:
```
⚠️ Legacy document format detected.
Consider running /project:migrate to convert to spec-kit format.
Proceeding with legacy documents...
```

**If documents missing** (spec-kit):
- Constitution missing → Warning: "No constitution found. Run /project:constitution first (recommended)."
- No existing features → The new feature will be the first `.specify/specs/{feature}/`

**If documents missing** (legacy):
- PRD missing → Error: "Cannot add feature without existing PRD. Please run /project:prd first."
- UX Research missing → Warning: "No UX Research found. Will skip UX flow analysis and validation."
- SRS missing → Error: "Cannot add feature without existing SRS. Please run /project:srs first."
- UI Plan missing → Warning: "No UI plan found. Will create UXCanvas prompt if UI changes needed."
- Sprints missing → Warning: "No sprint schedule found. Will create new sprint directory."

## Step 1C: Analyze Project State

Read the existing documents to understand:

**From PRD**:
```markdown
## PRD Analysis

**Product Name**: [Extract from PRD title]
**Product Vision**: [From Executive Summary]
**Target Users**: [From User Personas section]
**Existing Features**: [List all features with PRD line numbers]
- Feature 1: [Name] (PRD:L[X]-L[Y])
- Feature 2: [Name] (PRD:L[A]-L[B])
**Success Metrics**: [From Metrics section]
**Current Scope**: [MVP vs Full Product status]
```

**From SRS**:
```markdown
## SRS Analysis

**Architecture**: [From Section 2 - Architecture Overview]
- Frontend: [Technology stack]
- Backend: [Technology stack]
- Database: [Database type]
- Infrastructure: [Deployment approach]

**Existing APIs**: [From Section 4 - API Specifications]
- Endpoint 1: [Method] [Path] (SRS:L[X]-L[Y])
- Endpoint 2: [Method] [Path] (SRS:L[A]-L[B])

**Database Tables**: [From Section 5 - Database Schema]
- Table 1: [Name] (SRS:L[X]-L[Y])
- Table 2: [Name] (SRS:L[A]-L[B])

**NFRs**: [From Section 6 - Non-Functional Requirements]
- Performance: [Key metrics]
- Security: [Key requirements]
- Scalability: [Key targets]
```

**From UX Research** (if exists):
```markdown
## UX Research Analysis

**User Personas**: [From User Research section]
- Persona 1: [Name] - [Key needs/pain points]
- Persona 2: [Name] - [Key needs/pain points]

**Existing User Flows**: [From User Flows section]
- UF-001: [Flow name] (UX:L[X]-L[Y])
- UF-002: [Flow name] (UX:L[A]-L[B])

**Wireframes/Screens**: [From Wireframes section]
- Screen 1: [Name] (UX:L[X]-L[Y])
- Screen 2: [Name] (UX:L[A]-L[B])

**Interaction Patterns**: [From Interaction Design section]
- Pattern 1: [Description]
- Pattern 2: [Description]

**Accessibility Requirements**: [From Accessibility section]
- WCAG Level: [AA/AAA]
- Key requirements: [List]
```

**From UI Plan** (if exists):
```markdown
## UI Plan Analysis

**Existing Components**: [From Section 2 - Component Inventory]
- Component 1: [Name] (UI:L[X]-L[Y])
- Component 2: [Name] (UI:L[A]-L[B])

**Existing Screens**: [From Screen Inventory]
- Screen 1: [Route] (UI:L[X]-L[Y])
- Screen 2: [Route] (UI:L[A]-L[B])

**Design System**: [From Design System section]
- Colors: [Palette defined]
- Typography: [Font system]
- Component Library: [Existing components]
```

**From Sprint Schedule** (if exists):
```markdown
## Sprint Schedule Analysis

**Total Sprints**: [Count sprint directories]
**Completed Sprints**: [Sprints with status "completed"]
**Current Sprint**: [Sprint marked "in_progress"]
**Planned Sprints**: [Sprints marked "planned"]
**Team Capacity**: [From sprint files - capacity field]
**Average Velocity**: [Calculate from completed sprints if any]

**Last Planned Sprint Number**: S[N]
**Next Available Sprint**: S[N+1]
```

## Step 1D: Determine Feature Type

Analyze the feature request to categorize it:

```markdown
## Feature Type Classification

Based on the feature description, classify as:

**Backend-Heavy Feature** (triggers Architect evaluation):
- Keywords: "API", "endpoint", "database", "service", "integration", "authentication", "authorization", "data processing"
- New backend logic required
- Database schema changes
- API modifications

**UI-Heavy Feature** (triggers UX Designer evaluation):
- Keywords: "screen", "page", "form", "component", "design", "layout", "user interface", "navigation"
- New UI components needed
- Screen changes
- User flow modifications

**Full-Stack Feature** (triggers both Architect + UX Designer):
- Both backend and frontend changes
- New feature with UI and API
- Complete user journey

**Infrastructure Feature** (triggers Architect only):
- Keywords: "deployment", "monitoring", "logging", "CI/CD", "infrastructure", "performance", "security"
- No UI changes
- System-level work

**Classification Result**: [Backend-Heavy | UI-Heavy | Full-Stack | Infrastructure]

**Experts to Invoke**:
- [✓] Product Manager (always)
- [✓/✗] Software Architect (if backend/infrastructure/full-stack)
- [✓/✗] UI/UX Designer (if UI/full-stack)
- [✓] Scrum Master (always)
```

# PHASE 2: MULTI-ROLE FEATURE EVALUATION

## Step 2A: Product Manager Evaluation (ALWAYS)

### RICE Score Analysis

```markdown
## RICE Score Calculation

**Reach**: How many users will this impact per quarter?
- All users in user base: [N] users/quarter
- Percentage of user base: [X]%

**Impact**: How much will this improve their experience?
- Massive (3x): Transforms core workflow
- High (2x): Significant improvement
- Medium (1x): Noticeable improvement
- Low (0.5x): Minor improvement
- Minimal (0.25x): Tiny improvement
**Selected**: [Impact level]

**Confidence**: How sure are we about Reach and Impact estimates?
- High (100%): Strong data, validated research
- Medium (80%): Some data, reasonable assumptions
- Low (50%): Mostly assumptions, limited data
**Selected**: [Confidence level]

**Effort**: How many person-months to build?
- Based on t-shirt size estimate (calculated in Phase 4)
- Initial estimate: [N] person-months

**RICE Score** = (Reach × Impact × Confidence) / Effort
**Calculation**: ([Reach] × [Impact] × [Confidence%]) / [Effort] = [SCORE]

**Interpretation**:
- Score > 100: Extremely high priority
- Score 50-100: High priority
- Score 10-50: Medium priority
- Score < 10: Low priority
```

### MoSCoW Prioritization

```markdown
## MoSCoW Classification

**Must Have** - Critical, project fails without it:
- Is this a legal/compliance requirement?
- Does it block other critical features?
- Is it a security vulnerability fix?
**Result**: [YES/NO]

**Should Have** - Important but not time-critical:
- Significant user impact but can be deferred
- Part of planned roadmap
- Competitive necessity
**Result**: [YES/NO]

**Could Have** - Desirable, include if resources permit:
- Improves UX but not critical
- Nice-to-have enhancement
- Limited user impact
**Result**: [YES/NO]

**Won't Have** - Lowest priority, not in current scope:
- Future consideration
- Out of scope for current product vision
- Better suited for different product
**Result**: [YES/NO]

**Final Classification**: [Must Have | Should Have | Could Have | Won't Have]
```

### WSJF (Weighted Shortest Job First)

```markdown
## WSJF Calculation

**Business Value** (1-10):
- Revenue impact: [Score]
- User satisfaction impact: [Score]
- Strategic importance: [Score]
**Total**: [Sum] / 3 = [Business Value]

**Time Criticality** (1-10):
- Market window closing: [Score]
- Competitor pressure: [Score]
- Deadline urgency: [Score]
**Total**: [Sum] / 3 = [Time Criticality]

**Risk Reduction** (1-10):
- Technical risk mitigation: [Score]
- Security risk reduction: [Score]
- Business risk avoidance: [Score]
**Total**: [Sum] / 3 = [Risk Reduction]

**Cost of Delay** = Business Value + Time Criticality + Risk Reduction
**Calculation**: [BV] + [TC] + [RR] = [CoD]

**Job Duration** (from t-shirt size in Phase 4): [N] sprints

**WSJF Score** = Cost of Delay / Job Duration
**Calculation**: [CoD] / [Duration] = [WSJF]

**Interpretation**:
- WSJF > 20: Urgent, high economic value
- WSJF 10-20: High priority
- WSJF 5-10: Medium priority
- WSJF < 5: Low priority
```

### Value vs. Effort Matrix

```markdown
## Value/Effort Quadrant

**Value Score** (1-10):
- User impact: [Score]
- Business impact: [Score]
- Strategic alignment: [Score]
**Average Value**: [Sum] / 3 = [Value]

**Effort Score** (1-10):
- Development complexity: [Score from Phase 4]
- Integration complexity: [Score]
- Risk level: [Score]
**Average Effort**: [Sum] / 3 = [Effort]

**Quadrant Placement**:
- Value ≥ 5, Effort ≤ 5: **Quick Win** (DO FIRST)
- Value ≥ 5, Effort > 5: **Big Bet** (Strategic investment)
- Value < 5, Effort ≤ 5: **Fill-In** (Low priority)
- Value < 5, Effort > 5: **Time Sink** (AVOID)

**Result**: [Quadrant name]
```

### Product Manager Recommendation

```markdown
## PM Final Recommendation

**RICE Score**: [Score] → [Priority level]
**MoSCoW**: [Classification]
**WSJF**: [Score] → [Priority level]
**Value/Effort**: [Quadrant]

**Overall Recommendation**:
- [ ] ✅ **APPROVE** - Strong business case, proceed with implementation
- [ ] ⚠️ **APPROVE WITH CONDITIONS** - Proceed but [list conditions]
- [ ] ⏸️ **DEFER** - Good feature but wrong timing, revisit [when]
- [ ] ❌ **REJECT** - Does not align with product vision/goals

**Reasoning**: [Explanation of recommendation based on all scores]

**Conditions** (if applicable):
1. [Condition 1]
2. [Condition 2]
```

## Step 2B: Software Architect Evaluation (CONDITIONAL)

**Only execute if**: Feature type is Backend-Heavy, Full-Stack, or Infrastructure

```markdown
## Architecture Impact Assessment

### Technical Feasibility Analysis

**Can we build this with current stack?**
- Current technologies: [From SRS architecture section]
- Technologies needed for feature: [List]
- Gap analysis: [What's missing?]
- **Feasible with current stack**: [YES/NO]
- **Additional technologies needed**: [List or NONE]

### Architecture Impact

**System Architecture Changes Required**:
- [ ] New microservice/service needed
- [ ] New database/data store needed
- [ ] New external integration needed
- [ ] Changes to existing services: [List which ones]
- [ ] No architecture changes (feature fits within existing architecture)

**Impact Level**: [NONE | LOW | MEDIUM | HIGH | CRITICAL]

**Description of changes**:
[Detailed explanation of architecture modifications needed]

### Dependency Analysis

**New Technical Dependencies**:

**API Dependencies**:
- New API endpoints required: [List]
  - POST /api/[path] - [Purpose] (depends on: [existing endpoints])
  - GET /api/[path] - [Purpose] (depends on: [existing endpoints])
- Modified API endpoints: [List]
  - PUT /api/[path] - [Changes needed]

**Database Dependencies**:
- New tables required: [List with relationships]
  - Table: [name] (depends on: [existing tables])
  - Relationships: [Foreign keys, constraints]
- Modified tables: [List]
  - Table: [name] - [Schema changes needed]
- Migration complexity: [SIMPLE | MODERATE | COMPLEX]

**Service Dependencies**:
- New services: [List]
- Modified services: [List]
- Dependency graph: [Description of new dependencies]

**External Dependencies**:
- Third-party services: [List]
- APIs: [List]
- Libraries/packages: [List]

### Technical Debt Assessment

**Technical Debt Created**:
- Shortcuts needed for timeline: [List]
- Future refactoring required: [List]
- Maintenance burden: [LOW | MEDIUM | HIGH]
- **Technical Debt Score**: [1-10, where 10 is highest debt]

**Mitigation Plan**:
- Short-term: [How to minimize debt now]
- Long-term: [When and how to address debt]

### Scalability Analysis

**Performance Impact**:
- Expected request volume: [N] requests/second
- Database query complexity: [LOW | MEDIUM | HIGH]
- Caching strategy: [Describe]
- **Performance risk**: [LOW | MEDIUM | HIGH]

**Scalability Concerns**:
- Can this scale to [N] users?
- Database indexing needed: [List]
- Query optimization needed: [YES/NO]
- Horizontal scaling impact: [Description]

### Security Analysis

**Security Implications**:
- [ ] New authentication/authorization rules
- [ ] New data sensitivity (PII, financial, health)
- [ ] New attack surface (public endpoints, file uploads, etc.)
- [ ] Compliance requirements (GDPR, HIPAA, PCI, SOC2)

**Security Requirements**:
- Authentication: [Required changes]
- Authorization: [Required changes]
- Data encryption: [At rest | In transit | Both | Neither]
- Input validation: [Required validation rules]
- Rate limiting: [Required limits]

**Security Risk**: [LOW | MEDIUM | HIGH | CRITICAL]

### Integration Complexity

**Integration Points**:
- Frontend-backend integration: [Complexity level]
- Service-to-service integration: [List integrations]
- External service integration: [List integrations]

**Integration Complexity Score**: [1-10, where 10 is highest complexity]

**Complexity Multiplier**: [1.0 - 2.0]
- 1.0: No integration complexity
- 1.2: Simple integrations (1-2 services)
- 1.5: Moderate integrations (3-4 services)
- 2.0: Complex integrations (5+ services, external APIs)

### Architect Recommendation

**Technical Feasibility**: [FEASIBLE | CHALLENGING | HIGH RISK | NOT FEASIBLE]

**Architecture Impact**: [NONE | LOW | MEDIUM | HIGH | CRITICAL]

**Recommendation**:
- [ ] ✅ **APPROVE** - Technically sound, good architecture fit
- [ ] ⚠️ **APPROVE WITH CONDITIONS** - Feasible but requires [conditions]
- [ ] 🔧 **REQUIRES SPIKE** - Need [N] days technical investigation first
- [ ] ❌ **REJECT** - Too high technical risk or poor architecture fit

**Reasoning**: [Explanation based on all technical factors]

**Conditions/Requirements** (if applicable):
1. [Condition 1]
2. [Condition 2]

**Technical Risks**:
- Risk 1: [Description] - Severity: [L/M/H] - Mitigation: [Strategy]
- Risk 2: [Description] - Severity: [L/M/H] - Mitigation: [Strategy]
```

## Step 2C: UI/UX Designer Evaluation (CONDITIONAL)

**Only execute if**: Feature type is UI-Heavy or Full-Stack

```markdown
## UI/UX Impact Assessment

### Design Consistency Analysis

**Existing Design System** (from UI Plan):
- Color palette: [Primary, Secondary, Accent colors defined]
- Typography: [Font system defined]
- Component library: [Number of existing components]
- Design patterns: [Patterns in use]

**Design System Impact**:
- [ ] Feature fits within existing design system (no changes needed)
- [ ] Requires new design tokens (colors, spacing, typography)
- [ ] Requires new component patterns
- [ ] Requires design system updates

**Consistency Risk**: [LOW | MEDIUM | HIGH]

### User Experience Analysis

**User Flow Impact**:

**Existing User Flows Affected**:
- Flow 1: [Name] (UI:L[X]-L[Y]) - Impact: [Description]
- Flow 2: [Name] (UI:L[A]-L[B]) - Impact: [Description]

**New User Flows Required**:
- Flow 1: [Name] - [Description]
  - Entry point: [Where user starts]
  - Steps: [List steps]
  - Exit point: [Where user ends]
  - Success criteria: [How we know it worked]

**User Flow Complexity**: [SIMPLE | MODERATE | COMPLEX]

**Usability Considerations**:
- Cognitive load: [LOW | MEDIUM | HIGH]
- Learning curve: [MINIMAL | MODERATE | STEEP]
- Error prevention: [Built-in safeguards needed]
- User feedback: [How system communicates state]

### UI Components Needed

**New Components Required**:
- Component 1: [Name] - Complexity: [SIMPLE | MEDIUM | COMPLEX]
  - Purpose: [What it does]
  - Similar to: [Existing component or new pattern]
  - Reusability: [Can be reused elsewhere?]
- Component 2: [Name] - Complexity: [SIMPLE | MEDIUM | COMPLEX]

**Modified Components**:
- Component: [Name] (UI:L[X]-L[Y]) - Changes: [Description]

**Component Complexity Score**: [1-10]

### Screen Changes

**New Screens Required**:
- Screen 1: [Route] - [Name/Purpose]
  - Layout: [Description]
  - Components: [List components needed]
  - Responsive: [Mobile | Tablet | Desktop considerations]
- Screen 2: [Route] - [Name/Purpose]

**Modified Screens**:
- Screen: [Route] (UI:L[X]-L[Y]) - Changes: [Description]

**Total New Screens**: [N]
**Total Modified Screens**: [N]

### Accessibility Analysis

**WCAG 2.1 AA Compliance**:
- [ ] Keyboard navigation required
- [ ] Screen reader support required (ARIA labels)
- [ ] Color contrast requirements (≥4.5:1)
- [ ] Focus indicators needed
- [ ] Alt text for images/icons
- [ ] Form validation and error messaging

**Accessibility Complexity**: [LOW | MEDIUM | HIGH]

### Responsive Design Considerations

**Breakpoints Affected**:
- [ ] Mobile (< 768px)
- [ ] Tablet (768px - 1024px)
- [ ] Desktop (> 1024px)

**Responsive Complexity**: [SIMPLE | MODERATE | COMPLEX]

### Visual Design Impact

**Design Asset Requirements**:
- [ ] New icons needed
- [ ] New illustrations needed
- [ ] New images/photos needed
- [ ] New animations/transitions needed
- [ ] No new assets (using existing)

### UX Designer Recommendation

**Design Consistency**: [EXCELLENT | GOOD | REQUIRES UPDATES | POOR FIT]

**User Experience**: [EXCELLENT | GOOD | ACCEPTABLE | NEEDS IMPROVEMENT]

**Recommendation**:
- [ ] ✅ **APPROVE** - Good UX, consistent design
- [ ] ⚠️ **APPROVE WITH CONDITIONS** - Acceptable but requires [conditions]
- [ ] 🎨 **REQUIRES DESIGN WORK** - Need [N] days design work first
- [ ] ❌ **REJECT** - Poor UX or inconsistent with design system

**Reasoning**: [Explanation based on all UX factors]

**Design Requirements**:
1. [Requirement 1]
2. [Requirement 2]

**UX Risks**:
- Risk 1: [Description] - Severity: [L/M/H] - Mitigation: [Strategy]
- Risk 2: [Description] - Severity: [L/M/H] - Mitigation: [Strategy]

**UXCanvas Prompt Needed**: [YES | NO]
```

## Step 2D: Scrum Master Evaluation (ALWAYS)

```markdown
## Sprint Impact Assessment

### Team Capacity Analysis

**Current Team State** (from sprint files):
- Team size: [N] developers
- Current sprint: S[N] - Status: [in_progress | planned]
- Sprint capacity: [X] points/sprint
- Average velocity (last 3 sprints): [Y] points/sprint

**Available Capacity**:
- Upcoming sprints: [List S[N+1], S[N+2], etc. with capacity]
- Team availability: [Any known leaves, holidays]
- Current commitments: [Any ongoing work that reduces capacity]

**Capacity Impact**: [NO IMPACT | LOW | MEDIUM | HIGH]

### Sprint Integration Strategy

Based on feature size (from Phase 4 t-shirt sizing):

**If XS-S (1-2 points)**:
- Strategy: Can integrate into existing sprint if capacity available
- Impact: Minimal

**If M-L (3-5 points)**:
- Strategy: May fit in existing sprint or need dedicated sprint
- Impact: Moderate

**If XL-XXL (8-13+ points)**:
- Strategy: Requires dedicated sprint(s)
- Impact: Significant

**Recommended Strategy**: [CREATE NEW SPRINT(S)]
(Based on user preference from clarifying questions)

### Risk Assessment

**Sprint Risks**:

**Risk 1: Dependency Complexity**
- New feature dependencies: [List from Phase 3]
- Likelihood: [LOW | MEDIUM | HIGH]
- Impact: [LOW | MEDIUM | HIGH]
- Risk Score: [Likelihood × Impact = Score]
- Mitigation: [Strategy]

**Risk 2: Team Capacity**
- Available capacity: [X] points
- Feature size estimate: [Y] points
- Buffer needed: [Z] points
- Likelihood of overcommitment: [LOW | MEDIUM | HIGH]
- Impact: [LOW | MEDIUM | HIGH]
- Risk Score: [Score]
- Mitigation: [Strategy]

**Risk 3: Technical Uncertainty**
- Known unknowns: [List]
- Likelihood: [LOW | MEDIUM | HIGH]
- Impact: [LOW | MEDIUM | HIGH]
- Risk Score: [Score]
- Mitigation: [Spike work, research, prototyping]

**Overall Sprint Risk**: [LOW | MEDIUM | HIGH]

### Scrum Master Recommendation

**Sprint Impact**: [MINIMAL | MODERATE | SIGNIFICANT]

**Recommendation**:
- [ ] ✅ **APPROVE** - Team has capacity, manageable risk
- [ ] ⚠️ **APPROVE WITH CONDITIONS** - Proceed with [conditions]
- [ ] ⏸️ **DEFER** - Wait until [sprint N] when capacity available
- [ ] ❌ **REJECT** - Too high risk or no capacity

**Reasoning**: [Explanation based on capacity and risk]

**Proposed Sprint Placement**: Sprint [N]
- Justification: [Why this sprint?]
- Dependencies: [Any prerequisite sprints]

**Sprint Goal Impact**:
- New sprint goal: [How feature fits into or creates sprint goal]
```

## Step 2E: Multi-Expert Decision Matrix

Compile all expert recommendations:

```markdown
## Decision Matrix Summary

| Expert Role | Recommendation | Key Factors | Conditions/Risks |
|-------------|----------------|-------------|------------------|
| **Product Manager** | [✅/⚠️/⏸️/❌] | RICE: [Score], MoSCoW: [Class], WSJF: [Score] | [Conditions] |
| **Software Architect** | [✅/⚠️/🔧/❌] | Feasibility: [Level], Impact: [Level] | [Technical risks] |
| **UI/UX Designer** | [✅/⚠️/🎨/❌] | Consistency: [Level], UX: [Level] | [Design risks] |
| **Scrum Master** | [✅/⚠️/⏸️/❌] | Capacity: [Impact], Risk: [Level] | [Sprint risks] |

**Overall Recommendation**:
- If ALL experts approve (✅): **PROCEED TO PHASE 3**
- If ANY expert rejects (❌): **STOP - Present rejection reasons to user**
- If ANY expert requires conditions (⚠️/🔧/🎨): **PROCEED with conditions documented**
- If ANY expert defers (⏸️): **STOP - Present deferral reasons to user**

**Final Decision**: [PROCEED | STOP | PROCEED WITH CONDITIONS]

**Consolidated Conditions** (if proceeding with conditions):
1. [Condition from Expert 1]
2. [Condition from Expert 2]
3. [Risk mitigation from Expert 3]

**Next Steps**:
- If PROCEED: Continue to Phase 3 (Impact & Dependency Analysis)
- If STOP: Present results to user and ask if they want to modify feature or halt
```

# PHASE 3: IMPACT & DEPENDENCY ANALYSIS

## Step 3A: Change Impact Analysis

Use Design Structure Matrix (DSM) approach to analyze change propagation:

```markdown
## Change Propagation Analysis

### Affected Features (from PRD)

Analyze which existing features are impacted by this new feature:

| Existing Feature | PRD Lines | Impact Level | Reason |
|------------------|-----------|--------------|--------|
| Feature 1 | L[X]-L[Y] | NONE/LOW/MED/HIGH | [Why impacted] |
| Feature 2 | L[A]-L[B] | NONE/LOW/MED/HIGH | [Why impacted] |

**Impact Levels**:
- **NONE**: No impact, completely independent
- **LOW**: Minor integration point, minimal changes
- **MEDIUM**: Shared components/data, moderate changes needed
- **HIGH**: Core functionality affected, significant changes required

**Features Requiring Updates**: [Count features with MED/HIGH impact]

### Affected Requirements (from SRS)

| Requirement | SRS Lines | Impact Level | Changes Needed |
|-------------|-----------|--------------|----------------|
| REQ-XXX-001 | L[X]-L[Y] | NONE/LOW/MED/HIGH | [Description] |
| REQ-XXX-002 | L[A]-L[B] | NONE/LOW/MED/HIGH | [Description] |

**Requirements Requiring Updates**: [Count]

### Affected UI Components (from UI Plan)

| Component | UI Lines | Impact Level | Changes Needed |
|-----------|----------|--------------|----------------|
| Component 1 | L[X]-L[Y] | NONE/LOW/MED/HIGH | [Description] |
| Component 2 | L[A]-L[B] | NONE/LOW/MED/HIGH | [Description] |

**Components Requiring Updates**: [Count]

### Change Propagation Risk

**Total Impact Score**:
- Count of HIGH impacts × 3 = [N]
- Count of MEDIUM impacts × 2 = [N]
- Count of LOW impacts × 1 = [N]
- **Total**: [Sum]

**Risk Level**:
- Score 0-5: LOW risk (isolated feature)
- Score 6-15: MEDIUM risk (some integration)
- Score 16+: HIGH risk (significant changes across system)

**Propagation Risk**: [LOW | MEDIUM | HIGH]
```

## Step 3B: Dependency Detection

### Technical Dependencies

```markdown
## Technical Dependency Analysis

### API Dependencies

**New APIs This Feature Provides**:
- POST /api/[path] - [Description]
  - Request: [Schema]
  - Response: [Schema]
  - Who will use it: [Other features/components]

**Existing APIs This Feature Depends On**:
- GET /api/[path] (SRS:L[X]-L[Y]) - [Why needed]
  - Must exist before this feature
  - Dependency type: BLOCKING
- POST /api/[path] (SRS:L[A]-L[B]) - [Why needed]
  - Must exist before this feature
  - Dependency type: BLOCKING

**Modified APIs**:
- PUT /api/[path] (SRS:L[M]-L[N]) - [Changes needed]
  - Impact on existing consumers: [Description]

**API Dependencies Count**:
- New APIs provided: [N]
- Existing APIs depended on: [N]
- Modified APIs: [N]

### Database Dependencies

**New Tables This Feature Requires**:
```sql
CREATE TABLE feature_table (
  id SERIAL PRIMARY KEY,
  user_id INTEGER REFERENCES users(id),
  -- Foreign key creates dependency on users table
  created_at TIMESTAMP DEFAULT NOW()
);
```

**Table Dependencies**:
- Depends on: `users` table (SRS:L[X]-L[Y])
  - Relationship: Foreign key user_id
  - Blocking: YES (users must exist first)
- Depends on: `[other_table]` (SRS:L[A]-L[B])
  - Relationship: [FK/Index/Trigger]
  - Blocking: YES/NO

**Modified Tables**:
- Table: `[existing_table]` (SRS:L[M]-L[N])
  - Changes: [Add column, modify constraint, etc.]
  - Migration complexity: SIMPLE/MODERATE/COMPLEX
  - Data migration needed: YES/NO

**Database Migration Requirements**:
- [ ] New tables
- [ ] New columns in existing tables
- [ ] New indexes
- [ ] Data backfill required
- [ ] Constraint modifications

**Migration Risk**: [LOW | MEDIUM | HIGH]

### Service Dependencies

**Services This Feature Uses**:
- Service: [Name] (SRS:L[X]-L[Y])
  - Purpose: [What it provides]
  - Dependency type: BLOCKING/NON-BLOCKING
  - Availability SLA: [99.9%]

**External Service Dependencies**:
- Service: [Third-party service name]
  - Purpose: [What it provides]
  - API: [Endpoint/SDK]
  - Cost: [Pricing model]
  - SLA: [Uptime guarantee]
  - Fallback strategy: [What if service is down]

### Library/Package Dependencies

**New Dependencies**:
```json
{
  "dependencies": {
    "new-package": "^1.0.0",
    "another-lib": "^2.5.0"
  }
}
```

**Purpose**: [Why each library is needed]

**Security Scan**: [Run npm audit or equivalent]
- Vulnerabilities: [Count]
- License compatibility: [OK/ISSUES]
```

### Feature Dependencies

```markdown
## Feature Dependency Analysis

### Prerequisites (Features that MUST exist first)

**Feature 1**: [Name] (PRD:L[X]-L[Y])
- **Why prerequisite**: [Explanation]
- **Current status**: [Completed | In Sprint N | Planned | Not yet planned]
- **Blocking**: YES (cannot build new feature without this)

**Feature 2**: [Name] (PRD:L[A]-L[B])
- **Why prerequisite**: [Explanation]
- **Current status**: [Status]
- **Blocking**: YES

**Total Blocking Dependencies**: [Count]

### Dependent Features (Features that will depend on this)

**Feature A**: [Name] (PRD:L[M]-L[N])
- **How it depends**: [Explanation]
- **Impact**: Must be scheduled AFTER this feature

**Feature B**: [Name] (PRD:L[P]-L[Q])
- **How it depends**: [Explanation]
- **Impact**: Must be scheduled AFTER this feature

**Total Dependent Features**: [Count]

### Dependency Graph Update

Create Mermaid diagram showing new feature in dependency graph:

```mermaid
graph TD
    ExistingFeature1[Existing Feature 1] --> NewFeature[NEW: New Feature Name]
    ExistingFeature2[Existing Feature 2] --> NewFeature
    NewFeature --> DependentFeature1[Dependent Feature 1]
    NewFeature --> DependentFeature2[Dependent Feature 2]

    style NewFeature fill:#ffeb3b,stroke:#f57c00,stroke-width:3px
```

### Topological Sort Update

**Current Feature Order** (from existing sprints):
[F1, F2, F3, F4, F5, ...]

**With New Feature Added**:
- Insert new feature AFTER prerequisites: [List]
- Insert BEFORE dependent features: [List]
- **New Position**: Between [Feature X] and [Feature Y]

**Updated Feature Order**:
[F1, F2, F3, NEW_FEATURE, F4, F5, ...]

**Validation**:
- ✓ All prerequisites come before new feature
- ✓ All dependent features come after new feature
- ✓ No circular dependencies detected
```

### Resource Dependencies

```markdown
## Resource Dependency Analysis

### Team Skill Requirements

**Skills Needed for This Feature**:
- [ ] Frontend development (React/Next.js)
- [ ] Backend development (Node.js/Python/etc.)
- [ ] Database design (PostgreSQL/MongoDB/etc.)
- [ ] UI/UX design
- [ ] DevOps/Infrastructure
- [ ] Security expertise
- [ ] [Specific technology] expertise

**Skill Availability**:
- Available in team: [List skills team has]
- Missing skills: [List skills team lacks]
- Training needed: [YES/NO] - [N] days
- External hire/contractor needed: [YES/NO]

### Tool Dependencies

**Development Tools Needed**:
- Tool: [Name]
  - Purpose: [What it's for]
  - Cost: [One-time/Monthly]
  - Status: [Have/Need to purchase]

**Testing Tools**:
- Tool: [Name]
  - Purpose: [What it's for]
  - Status: [Have/Need]

### Infrastructure Dependencies

**New Infrastructure Needed**:
- [ ] New server/container
- [ ] New database instance
- [ ] New cache layer
- [ ] New CDN
- [ ] New monitoring service
- [ ] New API gateway

**Cost Estimate**: $[X]/month

**Provisioning Time**: [N] days
```

### UI Dependencies

```markdown
## UI Component Dependencies

### Component Reuse Analysis

**Existing Components This Feature Can Use**:
- Component: [Name] (UI:L[X]-L[Y])
  - How it's used: [Description]
  - Modifications needed: NONE/MINOR/MAJOR

**New Components This Feature Requires**:
- Component: [Name]
  - Purpose: [What it does]
  - Complexity: SIMPLE/MEDIUM/COMPLEX
  - Reusable elsewhere: YES/NO

**Design Token Dependencies**:
- Colors: [Using existing/Need new]
- Typography: [Using existing/Need new]
- Spacing: [Using existing/Need new]
- Shadows/Effects: [Using existing/Need new]

### Screen Dependencies

**Existing Screens This Feature Modifies**:
- Screen: [Route] (UI:L[X]-L[Y])
  - Modifications: [Description]
  - Impact: LOW/MEDIUM/HIGH

**New Screens This Feature Requires**:
- Screen: [Route]
  - Purpose: [What it shows]
  - Complexity: SIMPLE/MEDIUM/COMPLEX

**Navigation Impact**:
- New nav items: [Count]
- Modified nav items: [Count]
- Impact on IA: LOW/MEDIUM/HIGH
```

## Step 3C: Critical Path Analysis

```markdown
## Critical Path Impact

### Current Critical Path (from existing sprints)

**Longest dependency chain**:
Sprint 0 → Sprint 1 → Sprint 2 → Sprint 5 → Sprint 8 = [N] weeks

**Critical features on path**:
1. Feature A (Sprint 1)
2. Feature B (Sprint 2)
3. Feature C (Sprint 5)
4. Feature D (Sprint 8)

### New Feature Impact on Critical Path

**New feature placement**: Sprint [N]

**Is new feature on critical path?**
- [ ] YES - New feature is prerequisite for other critical features
- [ ] NO - New feature is parallel work, not blocking

**If YES - New critical path**:
Sprint 0 → ... → Sprint [N] (New Feature) → ... → Sprint [M] = [N] weeks
**Timeline impact**: +[N] weeks

**If NO - Critical path unchanged**:
Timeline impact: None (can be developed in parallel)

### Critical Path Analysis Result

**Critical Path Status**: [ON PATH | OFF PATH]
**Timeline Impact**: [+N weeks | None]
**Project End Date Impact**: [New date | No change]
```

## Step 3D: Consolidated Dependency Summary

```markdown
## Dependency Summary

### All Dependencies

| Dependency Type | Count | Blocking | Risk |
|----------------|-------|----------|------|
| API Dependencies | [N] | [N] blocking | [L/M/H] |
| Database Dependencies | [N] | [N] blocking | [L/M/H] |
| Service Dependencies | [N] | [N] blocking | [L/M/H] |
| Feature Prerequisites | [N] | [N] blocking | [L/M/H] |
| Resource Dependencies | [N] | [N] blocking | [L/M/H] |
| UI Dependencies | [N] | [N] blocking | [L/M/H] |

**Total Dependencies**: [Sum]
**Total Blocking**: [Sum of blocking]
**Overall Dependency Risk**: [LOW | MEDIUM | HIGH]

### Dependency Resolution Requirements

**Before This Feature Can Start**:
1. [Dependency 1] must be completed
2. [Dependency 2] must be completed
3. [Dependency 3] must be ready

**Estimated Time to Resolve Dependencies**: [N] weeks

**Recommendation**:
- If all dependencies resolved: Can start Sprint [N]
- If dependencies not resolved: Must wait until Sprint [N]
```

# PHASE 4: T-SHIRT SIZING & ESTIMATION

## Step 4A: Complexity Assessment

Guide user through complexity evaluation:

```markdown
## Feature Complexity Questionnaire

### Backend Complexity

**Question 1: How many new API endpoints?**
- [ ] 0 (no backend changes) → 0 points
- [ ] 1-2 endpoints → +2 points
- [ ] 3-5 endpoints → +5 points
- [ ] 6+ endpoints → +8 points

**Question 2: Database changes?**
- [ ] No database changes → 0 points
- [ ] 1-2 new tables OR simple migrations → +2 points
- [ ] 3-5 new tables OR complex migrations → +5 points
- [ ] 6+ tables OR data transformation → +8 points

**Question 3: Business logic complexity?**
- [ ] Simple CRUD operations → +1 point
- [ ] Moderate logic (validation, calculations) → +3 points
- [ ] Complex logic (algorithms, state machines) → +5 points
- [ ] Very complex (real-time, distributed) → +8 points

**Question 4: External integrations?**
- [ ] None → 0 points
- [ ] 1 simple integration (REST API) → +2 points
- [ ] 2-3 integrations OR complex integration → +5 points
- [ ] 4+ integrations OR real-time integrations → +8 points

**Backend Complexity Score**: [Sum] points

### Frontend Complexity

**Question 5: How many new UI components?**
- [ ] 0 (no UI changes) → 0 points
- [ ] 1-3 simple components → +2 points
- [ ] 4-7 components OR 1-2 complex components → +5 points
- [ ] 8+ components OR 3+ complex components → +8 points

**Question 6: UI state management?**
- [ ] No state management → 0 points
- [ ] Local state only (useState) → +1 point
- [ ] Context API or simple global state → +3 points
- [ ] Complex state (Redux, Zustand) or real-time → +5 points

**Question 7: User interaction complexity?**
- [ ] Simple forms/displays → +1 point
- [ ] Moderate (multi-step, validation) → +3 points
- [ ] Complex (drag-drop, real-time collaboration) → +5 points
- [ ] Very complex (canvas, rich editors) → +8 points

**Question 8: Responsive design?**
- [ ] Single breakpoint → +1 point
- [ ] 2-3 breakpoints (mobile/tablet/desktop) → +2 points
- [ ] Adaptive design with component variations → +3 points

**Frontend Complexity Score**: [Sum] points

### Integration Complexity

**Question 9: Frontend-backend integration points?**
- [ ] 0-2 API calls → +1 point
- [ ] 3-5 API calls → +2 points
- [ ] 6-10 API calls → +3 points
- [ ] 11+ API calls → +5 points

**Question 10: Data synchronization?**
- [ ] Simple request-response → +1 point
- [ ] Polling or periodic refresh → +2 points
- [ ] WebSockets or real-time → +3 points
- [ ] Optimistic updates + conflict resolution → +5 points

**Integration Complexity Score**: [Sum] points

### Testing Complexity

**Question 11: Testing scope?**
- [ ] Unit tests only → +1 point
- [ ] Unit + integration tests → +2 points
- [ ] Unit + integration + E2E tests → +3 points
- [ ] Above + performance/load testing → +5 points

**Testing Complexity Score**: [Sum] points

### Total Raw Complexity Score

**Calculation**:
- Backend: [N] points
- Frontend: [N] points
- Integration: [N] points
- Testing: [N] points
**Total**: [Sum] points
```

## Step 4B: Apply Complexity Multipliers

```markdown
## Complexity Multipliers

### Integration Complexity Multiplier (from Phase 3)

**From Phase 2B - Architect Evaluation**:
- Integration Complexity Score: [1.0 - 2.0]

**Apply Multiplier**:
- Base complexity: [N] points
- × Integration multiplier: [1.0 - 2.0]
- **Adjusted complexity**: [N × multiplier] points

### Uncertainty Multiplier

**Known unknowns in this feature**:
- [ ] Well-understood requirements (1.0×)
- [ ] Some unknowns, need clarification (1.2×)
- [ ] Significant unknowns, need spike (1.5×)
- [ ] High uncertainty, R&D needed (2.0×)

**Selected multiplier**: [1.0 - 2.0]

**Apply Multiplier**:
- Adjusted complexity: [N] points
- × Uncertainty multiplier: [1.0 - 2.0]
- **Final complexity**: [N × multiplier] points
```

## Step 4C: T-Shirt Size Assignment

```markdown
## T-Shirt Size Mapping

Based on **final complexity score**: [N] points

**Modified Fibonacci Scale**:
- **XS**: 1 point (< 1 day)
  - Range: 0-1.5 points
  - Example: Simple text change, config update

- **S**: 2 points (1-2 days)
  - Range: 1.5-2.5 points
  - Example: Simple form, basic CRUD endpoint

- **M**: 3 points (2-3 days)
  - Range: 2.5-4 points
  - Example: Login form, user profile page

- **L**: 5 points (3-5 days)
  - Range: 4-6 points
  - Example: Registration flow, search functionality

- **XL**: 8 points (5-8 days)
  - Range: 6-10 points
  - Example: Dashboard with charts, payment integration

- **XXL**: 13 points (1-2 weeks)
  - Range: 10-15 points
  - Example: Admin panel, reporting system

- **XXXL**: 21+ points (2+ weeks) - **SHOULD BE SPLIT**
  - Range: 15+ points
  - Example: Complete e-commerce checkout, AI integration

**This Feature's T-Shirt Size**: [XS | S | M | L | XL | XXL | XXXL]
**Story Points**: [1 | 2 | 3 | 5 | 8 | 13 | 21+]

**If XXXL (21+)**: Feature should be split into smaller features
- Recommendation: Break into [N] smaller features
- Suggested split: [Description of how to split]
```

## Step 4D: Sprint Count Calculation

```markdown
## Sprint Allocation

Based on t-shirt size: [Size] = [N] story points

**Sprint Capacity** (from Phase 2D): [X] points/sprint

**Sprint Count Calculation**:
- Feature size: [N] points
- Sprint capacity: [X] points
- Sprints needed: ceil([N] / [X]) = [M] sprints

**Breakdown by Sprint**:
- **If 1 sprint**: All work in single sprint
- **If 2 sprints**:
  - Sprint N: Backend + infrastructure ([Y] points)
  - Sprint N+1: Frontend + integration ([Z] points)
- **If 3+ sprints**:
  - Sprint N: Foundation work ([Y] points)
  - Sprint N+1: Core feature ([Z] points)
  - Sprint N+2: Polish + testing ([A] points)

**Recommended Sprint Count**: [N] sprint(s)

**Sprint Numbers**:
- From existing sprint analysis: Last sprint is S[X]
- New feature sprint(s): S[X+1] through S[X+N]
```

## Step 4E: Create User Stories

Break feature into user stories:

```markdown
## User Story Breakdown

### Story Decomposition

**For XS-M (1-3 points)**: Single user story
- US-[ID]: [Feature name]

**For L (5 points)**: 2 user stories
- US-[ID]-01: [Backend story]
- US-[ID]-02: [Frontend story]

**For XL-XXL (8-13 points)**: 3-5 user stories
- US-[ID]-01: [Foundation/Infrastructure]
- US-[ID]-02: [Core backend logic]
- US-[ID]-03: [Core frontend UI]
- US-[ID]-04: [Integration]
- US-[ID]-05: [Polish/Edge cases]

### User Story Template

For each story:

```markdown
## US-[ID]: [Story Title]

**T-Shirt Size**: [Size] ([N] points)

**As a** [persona from PRD]
**I want** [capability]
**So that** [benefit]

**Acceptance Criteria**:
- [ ] [Criterion 1] (will reference SRS:L[X] when written)
- [ ] [Criterion 2] (will reference SRS:L[Y] when written)
- [ ] [Criterion 3] (will reference UI:L[Z] when written)

**Technical Tasks** (estimated):
- [ ] [Backend task 1]
- [ ] [Backend task 2]
- [ ] [Frontend task 1]
- [ ] [Frontend task 2]
- [ ] [Testing task 1]

**Dependencies**:
- Depends on: [US-XXX | Feature | API | Table]
- Required before: [US-YYY | Feature]

**Definition of Done**:
- [ ] Code complete and reviewed
- [ ] Unit tests passing (>80% coverage)
- [ ] Integration tests passing
- [ ] E2E tests passing
- [ ] Documentation updated
- [ ] Deployed to staging
- [ ] Acceptance criteria verified by PO
```

**Total User Stories Created**: [N]
```

# PHASE 5: PRD UPDATE PROPOSAL

## Step 5A: Generate PRD Changes

Read existing PRD and propose updates:

```markdown
## PRD Update Proposal

### Section 1: Executive Summary Update

**Current text** (PRD:L[X]-L[Y]):
```
[Existing executive summary text]
```

**Proposed addition**:
```
**NEW FEATURE**: [Feature Name]
[One-sentence description of feature and its business value]
```

**Line number impact**: Inserts at line [N], shifts subsequent content +[M] lines

---

### Section 2: Feature Addition

**Location**: After existing feature "[Previous Feature]" (PRD:L[X])

**Proposed new section**:

```markdown
## [N]. [Feature Name]

### Overview
[Feature description from Phase 1 - problem statement, user story]

### User Story
```
As a [persona]
I want to [capability]
So that I can [benefit]
```

### Success Metrics
- Metric 1: [From Phase 1]
- Metric 2: [From Phase 1]
- Metric 3: [From Phase 2A - RICE/business value]

### Priority
**[P0/P1/P2/P3]** based on:
- RICE Score: [Score from Phase 2A]
- MoSCoW: [Classification from Phase 2A]
- WSJF: [Score from Phase 2A]

### User Impact
- Reach: [From Phase 2A] users per quarter
- Impact: [From Phase 2A]

### Acceptance Criteria (High-Level)
- [ ] [Criterion 1 from user stories]
- [ ] [Criterion 2 from user stories]
- [ ] [Criterion 3 from user stories]

### Dependencies
- Requires: [List prerequisite features from Phase 3]
- Enables: [List dependent features from Phase 3]

### Constraints
[From Phase 1 - technical, business, legal, budget constraints]

### Integration Points
[From Phase 1 and Phase 3 - what existing features this touches]

**Estimated Effort**: [T-shirt size from Phase 4] ([N] story points, [M] sprints)

**Target Sprint**: Sprint [N] (based on Phase 4D)
```

**Line numbers**: L[New Start]-L[New End]
**Lines added**: [Count]

---

### Section 3: Success Metrics Update (if applicable)

**Current section** (PRD:L[A]-L[B]):
```
[Existing success metrics]
```

**Proposed update**:
```
[Existing success metrics]

**NEW - [Feature Name] Metrics**:
- [Metric from Phase 1]
- [Metric from Phase 2A]
```

**Line number impact**: Inserts at line [N], shifts subsequent content +[M] lines

---

### Section 4: Feature Inventory/Roadmap Update

**Current feature list** (PRD:L[P]-L[Q]):
```
- Feature 1: [Name]
- Feature 2: [Name]
- Feature 3: [Name]
```

**Proposed update** (insert in priority order):
```
- Feature 1: [Name]
- Feature 2: [Name]
- **NEW** - Feature [N]: [New Feature Name] - [Priority] - Sprint [M]
- Feature 3: [Name]
```

---

### Section 5: Changelog Addition

**Location**: End of PRD document

**Proposed new entry**:
```markdown
## Change Log

### [Date] - v[X.Y] - [Feature Name] Added

**Added**:
- New feature: [Feature Name]
- Success metrics for [Feature Name]
- Updated feature roadmap

**Reason**: [From Phase 1 - problem statement]

**Impact**:
- [From Phase 3 - affected features count]
- [From Phase 4 - sprint count estimate]

**Approved by**: [User name]
**Sprint**: S[N]
```

---

## PRD Update Summary

**Total Changes**:
- Executive summary: +[N] lines
- New feature section: +[M] lines
- Success metrics: +[P] lines
- Feature inventory: Modified
- Changelog: +[Q] lines

**Total lines added**: [Sum]
**Line number shift**: All content after line [X] shifts +[Sum] lines

**Updated traceability**:
- PRD feature will be at: L[New Start]-L[New End]
- Cross-references to update: [List SRS/UI plan sections that reference PRD line numbers]
```

## Step 5B: Show PRD Diff Preview

Present changes to user for approval:

```markdown
## PRD Diff Preview

**File**: prd-[product-name].md

**Changes**:

```diff
@@ Line [X] @@
 [Existing content]
+**NEW FEATURE**: [Feature Name]
+[Description]

@@ Line [Y] - New Feature Section @@
+## [N]. [Feature Name]
+
+### Overview
+[Full feature section as proposed above]

@@ Line [Z] - Success Metrics @@
 [Existing metrics]
+
+**NEW - [Feature Name] Metrics**:
+- [Metric 1]

@@ End of file - Changelog @@
+### [Date] - v[X.Y] - [Feature Name] Added
+[Changelog entry]
```

**Summary**:
- ➕ Added: [N] lines
- ✏️ Modified: [M] sections
- 🔢 Line shifts: Content after L[X] shifts +[N] lines

---

**USER APPROVAL REQUIRED**

Do you approve these PRD changes?
- [ ] ✅ YES - Apply these changes to PRD
- [ ] ✏️ MODIFY - I want to change [specify what]
- [ ] ❌ NO - Skip PRD updates

[Wait for user response before proceeding]
```

# PHASE 6: UX RESEARCH UPDATE PROPOSAL (CONDITIONAL)

**Execute this phase ONLY if**:
- UX Research document exists, AND
- Feature has user-facing components or changes user flows

**Skip if**: Feature is purely backend (no UI changes) or UX Research document doesn't exist

## Step 6A: Analyze UX Impact

Determine if the new feature affects user experience:

```markdown
## UX Impact Analysis

**User-Facing Changes**: [YES | NO]
- Does this feature add new screens? [YES/NO]
- Does this feature modify existing user flows? [YES/NO]
- Does this feature affect user personas? [YES/NO]
- Does this feature require new interaction patterns? [YES/NO]

**If ANY answer is YES → Proceed with UX Research updates**
**If ALL answers are NO → Skip to Phase 7 (SRS)**
```

## Step 6B: Generate UX Research Changes (If Applicable)

Read existing UX Research and propose updates:

```markdown
## UX Research Update Proposal

### Section 1: Document Revision History Update

**Current version** (UX:L[1]-L[10]):
```
Version: [Current version]
Last Updated: [Current date]
```

**Proposed update**:
```
Version: [Increment version]
Last Updated: [New date]
Changes: Added [Feature Name] user flow and interaction patterns
```

### Section 2: User Personas Update (If Applicable)

**If feature serves new persona type**:

**Location**: After existing personas (UX:L[X])

**Proposed addition**:
```markdown
#### Persona N: [New Persona Name]
[Demographics, goals, pain points, tech proficiency]
Key needs related to [Feature Name]:
- [Need 1]
- [Need 2]
```

**If feature enhances existing persona needs**:

**Location**: Within existing persona section (UX:L[X]-L[Y])

**Proposed update**:
```markdown
Additional needs (from [Feature Name]):
- [Enhanced need]
```

### Section 3: User Flows Addition

**Location**: User Flows section (UX:L[X])

**Proposed addition**:
```markdown
#### UF-[Next Number]: [Feature Name] User Flow

**User Goal**: [What user wants to accomplish]

**Entry Point**: [Where flow starts - screen/action]

**Flow Steps**:
1. [Step 1 description]
2. [Step 2 description]
3. [Decision point: If X, then Y; else Z]
4. [Step 4 description]

**Exit Point**: [Success state/destination]

**Error States**:
- Error 1: [Condition] → [Recovery action]
- Error 2: [Condition] → [Recovery action]

**Success Criteria**:
- [Criterion 1]
- [Criterion 2]

**Wireframe References**: [Link to wireframe section if created]
```

### Section 4: Wireframes/Mockups Addition (If Applicable)

**Location**: Wireframes section (UX:L[X])

**Proposed addition**:
```markdown
#### [Screen Name] - [Feature Name]

**Layout Pattern**: [Card grid/Form/Table/etc.]

**Key Components**:
- Component 1: [Name] - [Purpose]
- Component 2: [Name] - [Purpose]

**Interactions**:
- Action 1: [User action] → [System response]
- Action 2: [User action] → [System response]

**Design Rationale**: [Why this pattern was chosen]

**Accessibility Notes**: [WCAG considerations]
```

### Section 5: Interaction Patterns Addition (If New Patterns)

**Location**: Interaction Design section (UX:L[X])

**Proposed addition** (if feature introduces new interaction patterns):
```markdown
#### [Pattern Name] - For [Feature Name]

**Description**: [What this pattern does]

**Animation/Transition**: [Timing, easing, visual effect]

**Trigger**: [User action that initiates]

**Feedback**: [Visual/auditory feedback provided]

**Accessibility**: [Keyboard alternative, screen reader support]
```

### Section 6: Accessibility Requirements Update (If Applicable)

**Location**: Accessibility section (UX:L[X])

**Proposed addition** (if feature has specific accessibility needs):
```markdown
#### [Feature Name] Accessibility Requirements

- **Keyboard Navigation**: [Tab order, shortcuts]
- **Screen Reader**: [ARIA labels, announcements]
- **Focus Management**: [Focus trap, initial focus]
- **Color Contrast**: [Specific requirements]
```

## Step 6C: Present UX Research Diff Preview

```markdown
## 📝 UX RESEARCH UPDATE PREVIEW

**File**: ux-research-{product}.md

### Changes Summary

| Section | Change Type | Lines | Impact |
|---------|-------------|-------|--------|
| User Personas | Addition/Update | UX:L[X] | [Description] |
| User Flows | Addition | UX:L[Y] | New flow UF-[N] |
| Wireframes | Addition | UX:L[Z] | New screen [Name] |
| Interaction Patterns | Addition | UX:L[A] | New pattern [Name] |
| Accessibility | Addition | UX:L[B] | Requirements for [Feature] |

---

[Full diff content showing before/after for each section]

---

**USER APPROVAL REQUIRED**

Do you approve these UX Research changes?
- [ ] ✅ YES - Apply these changes to UX Research
- [ ] ✏️ MODIFY - I want to change [specify what]
- [ ] ❌ NO - Skip UX Research updates

[Wait for user response before proceeding]
```

# PHASE 7: SRS UPDATE PROPOSAL

## Step 7A: Generate SRS Changes

Read existing SRS and propose updates:

```markdown
## SRS Update Proposal

### Section 1: Document Revision History Update

**Current version** (SRS:L[1]-L[10]):
```
Version: [Current version]
Last Updated: [Current date]
```

**Proposed update**:
```
Version: [Increment version]
Last Updated: [Today's date]
Revision: Added [Feature Name] - Sprint S[N]
```

---

### Section 2: Table of Contents Update

**Proposed additions** to TOC:
```
3.X - [Feature Name] Functional Requirements
4.X - [Feature Name] API Specifications
5.X - [Feature Name] Database Schema Changes (if applicable)
```

---

### Section 3: Functional Requirements

**Location**: After existing FR section (SRS:L[X])

**Proposed new section**:

```markdown
### 3.[N] [Feature Name] Functional Requirements

#### REQ-[FEATURE]-001: [Requirement Title]
**Priority**: [P0/P1/P2]
**Source**: PRD Section [N], L[X]-L[Y]
**User Story**: US-[ID]

**Description**:
[Detailed requirement description from user stories]

**Acceptance Criteria**:
- AC1: [From Phase 4E user stories]
- AC2: [From Phase 4E user stories]
- AC3: [From Phase 4E user stories]

**Dependencies**:
- Depends on: REQ-[XXX]-[YYY] (SRS:L[A]-L[B])
- Required for: REQ-[ZZZ]-[WWW]

**Validation**:
- Input: [Validation rules]
- Output: [Expected results]
- Error handling: [Error scenarios]

---

#### REQ-[FEATURE]-002: [Next Requirement]
[Continue for all functional requirements derived from user stories...]

**Total Requirements**: [Count]
```

**Line numbers**: L[New Start]-L[New End]
**Lines added**: [Count]

---

### Section 4: API Specifications

**Location**: After existing API section (SRS:L[M])

**Proposed new APIs**:

For each API identified in Phase 3:

```markdown
### 4.[N] [Feature Name] API Endpoints

#### POST /api/[path]

**Description**: [From Phase 3 - API dependencies]

**Authentication**: Required (JWT Bearer token)

**Request**:
```json
{
  "field1": "string",
  "field2": "integer",
  "field3": {
    "nested": "object"
  }
}
```

**Request Schema**:
| Field | Type | Required | Validation | Description |
|-------|------|----------|------------|-------------|
| field1 | string | Yes | Max 255 chars | [Description] |
| field2 | integer | Yes | Min 1, Max 100 | [Description] |

**Response** (200 OK):
```json
{
  "id": "uuid",
  "status": "created",
  "data": {
    "field1": "string",
    "field2": "integer"
  },
  "created_at": "ISO 8601 datetime"
}
```

**Response Schema**:
| Field | Type | Description |
|-------|------|-------------|
| id | uuid | Unique identifier |
| status | string | Operation status |
| data | object | Result data |

**Error Responses**:
- 400 Bad Request: Invalid input
  ```json
  {"error": "field1 is required", "code": "VALIDATION_ERROR"}
  ```
- 401 Unauthorized: Missing/invalid token
- 403 Forbidden: Insufficient permissions
- 500 Internal Server Error: Server failure

**Rate Limiting**: 100 requests/minute per user

**OpenAPI 3.2 Specification**:
```yaml
/api/[path]:
  post:
    summary: [Description]
    tags:
      - [Feature Name]
    security:
      - BearerAuth: []
    requestBody:
      required: true
      content:
        application/json:
          schema:
            type: object
            required:
              - field1
              - field2
            properties:
              field1:
                type: string
                maxLength: 255
              field2:
                type: integer
                minimum: 1
                maximum: 100
    responses:
      '200':
        description: Successfully created
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/[Feature]Response'
```

---

[Continue for all APIs from Phase 3...]

**Total New Endpoints**: [Count]
```

**Line numbers**: L[New Start]-L[New End]
**Lines added**: [Count]

---

### Section 5: Database Schema Updates (if applicable)

**Only if database changes from Phase 3**

**Location**: After existing schema section (SRS:L[P])

**Proposed schema additions**:

```markdown
### 5.[N] [Feature Name] Database Schema

#### Table: [table_name]

**Purpose**: [Description from Phase 3]

**ERD**:
```
┌─────────────────────┐
│   [table_name]      │
├─────────────────────┤
│ PK  id (SERIAL)     │
│ FK  user_id (INT)   │ ──→ users.id
│     field1 (VARCHAR)│
│     field2 (JSONB)  │
│     created_at (TS) │
│     updated_at (TS) │
└─────────────────────┘
```

**Schema Definition**:
```sql
CREATE TABLE [table_name] (
  id SERIAL PRIMARY KEY,
  user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  field1 VARCHAR(255) NOT NULL,
  field2 JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- Indexes
  CREATE INDEX idx_[table]_user_id ON [table_name](user_id);
  CREATE INDEX idx_[table]_created_at ON [table_name](created_at);
);

-- Trigger for updated_at
CREATE TRIGGER update_[table]_updated_at
BEFORE UPDATE ON [table_name]
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();
```

**Data Dictionary**:
| Column | Type | Nullable | Default | Description | Constraints |
|--------|------|----------|---------|-------------|-------------|
| id | SERIAL | No | AUTO | Primary key | PK |
| user_id | INTEGER | No | - | Owner user | FK→users.id |
| field1 | VARCHAR(255) | No | - | [Description] | Max 255 |
| field2 | JSONB | Yes | '{}' | [Description] | Valid JSON |
| created_at | TIMESTAMP | No | NOW() | Creation time | - |
| updated_at | TIMESTAMP | No | NOW() | Last update | - |

**Relationships**:
- MANY-TO-ONE with `users` (user_id → users.id)
- [Other relationships from Phase 3]

**Migration**:
```sql
-- Migration Up
-- File: migrations/[timestamp]_add_[feature]_table.sql
[Schema definition above]

-- Migration Down
DROP TABLE IF EXISTS [table_name] CASCADE;
```

**Migration Complexity**: [SIMPLE | MODERATE | COMPLEX] (from Phase 3)
**Data Migration Required**: [YES/NO]
```

**Line numbers**: L[New Start]-L[New End]
**Lines added**: [Count]

---

### Section 6: Non-Functional Requirements Update

**Location**: NFR section (SRS:L[Q])

**Proposed NFR additions**:

```markdown
### 6.[N] [Feature Name] Non-Functional Requirements

#### NFR-[FEATURE]-PERF-001: Response Time
**Requirement**: API endpoints must respond within 200ms for 95th percentile
**Measurement**: Response time monitoring via APM
**Priority**: P1

#### NFR-[FEATURE]-SEC-001: Data Security
**Requirement**: All [feature] data must be encrypted at rest and in transit
**Implementation**: TLS 1.3 for transit, AES-256 for rest
**Priority**: P0

#### NFR-[FEATURE]-SCALE-001: Scalability
**Requirement**: Must handle [N] concurrent users
**Target**: [From Phase 2B - architect evaluation]
**Priority**: P1

[Continue for all NFRs from Phase 2B...]
```

---

### Section 7: Integration Specifications

**Location**: After existing integrations (SRS:L[R])

**Proposed integration documentation**:

```markdown
### [N]. [Feature Name] Integrations

#### Frontend-Backend Integration

**Components**:
- Frontend: [Components from Phase 3 UI dependencies]
- Backend: [APIs from this section]

**Data Flow**:
1. User action in [Component] (UI:L[X]-L[Y])
2. API call to POST /api/[path] (SRS:L[A]-L[B])
3. Backend processes request
4. Response updates component state
5. UI reflects changes

**Error Handling**:
- Network errors: Retry with exponential backoff
- Validation errors: Show inline field errors
- Server errors: Show global error message + log

**State Management**:
[From Phase 2C - UI/UX evaluation]

#### External Service Integration (if applicable)

**Service**: [From Phase 3 - external dependencies]
**Purpose**: [What it provides]
**Integration Method**: [REST API / SDK / WebSocket]
**Authentication**: [Method]
**Fallback**: [Strategy if service unavailable]
**SLA**: [Uptime guarantee]
**Cost**: [Pricing model]
```

---

### Section 8: Changelog Addition

**Location**: End of SRS

**Proposed changelog entry**:

```markdown
## Change Log

### [Date] - v[X.Y] - [Feature Name]

**Added**:
- Functional requirements: REQ-[FEATURE]-001 through REQ-[FEATURE]-[N]
- API endpoints: POST /api/[path], GET /api/[path]
- Database schema: [table_name]
- Non-functional requirements: [Count] NFRs
- Integration specifications

**Modified**:
- [Existing requirements that changed from Phase 3]

**Reason**: New feature addition per PRD Section [N]

**Dependencies**:
- Prerequisites: [From Phase 3]
- Impacts: [Affected requirements from Phase 3]

**Sprint**: S[N]
```

---

## SRS Update Summary

**Total Changes**:
- Document version: Updated
- Table of contents: +[N] sections
- Functional requirements: +[M] requirements
- API specifications: +[P] endpoints
- Database schema: +[Q] tables
- NFRs: +[R] requirements
- Integration specs: +[S] sections
- Changelog: +[T] lines

**Total lines added**: [Sum]
**Line number shift**: All content after line [X] shifts +[Sum] lines

**Updated traceability**:
- REQ-[FEATURE]-XXX will be at: L[New Start]-L[New End]
- API specs will be at: L[API Start]-L[API End]
- DB schema will be at: L[DB Start]-L[DB End]
```

## Step 6B: Show SRS Diff Preview

Present changes to user for approval:

```markdown
## SRS Diff Preview

**File**: srs-[product-name].md

**Changes**:

```diff
@@ Line 1 - Version @@
-Version: [Old version]
+Version: [New version]
-Last Updated: [Old date]
+Last Updated: [Today]

@@ Line [X] - Functional Requirements @@
 [Existing FRs]
+
+### 3.[N] [Feature Name] Functional Requirements
+
+#### REQ-[FEATURE]-001: [Title]
+[Full requirement spec]

@@ Line [Y] - API Specifications @@
 [Existing APIs]
+
+### 4.[N] [Feature Name] API Endpoints
+
+#### POST /api/[path]
+[Full API spec with OpenAPI]

@@ Line [Z] - Database Schema (if applicable) @@
 [Existing schema]
+
+### 5.[N] [Feature Name] Database Schema
+[Full schema spec]
```

**Summary**:
- ➕ Added: [N] requirements, [M] APIs, [P] tables
- ✏️ Modified: [Q] sections
- 🔢 Line shifts: Content after L[X] shifts +[Sum] lines

---

**USER APPROVAL REQUIRED**

Do you approve these SRS changes?
- [ ] ✅ YES - Apply these changes to SRS
- [ ] ✏️ MODIFY - I want to change [specify what]
- [ ] ❌ NO - Skip SRS updates

[Wait for user response before proceeding]
```

# PHASE 8: UI PLAN UPDATE PROPOSAL (CONDITIONAL)

**Execute this phase ONLY if**:
- From Phase 1D: Feature type is UI-Heavy or Full-Stack
- From Phase 2C: UXCanvas Prompt Needed = YES

## Step 7A: Generate UI Plan Changes

```markdown
## UI Plan Update Proposal

### Section 1: Component Inventory Update

**Location**: Component inventory section (UI:L[X])

**Proposed additions**:

```markdown
### New Components for [Feature Name]

From Phase 2C and Phase 3 UI dependencies analysis:

#### [ComponentName]
**Purpose**: [From Phase 2C]
**Complexity**: [SIMPLE | MEDIUM | COMPLEX]
**Location**: `src/components/[ComponentName].tsx`
**Reusability**: [Can be reused for: [Other features] | Feature-specific]

**Props Interface** (estimated):
```typescript
interface [ComponentName]Props {
  data?: [Type];           // [Description]
  onAction: (param) => void; // [Description]
  isLoading?: boolean;
  className?: string;
}
```

**State Management**:
- Local state: [useState for: [what]]
- Global state: [If needed: Context/Redux for: [what]]
- API integration: [Which endpoints from SRS Section 4.X]

**Accessibility**:
- ARIA labels: [Required labels]
- Keyboard navigation: [Tab order, shortcuts]
- Screen reader: [What's announced]

**Responsive**:
- Mobile: [Behavior/layout]
- Tablet: [Behavior/layout]
- Desktop: [Behavior/layout]

**Dependencies**:
- Uses components: [List existing components from UI:L[Y]-L[Z]]
- Design tokens: [Colors, typography, spacing]
- APIs: [From SRS Section 4.X]

**Testing**:
- Unit tests: [Key scenarios]
- Integration tests: [With APIs]
- E2E tests: [User flows]

---

[Continue for all new components from Phase 2C...]

**Total New Components**: [Count]
```

**Line numbers**: L[New Start]-L[New End]
**Lines added**: [Count]

---

### Section 2: Screen Inventory Update

**Location**: Screen inventory section (UI:L[M])

**Proposed additions**:

```markdown
### New Screens for [Feature Name]

#### [ScreenName]
**Route**: `/[path]`
**Purpose**: [From Phase 2C]
**Complexity**: [SIMPLE | MEDIUM | COMPLEX]
**Location**: `src/app/[path]/page.tsx`

**Layout Structure**:
```
┌─────────────────────────────────┐
│ Header (existing)               │
├─────────────────────────────────┤
│ [MainComponent]                 │
│  ├─ [SubComponent1]             │
│  ├─ [SubComponent2]             │
│  └─ [SubComponent3]             │
├─────────────────────────────────┤
│ Footer (existing)               │
└─────────────────────────────────┘
```

**Components Used**:
- [NewComponent1] (UI:L[X]-L[Y]) - [Purpose]
- [NewComponent2] (UI:L[A]-L[B]) - [Purpose]
- [ExistingComponent] (UI:L[M]-L[N]) - [Purpose]

**Data Requirements**:
- From API: GET /api/[path] (SRS:L[P]-L[Q])
- From API: POST /api/[path] (SRS:L[R]-L[S])

**User Flow**:
1. User navigates to /[path]
2. Page loads, fetches data from API
3. [MainComponent] renders with data
4. User performs [action]
5. API call updates backend
6. UI updates to reflect changes

**Responsive Layout**:
- Mobile (< 768px): [Single column, stacked]
- Tablet (768-1024px): [Two columns]
- Desktop (> 1024px): [Three columns]

**Loading States**:
- Initial load: Skeleton UI
- Action in progress: Loading spinner + disabled controls
- Error state: Error message + retry button

---

[Continue for all new screens from Phase 2C...]

**Total New Screens**: [Count]
```

---

### Section 3: Component-API Mapping Update

**Location**: Integration matrix (UI:L[N])

**Proposed additions**:

```markdown
### [Feature Name] Component-API Integration

| Component | API Endpoint | SRS Lines | UI Lines | Method | Data Flow |
|-----------|--------------|-----------|----------|--------|-----------|
| [Component1] | POST /api/[path] | L[X]-L[Y] | L[A]-L[B] | POST | Form submit → API → Success message |
| [Component2] | GET /api/[path] | L[M]-L[N] | L[C]-L[D] | GET | Page load → API → Render list |
| [Component3] | PUT /api/[path] | L[P]-L[Q] | L[E]-L[F] | PUT | Edit action → API → Update UI |

**Integration Notes**:
- Error handling: [Strategy from SRS Section 8]
- Loading states: [Strategy]
- Optimistic updates: [YES/NO - for which actions]
- Caching: [Strategy - React Query, SWR, etc.]
```

---

### Section 4: User Flow Update

**Location**: User flows section (UI:L[P])

**Proposed addition**:

```markdown
### Flow [N]: [Feature Name] User Flow

**Entry Point**: [Where user starts]
**Exit Point**: [Where user ends]
**Frequency**: [How often: Always | Optional | Rarely]

**Steps**:

**Step 1: [Action Name]**
- **Screen**: /[route] (UI:L[X]-L[Y])
- **User Action**: [What user does]
- **System Response**: API call to [endpoint] (SRS:L[A]-L[B])
- **UI Update**: [What changes on screen]
- **Success Indicator**: [How user knows it worked]
- **Error Handling**: [What happens if fails]

**Step 2: [Next Action]**
[Continue for all steps...]

**Success Path**: Steps 1 → 2 → 3 → 4 → Success
**Error Paths**:
- If Step 2 fails: Show error → Retry or Cancel
- If Step 3 fails: Rollback → Return to Step 1

**Accessibility**: [Keyboard shortcuts, screen reader announcements]
```

---

### Section 5: Changelog Addition

**Location**: End of UI plan

**Proposed changelog entry**:

```markdown
## Change Log

### [Date] - v[X.Y] - [Feature Name] UI

**Added**:
- Components: [List]
- Screens: [List]
- User flows: [Count]
- Component-API mappings: [Count]

**Modified**:
- [Components from Phase 3 - affected components]

**Reason**: New feature UI per PRD Section [N], SRS Section [M]

**Sprint**: S[N]
```

---

## UI Plan Update Summary

**Total Changes**:
- Component inventory: +[N] components
- Screen inventory: +[M] screens
- Component-API mapping: +[P] integrations
- User flows: +[Q] flows
- Changelog: +[R] lines

**Total lines added**: [Sum]
```

## Step 7B: Generate UXCanvas Prompt

**Only if UI changes needed**

Create a focused UXCanvas prompt for this feature:

```markdown
## UXCanvas Prompt for [Feature Name]

**File**: uxcanvas-prompt-[feature-name].md

**Content**:

```markdown
# UXCanvas Design Request: [Feature Name]

## Context
This is an addition to an existing product. Please generate UI components that:
- Match the existing design system (colors, typography, components)
- Integrate with existing navigation and layouts
- Follow established patterns from current screens

**Existing Design System** (from UI Plan):
- **Colors**: Primary [hex], Secondary [hex], Accent [hex]
- **Typography**: Heading [font], Body [font]
- **Component Library**: [List key existing components to reuse]

---

## Feature Overview

**Feature**: [Name]
**Purpose**: [From Phase 1 - problem statement]
**User Story**: As a [persona], I want to [capability], so that [benefit]

---

## Target User

**Primary Persona**: [From PRD]
- Demographics: [From PRD]
- Goals: [From PRD]
- Pain Points: [From Phase 1]

---

## New Components Needed

[From Phase 2C and this phase - list all new components]

### [ComponentName]
**Purpose**: [What it does]
**Complexity**: [SIMPLE | MEDIUM | COMPLEX]
**Key Interactions**: [User actions]
**Data**: [What data it displays/collects]
**States**: [Loading, error, success, empty]

---

## New Screens

[From Phase 2C and this phase - list all new screens]

### [ScreenName] (`/[route]`)
**Purpose**: [What user accomplishes]
**Components**: [List components on this screen]
**Layout**: [Describe layout]
**Data**: [What APIs provide data - reference SRS]

---

## User Flow

**From Phase 2C/7A**:

[Copy user flow from Step 7A Section 4]

---

## UI/UX Requirements

### Visual Design
- **Consistency**: Must match existing design system
- **Accessibility**: WCAG 2.1 AA compliance
  - Keyboard navigation for all interactions
  - Screen reader support with ARIA labels
  - Color contrast ≥4.5:1
  - Focus indicators on all interactive elements

### Responsive Design
- Mobile-first approach
- Breakpoints: 768px (tablet), 1024px (desktop)
- Touch-friendly targets (min 44x44px)

### Interaction Patterns
[From Phase 2C - user interaction complexity]

---

## Integration with Backend

**APIs This Feature Uses** (from SRS):

### [Endpoint Name]
**Method**: [GET/POST/PUT/DELETE]
**Path**: /api/[path]
**Purpose**: [What it does]

**Request** (example):
```json
{
  "field": "value"
}
```

**Response** (example):
```json
{
  "id": "123",
  "data": {}
}
```

[Continue for all APIs from SRS Section 4.X...]

---

## Error Handling

**Validation Errors**: Show inline next to field
**Network Errors**: Toast notification + retry button
**Server Errors**: Error page with support contact
**Empty States**: Helpful message + CTA

---

## Loading States

- **Initial load**: Skeleton UI matching final layout
- **Action in progress**: Loading spinner + disabled controls
- **Background refresh**: Subtle indicator, non-blocking

---

## Success Criteria

- [ ] All components match existing design system
- [ ] All screens responsive (mobile/tablet/desktop)
- [ ] WCAG 2.1 AA compliant
- [ ] All user flows implemented
- [ ] Error handling for all API calls
- [ ] Loading states for all async actions

---

## Generation Instructions

🎨 **Please generate**:
1. All components listed above in React + TypeScript + Tailwind CSS
2. All screens with proper routing (Next.js 14 App Router)
3. API integration with proper error handling
4. Responsive layouts for all breakpoints
5. Accessibility features (ARIA, keyboard nav)
6. Loading and error states

**Deliverables**:
- Component files: `src/components/[ComponentName].tsx`
- Screen files: `src/app/[route]/page.tsx`
- Type definitions: Interfaces for all props and data
- Ready for download via UXCanvas API

```

**File created**: uxcanvas-prompt-[feature-name].md
**Size**: [Estimated 5-10KB]
```

## Step 7C: Show UI Plan Diff Preview

**Only if UI changes needed**

```markdown
## UI Plan Diff Preview

**File**: ui-implementation-[product-name].md

**Changes**:

```diff
@@ Line [X] - Component Inventory @@
 [Existing components]
+
+### New Components for [Feature Name]
+
+#### [ComponentName]
+[Full component spec]

@@ Line [Y] - Screen Inventory @@
 [Existing screens]
+
+### New Screens for [Feature Name]
+
+#### [ScreenName]
+[Full screen spec]

@@ Line [Z] - Component-API Mapping @@
 [Existing mappings]
+
+| [Component] | [API] | ... |
```

**Summary**:
- ➕ Added: [N] components, [M] screens
- ✏️ Modified: [P] existing components
- 🔢 Line shifts: Content after L[X] shifts +[Sum] lines

**New File Created**:
- uxcanvas-prompt-[feature-name].md ([Size]KB)

---

**USER APPROVAL REQUIRED**

Do you approve these UI Plan changes?
- [ ] ✅ YES - Apply these changes to UI Plan
- [ ] ✏️ MODIFY - I want to change [specify what]
- [ ] ❌ NO - Skip UI Plan updates

[Wait for user response before proceeding]
```

# PHASE 9: SPRINT PLANNING & CREATION

## Step 9A: Determine Sprint Placement

Based on dependency analysis from Phase 3:

```markdown
## Sprint Placement Analysis

### Current Sprint State

**From Phase 1C - Sprint Schedule Analysis**:
- Last planned sprint: S[N]
- Next available sprint: S[N+1]

### Dependency Requirements

**From Phase 3B - Feature Dependencies**:

**Prerequisites** (must be completed first):
- Feature 1: [Name] - Currently in Sprint S[X]
- Feature 2: [Name] - Currently in Sprint S[Y]

**Latest prerequisite sprint**: S[max(X, Y)]

**Earliest this feature can start**: S[max(X, Y) + 1]

### Topological Sort Validation

**From Phase 3B - Topological Sort Update**:

**New feature position in dependency order**:
- Must come AFTER: [Prerequisites]
- Must come BEFORE: [Dependent features if any]

**Valid sprint placement**: S[Earliest] or later

### Sprint Count Requirement

**From Phase 4D - Sprint Count Calculation**:
- Feature size: [N] story points
- Sprint capacity: [X] points/sprint
- Sprints needed: [M] sprint(s)

**Sprint assignment**:
- Sprint S[Earliest]: [Description of work]
- Sprint S[Earliest+1]: [Description of work] (if multi-sprint)
- Sprint S[Earliest+2]: [Description of work] (if 3+ sprints)

**Placement decision**: Sprint(s) S[Earliest] through S[Earliest+M-1]
```

## Step 8B: Create Sprint File(s)

For each sprint needed (from Phase 4D):

```markdown
## Sprint File Creation

### Sprint S[N]: [Feature Name] - [Phase Description]

**File**: sprints/sprint_[NN]/sprint_plan.md

**Content**:

```markdown
---
sprint: [N]
dates: [Start Date] to [End Date]
duration: 2wk
capacity: [X]pts
committed: [Y]pts
velocity_target: [Z]pts
focus_epic: [Feature Name]
risk_level: [LOW/MEDIUM/HIGH from Phase 2E]
feature_addition: true
---

# S[N]: [Feature Name] - [Phase]

**Goal**: [From user story - what user can accomplish after this sprint]

**Meta**: [X]pts cap | [Y]pts committed | [Team size] devs | [Feature Name] focus
**Risk**: [LEVEL from Phase 2] - [Primary risks from Phase 2/3]
**Depends**: [Sprint dependencies from Phase 3]
**Feature Addition**: New feature added to roadmap

## Committed Work ([Y]/[X] pts)

[From Phase 4E - User Stories]

### US-[ID]: [Story Title] ([N]pts) [P0/P1/P2]
**Refs**: PRD:L[X]-L[Y], SRS:L[A]-L[B], UI:L[M]-L[N] (if applicable)
**AC**: [Criterion 1 from Phase 5/6/7], [Criterion 2], [Criterion 3]
**Tasks**: [Task list from Phase 4E]
**Owner**: [TBD - to be assigned during sprint planning] | **Status**: Not Started | **Depends**: [US-XXX if dependency]

### US-[ID2]: [Next Story] ([N]pts) [P0/P1/P2]
**Refs**: PRD:L[X]-L[Y], SRS:L[A]-L[B]
**AC**: [ACs]
**Tasks**: [Tasks]
**Owner**: [TBD] | **Status**: Not Started

[Continue for all user stories in this sprint...]

## Dependencies

### External Dependencies
[From Phase 3 - External Service Dependencies, Resource Dependencies]
- **External**: [Service/Tool name] - Due: [Date] - Owner: [Team/Person] - Status: 🟡 Pending
- **External**: [Infrastructure] - [Description] - Provisioning time: [N] days

### Internal Dependencies
[From Phase 3 - Feature Dependencies, API Dependencies, DB Dependencies]
- **Internal**: US-[XXX] depends on US-[YYY] (same sprint/different sprint)
- **Blocking**: [Feature from other sprint] must be complete (Sprint S[X])

### API Dependencies
[From Phase 6A - API Specifications]
- Provides API: POST /api/[path] (SRS:L[X]-L[Y]) - Used by: [Future features]
- Depends on API: GET /api/[path] (SRS:L[A]-L[B]) - Must exist

### Database Dependencies
[From Phase 6A - Database Schema if applicable]
- New table: [table_name] - Depends on: [existing_table]
- Migration: [Complexity level] - Backfill needed: [YES/NO]

## Risks

[From Phase 2 - All expert evaluations, Phase 3 - Dependency risks]

**Technical Risks**:
- R1: [Risk from Phase 2B Architect] ([L]×[I]=[Score]) - Mit: [Strategy]
- R2: [Integration complexity from Phase 3] ([L]×[I]=[Score]) - Mit: [Strategy]

**UX Risks** (if applicable):
- R3: [Risk from Phase 2C UX Designer] ([L]×[I]=[Score]) - Mit: [Strategy]

**Capacity Risks**:
- R4: [Risk from Phase 2D Scrum Master] ([L]×[I]=[Score]) - Mit: [Strategy]

**Dependency Risks**:
- R5: [Dependency risk from Phase 3] ([L]×[I]=[Score]) - Mit: [Strategy]

## Capacity Detail

**From Phase 2D - Scrum Master Evaluation**:
- Team: [N] devs × 6h/day × 10 days = [X]h total
- Ceremonies: 24h | Net: [Y]h × 0.80 focus = [Z]h ≈ [A]pts capacity
- Committed: [B]pts ([C]% capacity)
- Allocation: [D]% features, [E]% infrastructure, [F]% tech debt

**Velocity Considerations**:
- Average velocity: [From Phase 1C]
- New feature complexity: [From Phase 4]
- Team learning curve: [Factor if new technology]
```

**File size**: ~5-10KB (context-optimized)
**Line count**: ~150-200 lines
```

## Step 8C: Update Dependency Graph

```markdown
## Dependency Graph Update

Update the Mermaid dependency graph to include new feature:

```mermaid
graph TD
    S0[Sprint 0: Infrastructure] --> S1[Sprint 1: Auth]
    S1 --> S2[Sprint 2: Users]
    S2 --> S3[Sprint 3: Content]
    S3 --> S4[Sprint 4: Search]

    %% Existing features
    S2 --> S5[Sprint 5: Payments]
    S5 --> S6[Sprint 6: Orders]

    %% NEW FEATURE
    S2 --> NEW[Sprint 7: NEW FEATURE]
    NEW --> S8[Sprint 8: Admin]

    %% Dependent features
    S4 --> S8
    S6 --> S8
    S8 --> S9[Sprint 9: Polish]

    style NEW fill:#ffeb3b,stroke:#f57c00,stroke-width:3px
```

**Critical Path Updated**:
- Previous: S0 → S1 → S2 → S3 → S4 → S8 → S9
- **With new feature**: [Update if on critical path]
```

# PHASE 10: TRACEABILITY MATRIX UPDATE

## Step 10A: Update Requirements Coverage

```markdown
## Traceability Matrix Update

**File**: sprints/traceability_matrix.md

**Add new entries** (with UX Research integration):

| PRD Feature | UX Flow | SRS Requirement | UI Component | User Story | Sprint | Status |
|-------------|---------|-----------------|--------------|------------|--------|--------|
| **NEW** PRD:L[X]-L[Y] ([Feature]) | **NEW** UX:UF-[N] | **NEW** SRS:L[A]-L[B] (REQ-[FEATURE]-001) | **NEW** UI:L[M]-L[N] ([Component]) | **NEW** US-[ID] | S[N] | Planned |
| **NEW** PRD:L[X]-L[Y] ([Feature]) | **NEW** UX:UF-[N] | **NEW** SRS:L[C]-L[D] (REQ-[FEATURE]-002) | **NEW** UI:L[P]-L[Q] ([Component]) | **NEW** US-[ID2] | S[N] | Planned |

**Coverage Statistics Update**:
- PRD Features Mapped: [Old count + 1]/[Total + 1] ([New %])
- UX Flows Mapped: [Old + 1]/[Total + 1] ([New %]) (if UX changes)
- SRS Requirements Mapped: [Old + N]/[Total + N] ([New %])
- UI Components Mapped: [Old + M]/[Total + M] ([New %]) (if UI changes)

**Sprint Schedule Update**:

| Sprint | Dates | Goal | Committed | Epic Focus | Risk | Status |
|--------|-------|------|-----------|------------|------|--------|
| [Existing sprints...] | | | | | | |
| **NEW** S[N] | [Dates] | [Feature Name] | [Y]pts | [Feature] | [LEVEL] | Planned |

**Epic Breakdown Update**:

### Epic: [Feature Name] ([Y]pts, [M] sprint(s))
- ✓ US-[ID]: [Title] ([N]pts) - S[N]
- ✓ US-[ID2]: [Title] ([N]pts) - S[N]
[Continue for all user stories...]
```

## Step 10B: Update Sprint README

```markdown
## Sprint README Update

**File**: sprints/README.md

**Update sprint overview table**:

| # | Dates | Goal | Focus | Capacity | Committed | Velocity | Risk | Status |
|---|-------|------|-------|----------|-----------|----------|------|--------|
| [Existing sprints...] | | | | | | | | |
| **NEW** [N](sprint_[NN]/sprint_plan.md) | [Dates] | [Feature Name] | [Feature] | [X]pts | [Y]pts | — | [LEVEL] | 📋 Planned |

**Update milestones** (if applicable):
- 📋 **[Date]**: [Feature Name] Live (S[N] complete)

**Update epic distribution**:
```
[Existing distribution...]
Sprint [N]: [Feature Name] ████████ [Y]pts
```

**Update total statistics**:
- **Total Sprints**: [Old count + M]
- **Total Points**: [Old total + Y]
- **Average Committed**: [Recalculate average]
```

# PHASE 11: EXECUTE UPDATES & SUMMARY

## Step 11A: Apply Approved Changes

After user approvals from Phases 5B (PRD), 6C (UX Research), 7B (SRS), 8C (UI Plan):

```markdown
## Executing Document Updates

### 1. Update PRD

**If user approved PRD changes**:

```bash
# Read current PRD
[Read prd-{product-name}.md]

# Apply changes from Phase 5A
# Use Edit tool to:
# - Update executive summary
# - Add new feature section at calculated line
# - Update success metrics
# - Update feature inventory
# - Add changelog entry

# Result: prd-{product-name}.md updated
```

**Version increment**: v[X.Y] → v[X.Y+1]

---

### 2. Update UX Research (Conditional)

**If user approved UX Research changes AND UX changes needed**:

```bash
# Read current UX Research
[Read ux-research-{product-name}.md]

# Apply changes from Phase 6B
# Use Edit tool to:
# - Update document version
# - Add/update user personas (if applicable)
# - Add new user flow (UF-[N])
# - Add wireframes/mockups (if applicable)
# - Add interaction patterns (if new patterns)
# - Add accessibility requirements (if applicable)
# - Add changelog entry

# Result: ux-research-{product-name}.md updated
```

**Version increment**: v[X.Y] → v[X.Y+1]

---

### 3. Update SRS

**If user approved SRS changes**:

```bash
# Read current SRS
[Read srs-{product-name}.md]

# Apply changes from Phase 6A
# Use Edit tool to:
# - Update document version
# - Update table of contents
# - Add functional requirements section
# - Add API specifications section
# - Add database schema section (if applicable)
# - Update NFRs
# - Add integration specifications
# - Add changelog entry

# Result: srs-{product-name}.md updated
```

**Version increment**: v[X.Y] → v[X.Y+1]

---

### 4. Update UI Plan (Conditional)

**If user approved UI Plan changes AND UI changes needed**:

```bash
# Read current UI plan
[Read ui-implementation-{product-name}.md]

# Apply changes from Phase 7A
# Use Edit tool to:
# - Update component inventory
# - Update screen inventory
# - Update component-API mapping
# - Add user flow
# - Add changelog entry

# Result: ui-implementation-{product-name}.md updated
```

**Version increment**: v[X.Y] → v[X.Y+1]

---

### 4. Create UXCanvas Prompt (Conditional)

**If UI changes needed**:

```bash
# Create new file from Phase 7B
# Use Write tool

# Result: uxcanvas-prompt-[feature-name].md created
```

---

### 5. Create Sprint File(s)

**From Phase 8B**:

```bash
# Create sprint directory if needed
mkdir -p sprints/sprint_[NN]

# Create sprint plan file
# Use Write tool with content from Phase 8B

# Result: sprints/sprint_[NN]/sprint_plan.md created
```

**Repeat for each sprint** (if multi-sprint feature)

---

### 6. Update Traceability Matrix

```bash
# Read current traceability matrix
[Read sprints/traceability_matrix.md]

# Apply changes from Phase 9A
# Use Edit tool to:
# - Add new rows to requirements coverage table
# - Update coverage statistics
# - Add new rows to sprint schedule table
# - Add new epic breakdown section

# Result: sprints/traceability_matrix.md updated
```

---

### 7. Update Sprint README

```bash
# Read current sprint README
[Read sprints/README.md]

# Apply changes from Phase 9B
# Use Edit tool to:
# - Add new row(s) to sprint overview table
# - Update milestones
# - Update epic distribution
# - Update total statistics

# Result: sprints/README.md updated
```
```

## Step 10B: Generate Change Summary Report

Create comprehensive report of all changes:

```markdown
## Feature Addition Summary Report

**File**: feature-addition-summary-[feature-name]-[date].md

**Content**:

```markdown
# Feature Addition Summary: [Feature Name]

**Date**: [Today's date]
**Added by**: [User name]
**Feature Type**: [Backend-Heavy | UI-Heavy | Full-Stack | Infrastructure]

---

## Executive Summary

**Feature**: [Feature Name]
**Problem**: [From Phase 1 - problem statement]
**Solution**: [From Phase 1 - user story]
**Business Value**: [From Phase 2A - RICE score, business impact]
**Estimated Effort**: [From Phase 4] ([N] story points, [M] sprint(s))
**Target Sprint(s)**: S[N] through S[N+M-1]

---

## Feature Overview

### User Story
```
As a [persona]
I want to [capability]
So that I can [benefit]
```

### Success Metrics
[From Phase 1 and Phase 5A]

### Priority & Justification
- **RICE Score**: [Score] → [Priority level]
- **MoSCoW**: [Classification]
- **WSJF**: [Score] → [Priority level]
- **Value/Effort**: [Quadrant]

---

## Multi-Expert Evaluation Results

### Product Manager ✅ **[Recommendation]**
- **Business Value**: [Assessment]
- **User Impact**: [Reach × Impact]
- **Key Insight**: [Quote from Phase 2A]

### Software Architect ✅ **[Recommendation]**
- **Technical Feasibility**: [Level]
- **Architecture Impact**: [Level]
- **Key Concern**: [Quote from Phase 2B]

### UI/UX Designer ✅ **[Recommendation]** (if applicable)
- **Design Consistency**: [Level]
- **User Experience**: [Level]
- **Key Consideration**: [Quote from Phase 2C]

### Scrum Master ✅ **[Recommendation]**
- **Sprint Impact**: [Level]
- **Capacity Available**: [Yes/No]
- **Key Risk**: [Quote from Phase 2D]

**Overall Decision**: **[APPROVED | APPROVED WITH CONDITIONS | DEFERRED | REJECTED]**

---

## Impact Analysis

### Change Propagation
- **Features Impacted**: [Count from Phase 3A]
- **Requirements Updated**: [Count from Phase 3A]
- **Components Modified**: [Count from Phase 3A]
- **Propagation Risk**: [LOW | MEDIUM | HIGH]

### Dependencies
**Total Dependencies**: [Count from Phase 3D]
- API Dependencies: [Count]
- Database Dependencies: [Count]
- Feature Prerequisites: [Count]
- Resource Dependencies: [Count]
- UI Dependencies: [Count]

**Blocking Dependencies**: [Count]
**Dependency Risk**: [LOW | MEDIUM | HIGH]

### Critical Path Impact
- **On Critical Path**: [YES/NO]
- **Timeline Impact**: [+N weeks | None]
- **Project End Date**: [New date | No change]

---

## Technical Specifications

### T-Shirt Size & Estimation
- **Size**: [XS/S/M/L/XL/XXL]
- **Story Points**: [N] points
- **Sprint Count**: [M] sprint(s)
- **User Stories Created**: [Count]

### User Stories
[List all user stories from Phase 4E with IDs, titles, points]

---

## Document Updates

### PRD Updates
**File**: prd-{product-name}.md
**Version**: v[X.Y] → v[X.Y+1]
**Changes**:
- Executive summary: Updated
- New feature section: Added at L[X]-L[Y]
- Success metrics: Updated
- Feature inventory: Updated
- Changelog: Entry added
**Total lines added**: [Count]

### SRS Updates
**File**: srs-{product-name}.md
**Version**: v[X.Y] → v[X.Y+1]
**Changes**:
- Functional requirements: +[N] requirements (REQ-[FEATURE]-001 through REQ-[FEATURE]-[N])
- API specifications: +[M] endpoints
- Database schema: +[P] tables
- NFRs: +[Q] requirements
- Integration specs: Added
- Changelog: Entry added
**Total lines added**: [Count]

**New Requirements**:
- REQ-[FEATURE]-001: [Title] (SRS:L[X]-L[Y])
- REQ-[FEATURE]-002: [Title] (SRS:L[A]-L[B])
[Continue for all requirements...]

**New APIs**:
- POST /api/[path] (SRS:L[M]-L[N])
- GET /api/[path] (SRS:L[P]-L[Q])
[Continue for all APIs...]

**New Database Tables** (if applicable):
- [table_name] (SRS:L[R]-L[S])

### UI Plan Updates (if applicable)
**File**: ui-implementation-{product-name}.md
**Version**: v[X.Y] → v[X.Y+1]
**Changes**:
- Component inventory: +[N] components
- Screen inventory: +[M] screens
- Component-API mapping: +[P] integrations
- User flows: +[Q] flows
- Changelog: Entry added
**Total lines added**: [Count]

**New Components**:
- [ComponentName] (UI:L[X]-L[Y])
- [ComponentName2] (UI:L[A]-L[B])

**New Screens**:
- /[route] (UI:L[M]-L[N])

**New File Created**:
- uxcanvas-prompt-[feature-name].md ([Size]KB)

---

## Sprint Planning

### Sprint Assignment
**Sprint(s)**: S[N] through S[N+M-1]
**Dates**: [Start] to [End]
**Duration**: [M] × 2 weeks = [N] weeks
**Capacity**: [X] points/sprint
**Committed**: [Y] points total

### Sprint Breakdown

**Sprint S[N]**: [Phase Description]
- **Goal**: [Sprint goal]
- **Committed**: [Y] points
- **Stories**: US-[ID], US-[ID2], ...
- **Risk**: [LEVEL]

[Continue for each sprint...]

### Files Created
- sprints/sprint_[NN]/sprint_plan.md
[Continue for each sprint...]

---

## Traceability

### Requirements Traceability Matrix
[Table from Phase 9A showing PRD → SRS → UI → Story → Sprint mapping]

### Dependency Graph
[Mermaid diagram from Phase 8C showing new feature in context]

---

## Risks & Mitigation

### High Risks (Score > 15)
[From Phase 8B - Risks sections]

### Medium Risks (Score 8-15)
[From Phase 8B]

### Low Risks (Score < 8)
[From Phase 8B]

**Risk Management Plan**: [Overall strategy]

---

## Next Steps

### Immediate Actions
1. [ ] Share updated PRD/SRS/UI Plan with stakeholders
2. [ ] Schedule sprint planning meeting for S[N]
3. [ ] Resolve blocking dependencies [list]
4. [ ] Provision required resources [list from Phase 3]

### Before Sprint Starts
1. [ ] Complete prerequisite features [list from Phase 3]
2. [ ] Set up infrastructure [if needed]
3. [ ] Assign user stories to team members
4. [ ] Conduct technical spike [if needed from Phase 2]

### During Sprint
1. [ ] Daily standups tracking progress
2. [ ] Mid-sprint backlog refinement
3. [ ] Risk monitoring and mitigation
4. [ ] Dependency coordination

### Sprint Completion
1. [ ] Sprint review and demo
2. [ ] Retrospective
3. [ ] Update velocity metrics
4. [ ] Plan next sprint (if multi-sprint feature)

---

## Approvals

**Product Manager**: [Recommendation from Phase 2A]
**Software Architect**: [Recommendation from Phase 2B]
**UI/UX Designer**: [Recommendation from Phase 2C] (if applicable)
**Scrum Master**: [Recommendation from Phase 2D]
**User**: APPROVED (changes applied)

**Date Approved**: [Today]
**Approved By**: [User name]

---

## Files Modified/Created

### Modified
- ✏️ prd-{product-name}.md (v[X.Y+1])
- ✏️ ux-research-{product-name}.md (v[X.Y+1]) (if applicable)
- ✏️ srs-{product-name}.md (v[X.Y+1])
- ✏️ ui-implementation-{product-name}.md (v[X.Y+1]) (if applicable)
- ✏️ sprints/traceability_matrix.md
- ✏️ sprints/README.md

### Created
- ➕ uxcanvas-prompt-[feature-name].md (if applicable)
- ➕ sprints/sprint_[NN]/sprint_plan.md
[Continue for each sprint file...]
- ➕ feature-addition-summary-[feature-name]-[date].md (this file)

---

## Summary Statistics

- **User Stories Created**: [N]
- **Story Points Added**: [N] points
- **Sprints Added**: [M]
- **PRD Lines Added**: [N]
- **UX Research Lines Added**: [N] (if applicable)
- **SRS Lines Added**: [N]
- **UI Plan Lines Added**: [N] (if applicable)
- **Total Dependencies**: [N]
- **Total Risks Identified**: [N]
- **Timeline Impact**: [+N weeks | None]

---

**Feature Addition Complete** ✅

Next: Execute sprint(s) S[N] through S[N+M-1]
```

**File created**: feature-addition-summary-[feature-name]-[date].md
**Size**: ~15-20KB
```

## Step 10C: Final User Notification

```markdown
## ✅ Feature Addition Complete!

### Summary

**Feature**: [Feature Name]
**Sprint(s)**: S[N] through S[N+M-1]
**Estimated Effort**: [N] story points, [M] sprint(s)

### Files Updated

✅ **PRD**: prd-{product-name}.md (v[X.Y+1])
- Added feature section at L[X]-L[Y]
- +[N] lines

✅ **SRS**: srs-{product-name}.md (v[X.Y+1])
- Added [M] requirements, [P] APIs, [Q] tables
- +[N] lines

✅ **UI Plan**: ui-implementation-{product-name}.md (v[X.Y+1]) (if applicable)
- Added [M] components, [P] screens
- +[N] lines

### Files Created

➕ **UXCanvas Prompt**: uxcanvas-prompt-[feature-name].md (if applicable)
➕ **Sprint Plan(s)**: sprints/sprint_[NN]/sprint_plan.md (×[M])
➕ **Change Summary**: feature-addition-summary-[feature-name]-[date].md

### Traceability Updated

✅ **Traceability Matrix**: sprints/traceability_matrix.md
✅ **Sprint README**: sprints/README.md
✅ **Dependency Graph**: Updated with new feature

### Next Steps

**Immediate**:
1. Review change summary: feature-addition-summary-[feature-name]-[date].md
2. Share updated documents with stakeholders
3. Schedule sprint planning for S[N]

**Before Sprint S[N]**:
- Resolve dependencies: [List]
- Provision resources: [List]
- Assign stories to team

**Sprint Execution**:
- Sprint S[N]: [Goal]
[Continue for each sprint...]

---

Your feature has been successfully added to the project! 🎉
```

---

# EXECUTION SUMMARY

When you invoke this `/add` command, you will:

1. **Gather feature details** from user (problem, user story, metrics, priority, constraints)
2. **Locate existing documents** (PRD, SRS, UI Plan, Sprints)
3. **Classify feature type** (Backend/UI/Full-Stack/Infrastructure) to determine expert involvement
4. **Evaluate with multi-expert system**:
   - Product Manager: RICE, MoSCoW, WSJF, Value/Effort analysis
   - Software Architect: Feasibility, architecture impact, dependencies (conditional)
   - UI/UX Designer: Design consistency, UX impact, components needed (conditional)
   - Scrum Master: Capacity, sprint impact, risks (always)
5. **Analyze impact & dependencies**: Change propagation, technical/feature/resource/UI dependencies, critical path
6. **Estimate with t-shirt sizing**: Complexity assessment, multipliers, story point conversion, user story breakdown
7. **Propose PRD updates**: New feature section, metrics, inventory, changelog with diff preview
8. **Propose SRS updates**: Requirements, APIs, database schema, NFRs, integrations with diff preview
9. **Propose UI Plan updates**: Components, screens, flows, UXCanvas prompt (conditional) with diff preview
10. **Create sprint plan(s)**: Dependency-aware placement, minimal format files, risk assessment
11. **Update traceability**: Requirements matrix, sprint schedule, epic breakdown
12. **Execute approved changes**: Apply all updates, create sprint files
13. **Generate summary report**: Comprehensive change documentation

## Output Files

```
prd-{product}.md                            # Updated (v+1)
srs-{product}.md                            # Updated (v+1)
ui-implementation-{product}.md              # Updated (v+1) (if UI changes)
uxcanvas-prompt-{feature-name}.md          # Created (if UI changes)
sprints/sprint_{NN}/sprint_plan.md          # Created (1+ files)
sprints/traceability_matrix.md              # Updated
sprints/README.md                           # Updated
feature-addition-summary-{feature}-{date}.md # Created
```

## Success Criteria

✅ Feature evaluated by all relevant experts
✅ All dependencies identified and resolved
✅ PRD, SRS, UI Plan updated with new feature
✅ Sprint(s) created in correct dependency order
✅ Traceability maintained (PRD→SRS→UI→Story→Sprint)
✅ Context-optimized files with line references
✅ Complete change summary generated
✅ Ready for sprint planning and execution

---

**END OF /add SLASH COMMAND**
