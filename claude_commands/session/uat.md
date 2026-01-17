---
description: Execute UAT tests using browser automation (Playwright or Chrome DevTools)
model: claude-opus-4-5
---

# UAT Execution

You are executing **User Acceptance Tests** for a feature using browser automation. This command supports two execution modes:

- **Automated Mode**: Playwright for CI/CD and regression testing
- **Interactive Mode**: Chrome DevTools Protocol for exploratory testing and debugging

**IMPORTANT**: Use ultrathink and extended thinking for all complex reasoning, planning, and decision-making throughout this process.

---

# ARGUMENTS

```
/session:uat [feature-name] [--mode automated|interactive|both] [--env staging|local] [--scenario UAT-xxx]
```

- `feature-name`: Name of feature to test (matches `.specify/specs/{feature-name}/`)
- `--mode`: Execution mode
  - `automated` (default): Run Playwright tests
  - `interactive`: Use Chrome DevTools for real-time testing
  - `both`: Run automated first, then interactive for failed scenarios
- `--env`: Target environment (`local` or `staging`, default: `local`)
- `--scenario`: Run specific scenario only (e.g., `--scenario UAT-001`)

---

# PHASE 1: ENVIRONMENT VALIDATION

## Step 1A: Validate Feature Exists

```bash
FEATURE_NAME="${1:-}"
MODE="${2:-automated}"
ENV="${3:-local}"

if [ -z "$FEATURE_NAME" ]; then
    echo "❌ Error: Feature name required"
    echo "   Usage: /session:uat <feature-name> [--mode automated|interactive|both] [--env staging|local]"
    exit 1
fi

FEATURE_DIR=".specify/specs/${FEATURE_NAME}"

if [ ! -d "$FEATURE_DIR" ]; then
    echo "❌ Error: Feature not found at ${FEATURE_DIR}"
    echo "   Available features:"
    ls -1 .specify/specs/ 2>/dev/null || echo "   (none)"
    exit 1
fi
```

## Step 1B: Validate UAT Plan Exists

```bash
UAT_PLAN="${FEATURE_DIR}/uat-plan.md"

if [ ! -f "$UAT_PLAN" ]; then
    echo "❌ Error: UAT plan not found at ${UAT_PLAN}"
    echo "   Run /project:uat ${FEATURE_NAME} to generate UAT plan"
    exit 1
fi

echo "✅ UAT plan found: ${UAT_PLAN}"
```

## Step 1C: Validate Environment Variables

```python
import os
import sys

def validate_environment(env_type):
    """Validate required environment variables are set."""

    required_vars = {
        "local": ["API_BASE_URL"],
        "staging": ["API_BASE_URL", "AUTH_TEST_USER", "AUTH_TEST_PASSWORD"]
    }

    missing = []
    for var in required_vars.get(env_type, required_vars["local"]):
        if not os.environ.get(var):
            missing.append(var)

    if missing:
        print("❌ Missing required environment variables:")
        for var in missing:
            print(f"   - {var}")
        print()
        print("Set these in your .env file or export them:")
        for var in missing:
            print(f"   export {var}=<value>")
        sys.exit(1)

    print("✅ Environment validation passed")
    print(f"   API_BASE_URL: {os.environ.get('API_BASE_URL')}")
    print(f"   Environment: {env_type}")

validate_environment(os.environ.get("UAT_ENV", "local"))
```

---

# PHASE 2: LOAD UAT PLAN

## Step 2A: Parse UAT Plan

```python
import re
from dataclasses import dataclass
from typing import List, Optional

@dataclass
class UATScenario:
    id: str
    title: str
    user_story: str
    priority: str
    steps: List[dict]
    api_validations: List[dict]
    status: str = "not_started"

def parse_uat_plan(plan_path):
    """Parse UAT plan markdown into structured scenarios."""

    with open(plan_path) as f:
        content = f.read()

    scenarios = []

    # Pattern to match UAT scenario blocks
    scenario_pattern = r'## (UAT-\d+): ([^\n]+)\n(.*?)(?=## UAT-|\Z)'

    for match in re.finditer(scenario_pattern, content, re.DOTALL):
        scenario_id = match.group(1)
        title = match.group(2).strip()
        body = match.group(3)

        # Extract user story reference
        us_match = re.search(r'\*\*User Story\*\*:\s*(US-\d+)', body)
        user_story = us_match.group(1) if us_match else "Unknown"

        # Extract priority
        priority_match = re.search(r'\*\*Priority\*\*:\s*(\w+)', body)
        priority = priority_match.group(1) if priority_match else "Medium"

        # Extract test steps from table
        steps = extract_steps_from_table(body)

        # Extract API validations
        api_validations = extract_api_validations(body)

        scenarios.append(UATScenario(
            id=scenario_id,
            title=title,
            user_story=user_story,
            priority=priority,
            steps=steps,
            api_validations=api_validations
        ))

    return scenarios

def extract_steps_from_table(body):
    """Extract test steps from markdown table."""
    steps = []
    # Match table rows: | 1 | Action | Expected | API |
    step_pattern = r'\|\s*(\d+)\s*\|\s*([^|]+)\s*\|\s*([^|]+)\s*\|\s*([^|]*)\s*\|'

    for match in re.finditer(step_pattern, body):
        steps.append({
            "number": int(match.group(1)),
            "action": match.group(2).strip(),
            "expected": match.group(3).strip(),
            "api_call": match.group(4).strip() or None
        })

    return steps

def extract_api_validations(body):
    """Extract API validation requirements."""
    validations = []
    # Match API validation table
    api_pattern = r'\|\s*(\d+)\s*\|\s*(GET|POST|PUT|DELETE|PATCH)\s*\|\s*([^|]+)\s*\|'

    for match in re.finditer(api_pattern, body):
        validations.append({
            "step": int(match.group(1)),
            "method": match.group(2),
            "endpoint": match.group(3).strip()
        })

    return validations
```

## Step 2B: Display Execution Plan

```python
def display_execution_plan(scenarios, mode, specific_scenario=None):
    """Display what will be executed."""

    if specific_scenario:
        scenarios = [s for s in scenarios if s.id == specific_scenario]
        if not scenarios:
            print(f"❌ Scenario {specific_scenario} not found")
            return None

    print("\n" + "=" * 60)
    print("UAT EXECUTION PLAN")
    print("=" * 60)
    print(f"\nMode: {mode}")
    print(f"Scenarios: {len(scenarios)}")
    print()

    # Group by priority
    by_priority = {"Critical": [], "High": [], "Medium": [], "Low": []}
    for s in scenarios:
        by_priority.get(s.priority, by_priority["Medium"]).append(s)

    for priority in ["Critical", "High", "Medium", "Low"]:
        if by_priority[priority]:
            print(f"\n{priority} Priority:")
            for s in by_priority[priority]:
                print(f"  - {s.id}: {s.title}")
                print(f"    Steps: {len(s.steps)}, API Validations: {len(s.api_validations)}")

    print("\n" + "=" * 60)

    return scenarios

scenarios = parse_uat_plan(UAT_PLAN)
scenarios = display_execution_plan(scenarios, MODE, SPECIFIC_SCENARIO)
```

---

# PHASE 3: AUTOMATED EXECUTION (Playwright)

## Step 3A: Check Playwright Installation

```bash
if [ "$MODE" = "automated" ] || [ "$MODE" = "both" ]; then
    if ! command -v npx &> /dev/null; then
        echo "❌ npx not found. Install Node.js first."
        exit 1
    fi

    if ! npx playwright --version &> /dev/null; then
        echo "⚠️ Playwright not installed. Installing..."
        npm install -D @playwright/test
        npx playwright install
    fi

    echo "✅ Playwright ready"
fi
```

## Step 3B: Run Playwright Tests

```python
import subprocess
import json
import os
from datetime import datetime

def run_playwright_tests(feature_name, scenarios, env_type):
    """Execute Playwright E2E tests."""

    e2e_dir = f".specify/specs/{feature_name}/e2e"
    results_dir = f".specify/specs/{feature_name}/uat-results"

    os.makedirs(results_dir, exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    print("\n🎭 Running Playwright Tests...")
    print("-" * 40)

    # Build Playwright command
    cmd = [
        "npx", "playwright", "test",
        e2e_dir,
        "--reporter=json",
        f"--output={results_dir}/playwright-results",
    ]

    # Add environment
    env = os.environ.copy()
    env["UAT_ENV"] = env_type

    try:
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            env=env,
            timeout=600  # 10 minute timeout
        )

        # Parse JSON results
        json_output = result.stdout
        try:
            test_results = json.loads(json_output)
        except json.JSONDecodeError:
            test_results = {"error": "Could not parse results"}

        # Generate report
        report = {
            "timestamp": timestamp,
            "mode": "automated",
            "feature": feature_name,
            "environment": env_type,
            "passed": result.returncode == 0,
            "test_results": test_results,
            "stdout": result.stdout,
            "stderr": result.stderr
        }

        # Save JSON report
        report_path = f"{results_dir}/uat_{timestamp}.json"
        with open(report_path, "w") as f:
            json.dump(report, f, indent=2)

        # Display summary
        if result.returncode == 0:
            print("\n✅ All Playwright tests PASSED")
        else:
            print("\n❌ Some Playwright tests FAILED")
            print(result.stderr)

        return report

    except subprocess.TimeoutExpired:
        print("\n❌ Playwright tests timed out after 10 minutes")
        return {"passed": False, "error": "Timeout"}

    except Exception as e:
        print(f"\n❌ Error running Playwright: {e}")
        return {"passed": False, "error": str(e)}

if MODE in ["automated", "both"]:
    playwright_report = run_playwright_tests(FEATURE_NAME, scenarios, ENV)
```

---

# PHASE 4: INTERACTIVE EXECUTION (Chrome DevTools)

## Step 4A: Initialize Chrome Connection

When running in interactive mode, use Claude's Chrome integration for real-time browser control.

```python
def run_interactive_uat(scenarios, feature_name, env_type):
    """
    Execute UAT scenarios interactively using Chrome DevTools Protocol.

    This uses the mcp__claude-in-chrome__* tools for:
    - Real-time browser control
    - Screenshot capture at each step
    - API call monitoring
    - GIF recording of test execution
    """

    results_dir = f".specify/specs/{feature_name}/uat-results"
    os.makedirs(f"{results_dir}/screenshots", exist_ok=True)

    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")

    print("\n🌐 Starting Interactive UAT...")
    print("-" * 40)
    print("Using Chrome DevTools Protocol for real-time testing")
    print()

    # Track results
    scenario_results = []

    for scenario in scenarios:
        print(f"\n📋 Scenario: {scenario.id} - {scenario.title}")
        print(f"   User Story: {scenario.user_story}")
        print(f"   Steps: {len(scenario.steps)}")

        # Instructions for interactive execution
        # (These will be performed using Chrome tools)

        scenario_result = {
            "id": scenario.id,
            "title": scenario.title,
            "steps": [],
            "api_calls": [],
            "screenshots": [],
            "passed": None
        }

        scenario_results.append(scenario_result)

    return {
        "timestamp": timestamp,
        "mode": "interactive",
        "feature": feature_name,
        "scenarios": scenario_results
    }
```

## Step 4B: Chrome Automation Instructions

When using interactive mode, execute these steps with Chrome tools:

```markdown
## Interactive UAT Execution Protocol

For each UAT scenario:

### 1. Setup
- Use `mcp__claude-in-chrome__tabs_context_mcp` to get current tab state
- Create new tab with `mcp__claude-in-chrome__tabs_create_mcp` for testing
- Start GIF recording with `mcp__claude-in-chrome__gif_creator`

### 2. Execute Steps
For each step in the scenario:

a. **Take Action**
   - Use appropriate Chrome tool for the action type:
     - Navigation: `mcp__claude-in-chrome__tabs_navigate_mcp`
     - Click: `mcp__claude-in-chrome__mouse_click_mcp`
     - Type: `mcp__claude-in-chrome__type_text_mcp`
     - Select: `mcp__claude-in-chrome__select_option_mcp`

b. **Capture Evidence**
   - Take screenshot: `mcp__claude-in-chrome__screenshot_mcp`
   - Record console: `mcp__claude-in-chrome__read_console_messages`

c. **Verify Expected Result**
   - Check page content for expected elements
   - Verify no console errors

### 3. Monitor API Calls
- Use `mcp__claude-in-chrome__read_console_messages` with network filter
- Check for:
  - Correct API host used
  - Expected endpoints called
  - No hardcoded localhost URLs

### 4. Record Results
- Stop GIF recording
- Save screenshots to uat-results/screenshots/
- Log pass/fail for each step

### 5. Generate Report
- Create uat_{timestamp}.md with:
  - Scenario results
  - Screenshots embedded
  - API call log
  - Console errors (if any)
```

## Step 4C: API Host Validation During Interactive Testing

```python
def validate_api_calls_interactive(console_messages, expected_api_host):
    """
    Validate API calls from console/network logs.

    Returns violations if frontend calls wrong API host.
    """

    violations = []
    api_calls = []

    # Parse network-related console messages
    for msg in console_messages:
        # Look for fetch/XHR calls
        if '/api/' in msg or 'fetch' in msg.lower():
            api_calls.append(msg)

            # Check for localhost
            if 'localhost' in msg and expected_api_host != 'localhost':
                violations.append({
                    "type": "hardcoded_localhost",
                    "message": msg
                })

            # Check for wrong host
            if expected_api_host not in msg and '/api/' in msg:
                violations.append({
                    "type": "wrong_host",
                    "message": msg,
                    "expected": expected_api_host
                })

    return {
        "api_calls": api_calls,
        "violations": violations,
        "valid": len(violations) == 0
    }
```

---

# PHASE 5: REPORT GENERATION

## Step 5A: Generate UAT Report

```python
def generate_uat_report(feature_name, results, mode):
    """Generate comprehensive UAT report in markdown format."""

    results_dir = f".specify/specs/{feature_name}/uat-results"
    timestamp = results.get("timestamp", datetime.now().strftime("%Y%m%d_%H%M%S"))

    report_lines = [
        f"# UAT Report: {feature_name}",
        "",
        f"**Generated**: {datetime.now().isoformat()}",
        f"**Mode**: {mode}",
        f"**Environment**: {results.get('environment', 'unknown')}",
        f"**Overall Result**: {'✅ PASSED' if results.get('passed') else '❌ FAILED'}",
        "",
        "---",
        "",
        "## Summary",
        "",
    ]

    # Add scenario results
    if mode == "automated":
        report_lines.extend([
            "### Playwright Test Results",
            "",
            "| Scenario | Status | Duration |",
            "|----------|--------|----------|",
        ])

        # Parse playwright results
        test_results = results.get("test_results", {})
        # Add rows...

    elif mode == "interactive":
        report_lines.extend([
            "### Interactive Test Results",
            "",
            "| Scenario | Steps | API Checks | Status |",
            "|----------|-------|------------|--------|",
        ])

        for scenario in results.get("scenarios", []):
            status = "✅" if scenario.get("passed") else "❌" if scenario.get("passed") is False else "⏳"
            report_lines.append(
                f"| {scenario['id']} | {len(scenario.get('steps', []))} | "
                f"{len(scenario.get('api_calls', []))} | {status} |"
            )

    # API Validation Section
    report_lines.extend([
        "",
        "## API Host Validation",
        "",
    ])

    api_violations = results.get("api_violations", [])
    if api_violations:
        report_lines.extend([
            "⚠️ **API Host Violations Detected**",
            "",
            "| Type | Details |",
            "|------|---------|",
        ])
        for v in api_violations:
            report_lines.append(f"| {v['type']} | {v.get('message', '')} |")
    else:
        report_lines.append("✅ No API host violations detected")

    # Evidence Section
    report_lines.extend([
        "",
        "## Evidence",
        "",
        "### Screenshots",
        "",
    ])

    screenshots_dir = f"{results_dir}/screenshots"
    if os.path.isdir(screenshots_dir):
        for img in os.listdir(screenshots_dir):
            if img.endswith(('.png', '.jpg', '.gif')):
                report_lines.append(f"![{img}](screenshots/{img})")

    # Write report
    report_path = f"{results_dir}/uat_{timestamp}.md"
    with open(report_path, "w") as f:
        f.write("\n".join(report_lines))

    print(f"\n📄 Report generated: {report_path}")
    return report_path
```

## Step 5B: Update UAT Plan Status

```python
def update_uat_plan_status(plan_path, results):
    """Update UAT plan with test execution status."""

    with open(plan_path) as f:
        content = f.read()

    # Update traceability matrix status
    for scenario_id, passed in results.get("scenario_status", {}).items():
        status = "Passed ✅" if passed else "Failed ❌"
        # Replace "Not Started" with actual status
        content = re.sub(
            rf'(\| {scenario_id} \|[^|]+\|[^|]+\|)\s*Not Started\s*\|',
            rf'\1 {status} |',
            content
        )

    with open(plan_path, "w") as f:
        f.write(content)

    print(f"✅ Updated UAT plan status: {plan_path}")
```

---

# PHASE 6: COMPLETION

## Step 6A: Display Final Summary

```python
def display_final_summary(results, mode):
    """Display final UAT execution summary."""

    print("\n" + "=" * 60)
    print("UAT EXECUTION COMPLETE")
    print("=" * 60)

    passed = results.get("passed", False)

    if passed:
        print("\n✅ UAT PASSED")
    else:
        print("\n❌ UAT FAILED")

    print(f"\nMode: {mode}")
    print(f"Environment: {results.get('environment', 'unknown')}")

    # Scenario summary
    scenarios = results.get("scenarios", [])
    passed_count = sum(1 for s in scenarios if s.get("passed"))
    failed_count = sum(1 for s in scenarios if s.get("passed") is False)

    print(f"\nScenarios: {len(scenarios)} total")
    print(f"  ✅ Passed: {passed_count}")
    print(f"  ❌ Failed: {failed_count}")
    print(f"  ⏳ Not run: {len(scenarios) - passed_count - failed_count}")

    # API validation summary
    api_violations = results.get("api_violations", [])
    if api_violations:
        print(f"\n⚠️ API Host Violations: {len(api_violations)}")
        print("   (Frontend may be calling wrong API endpoints)")
    else:
        print("\n✅ API Host Validation: Passed")

    # Next steps
    print("\n" + "-" * 40)
    print("Next Steps:")

    if passed:
        print("  1. Review UAT report")
        print("  2. Run /session:end to close sprint")
    else:
        print("  1. Review failed scenarios in UAT report")
        print("  2. Fix issues in code")
        print("  3. Re-run /session:uat to verify fixes")

    print("=" * 60)
```

---

# OUTPUT FILES

```
.specify/
└── specs/
    └── {feature-name}/
        ├── uat-plan.md                      # ← Input (from /project:uat)
        └── uat-results/                     # ← OUTPUT
            ├── uat_{timestamp}.json         # Machine-readable results
            ├── uat_{timestamp}.md           # Human-readable report
            ├── screenshots/                 # Step screenshots
            │   ├── UAT-001_step1.png
            │   ├── UAT-001_step2.png
            │   └── ...
            └── recordings/                  # GIF recordings (interactive mode)
                └── UAT-001_full.gif
```

---

# EXECUTION MODES COMPARISON

| Feature | Automated (Playwright) | Interactive (Chrome) |
|---------|------------------------|---------------------|
| Speed | Fast, parallel | Slower, sequential |
| CI/CD | ✅ Ideal | ❌ Not suitable |
| Debugging | Limited | ✅ Full visibility |
| Exploratory | ❌ No | ✅ Yes |
| Evidence | Screenshots only | Screenshots + GIFs |
| API Monitoring | Via fixtures | Via console |
| Best For | Regression | Debugging, demos |

---

# INTEGRATION WITH WORKFLOW

```
/project:uat                    /session:uat
├── Generate UAT plan  ───────> ├── Load UAT plan
├── Generate E2E tests          ├── Validate environment
└── Generate fixtures           ├── Execute tests
                                ├── Monitor API calls
                                ├── Capture evidence
                                └── Generate report
                                           │
                                           v
                                    /session:end
                                    └── UAT gate validation
```

---

**END OF /session:uat COMMAND**
