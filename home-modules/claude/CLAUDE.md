# Writing style (Plans, Commits, Etc)
- Reading takes time. Communicate in as few words as possible.
- Write for experts.

# Code Comments
- Prefer to comment less rather than more.
- Documentation comments should NOT contain implementation details or trade offs unless it's directly relevant to the caller.
- If implementation details require explanation, leave the comment in the function body as close to the relevant code as reasonable. Prefix such comments with `NB: `.

# Commits
- Prefix summaries with the affected package or area of the code base. e.g. `operator:`, `charts/redpanda:`
- Write bodies for experts of the codebase. Be terse and concise rather than over explanatory.
- Don't duplicate context that's explained by content in the commit itself.
- Wrap code references in `backticks`.

# Git Workflows
- NEVER run `git push` unless explicitly asked to.
- NEVER create a new branch or tag unless explicitly asked to.
- Prefer to fixup commits during iteration over immediate rebasing.
