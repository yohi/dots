# Implementation Plan

- [x] 1. Create LazyGit configuration file and implement basic AI integration structure
  - Create customCommands section in config.yml
  - Configure key binding (`<c-a>`) and context (`files`)
  - Define basic menuFromCommand prompt structure
  - _Requirements: 1.1, 9.1, 9.2, 9.3_

- [x] 2. Implement diff retrieval and error handling
  - Create script to retrieve staging diff with `git diff --cached`
  - Implement check to detect empty staging area
  - Implement error message display
  - _Requirements: 5.1, 2.4_

- [ ]* 2.1 Create unit tests for diff retrieval
  - Test that returns error for empty staging area
  - Test that outputs diff when valid changes exist
  - _Requirements: 5.1, 2.4_

- [x] 3. Implement size limiting
  - Implement processing to limit diff output to 12KB
  - Add truncation using `head -c 12000`
  - _Requirements: 8.1_

- [ ]* 3.1 Create unit tests for size limiting
  - Test that input under 12KB passes through unchanged
  - Test that input over 12KB is correctly truncated
  - _Requirements: 8.1_

- [x] 4. Implement AI CLI interface
  - Create mock AI tool script (for testing)
  - Define prompt structure (Conventional Commits format, Markdown removal instructions)
  - Implement stdin/stdout pipeline processing
  - _Requirements: 5.2, 5.3, 6.1, 6.3_

- [ ]* 4.1 Property test: Multiple candidate generation
  - **Property 1: Multiple candidate generation**
  - **Validates: Requirements 2.1**
  - Verify that 2 or more candidates are generated for any valid diff input
  - _Requirements: 2.1_

- [ ]* 4.2 Property test: Conventional Commits format compliance
  - **Property 4: Conventional Commits format compliance**
  - **Validates: Requirements 6.1**
  - Verify that generated messages follow format for any diff input
  - _Requirements: 6.1_

- [ ]* 4.3 Property test: Markdown removal
  - **Property 5: Markdown removal**
  - **Validates: Requirements 6.3**
  - Verify that generated messages contain no Markdown symbols for any diff input
  - _Requirements: 6.3_

- [x] 5. Implement regex parser
  - Implement regex to parse AI output (`^(?P<msg>.+)$`)
  - Add processing to skip empty lines
  - Implement regex for numbered list support
  - _Requirements: 5.4_

- [ ]* 5.1 Property test: Regex parsing completeness
  - **Property 2: Regex parsing completeness**
  - **Validates: Requirements 5.4**
  - Verify that all newline-delimited text is extracted
  - _Requirements: 5.4_

- [ ]* 5.2 Create unit tests for regex parsing
  - Test splitting standard newline-delimited input
  - Test processing numbered lists
  - Test skipping empty lines
  - _Requirements: 5.4_

- [x] 6. Complete menuFromCommand configuration
  - Integrate entire pipeline in command field
  - Set regex in filter field
  - Configure valueFormat and labelFormat (colored display)
  - Add loadingText for user feedback
  - _Requirements: 2.2, 2.3, 3.1, 3.2, 1.2_

- [x] 7. Implement commit execution and escape processing
  - Implement `git commit -m {{.Form.SelectedMsg | quote}}` command
  - Apply shell escaping with `| quote` filter
  - Verify UI update after commit
  - _Requirements: 4.1, 4.2, 4.3_

- [ ]* 7.1 Property test: Shell injection prevention
  - **Property 3: Shell injection prevention**
  - **Validates: Requirements 4.2, 8.3**
  - Verify that messages with any special characters are safely escaped
  - _Requirements: 4.2, 8.3_

- [ ]* 7.2 Create unit tests for escape processing
  - Test messages with single quotes
  - Test messages with double quotes
  - Test messages with backticks
  - Test messages with semicolons
  - _Requirements: 4.2, 8.3_

- [x] 8. Enhance error handling
  - Implement AI execution error handling (`set -o pipefail`)
  - Implement timeout processing (`timeout 30s`)
  - Implement error messages for malformed output
  - _Requirements: 8.2, 8.4_

- [x] 9. Integrate with actual AI CLI tools
  - Select one of Gemini CLI, Claude CLI, or Ollama
  - Document installation instructions for selected AI tool
  - Adjust prompt for actual AI tool
  - Add configuration to manage API keys via environment variables
  - _Requirements: 7.1, 7.2, 7.3_

- [x] 10. Integration testing and documentation
  - Verify complete workflow in test Git repository
  - Document usage and troubleshooting in README.md
  - Document configuration examples (multiple AI backends)
  - _Requirements: 3.3, 3.4_

- [x] 11. Checkpoint - Verify all tests pass
  - Confirm all tests pass
  - Check with user if there are any questions
