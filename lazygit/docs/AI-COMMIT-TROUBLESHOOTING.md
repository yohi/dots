# Lazygit AI Commit Feature Troubleshooting

## Current Status
The AI Commit feature (Ctrl+A) in Lazygit is functional with the `gemini` CLI, but encounters a timeout when processing actual git diff content.

## Identified Problem
When `gemini` CLI receives git diff data (even after being limited to 6000 characters), it consistently times out after 60 seconds. However, when no diff data is provided (sending only the prompt), it successfully generates commit messages. This indicates the issue is related to the processing of diff content by the AI model.

## Next Steps / TODOs

### Immediate
1.  **Re-evaluate Diff Size Limit**: Experiment with even smaller diff limits (e.g., `head -c 3000`, `head -c 1000`) in `lazygit/scripts/lazygit-ai-commit/generate-menu-items.sh`.
2.  **Increase Timeout**: Temporarily increase `TIMEOUT_SECONDS` further (e.g., 90s, 120s) to see if a response is eventually returned, providing insight into the processing time.
3.  **Check Diff Content for Anomalies**: Inspect the content of the git diff being sent. Look for very long lines, binary data, or unusual characters that might confuse the AI model or the CLI parser.
    *   `git diff --cached | head -c 6000 | cat -v` to visualize non-printable characters.

### Long-term / Alternative Solutions
1.  **Explore other Gemini Models**: Investigate if `gemini-pro` or other available models perform better with large diffs or have different rate limits/processing speeds.
2.  **Implement Server-Side Processing**: For very large diffs, a local or remote server could pre-process the diff (e.g., summarize it) before sending to the AI.
3.  **Use AI API directly (with API Key)**: If `gemini` CLI continues to be problematic, revert to using a direct API call via Python/Curl, requiring the user to set `GEMINI_API_KEY`. This provides more control over the request format and error handling.
4.  **CLI Version Check**: Ensure the installed `gemini` CLI is up-to-date. `gemini --version`.
