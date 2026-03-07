# Diff Summary Tool

Compare two git refs (branches, commit SHAs, or tags) and generate a markdown summary of all differences. Uses Beyond Compare 5 for folder comparison with rules-based analysis that ignores insignificant differences (whitespace, blank lines, line endings).

## Prerequisites

- **git** — must be available on `PATH`
- **PowerShell Core** (pwsh 7+)
- **Beyond Compare 5** — installed at `C:\Program Files\Beyond Compare 5`

## Usage

```powershell
# Compare two branches
./tools/diff-summary/Compare-Changes.ps1 -Ref1 main -Ref2 feature/agent-test

# Compare two commit SHAs
./tools/diff-summary/Compare-Changes.ps1 -Ref1 abc1234 -Ref2 def5678

# Custom output file
./tools/diff-summary/Compare-Changes.ps1 -Ref1 main -Ref2 feature/no-agent -OutputFile results/my-comparison.md
```

## Parameters

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-Ref1` | Yes | — | First git ref to compare — branch name, commit SHA, or tag (base) |
| `-Ref2` | Yes | — | Second git ref to compare — branch name, commit SHA, or tag (compare) |
| `-OutputFile` | No | `diff-summary.md` | Path to the output markdown file |

## How It Works

1. Creates temporary git worktrees for both refs
2. Runs Beyond Compare 5 in silent mode to identify files with significant differences (ignoring whitespace, blank lines, line endings)
3. Uses `git diff --no-index` to generate unified diffs for each changed file
4. Assembles a markdown report with a summary table and per-file inline diffs
5. Cleans up temporary worktrees

## Output Format

The generated markdown file contains:

1. **Header** — ref names, resolved SHAs, repository name, and timestamp
2. **Summary table** — every changed file listed with status (Added/Modified/Deleted) and line counts
3. **File changes** — per-file sections with inline diffs in fenced `diff` code blocks for syntax highlighting
