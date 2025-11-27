# Requirements Document

## Introduction

This specification defines the requirements for integrating AI-based commit message generation into LazyGit (a terminal UI tool for Git). The goal is to enable developers to adopt high-quality commit messages from staged changes through visual confirmation only, without manual editing. This reduces cognitive load during commits, promotes Atomic Commits, and improves overall commit quality.

## Glossary

- **LazyGit**: A terminal-based user interface (TUI) tool for operating Git commands
- **Custom Commands**: LazyGit's extension feature that allows user-defined commands and key bindings via config.yml
- **menuFromCommand**: A LazyGit prompt type that dynamically parses shell command output to generate menu items
- **Staging Area**: The Git area that temporarily holds changes to be included in the next commit
- **Diff**: Difference information showing file changes
- **AI CLI Tool**: Command-line interface for AI language models (e.g., gemini-cli, sgpt, ollama)
- **Conventional Commits**: A standardized commit message format (e.g., feat:, fix:, docs:)
- **Context**: In LazyGit, a concept representing specific screens or operational states (e.g., files, branches, commits)

## Requirements

### Requirement 1

**User Story:** As a developer, I want to generate commit messages with AI from staged changes without leaving LazyGit, so that I can maintain workflow context and reduce cognitive load.

#### Acceptance Criteria

1. WHEN the developer triggers the AI commit command from the files context THEN the LazyGit system SHALL execute the command without switching to external applications
2. WHEN the AI commit command is executed THEN the LazyGit system SHALL remain in the foreground and display loading feedback to the user
3. WHEN the command completes THEN the LazyGit system SHALL display results within the LazyGit terminal interface

### Requirement 2

**User Story:** As a developer, I want to see multiple AI-generated commit message candidates, so that I can select the one most appropriate for my changes.

#### Acceptance Criteria

1. WHEN the AI processes staged changes THEN the LazyGit system SHALL generate multiple commit message candidates
2. WHEN candidates are generated THEN the LazyGit system SHALL display them as a selectable menu list
3. WHEN displaying the menu THEN the LazyGit system SHALL present each candidate message in a readable format with visual highlighting
4. WHEN no staged changes exist THEN the LazyGit system SHALL display an error message and prevent AI execution

### Requirement 3

**User Story:** As a developer, I want to visually confirm AI-generated messages before committing, so that I can ensure accuracy without manual editing.

#### Acceptance Criteria

1. WHEN the menu is displayed THEN the LazyGit system SHALL allow navigation between candidates using keyboard controls
2. WHEN the user selects a candidate THEN the LazyGit system SHALL highlight the selected message for visual confirmation
3. WHEN the user confirms the selection THEN the LazyGit system SHALL execute the git commit command with the selected message
4. WHEN the user cancels the menu THEN the LazyGit system SHALL abort the commit operation and return to the previous state

### Requirement 4

**User Story:** As a developer, I want to use the selected commit message as-is, so that I can complete commits quickly without editing.

#### Acceptance Criteria

1. WHEN the user confirms message selection THEN the LazyGit system SHALL pass the message text directly to git commit without opening an editor
2. WHEN passing the message to git THEN the LazyGit system SHALL properly escape special characters to prevent shell injection
3. WHEN the commit completes THEN the LazyGit system SHALL update the interface to reflect the new commit

### Requirement 5

**User Story:** As a developer, I want the AI to analyze git diff output and generate contextually appropriate messages, so that commit messages accurately reflect the changes.

#### Acceptance Criteria

1. WHEN the AI command is executed THEN the LazyGit system SHALL retrieve staged changes using git diff --cached
2. WHEN the diff is retrieved THEN the LazyGit system SHALL pipe the diff content to the configured AI CLI tool via standard input
3. WHEN calling the AI tool THEN the LazyGit system SHALL include a prompt specifying output format requirements
4. WHEN the AI tool returns output THEN the LazyGit system SHALL parse the output using regular expressions to extract individual message candidates

### Requirement 6

**User Story:** As a developer, I want commit messages to follow Conventional Commits format, so that the repository maintains a consistent commit history.

#### Acceptance Criteria

1. WHEN generating messages THEN the AI tool SHALL produce messages following Conventional Commits format with type prefixes
2. WHEN formatting messages THEN the AI tool SHALL include appropriate scope information when relevant
3. WHEN outputting messages THEN the AI tool SHALL generate concise, descriptive text without Markdown formatting

### Requirement 7

**User Story:** As a developer, I want to configure which AI backend to use, so that I can choose based on speed, cost, and privacy requirements.

#### Acceptance Criteria

1. WHEN configuration is defined THEN the LazyGit system SHALL support specifying any AI CLI command in config.yml
2. WHEN the AI command is invoked THEN the LazyGit system SHALL execute the configured command with the diff as input
3. WHEN the AI backend is changed THEN the LazyGit system SHALL continue to function without code changes

### Requirement 8

**User Story:** As a developer, I want the system to handle edge cases properly, so that unexpected situations don't break my workflow.

#### Acceptance Criteria

1. WHEN diff output exceeds token limits THEN the LazyGit system SHALL truncate the input to an appropriate size before sending to the AI
2. WHEN the AI tool returns malformed output THEN the LazyGit system SHALL display an error message and allow the user to retry or cancel
3. WHEN generated messages contain special characters THEN the LazyGit system SHALL properly escape them to prevent command injection
4. WHEN the AI tool execution times out THEN the LazyGit system SHALL display a timeout message and return control to the user

### Requirement 9

**User Story:** As a developer, I want to trigger the AI commit feature with a keyboard shortcut, so that I can access it quickly during my workflow.

#### Acceptance Criteria

1. WHEN the custom command is configured THEN the LazyGit system SHALL bind the command to a user-specified key combination
2. WHEN the key combination is pressed in the files context THEN the LazyGit system SHALL execute the AI commit workflow
3. WHEN the key combination is pressed in other contexts THEN the LazyGit system SHALL ignore the command to prevent unintended execution
