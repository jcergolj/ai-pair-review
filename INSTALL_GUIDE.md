# Installation Guide

Complete guide for installing and using AI Review Hook in your projects.

## For New Projects

### Step 1: Install Package

```bash
composer require --dev jcergolj/ai-pair-review
```

### Step 2: Install Hooks

```bash
php artisan ai-review:install
```

This creates:
- `.ai/scripts/` directory with the reviewer script
- `.ai/ignore.yml` file for managing ignored issues
- `.ai/code-reviews/` directory for storing reviews
- Updates `.gitignore` to exclude review files and personal ignore preferences

### Step 3: Start Committing

```bash
git add .
git commit -m "Your changes"
```

The AI review runs automatically with interactive triage:
- Choose to fix, skip, or permanently ignore each issue
- Ignored issues won't appear again until you make fresh commits
- Get personalized fix commands based on your choices

## For Existing Projects

Same as above. The hooks work with any existing Laravel project.

## Installation Options

### Option 1: Basic Install

```bash
composer require --dev jcergolj/ai-pair-review
php artisan ai-review:install
```

### Option 2: With Force (Overwrite Existing)

```bash
php artisan ai-review:install --force
```

### Option 3: Auto-Install on Composer Install

Add to your project's `composer.json`:

```json
{
  "scripts": {
    "post-install-cmd": [
      "@php artisan ai-review:install || true"
    ],
    "post-update-cmd": [
      "@php artisan ai-review:install || true"
    ]
  }
}
```

Now hooks install automatically when anyone runs `composer install`.

## Publishing to Packagist (For Package Authors)

To make this available on Packagist:

### 1. Prepare the Repository

```bash
cd ai-pair-review

# Initialize git
git init
git add .
git commit -m "Initial release"

# Create GitHub repository and push
git remote add origin https://github.com/jcergolj/ai-pair-review.git
git push -u origin main
```

### 2. Create a Release

```bash
# Tag the first version
git tag -a v1.0.0 -m "First stable release"
git push origin v1.0.0
```

### 3. Submit to Packagist

1. Go to https://packagist.org
2. Sign in with GitHub
3. Click "Submit"
4. Enter: `https://github.com/jcergolj/ai-pair-review`
5. Click "Check"
6. If valid, click "Submit"

### 4. Set Up Auto-Updates

In your GitHub repository settings:

1. Go to Settings → Webhooks
2. Packagist will have added a webhook automatically
3. Verify it's active

Now every time you push a new tag, Packagist updates automatically!

### 5. Update composer.json

Update the package name in `composer.json`:

```json
{
  "name": "jcergolj/ai-pair-review",
  "authors": [
    {
      "name": "Your Name",
      "email": "your@email.com"
    }
  ]
}
```

## Using in Projects

Once published to Packagist, anyone can install it:

```bash
composer require --dev jcergolj/ai-pair-review
php artisan ai-review:install
```

## Non-Laravel Projects

For non-Laravel PHP projects:

### Using Composer

```bash
composer require --dev jcergolj/ai-pair-review
```

Then manually copy the hooks:

```bash
cp vendor/jcergolj/ai-pair-review/stubs/pre-commit .git/hooks/
cp vendor/jcergolj/ai-pair-review/stubs/ai-reviewer.sh .git/hooks/
cp vendor/jcergolj/ai-pair-review/stubs/.pre-commit-config .
chmod +x .git/hooks/*
```

### Without Composer

Download the repository and copy files:

```bash
# Download
git clone https://github.com/jcergolj/ai-pair-review.git /tmp/ai-review

# Copy to your project
cd your-project
cp /tmp/ai-review/stubs/pre-commit .git/hooks/
cp /tmp/ai-review/stubs/ai-reviewer.sh .git/hooks/
cp /tmp/ai-review/stubs/.pre-commit-config .
chmod +x .git/hooks/*
```

## Team Setup

### Method 1: Commit Config to Repo

```bash
# In your project
git add .pre-commit-config
git commit -m "Add AI review configuration"
git push
```

Team members:
```bash
git pull
composer install
php artisan ai-review:install
```

**Note**: Each team member gets their own `.ai/ignore.yml` file (gitignored), so ignore preferences are personal and don't conflict.

### Method 2: Auto-Install for Team

Add to project's `composer.json`:

```json
{
  "require-dev": {
    "jcergolj/ai-pair-review": "^1.0"
  },
  "scripts": {
    "post-install-cmd": [
      "@php artisan ai-review:install --quiet || echo 'Skipping hook install'"
    ]
  }
}
```

Now when any team member runs `composer install`, hooks install automatically!

### Method 3: .githooks Directory

For teams wanting to commit hooks to the repo:

```bash
# Create .githooks directory
mkdir .githooks
cp .git/hooks/pre-commit .githooks/
cp .git/hooks/ai-reviewer.sh .githooks/

# Commit to repo
git add .githooks/
git commit -m "Add AI review hooks"

# Tell git to use this directory
git config core.hooksPath .githooks
```

Add to team README:
```markdown
## Setup

After cloning:
```bash
composer install
git config core.hooksPath .githooks
chmod +x .githooks/*
```
```

## Updating the Package

### For Package Authors

```bash
# Make changes
git add .
git commit -m "Add new feature"

# Tag new version
git tag -a v1.1.0 -m "Version 1.1.0"
git push origin main --tags
```

Packagist automatically updates!

### For Package Users

```bash
# Update to latest version
composer update jcergolj/ai-pair-review

# Reinstall hooks (if changed)
php artisan ai-review:install --force
```

## Troubleshooting

### Package Not Found

If Composer can't find the package:

1. Check it's published on Packagist: https://packagist.org/packages/jcergolj/ai-pair-review
2. Verify the name in composer.json matches
3. Try: `composer clear-cache`

### Service Provider Not Found

Make sure the package is in `require-dev`:

```bash
composer require --dev jcergolj/ai-pair-review
```

Laravel auto-discovers the service provider.

### Hooks Not Installing

```bash
# Check Laravel discovered the package
php artisan package:discover

# Check the command is available
php artisan list | grep ai-review

# Reinstall with force
php artisan ai-review:install --force
```

### Claude CLI Not Found

The hooks need Claude Code CLI:

```bash
# Check if installed
which claude

# If not found, install from:
# https://claude.ai/code
```

The hook will skip gracefully if Claude isn't installed.

## Versioning

This package follows [Semantic Versioning](https://semver.org/):

- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Minor** (1.0.0 → 1.1.0): New features, backwards compatible
- **Patch** (1.0.0 → 1.0.1): Bug fixes

Specify version in composer.json:

```json
{
  "require-dev": {
    "jcergolj/ai-pair-review": "^1.0"
  }
}
```

- `^1.0` - Any 1.x version (recommended)
- `~1.0` - >=1.0, <1.1
- `1.0.*` - Any 1.0.x patch
- `1.0.0` - Exact version

## Next Steps

- ✅ Install the package
- ✅ Test with a commit
- ✅ Customize `.pre-commit-config`
- ✅ Share with your team
- ✅ Publish to Packagist (if you're the author)

For more info, see the main README.md
