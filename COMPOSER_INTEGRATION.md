# Composer Integration Guide

This shows how to integrate AI code review into your existing composer workflow.

## Example Composer Workflow with AI Review

```json
{
    "scripts": {
        "jsprettier": "npm run format-js",
        "bladeprettier": "npm run format-blade", 
        "phpstan": "./vendor/bin/phpstan analyse --memory-limit=2G",
        "env-sync": "php artisan envy:sync --dry",
        "env-prune": "php artisan envy:prune --dry",
        "pint": "vendor/bin/pint",
        "ide-helper-generate": "php artisan ide-helper:generate",
        "ide-helper-models": "php artisan ide-helper:models --write",
        "rector": "vendor/bin/rector",
        "test": "php artisan test",
        
        "ai-review": [
            "./.ai/scripts/ai-reviewer.sh manual"
        ],
        "ai-review-staged": [
            "./.ai/scripts/ai-reviewer.sh staged"
        ],
        
        "analyse": [
            "@env-sync",
            "@env-prune", 
            "@ide-helper-generate",
            "@ide-helper-models",
            "@bladeprettier",
            "@jsprettier",
            "@rector",
            "@pint",
            "@phpstan",
            "@test --parallel"
        ],
        
        "analyse-with-ai": [
            "@analyse",
            "@ai-review"
        ]
    }
}
```

## Usage Examples

### Manual AI Review (Reviews all uncommitted changes)
```bash
composer ai-review
```

### Staged AI Review (Reviews only staged changes) 
```bash
composer ai-review-staged
```

### Full Analysis with AI Review
```bash
composer analyse-with-ai
```

### Individual Steps
```bash
# Format and fix code
composer pint
composer rector
composer phpstan

# Review the changes with AI
composer ai-review

# Run tests
composer test
```

## Benefits of Composer Commands

✅ **Flexible** - Run when you want, not forced automatically  
✅ **Integrated** - Works seamlessly with your existing composer workflow  
✅ **CI/CD friendly** - Easy to run in automated pipelines  
✅ **Debuggable** - Can run individually to troubleshoot  
✅ **Optional** - Developers can choose when to use it  
✅ **Fast commits** - No mandatory delays for quick fixes  
✅ **IDE integration** - Better support in development tools

## Development Workflows

### Daily Development
```bash
# Make changes
vim app/Services/UserService.php

# Review changes
composer ai-review

# Fix issues if any
claude "Implement improvements from .ai/code-reviews/code-review-20241021_143022.md"

# Final checks and commit
composer phpstan && composer test
git add . && git commit -m "feature: improve user service"
```

### Before Major Commits
```bash
# Run full analysis pipeline
composer analyse-with-ai

# Address any issues
# Then commit
git add . && git commit -m "refactor: comprehensive code improvements"
```

### Quick Fixes (Skip Review)
```bash
# For urgent hotfixes, skip AI review
composer pint  # Just format
git add . && git commit -m "fix: typo in error message"
```

## CI/CD Integration

### GitHub Actions Example
```yaml
name: Code Quality with AI Review

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup PHP
        uses: shivammathur/setup-php@v2
        with:
          php-version: 8.2
          
      - name: Install dependencies
        run: composer install --no-dev --optimize-autoloader
        
      - name: Run analysis with AI review
        run: composer analyse-with-ai
        
      - name: Upload AI reviews
        uses: actions/upload-artifact@v3
        if: always()
        with:
          name: ai-code-reviews
          path: .ai/code-reviews/
```

### Team Adoption Strategy
1. **Week 1**: Install and introduce `composer ai-review` - optional use
2. **Week 2**: Add `composer analyse-with-ai` to workflow  
3. **Week 3**: Add to CI/CD pipeline for visibility
4. **Week 4**: Make it part of standard development process

This approach gives you maximum flexibility while maintaining powerful AI-driven code quality insights!