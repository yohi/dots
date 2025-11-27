# LazyGit AI Commit Message Generator

AI-powered commit message generation integrated directly into LazyGit. Generate high-quality, Conventional Commits-formatted messages without leaving your terminal UI.

## Features

- 🤖 **Multiple AI Backends**: Support for Gemini, Claude, and Ollama
- ⚡ **Zero Context Switch**: Everything happens within LazyGit's TUI
- 🎯 **Conventional Commits**: Automatically formatted messages (feat:, fix:, etc.)
- 🔒 **Security First**: Proper shell escaping and injection prevention
- 📝 **Multiple Candidates**: Choose from 5 AI-generated options
- ⏱️ **Timeout Protection**: 30-second timeout prevents hanging

## Quick Start

### 1. Choose Your AI Backend

#### Option A: Gemini (Recommended - Fast & Free)

```bash
# Install Gemini CLI
pip install google-generativeai

# Set API key
export GEMINI_API_KEY="your-api-key-here"
```

Get your API key from: https://aistudio.google.com/app/apikey

#### Option B: Claude (Best for Code Understanding)

```bash
# Install Claude CLI
npm install -g @anthropic-ai/claude-cli

# Set API key
export ANTHROPIC_API_KEY="your-api-key-here"
```

Get your API key from: https://console.anthropic.com/

#### Option C: Ollama (Local & Private)

```bash
# Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# Pull a model (e.g., mistral)
ollama pull mistral

# Start Ollama service
ollama serve
```

No API key needed - runs completely locally!

### 2. Configure LazyGit

Copy the provided `config.yml` to your LazyGit config directory:

```bash
# Linux/macOS
cp config.yml ~/.config/lazygit/config.yml

# Or merge with existing config
cat config.yml >> ~/.config/lazygit/config.yml
```

### 3. Set Your AI Backend

Edit `config.yml` and uncomment your chosen AI backend in the `AI_BACKEND` variable:

```yaml
# For Gemini (default)
export AI_BACKEND=gemini

# For Claude
export AI_BACKEND=claude

# For Ollama
export AI_BACKEND=ollama
```

### 4. Make Scripts Executable

```bash
chmod +x ai-commit-generator.sh
chmod +x parse-ai-output.sh
chmod +x get-staged-diff.sh
```

### 5. Use in LazyGit

1. Stage your changes in LazyGit (press `space` on files)
2. Press `Ctrl+A` to generate commit messages
3. Select your preferred message from the menu
4. Press `Enter` to commit

## Configuration

### Environment Variables

Set these in your shell profile (`~/.bashrc`, `~/.zshrc`, etc.):

```bash
# Required: Choose your AI backend
export AI_BACKEND="gemini"  # or "claude" or "ollama"

# Required for cloud AI: Set your API key
export GEMINI_API_KEY="your-key"      # For Gemini
export ANTHROPIC_API_KEY="your-key"   # For Claude

# Optional: Customize behavior
export TIMEOUT_SECONDS=30              # AI request timeout (default: 30)
export OLLAMA_MODEL="mistral"          # Ollama model (default: mistral)
```

### AI Backend Details

#### Gemini Configuration

```bash
export AI_BACKEND="gemini"
export GEMINI_API_KEY="your-api-key"
export GEMINI_MODEL="gemini-1.5-flash"  # Optional, default shown
```

**Pros**: Fast, generous free tier, good quality
**Cons**: Requires internet, sends code to Google

#### Claude Configuration

```bash
export AI_BACKEND="claude"
export ANTHROPIC_API_KEY="your-api-key"
export CLAUDE_MODEL="claude-3-5-haiku-20241022"  # Optional, default shown
```

**Pros**: Excellent code understanding, high quality
**Cons**: Requires internet, paid API (though affordable)

#### Ollama Configuration

```bash
export AI_BACKEND="ollama"
export OLLAMA_MODEL="mistral"  # Optional, default shown
export OLLAMA_HOST="http://localhost:11434"  # Optional, default shown
```

**Pros**: Completely local, private, no API costs
**Cons**: Requires local resources, slower than cloud APIs

**Recommended models**:
- `mistral` - Good balance of speed and quality
- `codellama` - Optimized for code
- `llama2` - General purpose

## Troubleshooting

### "No staged changes" Error

**Problem**: Message appears when pressing Ctrl+A

**Solution**: Stage files first by pressing `space` on them in LazyGit

### "AI tool failed" Error

**Problem**: AI backend returns an error

**Solutions**:
- Check your API key is set correctly: `echo $GEMINI_API_KEY`
- Verify the AI tool is installed: `which gemini` or `ollama list`
- Check your internet connection (for cloud AI)
- For Ollama: Ensure service is running: `ollama serve`

### "Timeout" Error

**Problem**: AI takes too long to respond

**Solutions**:
- Increase timeout: `export TIMEOUT_SECONDS=60`
- Stage fewer files at once
- For Ollama: Use a smaller/faster model

### Messages Have Markdown Formatting

**Problem**: Generated messages contain `**bold**` or other markdown

**Solution**: This shouldn't happen with the configured prompts. If it does:
1. Update to the latest version of the AI tool
2. Check the prompt in `ai-commit-generator.sh` is correct
3. Report as a bug

### Special Characters Break Commits

**Problem**: Commits fail with messages containing quotes or special characters

**Solution**: This is handled automatically by LazyGit's `| quote` filter. If issues persist:
1. Verify `config.yml` has `{{.Form.SelectedMsg | quote}}`
2. Update LazyGit to the latest version

## Advanced Usage

### Custom Prompts

Edit `ai-commit-generator.sh` to customize the prompt sent to the AI:

```bash
PROMPT='Your custom instructions here...'
```

### Multiple AI Backends

You can switch backends on-the-fly:

```bash
# In one terminal session
AI_BACKEND=gemini lazygit

# In another
AI_BACKEND=ollama lazygit
```

### Size Limits

Large diffs are automatically truncated to 12KB to avoid token limits. Adjust in `config.yml`:

```yaml
git diff --cached | head -c 12000  # Change 12000 to your preferred size
```

## Security Considerations

### API Keys

- **Never commit API keys** to version control
- Store in environment variables or secure key management
- Use `.bashrc`/`.zshrc` or a secrets manager

### Code Privacy

- **Cloud AI (Gemini/Claude)**: Your code diffs are sent to external servers
- **Local AI (Ollama)**: Everything stays on your machine
- For sensitive projects, use Ollama or review diffs before generating

### Shell Injection

- All user input is properly escaped via LazyGit's `| quote` filter
- The system is designed to prevent command injection attacks

## Requirements

- LazyGit (latest version recommended)
- Git
- Bash
- One of: Python 3 (Gemini), Node.js (Claude), or Ollama
- Internet connection (for cloud AI backends)

## License

MIT

## Contributing

Contributions welcome! Please ensure:
- All tests pass
- Follow Conventional Commits format
- Update documentation for new features

## Credits

Built following the spec-driven development methodology with property-based testing.
