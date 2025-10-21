# Customizing the AI Review Prompt

This guide shows you how to customize what the AI reviews and how it reviews your code.

## Quick Start

The review prompt is in `.git/hooks/ai-reviewer.sh` starting at **line 33**.

```bash
# Open the file
code .git/hooks/ai-reviewer.sh

# Or use any editor
vim .git/hooks/ai-reviewer.sh
nano .git/hooks/ai-reviewer.sh
```

Look for the `REVIEW_PROMPT` variable around line 33.

## Default Prompt Structure

```bash
REVIEW_PROMPT="You are an expert software architect and code reviewer...

Review the following code changes in a Laravel application...

## Files being committed:
$STAGED_FILES

## Diff of changes:
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
..."
```

## Common Customizations

### 1. Focus on Security

Add security as the top priority:

```bash
REVIEW_PROMPT="You are an expert security-focused code reviewer.

Review the following code changes with a PRIMARY FOCUS ON SECURITY.

## Files being committed:
$STAGED_FILES

## Diff of changes:
\`\`\`diff
$DIFF
\`\`\`

## Your Task (Priority Order):

### 1. CRITICAL SECURITY ISSUES
- SQL injection vulnerabilities
- XSS (Cross-Site Scripting) vulnerabilities
- CSRF token missing
- Mass assignment vulnerabilities
- Authentication/Authorization bypasses
- Insecure direct object references
- Sensitive data exposure
- Using unsafe functions (eval, unserialize, etc.)
- Missing input validation/sanitization
- Hardcoded secrets or credentials

### 2. SOLID Principles
[... rest of analysis ...]

### 3. Design Patterns
[... rest of analysis ...]

## Output Format:
Create a structured improvement plan in markdown...

# Code Review - $(date +"%Y-%m-%d %H:%M:%S")

## Summary
[Overview with SECURITY FOCUS]

## Issues Found

### 🚨 CRITICAL SECURITY ISSUES
[List all security vulnerabilities found]

### High Priority
[SOLID violations, bugs]

### Medium Priority
[Improvements, patterns]

### Low Priority
[Nice to have]
"
```

### 2. Focus on Performance

Prioritize performance issues:

```bash
REVIEW_PROMPT="You are an expert performance optimization specialist.

Review code with PRIMARY FOCUS ON PERFORMANCE.

## Your Task:

### 1. PERFORMANCE ISSUES (Critical)
- N+1 query problems
- Missing database indexes
- Inefficient queries (SELECT *, missing pagination)
- Missing query result caching
- Eager loading opportunities
- Slow algorithms (O(n²) or worse)
- Missing lazy loading
- Large file operations in memory
- Synchronous operations that should be queued
- Missing database transaction optimization

### 2. CACHING OPPORTUNITIES
- Query result caching
- View caching
- Route caching
- Config caching
- Computed values that could be cached

### 3. DATABASE OPTIMIZATION
- Missing indexes
- Inefficient joins
- Subqueries that could be optimized
- Missing database-level constraints

Then analyze for:
4. SOLID principles
5. Design patterns
6. Code quality

## Output Format:
# Code Review - Performance Focus

## Summary
[Focus on performance impact]

### ⚡ CRITICAL PERFORMANCE ISSUES
- [ ] Issue 1...

### 🔥 Performance Improvements
- [ ] Improvement 1...
"
```

### 3. Team-Specific Standards

Add your team's coding standards:

```bash
REVIEW_PROMPT="You are a code reviewer for [YOUR COMPANY NAME].

Review code according to our team standards:

## [YOUR COMPANY] Coding Standards:

### Required Patterns:
- All database access MUST go through Repository pattern
- All business logic MUST be in Action classes
- All validation MUST use Form Requests
- All API responses MUST use API Resources
- Events MUST be used for cross-cutting concerns
- Jobs MUST be queued (never run synchronously)

### Naming Conventions:
- Actions: {Verb}{Noun}Action (e.g., CreateUserAction)
- Repositories: {Model}Repository
- Form Requests: {Action}{Model}Request (e.g., StoreUserRequest)
- Resources: {Model}Resource
- Events: {Model}{PastTense} (e.g., UserCreated)

### Architecture Rules:
- Controllers should be thin (max 10 lines per method)
- Services should have single responsibility
- No business logic in controllers or models
- DTOs must be used for data transfer between layers

## Your Task:
1. Check compliance with above standards (HIGHEST PRIORITY)
2. SOLID principles
3. Design patterns
4. Code quality

## Output Format:
# Code Review - [YOUR COMPANY] Standards

## Standards Compliance Issues
### ❌ Standards Violations (MUST FIX)
- [ ] Violation 1...

### ⚠️ Standards Warnings
- [ ] Warning 1...

## Architecture & SOLID
...
"
```

### 4. Language-Agnostic (Remove Laravel)

For non-Laravel projects:

```bash
REVIEW_PROMPT="You are an expert code reviewer specializing in clean code and SOLID principles.

Review the following code changes.

## Files being committed:
$STAGED_FILES

## Diff of changes:
\`\`\`diff
$DIFF
\`\`\`

## Your Task:
Analyze for:

1. **SOLID Principles**
   - Single Responsibility
   - Open/Closed
   - Liskov Substitution
   - Interface Segregation
   - Dependency Inversion

2. **Design Patterns**
   - Strategy, Factory, Builder, Observer, etc.
   - Dependency Injection
   - Proper abstraction

3. **Code Quality**
   - Code smells (long methods, god classes, etc.)
   - Duplication
   - Complexity
   - Naming

4. **Type Safety**
   - Type declarations
   - Null safety
   - Proper use of types

## Output Format:
[Standard format without Laravel-specific sections]
"
```

### 5. Strict Mode (Fail on Any Issue)

Make the review more strict:

```bash
REVIEW_PROMPT="You are a STRICT code reviewer. Be thorough and critical.

Review the code and find EVERY issue, no matter how small.

## Your Task:

Look for EVERYTHING:
- Any SOLID principle violation (even minor)
- Any missing type declaration
- Any code smell (even small ones)
- Any magic number or string
- Any missing documentation
- Any method over 15 lines
- Any class over 200 lines
- Any complexity issues
- Any naming that isn't perfectly clear
- Any potential for improvement

Be CRITICAL but CONSTRUCTIVE. Explain why each issue matters.

## Output Format:
# STRICT Code Review

## 🚨 Critical Issues
[All critical issues - must fix]

## ⚠️ Warnings
[All warnings - should fix]

## 💡 Improvements
[All possible improvements - consider fixing]

## ✅ What's Good
[Acknowledge good practices too]

Be thorough - find everything!
"
```

### 6. Lenient Mode (Only Critical Issues)

More relaxed review:

```bash
REVIEW_PROMPT="You are a pragmatic code reviewer.

Focus ONLY on issues that would cause:
- Bugs or errors
- Security vulnerabilities
- Severe performance problems
- Major maintainability issues

IGNORE:
- Minor style issues
- Subjective improvements
- Micro-optimizations
- Nice-to-have refactorings

Only report issues that truly matter.

## Output Format:
# Pragmatic Code Review

## Summary
[Brief overview]

## Critical Issues Only
- [ ] Issue 1: [Only if it's truly critical]

If no critical issues: 'No critical issues found - code is acceptable.'
"
```

### 7. Educational Mode (Detailed Explanations)

For learning:

```bash
REVIEW_PROMPT="You are a patient, educational code reviewer helping developers learn.

For EACH issue found:
1. Explain WHAT the issue is
2. Explain WHY it matters (real-world impact)
3. Show HOW to fix it (with code examples)
4. Explain WHEN this pattern should be used
5. Provide links to further reading

Be detailed and educational. This is a learning opportunity.

## Output Format:
# Educational Code Review

## Issues Found

### Issue 1: [Name]
**What:** [Describe the issue]

**Why it matters:** [Explain impact on:
- Maintainability
- Testability
- Performance
- Team collaboration]

**How to fix:**
\`\`\`php
// Before (current code)
[show current code]

// After (improved code)
[show better approach]
\`\`\`

**When to use this pattern:**
[Explain when this applies]

**Learn more:**
- [Link to documentation]
- [Link to article]

---

[Repeat for each issue]
"
```

### 8. Multi-Language Support

For projects with multiple languages:

First, update line 17 to detect multiple file types:

```bash
# Line 17 - detect multiple languages
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM | grep -E '\.(php|py|js|ts|tsx|jsx|go|rb)$' || true)
```

Then customize the prompt:

```bash
REVIEW_PROMPT="You are an expert polyglot code reviewer.

Review the following code changes. The project uses multiple languages.

## Files being committed:
$STAGED_FILES

Analyze based on file type:

### For PHP files:
- Laravel best practices
- PHP 8.2+ features
- PSR standards

### For JavaScript/TypeScript:
- React/Vue best practices
- Modern ES6+ patterns
- Type safety (TypeScript)

### For Python:
- PEP 8 standards
- Pythonic idioms
- Type hints

### For All Languages:
- SOLID principles
- Design patterns
- Code quality
- Security

## Output Format:
# Multi-Language Code Review

## By Language

### PHP Files
[Issues specific to PHP]

### JavaScript/TypeScript Files
[Issues specific to JS/TS]

[etc.]

## Universal Issues
[Issues applicable across languages]
"
```

## Step-by-Step: Editing the Prompt

### Method 1: Direct Edit

```bash
# 1. Open the file
nano .git/hooks/ai-reviewer.sh

# 2. Find line 33 (search for REVIEW_PROMPT)
# Press Ctrl+W in nano, type "REVIEW_PROMPT", press Enter

# 3. Edit the text between the quotes
REVIEW_PROMPT="Your custom prompt here..."

# 4. Save and exit
# Ctrl+X, then Y, then Enter

# 5. Test it
git add some-file.php
git commit -m "Test custom prompt"
```

### Method 2: Using VS Code

```bash
# 1. Open in VS Code
code .git/hooks/ai-reviewer.sh

# 2. Use Cmd+F (Mac) or Ctrl+F (Windows/Linux)
#    Search for: REVIEW_PROMPT

# 3. Edit the multi-line string starting at line 33

# 4. Save (Cmd+S or Ctrl+S)

# 5. Test
git add .
git commit -m "Test"
```

### Method 3: Replace Entire Section

Create a new file with your custom prompt:

```bash
# Create custom prompt file
cat > /tmp/custom-prompt.txt << 'EOF'
You are a security-focused code reviewer.

Review for:
1. Security vulnerabilities
2. SOLID principles
3. Performance issues

Output format:
...
EOF

# Replace the prompt section in ai-reviewer.sh
# (Advanced - requires careful editing)
```

## Testing Your Custom Prompt

After editing:

```bash
# 1. Stage a file
git add app/Services/UserService.php

# 2. Try to commit (triggers review)
git commit -m "Test custom prompt"

# 3. Check the generated review file
cat .ai/code-reviews/code-review-*.md

# 4. Verify it matches your customization

# 5. If not happy, edit again and retry
git reset HEAD~1  # Undo last commit
# Edit prompt again
git commit -m "Test again"
```

## Template Variables Available

You can use these variables in your prompt:

- `$STAGED_FILES` - List of files being committed
- `$DIFF` - The full git diff of changes
- `$(date +"%Y-%m-%d %H:%M:%S")` - Current timestamp

Example:
```bash
REVIEW_PROMPT="Review these files: $STAGED_FILES

Changes:
$DIFF

Generated at: $(date +"%Y-%m-%d %H:%M:%S")
"
```

## Sharing Custom Prompts

### With Your Team

```bash
# 1. Create a template file
cat > .ai-review-prompt-template.txt << 'EOF'
[Your custom prompt]
EOF

# 2. Commit it to the repo
git add .ai-review-prompt-template.txt
git commit -m "Add AI review prompt template"

# 3. Team members copy it
cp .ai-review-prompt-template.txt /tmp/prompt.txt
# Then manually paste into .git/hooks/ai-reviewer.sh
```

### Create Prompt Presets

Save different prompts for different situations:

```bash
# Create prompts directory
mkdir -p .git/hooks/prompts/

# Save presets
cat > .git/hooks/prompts/security.txt << 'EOF'
[Security-focused prompt]
EOF

cat > .git/hooks/prompts/performance.txt << 'EOF'
[Performance-focused prompt]
EOF

cat > .git/hooks/prompts/educational.txt << 'EOF'
[Educational prompt]
EOF

# Use a preset (replace prompt in ai-reviewer.sh with file content)
```

## Advanced: Dynamic Prompts

Edit `.git/hooks/ai-reviewer.sh` to use different prompts based on context:

```bash
# Around line 33, replace static prompt with conditional:

# Detect if this is a security-related commit
if echo "$STAGED_FILES" | grep -q "Auth\|Security\|Login"; then
    REVIEW_PROMPT="Security-focused prompt for auth files..."
elif echo "$STAGED_FILES" | grep -q "Controller"; then
    REVIEW_PROMPT="Controller-specific prompt..."
else
    REVIEW_PROMPT="Default prompt..."
fi
```

## Troubleshooting

### Prompt Not Updating

```bash
# Make sure you edited the right file
ls -la .git/hooks/ai-reviewer.sh

# Check if it's executable
chmod +x .git/hooks/ai-reviewer.sh

# Test the script directly
.git/hooks/ai-reviewer.sh
```

### Syntax Errors

If you get errors after editing:

```bash
# Check for syntax errors
bash -n .git/hooks/ai-reviewer.sh

# Common issues:
# - Unclosed quotes
# - Missing backslashes before special characters
# - Wrong quote type (use " or ')
```

### Prompt Too Long

Claude has token limits. If your prompt is too long:

```bash
# Check prompt length
wc -c .git/hooks/ai-reviewer.sh

# If > 10,000 characters, consider:
# - Shorter descriptions
# - Fewer examples
# - Focus on specific areas
```

## Example: Complete Custom Prompt

Here's a complete example you can copy:

```bash
# Replace lines 33-106 in .git/hooks/ai-reviewer.sh with:

REVIEW_PROMPT="You are a senior code reviewer for a Laravel application.

## Files being committed:
$STAGED_FILES

## Changes:
\`\`\`diff
$DIFF
\`\`\`

## Review Focus:
1. Security vulnerabilities
2. SOLID principle violations
3. Laravel best practices
4. Performance issues

## Output Format:
# Code Review - $(date +"%Y-%m-%d %H:%M:%S")

## Summary
[2-3 sentences]

## Issues Found

### 🚨 Security & Critical
- [ ] Issue: [Description]
  - File: [filename:line]
  - Fix: [How to fix]

### ⚠️ SOLID & Architecture
- [ ] Issue: [Description]

### 💡 Improvements
- [ ] Suggestion: [Description]

Keep it concise and actionable."
```

## Next Steps

1. Choose a customization approach
2. Edit `.git/hooks/ai-reviewer.sh`
3. Test with a commit
4. Refine based on results
5. Share with your team!

For more examples, see the package repository or create an issue with your use case.
