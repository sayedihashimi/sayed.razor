# Create Branch Diff Summary Tool

Create a PowerShell Core script that compares two git refs (branches, commit SHAs, or tags) and generates a markdown summary of all differences. The tool lives in `./tools/diff-summary/` and is completely independent from the rest of this repository.

## Files to Create

1. `./tools/diff-summary/Compare-Branches.ps1` — Main script
2. `./tools/diff-summary/README.md` — Usage documentation

---

## 1. `Compare-Branches.ps1`

### Parameters

```powershell
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Ref1,

    [Parameter(Mandatory)]
    [string]$Ref2,

    [Parameter()]
    [string]$OutputFile = "diff-summary.md"
)
```

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `-Ref1` | Yes | — | First git ref to compare (branch name, commit SHA, or tag) |
| `-Ref2` | Yes | — | Second git ref to compare (branch name, commit SHA, or tag) |
| `-OutputFile` | No | `diff-summary.md` | Path to the output markdown file |

### Behavior

#### Step 1: Validate Environment

- Confirm `git` is available on `PATH`.
- Confirm the current directory is inside a git repository (run `git rev-parse --is-inside-work-tree`).
- Confirm both `Ref1` and `Ref2` are valid git refs. Use `git rev-parse --verify <ref>` for each. If a ref doesn't resolve, write a clear error and exit with code 1. This works for branch names, commit SHAs (full or abbreviated), and tags.

#### Step 2: Gather Diff Data

Run these git commands to collect the raw data. All diffs are `Ref1...Ref2` (changes in Ref2 relative to Ref1):

1. **File status list** — `git diff --name-status <Ref1>...<Ref2>`
   Produces lines like `M\tsrc/file.cs`, `A\tnew-file.txt`, `D\tremoved.cs`.
   Parse each line into a status (`Added`, `Modified`, `Deleted`, `Renamed`) and file path.

2. **Stat summary** — `git diff --stat <Ref1>...<Ref2>`
   Captures the summary line at the bottom (e.g., `5 files changed, 120 insertions(+), 30 deletions(-)`).

3. **Per-file diffs** — For each changed file, get the diff content:
   `git diff <Ref1>...<Ref2> -- <filepath>`
   This provides the unified diff for each file individually.

#### Step 3: Generate Markdown

Assemble the markdown file with the structure below. Use UTF-8 encoding without BOM.

````markdown
# Diff Summary: `<Ref1>` vs `<Ref2>`

**Repository:** <repo name from `git remote get-url origin` or folder name if no remote>
**Date:** <current date/time in yyyy-MM-dd HH:mm format>
**Base ref:** `<Ref1>` (`<resolved full SHA>`)
**Compare ref:** `<Ref2>` (`<resolved full SHA>`)

---

## Summary

<stat summary line from git diff --stat, e.g. "5 files changed, 120 insertions(+), 30 deletions(-)">

| Status | File | Lines Added | Lines Removed |
|--------|------|-------------|---------------|
| Modified | `src/Pages/Index.cshtml` | +15 | -3 |
| Added | `src/Models/Product.cs` | +42 | -0 |
| Deleted | `src/old-file.cs` | +0 | -18 |

---

## File Changes

### `src/Pages/Index.cshtml`

**Status:** Modified | **+15** | **-3**

```diff
<full unified diff output for this file>
```

---

### `src/Models/Product.cs`

**Status:** Added | **+42** | **-0**

```diff
<full unified diff output for this file>
```

---

(repeat for each changed file)
````

**Rules for the markdown:**

- The summary table must list every changed file, sorted alphabetically by file path.
- Per-file diffs use fenced code blocks with the `diff` language identifier for syntax highlighting.
- Compute per-file lines added/removed by counting lines starting with `+` (excluding `+++`) and `-` (excluding `---`) in each file's diff output.
- If a file is binary (git reports `Binary files ... differ`), show "Binary file" in the diff section instead of diff content.
- Use `---` horizontal rules between file change sections for readability.

#### Step 4: Output

- Write the markdown content to the path specified by `-OutputFile`.
- If the file already exists, overwrite it.
- Print a confirmation message to the console: `Diff summary written to: <absolute path to OutputFile>`
- Print the summary stats line to the console as well.

### Error Handling

- Use `$ErrorActionPreference = 'Stop'` at the top of the script.
- Wrap the main logic in a `try/catch` block.
- On any git command failure, write the error to `Write-Error` and exit with code 1.
- Validate parameters early (before doing any work).

### Script Style

- Use PowerShell Core idiomatic style (no aliases in the script, use full cmdlet names).
- Add a comment-based help block (`<# .SYNOPSIS ... #>`) at the top with usage examples.
- Use `Write-Host` for progress/status messages and `Write-Error` for errors.
- Do **not** depend on any external modules — only git and built-in PowerShell cmdlets.

---

## 2. `README.md`

Create a README at `./tools/diff-summary/README.md` with:

- **Title and one-line description** of what the tool does.
- **Prerequisites**: git, PowerShell Core (pwsh 7+).
- **Usage examples**:
  ```powershell
  # Compare two branches
  ./tools/diff-summary/Compare-Branches.ps1 -Ref1 main -Ref2 feature/agent-test

  # Compare two commit SHAs
  ./tools/diff-summary/Compare-Branches.ps1 -Ref1 abc1234 -Ref2 def5678

  # Custom output file
  ./tools/diff-summary/Compare-Branches.ps1 -Ref1 main -Ref2 feature/no-agent -OutputFile results/my-comparison.md
  ```
- **Parameter reference** table (same as above).
- **Output format** — brief description of the generated markdown structure.
