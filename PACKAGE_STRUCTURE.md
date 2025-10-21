# Package Structure

This document explains the structure of the AI Review Hook Composer package.

## Directory Structure

```
ai-pair-review/
├── src/
│   ├── AiReviewHookServiceProvider.php    # Laravel service provider
│   └── Commands/
│       ├── InstallCommand.php             # php artisan ai-review:install
│       └── UninstallCommand.php           # php artisan ai-review:uninstall
├── stubs/
│   ├── pre-commit                         # Main pre-commit hook
│   ├── ai-reviewer.sh                     # AI review script
│   └── .pre-commit-config                 # Configuration file
├── composer.json                          # Package definition
├── README.md                              # Main documentation
├── INSTALL_GUIDE.md                       # Installation instructions
├── LICENSE                                # MIT License
└── .gitignore                             # Git ignore rules
```

## Key Files

### composer.json
Defines the package metadata, dependencies, and auto-loading.

Key sections:
- **name**: `jcergolj/ai-pair-review` (change this!)
- **autoload**: PSR-4 autoloading for `AiReviewHook` namespace
- **extra.laravel.providers**: Auto-discovery of service provider
- **scripts**: Post-install reminder to run setup

### src/AiReviewHookServiceProvider.php
Laravel service provider that registers the Artisan commands.

### src/Commands/InstallCommand.php
Artisan command that:
1. Checks for git repository
2. Copies hook files from stubs/ to .git/hooks/
3. Makes them executable
4. Creates .pre-commit-config
5. Updates .gitignore
6. Checks for Claude CLI

### src/Commands/UninstallCommand.php
Artisan command that removes the hooks.

### stubs/pre-commit
The main git pre-commit hook that:
1. Detects staged PHP files
2. Calls ai-reviewer.sh
3. Displays results
4. Prompts user to continue or abort

### stubs/ai-reviewer.sh
The AI review script that:
1. Gets staged diff
2. Creates review prompt for Claude
3. Calls Claude CLI
4. Saves review to markdown file
5. Opens in VS Code
6. Returns exit code based on findings

### stubs/.pre-commit-config
Configuration file for users to customize behavior.

## How It Works

### Installation Flow

```
composer require --dev jcergolj/ai-pair-review
    ↓
Composer installs package to vendor/
    ↓
Laravel auto-discovers AiReviewHookServiceProvider
    ↓
User runs: php artisan ai-review:install
    ↓
InstallCommand copies files:
  - stubs/pre-commit → .git/hooks/pre-commit
  - stubs/ai-reviewer.sh → .git/hooks/ai-reviewer.sh
  - stubs/.pre-commit-config → .pre-commit-config
    ↓
Makes hooks executable (chmod +x)
    ↓
Updates .gitignore
    ↓
Done! Hooks are active
```

### Commit Flow

```
User runs: git commit -m "message"
    ↓
Git executes: .git/hooks/pre-commit
    ↓
pre-commit calls: .git/hooks/ai-reviewer.sh
    ↓
ai-reviewer.sh:
  1. Gets git diff --cached
  2. Builds prompt with SOLID/patterns focus
  3. Calls: claude -p "prompt"
  4. Saves output to: .ai/code-reviews/code-review-TIMESTAMP.md
  5. Opens file in VS Code
  6. Returns exit code
    ↓
pre-commit:
  - If exit 0: Shows success, allows commit
  - If exit 1: Shows suggestions, prompts user
    ↓
User chooses:
  - y: Commit proceeds
  - n: Commit aborted
    ↓
After commit, user can:
  claude "Implement improvements in .ai/code-reviews/code-review-*.md"
```

## Customization

### Change Package Name

Edit `composer.json`:

```json
{
  "name": "yourname/your-package-name"
}
```

Also update:
- README.md (all references)
- INSTALL_GUIDE.md (all references)

### Change Namespace

Edit `composer.json`:

```json
{
  "autoload": {
    "psr-4": {
      "YourNamespace\\": "src/"
    }
  }
}
```

Then update all PHP files:
- `namespace AiReviewHook;` → `namespace YourNamespace;`
- `use AiReviewHook\...;` → `use YourNamespace\...;`

### Change Command Names

Edit the Command classes:

```php
// In InstallCommand.php
protected $signature = 'your:install';
protected $description = 'Your description';
```

### Modify Review Focus

Edit `stubs/ai-reviewer.sh` line 33-106 to change the `REVIEW_PROMPT`.

Examples:
- Add security focus
- Add performance focus
- Remove Laravel-specific sections
- Add your team's standards

### Support Different Languages

Edit `stubs/ai-reviewer.sh` line 17:

```bash
# Current (PHP only)
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.php$' || true)

# For Python
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep '\.py$' || true)

# For multiple languages
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(php|py|js|ts)$' || true)
```

## Publishing Checklist

Before publishing to Packagist:

- [ ] Update `composer.json` with your name/email
- [ ] Update package name in `composer.json`
- [ ] Update README.md references to package name
- [ ] Update LICENSE with your name
- [ ] Test installation in a fresh Laravel project
- [ ] Test the hooks work correctly
- [ ] Create GitHub repository
- [ ] Push to GitHub
- [ ] Tag first release: `git tag -a v1.0.0 -m "First release"`
- [ ] Push tags: `git push origin v1.0.0`
- [ ] Submit to Packagist: https://packagist.org/packages/submit
- [ ] Verify auto-update webhook is set up
- [ ] Update README with actual installation command

## Testing Locally

Before publishing, test the package locally:

### Method 1: Composer Path Repository

In a test Laravel project's `composer.json`:

```json
{
  "repositories": [
    {
      "type": "path",
      "url": "../ai-pair-review"
    }
  ],
  "require-dev": {
    "jcergolj/ai-pair-review": "@dev"
  }
}
```

Then:
```bash
composer install
php artisan ai-review:install
git commit -m "Test"
```

### Method 2: Symlink

```bash
cd your-test-project/vendor
ln -s ../../ai-pair-review jcergolj/ai-pair-review
php artisan package:discover
php artisan ai-review:install
```

## Maintenance

### Updating the Package

```bash
# Make changes
vim src/Commands/InstallCommand.php

# Commit
git add .
git commit -m "Fix: Handle edge case"

# Version bump
git tag -a v1.0.1 -m "Bug fixes"
git push origin main --tags
```

Packagist auto-updates!

### Changelog

Consider maintaining CHANGELOG.md:

```markdown
# Changelog

## [1.0.1] - 2025-01-22
### Fixed
- Handle missing .gitignore gracefully

## [1.0.0] - 2025-01-21
### Added
- Initial release
- Pre-commit hooks
- AI review integration
- Laravel Artisan commands
```

## Support

For issues or questions:
- GitHub Issues: https://github.com/jcergolj/ai-pair-review/issues
- Pull Requests: https://github.com/jcergolj/ai-pair-review/pulls

## License

MIT License - see LICENSE file
