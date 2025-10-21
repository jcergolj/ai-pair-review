# Quick Start Guide

Get up and running with AI Review Hook in 5 minutes.

## Installation

### 1. Install Package

```bash
composer require --dev jcergolj/ai-pair-review
```

### 2. Run Installation Command

```bash
php artisan ai-review:install
```

You'll see:
```
🤖 Installing AI Code Review Hooks...

✓ Installed pre-commit hook
✓ Installed ai-reviewer.sh
✓ Created .pre-commit-config
✓ Updated .gitignore

═══════════════════════════════════════════
  ✨ AI Code Review installed successfully!
═══════════════════════════════════════════
```

### 3. Make a Commit

```bash
git add .
git commit -m "Add user registration feature"
```

The AI review runs automatically!

## What Happens Next

1. **AI analyzes your code** - Reviews staged PHP files
2. **Interactive triage** - Choose to fix, skip, or ignore each issue
3. **Review is saved** - Creates `.ai/code-reviews/code-review-TIMESTAMP.md`
4. **File opens** - Automatically in VS Code
5. **Smart ignore** - Issues you ignore won't appear again until fresh changes

## Example Output

```
🤖 AI Code Review

Analyzing 1 PHP file(s)...

Analyzing code with Claude AI...
Checking: SOLID principles, design patterns, code quality

✓ Review complete

═══════════════════════════════════════════════════════════
  📝 Review saved to: .ai/code-reviews/code-review-20251021_143022.md
═══════════════════════════════════════════════════════════

Found 2 new issue(s) to triage:

Issue 1 of 2:
- [ ] Single Responsibility Violation (UserService.php:21)

Action: [f]ix, [s]kip this time, [i]gnore forever, [q]uit: f
✓ Added to fix list

Issue 2 of 2:
- [ ] Missing Type Declarations (UserService.php:21)

Action: [f]ix, [s]kip this time, [i]gnore forever, [q]uit: i
🚫 Added to ignore list

═══════════════════════════════════════════════════════════
                      TRIAGE SUMMARY
═══════════════════════════════════════════════════════════

✅ Issues to fix (1):
   • - [ ] Single Responsibility Violation (UserService.php:21)

📋 To implement fixes, run:
claude "Please implement the following improvements:
• - [ ] Single Responsibility Violation (UserService.php:21)"

✓ Opened in VS Code
```

## After Committing

### Option 1: Use Claude to Implement Fixes

```bash
# The script provides the exact command based on your triage choices:
claude "Please implement the following improvements:
• - [ ] Single Responsibility Violation (UserService.php:21)
• - [ ] Missing Type Declarations (UserService.php:21)"

# Claude will make the changes automatically
git add .
git commit -m "Fix: Apply AI code review suggestions"
```

### Option 2: Review and Fix Manually

```bash
# Open the review file
cat .ai/code-reviews/code-review-20251021_143022.md

# Edit your code based on suggestions
vim app/Services/UserService.php

# Commit fixes
git add .
git commit -m "Fix: Apply code review suggestions"
```

### Option 3: Submit Full Review to Claude

```bash
# Submit the entire review file to Claude Code
claude "Implement the improvements in .ai/code-reviews/code-review-20251021_143022.md"

git add .
git commit -m "Fix: Apply AI code review suggestions"
```

## Configuration

### Basic Configuration

Edit `.pre-commit-config` to customize:

```bash
# Enable/disable AI review
AI_REVIEW=true
```

Disable for one commit:
```bash
AI_REVIEW=false git commit -m "Quick fix"
```

Skip entirely (emergency):
```bash
git commit --no-verify -m "Hotfix"
```

### Manage Ignore List

```bash
# View what you've ignored
cat .ai/ignore.yml

# Reset ignore list manually
rm .ai/ignore.yml

# The ignore list automatically resets when you commit new changes
```

## Customize What Gets Reviewed

Want to focus on specific things? Edit the prompt!

```bash
# Open the reviewer script
code .git/hooks/ai-reviewer.sh

# Edit line 33: REVIEW_PROMPT="..."
```

**Popular customizations:**
- Security focus
- Performance focus
- Team-specific standards
- Educational mode

See [CUSTOMIZE_PROMPT.md](CUSTOMIZE_PROMPT.md) for templates.

## Common Commands

```bash
# Install hooks
php artisan ai-review:install

# Reinstall/update hooks  
php artisan ai-review:install --force

# Uninstall hooks
php artisan ai-review:uninstall

# Review without committing (manual mode)
composer ai-review

# Review staged files only
composer ai-review-staged

# View your ignore list
cat .ai/ignore.yml

# Reset ignore list manually (or just make a new commit)
rm .ai/ignore.yml
```

## Troubleshooting

### "Claude CLI not found"

Install Claude Code from https://claude.ai/code

The hook will skip gracefully if Claude isn't installed.

### Hook not running

```bash
# Check hooks are installed
ls -la .git/hooks/

# Reinstall
php artisan ai-review:install --force
```

### Review file not opening

It's still saved to `.ai/code-reviews/code-review-*.md` even if VS Code doesn't open.

## Next Steps

- ✅ Make commits and get reviews
- ✅ Use interactive triage to manage issues
- ✅ Let the ignore system learn your preferences
- ✅ Customize the prompt (see CUSTOMIZE_PROMPT.md)
- ✅ Share with your team
- ✅ Learn from the AI feedback

## Full Documentation

- **[README.md](README.md)** - Complete package documentation
- **[CUSTOMIZE_PROMPT.md](CUSTOMIZE_PROMPT.md)** - Customize what gets reviewed
- **[INSTALL_GUIDE.md](INSTALL_GUIDE.md)** - Advanced installation scenarios
- **[PACKAGE_STRUCTURE.md](PACKAGE_STRUCTURE.md)** - How the package works

## Support

- Issues: GitHub Issues
- Questions: Open a discussion
- Improvements: Pull Requests welcome!

Happy coding! 🚀
