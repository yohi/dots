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

## Usage

### Basic Workflow

The typical workflow for using AI-generated commit messages:

1. **Make your changes** - Edit files as usual in your project

2. **Open LazyGit** - Run `lazygit` in your repository
   ```bash
   cd your-project
   lazygit
   ```

3. **Stage your changes** - In the Files panel:
   - Navigate to changed files with `↑`/`↓` arrow keys
   - Press `space` to stage individual files
   - Or press `a` to stage all changes

4. **Generate commit messages** - Press `Ctrl+A`
   - You'll see "Generating commit messages with AI..." loading text
   - Wait 1-15 seconds depending on your backend
   - A menu will appear with 5+ commit message options

5. **Review and select** - In the menu:
   - Navigate with `↑`/`↓` arrow keys
   - Read each message carefully
   - Press `Enter` on your preferred message
   - Or press `Esc` to cancel and try again

6. **Commit is created** - LazyGit automatically:
   - Executes `git commit` with your selected message
   - Updates the UI to show the new commit
   - Returns you to the normal view

### Advanced Usage

#### Customizing the Prompt

Edit `ai-commit-generator.sh` to customize how the AI generates messages:

```bash
# Find the PROMPT variable and modify it
PROMPT='Generate 5 commit messages following Conventional Commits format.
Rules:
- Use these types: feat, fix, docs, style, refactor, test, chore
- Be specific and descriptive
- Keep under 72 characters
- No markdown formatting
- One message per line

Additional custom instructions here...'
```

#### Switching Backends On-The-Fly

You can switch AI backends without editing config files:

```bash
# Use Gemini for this session
AI_BACKEND=gemini lazygit

# Use Ollama for this session
AI_BACKEND=ollama lazygit

# Use mock for testing
AI_BACKEND=mock lazygit
```

#### Adjusting Timeout

For slower backends or large diffs:

```bash
# Increase timeout to 60 seconds
TIMEOUT_SECONDS=60 lazygit

# Or set permanently in ~/.bashrc
export TIMEOUT_SECONDS=60
```

#### Controlling Diff Size

Adjust how much context is sent to the AI:

Edit `config.yml` and change the `head -c` value:

```yaml
# Smaller diffs (faster, less context)
git diff --cached | head -c 8000 | ...

# Larger diffs (slower, more context)
git diff --cached | head -c 20000 | ...

# Default (balanced)
git diff --cached | head -c 12000 | ...
```

#### Using Different Models

For each backend, you can specify which model to use:

```bash
# Gemini models
export GEMINI_MODEL="gemini-1.5-flash"  # Fast (default)
export GEMINI_MODEL="gemini-1.5-pro"    # Higher quality

# Claude models
export CLAUDE_MODEL="claude-3-5-haiku-20241022"   # Fast (default)
export CLAUDE_MODEL="claude-3-5-sonnet-20241022"  # Higher quality

# Ollama models
export OLLAMA_MODEL="mistral"      # Balanced (default)
export OLLAMA_MODEL="codellama"    # Code-focused
export OLLAMA_MODEL="mixtral"      # Higher quality
```

### Best Practices

#### Commit Frequently with Focused Changes

- Stage related changes together
- Keep commits atomic (one logical change per commit)
- The AI works best with focused, coherent diffs

#### Review Before Committing

- Always read the generated message before pressing Enter
- Ensure it accurately describes your changes
- Select a different option if the first isn't perfect

#### Stage Meaningful Changes

- Avoid staging whitespace-only changes
- Don't stage unrelated changes together
- The AI generates better messages for clear, purposeful changes

#### Use Conventional Commits Types Appropriately

The AI will suggest types like:
- `feat:` - New features
- `fix:` - Bug fixes
- `docs:` - Documentation changes
- `style:` - Code style changes (formatting, etc.)
- `refactor:` - Code refactoring
- `test:` - Adding or updating tests
- `chore:` - Maintenance tasks

#### Combine with Manual Commits

You don't have to use AI for every commit:
- Use `c` in LazyGit for manual commits when you prefer
- Use `Ctrl+A` when you want AI suggestions
- Mix and match based on your needs

### Keyboard Shortcuts Reference

In LazyGit Files view:
- `space` - Stage/unstage file
- `a` - Stage all files
- `Ctrl+A` - Generate AI commit messages (custom command)
- `c` - Manual commit (traditional)
- `Esc` - Cancel/go back

In the AI message menu:
- `↑`/`↓` - Navigate messages
- `Enter` - Select and commit
- `Esc` - Cancel and return to files view

### Example Workflows

#### Workflow 1: Feature Development

```bash
# 1. Implement a new feature
vim src/auth.js  # Add JWT authentication

# 2. Open LazyGit
lazygit

# 3. Stage the file
# Press 'space' on src/auth.js

# 4. Generate messages
# Press Ctrl+A

# 5. Select from options like:
#    - feat(auth): add JWT token validation
#    - feat(auth): implement authentication middleware
#    - feat: add user authentication with JWT

# 6. Press Enter on your choice
```

#### Workflow 2: Bug Fix

```bash
# 1. Fix a bug
vim src/database.js  # Fix connection timeout

# 2. Open LazyGit and stage
lazygit
# Press 'space' on src/database.js

# 3. Generate messages
# Press Ctrl+A

# 4. Select from options like:
#    - fix(db): correct connection timeout handling
#    - fix(database): resolve timeout issue
#    - fix: prevent database connection timeouts

# 5. Press Enter
```

#### Workflow 3: Multiple Files

```bash
# 1. Make related changes across files
vim src/api.js src/routes.js tests/api.test.js

# 2. Open LazyGit
lazygit

# 3. Stage all related files
# Press 'a' to stage all, or 'space' on each file

# 4. Generate messages
# Press Ctrl+A

# 5. Select from options like:
#    - feat(api): add user profile endpoints
#    - feat: implement user profile API with tests
#    - feat(routes): add profile routes and handlers

# 6. Press Enter
```

#### Workflow 4: Documentation

```bash
# 1. Update documentation
vim README.md CONTRIBUTING.md

# 2. Open LazyGit and stage
lazygit
# Press 'space' on documentation files

# 3. Generate messages
# Press Ctrl+A

# 4. Select from options like:
#    - docs: update README with installation steps
#    - docs(readme): add contributing guidelines
#    - docs: improve project documentation

# 5. Press Enter
```

### Tips and Tricks

#### Tip 1: Try Multiple Times

If the first set of messages isn't great:
- Press `Esc` to cancel
- Press `Ctrl+A` again for new suggestions
- The AI generates different options each time

#### Tip 2: Use Scopes Effectively

Look for messages with scopes like `feat(auth):` or `fix(db):`:
- Scopes help organize commits by component
- They make git history more searchable
- They're especially useful in larger projects

#### Tip 3: Combine with Git Aliases

Create shell aliases for common workflows:

```bash
# Add to ~/.bashrc or ~/.zshrc
alias lg='lazygit'
alias lga='cd $(git rev-parse --show-toplevel) && lazygit'
```

#### Tip 4: Use for Learning

The AI-generated messages can teach you:
- How to write better commit messages
- Conventional Commits format
- How to describe changes concisely

#### Tip 5: Backend Selection Strategy

- **Development**: Use Gemini (fast, free)
- **Sensitive code**: Use Ollama (private)
- **Important commits**: Use Claude (best quality)
- **Testing**: Use mock (no API needed)

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

## Testing

### Run the Complete Test Suite

Verify your installation is working correctly:

```bash
# Run all integration tests (23 tests)
./test-complete-workflow.sh

# Run error scenario tests
./test-all-error-scenarios.sh

# Test specific components
./test-lazygit-commit-integration.sh
./test-regex-parser.sh
./test-error-handling.sh
```

**Expected result**: All tests should pass with green checkmarks.

The test suite validates:
- ✅ Complete workflow from diff to commit
- ✅ Special character handling and shell escaping
- ✅ Empty staging detection
- ✅ Large diff truncation (12KB limit)
- ✅ Conventional Commits format compliance
- ✅ Markdown removal from messages
- ✅ Timeout handling (30s default)
- ✅ Error recovery and user feedback
- ✅ Multiple backend support (Gemini, Claude, Ollama, Mock)
- ✅ Parser robustness with various input formats

For detailed testing instructions, see [TESTING-GUIDE.md](TESTING-GUIDE.md).

### Manual Testing

Test in a real repository:

```bash
# Create a test repo
mkdir ~/test-ai-commit
cd ~/test-ai-commit
git init

# Make some changes
echo "function hello() { return 'world'; }" > test.js
git add test.js

# Open LazyGit and test
lazygit
# Press Ctrl+A, select a message, press Enter

# Verify the commit
git log -1
```

### Quick Verification

Verify each component works:

```bash
# 1. Test AI generation
echo "test change" | AI_BACKEND=mock ./ai-commit-generator.sh

# 2. Test parser
echo -e "feat: test\nfix: another" | ./parse-ai-output.sh

# 3. Test complete pipeline
git diff --cached | ./ai-commit-generator.sh | ./parse-ai-output.sh
```

## Troubleshooting

### Installation Issues

#### "No such file or directory" when pressing Ctrl+A

**Problem**: Script paths in config.yml are incorrect

**Solution**:
1. Find where you installed the scripts: `pwd` in the installation directory
2. Edit `~/.config/lazygit/config.yml` and update paths to absolute paths:
   ```yaml
   git diff --cached | head -c 12000 | /full/path/to/ai-commit-generator.sh | /full/path/to/parse-ai-output.sh
   ```
3. Ensure scripts are executable: `chmod +x *.sh`

#### "command not found: gemini" or similar

**Problem**: AI CLI tool not in PATH

**Solution**:
- For Python packages: `pip install --user google-generativeai` and ensure `~/.local/bin` is in PATH
- For npm packages: `npm install -g @anthropic-ai/claude-cli` and ensure npm global bin is in PATH
- Verify installation: `which gemini` or `which claude` or `which ollama`

#### LazyGit doesn't show Ctrl+A option

**Problem**: Config file not loaded or has syntax errors

**Solution**:
1. Verify config location: `ls -la ~/.config/lazygit/config.yml`
2. Check for YAML syntax errors: `python3 -c "import yaml; yaml.safe_load(open('config.yml'))"`
3. Restart LazyGit completely (close all instances)
4. Check LazyGit version: `lazygit --version` (ensure it's recent)

### Runtime Issues

#### "No staged changes" Error

**Problem**: Message appears when pressing Ctrl+A

**Solution**: Stage files first by pressing `space` on them in LazyGit

**Requirement**: 2.4 - System prevents execution when staging area is empty

#### "AI tool failed" Error

**Problem**: AI backend returns an error

**Solutions**:
- Check your API key is set correctly: `echo $GEMINI_API_KEY`
- Verify the AI tool is installed: `which gemini` or `ollama list`
- Check your internet connection (for cloud AI)
- For Ollama: Ensure service is running: `ollama serve`
- Test the AI tool independently: `echo "test" | ./ai-commit-generator.sh`

**Requirement**: 8.2 - Enhanced error handling with proper error messages

#### "Timeout" Error

**Problem**: AI takes too long to respond (>30 seconds default)

**Solutions**:
- Increase timeout: `export TIMEOUT_SECONDS=60` (or add to ~/.bashrc)
- Stage fewer files at once to reduce diff size
- For Ollama: Use a smaller/faster model: `export OLLAMA_MODEL="mistral:7b"`
- For large diffs: Reduce size limit in config.yml: `head -c 8000` instead of `head -c 12000`

**Requirement**: 8.4 - Timeout handling prevents hanging

#### "GEMINI_API_KEY not set" or "ANTHROPIC_API_KEY not set"

**Problem**: Environment variable not configured

**Solution**:
```bash
# Check if set
echo $GEMINI_API_KEY

# Set temporarily
export GEMINI_API_KEY="your-key-here"
export AI_BACKEND="gemini"

# Set permanently (add to ~/.bashrc or ~/.zshrc)
echo 'export GEMINI_API_KEY="your-key-here"' >> ~/.bashrc
echo 'export AI_BACKEND="gemini"' >> ~/.bashrc
source ~/.bashrc
```

**Requirement**: 7.1 - API key management via environment variables

### Quality Issues

#### Messages Have Markdown Formatting

**Problem**: Generated messages contain `**bold**`, `` `code` ``, or other markdown

**Solution**: This shouldn't happen with the configured prompts. If it does:
1. Verify you're using the latest version of the scripts
2. Check the prompt in `ai-commit-generator.sh` includes "No markdown" instruction
3. Try a different AI backend (Claude is best at following format rules)
4. For Ollama: Try a different model or adjust the prompt

**Requirement**: 6.3 - Messages should not contain markdown formatting

#### Messages Don't Follow Conventional Commits

**Problem**: Messages don't have `feat:`, `fix:`, etc. prefixes

**Solution**:
1. Verify the prompt in `ai-commit-generator.sh` mentions Conventional Commits
2. Try Claude backend (best at following format)
3. For Ollama: Use `codellama` model which understands code conventions better
4. Manually edit the prompt to emphasize the format requirement

**Requirement**: 6.1 - Messages must follow Conventional Commits format

#### Messages Are Too Generic

**Problem**: Messages like "update files" or "make changes"

**Solution**:
1. Stage more specific changes (smaller, focused commits)
2. Try Claude backend for better code understanding
3. For Ollama: Use a larger model like `mixtral`
4. Ensure your diff is meaningful (not just whitespace changes)

### Security Issues

#### Special Characters Break Commits

**Problem**: Commits fail with messages containing quotes, backticks, or special characters

**Solution**: This is handled automatically by LazyGit's `| quote` filter. If issues persist:
1. Verify `config.yml` has `{{.Form.SelectedMsg | quote}}` in the command section
2. Update LazyGit to the latest version
3. Test escaping manually: `printf %q "test 'message' with \"quotes\""`

**Requirement**: 4.2, 8.3 - Proper shell escaping prevents injection

#### Concerned About Code Privacy

**Problem**: Don't want to send code to external servers

**Solution**:
1. Use Ollama backend (completely local): `export AI_BACKEND="ollama"`
2. Review diffs before generating (check what's staged)
3. Use `.gitignore` to prevent staging sensitive files
4. For very sensitive projects, use mock backend for testing only

**Requirement**: 7.1, 7.3 - Pluggable backends allow privacy-focused options

### Performance Issues

#### AI Responses Are Slow

**Problem**: Takes more than 10 seconds to generate messages

**Solutions**:
- For Gemini/Claude: Check internet connection speed
- For Ollama: 
  - Use a smaller model: `export OLLAMA_MODEL="mistral:7b"`
  - Enable GPU acceleration if available
  - Increase system resources allocated to Ollama
- Reduce diff size: Stage fewer files or reduce size limit in config.yml

#### LazyGit Freezes During Generation

**Problem**: LazyGit becomes unresponsive

**Solution**:
1. This is expected - LazyGit waits for the command to complete
2. The `loadingText` should show "Generating commit messages with AI..."
3. If it truly freezes (no loading text), check timeout settings
4. Reduce timeout to fail faster: `export TIMEOUT_SECONDS=15`

**Requirement**: 1.2 - Loading feedback during AI processing

### Debugging

#### Enable Verbose Logging

Add debug output to troubleshoot issues:

```bash
# Edit ai-commit-generator.sh and add at the top:
set -x  # Enable debug mode

# Or run manually with debug:
bash -x ./ai-commit-generator.sh < test-diff.txt
```

#### Test Components Individually

```bash
# Test diff generation
git diff --cached

# Test AI generation
git diff --cached | ./ai-commit-generator.sh

# Test parsing
echo -e "feat: test\nfix: another" | ./parse-ai-output.sh

# Test complete pipeline
git diff --cached | head -c 12000 | ./ai-commit-generator.sh | ./parse-ai-output.sh
```

#### Check LazyGit Logs

LazyGit may log errors to stderr:

```bash
# Run LazyGit with error output visible
lazygit 2>&1 | tee lazygit-errors.log
```

### Getting Help

If you're still stuck:

1. **Run the test suite**: `./test-complete-workflow.sh` - it will identify specific issues
2. **Check the documentation**:
   - [INSTALLATION.md](INSTALLATION.md) - Detailed setup instructions
   - [AI-BACKEND-GUIDE.md](AI-BACKEND-GUIDE.md) - Backend-specific help
   - [QUICKSTART.md](QUICKSTART.md) - Quick setup paths
3. **Test your AI backend independently**:
   ```bash
   # For Gemini
   python3 -c "import google.generativeai as genai; print('OK')"
   
   # For Claude
   claude --version
   
   # For Ollama
   ollama list
   ```
4. **Verify environment variables**: `env | grep -E 'AI_|GEMINI|ANTHROPIC|OLLAMA'`
5. **Check script permissions**: `ls -l *.sh` (should show `-rwxr-xr-x`)

### Common Error Messages

| Error Message | Cause | Solution |
|---------------|-------|----------|
| "No diff input provided" | Empty staging area | Stage files with `space` in LazyGit |
| "AI tool failed" | Backend error or not installed | Check API key and installation |
| "timed out after X seconds" | AI took too long | Increase timeout or reduce diff size |
| "No valid commit messages found" | Parser received empty/invalid output | Check AI backend is working |
| "command not found" | Script path wrong in config | Use absolute paths in config.yml |
| "GEMINI_API_KEY not set" | Missing environment variable | Set API key in shell profile |

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

## Documentation

This project includes comprehensive documentation:

- **[README.md](README.md)** (this file) - Overview, features, and quick start
- **[QUICKSTART.md](QUICKSTART.md)** - Get started in under 5 minutes
- **[INSTALLATION.md](INSTALLATION.md)** - Detailed installation instructions
- **[AI-BACKEND-GUIDE.md](AI-BACKEND-GUIDE.md)** - Complete guide to AI backends
- **[BACKEND-COMPARISON.md](BACKEND-COMPARISON.md)** - Compare backends at a glance
- **[TESTING-GUIDE.md](TESTING-GUIDE.md)** - How to test your installation
- **[config.example.yml](config.example.yml)** - Annotated configuration example

### Quick Links

- **New users**: Start with [QUICKSTART.md](QUICKSTART.md)
- **Installation help**: See [INSTALLATION.md](INSTALLATION.md)
- **Choosing a backend**: Read [BACKEND-COMPARISON.md](BACKEND-COMPARISON.md)
- **Backend setup**: Check [AI-BACKEND-GUIDE.md](AI-BACKEND-GUIDE.md)
- **Testing**: Follow [TESTING-GUIDE.md](TESTING-GUIDE.md)
- **Troubleshooting**: See the Troubleshooting section above

## Contributing

Contributions welcome! Please ensure:
- All tests pass (`./test-complete-workflow.sh`)
- Follow Conventional Commits format
- Update documentation for new features
- Add tests for new functionality

## Credits

Built following the spec-driven development methodology with property-based testing.

**Methodology**:
- Requirements-driven design with EARS patterns
- Correctness properties defined upfront
- Comprehensive test coverage
- Iterative refinement with user feedback

**Architecture**:
- LazyGit Custom Commands integration
- Pluggable AI backend system
- Shell-based pipeline architecture
- Security-first design (proper escaping, timeout handling)
