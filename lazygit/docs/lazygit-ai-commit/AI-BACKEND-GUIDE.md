# AI Backend Configuration Guide

This guide provides detailed information about configuring and using different AI backends with the LazyGit commit message generator.

## Quick Reference

### Environment Variables Summary

```bash
# Required: Choose backend
export AI_BACKEND="gemini"  # or "claude" or "ollama" or "mock"

# API Keys (required for cloud backends)
export GEMINI_API_KEY="your-gemini-key"
export ANTHROPIC_API_KEY="your-claude-key"

# Optional: Customize behavior
export TIMEOUT_SECONDS=30              # Request timeout (default: 30)
export GEMINI_MODEL="gemini-1.5-flash" # Gemini model (default shown)
export CLAUDE_MODEL="claude-3-5-haiku-20241022"  # Claude model
export OLLAMA_MODEL="mistral"          # Ollama model (default: mistral)
export OLLAMA_HOST="http://localhost:11434"  # Ollama server
```

## Backend Comparison

### Gemini (Google)

**Best for**: Most users, quick setup, free tier

**Setup**:
```bash
pip install google-generativeai
export GEMINI_API_KEY="your-key"
export AI_BACKEND="gemini"
```

**Available Models**:
- `gemini-1.5-flash` (default) - Fast, good quality, recommended
- `gemini-1.5-pro` - Higher quality, slower, more expensive
- `gemini-1.0-pro` - Older model, still capable

**Pricing** (as of 2024):
- Free tier: 15 requests per minute
- Paid: $0.00025 per 1K characters (very affordable)

**Pros**:
- Fast response times (1-3 seconds)
- Generous free tier
- Good quality commit messages
- Easy to set up

**Cons**:
- Requires internet connection
- Code diffs sent to Google servers
- Rate limits on free tier

**Configuration Example**:
```bash
# ~/.bashrc or ~/.zshrc
export AI_BACKEND="gemini"
export GEMINI_API_KEY="AIzaSy..."
export GEMINI_MODEL="gemini-1.5-flash"
export TIMEOUT_SECONDS=30
```

### Claude (Anthropic)

**Best for**: Professional use, highest quality output

**Setup**:
```bash
npm install -g @anthropic-ai/claude-cli
export ANTHROPIC_API_KEY="your-key"
export AI_BACKEND="claude"
```

**Available Models**:
- `claude-3-5-haiku-20241022` (default) - Fast, affordable, recommended
- `claude-3-5-sonnet-20241022` - Higher quality, more expensive
- `claude-3-opus-20240229` - Highest quality, most expensive

**Pricing** (as of 2024):
- Haiku: $0.25 per million input tokens
- Sonnet: $3 per million input tokens
- Opus: $15 per million input tokens

**Pros**:
- Excellent code understanding
- High-quality, contextual messages
- Good at following Conventional Commits format
- Reliable output format

**Cons**:
- Requires paid API (no free tier)
- Requires internet connection
- Code diffs sent to Anthropic servers
- More expensive than Gemini

**Configuration Example**:
```bash
# ~/.bashrc or ~/.zshrc
export AI_BACKEND="claude"
export ANTHROPIC_API_KEY="sk-ant-..."
export CLAUDE_MODEL="claude-3-5-haiku-20241022"
export TIMEOUT_SECONDS=30
```

### Ollama (Local)

**Best for**: Privacy-sensitive projects, offline work, no API costs

**Setup**:
```bash
curl -fsSL https://ollama.com/install.sh | sh
ollama pull mistral
ollama serve
export AI_BACKEND="ollama"
```

**Available Models**:
- `mistral` (default) - 7B params, good balance of speed/quality
- `codellama` - 7B params, optimized for code
- `llama2` - 7B params, general purpose
- `mixtral` - 8x7B params, higher quality, slower
- `deepseek-coder` - 6.7B params, code-focused

**Pricing**:
- Free! Runs completely locally

**Pros**:
- Complete privacy - nothing leaves your machine
- No API costs
- Works offline
- No rate limits
- Customizable models

**Cons**:
- Slower than cloud APIs (5-15 seconds)
- Requires local compute resources (4-8GB RAM)
- Quality varies by model
- Requires Ollama service running

**Configuration Example**:
```bash
# ~/.bashrc or ~/.zshrc
export AI_BACKEND="ollama"
export OLLAMA_MODEL="mistral"
export OLLAMA_HOST="http://localhost:11434"
export TIMEOUT_SECONDS=60  # Longer timeout for local processing
```

**Model Recommendations**:
```bash
# For speed (2-5 seconds)
ollama pull mistral:7b-instruct

# For code quality
ollama pull codellama:7b-instruct

# For best quality (slower, 10-20 seconds)
ollama pull mixtral:8x7b-instruct
```

### Mock (Testing)

**Best for**: Testing, development, CI/CD

**Setup**:
```bash
export AI_BACKEND="mock"
# No API key needed
```

**Behavior**:
- Generates simple heuristic-based messages
- Analyzes diff for keywords (test, doc, config, etc.)
- Always returns 5+ messages
- No external dependencies

**Use Cases**:
- Testing the integration without API keys
- CI/CD pipelines
- Development and debugging
- Demonstrating the feature

## Switching Between Backends

### Temporary Switch (Current Session)

```bash
# Switch to Gemini for this session
AI_BACKEND=gemini lazygit

# Switch to Ollama for this session
AI_BACKEND=ollama lazygit
```

### Permanent Switch

Edit your shell profile (`~/.bashrc` or `~/.zshrc`):

```bash
# Comment out old backend
# export AI_BACKEND="gemini"
# export GEMINI_API_KEY="..."

# Enable new backend
export AI_BACKEND="ollama"
export OLLAMA_MODEL="mistral"
```

Then reload:
```bash
source ~/.bashrc  # or source ~/.zshrc
```

### Project-Specific Backend

Create a `.envrc` file in your project (requires `direnv`):

```bash
# .envrc
export AI_BACKEND="ollama"  # Use local AI for this sensitive project
```

## Performance Tuning

### Timeout Configuration

Adjust based on your backend:

```bash
# Cloud APIs (fast)
export TIMEOUT_SECONDS=30

# Ollama with small models
export TIMEOUT_SECONDS=60

# Ollama with large models
export TIMEOUT_SECONDS=120
```

### Diff Size Limits

Large diffs can cause timeouts or poor quality. Adjust in `config/config.yml`:

```yaml
# Default: 12KB
git diff --cached | head -c 12000

# For faster processing
git diff --cached | head -c 8000

# For more context
git diff --cached | head -c 20000
```

### Model Selection

Choose models based on your needs:

**Speed Priority**:
- Gemini: `gemini-1.5-flash`
- Claude: `claude-3-5-haiku-20241022`
- Ollama: `mistral:7b-instruct`

**Quality Priority**:
- Gemini: `gemini-1.5-pro`
- Claude: `claude-3-5-sonnet-20241022`
- Ollama: `mixtral:8x7b-instruct`

**Cost Priority**:
- Ollama: Any model (free)
- Gemini: `gemini-1.5-flash` (cheapest cloud)
- Claude: `claude-3-5-haiku-20241022` (affordable)

## Security Best Practices

### API Key Management

**DO**:
- Store keys in environment variables
- Use a secrets manager (e.g., `pass`, `1password-cli`)
- Add `.env` files to `.gitignore`
- Rotate keys regularly

**DON'T**:
- Commit keys to version control
- Share keys in chat/email
- Use the same key across multiple projects
- Store keys in plain text files

### Code Privacy

**Cloud AI (Gemini/Claude)**:
- Your code diffs are sent to external servers
- Review diffs before generating if sensitive
- Consider using Ollama for proprietary code
- Check your organization's AI usage policy

**Local AI (Ollama)**:
- Everything stays on your machine
- No data sent externally
- Safe for sensitive/proprietary code
- Complies with strict privacy requirements

### Network Security

For cloud backends, ensure:
- HTTPS connections (handled by CLI tools)
- Firewall allows outbound HTTPS
- Corporate proxy configured if needed

## Troubleshooting by Backend

### Gemini Issues

**"Invalid API key"**:
```bash
# Verify key is set
echo $GEMINI_API_KEY

# Test the key
python3 -c "
import google.generativeai as genai
import os
genai.configure(api_key=os.environ['GEMINI_API_KEY'])
print('API key is valid')
"
```

**"Rate limit exceeded"**:
- Wait a minute and retry
- Upgrade to paid tier
- Switch to Ollama temporarily

### Claude Issues

**"Authentication failed"**:
```bash
# Verify key is set
echo $ANTHROPIC_API_KEY

# Test the CLI
claude --version
```

**"Insufficient credits"**:
- Add credits at https://console.anthropic.com/
- Switch to Gemini or Ollama

### Ollama Issues

**"Connection refused"**:
```bash
# Check if Ollama is running
curl http://localhost:11434/api/tags

# Start Ollama
ollama serve
```

**"Model not found"**:
```bash
# List installed models
ollama list

# Pull the model
ollama pull mistral
```

**"Too slow"**:
- Use a smaller model: `export OLLAMA_MODEL="mistral:7b"`
- Increase timeout: `export TIMEOUT_SECONDS=120`
- Check system resources: `htop`

## Advanced Configuration

### Custom Prompts per Backend

Edit `ai-commit-generator.sh` to customize prompts:

```bash
case "$AI_BACKEND" in
    gemini)
        PROMPT="Your custom Gemini prompt..."
        ;;
    claude)
        PROMPT="Your custom Claude prompt..."
        ;;
    ollama)
        PROMPT="Your custom Ollama prompt..."
        ;;
esac
```

### Multiple Backends in Parallel

For maximum reliability, you could modify the script to try multiple backends:

```bash
# Try Gemini first, fallback to Ollama
AI_BACKEND=gemini scripts/lazygit-ai-commit/ai-commit-generator.sh || \
AI_BACKEND=ollama scripts/lazygit-ai-commit/ai-commit-generator.sh
```

### Backend-Specific Timeouts

```bash
case "$AI_BACKEND" in
    gemini|claude)
        TIMEOUT_SECONDS=30
        ;;
    ollama)
        TIMEOUT_SECONDS=90
        ;;
esac
```

## Cost Estimation

### Typical Usage

Assuming 50 commits per day, 500 bytes average diff:

**Gemini**:
- Free tier: Unlimited (within rate limits)
- Paid: ~$0.01 per month

**Claude (Haiku)**:
- ~$0.25 per month

**Ollama**:
- $0 (electricity costs only)

### Heavy Usage

Assuming 200 commits per day, 2KB average diff:

**Gemini**:
- Free tier: May hit rate limits
- Paid: ~$0.10 per month

**Claude (Haiku)**:
- ~$1.50 per month

**Ollama**:
- $0 (electricity costs only)

## Recommendations

### For Individual Developers

- **Start with**: Gemini (free, easy setup)
- **Upgrade to**: Claude if you need better quality
- **Switch to**: Ollama for sensitive projects

### For Teams

- **Small teams**: Gemini (cost-effective)
- **Enterprise**: Ollama (privacy, compliance)
- **Quality-focused**: Claude (best output)

### For Open Source Projects

- **Public repos**: Any backend (code is public anyway)
- **Private repos**: Ollama (no data sharing)
- **CI/CD**: Mock backend (no API keys needed)

## Getting Help

If you need assistance with backend configuration:

1. Check the backend's official documentation
2. Verify environment variables: `env | grep -E 'AI_|GEMINI|ANTHROPIC|OLLAMA'`
3. Test the backend independently (outside LazyGit)
4. Check the logs in `ai-commit-generator.sh`
