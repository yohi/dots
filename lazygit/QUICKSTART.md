# Quick Start Guide

Get AI-powered commit messages in LazyGit in under 5 minutes!

## Choose Your Path

### Path 1: Quick Test (No Setup Required)

Try it out with the mock backend first:

```bash
# 1. Clone the repository
git clone <repo-url> ~/lazygit-ai-commit
cd ~/lazygit-ai-commit

# 2. Make scripts executable
chmod +x *.sh

# 3. Test it works
export AI_BACKEND=mock
echo "test change" | ./ai-commit-generator.sh

# 4. Update config.yml with full paths
# Edit config.yml and replace ./ai-commit-generator.sh with full path
# Example: /home/username/lazygit-ai-commit/ai-commit-generator.sh

# 5. Copy to LazyGit config
cp config.yml ~/.config/lazygit/config.yml

# 6. Try it in LazyGit
cd /tmp
git init test-repo
cd test-repo
echo "test" > test.txt
git add test.txt
lazygit
# Press Ctrl+A to see AI-generated messages!
```

### Path 2: Gemini Setup (Recommended)

Get real AI-powered messages with Google Gemini:

```bash
# 1. Install Gemini
pip install google-generativeai

# 2. Get API key
# Visit: https://aistudio.google.com/app/apikey
# Click "Create API Key" and copy it

# 3. Set environment variable
echo 'export GEMINI_API_KEY="your-key-here"' >> ~/.bashrc
echo 'export AI_BACKEND="gemini"' >> ~/.bashrc
source ~/.bashrc

# 4. Clone and setup
git clone <repo-url> ~/lazygit-ai-commit
cd ~/lazygit-ai-commit
chmod +x *.sh

# 5. Test it
echo "test change" | ./ai-commit-generator.sh

# 6. Update paths in config.yml and copy to LazyGit
# Edit config.yml: replace ./ai-commit-generator.sh with full path
cp config.yml ~/.config/lazygit/config.yml

# 7. Use in LazyGit
lazygit
# Press Ctrl+A in files view!
```

### Path 3: Ollama Setup (Privacy-Focused)

Run AI completely locally:

```bash
# 1. Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 2. Pull a model
ollama pull mistral

# 3. Start Ollama (in a separate terminal)
ollama serve

# 4. Set environment variable
echo 'export AI_BACKEND="ollama"' >> ~/.bashrc
source ~/.bashrc

# 5. Clone and setup
git clone <repo-url> ~/lazygit-ai-commit
cd ~/lazygit-ai-commit
chmod +x *.sh

# 6. Test it
echo "test change" | ./ai-commit-generator.sh

# 7. Update paths in config.yml and copy to LazyGit
# Edit config.yml: replace ./ai-commit-generator.sh with full path
cp config.yml ~/.config/lazygit/config.yml

# 8. Use in LazyGit
lazygit
# Press Ctrl+A in files view!
```

## Usage

Once set up:

1. **Stage your changes** in LazyGit (press `space` on files)
2. **Press `Ctrl+A`** to generate commit messages
3. **Navigate** with arrow keys
4. **Press `Enter`** to commit with selected message
5. **Press `Esc`** to cancel

## Troubleshooting

### "No such file or directory"

**Problem**: Script paths in config.yml are wrong

**Fix**: Edit `~/.config/lazygit/config.yml` and use full absolute paths:
```yaml
git diff --cached | head -c 12000 | /home/username/lazygit-ai-commit/ai-commit-generator.sh | /home/username/lazygit-ai-commit/parse-ai-output.sh
```

### "GEMINI_API_KEY not set"

**Problem**: Environment variable not configured

**Fix**:
```bash
export GEMINI_API_KEY="your-key"
export AI_BACKEND="gemini"
# Add to ~/.bashrc to make permanent
```

### "AI tool failed"

**Problem**: Backend not installed or not running

**Fix**:
- Gemini: `pip install google-generativeai`
- Claude: `npm install -g @anthropic-ai/claude-cli`
- Ollama: Ensure `ollama serve` is running

### "No staged changes"

**Problem**: No files staged for commit

**Fix**: Press `space` on files in LazyGit to stage them first

## Next Steps

- Read [README.md](README.md) for full documentation
- See [INSTALLATION.md](INSTALLATION.md) for detailed setup
- Check [AI-BACKEND-GUIDE.md](AI-BACKEND-GUIDE.md) for backend comparison
- Customize prompts in `ai-commit-generator.sh`

## Getting Help

Run the test suite to diagnose issues:
```bash
./test-ai-backend-integration.sh
```

This will tell you exactly what's working and what needs fixing!
