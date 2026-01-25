---
description: Execute sprint tasks sequentially from task graph with TDD workflow
---

# SEQUENTIAL SPRINT IMPLEMENTATION

You are executing a sprint's tasks **sequentially** from a pre-generated task graph. This command is the simpler alternative to `/session:parallel` - execute tasks one at a time with full context and easier debugging.

## ARGUMENTS

```
/session:implement [sprint-number] [--resume] [--dry-run] [--start-from TASK-ID]
```

- `sprint-number`: Sprint to execute (e.g., `5` for sprint 5). Default: detect from `state/current_state.md`
- `--resume`: Resume from last checkpoint (reads `execution_checkpoint.json`)
- `--dry-run`: Show execution plan without running tasks
- `--start-from`: Start from a specific task ID (skips prior tasks)

---

# PHASE 6: LOAD TASKS FROM BEADS

## Step 6A: Verify Beads Initialized

**Beads is the primary source of truth for task tracking.**

```bash
# Check beads is initialized
if [ ! -d ".beads" ]; then
    echo "❌ Beads not initialized."
    echo "   Run /project:scrum to create tasks in beads."
    exit 1
fi

# Check for ready tasks
bd ready
```

## Step 6B: Load Tasks from Beads

```python
import subprocess
import json

def load_tasks_from_beads():
    """Load all tasks from beads - the source of truth for task tracking."""

    # Get all open issues from beads
    result = subprocess.run(
        ["bd", "list", "--json"],
        capture_output=True, text=True
    )

    if result.returncode != 0:
        raise RuntimeError("Failed to load tasks from beads. Is beads initialized?")

    all_issues = json.loads(result.stdout) if result.stdout else []

    # Filter to open tasks only (not epics, not closed)
    tasks = {}
    for issue in all_issues:
        if issue["status"] == "closed":
            continue
        if issue.get("issue_type") == "epic":
            continue

        task_id = issue["id"]
        tasks[task_id] = {
            "id": task_id,
            "title": issue["title"],
            "description": issue.get("description", ""),
            "status": issue["status"],
            "priority": issue.get("priority", 2),
            "complexity": get_label_value(issue, "complexity", "standard"),
            "domain": get_label_value(issue, "domain", "backend"),
            "dependencies": [],  # Will be populated from deps
            "estimated_minutes": issue.get("estimate", 60),
            "external_ref": issue.get("external_ref", ""),
        }

    # Load dependencies for each task
    for task_id in tasks:
        deps_result = subprocess.run(
            ["bd", "dep", "list", task_id, "--json"],
            capture_output=True, text=True
        )
        if deps_result.stdout:
            deps = json.loads(deps_result.stdout)
            for dep in deps:
                if dep.get("type") == "blocks":
                    tasks[task_id]["dependencies"].append(dep["target"])

    return {"format": "beads", "tasks": tasks}

def get_label_value(issue, prefix, default):
    """Extract label value like 'complexity:standard' -> 'standard'."""
    for label in issue.get("labels", []):
        if label.startswith(f"{prefix}:"):
            return label.split(":")[1]
    return default

def get_next_ready_task():
    """Get the next task ready for execution (no blockers)."""
    result = subprocess.run(
        ["bd", "ready", "--json"],
        capture_output=True, text=True
    )
    ready_tasks = json.loads(result.stdout) if result.stdout else []

    # Filter out epics
    ready_tasks = [t for t in ready_tasks if t.get("issue_type") != "epic"]

    if ready_tasks:
        # Sort by priority (lower = higher priority)
        ready_tasks.sort(key=lambda t: t.get("priority", 2))
        return ready_tasks[0]
    return None
```

**CRITICAL**: If no beads tasks exist, STOP and inform user:
```
❌ No tasks found in beads.

Run /project:scrum to generate beads issues from your spec.
```

## Step 6C: Fallback to Legacy Task Graph (Deprecated)

For backward compatibility with projects not yet migrated to beads:

```python
def load_task_graph_legacy(path):
    """Load task graph from JSON file - DEPRECATED, use beads instead."""
    print("⚠️ Using legacy task_graph.json format.")
    print("   Consider running migration: scripts/migrate_to_beads.sh")

    with open(path) as f:
        graph = json.load(f)

    # Validate no cycles
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
    "beads_issues": {"T-001": 42, "T-002": 43, "T-003": 44}
}
```

## Step 6D: Display Execution Plan

Show the user what will be executed:

```bash
# Get task summary from beads
TOTAL=$(bd list --json | jq '[.[] | select(.issue_type != "epic")] | length')
OPEN=$(bd list --json | jq '[.[] | select(.status == "open" and .issue_type != "epic")] | length')
READY=$(bd ready --json | jq '[.[] | select(.issue_type != "epic")] | length')

echo "## Execution Plan"
echo ""
echo "**Task Source**: Beads (.beads/)"
echo "**Tasks**: $TOTAL total, $OPEN remaining, $READY ready to start"
echo ""
echo "### Ready Tasks (no blockers)"
bd ready --json | jq -r '.[] | select(.issue_type != "epic") | "- [\(.priority)] \(.id): \(.title)"'
```

```markdown
## Execution Plan - Sprint {N}

**Task Source**: Beads (.beads/)
**Tasks**: {TOTAL} total, {OPEN} remaining, {READY} ready
**Resume**: {Yes (from checkpoint) | No (fresh start)}

### Ready Tasks (will execute first)

| # | Task ID | Title | Domain | Est. Min | Priority |
|---|---------|-------|--------|----------|----------|
| 1 | bd-xxx | Role Flags Schema | backend | 60 | P2 |
| 2 | bd-yyy | Migration Script | backend | 120 | P2 |

**Note**: Tasks execute in dependency order. `bd ready` auto-computes unblocked tasks.
```

If `--dry-run` is set, STOP here after displaying the plan.

---

# PHASE 7: SEQUENTIAL TASK EXECUTION

## Step 7A: Initialize Execution State

```python
def init_execution_state(checkpoint=None):
    """Initialize or restore execution state.

    Note: Task state is now tracked in beads, not locally.
    Checkpoint is only for session recovery.
    """
    if checkpoint:
        completed = set(checkpoint.get("completed_tasks", []))
        failed = set(checkpoint.get("failed_tasks", []))
        skipped = set(checkpoint.get("skipped_tasks", []))
    else:
        completed = set()
        failed = set()
        skipped = set()

    return {
        "completed": completed,
        "failed": failed,
        "skipped": skipped,
        "current_task": None,
        "started_at": datetime.utcnow().isoformat()
    }

def get_execution_order_from_beads():
    """Get tasks in execution order from beads.

    Uses `bd ready` to get unblocked tasks, which handles
    dependency resolution automatically.
    """
    result = subprocess.run(
        ["bd", "ready", "--json"],
        capture_output=True, text=True
    )
    ready_tasks = json.loads(result.stdout) if result.stdout else []

    # Filter out epics, sort by priority
    tasks = [t for t in ready_tasks if t.get("issue_type") != "epic"]
    tasks.sort(key=lambda t: t.get("priority", 2))

    return tasks
```

## Step 7B: Task Execution Loop

Execute tasks using beads for task selection:

```python
task_count = 0
total_tasks = get_total_open_tasks()

while True:
    # Get next ready task from beads
    task = get_next_ready_task()

    if not task:
        print("No more ready tasks.")
        break

    task_id = task["id"]
    task_count += 1
    state["current_task"] = task_id

    # 1. Display task header
    print(f"\n{'='*60}")
    print(f"TASK {task_count}/{total_tasks}: {task_id}")
    print(f"Title: {task['title']}")
    print(f"Priority: P{task.get('priority', 2)}")
    print(f"Estimated: {task.get('estimate', 60)} minutes")
    print(f"{'='*60}\n")

    # 2. Claim task in beads (mark as in_progress)
    update_beads_issue(task_id, "in-progress")

    # 3. Execute task using TDD workflow
    result = execute_task_tdd(task)

    # 4. Handle result
    if result["status"] == "success":
        state["completed"].add(task_id)
        update_beads_issue(task_id, "done")  # Closes task, unblocks dependents
        print(f"✅ Task {task_id} completed successfully")

    elif result["status"] == "failed":
        # Offer options to user
        action = handle_task_failure(task_id, result["error"])
        if action == "retry":
            # Re-run current task
            continue
        elif action == "skip":
            state["skipped"].add(task_id)
            update_beads_issue(task_id, "skipped")
        elif action == "abort":
            save_checkpoint(state)
            raise ExecutionAborted(f"Aborted at task {task_id}")

    # 5. Save checkpoint after each task
    save_checkpoint(state)

def get_total_open_tasks():
    """Get count of open tasks from beads."""
    result = subprocess.run(
        ["bd", "list", "--json"],
        capture_output=True, text=True
    )
    issues = json.loads(result.stdout) if result.stdout else []
    return len([i for i in issues if i["status"] == "open" and i.get("issue_type") != "epic"])
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

    # 🔍 Efficiency Check (non-blocking awareness prompt)
    print("\n" + "-" * 50)
    print("   🔍 Efficiency Check:")
    print("   Before marking this task complete, consider:")
    print("   • Is there a simpler way to achieve this?")
    print("   • Are there any O(n²) operations that could be O(n)?")
    print("   • Is there unnecessary complexity or over-engineering?")
    print("   • Could any loops be replaced with built-in functions?")
    print("   • Are there repeated calculations that could be cached?")
    print("")
    print("   If yes to any: refactor now while context is fresh.")
    print("   If no: proceed to final tests.")
    print("-" * 50)

    # Final test run to ensure refactoring didn't break anything
    final_result = run_tests(task["test_pattern"])
    if not final_result["passed"]:
        return {
            "status": "failed",
            "error": f"Tests failed after refactoring:\n{final_result['output']}"
        }

    # Phase 4: E2E VERIFICATION (for frontend/integration tasks)
    if is_frontend_or_integration_task(task):
        print(f"\n🔍 Phase 4/4: E2E Verification for {task['id']}...")

        # 4a. Validate API hosts - no hardcoded URLs
        api_validation = validate_api_hosts(task)
        if not api_validation["valid"]:
            return {
                "status": "failed",
                "error": f"API Host Validation Failed:\n" +
                         "\n".join(f"  - {e}" for e in api_validation["errors"])
            }
        print("  ✅ API host validation passed")

        # 4b. Run E2E tests if they exist for this feature
        e2e_result = run_e2e_tests_for_task(task)
        if e2e_result["tests_exist"] and not e2e_result["passed"]:
            return {
                "status": "failed",
                "error": f"E2E tests failed:\n{e2e_result['output']}"
            }
        elif e2e_result["tests_exist"]:
            print(f"  ✅ E2E tests passed ({e2e_result['test_count']} tests)")
        else:
            print("  ℹ️  No E2E tests found for this task")

    return {"status": "success", "coverage": final_result.get("coverage", 0)}


def is_frontend_or_integration_task(task):
    """Check if task requires E2E verification."""
    frontend_domains = ["frontend", "ui", "e2e", "integration"]
    frontend_indicators = ["component", "form", "page", "view", "api call"]

    if task.get("domain", "").lower() in frontend_domains:
        return True

    title_lower = task.get("title", "").lower()
    return any(ind in title_lower for ind in frontend_indicators)


def validate_api_hosts(task):
    """
    Validate frontend code doesn't contain hardcoded API URLs.

    Scans for:
    1. Hardcoded localhost URLs
    2. Hardcoded staging/production URLs
    3. Missing API_BASE_URL usage
    """
    import re
    import os

    errors = []
    warnings = []

    # Patterns that should NOT appear in frontend code
    forbidden_patterns = [
        (r'localhost:\d+', "Hardcoded localhost URL"),
        (r'127\.0\.0\.1', "Hardcoded IP address"),
        (r'https?://[a-z]+\.staging\.[a-z]+\.[a-z]+', "Hardcoded staging URL"),
        (r'https?://api\.[a-z]+\.[a-z]+', "Hardcoded production API URL"),
    ]

    # Files to scan based on task
    files_to_scan = task.get("files_affected", [])

    # Also scan common API-related directories
    api_dirs = ["src/api", "src/services", "src/lib", "src/utils/api"]

    for file_info in files_to_scan:
        filepath = file_info.get("path", file_info) if isinstance(file_info, dict) else file_info

        # Only scan frontend files
        if not any(filepath.endswith(ext) for ext in ['.ts', '.tsx', '.js', '.jsx', '.vue']):
            continue

        if not os.path.exists(filepath):
            continue

        try:
            with open(filepath, 'r') as f:
                content = f.read()
                lines = content.split('\n')

            for line_num, line in enumerate(lines, 1):
                for pattern, description in forbidden_patterns:
                    if re.search(pattern, line, re.IGNORECASE):
                        errors.append(
                            f"{filepath}:{line_num} - {description}: {line.strip()[:80]}"
                        )

            # Check for proper environment variable usage
            if '/api/' in content or 'fetch(' in content or 'axios' in content:
                if 'API_BASE_URL' not in content and 'VITE_API' not in content:
                    if 'process.env' not in content and 'import.meta.env' not in content:
                        warnings.append(
                            f"{filepath} - Makes API calls but may not use environment variables"
                        )

        except Exception as e:
            warnings.append(f"Could not scan {filepath}: {e}")

    return {
        "valid": len(errors) == 0,
        "errors": errors,
        "warnings": warnings
    }


def run_e2e_tests_for_task(task):
    """
    Run E2E tests associated with this task.

    Looks for E2E tests in:
    1. Task's test_files with e2e pattern
    2. Feature's e2e directory
    """
    import subprocess
    import os

    # Determine feature from task
    feature_name = extract_feature_from_task(task)
    e2e_dir = f".specify/specs/{feature_name}/e2e" if feature_name else None

    # Check if E2E tests exist
    if e2e_dir and os.path.isdir(e2e_dir):
        test_files = []
        for root, dirs, files in os.walk(e2e_dir):
            for f in files:
                if f.endswith('.spec.ts') or f.endswith('.test.ts'):
                    test_files.append(os.path.join(root, f))

        if not test_files:
            return {"tests_exist": False}

        # Run Playwright tests
        try:
            result = subprocess.run(
                ["npx", "playwright", "test", e2e_dir, "--reporter=list"],
                capture_output=True,
                text=True,
                timeout=300  # 5 minute timeout
            )

            return {
                "tests_exist": True,
                "passed": result.returncode == 0,
                "test_count": len(test_files),
                "output": result.stdout + result.stderr
            }
        except subprocess.TimeoutExpired:
            return {
                "tests_exist": True,
                "passed": False,
                "output": "E2E tests timed out after 5 minutes"
            }
        except FileNotFoundError:
            return {
                "tests_exist": True,
                "passed": False,
                "output": "Playwright not installed. Run: npm install -D @playwright/test"
            }

    return {"tests_exist": False}


def extract_feature_from_task(task):
    """Extract feature name from task metadata."""
    # Try to get from external_ref or spec reference
    external_ref = task.get("external_ref", "")
    if external_ref:
        # Pattern: FR-001,.specify/specs/{feature}/spec.md
        match = re.search(r'\.specify/specs/([^/]+)/', external_ref)
        if match:
            return match.group(1)

    # Try to infer from task title or files
    for file_info in task.get("files_affected", []):
        filepath = file_info.get("path", file_info) if isinstance(file_info, dict) else file_info
        match = re.search(r'\.specify/specs/([^/]+)/', filepath)
        if match:
            return match.group(1)

    return None


def is_wiring_task(task):
    """Check if this is a -WIRE task requiring handler verification."""
    task_id = task.get("id", "")
    title_lower = task.get("title", "").lower()

    return (
        "-WIRE" in task_id.upper() or
        "wire" in title_lower and "handler" in title_lower
    )


def is_data_loading_task(task):
    """Check if this is a -DATA task requiring data loading verification."""
    task_id = task.get("id", "")
    title_lower = task.get("title", "").lower()

    return (
        "-DATA" in task_id.upper() or
        ("data" in title_lower and "loading" in title_lower) or
        "wire" in title_lower and "data" in title_lower
    )
```

## Step 7D-WIRE: Handler Wiring Verification (for -WIRE tasks)

**Purpose**: Verify that handlers are properly wired to real actions, not left as `console.log()` stubs. This is a BLOCKING check for tasks with `-WIRE` suffix.

```python
def verify_handler_wiring(task):
    """
    Verify handlers are wired to real actions, not console.log stubs.

    For -WIRE tasks, scan modified files for:
    1. console.log() in onClick/onSubmit handlers
    2. Empty arrow functions () => {}
    3. TODO comments about wiring
    4. Placeholder handlers

    Returns: {"valid": bool, "errors": list, "warnings": list}
    """
    import re
    import os

    errors = []
    warnings = []

    # Patterns that indicate stub handlers (BLOCKING)
    stub_patterns = [
        # console.log in handlers
        (r'onClick=\{[^}]*console\.log[^}]*\}', "onClick handler is console.log() stub"),
        (r'onSubmit=\{[^}]*console\.log[^}]*\}', "onSubmit handler is console.log() stub"),
        (r'onStart=\{[^}]*console\.log[^}]*\}', "onStart handler is console.log() stub"),
        (r'onChange=\{[^}]*console\.log[^}]*\}', "onChange handler is console.log() stub"),
        (r'on\w+=\{[^}]*console\.log[^}]*\}', "Handler contains console.log() stub"),

        # Empty handlers
        (r'onClick=\{\(\)\s*=>\s*\{\s*\}\}', "onClick is empty arrow function"),
        (r'onSubmit=\{\(\)\s*=>\s*\{\s*\}\}', "onSubmit is empty arrow function"),
        (r'on\w+=\{\(\)\s*=>\s*\{\s*\}\}', "Handler is empty arrow function"),
        (r'on\w+=\{\(\)\s*=>\s*null\}', "Handler returns null (placeholder)"),
        (r'on\w+=\{\(\)\s*=>\s*undefined\}', "Handler returns undefined (placeholder)"),

        # TODO/FIXME comments about wiring
        (r'//\s*TODO:?\s*(wire|connect|implement|add\s+action)', "TODO comment about wiring found"),
        (r'//\s*FIXME:?\s*(wire|handler|onclick)', "FIXME comment about handler found"),
    ]

    # Warning patterns (non-blocking but should be reviewed)
    warning_patterns = [
        (r'onClick=\{[^}]*alert\([^}]*\}', "onClick uses alert() - likely placeholder"),
        (r'console\.log\([\'"]click', "console.log for click event - debug code?"),
        (r'console\.log\([\'"]handle', "console.log for handler - debug code?"),
    ]

    files_to_scan = task.get("files_affected", [])

    for file_info in files_to_scan:
        filepath = file_info.get("path", file_info) if isinstance(file_info, dict) else file_info

        # Only scan frontend files
        if not any(filepath.endswith(ext) for ext in ['.ts', '.tsx', '.js', '.jsx', '.vue', '.svelte']):
            continue

        if not os.path.exists(filepath):
            continue

        try:
            with open(filepath, 'r') as f:
                content = f.read()
                lines = content.split('\n')

            # Check for stub patterns (BLOCKING)
            for pattern, description in stub_patterns:
                matches = list(re.finditer(pattern, content, re.IGNORECASE | re.MULTILINE))
                for match in matches:
                    # Find line number
                    line_num = content[:match.start()].count('\n') + 1
                    errors.append(
                        f"{filepath}:{line_num} - {description}\n"
                        f"    Found: {match.group()[:60]}..."
                    )

            # Check for warning patterns
            for pattern, description in warning_patterns:
                matches = list(re.finditer(pattern, content, re.IGNORECASE | re.MULTILINE))
                for match in matches:
                    line_num = content[:match.start()].count('\n') + 1
                    warnings.append(
                        f"{filepath}:{line_num} - {description}"
                    )

            # Check that navigation handlers actually use router
            if 'Navigate' in task.get("title", "") or 'navigation' in task.get("description", "").lower():
                if 'router.push' not in content and 'useNavigate' not in content and '<Link' not in content:
                    warnings.append(
                        f"{filepath} - Navigation task but no router.push/useNavigate/Link found"
                    )

        except Exception as e:
            warnings.append(f"Could not scan {filepath}: {e}")

    return {
        "valid": len(errors) == 0,
        "errors": errors,
        "warnings": warnings
    }


def verify_data_loading(task):
    """
    Verify pages load data on mount (useEffect calling load function).

    For -DATA tasks, scan modified page files for:
    1. useEffect that calls a load/fetch function
    2. Loading state handling
    3. Error state handling
    4. Empty state handling

    Returns: {"valid": bool, "errors": list, "warnings": list}
    """
    import re
    import os

    errors = []
    warnings = []

    files_to_scan = task.get("files_affected", [])

    for file_info in files_to_scan:
        filepath = file_info.get("path", file_info) if isinstance(file_info, dict) else file_info

        # Only scan page/component files
        if not any(filepath.endswith(ext) for ext in ['.ts', '.tsx', '.js', '.jsx']):
            continue

        # Focus on page files
        is_page = 'page' in filepath.lower() or '/pages/' in filepath or '/app/' in filepath

        if not is_page:
            continue

        if not os.path.exists(filepath):
            continue

        try:
            with open(filepath, 'r') as f:
                content = f.read()

            # Check for useEffect with data loading
            has_use_effect = 'useEffect' in content
            has_data_call = any(pattern in content for pattern in [
                'load', 'fetch', 'get', 'query', 'useQuery'
            ])

            # Pattern: useEffect(() => { loadData() }, [])
            use_effect_with_load = re.search(
                r'useEffect\s*\(\s*\(\)\s*=>\s*\{[^}]*(?:load|fetch|get|query)[^}]*\}',
                content,
                re.IGNORECASE | re.DOTALL
            )

            # Also check for React Query / SWR patterns
            has_react_query = 'useQuery' in content or 'useSWR' in content

            if not use_effect_with_load and not has_react_query:
                # Check if there's any data dependency
                if has_data_call:
                    errors.append(
                        f"{filepath} - Has data fetching code but no useEffect to trigger on mount.\n"
                        f"    Data loading tasks MUST have useEffect that calls load function on mount."
                    )

            # Check for loading state
            if 'loading' not in content.lower() and 'isLoading' not in content:
                warnings.append(
                    f"{filepath} - No loading state found. Consider showing a skeleton/spinner."
                )

            # Check for error state
            if 'error' not in content.lower() and 'Error' not in content:
                warnings.append(
                    f"{filepath} - No error state handling. Consider showing error message with retry."
                )

            # Check for empty state
            if 'empty' not in content.lower() and 'no data' not in content.lower():
                warnings.append(
                    f"{filepath} - No empty state handling. Consider showing helpful empty state UI."
                )

        except Exception as e:
            warnings.append(f"Could not scan {filepath}: {e}")

    return {
        "valid": len(errors) == 0,
        "errors": errors,
        "warnings": warnings
    }
```

### Integration into TDD Workflow

Add these checks to `execute_task_tdd()` after E2E verification:

```python
    # Phase 5: WIRING VERIFICATION (for -WIRE and -DATA tasks)
    if is_wiring_task(task):
        print(f"\n🔌 Phase 5/5: Handler Wiring Verification for {task['id']}...")

        wiring_result = verify_handler_wiring(task)

        if wiring_result["warnings"]:
            print("  ⚠️ Warnings (non-blocking):")
            for w in wiring_result["warnings"][:5]:
                print(f"    - {w}")

        if not wiring_result["valid"]:
            print("\n" + "=" * 60)
            print("❌ HANDLER WIRING VERIFICATION FAILED")
            print("=" * 60)
            print("\nStub handlers detected in your code. Handlers must perform")
            print("real actions, not console.log() or empty functions.\n")
            print("Errors found:")
            for e in wiring_result["errors"]:
                print(f"  ❌ {e}")
            print("\n" + "=" * 60)
            print("REQUIRED FIX:")
            print("  1. Replace console.log() handlers with real actions")
            print("  2. Navigation handlers: use router.push() or <Link>")
            print("  3. API handlers: call the actual API method")
            print("  4. Modal handlers: set modal state to true")
            print("=" * 60)

            return {
                "status": "failed",
                "error": "Handler wiring verification failed - stub handlers detected"
            }

        print("  ✅ Handler wiring verification passed (no stubs)")

    if is_data_loading_task(task):
        print(f"\n📊 Phase 5/5: Data Loading Verification for {task['id']}...")

        data_result = verify_data_loading(task)

        if data_result["warnings"]:
            print("  ⚠️ Warnings (non-blocking):")
            for w in data_result["warnings"][:5]:
                print(f"    - {w}")

        if not data_result["valid"]:
            print("\n" + "=" * 60)
            print("❌ DATA LOADING VERIFICATION FAILED")
            print("=" * 60)
            print("\nPages must load data on mount. Common issues:")
            print("  - Missing useEffect to trigger data loading")
            print("  - Data is defined but never loaded into state")
            print("  - Page renders empty array instead of calling API\n")
            print("Errors found:")
            for e in data_result["errors"]:
                print(f"  ❌ {e}")
            print("\n" + "=" * 60)
            print("REQUIRED FIX:")
            print("  useEffect(() => {")
            print("    loadData();")
            print("  }, [loadData]);")
            print("=" * 60)

            return {
                "status": "failed",
                "error": "Data loading verification failed - missing useEffect"
            }

        print("  ✅ Data loading verification passed")
```

### Example: Detected Stub Handler

```
❌ HANDLER WIRING VERIFICATION FAILED
============================================================

Stub handlers detected in your code. Handlers must perform
real actions, not console.log() or empty functions.

Errors found:
  ❌ src/components/MiaCard.tsx:45 - onClick handler is console.log() stub
      Found: onClick={() => console.log("Start:", taskId)}...

  ❌ src/components/MiaCard.tsx:52 - onStart handler is empty arrow function
      Found: onStart={() => {}}...

============================================================
REQUIRED FIX:
  1. Replace console.log() handlers with real actions
  2. Navigation handlers: use router.push() or <Link>
  3. API handlers: call the actual API method
  4. Modal handlers: set modal state to true
============================================================
```

## Step 7D: Beads Issue Management

```python
import subprocess
import json

def update_beads_issue(task_id, status):
    """Update beads issue status for task.

    Beads issues should already exist (created by /project:scrum).
    This function updates status during execution.
    """

    if status == "in-progress":
        # Claim the task
        subprocess.run([
            "bd", "update", task_id,
            "--status", "in_progress"
        ])
    elif status == "done":
        # Close the task
        subprocess.run([
            "bd", "close", task_id,
            "--reason", "Task completed via /session:implement"
        ])
        # Sync to git
        subprocess.run(["bd", "sync"])
    elif status == "skipped":
        # Mark as skipped
        subprocess.run([
            "bd", "update", task_id,
            "--notes", "Skipped by user during sequential execution"
        ])
    elif status == "failed":
        # Mark as failed
        subprocess.run([
            "bd", "update", task_id,
            "--status", "failed"
        ])

def get_next_ready_task():
    """Get the next task ready for execution from beads."""
    result = subprocess.run(
        ["bd", "ready", "--json"],
        capture_output=True, text=True
    )
    ready_tasks = json.loads(result.stdout) if result.stdout else []

    if ready_tasks:
        # Return highest priority task
        ready_tasks.sort(key=lambda t: t.get("priority", 2))
        return ready_tasks[0]["id"]
    return None
```

**Note**: Beads issues should be created by `/project:scrum` before running `/session:implement`. Beads handles dependency unblocking automatically when tasks are closed.

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
        "beads_issues": state["beads_issues"]
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

### Beads Issues
- Completed: {COMPLETED_COUNT}
- Remaining: {REMAINING_COUNT}
- Run `bd list` for full status

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
