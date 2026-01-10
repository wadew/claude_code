# Claude Code Configuration Repository

A reference repository containing custom skills and agents for [Claude Code](https://claude.com/claude-code), Anthropic's official CLI tool for software development.

## Overview

This repository serves as a centralized collection of reusable Claude Code configurations, including:

- **Custom Agents**: Specialized AI agents with domain-specific expertise
- **Skills**: Advanced workflow frameworks and best practice templates

## Repository Structure

```
gh_claude_code/
├── claude_agents/              # Custom agent configurations
│   ├── security-expert.md
│   ├── jwt-expert.md
│   ├── gitlab-cicd-expert.md
│   ├── test-orchastrator.md
│   ├── sprint-worker.md        # Sprint task executor
│   └── tdd-modular-architect.md # TDD workflow expert
├── claude_commands/            # SDLC workflow commands
│   ├── project/                # Specification commands
│   │   ├── constitution.md     # Project principles
│   │   ├── prd.md              # Product requirements
│   │   ├── srs.md              # Technical design
│   │   ├── scrum.md            # Task breakdown
│   │   ├── validate.md         # Spec validation
│   │   ├── ux.md               # UX specification
│   │   ├── ui.md               # UI implementation plan
│   │   ├── add.md              # Feature addition
│   │   ├── audit.md            # Spec audit
│   │   ├── migrate.md          # Format migration
│   │   └── prd_signoff.md      # PRD sign-off
│   └── session/                # Sprint execution commands
│       ├── init.md             # Project initialization
│       ├── plan.md             # Task graph creation
│       ├── implement.md        # Sequential execution
│       ├── parallel.md         # Parallel execution
│       └── end.md              # Sprint closeout
├── claude_skills/              # Skill documents and frameworks
│   ├── threat-modeling-expert.md
│   └── project-initialization-skill.md
├── LICENSE
└── README.md
```

## Available Agents

### Security Expert
**Location**: `claude_agents/security-expert.md`

A comprehensive security specialist with expertise in:
- Static Application Security Testing (SAST)
- Software Composition Analysis (SCA)
- Container security (Docker, Kubernetes)
- Infrastructure security (IaC, cloud platforms)
- OWASP Top 10 vulnerabilities
- Security tooling (OWASP ZAP, Semgrep, Trivy, Falco)

**Use Cases**: Security audits, vulnerability assessment, code review, secure architecture design

### JWT Expert
**Location**: `claude_agents/jwt-expert.md`

Specialized agent for JWT (JSON Web Token) implementation and security:
- JWT creation, validation, and management
- Token security best practices
- Authentication system design
- Vulnerability analysis and remediation

**Use Cases**: Authentication implementation, JWT security audits, token lifecycle management

### GitLab CI/CD Expert
**Location**: `claude_agents/gitlab-cicd-expert.md`

Expert GitLab CI/CD engineer specializing in pipeline optimization and deployment automation:
- GitLab CI/CD pipeline architecture and YAML configuration
- Docker BuildKit and rootless container builds
- Security scanning (SAST, container scanning, DAST, IaC)
- Caching strategies and DAG pipeline optimization
- Multi-environment deployments and GitOps workflows
- Blue-green deployments and canary releases

**Use Cases**: Pipeline optimization, security scanning setup, container builds, deployment automation, GitLab CI/CD best practices

### Test Orchestrator
**Location**: `claude_agents/test-orchastrator.md`

TDD expert guiding comprehensive test coverage through incremental development:
- Test-Driven Development (TDD) workflow guidance
- Incremental test creation (happy path → validation → edge cases)
- Pytest fixture organization and test structure
- Test file organization and naming conventions
- Mock and integration testing strategies

**Use Cases**: TDD implementation, test suite creation, test coverage improvement, test structure guidance

### Sprint Worker
**Location**: `claude_agents/sprint-worker.md`

Specialized agent for executing individual sprint tasks with strict TDD workflow:
- Red-Green-Refactor cycle execution
- Context management and task isolation
- GitLab issue integration
- Quality gates (80% coverage, 100% pass rate)
- Checkpoint creation for context recovery

**Use Cases**: Used by `/session:parallel` for concurrent worker processes, individual task execution with TDD

### TDD Modular Architect
**Location**: `claude_agents/tdd-modular-architect.md`

Expert in Test-Driven Development for modular architectures and component-based systems:
- Test-first development methodology
- Modular architecture design patterns
- Red-Green-Refactor workflow guidance
- Test suite architecture for microservices
- Component isolation and integration testing strategies

**Use Cases**: TDD implementation, modular architecture design, test strategy planning, component-based system development

## SDLC Workflow Commands

This repository includes a comprehensive set of commands for managing the full Software Development Lifecycle using the **spec-kit methodology**.

### Spec-Kit Directory Structure

All specifications are stored in a `.specify/` directory:

```
.specify/
├── memory/
│   └── constitution.md           # Project principles and standards
└── specs/
    └── {feature-name}/
        ├── spec.md               # Product requirements (PRD)
        ├── plan.md               # Implementation plan (SRS)
        ├── data-model.md         # Database schemas
        ├── contracts/
        │   └── rest-api.yaml     # API specifications
        ├── tasks.md              # Sprint task breakdown
        ├── research.md           # Technology investigation
        └── quickstart.md         # Validation scenarios
```

### Workflow Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                      SPECIFICATION PHASE                             │
│  /project:constitution → /project:prd → /project:srs → /project:scrum │
└─────────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────┐
│                       EXECUTION PHASE                                │
│   /session:init → /session:plan → /session:implement OR parallel     │
└─────────────────────────────────────────────────────────────────────┘
                                  ↓
┌─────────────────────────────────────────────────────────────────────┐
│                       CLOSEOUT PHASE                                 │
│                        /session:end                                  │
└─────────────────────────────────────────────────────────────────────┘
```

### Project Commands

Commands for creating long-lived specification artifacts.

| Command | Description | Output |
|---------|-------------|--------|
| `/project:constitution` | Establish project principles, code standards, and forbidden patterns | `.specify/memory/constitution.md` |
| `/project:prd` | Create Product Requirements Document following spec-kit methodology | `.specify/specs/{feature}/spec.md` |
| `/project:srs` | Generate Implementation Plan and Technical Design Specification | `plan.md`, `data-model.md`, `contracts/` |
| `/project:scrum` | Generate sprint-ready task breakdown from implementation plan | `.specify/specs/{feature}/tasks.md` |
| `/project:validate` | Validate specifications against project constitution | Validation report |
| `/project:ux` | Create UX specification and research document | UX research document |
| `/project:ui` | Create UI implementation plan from UXCanvas designs | `ui-implementation-*.md` |
| `/project:add` | Add feature with multi-expert evaluation (PM, Architect, UX, Scrum) | Updated documentation |
| `/project:audit` | Audit specifications for completeness and consistency | Audit report |
| `/project:migrate` | Convert legacy document format to spec-kit structure | Updated directory structure |
| `/project:prd_signoff` | PRD sign-off workflow with stakeholder approval | Sign-off documentation |

### Session Commands

Commands for sprint execution and session management.

| Command | Description | Key Features |
|---------|-------------|--------------|
| `/session:init` | Initialize project for AI-assisted development | Directory structure, CLAUDE.md, git setup, module registry |
| `/session:plan` | Create sprint task graph with dependencies | DAG generation, critical path analysis, prerequisite validation |
| `/session:implement` | Sequential task execution with TDD workflow | Red-Green-Refactor, checkpoint/resume, `--start-from TASK-ID` |
| `/session:parallel` | Parallel execution with git worktrees | 3-5 concurrent workers, task queue, context exhaustion detection |
| `/session:end` | Sprint closeout with validation gates | 80% coverage gate, test quality validation, documentation |

#### Session Command Arguments

**`/session:implement`**:
```
/session:implement [sprint-number] [--resume] [--dry-run] [--skip-gitlab] [--start-from TASK-ID]
```

**`/session:parallel`**:
```
/session:parallel [sprint-number] [--dry-run] [--max-workers N] [--resume] [--cleanup]
```

## Available Skills

### Threat Modeling Expert
**Location**: `claude_skills/threat-modeling-expert.md`

Framework for comprehensive threat modeling and security analysis.

**Use Cases**: Application security design, threat identification, risk assessment

### Project Initialization
**Location**: `claude_skills/project-initialization-skill.md`

A comprehensive framework for initializing software projects with Claude Code, implementing 2025 best practices including:
- Test-Driven Development (TDD) methodology
- Multi-agent orchestration
- Session management protocols
- Phase decomposition strategies
- MCP server integration

**Use Cases**: Starting new projects, establishing development workflows, implementing best practices

## Usage

### Using Agents

1. **Copy Agent File**: Copy the desired agent markdown file to your project's `.claude/agents/` directory
   ```bash
   cp claude_agents/security-expert.md /path/to/your/project/.claude/agents/
   ```

2. **Invoke in Claude Code**: Use the agent within Claude Code sessions
   ```
   "Can you review this code for security vulnerabilities using the security-expert agent?"
   ```

### Using SDLC Commands

1. **Copy Commands**: Copy the command directories to your project's `.claude/commands/` directory
   ```bash
   cp -r claude_commands/ /path/to/your/project/.claude/commands/
   ```

2. **Typical Workflow**:
   ```bash
   # 1. Initialize a new project
   /session:init

   # 2. Create project constitution (first time only)
   /project:constitution

   # 3. Create feature specification
   /project:prd

   # 4. Generate implementation plan
   /project:srs

   # 5. Create sprint tasks
   /project:scrum

   # 6. Plan the sprint
   /session:plan

   # 7. Execute tasks (choose one)
   /session:implement              # Sequential execution
   /session:parallel --max-workers 3  # Parallel execution

   # 8. Close out the sprint
   /session:end
   ```

3. **Resume Interrupted Work**:
   ```bash
   /session:implement --resume
   /session:implement --start-from TASK-003
   ```

### Using Skills

1. **Copy Skill File**: Copy the skill document to your project's `.claude/skills/` directory
   ```bash
   cp claude_skills/project-initialization-skill.md /path/to/your/project/.claude/skills/
   ```

2. **Reference in Sessions**: Invoke skills using the `/` command or reference them in prompts
   ```
   /project-initialization
   ```

3. **Adapt to Your Needs**: Customize skills based on your project requirements

## Creating Custom Configurations

### Agent Structure

Agents should follow this format:

```markdown
---
name: Agent Name
description: Brief description of agent capabilities
---

# Agent Title

## Core Competencies
[Detailed expertise areas]

## Working Approach
[How the agent operates]

## Communication Guidelines
[How the agent should communicate]
```

### Skill Structure

Skills should include:

```markdown
---
name: skill-name
description: Brief description of what the skill provides
---

# Skill Title

## Overview
[Purpose and scope]

## Implementation
[Detailed guidelines and procedures]

## Usage
[How to apply the skill]
```

## Best Practices

1. **Version Control**: Keep your configurations in version control
2. **Documentation**: Maintain clear descriptions and usage examples
3. **Modularity**: Create focused agents and skills for specific domains
4. **Testing**: Validate configurations in real projects before sharing
5. **Updates**: Regularly update based on new Claude Code features

## Learning More

- [Claude Code Documentation](https://docs.claude.com/claude-code)
- [Claude Code GitHub](https://github.com/anthropics/claude-code)

## License

This repository is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

Contributions are welcome! If you have useful agents or skills to share:

1. Ensure configurations follow the established format
2. Include clear documentation and use cases
3. Test thoroughly before submitting
4. Submit a pull request with a clear description

---

**Note**: This is a personal reference repository. Configurations are provided as-is and should be adapted to your specific needs and security requirements.
