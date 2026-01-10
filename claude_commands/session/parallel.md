---
description: Execute sprint tasks in parallel using up to 3 concurrent Claude Code worker sessions
---

# ⚠️ CRITICAL: WORKER SPAWNING METHOD - READ FIRST

**DO NOT use the Task tool for spawning workers.**

Task tool sub-agents have **ZERO auto-compaction capability**.
Workers **WILL** fail from context exhaustion on complex tasks.

You **MUST** spawn workers using the **Bash tool** with `claude -p`:

## Mandatory Spawn Command (Use Exactly This)

```bash
# Spawn headless worker - MUST use Bash tool, NOT Task tool
claude -p --model {model} --max-turns {max_turns} \
    --add-dir "{worktree_path}" \
    --agent sprint-worker \
    --permission-mode acceptEdits \
    --allowedTools "Read" "Write" "Edit" "Bash" "Grep" "Glob" "mcp__gitlab-mcp__update_issue" \
    --output-format json \
    "{task_prompt}" \
    > "{output_file}" 2>&1 &
PID=$!
echo "Worker PID: $PID"
```

## Verify Spawn (REQUIRED After Each Spawn)

```bash
ps -p {PID} | grep claude
```

## Poll for Completion

```bash
# Check if worker finished
if ! ps -p {PID} > /dev/null 2>&1; then
    # Process finished - read output
    cat "{output_file}"
fi
```

## Why This Matters

| Mode | Auto-Compaction | Result on Complex Tasks |
|------|-----------------|------------------------|
| Task tool sub-agents | ❌ NONE | Guaranteed context exhaustion failure |
| Headless `claude -p` | ✅ Yes (unreliable but exists) | May recover via compaction |

**Headless `claude -p` is the ONLY safe option for workers.**

---

# PARALLEL SPRINT EXECUTION (Continuous Worker Model)

You are the **Orchestrator** for parallel sprint execution. Your role is to manage a continuous pool of workers that execute tasks from a pre-generated task graph.

## ARGUMENTS

```
/session:parallel [sprint-number] [--dry-run] [--max-workers N] [--resume] [--cleanup]
```

- `sprint-number`: Sprint to execute (e.g., `5` for sprint 5). Default: detect from `state/current_state.md`
- `--dry-run`: Plan without spawning workers (useful for validation)
- `--max-workers`: Override default of 3 concurrent workers (max: 5)
- `--resume`: Resume from previous execution state
- `--cleanup`: Clean up worktrees from a previous run without executing

---

# ARCHITECTURE: CONTINUOUS WORKER MODEL WITH GIT WORKTREES

```
┌─────────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATOR (Main Repo)                      │
│                                                                      │
│  ~/Code/project/                ← Main worktree (orchestrator)       │
│  ├── .git/                                                           │
│  │   └── worktrees/             ← Worktree metadata                  │
│  └── src/                                                            │
│                                                                      │
│  ~/Code/project-worktrees/      ← Isolated worker directories        │
│  ├── sprint-05-t-001/           ← WORKER 1 (isolated checkout)       │
│  ├── sprint-05-t-003/           ← WORKER 2 (isolated checkout)       │
│  └── sprint-05-t-005/           ← WORKER 3 (isolated checkout)       │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────┐       │
│  │                    TASK QUEUE                             │       │
│  │  [T-002: blocked] [T-004: pending] [T-006: pending]      │       │
│  └──────────────────────────────────────────────────────────┘       │
│                                                                      │
│  LOOP: Poll → Complete/Fail → Unblock → Select → Worktree → Spawn   │
│        → Save → Merge → Remove Worktree                              │
└─────────────────────────────────────────────────────────────────────┘
```

**Key Features**:
- **Git Worktrees**: Each worker runs in its own isolated git worktree - no checkout conflicts!
- **Continuous Pool**: Workers spawn immediately when slots open - no waiting for batches
- **Automatic Cleanup**: Successful worktrees removed after merge; failed preserved for debug

---

# PHASE 1: LOAD TASK GRAPH

## Step 1A: Locate Task Graph

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
            print("\nSpecify feature: /session:parallel --feature {name}")
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

**CRITICAL**: If no task graph exists, STOP and inform user:
```
❌ No task graph found.

For spec-kit format:
  Run /project:scrum to generate .specify/specs/{feature}/tasks.md

For legacy format:
  Run /session:plan to generate task_graph.json
```

## Step 1B: Validate Task Graph

```python
def validate_task_graph(graph):
    """Validate task graph integrity."""
    tasks = graph["tasks"]

    # Check for cycles
    if has_cycle(tasks):
        raise ValueError("Task graph contains cycles - invalid DAG")

    # Validate all dependencies exist
    for task_id, task in tasks.items():
        for dep in task.get("dependencies", []):
            if dep not in tasks:
                raise ValueError(f"Task {task_id} depends on unknown task {dep}")

    # Validate parallel groups are consistent
    for group in graph.get("parallel_groups", []):
        for task_id in group["tasks"]:
            if tasks[task_id].get("parallel_group") != group["group"]:
                raise ValueError(f"Parallel group mismatch for {task_id}")

    return True
```

## Step 1C: Initialize Execution State

```python
def init_execution_state(graph, max_workers=3, resume_state=None, project_dir=None):
    """Initialize parallel execution state with worktree support."""

    if resume_state:
        # Resume from previous state
        state = resume_state
        state["resumed_at"] = datetime.utcnow().isoformat()
    else:
        # Fresh start
        tasks = graph["tasks"]
        project_name = os.path.basename(project_dir) if project_dir else "project"
        worktree_base = f"{project_dir}-worktrees" if project_dir else "project-worktrees"

        state = {
            "sprint_id": graph["sprint_id"],
            "started_at": datetime.utcnow().isoformat(),
            "status": "initializing",
            "max_workers": max_workers,
            "worktree_base": worktree_base,  # NEW: Base path for worktrees
            "tasks": {},
            "active_workers": [],
            "completed_tasks": [],
            "failed_tasks": [],
            "pending_tasks": [],
            "blocked_tasks": [],
            "gitlab_issues": {},
            "metrics": {
                "tasks_total": len(tasks),
                "tasks_completed": 0,
                "critical_path_blocked": False
            }
        }

        # Initialize task states with worktree paths
        for task_id, task in tasks.items():
            deps = task.get("dependencies", [])
            worktree_name = f"sprint-{graph['sprint_id']}-{task_id.lower()}"
            state["tasks"][task_id] = {
                "status": "pending" if not deps else "blocked",
                "blocked_by": list(deps),
                "worker_pid": None,
                "started_at": None,
                "completed_at": None,
                "branch": f"feature/sprint-{graph['sprint_id']}-{task_id.lower()}",
                "worktree_path": f"{worktree_base}/{worktree_name}",  # NEW
                "model_used": None,
                "exit_code": None,
                "merged": False,
                "output_file": None
            }

            if deps:
                state["blocked_tasks"].append(task_id)
            else:
                state["pending_tasks"].append(task_id)

    # Clean up stale worktrees from previous runs
    if not resume_state:
        cleanup_stale_worktrees(state["worktree_base"], project_dir)

    return state

def cleanup_stale_worktrees(worktree_base, project_dir):
    """Clean up worktrees from previous runs."""
    if os.path.exists(worktree_base):
        print(f"🧹 Cleaning up stale worktrees in {worktree_base}...")
        run_cmd(f"git worktree prune", cwd=project_dir)
        for item in os.listdir(worktree_base):
            path = os.path.join(worktree_base, item)
            if os.path.isdir(path):
                run_cmd(f"git worktree remove -f {path}", cwd=project_dir, check=False)
        run_cmd(f"git worktree prune", cwd=project_dir)
```

---

# PHASE 2: CREATE GITLAB ISSUES (ALL UPFRONT)

Create GitLab issues for ALL tasks before execution begins:

```python
def create_all_gitlab_issues(graph, state, project_id):
    """Create GitLab issues for all tasks upfront."""
    print(f"📋 Creating GitLab issues for {len(graph['tasks'])} tasks...")

    for task_id, task in graph["tasks"].items():
        if task_id in state["gitlab_issues"]:
            continue  # Already created (resume scenario)

        issue = create_issue(
            project_id=project_id,
            title=f"[Sprint {graph['sprint_id']}] {task_id}: {task['title']}",
            description=format_task_issue(task, graph),
            labels=[
                f"sprint-{graph['sprint_id']}",
                task["domain"],
                "pending",
                "parallel-execution"
            ]
        )
        state["gitlab_issues"][task_id] = issue["iid"]
        print(f"  ✓ Created issue #{issue['iid']} for {task_id}")

    return state

def format_task_issue(task, graph):
    """Format GitLab issue description."""
    critical_path = set(graph.get("critical_path", {}).get("tasks", []))

    return f"""
## Task Context
{task['description']}

## Acceptance Criteria
{chr(10).join(f"- [ ] {ac}" for ac in task['acceptance_criteria'])}

## Worker Instructions
- **Branch**: `feature/sprint-{graph['sprint_id']}-{task['id'].lower()}`
- **Domain**: {task['domain']}
- **Complexity**: {task['complexity']}
- **Estimated Tokens**: {task['estimated_tokens']:,}
- **Critical Path**: {'⚠️ YES' if task['id'] in critical_path else 'No'}

## Dependencies
{chr(10).join(f"- {dep}" for dep in task['dependencies']) or 'None - can start immediately'}

## Dependents (blocked by this task)
{chr(10).join(f"- {dep}" for dep in task.get('dependents', [])) or 'None'}

## Files Affected
{chr(10).join(f"- `{f['path']}` ({f['operation']})" for f in task['files_affected'])}

## References
- SRS: {task.get('srs_ref', 'N/A')}
- UI: {task.get('ui_ref', 'N/A')}
- Expert Agent: `{task.get('expert_agent', 'general-purpose')}`

---
*Executed via `/session:parallel` (continuous worker model)*
"""
```

---

# PHASE 3: ORCHESTRATOR MAIN LOOP

## Step 3A: Task Selection Algorithm

```python
def select_next_tasks(state, graph, max_to_select):
    """
    Select next tasks to execute using priority algorithm.

    Priority order:
    1. Tasks with all dependencies satisfied (pending, not blocked)
    2. Among eligible: prefer Critical Path tasks
    3. Then prefer tasks that unblock the most dependents
    4. Then by parallel group order
    5. Tiebreaker: alphabetical by task ID
    """
    critical_path = set(graph.get("critical_path", {}).get("tasks", []))
    tasks = graph["tasks"]

    # Get eligible tasks (pending, not in_progress)
    eligible = []
    for task_id in state["pending_tasks"]:
        if task_id not in state["active_workers"]:
            task = tasks[task_id]
            priority = (
                0 if task_id in critical_path else 1,       # Critical path first
                -len(task.get("dependents", [])),            # More dependents = higher priority
                task.get("parallel_group", 999),             # Lower group first
                task_id                                       # Alphabetical tiebreaker
            )
            eligible.append((priority, task_id))

    # Sort by priority and take up to max_to_select
    eligible.sort()
    return [task_id for _, task_id in eligible[:max_to_select]]
```

## Step 3B: Pre-flight Token Estimation

Before spawning, estimate if a task might exhaust context and proactively split:

```python
MAX_SAFE_TOKENS = 80000  # Leave headroom for auto-compact to trigger

def estimate_task_tokens(task):
    """Estimate context tokens required for a task.

    Conservative estimates to catch potential overflows early.
    """
    base = 8000  # System prompt + agent instructions + overhead

    # File operations
    for file in task.get("files_affected", []):
        if file.get("operation") == "create":
            base += 4000  # New file creation + tests
        elif file.get("operation") == "modify":
            base += 6000  # Read + understand + modify + write

    # Test operations based on acceptance criteria
    base += len(task.get("acceptance_criteria", [])) * 2500

    # Quality checks overhead
    base += 10000  # pytest + coverage + lint + type check

    # TDD multiplier (each phase consumes context)
    if task.get("complexity") == "complex":
        base = int(base * 1.5)

    return base

def should_split_before_spawn(task, task_id):
    """Check if task should be split before even spawning."""
    estimated = estimate_task_tokens(task)

    if estimated > MAX_SAFE_TOKENS:
        print(f"⚠️ {task_id} estimated at {estimated} tokens (max: {MAX_SAFE_TOKENS})")
        print(f"   ↪ Pre-emptively splitting to avoid context exhaustion")
        return True

    return False
```

## Step 3C: Worker Spawning with Git Worktrees

**NEW**: Each worker now runs in its own isolated git worktree, preventing checkout conflicts.

```python
def spawn_worker(task_id, task, graph, state, project_dir):
    """Spawn a Claude Code worker in an isolated git worktree.

    IMPORTANT: Use Bash tool to run `claude -p`, NOT Task tool!
    Task tool sub-agents have NO auto-compaction.
    """

    # PRE-FLIGHT CHECK: Split large tasks before spawning
    if should_split_before_spawn(task, task_id):
        subtasks = split_task_for_retry(task, task_id)
        if subtasks:
            for subtask in subtasks:
                graph["tasks"][subtask["id"]] = subtask
                state["tasks"][subtask["id"]] = {
                    "status": "pending",
                    "blocked_by": subtask.get("dependencies", []),
                    "parent_task": task_id,
                }
                state["pending_tasks"].append(subtask["id"])

            state["tasks"][task_id]["status"] = "split"
            state["tasks"][task_id]["subtasks"] = [s["id"] for s in subtasks]
            return None  # Don't spawn - subtasks will be spawned instead

    # Determine model based on complexity
    model_flag = get_model_for_complexity(task["complexity"])

    # Determine max_turns based on complexity (prevents infinite loops)
    MAX_TURNS = {
        "simple": 15,      # Quick fixes, single file changes
        "standard": 25,    # Normal features, moderate scope
        "complex": 40,     # Large features, multi-file changes
    }
    max_turns = MAX_TURNS.get(task.get("complexity", "standard"), 25)

    # Get worktree path from state
    worktree_path = state["tasks"][task_id]["worktree_path"]
    branch = state["tasks"][task_id]["branch"]

    # Step 1: Create worktree (isolated directory for this task)
    create_worktree(project_dir, worktree_path, branch)

    # Step 2: Create task context for worker
    task_context = json.dumps({
        "task_id": task_id,
        "task": task,
        "sprint_id": graph["sprint_id"],
        "branch": branch,
        "worktree_path": worktree_path,
        "gitlab_issue": state["gitlab_issues"].get(task_id)
    })

    # Output file for worker results (in main project state/)
    output_file = f"{project_dir}/state/workers/worker-{task_id}.json"

    # Build user prompt - worker is ALREADY in worktree, no checkout needed!
    user_prompt = f"""Execute this task:

TASK CONTEXT:
{task_context}

IMPORTANT: You are already in an isolated git worktree on branch '{branch}'.
Do NOT run 'git checkout' or create branches - just start implementing!

Follow TDD workflow. Read CLAUDE.md first. Output JSON status block at the end."""

    # Spawn worker IN THE WORKTREE directory (not main project)
    # CRITICAL: Use Bash tool to run this command, NOT Task tool!
    cmd = f"""
    claude -p {model_flag} --max-turns {max_turns} \\
        --add-dir "{worktree_path}" \\
        --agent sprint-worker \\
        --permission-mode acceptEdits \\
        --allowedTools "Read" "Write" "Edit" "Bash" "Grep" "Glob" "mcp__gitlab-mcp__update_issue" \\
        --output-format json \\
        "{user_prompt}" \\
        > "{output_file}" 2>&1 &
    """
    # Note: The trailing & runs in background so we can spawn multiple workers

    # Run in background
    process = subprocess.Popen(cmd, shell=True)

    # Update state
    state["tasks"][task_id]["status"] = "in_progress"
    state["tasks"][task_id]["worker_pid"] = process.pid
    state["tasks"][task_id]["started_at"] = datetime.utcnow().isoformat()
    state["tasks"][task_id]["model_used"] = model_flag or "default"
    state["tasks"][task_id]["output_file"] = output_file
    state["active_workers"].append(task_id)

    if task_id in state["pending_tasks"]:
        state["pending_tasks"].remove(task_id)

    # Update GitLab issue
    update_issue(
        project_id=get_project_id(),
        issue_iid=state["gitlab_issues"][task_id],
        labels=["in-progress"]
    )

    print(f"🚀 Spawned worker for {task_id} (PID: {process.pid}) in worktree: {worktree_path}")
    return process.pid

def create_worktree(project_dir, worktree_path, branch):
    """Create an isolated git worktree for a task."""
    worktree_base = os.path.dirname(worktree_path)

    # Create worktree base directory if needed
    os.makedirs(worktree_base, exist_ok=True)

    if os.path.exists(worktree_path):
        print(f"   ↪ Worktree already exists: {worktree_path}")
        return

    # Fetch latest develop
    run_cmd("git fetch origin develop", cwd=project_dir)

    # Check if branch exists
    branch_exists = run_cmd(
        f"git show-ref --verify --quiet refs/heads/{branch}",
        cwd=project_dir, check=False
    ).returncode == 0

    if branch_exists:
        # Use existing branch
        run_cmd(f"git worktree add {worktree_path} {branch}", cwd=project_dir)
    else:
        # Create new branch from develop
        run_cmd(f"git worktree add -b {branch} {worktree_path} origin/develop", cwd=project_dir)

    print(f"   ✓ Created worktree: {worktree_path}")

def get_model_for_complexity(complexity):
    """Return model flag based on task complexity."""
    models = {
        "simple": "--model haiku",
        "standard": "",  # Use default (sonnet)
        "complex": "--model opus"
    }
    return models.get(complexity, "")
```

## Step 3C: Worker Polling & Completion

```python
def poll_workers(state, graph):
    """Poll for completed or failed workers."""
    completed = []
    failed = []

    for task_id in list(state["active_workers"]):
        task_state = state["tasks"][task_id]
        pid = task_state["worker_pid"]
        output_file = task_state["output_file"]

        # Check if process is still running
        try:
            os.kill(pid, 0)  # Signal 0 = just check if exists
            continue  # Still running
        except OSError:
            pass  # Process finished

        # Read output file
        if os.path.exists(output_file):
            with open(output_file) as f:
                try:
                    result = json.load(f)
                    if result.get("status") == "success":
                        completed.append((task_id, result))
                    else:
                        failed.append((task_id, result.get("error", "Unknown error")))
                except json.JSONDecodeError:
                    failed.append((task_id, "Invalid worker output"))
        else:
            failed.append((task_id, "No output file generated"))

    return completed, failed
```

## Step 3D: Task Completion Handler

```python
def on_worker_complete(task_id, result, state, graph):
    """Handle successful task completion."""

    # 1. Update task state
    state["tasks"][task_id]["status"] = "completed"
    state["tasks"][task_id]["completed_at"] = datetime.utcnow().isoformat()
    state["tasks"][task_id]["exit_code"] = 0

    # 2. Move from active to completed
    state["active_workers"].remove(task_id)
    state["completed_tasks"].append(task_id)

    # 3. Update metrics
    state["metrics"]["tasks_completed"] += 1

    # 4. Unblock dependent tasks
    newly_unblocked = unblock_dependents(task_id, state, graph)

    # 5. Update GitLab issue
    update_issue(
        project_id=get_project_id(),
        issue_iid=state["gitlab_issues"][task_id],
        labels=["done"]
    )
    close_issue(
        project_id=get_project_id(),
        issue_iid=state["gitlab_issues"][task_id]
    )

    print(f"✅ {task_id} completed. Unblocked: {newly_unblocked or 'none'}")
    return newly_unblocked

def unblock_dependents(completed_task_id, state, graph):
    """Check and unblock tasks that depended on the completed task."""
    newly_unblocked = []

    for dependent_id in graph["tasks"][completed_task_id].get("dependents", []):
        dep_state = state["tasks"][dependent_id]

        # Remove completed task from blocked_by
        if completed_task_id in dep_state["blocked_by"]:
            dep_state["blocked_by"].remove(completed_task_id)

        # If no more blockers, move to pending
        if not dep_state["blocked_by"] and dep_state["status"] == "blocked":
            dep_state["status"] = "pending"
            state["blocked_tasks"].remove(dependent_id)
            state["pending_tasks"].append(dependent_id)
            newly_unblocked.append(dependent_id)

    return newly_unblocked
```

## Step 3E: Context Exhaustion Detection

```python
def detect_context_exhaustion(output_file):
    """Check if worker failed due to context window exhaustion."""
    if not os.path.exists(output_file):
        return False

    with open(output_file) as f:
        content = f.read()

    EXHAUSTION_PATTERNS = [
        "Input length and max_tokens exceed context limit",
        "Conversation too long",
        "context window exceeded",
        "context length exceeded",
        "maximum context length",
        "token limit exceeded",
    ]
    return any(pattern.lower() in content.lower() for pattern in EXHAUSTION_PATTERNS)

def split_task_for_retry(task, task_id):
    """Split a task into smaller subtasks for retry after context exhaustion.

    Returns list of subtasks if decomposable, empty list otherwise.
    """
    # Only split tasks that are marked as decomposable or complex
    if not task.get("decomposable", False) and task.get("complexity") != "complex":
        return []

    # Split by TDD phases: test → implement → refactor
    subtasks = [
        {
            "id": f"{task_id}a",
            "title": f"Write tests for: {task['title']}",
            "complexity": "simple",
            "tdd_phase": "test",
            "parent_task": task_id,
            "files_affected": [f for f in task.get("files_affected", []) if "test" in f["path"]],
        },
        {
            "id": f"{task_id}b",
            "title": f"Implement: {task['title']}",
            "complexity": "standard",
            "tdd_phase": "implement",
            "parent_task": task_id,
            "dependencies": [f"{task_id}a"],
            "files_affected": [f for f in task.get("files_affected", []) if "test" not in f["path"]],
        },
        {
            "id": f"{task_id}c",
            "title": f"Refactor and finalize: {task['title']}",
            "complexity": "simple",
            "tdd_phase": "refactor",
            "parent_task": task_id,
            "dependencies": [f"{task_id}b"],
        },
    ]
    return subtasks
```

## Step 3F: Task Failure Handler

```python
def on_worker_fail(task_id, error, state, graph):
    """Handle task failure with context exhaustion recovery."""

    output_file = state["tasks"][task_id].get("output_file")

    # CHECK FOR CONTEXT EXHAUSTION - attempt recovery
    if output_file and detect_context_exhaustion(output_file):
        print(f"⚠️ {task_id} failed due to context exhaustion - attempting recovery...")

        task = graph["tasks"][task_id]
        subtasks = split_task_for_retry(task, task_id)

        if subtasks:
            print(f"   ↪ Splitting into {len(subtasks)} subtasks: {[s['id'] for s in subtasks]}")

            # Inject subtasks into graph and state
            for subtask in subtasks:
                graph["tasks"][subtask["id"]] = subtask
                state["tasks"][subtask["id"]] = {
                    "status": "pending",
                    "blocked_by": subtask.get("dependencies", []),
                    "parent_task": task_id,
                }
                state["pending_tasks"].append(subtask["id"])

            # Mark original task as "split" not "failed"
            state["tasks"][task_id]["status"] = "split"
            state["tasks"][task_id]["subtasks"] = [s["id"] for s in subtasks]
            state["active_workers"].remove(task_id)

            # Update GitLab issue
            update_issue(
                project_id=get_project_id(),
                issue_iid=state["gitlab_issues"][task_id],
                labels=["split-for-context"]
            )
            add_issue_comment(
                project_id=get_project_id(),
                issue_iid=state["gitlab_issues"][task_id],
                body=f"⚠️ Context exhaustion detected. Task split into subtasks: {[s['id'] for s in subtasks]}"
            )

            return []  # No downstream blocking - subtasks will complete the work

    # REGULAR FAILURE HANDLING (not context exhaustion)

    # 1. Update task state
    state["tasks"][task_id]["status"] = "failed"
    state["tasks"][task_id]["completed_at"] = datetime.utcnow().isoformat()
    state["tasks"][task_id]["exit_code"] = 1
    state["tasks"][task_id]["error"] = error

    # 2. Move from active to failed
    state["active_workers"].remove(task_id)
    state["failed_tasks"].append(task_id)

    # 3. Check critical path impact
    critical_path = set(graph.get("critical_path", {}).get("tasks", []))
    if task_id in critical_path:
        state["metrics"]["critical_path_blocked"] = True
        print(f"⚠️ CRITICAL PATH BLOCKED: {task_id} failed")

    # 4. Identify blocked tasks
    blocked_by_this = []
    for dep_id in graph["tasks"][task_id].get("dependents", []):
        blocked_by_this.append(dep_id)
        # Recursively find all downstream blocked tasks
        blocked_by_this.extend(get_all_dependents(dep_id, graph))

    if blocked_by_this:
        print(f"   Tasks blocked by this failure: {blocked_by_this}")

    # 5. Update GitLab issue
    update_issue(
        project_id=get_project_id(),
        issue_iid=state["gitlab_issues"][task_id],
        labels=["failed", "needs-attention"]
    )
    add_issue_comment(
        project_id=get_project_id(),
        issue_iid=state["gitlab_issues"][task_id],
        body=f"❌ Worker failed with error:\n```\n{error}\n```"
    )

    print(f"❌ {task_id} failed: {error[:100]}...")
    return blocked_by_this
```

## Step 3F: Main Orchestrator Loop

```python
def run_orchestrator(graph, state, project_dir):
    """Main orchestrator loop - continuous worker model."""

    state["status"] = "running"
    max_workers = state["max_workers"]
    poll_interval = 5  # seconds

    print(f"\n{'='*60}")
    print(f"PARALLEL EXECUTION - Sprint {state['sprint_id']}")
    print(f"Max Workers: {max_workers}")
    print(f"Total Tasks: {state['metrics']['tasks_total']}")
    print(f"{'='*60}\n")

    while True:
        # 1. Poll for completed/failed workers
        completed, failed = poll_workers(state, graph)

        # 2. Handle completions
        for task_id, result in completed:
            on_worker_complete(task_id, result, state, graph)

        # 3. Handle failures
        for task_id, error in failed:
            on_worker_fail(task_id, error, state, graph)

        # 4. Check termination conditions
        total_done = len(state["completed_tasks"]) + len(state["failed_tasks"])
        if total_done == state["metrics"]["tasks_total"]:
            state["status"] = "completed"
            break

        # All remaining tasks are blocked by failed tasks
        if not state["pending_tasks"] and not state["active_workers"]:
            state["status"] = "blocked"
            print("\n⚠️ All remaining tasks are blocked by failed tasks.")
            break

        # 5. Calculate available slots
        available_slots = max_workers - len(state["active_workers"])

        # 6. Select and spawn new workers
        if available_slots > 0 and state["pending_tasks"]:
            next_tasks = select_next_tasks(state, graph, available_slots)
            for task_id in next_tasks:
                spawn_worker(task_id, graph["tasks"][task_id], graph, state, project_dir)

        # 7. Save state checkpoint
        save_execution_state(state)

        # 8. Display progress
        display_progress(state)

        # 9. Wait before next poll
        time.sleep(poll_interval)

    return state
```

---

# PHASE 4: MERGE COMPLETED BRANCHES AND CLEANUP WORKTREES

## Step 4A: Sequential Merge with Worktree Cleanup

```python
def merge_completed_branches(state, graph, project_dir):
    """Merge completed task branches and clean up their worktrees."""

    # Get merge order (topological sort of completed tasks)
    merge_order = [
        task_id for task_id in topological_sort(graph)
        if task_id in state["completed_tasks"]
        and not state["tasks"][task_id]["merged"]
    ]

    print(f"\n📦 Merging {len(merge_order)} completed branches...")

    for task_id in merge_order:
        branch = state["tasks"][task_id]["branch"]
        worktree_path = state["tasks"][task_id]["worktree_path"]
        print(f"\n  Merging {branch}...")

        # Fetch branch
        run_cmd(f"git fetch origin {branch}", cwd=project_dir)

        # Attempt merge
        result = run_cmd(f"git merge origin/{branch} --no-commit", cwd=project_dir, check=False)

        if result.returncode != 0:
            # Check for conflicts
            conflicts = run_cmd("git diff --name-only --diff-filter=U", cwd=project_dir).stdout.strip()
            if conflicts:
                print(f"  ⚠️ Conflicts in: {conflicts}")
                resolved = resolve_conflicts(conflicts, task_id, graph)
                if not resolved:
                    run_cmd("git merge --abort", cwd=project_dir)
                    state["tasks"][task_id]["merge_status"] = "conflict"
                    print(f"  ❌ Keeping worktree for manual resolution: {worktree_path}")
                    continue

        # Complete merge
        run_cmd("git add .", cwd=project_dir)
        run_cmd(f'git commit -m "Merge {branch} (parallel execution)\n\nTask: {task_id}"', cwd=project_dir)
        state["tasks"][task_id]["merged"] = True
        state["tasks"][task_id]["merge_status"] = "success"
        print(f"  ✓ Merged {task_id}")

        # Clean up worktree after successful merge
        cleanup_worktree(project_dir, worktree_path, task_id)

    # Final worktree prune
    run_cmd("git worktree prune", cwd=project_dir)

    # Clean up worktree base if empty
    worktree_base = state.get("worktree_base")
    if worktree_base and os.path.exists(worktree_base):
        try:
            os.rmdir(worktree_base)
            print(f"  🧹 Removed empty worktree base: {worktree_base}")
        except OSError:
            pass  # Not empty, some failed worktrees remain

    return state

def cleanup_worktree(project_dir, worktree_path, task_id):
    """Remove a worktree after successful merge."""
    if not os.path.exists(worktree_path):
        return

    print(f"  🧹 Removing worktree: {worktree_path}")
    result = run_cmd(f"git worktree remove -f {worktree_path}", cwd=project_dir, check=False)

    if result.returncode != 0:
        # Force remove if git worktree fails
        import shutil
        shutil.rmtree(worktree_path, ignore_errors=True)
        print(f"     (forced removal)")
```

## Step 4B: Conflict Resolution

```python
def resolve_conflicts(conflict_files, task_id, graph):
    """Attempt automatic conflict resolution."""

    for file_path in conflict_files.split('\n'):
        if not file_path:
            continue

        print(f"    Resolving: {file_path}")

        # Read conflicted file
        content = read_file(file_path)

        # Parse conflict markers
        conflicts = parse_conflict_markers(content)

        for conflict in conflicts:
            # Analyze both versions
            ours = conflict["ours"]
            theirs = conflict["theirs"]

            # Resolution strategies:
            # 1. If changes are in different parts, keep both
            # 2. If theirs adds new code ours doesn't have, prefer theirs
            # 3. If both modify same code, need manual review

            resolved = auto_resolve_conflict(ours, theirs, file_path)
            if not resolved:
                print(f"    ❌ Cannot auto-resolve {file_path}")
                return False

        # Write resolved file
        write_file(file_path, resolved_content)
        run_cmd(f"git add {file_path}")

    return True
```

---

# PHASE 5: VALIDATION

## Step 5A: Run Full Test Suite

```bash
# After all merges complete
echo "🧪 Running full test suite..."

# Python projects
pytest --cov=src --cov-report=term-missing --cov-report=json

# Check for failures
if [ $? -ne 0 ]; then
    echo "❌ Tests failed after merge"
    # Identify which merge broke tests (bisect)
    identify_breaking_merge
fi
```

## Step 5B: Coverage Verification

```python
def verify_coverage(state, min_coverage=80):
    """Verify test coverage meets threshold."""
    result = run_cmd("pytest --cov=src --cov-report=json")

    with open(".coverage.json") as f:
        coverage_data = json.load(f)

    coverage_pct = coverage_data["totals"]["percent_covered"]
    state["metrics"]["final_coverage"] = coverage_pct

    if coverage_pct < min_coverage:
        print(f"⚠️ Coverage {coverage_pct}% below threshold {min_coverage}%")
        return False

    print(f"✓ Coverage: {coverage_pct}%")
    return True
```

---

# PHASE 6: REPORT

## Step 6A: Generate Execution Report

```python
def generate_report(state, graph):
    """Generate parallel execution report."""

    duration = calculate_duration(state["started_at"], datetime.utcnow())
    critical_path = set(graph.get("critical_path", {}).get("tasks", []))

    report = f"""
## Parallel Execution Report

**Sprint**: {state['sprint_id']}
**Executed**: {datetime.utcnow().isoformat()}
**Duration**: {duration}
**Max Workers**: {state['max_workers']}

### Tasks Summary

| Task | Status | Model | Duration | Critical | Merged |
|------|--------|-------|----------|----------|--------|
"""

    for task_id in topological_sort(graph):
        ts = state["tasks"][task_id]
        status_emoji = {
            "completed": "✅",
            "failed": "❌",
            "blocked": "🔒",
            "pending": "⏳"
        }.get(ts["status"], "❓")

        task_duration = ""
        if ts["started_at"] and ts["completed_at"]:
            task_duration = calculate_duration(ts["started_at"], ts["completed_at"])

        report += f"| {task_id} | {status_emoji} {ts['status']} | {ts['model_used'] or '-'} | {task_duration} | {'✓' if task_id in critical_path else ''} | {'✓' if ts['merged'] else ''} |\n"

    report += f"""

### Statistics
- **Total Tasks**: {state['metrics']['tasks_total']}
- **Completed**: {len(state['completed_tasks'])} ✅
- **Failed**: {len(state['failed_tasks'])} ❌
- **Blocked**: {len(state['blocked_tasks'])} 🔒

### Critical Path Status
- **Blocked**: {'⚠️ YES' if state['metrics']['critical_path_blocked'] else '✓ No'}

### Quality Metrics
- **Tests**: {state['metrics'].get('test_count', 'N/A')} passing
- **Coverage**: {state['metrics'].get('final_coverage', 'N/A')}%

### GitLab Issues
{chr(10).join(f"- #{iid}: {tid}" for tid, iid in state['gitlab_issues'].items())}

### Failed Tasks (Need Attention)
"""

    if state["failed_tasks"]:
        for task_id in state["failed_tasks"]:
            error = state["tasks"][task_id].get("error", "Unknown error")
            report += f"- **{task_id}**: {error[:200]}\n"
    else:
        report += "_None_\n"

    report += f"""

### Next Steps
"""

    if len(state['completed_tasks']) == state['metrics']['tasks_total']:
        report += "Sprint complete! Run `/session:end` to finalize.\n"
    elif state['failed_tasks']:
        report += f"Review failed tasks and re-run `/session:parallel --resume` after fixing.\n"
    elif state['blocked_tasks']:
        report += f"Blocked tasks: {state['blocked_tasks']}. Resolve dependencies first.\n"

    return report
```

---

# STATE MANAGEMENT

## Directory Structure

```
state/
├── workers/
│   ├── worker-T-001.json    # Output from worker T-001
│   ├── worker-T-002.json    # Output from worker T-002
│   └── worker-T-003.json    # Output from worker T-003
├── parallel_execution.json   # Current execution state
└── current_state.md          # Updated after execution
```

## Execution State Schema

```json
{
  "sprint_id": "05",
  "started_at": "2025-01-15T10:00:00Z",
  "status": "running",
  "max_workers": 3,
  "worktree_base": "/Users/user/Code/project-worktrees",
  "tasks": {
    "T-001": {
      "status": "completed",
      "blocked_by": [],
      "worker_pid": 12345,
      "started_at": "2025-01-15T10:00:05Z",
      "completed_at": "2025-01-15T10:15:30Z",
      "branch": "feature/sprint-05-t-001",
      "worktree_path": "/Users/user/Code/project-worktrees/sprint-05-t-001",
      "model_used": "sonnet",
      "exit_code": 0,
      "merged": true,
      "output_file": "state/workers/worker-T-001.json"
    },
    "T-002": {
      "status": "in_progress",
      "blocked_by": [],
      "worker_pid": 12346,
      "started_at": "2025-01-15T10:00:10Z",
      "completed_at": null,
      "branch": "feature/sprint-05-t-002",
      "worktree_path": "/Users/user/Code/project-worktrees/sprint-05-t-002",
      "model_used": "haiku",
      "exit_code": null,
      "merged": false,
      "output_file": "state/workers/worker-T-002.json"
    },
    "T-003": {
      "status": "blocked",
      "blocked_by": ["T-001", "T-002"],
      "worker_pid": null,
      "started_at": null,
      "completed_at": null,
      "branch": "feature/sprint-05-t-003",
      "worktree_path": "/Users/user/Code/project-worktrees/sprint-05-t-003",
      "model_used": null,
      "exit_code": null,
      "merged": false,
      "output_file": null
    }
  },
  "active_workers": ["T-002"],
  "completed_tasks": ["T-001"],
  "failed_tasks": [],
  "pending_tasks": [],
  "blocked_tasks": ["T-003"],
  "gitlab_issues": {
    "T-001": 42,
    "T-002": 43,
    "T-003": 44
  },
  "metrics": {
    "tasks_total": 3,
    "tasks_completed": 1,
    "critical_path_blocked": false,
    "final_coverage": null
  }
}
```

**NEW fields**:
- `worktree_base`: Base directory for all worktrees (sibling to project)
- `worktree_path` (per task): Full path to task's isolated worktree

---

# ERROR HANDLING

## Worker Failure

When a worker fails:
1. Log failure with worker output
2. Update GitLab issue with `failed` label
3. Continue with non-blocked tasks
4. Report all failures at end

## Critical Path Failure

If a critical path task fails:
```
⚠️ CRITICAL PATH BLOCKED

Task T-002 on the critical path has failed.
This will delay sprint completion.

Failed task: T-002 - "Implement user authentication"
Error: Tests failed - missing database migration

Options:
1. Fix T-002 manually and retry: /session:parallel --resume
2. Continue with non-blocked tasks (already happening)
3. Abort and review: Ctrl+C

Continuing with non-blocked tasks...
```

## Merge Failure

If automatic merge fails:
1. Abort the problematic merge
2. Mark task as `merge-conflict`
3. Continue with other merges
4. Report conflicts at end for manual resolution

## Context Exhaustion

If a worker exhausts context:
1. Mark task as `failed` with reason
2. Recommend splitting task in `/session:plan`
3. Continue with other tasks

---

# DRY RUN MODE

When `--dry-run` is specified:

```markdown
## Dry Run - Sprint {N} Parallel Execution

### Task Graph Loaded
- Tasks: {TOTAL}
- Pending: {PENDING}
- Blocked: {BLOCKED}

### GitLab Issues (Would Create)
| Task | Title | Labels |
|------|-------|--------|
| T-001 | Create user model | sprint-05, backend, pending |
| T-002 | Add API endpoint | sprint-05, backend, pending |

### Worker Schedule (Would Spawn)
**Wave 1** (immediate):
- T-001: backend, standard, sonnet
- T-003: tests, simple, haiku

**Wave 2** (after T-001 completes):
- T-002: backend, complex, opus

### Critical Path
T-001 → T-002 → T-004 (estimated 4.5h)

No workers spawned. Add --no-dry-run to execute.
```

---

# USAGE EXAMPLES

## Fresh Start
```bash
/session:parallel 5
```

## Resume from Previous
```bash
/session:parallel 5 --resume
```

## Dry Run
```bash
/session:parallel 5 --dry-run
```

## Custom Worker Count
```bash
/session:parallel 5 --max-workers 2
```
