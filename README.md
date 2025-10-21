# AI Review

🤖 AI-powered code review for Laravel projects using Claude Code CLI.

Automatically reviews your code for SOLID principles, design patterns, and code quality via composer commands.

## Features

- **🎯 SOLID Principles** - Detects violations of Single Responsibility, Open/Closed, etc.
- **🏗️ Design Patterns** - Suggests Strategy, Factory, Repository, Observer patterns
- **🔧 Code Quality** - Identifies code smells and refactoring opportunities
- **✅ Laravel Best Practices** - N+1 queries, proper Eloquent usage, security
- **📝 Comprehensive Reports** - Detailed analysis with actionable improvement plans
- **📋 Ready-to-Use Commands** - Includes Claude prompts you can copy and paste
- **⚡ Simple & Fast** - No interactive prompts, just run and get results
- **🔗 VS Code Integration** - Auto-opens review files for easy access

## Quick Start

### Install and Setup

```bash
# Install the package
composer require --dev jcergolj/ai-pair-review

# Setup scripts and directories  
php artisan ai-review:install
```

### Usage

```bash
# Review all uncommitted changes
composer ai-review

# Review only staged changes  
composer ai-review-staged

# Integration with existing workflow
composer analyse && composer ai-review
```

## How It Works

### Simple Code Review Process
1. **Run**: `composer ai-review` (or `composer ai-review-staged`)
2. **AI Analysis**: Claude AI analyzes your uncommitted PHP changes  
3. **Automatic Save**: Complete analysis saved to `.ai/code-reviews/YYYY-MM-DD-HH-MM-SS/review.md`
4. **Review Issues**: Open the file to see detailed issues with File, Problem, and Fix information
5. **Copy & Apply**: Use the included "Ready-to-Use Claude Command" to implement fixes
6. **Manual Control**: You choose which issues to fix by copying them to Claude

### File Outputs
- **Detailed Review**: `.ai/code-reviews/YYYY-MM-DD-HH-MM-SS/review.md` - Full AI analysis for decision-making
- **Claude Command**: `.ai/code-reviews/YYYY-MM-DD-HH-MM-SS/claude-command.txt` - Ready-to-copy command with all issues
- **Auto-open**: Review file automatically opens in VS Code if available
- **Organized**: Each review session gets its own timestamped folder

### What You Get
Each review includes:
- **Summary**: Overview of code changes and quality
- **Prioritized Issues**: High/Medium/Low priority with specific file locations
- **Detailed Analysis**: File names, line numbers, problems, and suggested fixes
- **Separate Command File**: Clean Claude prompt with all issues ready to copy
- **Positive Feedback**: Recognition of good practices in your code

## Implementing Fixes

You get two files for maximum convenience:

### 1. Review File (review.md)
Contains detailed analysis for your decision-making:
- Complete issue breakdown
- File locations and line numbers  
- Priority levels (High/Medium/Low)
- Specific problems and suggested fixes

### 2. Claude Command File (claude-command.txt)
Ready-to-use command with complete issue context:
- **Full Details**: Each issue includes File, Problem, and Fix information
- **Line Numbers**: Specific locations for precise fixes
- **Complete Context**: Everything Claude needs to implement the fix
- **Copy-Ready**: Just copy the entire file and paste into Claude

```bash
# Quick copy approach
cat .ai/code-reviews/2024-10-22-15-45-30/claude-command.txt | pbcopy

# Then paste into Claude Code CLI
claude
# Paste and press enter
```

### Using Claude Web Interface
1. Open: `.ai/code-reviews/YYYY-MM-DD-HH-MM-SS/claude-command.txt`
2. Copy the entire file contents
3. Paste into Claude web interface at https://claude.ai
4. Review and apply the suggested changes

### Customizing Before Use
Edit the `claude-command.txt` file to:
- Remove entire issues you don't want to fix (including all sub-bullets)
- Focus on specific priority levels only
- Add your own project-specific context
- Modify instructions to match your coding standards

### Example Files Structure
```
.ai/code-reviews/2024-10-22-15-45-30/
├── review.md          # Detailed analysis
└── claude-command.txt # Clean command ready to copy
```

**claude-command.txt example:**
```
I need you to implement the following code improvements in my Laravel project:

## Issues to Fix:

- [ ] **Duplicate Job Dispatch in CompletedOrderController**
  - File: app/Http/Controllers/Webhooks/CompletedOrderController.php:27-35
  - Problem: The `AllocateOneDirectToClientTokenJob` is dispatched twice with identical conditions and parameters (lines 27-30 and lines 32-35). This will cause the same job to run twice for every OneDirectToClient order, leading to duplicate emails, potential data inconsistencies, and unnecessary queue processing.
  - Fix: Remove one of the duplicate `AllocateOneDirectToClientTokenJob::dispatchIf()` calls. Keep only lines 27-30 or 32-35, but not both.

- [ ] **Missing type hints for parameters**
  - File: UserController.php:25
  - Problem: Method parameters lack type declarations
  - Fix: Add proper type hints for better code safety

## Context:
- This is a Laravel application
- Follow SOLID principles and design patterns
[... rest of context and instructions ...]
```

## Integration with Existing Workflow

### Basic Integration
```bash
# Your existing scripts + AI review
composer pint
composer phpstan  
composer ai-review  # <- Add this
composer test
```

### Advanced Integration
Add to your `composer.json`:

```json
{
    "scripts": {
        "analyse-with-ai": [
            "@analyse",
            "@ai-review"
        ]
    }
}
```

Then run: `composer analyse-with-ai`

## Code Review Storage

All AI-generated code reviews are automatically stored in the **`.ai/code-reviews/`** folder in your project root. Each review is saved as a markdown file with a timestamp:

```
.ai/
├── scripts/
│   └── ai-reviewer.sh
├── ignore.yml
└── code-reviews/
    ├── code-review-20251021_143022.md
    ├── code-review-20251021_151204.md
    └── code-review-20251022_094515.md
```

### Interactive Triage System

When issues are found, you'll be prompted for each one:

```
Issue 1 of 3:
- [ ] Single Responsibility Violation (UserService.php:21)

Action: [f]ix, [s]kip this time, [i]gnore forever, [q]uit: i
🚫 Added to ignore list

Issue 2 of 3:
- [ ] Missing Type Declarations (UserService.php:21)

Action: [f]ix, [s]kip this time, [i]gnore forever, [q]uit: f
✓ Added to fix list
```

**Options:**
- **[f]ix** - Add to your fix list for immediate action
- **[s]kip** - Skip for this review, will appear again next time
- **[i]gnore forever** - Never show this issue again (until fresh changes)
- **[q]uit** - Exit the triage process

### Smart Ignore System

Issues you ignore are stored in `.ai/ignore.yml`:

```yaml
# AI Code Review Ignore File
ignored_issues:
  - "- [ ] Use more descriptive variable names in legacy code"
  - "- [ ] Consider extracting UserService.formatName to a helper"
last_commit_hash: "abc123def456"
```

**Key features:**
- **Persistent**: Ignored issues won't appear in subsequent reviews
- **Fresh start**: When you commit changes, ignore list automatically resets
- **Team-friendly**: `.ai/ignore.yml` is gitignored (personal preferences)

This folder is automatically created on the first review and contains:
- **Timestamped files** - Each review gets a unique filename
- **Editable markdown** - Remove items you don't want to fix
- **Actionable checklists** - Ready to submit to Claude Code for implementation

### After Committing

```bash
# Review the detailed analysis
cat .ai/code-reviews/2024-10-21-14-30-22/review.md

# Copy the ready-to-use command
cat .ai/code-reviews/2024-10-21-14-30-22/claude-command.txt | pbcopy
# Then paste into Claude Code CLI or web interface

# Or edit the command file first, then copy
nano .ai/code-reviews/2024-10-21-14-30-22/claude-command.txt
```

### Managing Ignore List

```bash
# View your current ignore list
cat .ai/ignore.yml

# Reset ignore list manually (starts fresh)
rm .ai/ignore.yml

# Ignore list resets automatically when you commit changes
```

## Example Review

```markdown
Found 3 new issue(s) to triage:

Issue 1 of 3:
- [ ] Single Responsibility Violation (UserService.php:21)

Action: [f]ix, [s]kip this time, [i]gnore forever, [q]uit: f
✓ Added to fix list

Issue 2 of 3:
- [ ] Missing Type Declarations (UserService.php:21)

Action: [f]ix, [s]kip this time, [i]gnore forever, [q]uit: f
✓ Added to fix list

Issue 3 of 3:
- [ ] Use more descriptive variable names (UserService.php:45)

Action: [f]ix, [s]kip this time, [i]gnore forever, [q]uit: i
🚫 Added to ignore list

═══════════════════════════════════════════════════════════
                      TRIAGE SUMMARY
═══════════════════════════════════════════════════════════

✅ Issues to fix (2):
   • - [ ] Single Responsibility Violation (UserService.php:21)
   • - [ ] Missing Type Declarations (UserService.php:21)

📋 To implement fixes, run:
claude "Please implement the following improvements:
• - [ ] Single Responsibility Violation (UserService.php:21)
• - [ ] Missing Type Declarations (UserService.php:21)"
```

**Generated review file:**
```markdown
## Issues Found

### High Priority
- [ ] Single Responsibility Violation (UserService.php:21)
  - Problem: Class handles creation, emails, logging, subscriptions
  - Fix: Extract to CreateUserAction, UserRegistered event, SubscriptionStrategy

- [ ] Missing Type Declarations (UserService.php:21)
  - Problem: No return type, array instead of DTO
  - Fix: Add `: User` return type, create `RegisterUserData` DTO

### Medium Priority
- [ ] Strategy Pattern Opportunity (UserService.php:40)
  - Suggestion: Replace conditionals with SubscriptionStrategy interface

### Low Priority
- [ ] Use Eloquent Mass Assignment
  - Suggestion: Replace manual properties with User::create()
```

## What Gets Reviewed

### 🎯 SOLID Principles
- **S**ingle Responsibility - One class, one reason to change
- **O**pen/Closed - Open for extension, closed for modification
- **L**iskov Substitution - Proper use of abstractions
- **I**nterface Segregation - Focused, cohesive interfaces
- **D**ependency Inversion - Depend on abstractions, not concretions

### 🏗️ Architecture & Patterns
- Design pattern usage (Strategy, Factory, Repository, Observer, etc.)
- Dependency injection
- Domain-Driven Design principles
- God objects and procedural code

### 🔧 Code Quality
- Code smells (long methods, feature envy, data clumps)
- Duplicated code
- Complex conditionals → polymorphism
- Better use of collections

### ✅ Laravel Best Practices
- Eloquent relationships and query optimization
- N+1 query detection
- Service providers and facades
- Security (authorization, validation, mass assignment)
- Proper use of Form Requests, Events, Jobs

### 📝 Type Safety
- Missing type declarations
- Interface opportunities
- Value objects instead of primitives

## Configuration

### Basic Configuration

Edit `.pre-commit-config` in your project root:

```bash
# Enable/disable AI review
AI_REVIEW=true
```

### Disable AI Review

```bash
# Disable for one commit
AI_REVIEW=false git commit -m "Quick fix"

# Skip hook entirely (emergency)
git commit --no-verify -m "Hotfix"
```

### Ignore System Configuration

The ignore system automatically creates `.ai/ignore.yml` to track issues you don't want to see again.

**Structure:**
```yaml
# AI Code Review Ignore File
ignored_issues:
  - "- [ ] Use more descriptive variable names in legacy UserHelper"
  - "- [ ] Consider extracting formatUserData to separate class"
last_commit_hash: "abc123def456789"
```

**Key behaviors:**
- **Issues persist**: Ignored issues won't appear until fresh changes
- **Auto-reset**: When you commit new changes, ignore list resets (fresh start)
- **Personal**: `.ai/ignore.yml` is gitignored - each developer has their own preferences
- **Team-friendly**: Doesn't interfere with team workflow

**Manual management:**
```bash
# View ignored issues
cat .ai/ignore.yml

# Reset ignore list manually
rm .ai/ignore.yml

# Ignore list automatically resets on new commits
```

### Large Changes & Token Limits

Claude has token limits (~200k tokens, roughly 800k characters). The hook automatically handles large changes:

- **⚠️ Warning at 300KB** - Shows size and suggests splitting commits
- **🛑 Block at 500KB** - Offers options:
  - Skip AI review and commit normally
  - Truncate diff for partial review
  - Abort to split changes
- **🚨 Token errors** - Clear error messages with suggestions

**Best practices for large changes:**
```bash
# Instead of committing everything at once
git add .
git commit -m "Large refactor"

# Split into focused commits
git add app/Services/UserService.php
git commit -m "Extract user registration logic"

git add app/Events/UserRegistered.php
git commit -m "Add user registration event"

git add app/Listeners/SendWelcomeEmail.php
git commit -m "Add welcome email listener"
```

## Commands

### Install

```bash
php artisan ai-review:install
```

Installs the AI review system and creates:

```
your-project/
├── .ai/
│   ├── scripts/
│   │   └── ai-reviewer.sh          # Main review script
│   ├── ignore.yml                  # Personal ignore list (gitignored)
│   └── code-reviews/               # Generated reviews (gitignored)
├── .gitignore                      # Updated with AI review entries
```

**Options:**
- `--force` - Overwrite existing files

### Uninstall

```bash
php artisan ai-review:uninstall
```

Removes the pre-commit hooks.

## Requirements

- PHP 8.4+
- Laravel 12+
- Git repository
- **[Claude Code CLI](https://claude.ai/code)** installed and in PATH (default)

**Note**: Currently uses Claude Code CLI, but can be easily modified to use other AI providers (OpenAI, Gemini, Ollama, etc.). See [EXTEND_TO_OTHER_AI.md](EXTEND_TO_OTHER_AI.md) for instructions.

Install Claude Code from https://claude.ai/code

## Team Setup

**Option 1: Commit config to repository**

```bash
git add .pre-commit-config
git commit -m "Add AI review config"
```

Team members run:
```bash
composer install
php artisan ai-review:install
```

**Option 2: Auto-install on composer install**

Add to your project's `composer.json`:

```json
{
  "scripts": {
    "post-install-cmd": [
      "@php artisan ai-review:install --quiet || true"
    ]
  }
}
```

## Non-Laravel Projects

The hooks work with any PHP project! To install manually:

```bash
# From vendor directory
cp vendor/jcergolj/ai-pair-review/stubs/pre-commit .git/hooks/
cp vendor/jcergolj/ai-pair-review/stubs/ai-reviewer.sh .git/hooks/
cp vendor/jcergolj/ai-pair-review/stubs/.pre-commit-config .
'chmod +x .git/hooks/*
```

## Support Other Languages

Edit `.git/hooks/ai-reviewer.sh` line 17:

```bash
# For Python
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$' || true)

# For JavaScript/TypeScript
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(js|jsx|ts|tsx)$' || true)

# For all languages
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM || true)
```

## Troubleshooting

### "Claude CLI not found"

Install Claude Code from https://claude.ai/code

The hook will skip gracefully if Claude is not installed.

### Hook not running

```bash
# Check hooks are installed
ls -la .git/hooks/

# Reinstall
php artisan ai-review:install --force
```

### Review file not opening

Install VS Code CLI or the review is still saved to `.ai/code-reviews/YYYY-MM-DD-HH-MM-SS/review.md`

### Slow reviews

For large commits (10+ files), reviews may take 20-30 seconds. Consider:
- Smaller, more focused commits
- Temporarily disable: `AI_REVIEW=false git commit`

## Examples

### Before Review

```php
class UserService {
    public function register(array $data) {
        $user = User::create($data);
        Mail::to($user)->send(new WelcomeEmail());
        Log::info("Registered: {$user->email}");
        return $user;
    }
}
```

### After AI Suggestions

```php
// Single Responsibility - one action
class RegisterUserAction {
    public function execute(RegisterUserData $data): User {
        $user = User::create($data->toArray());
        event(new UserRegistered($user));
        return $user;
    }
}

// Event for cross-cutting concerns
class SendWelcomeEmail {
    public function handle(UserRegistered $event): void {
        $event->user->notify(new WelcomeNotification());
    }
}

// Value object for type safety
class RegisterUserData {
    public function __construct(
        public readonly string $name,
        public readonly Email $email,
        public readonly HashedPassword $password,
    ) {}
}
```

## Why Use This?

### 📚 Educational
Learn SOLID principles by seeing them applied to your actual code

### 🔍 Quality
Catch architectural issues before code review

### ⚡ Fast
Get instant expert feedback on every commit

### 🎯 Actionable
Edit the review to keep what matters, submit to Claude for automatic fixes

## Publishing to Packagist

To share this package publicly:

### 1. Create GitHub repository

```bash
cd ai-pair-review
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/jcergolj/ai-pair-review.git
git push -u origin main
```

### 2. Tag a release

```bash
git tag -a v1.0.0 -m "First release"
git push origin v1.0.0
```

### 3. Submit to Packagist

1. Go to https://packagist.org/packages/submit
2. Enter your GitHub URL: `https://github.com/jcergolj/ai-pair-review`
3. Click Submit

### 4. Install in any project

```bash
composer require --dev jcergolj/ai-pair-review
php artisan ai-review:install
```

## Customization

### Customize What Gets Reviewed

The AI review prompt is fully customizable! See **[CUSTOMIZE_PROMPT.md](CUSTOMIZE_PROMPT.md)** for the complete guide with examples.

**Quick start:**
```bash
# Open the reviewer script
code .git/hooks/ai-reviewer.sh

# Edit the REVIEW_PROMPT variable (starts at line 33)
```

**Popular customizations:**
- **Security Focus** - Prioritize vulnerabilities and security issues
- **Performance Focus** - Catch N+1 queries, caching opportunities
- **Team Standards** - Enforce your company's specific coding rules
- **Educational Mode** - Get detailed explanations for learning
- **Strict Mode** - Catch every small issue
- **Lenient Mode** - Only report critical problems

See [CUSTOMIZE_PROMPT.md](CUSTOMIZE_PROMPT.md) for copy-paste templates and examples.

### Save Reviews to Custom Location

Edit `.ai/scripts/ai-reviewer.sh` around line 210:

```bash
# Save to a different location
mkdir -p "$PROJECT_ROOT/.reviews"
REVIEW_FILE="$PROJECT_ROOT/.reviews/code-review-$TIMESTAMP.md"
```

## Extending to Other AI Providers

While this package uses Claude Code CLI by default, it's built on **standard Git hooks** and can be easily modified to use:

- **OpenAI GPT-4** (via API)
- **Google Gemini** (via API)
- **Ollama** (local, offline)
- **GitHub Copilot CLI**
- **Any other AI service**

The pre-commit hook is just a bash script - modify `.git/hooks/ai-reviewer.sh` to call your preferred AI provider.

**Full guide with examples**: [EXTEND_TO_OTHER_AI.md](EXTEND_TO_OTHER_AI.md)

Quick example for OpenAI:
```bash
# Replace line 118 in .git/hooks/ai-reviewer.sh
REVIEW_OUTPUT=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d '{"model":"gpt-4","messages":[...]}' | jq -r '.choices[0].message.content')
```

## Contributing

Contributions welcome!

**Especially wanted:**
- Support for additional AI providers
- Improved prompts
- Bug fixes
- Documentation improvements

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file

## Credits

Built with [Claude Code CLI](https://claude.ai/code) by Anthropic

## Support

- **Issues**: https://github.com/jcergolj/ai-pair-review/issues
- **Documentation**: This README
- **Full Guide**: `.git/hooks/README.md` (after installation)

---
