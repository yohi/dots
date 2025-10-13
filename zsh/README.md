# 🐚 Zsh Configuration

Modern, high-performance Zsh configuration with AWS integration, powerful theming, and intelligent function loading.

## 📋 Table of Contents

- [Features](#-features)
- [Quick Start](#-quick-start)
- [Directory Structure](#-directory-structure)
- [Configuration Files](#️-configuration-files)
- [AWS Functions](#-aws-functions)
- [Performance](#-performance)
- [Customization](#-customization)
- [Troubleshooting](#-troubleshooting)

---

## ✨ Features

### Core Features
- ⚡ **Fast Startup**: Optimized loading with Powerlevel10k instant prompt (~60-70ms)
- 🎨 **Modern Theme**: Powerlevel10k with customizable segments
- 📦 **Plugin Management**: Zinit for efficient plugin loading
- 🔧 **AWS Integration**: Comprehensive AWS CLI helper functions
- 🔒 **Privacy First**: IDE history isolation, telemetry opt-out
- 📝 **Well Documented**: Inline comments and external guides

### AWS Functions
- **EC2**: Interactive SSM connections, instance listing
- **RDS**: Smart RDS connections via SSM port forwarding
- **CloudWatch**: Real-time log streaming
- **ECS**: Cluster and service management
- **Auto-complete**: fzf-powered resource selection

### Developer Experience
- 🎯 **Smart Completion**: Context-aware completions
- 📚 **Extensive History**: 1M saved commands with deduplication
- 🌈 **Syntax Highlighting**: Fast syntax highlighting via Zinit
- 🔍 **Fuzzy Finding**: fzf integration for history and files
- 🚀 **Auto-suggestions**: Command suggestions from history

---

## 🚀 Quick Start

### Installation

```bash
# 1. Install dependencies
sudo apt-get install zsh fzf

# 2. Install AWS CLI v2 (optional, for AWS functions)
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# 3. Link configuration
ln -sf ~/dots/zsh/zshrc ~/.zshrc

# 4. Start zsh
zsh

# Zinit will auto-install on first run
```

### First Configuration

```bash
# 1. Copy configuration template
cp ~/dots/zsh/config.example.zsh ~/dots/zsh/config.zsh

# 2. Edit configuration (optional)
vim ~/dots/zsh/config.zsh

# 3. Configure AWS (if using AWS functions)
aws configure --profile default

# 4. Reload shell
exec zsh
```

### Quick Test

```bash
# Test AWS functions
aws-help

# List available functions
type ec2-ssm rds-ssm awslogs
```

---

## 📁 Directory Structure

```
zsh/
├── README.md                 # This file
├── QUICKSTART.md            # Quick start guide (6.9KB)
├── zshrc                    # Main configuration file (434 lines)
├── config.zsh               # User configuration (35 lines)
├── config.example.zsh       # Configuration template (4.6KB)
├── p10k.zsh                 # Powerlevel10k theme config
├── p10.zsh                  # Alternative P10k config
├── functions/
│   ├── README.md            # Function documentation
│   ├── aws.zsh              # AWS helper functions (3,085 lines)
│   ├── cursor.zsh           # Cursor IDE launcher (38 lines)
│   ├── test-rds-ssm.sh      # RDS-SSM test script
│   └── examples/
│       └── rds-ssm-config.example  # Configuration example
└── starship/
    ├── README.md            # Starship theme docs
    └── starship.toml        # Starship configuration
```

---

## ⚙️ Configuration Files

### `zshrc` - Main Configuration

**Purpose:** Primary zsh configuration loaded on shell start

**Key Sections:**
- **Environment Setup**: Locale, input method, telemetry opt-out
- **History Configuration**: 1M saved commands with smart deduplication
- **IDE Detection**: Automatic history isolation for Cursor/VSCode
- **Plugin Loading**: Zinit with syntax highlighting and auto-suggestions
- **Function Loading**: Dynamic loading from `functions/` directory
- **Editor Settings**: Neovim as default editor
- **Development Tools**: Go, Node.js, Python path configuration

**Performance:**
- Instant prompt via Powerlevel10k
- Optimized function loading (~60-70ms)
- Lazy plugin loading where possible

### `config.zsh` - User Configuration

**Purpose:** User-specific settings (not tracked in git)

**Settings:**
- `CUSTOM_DOTS_ROOT`: Override dotfiles location
- `FUNCTIONS_DEBUG`: Enable debug output
- `FUNCTIONS_SKIP_PATTERNS`: Files to ignore

**Usage:**
```bash
cp config.example.zsh config.zsh
vim config.zsh  # Customize
```

### `p10k.zsh` - Powerlevel10k Theme

**Purpose:** Configure prompt appearance and behavior

**Features:**
- Git status integration
- Command execution time
- Exit code display
- Context (user@host) when needed
- Language version displays
- Cloud context (AWS, GCP, Azure)

**Customization:**
```bash
p10k configure  # Interactive configuration wizard
```

---

## 🔧 AWS Functions

### Overview

Comprehensive AWS helper functions with interactive selection using fzf.

**Full Documentation:** See [QUICKSTART.md](QUICKSTART.md)

### Available Functions

#### `aws-help`
Display comprehensive help for all AWS functions.

```bash
aws-help
```

#### `ec2-list`
List all EC2 instances with details.

```bash
ec2-list
# Displays: InstanceID | State | Type | Name | IPs
```

#### `ec2-ssm`
Connect to EC2 instance via SSM (no SSH key needed).

```bash
ec2-ssm
# Interactive selection:
# 1. AWS Profile → 2. EC2 Instance → 3. Auto-connect
```

**Requirements:**
- SSM Agent on EC2
- Session Manager Plugin
- IAM permissions: `ssm:StartSession`

#### `rds-ssm`
Connect to RDS via EC2 bastion using SSM port forwarding.

```bash
# Basic usage (connectable instances only)
rds-ssm

# Show all instances
rds-ssm --show-all

# Search all regions
rds-ssm --all-regions

# Help
rds-ssm --help
```

**Features:**
- ✅ Security group connectivity validation
- ✅ AWS Secrets Manager integration
- ✅ Automatic port forwarding
- ✅ PostgreSQL and MySQL support
- ✅ Smart secret detection

**Workflow:**
1. Select AWS profile
2. Select EC2 bastion
3. Select RDS instance (with connectivity check)
4. Auto-detect credentials from Secrets Manager
5. Start SSM port forwarding
6. Launch database client

#### `awslogs`
Stream CloudWatch Logs in real-time.

```bash
# Simple view (timestamp + message)
awslogs

# Verbose view (full details)
awslogs -v
awslogs --verbose
```

**Features:**
- Interactive log group selection
- Real-time streaming
- Customizable output format

#### `ecs-list`
List all ECS clusters.

```bash
ecs-list
```

### Common Workflows

**Connect to Production Database:**
```bash
# 1. Set production profile
export AWS_PROFILE=production

# 2. Connect to RDS
rds-ssm
# Select bastion → Select RDS → Auto-connect
```

**View Application Logs:**
```bash
# 1. Set profile
export AWS_PROFILE=dev

# 2. Stream logs
awslogs
# Select log group → Stream in real-time
```

**SSH to EC2:**
```bash
ec2-ssm
# Select instance → Auto-connect via SSM
```

---

## ⚡ Performance

### Startup Performance

**Measured with:** `time zsh -i -c exit`

| Component | Time | Notes |
|-----------|------|-------|
| **Total Startup** | 60-70ms | With instant prompt |
| **Without Instant Prompt** | 800ms | Full initialization |
| **Function Loading** | 50-100ms | 2-3 function files |
| **Plugin Loading** | 200-300ms | Zinit with turbo mode |

### Optimization Techniques

1. **Instant Prompt** (Powerlevel10k)
   - Prompt renders immediately
   - Plugins load asynchronously

2. **Optimized Function Loading**
   - Array-based glob processing
   - Parameter expansion instead of subprocesses
   - Skip disabled files early

3. **Zinit Turbo Mode**
   - Deferred plugin loading
   - Load on first command

4. **Smart Caching**
   - Completion cache
   - History caching

### Performance Monitoring

```bash
# Measure startup time
time zsh -i -c exit

# Enable debug output
export ZSH_FUNCTIONS_DEBUG=true
source ~/.zshrc
# Shows: file count, loading time per file

# Profile with zprof
zmodload zsh/zprof
source ~/.zshrc
zprof
```

---

## 🎨 Customization

### Adding Custom Functions

```bash
# 1. Create function file
cat > ~/dots/zsh/functions/my-function.zsh << 'EOF'
#!/usr/bin/env zsh

my-custom-function() {
    echo "Hello from custom function"
}
EOF

# 2. Reload shell
exec zsh

# 3. Test
my-custom-function
```

### Custom Aliases

Add to `config.zsh`:
```bash
alias proj="cd ~/projects && ls"
alias gs="git status"
alias gp="git pull"
```

### Environment Variables

Add to `config.zsh`:
```bash
export AWS_PROFILE=production
export AWS_DEFAULT_REGION=ap-northeast-1
export EDITOR=vim
```

### Disabling Functions

```bash
# Rename to .disabled
mv functions/aws.zsh functions/aws.zsh.disabled

# Or add to FUNCTIONS_SKIP_PATTERNS in config.zsh
FUNCTIONS_SKIP_PATTERNS+=(
    "aws.zsh"
)
```

---

## 🔍 Troubleshooting

### Shell Startup Issues

**Problem:** Functions not loading
```bash
# Solution 1: Check DOTS_ROOT
export ZSH_FUNCTIONS_DEBUG=true
source ~/.zshrc
# Shows detection path

# Solution 2: Manual override
export CUSTOM_DOTS_ROOT=/path/to/dots
source ~/.zshrc
```

**Problem:** Slow startup
```bash
# Measure components
time zsh -i -c exit

# Disable instant prompt temporarily
# Comment in ~/.zshrc:
# if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
#   source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
# fi
```

### AWS Function Issues

**Problem:** `command not found: ec2-ssm`
```bash
# Check function loading
type ec2-ssm

# Check DOTS_ROOT
echo $DOTS_ROOT

# Enable debug
export ZSH_FUNCTIONS_DEBUG=true
source ~/.zshrc
```

**Problem:** AWS CLI errors
```bash
# Verify AWS CLI
aws --version  # Should be v2.x

# Check credentials
aws sts get-caller-identity

# Verify profile
aws configure list --profile myprofile
```

**Problem:** SSM connection fails
```bash
# Check plugin
session-manager-plugin

# If not found, install:
# https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html

# Check IAM permissions
aws iam get-user
```

### Common Fixes

**Reset Zinit:**
```bash
rm -rf ~/.local/share/zinit
source ~/.zshrc  # Will reinstall
```

**Clear Completion Cache:**
```bash
rm -f ~/.zcompdump*
compinit
```

**Reset Powerlevel10k:**
```bash
rm ~/.p10k.zsh
p10k configure
```

---

## 📚 Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Quick start guide (6.9KB)
- **[config.example.zsh](config.example.zsh)** - Configuration template (4.6KB)
- **[functions/README.md](functions/README.md)** - Function documentation
- **Inline Comments** - Extensive comments in all files

---

## 🛡️ Security Features

### Privacy Protection

1. **IDE History Isolation**
   - Detects Cursor/VSCode/Claude Code
   - Disables history in IDE terminals
   - Prevents command leakage

2. **Telemetry Opt-out**
   - Claude Code telemetry disabled
   - Bug reporting disabled
   - No non-essential network traffic

### Secure Practices

1. **No Hardcoded Credentials**
   - Uses AWS profiles
   - Supports MFA
   - Credential rotation friendly

2. **SSM Over SSH**
   - No SSH key management
   - No open ports
   - Full CloudTrail audit

3. **Secure Temp Files**
   - Automatic cleanup with traps
   - No file leaks on error
   - Proper permissions

---

## 🔄 Updates

### Updating Plugins

```bash
# Update all Zinit plugins
zinit update

# Update specific plugin
zinit update romkatv/powerlevel10k
```

### Updating Configuration

```bash
# Pull latest changes
cd ~/dots
git pull

# Reload
exec zsh
```

### Updating AWS CLI

```bash
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
```

---

## 🤝 Contributing

### Adding New Functions

1. Create function file in `functions/`
2. Add comprehensive header documentation
3. Include usage examples
4. Test thoroughly
5. Update this README

### Documentation Standards

- Use emoji for visual organization (sparingly)
- Include code examples
- Provide troubleshooting tips
- Link to official documentation

---

## 📊 Statistics

- **Total Lines**: ~6,500 lines
- **Functions**: 15+ AWS helper functions
- **Documentation**: 11.5KB guides
- **Startup Time**: 60-70ms
- **Supported OS**: Linux, macOS
- **Zsh Version**: 5.8+

---

## 📖 Related Documentation

### External Resources
- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Zinit](https://github.com/zdharma-continuum/zinit)
- [AWS CLI](https://docs.aws.amazon.com/cli/)
- [fzf](https://github.com/junegunn/fzf)

### Internal Documentation
- [functions/README.md](functions/README.md) - Function reference
- [QUICKSTART.md](QUICKSTART.md) - Quick start guide
- [config.example.zsh](config.example.zsh) - Configuration template

---

## ⚖️ License

Part of the `dots` repository. See main repository for license information.

---

## 🆘 Support

For issues or questions:
1. Check [QUICKSTART.md](QUICKSTART.md) troubleshooting section
2. Enable debug mode: `export ZSH_FUNCTIONS_DEBUG=true`
3. Review inline documentation
4. Check function-specific help: `aws-help`, `rds-ssm --help`

---

**Version:** 2.0.0
**Last Updated:** 2025-01-03
**Compatibility:** Zsh 5.8+, Linux/macOS
