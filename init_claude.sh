#!/usr/bin/env bash
#
# init_claude.sh - Initialize Claude Code directory structure with symlinks
#
# Usage: ./init_claude.sh <target_path>
#

set -euo pipefail

# Source directory for symlinks is the directory of this script
SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

usage() {
    echo "Usage: $0 <target_path>"
    echo ""
    echo "Initialize Claude Code directory structure with symlinks."
    echo ""
    echo "Arguments:"
    echo "  target_path    The target directory where .claude will be created"
    echo ""
    echo "Example:"
    echo "  $0 ~/Code/my-project"
    exit 1
}

create_symlink_dir() {
    local source="$1"
    local target="$2"

    if [[ -L "$target" ]]; then
        log_warn "Symlink already exists: $target"
    elif [[ -d "$target" ]]; then
        log_warn "Directory already exists (not a symlink): $target"
    else
        if [[ -d "$source" ]]; then
            ln -s "$source" "$target"
            log_info "Created symlink: $target -> $source"
        else
            log_error "Source directory does not exist: $source"
            return 1
        fi
    fi
}

create_symlink_file() {
    local source="$1"
    local target="$2"

    if [[ -L "$target" ]]; then
        log_warn "Symlink already exists: $target"
    elif [[ -f "$target" ]]; then
        log_warn "File already exists (not a symlink): $target"
    else
        if [[ -f "$source" ]]; then
            ln -s "$source" "$target"
            log_info "Created symlink: $target -> $source"
        else
            log_error "Source file does not exist: $source"
            return 1
        fi
    fi
}

main() {
    # Check for required argument
    if [[ $# -ne 1 ]]; then
        log_error "Missing required argument: target_path"
        usage
    fi

    local target_path="$1"

    # Expand ~ if present
    target_path="${target_path/#\~/$HOME}"

    # Convert to absolute path
    target_path="$(cd "$target_path" 2>/dev/null && pwd || echo "$target_path")"

    # Validate target path exists
    if [[ ! -d "$target_path" ]]; then
        log_error "Target path does not exist: $target_path"
        exit 1
    fi

    # Validate source directory exists
    if [[ ! -d "$SOURCE_DIR" ]]; then
        log_error "Source directory does not exist: $SOURCE_DIR"
        exit 1
    fi

    local claude_dir="$target_path/.claude"

    # Step 1: Create .claude directory
    if [[ ! -d "$claude_dir" ]]; then
        mkdir -p "$claude_dir"
        log_info "Created directory: $claude_dir"
    else
        log_info "Directory already exists: $claude_dir"
    fi

    # Step 2: Create subdirectories
    for subdir in agents commands skills scripts; do
        local dir_path="$claude_dir/$subdir"
        if [[ ! -d "$dir_path" ]]; then
            mkdir -p "$dir_path"
            log_info "Created directory: $dir_path"
        else
            log_info "Directory already exists: $dir_path"
        fi
    done

    # Step 3-5: Create symlinked directories in commands
    log_info "Creating command directory symlinks..."
    create_symlink_dir "$SOURCE_DIR/commands/project" "$claude_dir/commands/project"
    create_symlink_dir "$SOURCE_DIR/commands/session" "$claude_dir/commands/session"
    create_symlink_dir "$SOURCE_DIR/commands/scripts" "$claude_dir/commands/scripts"

    # Step 6: Create symlinked file for validate-gitlab-ci.md
    log_info "Creating command file symlinks..."
    create_symlink_file "$SOURCE_DIR/commands/validate-gitlab-ci.md" "$claude_dir/commands/validate-gitlab-ci.md"

    # Step 7: Create symlink for scripts directory (beads migration, etc.)
    log_info "Creating scripts symlinks..."
    create_symlink_file "$SOURCE_DIR/scripts/migrate_to_beads.sh" "$claude_dir/scripts/migrate_to_beads.sh"

    # Core agents for /session:* workflow
    log_info "Creating core workflow agent symlinks..."
    create_symlink_file "$SOURCE_DIR/agents/sprint-worker.md" "$claude_dir/agents/sprint-worker.md"
    create_symlink_file "$SOURCE_DIR/agents/tdd-modular-architect.md" "$claude_dir/agents/tdd-modular-architect.md"

    # Domain expert agents
    log_info "Creating domain expert agent symlinks..."
    create_symlink_file "$SOURCE_DIR/agents/ai_engineering-expert.md" "$claude_dir/agents/ai_engineering-expert.md"
    create_symlink_file "$SOURCE_DIR/agents/postgresql-expert.md" "$claude_dir/agents/postgresql-expert.md"
    create_symlink_file "$SOURCE_DIR/agents/security-expert.md" "$claude_dir/agents/security-expert.md"
    create_symlink_file "$SOURCE_DIR/agents/backend-systems-architect-expert.md" "$claude_dir/agents/backend-systems-architect-expert.md"

    # Ideation sub-agents (supporting /project:ideate command)
    log_info "Creating ideation agent symlinks..."
    create_symlink_file "$SOURCE_DIR/agents/ideation-market-researcher.md" "$claude_dir/agents/ideation-market-researcher.md"
    create_symlink_file "$SOURCE_DIR/agents/ideation-competitive-analyst.md" "$claude_dir/agents/ideation-competitive-analyst.md"
    create_symlink_file "$SOURCE_DIR/agents/ideation-validation-designer.md" "$claude_dir/agents/ideation-validation-designer.md"
    create_symlink_file "$SOURCE_DIR/agents/ideation-persona-builder.md" "$claude_dir/agents/ideation-persona-builder.md"
    create_symlink_file "$SOURCE_DIR/agents/ideation-unit-economics.md" "$claude_dir/agents/ideation-unit-economics.md"

    echo ""
    log_info "Claude Code initialization complete for: $target_path"
}

main "$@"
