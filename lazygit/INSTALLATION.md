# Installation Guide

This guide walks you through setting up the LazyGit AI Commit Message Generator with your preferred AI backend.

## Prerequisites

- LazyGit installed and working
- Git
- Bash shell
- Internet connection (for cloud AI backends)

## Step-by-Step Installation

### Step 1: Choose Your AI Backend

You need to choose one of three AI backends. Each has different trade-offs:

| Backend | Pros | Cons | Best For |
|---------|------|------|----------|
| **Gemini** | Fast, generous free tier, good quality | Requires internet, sends code to Google | Most users, quick setup |
| **Claude** | Excellent code understanding | Paid API, requires internet | Professional use, best quality |
| **Ollama** | Completely local, private, free | Slower, requires local resources | Privacy-sensitive projects |

### Step 2: Install Your Chosen Backend

#### Option A: Gemini (Recommended)

1. Install the Google Generative AI Python package:
   ```bash
   pip install google-generativeai
   ```

2. Get your API key:
   - Visit https://aistudio.google.com/app/apikey
   - Click "Create API Key"
   - Copy the key

3. Set the environment variable:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export GEMINI_API_KEY="your-api-key-here"
   export AI_BACKEND="gemini"
   ```

4. Reload your shell:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

#### Option B: Claude

1. Install the Claude CLI:
   ```bash
   npm install -g @anthropic-ai/claude-cli
   ```

2. Get your API key:
   - Visit https://console.anthropic.com/
   - Create an account and add credits
   - Generate an API key

3. Set the environment variable:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export ANTHROPIC_API_KEY="your-api-key-here"
   export AI_BACKEND="claude"
   ```

4. Reload your shell:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

#### Option C: Ollama (Local)

1. Install Ollama:
   ```bash
   curl -fsSL https://ollama.com/install.sh | sh
   ```

2. Pull a model (choose one):
   ```bash
   # Mistral (recommended - good balance)
   ollama pull mistral
   
   # OR CodeLlama (optimized for code)
   ollama pull codellama
   
   # OR Llama2 (general purpose)
   ollama pull llama2
   ```

3. Start the Ollama service:
   ```bash
   ollama serve
   ```
   
   Note: You may want to set this up as a system service to start automatically.

4. Set the environment variable:
   ```bash
   # Add to ~/.bashrc or ~/.zshrc
   export AI_BACKEND="ollama"
   export OLLAMA_MODEL="mistral"  # or your chosen model
   ```

5. Reload your shell:
   ```bash
   source ~/.bashrc  # or source ~/.zshrc
   ```

### Step 3: Install the Scripts

1. Clone or download this repository to a location on your system:
   ```bash
   cd ~/projects  # or your preferred location
   git clone <repository-url> lazygit-ai-commit
   cd lazygit-ai-commit
   ```

2. Make the scripts executable:
   ```bash
   chmod +x ai-commit-generator.sh
   chmod +x parse-ai-output.sh
   chmod +x get-staged-diff.sh
   chmod +x mock-ai-tool.sh
   ```

### Step 4: Configure LazyGit

1. Locate your LazyGit config directory:
   ```bash
   # Linux/macOS
   mkdir -p ~/.config/lazygit
   
   # The config file should be at:
   # ~/.config/lazygit/config.yml
   ```

2. Update the script paths in `config.yml`:
   
   Open `config.yml` and update the paths to point to where you installed the scripts:
   
   ```yaml
   command: |
     # ... existing config ...
     git diff --cached | head -c 12000 | /full/path/to/ai-commit-generator.sh | /full/path/to/parse-ai-output.sh
   ```
   
   Replace `/full/path/to/` with the actual path where you cloned the repository.

3. Copy or merge the config:
   ```bash
   # If you don't have an existing config:
   cp config.yml ~/.config/lazygit/config.yml
   
   # If you have an existing config, merge the customCommands section:
   # Open both files and copy the AI commit command to your existing config
   ```

### Step 5: Test the Installation

1. Create a test repository:
   ```bash
   mkdir ~/test-ai-commit
   cd ~/test-ai-commit
   git init
   echo "test" > test.txt
   git add test.txt
   ```

2. Open LazyGit:
   ```bash
   lazygit
   ```

3. Press `Ctrl+A` to trigger the AI commit generator

4. You should see:
   - "Generating commit messages with AI..." loading message
   - A menu with 5 commit message options
   - Messages in Conventional Commits format

5. Select a message and press Enter to commit

### Step 6: Verify Everything Works

Run the test suite to ensure everything is configured correctly:

```bash
# Test with mock backend (no API key needed)
export AI_BACKEND=mock
./test-all-error-scenarios.sh

# Test with your chosen backend
export AI_BACKEND=gemini  # or claude or ollama
echo "test change" | ./ai-commit-generator.sh
```

If you see commit messages generated, you're all set!

## Troubleshooting Installation

### "command not found: gemini" or similar

**Problem**: The AI CLI tool is not in your PATH

**Solution**:
- For Python packages: Ensure pip install location is in PATH
- For npm packages: Ensure npm global bin is in PATH
- Check with: `which gemini` or `which claude` or `which ollama`

### "GEMINI_API_KEY not set" error

**Problem**: Environment variable not configured

**Solution**:
1. Check if it's set: `echo $GEMINI_API_KEY`
2. If empty, add to your shell profile:
   ```bash
   echo 'export GEMINI_API_KEY="your-key"' >> ~/.bashrc
   source ~/.bashrc
   ```

### "No such file or directory" when pressing Ctrl+A

**Problem**: Script paths in config.yml are incorrect

**Solution**:
1. Find where you installed the scripts: `pwd`
2. Update config.yml with full absolute paths
3. Ensure scripts are executable: `ls -l *.sh`

### Ollama "connection refused" error

**Problem**: Ollama service is not running

**Solution**:
```bash
# Start Ollama in a separate terminal
ollama serve

# Or set up as a system service (Linux)
sudo systemctl enable ollama
sudo systemctl start ollama
```

### LazyGit doesn't show the Ctrl+A option

**Problem**: Config file not loaded or syntax error

**Solution**:
1. Check config location: `ls -la ~/.config/lazygit/config.yml`
2. Validate YAML syntax: `python3 -c "import yaml; yaml.safe_load(open('config.yml'))"`
3. Restart LazyGit completely

## Next Steps

- Read [README.md](README.md) for usage instructions
- Customize the prompt in `ai-commit-generator.sh`
- Set up additional environment variables for fine-tuning
- Consider setting up shell aliases for quick backend switching

## Getting Help

If you encounter issues:

1. Check the [Troubleshooting](README.md#troubleshooting) section in README.md
2. Verify your AI backend is working independently:
   ```bash
   # For Gemini
   python3 -c "import google.generativeai as genai; print('OK')"
   
   # For Claude
   claude --version
   
   # For Ollama
   ollama list
   ```
3. Test the scripts individually:
   ```bash
   echo "test diff" | ./ai-commit-generator.sh
   ```
4. Check LazyGit logs for errors

## Uninstallation

To remove the AI commit generator:

1. Remove the custom command from `~/.config/lazygit/config.yml`
2. Delete the cloned repository
3. Remove environment variables from your shell profile
4. (Optional) Uninstall the AI CLI tools:
   ```bash
   pip uninstall google-generativeai
   npm uninstall -g @anthropic-ai/claude-cli
   # For Ollama, follow their uninstall instructions
   ```
