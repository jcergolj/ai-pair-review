# Extending to Other AI Providers

This guide shows how to modify the hooks to work with AI providers other than Claude Code.

## Current Implementation

The package currently uses **Claude Code CLI** (`claude` command) to perform AI reviews.

However, the pre-commit hook structure is **standard Git** - just bash scripts that can be modified to call any AI service.

## Supported AI Providers (Examples)

You can modify `.git/hooks/ai-reviewer.sh` to use:

### 1. OpenAI GPT (via API)

Replace the Claude CLI call with OpenAI API:

```bash
# Around line 118 in ai-reviewer.sh
# Replace this section:
REVIEW_OUTPUT=$(claude -p "$(cat "$TEMP_PROMPT_FILE")" 2>&1)

# With OpenAI API call:
REVIEW_OUTPUT=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{
    \"model\": \"gpt-4\",
    \"messages\": [{
      \"role\": \"user\",
      \"content\": $(jq -Rs . "$TEMP_PROMPT_FILE")
    }],
    \"max_tokens\": 2000
  }" | jq -r '.choices[0].message.content')
```

**Requirements:**
- Set `OPENAI_API_KEY` environment variable
- Install `jq` for JSON parsing: `brew install jq`

### 2. GitHub Copilot CLI

Use GitHub Copilot for reviews:

```bash
# Replace Claude call with:
REVIEW_OUTPUT=$(gh copilot suggest "$(cat "$TEMP_PROMPT_FILE")" 2>&1)
```

**Requirements:**
- Install GitHub CLI: `brew install gh`
- Install Copilot extension: `gh extension install github/gh-copilot`
- Authenticate: `gh auth login`

### 3. Ollama (Local AI)

Run reviews completely offline using Ollama:

```bash
# Replace Claude call with:
REVIEW_OUTPUT=$(ollama run codellama "$(cat "$TEMP_PROMPT_FILE")" 2>&1)

# Or with llama3:
REVIEW_OUTPUT=$(ollama run llama3 "$(cat "$TEMP_PROMPT_FILE")" 2>&1)
```

**Requirements:**
- Install Ollama: `curl -fsSL https://ollama.ai/install.sh | sh`
- Pull a model: `ollama pull codellama`

### 4. Google Gemini

Use Google's Gemini API:

```bash
# Replace Claude call with:
REVIEW_OUTPUT=$(curl -s "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=$GEMINI_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{
    \"contents\": [{
      \"parts\": [{
        \"text\": $(jq -Rs . "$TEMP_PROMPT_FILE")
      }]
    }]
  }" | jq -r '.candidates[0].content.parts[0].text')
```

**Requirements:**
- Get API key from https://makersuite.google.com/app/apikey
- Set `GEMINI_API_KEY` environment variable
- Install `jq`: `brew install jq`

### 5. Anthropic Claude API (Direct)

Use Claude API directly instead of CLI:

```bash
# Replace Claude call with:
REVIEW_OUTPUT=$(curl -s https://api.anthropic.com/v1/messages \
  -H "x-api-key: $ANTHROPIC_API_KEY" \
  -H "anthropic-version: 2023-06-01" \
  -H "content-type: application/json" \
  -d "{
    \"model\": \"claude-sonnet-4-5-20250929\",
    \"max_tokens\": 2000,
    \"messages\": [{
      \"role\": \"user\",
      \"content\": $(jq -Rs . "$TEMP_PROMPT_FILE")
    }]
  }" | jq -r '.content[0].text')
```

**Requirements:**
- Get API key from https://console.anthropic.com/
- Set `ANTHROPIC_API_KEY` environment variable
- Install `jq`: `brew install jq`

### 6. Multiple Providers (Fallback)

Support multiple AI providers with automatic fallback:

```bash
# Around line 118 in ai-reviewer.sh, replace with:

# Try Claude CLI first
if command -v claude &> /dev/null; then
    echo -e "${CYAN}Using Claude Code CLI...${NC}"
    REVIEW_OUTPUT=$(claude -p "$(cat "$TEMP_PROMPT_FILE")" 2>&1) || REVIEW_FAILED=true
fi

# Fallback to OpenAI if Claude fails
if [ ! -z "$REVIEW_FAILED" ] && [ ! -z "$OPENAI_API_KEY" ]; then
    echo -e "${CYAN}Falling back to OpenAI GPT-4...${NC}"
    REVIEW_OUTPUT=$(curl -s https://api.openai.com/v1/chat/completions \
      -H "Content-Type: application/json" \
      -H "Authorization: Bearer $OPENAI_API_KEY" \
      -d "{
        \"model\": \"gpt-4\",
        \"messages\": [{\"role\": \"user\", \"content\": $(jq -Rs . "$TEMP_PROMPT_FILE")}]
      }" | jq -r '.choices[0].message.content') || REVIEW_FAILED=true
fi

# Fallback to Ollama if all else fails
if [ ! -z "$REVIEW_FAILED" ] && command -v ollama &> /dev/null; then
    echo -e "${CYAN}Falling back to Ollama (local)...${NC}"
    REVIEW_OUTPUT=$(ollama run codellama "$(cat "$TEMP_PROMPT_FILE")" 2>&1)
fi
```

## Complete Example: OpenAI Version

Here's a complete working example for OpenAI:

```bash
#!/bin/bash
# .git/hooks/ai-reviewer.sh modified for OpenAI

# ... (keep all the color definitions and setup code) ...

# Check if OpenAI API key is available
if [ -z "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}⚠ OPENAI_API_KEY not set${NC}"
    echo -e "${YELLOW}  Set it with: export OPENAI_API_KEY='your-key'${NC}"
    echo -e "${YELLOW}  Skipping review...${NC}"
    exit 0
fi

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo -e "${YELLOW}⚠ jq not found (required for OpenAI)${NC}"
    echo -e "${YELLOW}  Install with: brew install jq${NC}"
    echo -e "${YELLOW}  Skipping review...${NC}"
    exit 0
fi

# ... (keep the REVIEW_PROMPT section) ...

# Run OpenAI review
TEMP_PROMPT_FILE=$(mktemp)
echo "$REVIEW_PROMPT" > "$TEMP_PROMPT_FILE"

echo -e "${CYAN}Analyzing code with OpenAI GPT-4...${NC}"
echo -e "${CYAN}Checking: SOLID principles, design patterns, code quality${NC}"
echo ""

# Call OpenAI API
REVIEW_OUTPUT=$(curl -s https://api.openai.com/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $OPENAI_API_KEY" \
  -d "{
    \"model\": \"gpt-4\",
    \"messages\": [{
      \"role\": \"system\",
      \"content\": \"You are an expert code reviewer.\"
    }, {
      \"role\": \"user\",
      \"content\": $(jq -Rs . "$TEMP_PROMPT_FILE")
    }],
    \"max_tokens\": 2000,
    \"temperature\": 0.3
  }" 2>&1)

# Check for errors
if echo "$REVIEW_OUTPUT" | jq -e '.error' > /dev/null 2>&1; then
    echo -e "${RED}✗ OpenAI API error${NC}"
    ERROR_MSG=$(echo "$REVIEW_OUTPUT" | jq -r '.error.message')
    echo -e "${YELLOW}  Error: $ERROR_MSG${NC}"
    rm "$TEMP_PROMPT_FILE"
    exit 0
fi

# Extract the response
REVIEW_OUTPUT=$(echo "$REVIEW_OUTPUT" | jq -r '.choices[0].message.content')

rm "$TEMP_PROMPT_FILE"

# ... (keep the rest of the file - saving to file, opening VS Code, etc.) ...
```

## Configuration for Different Providers

Add to `.pre-commit-config`:

```bash
# AI Provider Selection
AI_PROVIDER=${AI_PROVIDER:-claude}  # claude, openai, gemini, ollama

# API Keys (set in environment or here)
# OPENAI_API_KEY=sk-...
# ANTHROPIC_API_KEY=sk-ant-...
# GEMINI_API_KEY=...

# Ollama Model
OLLAMA_MODEL=${OLLAMA_MODEL:-codellama}
```

## Making the Package Support Multiple Providers

To make this package officially support multiple AI providers:

### 1. Update InstallCommand.php

Add provider selection during installation:

```php
public function handle(): int
{
    // ... existing code ...

    // Ask which AI provider to use
    $provider = $this->choice(
        'Which AI provider do you want to use?',
        ['claude-cli', 'openai-api', 'gemini-api', 'ollama-local'],
        0
    );

    // Copy appropriate stub based on provider
    $reviewerSource = __DIR__ . "/../../stubs/ai-reviewer-{$provider}.sh";

    // ... rest of installation ...
}
```

### 2. Create Provider-Specific Stubs

```
stubs/
├── pre-commit                    # Same for all
├── ai-reviewer-claude-cli.sh     # Current version
├── ai-reviewer-openai-api.sh     # OpenAI version
├── ai-reviewer-gemini-api.sh     # Gemini version
├── ai-reviewer-ollama-local.sh   # Ollama version
└── .pre-commit-config
```

### 3. Update composer.json

```json
{
  "extra": {
    "ai-providers": [
      "claude-cli",
      "openai-api",
      "gemini-api",
      "ollama-local"
    ]
  }
}
```

## Comparison of Providers

| Provider | Cost | Speed | Quality | Offline | Setup |
|----------|------|-------|---------|---------|-------|
| Claude CLI | Free tier | Fast | Excellent | No | Easy |
| Claude API | Pay-per-use | Fast | Excellent | No | Medium |
| OpenAI GPT-4 | Pay-per-use | Medium | Excellent | No | Medium |
| Gemini | Free tier | Fast | Good | No | Medium |
| Ollama | Free | Medium | Good | Yes | Easy |
| GitHub Copilot | Subscription | Fast | Good | No | Easy |

## Recommendations

**For teams:**
- **Claude CLI** - Best balance of quality and ease of use
- **Ollama** - Best for offline/privacy-sensitive environments
- **OpenAI API** - Best if already using OpenAI

**For individuals:**
- **Claude CLI** - Easiest to set up
- **Ollama** - Free and runs locally

## Contributing Provider Support

Want to add support for another AI provider?

1. Fork the repository
2. Create `stubs/ai-reviewer-{provider}.sh`
3. Test it thoroughly
4. Submit a pull request
5. Update this document

## Non-AI Pre-Commit Hooks

You can also use the pre-commit hook structure for **non-AI** checks:

### Static Analysis Only

```bash
# .git/hooks/pre-commit
# Remove AI review, keep only:
- PHPStan
- Rector
- Pint
- Custom scripts
```

### Custom Linting

```bash
# .git/hooks/pre-commit
# Add your own checks:
- ESLint for JavaScript
- Black for Python
- Rubocop for Ruby
- Your team's custom scripts
```

### Mix AI with Tools

```bash
# .git/hooks/pre-commit
# Combine:
1. Run PHPStan (static analysis)
2. Run AI review (code quality)
3. Run security scan
4. All results in one report
```

## Summary

- **Current**: Package uses Claude Code CLI
- **Flexible**: Can be modified for any AI provider or tool
- **Standard**: Uses standard Git hooks (pure bash)
- **Extensible**: Easy to add new providers

The package is designed to be extended - all AI calls are isolated to one function in `ai-reviewer.sh` making it easy to swap providers!
