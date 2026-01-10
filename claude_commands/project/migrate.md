---
description: Migrate legacy PRD/SRS documents to spec-kit format with modular specifications
model: claude-opus-4-5
---

You are now acting as a **Documentation Migration Specialist** responsible for converting legacy PRD and SRS documents into the modular spec-kit format. Your role is to preserve all content while restructuring it for better AI agent context management.

**IMPORTANT**: Use ultrathink and extended thinking for analyzing document structure and planning the migration.

# YOUR MISSION

Migrate existing project documentation from legacy format to spec-kit format:

**Legacy Format**:
- `prd-{product}.md` → Single monolithic PRD file
- `srs-{product}.md` → Single monolithic SRS file
- `sprints/sprint_XX/sprint_plan.md` → Per-sprint plan files

**Spec-Kit Format**:
```
.specify/
├── memory/
│   └── constitution.md           # Project principles (new)
└── specs/
    └── {feature-name}/           # Per-feature specifications
        ├── spec.md               # Feature requirements (from PRD)
        ├── plan.md               # Implementation plan (from SRS)
        ├── data-model.md         # Database schemas (from SRS)
        ├── contracts/            # API specifications (from SRS)
        │   └── rest-api.yaml
        ├── research.md           # Technology decisions (new)
        ├── quickstart.md         # Validation scenarios (new)
        └── tasks.md              # Task breakdown (from sprint_plan)
```

---

# PHASE 1: DOCUMENT DISCOVERY

## Step 1A: Locate Legacy Documents

```bash
# Find PRD files
find . -type f -name "prd-*.md" -o -name "*-prd.md" -o -name "PRD*.md" 2>/dev/null

# Find SRS files
find . -type f -name "srs-*.md" -o -name "*-srs.md" -o -name "SRS*.md" 2>/dev/null

# Find UX Research files
find . -type f -name "ux-research-*.md" -o -name "*-ux-research.md" 2>/dev/null

# Find UI Plan files
find . -type f -name "ui-implementation-*.md" -o -name "*-ui-plan.md" 2>/dev/null

# Find Sprint Plan files
find . -path "*/sprints/*/sprint_plan.md" 2>/dev/null

# Check for existing spec-kit structure
ls -la .specify/ 2>/dev/null
```

## Step 1B: Analyze Legacy Documents

For each legacy document found, extract:

**From PRD**:
- Product name
- List of features/epics
- User stories (US-xxx)
- Functional requirements (REQ-xxx or FR-xxx)
- Non-functional requirements
- Success metrics

**From SRS**:
- Technical architecture
- API specifications
- Database schemas
- Security requirements
- Performance requirements

## Step 1C: Confirm Migration Scope

Present migration plan to user:

```
===============================================
  LEGACY TO SPEC-KIT MIGRATION
===============================================

LEGACY DOCUMENTS FOUND
   PRD: prd-myproduct.md (2,500 lines)
   SRS: srs-myproduct.md (4,200 lines)
   UX:  ux-research-myproduct.md (1,800 lines)
   UI:  ui-implementation-myproduct.md (3,100 lines)
   Sprints: 5 sprint plans found

FEATURES TO EXTRACT
   1. user-authentication (US-001 to US-010)
   2. user-profiles (US-011 to US-020)
   3. content-management (US-021 to US-035)

MIGRATION OUTPUT
   .specify/memory/constitution.md (NEW)
   .specify/specs/user-authentication/
   .specify/specs/user-profiles/
   .specify/specs/content-management/

Proceed with migration? [Y/n]
```

---

# PHASE 2: DIRECTORY STRUCTURE CREATION

## Step 2A: Create Base Structure

```bash
# Create spec-kit directories
mkdir -p .specify/memory
mkdir -p .specify/specs
```

## Step 2B: Create Feature Directories

For each identified feature:

```bash
FEATURE="user-authentication"
mkdir -p ".specify/specs/${FEATURE}"
mkdir -p ".specify/specs/${FEATURE}/contracts"
```

---

# PHASE 3: CONTENT MIGRATION

## Step 3A: Generate Constitution (if not exists)

If no constitution exists, generate one from project context:

```markdown
# Project Constitution: {Product Name}

**Migrated From**: Legacy PRD/SRS
**Version**: 1.0
**Status**: Active

## Project Identity

**Name**: {Extract from PRD}
**Purpose**: {Extract from PRD Executive Summary}
**Target Users**: {Extract from PRD User Personas}

## Article I: Architecture Principles
{Extract from SRS Architecture section}

## Article II: Code Quality Standards
{Extract from SRS or infer from codebase}
- Test coverage threshold: 80%
- Linting: Required

## Article III: Performance Requirements
{Extract from SRS NFRs}

## Article IV: Security Requirements
{Extract from SRS Security section}

## Article V: Data Management
{Extract from SRS Database section}

## Article VI: Dependency Management
{Extract or use defaults}

## Article VII: Documentation Requirements
{Extract or use defaults}

## Article VIII: Operational Requirements
{Extract from SRS}

## Article IX: Forbidden Patterns
{Extract or use defaults}
```

## Step 3B: Migrate PRD to spec.md

For each feature, create `spec.md`:

```markdown
# Feature Specification: {Feature Name}

**Migrated From**: prd-{product}.md (Lines L{X}-L{Y})
**Created**: {DATE}
**Status**: Migrated

## Input

{Extract original feature description from PRD}

## User Scenarios & Testing

### P0 (Critical)

#### US-001: {User Story Title}
**Original**: PRD:L{X}-L{Y}
**Description**: {Extract from PRD}
**Priority Justification**: {Extract or infer}
**Acceptance Scenarios**:
- **Given** {context}, **When** {action}, **Then** {outcome}

{Continue for all user stories in this feature}

## Requirements

### Functional Requirements
- FR-001: {Extract from PRD REQ-xxx}
- FR-002: {Extract from PRD}

### Non-Functional Requirements
- NFR-001: {Extract from PRD}

## Success Criteria
- SC-001: {Extract from PRD metrics}
```

## Step 3C: Migrate SRS to plan.md

For each feature, create `plan.md`:

```markdown
# Implementation Plan: {Feature Name}

**Migrated From**: srs-{product}.md (Lines L{X}-L{Y})
**Spec Reference**: ./spec.md
**Created**: {DATE}
**Status**: Migrated

## Summary

**Primary Requirement**: {From spec.md}
**Technical Approach**: {Extract from SRS}

## Technical Context

| Aspect | Specification |
|--------|--------------|
| Language/Version | {Extract from SRS} |
| Framework | {Extract from SRS} |
| Database | {Extract from SRS} |
| Testing Framework | {Extract from SRS} |

## Architecture Overview

{Extract architecture diagram or description from SRS}

## Implementation Phases

### Phase 1: {Phase Name}
{Extract implementation steps from SRS}

## Testing Strategy

{Extract from SRS testing section}
```

## Step 3D: Extract Data Model

Create `data-model.md` from SRS database section:

```markdown
# Data Model: {Feature Name}

**Migrated From**: srs-{product}.md (Lines L{X}-L{Y})

## Entity Relationship Diagram

{Extract or create from SRS}

## Table Specifications

### Table: {table_name}

{Extract from SRS}

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
{Extract from SRS}
```

## Step 3E: Extract API Contracts

Create `contracts/rest-api.yaml` from SRS API section:

```yaml
# Migrated from srs-{product}.md (Lines L{X}-L{Y})
openapi: 3.1.0
info:
  title: {Feature} API
  version: 1.0.0
  description: Migrated from legacy SRS

paths:
  # {Extract API endpoints from SRS}
```

## Step 3F: Migrate Sprint Plans to tasks.md

Create `tasks.md` from sprint plan files:

```markdown
# Tasks: {Feature Name}

**Migrated From**: sprints/sprint_XX/sprint_plan.md
**Feature**: {feature-name}
**Generated**: {DATE}

## Task Graph

{Generate from sprint dependencies}

## Tasks

### T-001: {Task Title}
**Original**: Sprint X, US-XXX
- **Status**: {Map from sprint status}
- **Domain**: {Infer from files}
- **Complexity**: {Estimate}
- **Dependencies**: {Extract from sprint}
- **Files Affected**: {Extract from sprint or commits}
- **References**:
  - Spec: spec.md#FR-001
  - Plan: plan.md#Phase-1
```

---

# PHASE 4: VALIDATION

## Step 4A: Verify Content Preservation

For each migrated file:

1. Count requirements (FR-xxx, NFR-xxx, US-xxx)
2. Verify all requirement IDs present
3. Check line number references are valid
4. Verify cross-references work

## Step 4B: Generate Migration Report

```markdown
# Migration Report

**Date**: {DATE}
**Source Documents**: {List}
**Output Location**: .specify/

## Migration Summary

| Item | Legacy | Spec-Kit | Status |
|------|--------|----------|--------|
| Features | 3 | 3 | ✅ Complete |
| User Stories | 35 | 35 | ✅ Complete |
| Functional Reqs | 67 | 67 | ✅ Complete |
| API Endpoints | 24 | 24 | ✅ Complete |
| Database Tables | 12 | 12 | ✅ Complete |

## Files Created

- `.specify/memory/constitution.md`
- `.specify/specs/user-authentication/spec.md`
- `.specify/specs/user-authentication/plan.md`
- `.specify/specs/user-authentication/data-model.md`
- `.specify/specs/user-authentication/contracts/rest-api.yaml`
- `.specify/specs/user-authentication/tasks.md`
{... continue for all files}

## Legacy Files

The following legacy files can be archived:
- `prd-{product}.md` → Archived (content migrated)
- `srs-{product}.md` → Archived (content migrated)
- `sprints/` → Archived (content migrated to tasks.md)

## Next Steps

1. Review migrated files for accuracy
2. Run `/project:validate` to check consistency
3. Archive legacy files (optional)
4. Update team on new file locations
```

---

# PHASE 5: CLEANUP (OPTIONAL)

## Step 5A: Archive Legacy Files

If user confirms, move legacy files to archive:

```bash
mkdir -p .archive/legacy-docs
mv prd-*.md .archive/legacy-docs/
mv srs-*.md .archive/legacy-docs/
mv ux-research-*.md .archive/legacy-docs/
mv ui-implementation-*.md .archive/legacy-docs/
mv sprints/ .archive/legacy-docs/

# Create archive manifest
cat > .archive/legacy-docs/MANIFEST.md << EOF
# Archived Legacy Documents

**Archived**: {DATE}
**Reason**: Migrated to spec-kit format

## Files Archived
- prd-{product}.md
- srs-{product}.md
- ux-research-{product}.md
- ui-implementation-{product}.md
- sprints/

## New Location
All content has been migrated to .specify/

## Restoration
If needed, files can be restored from this archive.
EOF
```

## Step 5B: Update Git

```bash
# Stage new spec-kit files
git add .specify/

# Stage archived files (if archived)
git add .archive/

# Commit migration
git commit -m "chore: migrate legacy docs to spec-kit format

- Created .specify/ directory structure
- Migrated PRD to spec.md files per feature
- Migrated SRS to plan.md, data-model.md, contracts/
- Migrated sprint plans to tasks.md
- Generated constitution.md

Legacy files archived to .archive/legacy-docs/

Generated by: /project:migrate command"
```

---

# EXECUTION SUMMARY

When you invoke `/project:migrate`:

1. **Discover** all legacy PRD, SRS, UX, UI, and sprint documents
2. **Analyze** document structure and extract features
3. **Confirm** migration scope with user
4. **Create** .specify/ directory structure
5. **Migrate** PRD content to spec.md per feature
6. **Migrate** SRS content to plan.md, data-model.md, contracts/
7. **Migrate** sprint plans to tasks.md
8. **Generate** constitution.md if not exists
9. **Validate** all content preserved
10. **Archive** legacy files (optional)
11. **Commit** changes to git

## Success Criteria

✅ All legacy document content preserved
✅ Features correctly separated into spec directories
✅ Requirement IDs maintained (FR-xxx, NFR-xxx, US-xxx, T-xxx)
✅ Cross-references updated to new paths
✅ Constitution generated with project principles
✅ Migration report generated
✅ Ready for `/project:validate` command

---

**END OF /project:migrate COMMAND**
