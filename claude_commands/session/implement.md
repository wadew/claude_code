---
description: Execute sprint tasks sequentially from task graph with TDD workflow
---

# SEQUENTIAL SPRINT IMPLEMENTATION

You are executing a sprint's tasks **sequentially** from a pre-generated task graph. This command is the simpler alternative to `/session:parallel` - execute tasks one at a time with full context and easier debugging.

## ARGUMENTS

```
/session:implement [sprint-number] [--resume] [--dry-run] [--skip-gitlab] [--start-from TASK-ID]
```

- `sprint-number`: Sprint to execute (e.g., `5` for sprint 5). Default: detect from `state/current_state.md`
- `--resume`: Resume from last checkpoint (reads `execution_checkpoint.json`)
- `--dry-run`: Show execution plan without running tasks
- `--start-from`: Start from a specific task ID (skips prior tasks)
- `--skip-gitlab`: Don't create/update GitLab issues

---

# PHASE 6: LOAD TASK GRAPH

## Step 6A: Locate Task Graph

### Spec-Kit Format (Preferred)

```python
def locate_task_graph(feature_name=None, sprint_number=None):
    """Find the task graph file, preferring spec-kit format."""

    # First, check for spec-kit tasks.md files
    spec_kit_paths = glob.glob(".specify/specs/*/tasks.md")

    if spec_kit_paths:
        if feature_name:
            # Look for specific feature
            feature_path = f".specify/specs/{feature_name}/tasks.md"
            if os.path.exists(feature_path):
                return ("spec-kit", feature_path)
        elif len(spec_kit_paths) == 1:
            # Single feature, use it
            return ("spec-kit", spec_kit_paths[0])
        else:
            # Multiple features, need to select
            print("Multiple features found:")
            for i, path in enumerate(spec_kit_paths):
                feature = path.split("/")[2]
                print(f"  {i+1}. {feature}")
            print("\nSpecify feature: /session:implement --feature {name}")
            return None

    # Fallback to legacy format
    legacy_paths = [
        f"sprints/sprint_{sprint_number:02d}/task_graph.json" if sprint_number else None,
        f"sprints/sprint_{sprint_number}/task_graph.json" if sprint_number else None,
        "state/task_graph.json"
    ]
    for path in [p for p in legacy_paths if p]:
        if os.path.exists(path):
            print(f"ℹ️ Using legacy task graph format: {path}")
            print("   Consider running /project:scrum to generate tasks.md")
            return ("legacy", path)

    raise FileNotFoundError(
        "Task graph not found.\n"
        "  - For spec-kit: Run /project:scrum to generate .specify/specs/{feature}/tasks.md\n"
        "  - For legacy: Run /session:plan to generate task_graph.json"
    )
```

### Spec-Kit tasks.md Parsing

```python
def parse_spec_kit_tasks(tasks_md_path):
    """Parse spec-kit tasks.md file into task graph structure."""
    with open(tasks_md_path) as f:
        content = f.read()

    tasks = {}
    current_task = None

    # Parse task blocks (T-XXX format)
    task_pattern = r"### (T-\d+): (.+)"
    for match in re.finditer(task_pattern, content):
        task_id = match.group(1)
        title = match.group(2)
        # Extract task details from following lines
        tasks[task_id] = {
            "id": task_id,
            "title": title,
            "status": "pending",  # Parse from content
            "domain": "",         # Parse from content
            "complexity": "",     # Parse from content
            "dependencies": [],   # Parse from content
            "estimated_hours": 0, # Parse from content
            "files_affected": [], # Parse from content
            "acceptance_criteria": [],
            "tests": [],
            "references": []
        }

    return {"format": "spec-kit", "tasks": tasks}
```

**CRITICAL**: If no task graph exists, STOP and inform user:
```
❌ No task graph found.

For spec-kit format:
  Run /project:scrum to generate .specify/specs/{feature}/tasks.md

For legacy format:
  Run /session:plan to generate task_graph.json
```

## Step 6B: Parse and Validate Task Graph

```python
def load_task_graph(path):
    """Load and validate task graph JSON."""
    with open(path) as f:
        graph = json.load(f)

    # Validate schema version
    if graph.get("version") != "1.0.0":
        raise ValueError(f"Unsupported task graph version: {graph.get('version')}")

    # Validate no cycles (should already be validated, but double-check)
    validate_dag(graph["tasks"])

    # Build execution order
    execution_order = topological_sort_with_priority(graph)

    return graph, execution_order

def topological_sort_with_priority(graph):
    """
    Sort tasks respecting dependencies, prioritizing:
    1. Critical path tasks
    2. Tasks that unblock the most dependents
    3. Lower parallel group number
    4. Alphabetical by ID
    """
    tasks = graph["tasks"]
    critical_path = set(graph.get("critical_path", {}).get("tasks", []))

    # Kahn's algorithm with priority queue
    in_degree = {tid: len(t["dependencies"]) for tid, t in tasks.items()}
    ready = []

    for tid, degree in in_degree.items():
        if degree == 0:
            task = tasks[tid]
            priority = (
                0 if tid in critical_path else 1,  # Critical path first
                -len(task.get("dependents", [])),   # More dependents = higher priority
                task.get("parallel_group", 999),    # Lower group first
                tid                                  # Alphabetical tiebreaker
            )
            heapq.heappush(ready, (priority, tid))

    order = []
    while ready:
        _, tid = heapq.heappop(ready)
        order.append(tid)

        for dep_tid in tasks[tid].get("dependents", []):
            in_degree[dep_tid] -= 1
            if in_degree[dep_tid] == 0:
                task = tasks[dep_tid]
                priority = (
                    0 if dep_tid in critical_path else 1,
                    -len(task.get("dependents", [])),
                    task.get("parallel_group", 999),
                    dep_tid
                )
                heapq.heappush(ready, (priority, dep_tid))

    return order
```

## Step 6C: Check for Resume State

```python
def load_checkpoint(sprint_dir):
    """Load checkpoint if --resume flag is set."""
    checkpoint_path = f"{sprint_dir}/execution_checkpoint.json"
    if os.path.exists(checkpoint_path):
        with open(checkpoint_path) as f:
            return json.load(f)
    return None

# Checkpoint structure
checkpoint = {
    "saved_at": "2025-01-15T10:30:00Z",
    "sprint_id": "05",
    "current_index": 3,
    "next_task": "T-004",
    "completed_tasks": ["T-001", "T-002", "T-003"],
    "failed_tasks": [],
    "skipped_tasks": [],
    "gitlab_issues": {"T-001": 42, "T-002": 43, "T-003": 44}
}
```

## Step 6D: Display Execution Plan

Show the user what will be executed:

```markdown
## Execution Plan - Sprint {N}

**Task Graph**: sprints/sprint_05/task_graph.json
**Tasks**: {TOTAL} total, {REMAINING} remaining
**Resume**: {Yes (from T-004) | No (fresh start)}
**Critical Path**: {PATH_LENGTH}h estimated

### Execution Order

| # | Task ID | Title | Domain | Est. Tokens | Critical |
|---|---------|-------|--------|-------------|----------|
| 1 | T-001 | Create user model | backend | 25K | ✓ |
| 2 | T-002 | Add API endpoint | backend | 30K | ✓ |
| 3 | T-003 | Write unit tests | tests | 20K | |
| 4 | T-004 | Frontend component | frontend | 35K | |

**Note**: Tasks will execute in dependency order. Each task follows TDD workflow.
```

If `--dry-run` is set, STOP here after displaying the plan.

---

# PHASE 7: SEQUENTIAL TASK EXECUTION

## Step 7A: Initialize Execution State

```python
def init_execution_state(graph, execution_order, checkpoint=None):
    """Initialize or restore execution state."""
    if checkpoint:
        start_index = checkpoint["current_index"]
        completed = set(checkpoint["completed_tasks"])
        failed = set(checkpoint["failed_tasks"])
        skipped = set(checkpoint["skipped_tasks"])
        gitlab_issues = checkpoint.get("gitlab_issues", {})
    else:
        start_index = 0
        completed = set()
        failed = set()
        skipped = set()
        gitlab_issues = {}

    return {
        "start_index": start_index,
        "completed": completed,
        "failed": failed,
        "skipped": skipped,
        "gitlab_issues": gitlab_issues,
        "current_task": None,
        "started_at": datetime.utcnow().isoformat()
    }
```

## Step 7B: Task Execution Loop

For each task in execution order:

```python
for index, task_id in enumerate(execution_order[state["start_index"]:], start=state["start_index"]):
    task = graph["tasks"][task_id]
    state["current_task"] = task_id

    # 1. Display task header
    print(f"\n{'='*60}")
    print(f"TASK {index+1}/{len(execution_order)}: {task_id}")
    print(f"Title: {task['title']}")
    print(f"Domain: {task['domain']} | Complexity: {task['complexity']}")
    print(f"Estimated: {task['estimated_tokens']/1000:.0f}K tokens, {task['estimated_hours']}h")
    print(f"{'='*60}\n")

    # 2. Create/update GitLab issue (if not --skip-gitlab)
    if not skip_gitlab:
        issue_iid = create_or_update_gitlab_issue(task, "in-progress")
        state["gitlab_issues"][task_id] = issue_iid

    # 3. Execute task using TDD workflow
    result = execute_task_tdd(task)

    # 4. Handle result
    if result["status"] == "success":
        state["completed"].add(task_id)
        if not skip_gitlab:
            update_gitlab_issue(task_id, "done")
        print(f"✅ Task {task_id} completed successfully")

    elif result["status"] == "failed":
        # Offer options to user
        action = handle_task_failure(task_id, result["error"])
        if action == "retry":
            # Re-run current task
            continue
        elif action == "skip":
            state["skipped"].add(task_id)
            if not skip_gitlab:
                update_gitlab_issue(task_id, "skipped")
        elif action == "abort":
            save_checkpoint(state, index)
            raise ExecutionAborted(f"Aborted at task {task_id}")

    # 5. Save checkpoint after each task
    save_checkpoint(state, index + 1)
```

## Step 7C: TDD Task Execution Workflow

Each task follows the Test-Driven Development pattern:

```python
def execute_task_tdd(task):
    """Execute a single task using TDD workflow."""

    # Phase 1: RED - Write failing tests first
    print(f"📝 Phase 1/3: Writing tests for {task['id']}...")

    if task.get("test_files"):
        for test_file in task["test_files"]:
            # Write or modify test file based on acceptance criteria
            write_tests_for_task(task, test_file)

    # Verify tests fail (they should, since implementation doesn't exist)
    test_result = run_tests(task["test_pattern"])
    if test_result["passed"]:
        print("⚠️ Warning: Tests passed before implementation - check test coverage")

    # Phase 2: GREEN - Implement to pass tests
    print(f"🔨 Phase 2/3: Implementing {task['id']}...")

    for file_info in task["files_affected"]:
        if file_info["operation"] == "create":
            create_implementation_file(file_info["path"], task)
        elif file_info["operation"] == "modify":
            modify_implementation_file(file_info["path"], task)

    # Verify tests pass
    test_result = run_tests(task["test_pattern"])
    if not test_result["passed"]:
        return {
            "status": "failed",
            "error": f"Tests failed after implementation:\n{test_result['output']}"
        }

    # Phase 3: REFACTOR - Clean up while keeping tests green
    print(f"✨ Phase 3/3: Refactoring {task['id']}...")

    # Run linting
    lint_result = run_linting(task["files_affected"])
    if lint_result["errors"]:
        fix_lint_errors(lint_result["errors"])

    # Run type checking (if applicable)
    type_result = run_type_check(task["files_affected"])
    if type_result["errors"]:
        fix_type_errors(type_result["errors"])

    # Final test run to ensure refactoring didn't break anything
    final_result = run_tests(task["test_pattern"])
    if not final_result["passed"]:
        return {
            "status": "failed",
            "error": f"Tests failed after refactoring:\n{final_result['output']}"
        }

    return {"status": "success", "coverage": final_result.get("coverage", 0)}
```

## Step 7D: GitLab Issue Management

```python
def create_or_update_gitlab_issue(task, status):
    """Create GitLab issue for task or update existing."""
    project_id = get_project_id()
    sprint_id = task.get("sprint_id", "XX")

    # Check if issue already exists
    existing = find_issue_by_title(
        project_id,
        f"[Sprint {sprint_id}] {task['id']}: {task['title']}"
    )

    if existing:
        # Update existing issue
        update_issue(
            project_id,
            existing["iid"],
            labels=get_labels_for_status(status)
        )
        return existing["iid"]

    # Create new issue
    issue = create_issue(
        project_id=project_id,
        title=f"[Sprint {sprint_id}] {task['id']}: {task['title']}",
        description=format_issue_description(task),
        labels=[
            f"sprint-{sprint_id}",
            task["domain"],
            status,
            "sequential-execution"
        ]
    )
    return issue["iid"]

def format_issue_description(task):
    """Format GitLab issue description from task."""
    return f"""
## Task Context
{task['description']}

## Acceptance Criteria
{chr(10).join(f"- [ ] {ac}" for ac in task['acceptance_criteria'])}

## Technical Details
- **Domain**: {task['domain']}
- **Complexity**: {task['complexity']}
- **Estimated Tokens**: {task['estimated_tokens']:,}
- **Estimated Hours**: {task['estimated_hours']}
- **Critical Path**: {'Yes' if task.get('on_critical_path') else 'No'}

## Dependencies
{chr(10).join(f"- {dep}" for dep in task['dependencies']) or 'None'}

## Files Affected
{chr(10).join(f"- `{f['path']}` ({f['operation']})" for f in task['files_affected'])}

## References
- SRS: {task.get('srs_ref', 'N/A')}
- UI: {task.get('ui_ref', 'N/A')}

---
*Executed via `/session:implement` (sequential execution)*
"""
```

## Step 7E: Failure Handling

When a task fails, present options to the user:

```python
def handle_task_failure(task_id, error):
    """Handle task failure with user options."""
    print(f"\n❌ Task {task_id} failed:")
    print(f"   {error}")
    print()
    print("Options:")
    print("  [R]etry  - Attempt the task again")
    print("  [S]kip   - Skip this task and continue")
    print("  [A]bort  - Stop execution and save checkpoint")
    print()

    # Use AskUserQuestion tool
    response = ask_user_question(
        question="How would you like to proceed?",
        options=[
            {"label": "Retry", "description": "Attempt the task again"},
            {"label": "Skip", "description": "Skip this task and continue with remaining"},
            {"label": "Abort", "description": "Stop execution and save checkpoint for later"}
        ]
    )

    return response.lower()
```

**CRITICAL**: On failure, always:
1. Preserve the error context
2. Save a checkpoint before any destructive action
3. Allow the user to choose the path forward
4. Never silently skip failed tasks

## Step 7F: Checkpoint Management

```python
def save_checkpoint(state, next_index):
    """Save execution checkpoint for resumption."""
    checkpoint = {
        "saved_at": datetime.utcnow().isoformat(),
        "sprint_id": state["sprint_id"],
        "current_index": next_index,
        "next_task": execution_order[next_index] if next_index < len(execution_order) else None,
        "completed_tasks": list(state["completed"]),
        "failed_tasks": list(state["failed"]),
        "skipped_tasks": list(state["skipped"]),
        "gitlab_issues": state["gitlab_issues"]
    }

    checkpoint_path = f"sprints/sprint_{state['sprint_id']}/execution_checkpoint.json"
    with open(checkpoint_path, "w") as f:
        json.dump(checkpoint, f, indent=2)

    print(f"💾 Checkpoint saved: {checkpoint_path}")
```

---

# PHASE 8: COMPLETION & REPORTING

## Step 8A: Final Validation

After all tasks complete:

```bash
# Run full test suite
pytest --cov=src --cov-report=term-missing

# Check coverage threshold
COVERAGE=$(pytest --cov=src --cov-report=json | jq '.totals.percent_covered')
if [ $(echo "$COVERAGE < 80" | bc) -eq 1 ]; then
    echo "⚠️ Coverage below 80%: ${COVERAGE}%"
fi

# Run linting
ruff check src/ tests/

# Run type checking
mypy src/
```

## Step 8B: Generate Execution Report

```markdown
## Sequential Execution Report

**Sprint**: {SPRINT_NUMBER}
**Executed**: {TIMESTAMP}
**Duration**: {TOTAL_TIME}

### Tasks Summary

| Task | Title | Status | Time |
|------|-------|--------|------|
| T-001 | Create user model | ✅ Completed | 45m |
| T-002 | Add API endpoint | ✅ Completed | 1h 20m |
| T-003 | Write unit tests | ⏭️ Skipped | - |
| T-004 | Frontend component | ✅ Completed | 55m |

### Statistics
- **Total Tasks**: {TOTAL}
- **Completed**: {COMPLETED_COUNT} ✅
- **Skipped**: {SKIPPED_COUNT} ⏭️
- **Failed**: {FAILED_COUNT} ❌

### Quality Metrics
- **Tests**: {TEST_COUNT} passing
- **Coverage**: {COVERAGE}%
- **Lint Errors**: {LINT_ERRORS}
- **Type Errors**: {TYPE_ERRORS}

### GitLab Issues
- Created: {CREATED_COUNT}
- Closed: {CLOSED_COUNT}
- Issues: {ISSUE_LIST with links}

### Next Steps
{
  if all_completed:
    "Sprint complete! Run /session:end to finalize."
  elif has_skipped:
    "Some tasks were skipped. Review and address:\n" + skipped_list
  elif has_failed:
    "Some tasks failed. Review errors and retry:\n" + failed_list
}
```

## Step 8C: Update State Files

```python
def update_sprint_state(state, graph):
    """Update sprint state files after execution."""

    # Update current_state.md
    state_content = f"""
# Current State

**Last Updated**: {datetime.utcnow().isoformat()}
**Sprint**: {state['sprint_id']}
**Status**: {'Complete' if len(state['completed']) == len(graph['tasks']) else 'In Progress'}

## Task Status
- Completed: {len(state['completed'])}
- Skipped: {len(state['skipped'])}
- Remaining: {len(graph['tasks']) - len(state['completed']) - len(state['skipped'])}

## Next Action
{determine_next_action(state, graph)}
"""

    with open("state/current_state.md", "w") as f:
        f.write(state_content)
```

---

# ERROR HANDLING

## Dependency Failure

If a task that others depend on fails:

```python
def check_dependency_impact(failed_task_id, graph):
    """Check what tasks are blocked by this failure."""
    blocked = []
    to_check = [failed_task_id]

    while to_check:
        current = to_check.pop()
        for dependent in graph["tasks"][current].get("dependents", []):
            if dependent not in blocked:
                blocked.append(dependent)
                to_check.append(dependent)

    return blocked
```

When a task fails, report impact:
```
⚠️ Task T-002 failure blocks {N} dependent tasks:
   - T-004: Frontend component (depends on T-002)
   - T-006: Integration tests (depends on T-004)

These tasks will be skipped if you choose to continue.
```

## Context Exhaustion

If a task is too large and causes context exhaustion:

1. Save checkpoint immediately
2. Report the issue with task details
3. Recommend splitting the task:
   ```
   ⚠️ Task T-003 exceeded context budget.

   Recommendation: Split this task in /session:plan:
   - Current estimate: 65K tokens
   - Recommended max: 50K tokens

   Re-run /session:plan to restructure, then resume.
   ```

## Test Failures in TDD

If tests fail after implementation:

1. Show specific failing tests
2. Provide error messages
3. Offer diagnostic suggestions
4. Allow retry or manual intervention

---

# COMPARISON: /session:implement vs /session:parallel

| Aspect | /session:implement | /session:parallel |
|--------|-------------------|-------------------|
| Execution | Sequential, one task at a time | Up to 3 concurrent workers |
| Best for | <10 tasks, tight coupling | >10 tasks, independent work |
| Debugging | Easier, inline execution | Harder, separate processes |
| Context | Full context available | Workers have limited context |
| Failure | Immediate feedback | Discover after worker completes |
| Resume | Simple checkpoint | Complex state management |
| Speed | Slower | Faster (parallelism) |

**Use /session:implement when:**
- Sprint has fewer than 10 tasks
- Tasks are tightly coupled
- You need easier debugging
- Sequential execution makes sense architecturally

**Use /session:parallel when:**
- Sprint has 10+ independent tasks
- Parallelization efficiency >50%
- Speed is important
- Tasks are well-isolated by domain

---

# USAGE EXAMPLES

## Fresh Start
```bash
/session:implement 5
```

## Resume from Checkpoint
```bash
/session:implement 5 --resume
```

## Dry Run (Preview)
```bash
/session:implement 5 --dry-run
```

## Start from Specific Task
```bash
/session:implement 5 --start-from T-004
```

## Skip GitLab Integration
```bash
/session:implement 5 --skip-gitlab
```
