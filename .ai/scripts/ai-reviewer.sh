#!/bin/bash

# AI Code Reviewer using Claude CLI
# Reviews code and saves detailed analysis to markdown files
# Simple, non-interactive approach - saves everything for manual review

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
GRAY='\033[0;37m'
NC='\033[0m'

# Configuration
PROJECT_ROOT=$(git rev-parse --show-toplevel)

# Default mode is manual, but can be overridden for staged
MODE="${1:-manual}"

# Helper function to format file sizes
format_size() {
    local size=$1
    if command -v numfmt &> /dev/null; then
        echo "$size" | numfmt --to=iec
    else
        if [ "$size" -gt 1048576 ]; then
            echo "$(($size / 1048576))MB"
        elif [ "$size" -gt 1024 ]; then
            echo "$(($size / 1024))KB"
        else
            echo "${size}B"
        fi
    fi
}

# Main execution starts here

echo -e "${BLUE}🤖 AI Code Reviewer${NC}"
echo -e "${GRAY}Analyzing code and saving detailed review${NC}"
echo ""

# Get diff and files based on mode
if [ "$MODE" = "staged" ]; then
    DIFF=$(git diff --cached)
    STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$' || true)
    REVIEW_TYPE="staged changes"
    echo -e "${CYAN}📋 Reviewing staged changes...${NC}"
else
    DIFF=$(git diff HEAD)
    STAGED_FILES=$(git diff HEAD --name-only --diff-filter=ACM | grep '\.php$' || true)
    REVIEW_TYPE="uncommitted changes"
    echo -e "${CYAN}📋 Reviewing all uncommitted changes...${NC}"
fi

if [ -z "$STAGED_FILES" ]; then
    echo -e "${GREEN}✓${NC} No PHP $REVIEW_TYPE to review"
    exit 0
fi

# Check diff size and warn about token limits
DIFF_SIZE=$(echo "$DIFF" | wc -c)
DIFF_LINES=$(echo "$DIFF" | wc -l)

# Claude token limits: roughly 200,000 tokens (~800,000 characters)
# Keep some buffer for prompt text, so warn at 500,000 characters
MAX_DIFF_SIZE=500000
WARN_DIFF_SIZE=300000

if [ "$DIFF_SIZE" -gt "$MAX_DIFF_SIZE" ]; then
    echo -e "${RED}⚠ WARNING: Changes too large for AI review${NC}"
    echo -e "${YELLOW}  Diff size: $(format_size $DIFF_SIZE) characters${NC}"
    echo -e "${YELLOW}  Claude token limit would be exceeded${NC}"
    echo ""
    echo -e "Options:"
    echo -e "  ${GREEN}s${NC} - Skip AI review and continue"
    echo -e "  ${YELLOW}t${NC} - Truncate diff and review first $(format_size $WARN_DIFF_SIZE) chars"
    echo -e "  ${RED}a${NC} - Abort"
    echo ""
    echo -n "Choice (s/t/a): "
    read -r choice
    choice=$(echo "$choice" | tr '[:upper:]' '[:lower:]' | head -c 1)
    echo ""
    
    case $choice in
        s)
            echo -e "${YELLOW}⚠ Skipping AI review due to size${NC}"
            exit 2
            ;;
        t)
            echo -e "${YELLOW}⚠ Truncating diff for review${NC}"
            DIFF=$(echo "$DIFF" | head -c "$WARN_DIFF_SIZE")
            DIFF="$DIFF

--- DIFF TRUNCATED DUE TO SIZE LIMIT ---
Total size: $(format_size $DIFF_SIZE) characters
Showing first: $(format_size $WARN_DIFF_SIZE) characters
Review may be incomplete. Consider splitting changes into smaller commits."
            ;;
        *)
            echo -e "${RED}Aborted${NC}"
            exit 1
            ;;
    esac
elif [ "$DIFF_SIZE" -gt "$WARN_DIFF_SIZE" ]; then
    echo -e "${YELLOW}⚠ Warning: Large changeset detected${NC}"
    echo -e "${YELLOW}  Diff size: $(format_size $DIFF_SIZE) characters ($(echo "$DIFF_LINES") lines)${NC}"
    echo -e "${YELLOW}  This may take longer to review and could hit token limits${NC}"
    echo -e "${BLUE}  Consider splitting into smaller commits for better reviews${NC}"
    echo ""
fi

# Check if Claude CLI is available
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}⚠ Claude CLI not found in PATH${NC}"
    echo -e "${YELLOW}  Install Claude Code to enable AI review${NC}"
    echo -e "${YELLOW}  Skipping review...${NC}"
    exit 2
fi

# Create comprehensive review prompt
REVIEW_PROMPT="You are an expert and senior software architect, and code reviewer, acting as pair programmer, specializing in clean code, design patterns, and SOLID principles.

Review the following code changes in a Laravel application and create an actionable improvement plan.

## Files being reviewed:
$STAGED_FILES

## Diff of $REVIEW_TYPE:
\`\`\`diff
$DIFF
\`\`\`

## Your Task:
Analyze the code for:
1. SOLID principle violations
2. Missing or misused design patterns
3. Code smells and refactoring opportunities
4. Laravel best practices
5. Type safety issues
6. Naming and readability improvements

## Output Format:

# Code Review - $(date +"%Y-%m-%d %H:%M:%S")

## Summary
[2-3 sentence overview of the changes and overall code quality]

## Files Reviewed
$STAGED_FILES

## Issues Found

### High Priority
[Critical issues that should be fixed before merge]
- [ ] Issue 1: [Description]
  - File: [filename:line]
  - Problem: [What's wrong]
  - Fix: [How to fix it]

### Medium Priority
[Improvements that would enhance code quality]
- [ ] Issue 1: [Description]
  - File: [filename:line]
  - Suggestion: [What to improve]

### Low Priority / Nice to Have
[Optional improvements]
- [ ] Issue 1: [Description]

## What's Done Well
[Acknowledge good practices in the code]

---

**Instructions:**
- Review each issue above
- Use the separate claude-command.txt file to implement fixes
- Edit the command file to include only the issues you want to fix
- Copy the entire claude-command.txt content and paste into Claude

This review provides detailed analysis for your decision-making, while claude-command.txt contains the streamlined implementation command."

# Run Claude CLI review
TEMP_PROMPT_FILE=$(mktemp)
echo "$REVIEW_PROMPT" > "$TEMP_PROMPT_FILE"

# Check final prompt size
PROMPT_SIZE=$(wc -c < "$TEMP_PROMPT_FILE")

echo -e "${CYAN}Analyzing code with Claude AI...${NC}"
echo -e "${CYAN}Checking: SOLID principles, design patterns, code quality${NC}"
echo -e "${GRAY}(Timeout: 600 seconds / 10 minutes for complex reviews)${NC}"
if [ "$PROMPT_SIZE" -gt 300000 ]; then
    echo -e "${YELLOW}Large prompt - this may take longer...${NC}"
fi
echo ""

# Use Claude CLI to review
REVIEW_OUTPUT=$(timeout 600 claude -p "$(cat "$TEMP_PROMPT_FILE")" 2>&1) || {
    CLAUDE_EXIT_CODE=$?
    echo -e "${RED}✗ Claude CLI error${NC}"
    
    # Check for timeout (exit code 124)
    if [ $CLAUDE_EXIT_CODE -eq 124 ]; then
        echo -e "${RED}🕐 Claude CLI timed out after 600 seconds${NC}"
        echo -e "${YELLOW}  The code changes may be too complex for review${NC}"
        echo -e "${YELLOW}  Consider splitting into smaller commits${NC}"
    else
        echo -e "${YELLOW}  Claude error (exit code: $CLAUDE_EXIT_CODE)${NC}"
    fi
    
    rm "$TEMP_PROMPT_FILE"
    exit 2
}

rm "$TEMP_PROMPT_FILE"

# Save review to file
TIMESTAMP=$(date +"%Y-%m-%d-%H-%M-%S")
REVIEWS_DIR="$PROJECT_ROOT/.ai/code-reviews/$TIMESTAMP"
mkdir -p "$REVIEWS_DIR"

REVIEW_FILE="$REVIEWS_DIR/review.md"
echo "$REVIEW_OUTPUT" > "$REVIEW_FILE"

# Extract issues and create Claude command file
CLAUDE_COMMAND_FILE="$REVIEWS_DIR/claude-command.txt"

# Extract all issues with their full context (including sub-bullets)
FULL_ISSUES=""
extracting_issue=false
current_issue=""

while IFS= read -r line; do
    # Check if this is a new checkbox issue
    if [[ $line =~ ^-[[:space:]]*\[[[:space:]]*\][[:space:]]*.+ ]]; then
        # Save previous issue if exists
        if [ "$extracting_issue" = true ] && [ -n "$current_issue" ]; then
            FULL_ISSUES="${FULL_ISSUES}${current_issue}"$'\n\n'
        fi
        # Start new issue
        current_issue="$line"$'\n'
        extracting_issue=true
    # Line that belongs to current issue (indented)
    elif [ "$extracting_issue" = true ] && [[ $line =~ ^[[:space:]]+.+ ]]; then
        current_issue="${current_issue}${line}"$'\n'
    # Empty line - might be part of issue
    elif [ "$extracting_issue" = true ] && [[ $line =~ ^[[:space:]]*$ ]]; then
        current_issue="${current_issue}${line}"$'\n'
    # Non-indented line that's not a checkbox - end current issue
    elif [ "$extracting_issue" = true ] && [[ $line =~ ^[^[:space:]] ]] && [[ ! $line =~ ^-[[:space:]]*\[[[:space:]]*\] ]]; then
        # End current issue
        if [ -n "$current_issue" ]; then
            FULL_ISSUES="${FULL_ISSUES}${current_issue}"$'\n\n'
        fi
        current_issue=""
        extracting_issue=false
    fi
done <<< "$REVIEW_OUTPUT"

# Save final issue
if [ "$extracting_issue" = true ] && [ -n "$current_issue" ]; then
    FULL_ISSUES="${FULL_ISSUES}${current_issue}"
fi

if [ -n "$FULL_ISSUES" ]; then
    # Create the Claude command file with full issue context
    cat > "$CLAUDE_COMMAND_FILE" << EOF
I need you to implement the following code improvements in my Laravel project. Here are the specific issues to address:

## Issues to Fix:

$FULL_ISSUES

## Context:
- This is a Laravel application
- Follow SOLID principles and design patterns
- Maintain backward compatibility
- Add proper type hints and documentation
- Follow Laravel conventions and best practices

## Instructions:
1. Analyze each issue carefully
2. Implement the most appropriate solution
3. Ensure code is clean, readable, and maintainable
4. Add comments only where necessary for complex logic
5. Run any necessary tests to ensure nothing breaks

## Files to modify:
You have access to the entire codebase. Focus on the files mentioned in the issues above.

Please implement these improvements systematically, explaining your changes as you go.
EOF
fi

echo -e "${GREEN}✓ Review complete${NC}"
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  📝 Files saved to: ${YELLOW}.ai/code-reviews/$TIMESTAMP/${NC}"
echo -e "${BLUE}     • review.md - Full analysis${NC}"
if [ -n "$FULL_ISSUES" ]; then
    echo -e "${BLUE}     • claude-command.txt - Ready-to-copy Claude prompt${NC}"
fi
echo -e "${BLUE}═══════════════════════════════════════════════════════════${NC}"
echo ""

# Count issues found
ISSUE_COUNT=$(echo "$REVIEW_OUTPUT" | grep -c "^- \[ \]" || echo "0")
if [ "$ISSUE_COUNT" -gt 0 ]; then
    echo -e "${CYAN}📋 Found ${ISSUE_COUNT} issues for review${NC}"
    echo -e "${GRAY}  • Full analysis: review.md${NC}"
    echo -e "${GRAY}  • Claude command: claude-command.txt${NC}"
    echo ""
    echo -e "${BLUE}💡 Quick copy command:${NC}"
    echo -e "${CYAN}  cat .ai/code-reviews/$TIMESTAMP/claude-command.txt | pbcopy${NC}"
    echo -e "${GRAY}  (or use 'xclip -selection clipboard' on Linux)${NC}"
else
    echo -e "${GREEN}✨ No issues found - code looks good!${NC}"
fi

echo ""
echo -e "${GREEN}✓ Review process complete${NC}"
exit 0
