# Diff Summary Tool

Compare two git refs (branches, commit SHAs, or tags) and generate a markdown summary of all differences. Uses `git diff` with built-in whitespace-ignore flags to skip insignificant differences (whitespace, blank lines, line endings). Works on Windows and Linux — no additional tools required.

## Prerequisites

- **git** — must be available on `PATH`
- **PowerShell Core** (pwsh 7+)

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

1. Resolves both refs (with automatic `origin/<ref>` fallback for remote branches in CI)
2. Uses `git diff --name-status -w` to identify changed files and their status (Added/Modified/Deleted/Renamed)
3. Uses `git diff -w --unified=3` per file to generate unified diffs with whitespace changes suppressed
4. Assembles a markdown report with a summary table and per-file inline diffs

## Output Format

The generated markdown file contains:

1. **Header** — ref names, resolved SHAs, repository name, and timestamp
2. **Summary table** — every changed file listed with status (Added/Modified/Deleted/Renamed) and line counts
3. **File changes** — per-file sections with inline diffs in fenced `diff` code blocks for syntax highlighting
