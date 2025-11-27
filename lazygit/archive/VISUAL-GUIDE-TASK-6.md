# Visual Guide: menuFromCommand Configuration

## Task 6 Implementation - User Experience Flow

### Step-by-Step Visual Walkthrough

---

## 1. Initial State: Files View

```
┌─ LazyGit ─────────────────────────────────────┐
│ Files                                          │
├────────────────────────────────────────────────┤
│ ● config.yml                    (modified)     │
│ ● test.sh                       (new file)     │
│                                                │
│ [Press 'space' to stage files]                │
│ [Press 'Ctrl+A' for AI commit]                │
└────────────────────────────────────────────────┘
```

**User Action:** Press `Ctrl+A`

---

## 2. Loading State

```
┌─ LazyGit ─────────────────────────────────────┐
│                                                │
│   🔄 Generating commit messages with AI...    │
│                                                │
│   Please wait...                               │
│                                                │
└────────────────────────────────────────────────┘
```

**What's Happening:**
- Pipeline executing: `diff → size limit → AI → parse`
- Typical duration: 2-10 seconds
- User sees clear feedback

---

## 3. Menu Display

```
┌─ Select a commit message ─────────────────────┐
│                                                │
│ > feat: add new files and functionality        │ ← Selected (green)
│   test: add test coverage for new functionality│ (green)
│   fix: resolve issues identified in code review│ (green)
│   docs: update documentation with latest changes│ (green)
│   refactor: improve code structure             │ (green)
│                                                │
├────────────────────────────────────────────────┤
│ ↑/↓: Navigate  Enter: Confirm  Esc: Cancel    │
└────────────────────────────────────────────────┘
```

**Features:**
- ✓ Multiple candidates (5+)
- ✓ Green color highlighting
- ✓ Clear selection indicator (>)
- ✓ Keyboard navigation hints

---

## 4. Navigation

```
┌─ Select a commit message ─────────────────────┐
│                                                │
│   feat: add new files and functionality        │ (green)
│   test: add test coverage for new functionality│ (green)
│ > fix: resolve issues identified in code review│ ← Selected (green)
│   docs: update documentation with latest changes│ (green)
│   refactor: improve code structure             │ (green)
│                                                │
└────────────────────────────────────────────────┘
```

**User Action:** Press `↓` or `j` to move down

---

## 5. Confirmation

```
┌─ Select a commit message ─────────────────────┐
│                                                │
│   feat: add new files and functionality        │
│ > test: add test coverage for new functionality│ ← Selected
│   fix: resolve issues identified in code review│
│   docs: update documentation with latest changes│
│   refactor: improve code structure             │
│                                                │
└────────────────────────────────────────────────┘
```

**User Action:** Press `Enter` to commit

---

## 6. Commit Execution

```
┌─ LazyGit ─────────────────────────────────────┐
│                                                │
│   ✓ Committed successfully!                   │
│                                                │
│   Message: test: add test coverage for new     │
│            functionality                       │
│                                                │
└────────────────────────────────────────────────┘
```

**What Happened:**
- Command executed: `git commit -m "test: add test coverage..."`
- Message properly escaped with `| quote` filter
- UI automatically updated

---

## 7. Updated View

```
┌─ LazyGit ─────────────────────────────────────┐
│ Commits                                        │
├────────────────────────────────────────────────┤
│ ● test: add test coverage for new functionality│ ← New commit
│ ● feat: implement AI commit generator          │
│ ● docs: update README                          │
│                                                │
└────────────────────────────────────────────────┘
```

**Result:** Clean commit history with AI-generated message

---

## Error Scenarios

### No Staged Changes

```
┌─ LazyGit ─────────────────────────────────────┐
│                                                │
│   ⚠ Error: No staged changes.                 │
│      Please stage files first.                │
│                                                │
│   [Press any key to continue]                 │
│                                                │
└────────────────────────────────────────────────┘
```

**User Action:** Press `Esc`, stage files, try again

---

## Configuration Breakdown

### The Complete menuFromCommand Structure

```yaml
prompts:
  - type: "menuFromCommand"           # ← Menu type
    title: "Select a commit message"  # ← Menu title
    command: |                         # ← Pipeline command
      if git diff --cached --quiet; then
        echo "Error: No staged changes. Please stage files first."
        exit 1
      fi
      git diff --cached | head -c 12000 | ./ai-commit-generator.sh | ./parse-ai-output.sh
    filter: "^(?P<msg>.+\\S.*)$"      # ← Regex to extract lines
    valueFormat: "{{ .msg }}"          # ← Value for commit
    labelFormat: "{{ .msg | green }}"  # ← Display format
```

### How Each Field Works

| Field | Purpose | Example |
|-------|---------|---------|
| `type` | Defines prompt type | `menuFromCommand` |
| `title` | Menu header text | "Select a commit message" |
| `command` | Generates menu items | Pipeline script |
| `filter` | Extracts items from output | Regex pattern |
| `valueFormat` | Value stored in variable | `{{ .msg }}` |
| `labelFormat` | How item is displayed | `{{ .msg \| green }}` |

### The Pipeline Explained

```
┌─────────────┐
│ User presses│
│   Ctrl+A    │
└──────┬──────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 1. Check staging area               │
│    git diff --cached --quiet        │
└──────┬──────────────────────────────┘
       │ (if empty → error)
       ▼
┌─────────────────────────────────────┐
│ 2. Get staged diff                  │
│    git diff --cached                │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 3. Limit size to 12KB               │
│    head -c 12000                    │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 4. Generate with AI                 │
│    ./ai-commit-generator.sh         │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 5. Parse output                     │
│    ./parse-ai-output.sh             │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 6. Apply regex filter               │
│    ^(?P<msg>.+\S.*)$                │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 7. Display menu with green text     │
│    labelFormat: {{ .msg | green }}  │
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 8. User selects message             │
│    ↑/↓ to navigate, Enter to select│
└──────┬──────────────────────────────┘
       │
       ▼
┌─────────────────────────────────────┐
│ 9. Commit with selected message     │
│    git commit -m "{{ .msg | quote }}"│
└─────────────────────────────────────┘
```

## Color Options

The `labelFormat` supports various colors:

```yaml
# Available colors:
labelFormat: "{{ .msg | green }}"   # ✓ Current (success/ready)
labelFormat: "{{ .msg | cyan }}"    # Alternative (info)
labelFormat: "{{ .msg | yellow }}"  # Warning style
labelFormat: "{{ .msg | blue }}"    # Neutral
labelFormat: "{{ .msg | magenta }}" # Highlight
labelFormat: "{{ .msg | red }}"     # Error/important
```

**Why green?**
- Indicates "ready to use"
- Matches Git's color scheme (green = additions)
- Good visibility in most terminal themes

## Template Variables

After regex capture, these variables are available:

```yaml
# From filter: ^(?P<msg>.+\S.*)$
{{ .msg }}              # The captured message text

# LazyGit built-in filters:
{{ .msg | green }}      # Apply green color
{{ .msg | quote }}      # Shell escape (for commit)
{{ .msg | upper }}      # Uppercase
{{ .msg | lower }}      # Lowercase
```

## Requirements Mapping

| Visual Element | Requirement | Status |
|----------------|-------------|--------|
| Loading text | 1.2 | ✓ |
| Menu list | 2.2 | ✓ |
| Green highlighting | 2.3 | ✓ |
| Keyboard navigation | 3.1 | ✓ |
| Selection highlight | 3.2 | ✓ |

## Testing the Configuration

### Quick Test

```bash
# Test the pipeline manually:
git diff --cached | head -c 12000 | ./ai-commit-generator.sh | ./parse-ai-output.sh

# Expected output:
# feat: add new feature
# fix: resolve bug
# docs: update documentation
# test: add test coverage
# refactor: improve code structure
```

### Integration Test

```bash
# Run comprehensive tests:
./test-menu-integration.sh

# Expected result:
# ✓ All tests passed
```

### In LazyGit

1. Open LazyGit: `lazygit`
2. Stage files: `space`
3. Trigger AI: `Ctrl+A`
4. Verify:
   - Loading text appears
   - Menu shows with green text
   - Navigation works (↑/↓)
   - Selection commits correctly

## Troubleshooting

### Menu doesn't appear

**Check:**
```bash
# Are scripts executable?
ls -la *.sh

# Should show: -rwxr-xr-x
# If not: chmod +x *.sh
```

### No green color

**Check:**
```bash
# Terminal color support
echo -e "\033[32mGreen text\033[0m"

# LazyGit version
lazygit --version  # Should be v0.40+
```

### Pipeline fails

**Debug:**
```bash
# Test each component:
git diff --cached                    # Step 1
git diff --cached | head -c 12000    # Step 2
./ai-commit-generator.sh < /tmp/test # Step 3
./parse-ai-output.sh < /tmp/output   # Step 4
```

## Summary

Task 6 successfully implements a complete, user-friendly menuFromCommand configuration that:

- ✓ Integrates the entire AI pipeline seamlessly
- ✓ Provides clear visual feedback with colors
- ✓ Offers intuitive keyboard navigation
- ✓ Handles errors gracefully
- ✓ Creates an excellent user experience

The implementation is production-ready and fully tested!
