#!/bin/bash
# migrate_to_beads.sh
# Migrate existing task_graph.json to beads issues
#
# Usage:
#   ./scripts/migrate_to_beads.sh [path/to/task_graph.json]
#
# If no path provided, searches for:
#   - .specify/specs/*/tasks.md
#   - sprints/sprint_*/task_graph.json
#   - state/task_graph.json

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}Beads Migration Script${NC}"
echo "======================================"

# Check beads is installed
if ! command -v bd &> /dev/null; then
    echo -e "${RED}Error: beads (bd) is not installed${NC}"
    echo "Install with: npm install -g @beads/bd"
    exit 1
fi

# Initialize beads if not already done
if [ ! -d ".beads" ]; then
    echo -e "${YELLOW}Initializing beads...${NC}"
    bd init
    echo -e "${GREEN}✓ Beads initialized${NC}"
else
    echo -e "${GREEN}✓ Beads already initialized${NC}"
fi

# Find task graph file
TASK_GRAPH=""
if [ -n "$1" ]; then
    TASK_GRAPH="$1"
elif [ -f "state/task_graph.json" ]; then
    TASK_GRAPH="state/task_graph.json"
else
    # Search for sprint task graphs
    TASK_GRAPH=$(find sprints -name "task_graph.json" 2>/dev/null | head -1)
fi

if [ -z "$TASK_GRAPH" ] || [ ! -f "$TASK_GRAPH" ]; then
    echo -e "${YELLOW}No task_graph.json found. Checking for tasks.md...${NC}"

    TASKS_MD=$(find .specify/specs -name "tasks.md" 2>/dev/null | head -1)
    if [ -n "$TASKS_MD" ]; then
        echo -e "${YELLOW}Found tasks.md at: $TASKS_MD${NC}"
        echo "This script migrates task_graph.json format."
        echo "For tasks.md, run /project:scrum to regenerate beads issues."
        exit 0
    fi

    echo -e "${RED}Error: No task graph file found${NC}"
    echo "Provide path as argument: ./scripts/migrate_to_beads.sh path/to/task_graph.json"
    exit 1
fi

echo -e "${GREEN}Using task graph: $TASK_GRAPH${NC}"

# Create mapping file for old ID -> beads ID
MAPPING_FILE=".beads/migration_map.txt"
> "$MAPPING_FILE"

# Extract sprint ID from path
SPRINT_ID=$(echo "$TASK_GRAPH" | grep -oE 'sprint[_-]?[0-9]+' | grep -oE '[0-9]+' || echo "01")
echo "Sprint ID: $SPRINT_ID"

# Count tasks
TASK_COUNT=$(jq '.tasks | length' "$TASK_GRAPH")
echo -e "${GREEN}Found $TASK_COUNT tasks to migrate${NC}"
echo ""

# Create epic for the sprint
echo "Creating sprint epic..."
EPIC_ID=$(bd create "Sprint $SPRINT_ID Tasks" \
    --type epic \
    --priority 1 \
    --json | jq -r '.id')
echo -e "${GREEN}✓ Created epic: $EPIC_ID${NC}"

# Migrate each task
echo ""
echo "Migrating tasks..."

jq -c '.tasks | to_entries[]' "$TASK_GRAPH" | while read -r task_entry; do
    OLD_ID=$(echo "$task_entry" | jq -r '.key')
    TITLE=$(echo "$task_entry" | jq -r '.value.title')
    DESC=$(echo "$task_entry" | jq -r '.value.description // ""')
    COMPLEXITY=$(echo "$task_entry" | jq -r '.value.complexity // "standard"')
    DOMAIN=$(echo "$task_entry" | jq -r '.value.domain // "backend"')
    PRIORITY=$(echo "$task_entry" | jq -r '.value.priority // 2')

    # Create acceptance criteria from task
    AC=$(echo "$task_entry" | jq -r '.value.acceptance_criteria // [] | .[]' | sed 's/^/- /' | tr '\n' ';' | sed 's/;$//')

    # Map complexity to estimated minutes
    case "$COMPLEXITY" in
        "simple") EST_MINS=60 ;;
        "standard") EST_MINS=120 ;;
        "complex") EST_MINS=240 ;;
        *) EST_MINS=120 ;;
    esac

    echo "  Migrating: $OLD_ID - $TITLE"

    # Create beads issue
    NEW_ID=$(bd create "$OLD_ID: $TITLE" \
        --type task \
        --priority "$PRIORITY" \
        --description "$DESC" \
        -e "$EST_MINS" \
        --json | jq -r '.id')

    # Add to epic
    bd dep add "$NEW_ID" "$EPIC_ID" --type parent-child 2>/dev/null || true

    # Add labels
    bd label add "$NEW_ID" "domain:$DOMAIN" 2>/dev/null || true
    bd label add "$NEW_ID" "complexity:$COMPLEXITY" 2>/dev/null || true
    bd label add "$NEW_ID" "migrated" 2>/dev/null || true

    # Save mapping
    echo "$OLD_ID:$NEW_ID" >> "$MAPPING_FILE"

    echo -e "    ${GREEN}✓ Created: $NEW_ID${NC}"
done

echo ""
echo "Adding dependencies..."

# Second pass: add dependencies using the mapping
jq -c '.tasks | to_entries[]' "$TASK_GRAPH" | while read -r task_entry; do
    OLD_ID=$(echo "$task_entry" | jq -r '.key')
    DEPS=$(echo "$task_entry" | jq -r '.value.dependencies // [] | .[]')

    if [ -z "$DEPS" ]; then
        continue
    fi

    # Look up new ID from mapping
    NEW_ID=$(grep "^$OLD_ID:" "$MAPPING_FILE" | cut -d: -f2)

    if [ -z "$NEW_ID" ]; then
        echo -e "  ${YELLOW}Warning: No mapping for $OLD_ID${NC}"
        continue
    fi

    for DEP_OLD_ID in $DEPS; do
        DEP_NEW_ID=$(grep "^$DEP_OLD_ID:" "$MAPPING_FILE" | cut -d: -f2)

        if [ -z "$DEP_NEW_ID" ]; then
            echo -e "  ${YELLOW}Warning: Dependency $DEP_OLD_ID not found${NC}"
            continue
        fi

        echo "  Adding: $NEW_ID blocked by $DEP_NEW_ID"
        bd dep add "$NEW_ID" "$DEP_NEW_ID" --type blocks 2>/dev/null || true
    done
done

# Sync to git
echo ""
echo "Syncing to git..."
bd sync

# Verification
echo ""
echo "======================================"
echo -e "${GREEN}Migration Complete!${NC}"
echo ""

BEADS_COUNT=$(bd list --json | jq 'length')
READY_COUNT=$(bd ready --json | jq 'length')

echo "Summary:"
echo "  - Tasks migrated: $TASK_COUNT"
echo "  - Beads issues created: $BEADS_COUNT"
echo "  - Ready tasks: $READY_COUNT"
echo ""
echo "Mapping file: $MAPPING_FILE"
echo ""
echo "Next steps:"
echo "  1. Review: bd list"
echo "  2. Check ready: bd ready"
echo "  3. Run parallel: /session:parallel"
