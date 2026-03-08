<#
.SYNOPSIS
    Compares two git refs (branches, commit SHAs, or tags) and generates a markdown diff summary.

.DESCRIPTION
    This script uses git diff to compare two refs and produces a well-formatted markdown file
    containing a summary table of all changed files and per-file inline diffs with syntax
    highlighting. Insignificant whitespace and blank-line differences are suppressed using
    git diff's built-in ignore flags.

    Supports Windows and Linux. Only git (already required) is needed — no additional tools.

.PARAMETER Ref1
    First git ref to compare (branch name, commit SHA, or tag). This is the base ref.
    Remote branches (e.g. "origin/my-branch") are also accepted. If a bare branch name is
    given and no local branch exists, the script automatically tries "origin/<Ref1>".

.PARAMETER Ref2
    Second git ref to compare (branch name, commit SHA, or tag). This is the compare ref.
    Remote branches (e.g. "origin/my-branch") are also accepted. If a bare branch name is
    given and no local branch exists, the script automatically tries "origin/<Ref2>".

.PARAMETER OutputFile
    Path to the output markdown file. Defaults to "diff-summary.md".

.EXAMPLE
    ./Compare-Changes.ps1 -Ref1 main -Ref2 feature/agent-test

.EXAMPLE
    ./Compare-Changes.ps1 -Ref1 abc1234 -Ref2 def5678

.EXAMPLE
    ./Compare-Changes.ps1 -Ref1 main -Ref2 feature/no-agent -OutputFile results/my-comparison.md
#>

#Requires -Version 7

[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Ref1,

    [Parameter(Mandatory)]
    [string]$Ref2,

    [Parameter()]
    [string]$OutputFile = "diff-summary.md"
)

$ErrorActionPreference = 'Stop'

function Get-RepoName {
    try {
        $remoteUrl = git remote get-url origin 2>$null
        if ($remoteUrl) {
            $repoName = $remoteUrl -replace '\.git$', '' -replace '^.*[/:]', ''
            $orgOrUser = ($remoteUrl -replace '\.git$', '') -replace '^.*[/:]([^/]+)/[^/]+$', '$1'
            return "$orgOrUser/$repoName"
        }
    }
    catch { }
    return (Get-Item -Path (git rev-parse --show-toplevel)).Name
}

function Get-FileLineCounts {
    param([string]$DiffContent)
    $added = 0
    $removed = 0
    foreach ($line in ($DiffContent -split "`n")) {
        if ($line -match '^\+' -and $line -notmatch '^\+\+\+') { $added++ }
        elseif ($line -match '^-' -and $line -notmatch '^---') { $removed++ }
    }
    return @{ Added = $added; Removed = $removed }
}

try {
    # Step 1: Validate environment
    Write-Host "Validating environment..." -ForegroundColor Cyan

    $gitCmd = Get-Command git -ErrorAction SilentlyContinue
    if (-not $gitCmd) {
        Write-Error "git is not available on PATH. Please install git and try again."
        exit 1
    }

    $isGitRepo = git rev-parse --is-inside-work-tree 2>$null
    if ($isGitRepo -ne 'true') {
        Write-Error "Current directory is not inside a git repository."
        exit 1
    }

    # Resolve Ref1 — try bare name first, fall back to origin/<ref>
    $ref1Sha = git rev-parse --verify $Ref1 2>$null
    if ($LASTEXITCODE -ne 0) {
        $ref1Sha = git rev-parse --verify "origin/$Ref1" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $Ref1 = "origin/$Ref1"
        }
        else {
            Write-Error "Ref1 '$Ref1' is not a valid git ref (branch, commit SHA, or tag)."
            exit 1
        }
    }

    # Resolve Ref2 — try bare name first, fall back to origin/<ref>
    $ref2Sha = git rev-parse --verify $Ref2 2>$null
    if ($LASTEXITCODE -ne 0) {
        $ref2Sha = git rev-parse --verify "origin/$Ref2" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $Ref2 = "origin/$Ref2"
        }
        else {
            Write-Error "Ref2 '$Ref2' is not a valid git ref (branch, commit SHA, or tag)."
            exit 1
        }
    }

    Write-Host "  Ref1: $Ref1 ($ref1Sha)" -ForegroundColor Gray
    Write-Host "  Ref2: $Ref2 ($ref2Sha)" -ForegroundColor Gray

    # Step 2: Get list of changed files via git diff --name-status
    # -w ignores whitespace changes; --diff-filter limits to Added/Copied/Deleted/Modified/Renamed
    Write-Host "Identifying changed files..." -ForegroundColor Cyan

    $nameStatusLines = git diff --name-status -w --diff-filter=ACDMR "$Ref1" "$Ref2" 2>&1
    if ($LASTEXITCODE -ne 0) {
        Write-Error "git diff --name-status failed: $nameStatusLines"
        exit 1
    }

    if ($nameStatusLines -is [array]) { $nameStatusLines = $nameStatusLines -join "`n" }

    $fileChanges = @()
    foreach ($line in ($nameStatusLines -split "`n")) {
        $line = $line.Trim()
        if ([string]::IsNullOrWhiteSpace($line)) { continue }

        # Format: <status><TAB><path>  or  R<score><TAB><old-path><TAB><new-path>
        $parts = $line -split "`t"
        $statusCode = $parts[0].Trim()

        $filePath = $null
        $status = $null

        if ($statusCode -match '^R') {
            # Renamed: R<score><TAB><old-path><TAB><new-path>
            if ($parts.Count -ge 3) {
                $filePath = $parts[2].Trim()
            }
            else {
                $filePath = $parts[1].Trim()
            }
            $status = "Renamed"
        }
        elseif ($statusCode -eq 'A') {
            $filePath = $parts[1].Trim()
            $status = "Added"
        }
        elseif ($statusCode -eq 'C') {
            $filePath = $parts[1].Trim()
            $status = "Copied"
        }
        elseif ($statusCode -eq 'D') {
            $filePath = $parts[1].Trim()
            $status = "Deleted"
        }
        elseif ($statusCode -eq 'M') {
            $filePath = $parts[1].Trim()
            $status = "Modified"
        }
        else {
            continue
        }

        # Skip .git metadata
        if ($filePath -eq '.git' -or $filePath -like '.git/*' -or $filePath -like '.git\*') {
            continue
        }

        # Step 3: Get per-file diff
        $diffContent = git diff -w --unified=3 "$Ref1" "$Ref2" -- $filePath 2>$null
        if ($null -eq $diffContent) { $diffContent = "" }
        if ($diffContent -is [array]) { $diffContent = $diffContent -join "`n" }

        $counts = Get-FileLineCounts -DiffContent $diffContent

        $fileChanges += [PSCustomObject]@{
            FilePath     = $filePath
            Status       = $status
            DiffContent  = $diffContent
            LinesAdded   = $counts.Added
            LinesRemoved = $counts.Removed
        }
    }

    $fileChanges = $fileChanges | Sort-Object FilePath

    if ($fileChanges.Count -eq 0) {
        Write-Host "No significant differences found between '$Ref1' and '$Ref2'." -ForegroundColor Yellow
    }
    else {
        Write-Host "  Found $($fileChanges.Count) changed file(s)" -ForegroundColor Gray
    }

    # Step 4: Generate markdown
    Write-Host "Generating markdown..." -ForegroundColor Cyan

    $repoName = Get-RepoName
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm"

    $totalAdded = ($fileChanges | Measure-Object -Property LinesAdded -Sum).Sum
    $totalRemoved = ($fileChanges | Measure-Object -Property LinesRemoved -Sum).Sum

    $sb = [System.Text.StringBuilder]::new()

    # Header
    [void]$sb.AppendLine("# Diff Summary: ``$Ref1`` vs ``$Ref2``")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("**Repository:** $repoName")
    [void]$sb.AppendLine("**Date:** $timestamp")
    [void]$sb.AppendLine("**Base ref:** ``$Ref1`` (``$ref1Sha``)")
    [void]$sb.AppendLine("**Compare ref:** ``$Ref2`` (``$ref2Sha``)")
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("---")
    [void]$sb.AppendLine()

    # Summary section
    [void]$sb.AppendLine("## Summary")
    [void]$sb.AppendLine()

    $statLine = "$($fileChanges.Count) file(s) changed, $totalAdded insertion(s)(+), $totalRemoved deletion(s)(-)"
    [void]$sb.AppendLine($statLine)
    [void]$sb.AppendLine()
    [void]$sb.AppendLine("> Insignificant differences (whitespace, blank lines) were ignored using git diff's built-in ignore flags.")
    [void]$sb.AppendLine()

    if ($fileChanges.Count -gt 0) {
        [void]$sb.AppendLine("| Status | File | Lines Added | Lines Removed |")
        [void]$sb.AppendLine("|--------|------|-------------|---------------|")

        foreach ($file in $fileChanges) {
            [void]$sb.AppendLine("| $($file.Status) | ``$($file.FilePath)`` | +$($file.LinesAdded) | -$($file.LinesRemoved) |")
        }

        [void]$sb.AppendLine()
        [void]$sb.AppendLine("---")
        [void]$sb.AppendLine()

        # File Changes section
        [void]$sb.AppendLine("## File Changes")
        [void]$sb.AppendLine()

        foreach ($file in $fileChanges) {
            [void]$sb.AppendLine("### ``$($file.FilePath)``")
            [void]$sb.AppendLine()
            [void]$sb.AppendLine("**Status:** $($file.Status) | **+$($file.LinesAdded)** | **-$($file.LinesRemoved)**")
            [void]$sb.AppendLine()

            if ($file.DiffContent -match '(?m)^Binary files .+ and .+ differ$') {
                [void]$sb.AppendLine("Binary file")
            }
            elseif ([string]::IsNullOrWhiteSpace($file.DiffContent)) {
                [void]$sb.AppendLine("_No diff content available._")
            }
            else {
                [void]$sb.AppendLine('```diff')
                [void]$sb.AppendLine($file.DiffContent)
                [void]$sb.AppendLine('```')
            }

            [void]$sb.AppendLine()
            [void]$sb.AppendLine("---")
            [void]$sb.AppendLine()
        }
    }

    # Step 5: Write output
    $outputPath = if ([System.IO.Path]::IsPathRooted($OutputFile)) {
        $OutputFile
    }
    else {
        Join-Path -Path (Get-Location) -ChildPath $OutputFile
    }

    $outputDir = Split-Path -Path $outputPath -Parent
    if ($outputDir -and -not (Test-Path $outputDir)) {
        New-Item -ItemType Directory -Path $outputDir -Force | Out-Null
    }

    $utf8NoBom = [System.Text.UTF8Encoding]::new($false)
    [System.IO.File]::WriteAllText($outputPath, $sb.ToString(), $utf8NoBom)

    Write-Host ""
    Write-Host "Diff summary written to: $outputPath" -ForegroundColor Green
    Write-Host $statLine -ForegroundColor Gray
}
catch {
    Write-Error "Failed to generate diff summary: $_"
    exit 1
}
