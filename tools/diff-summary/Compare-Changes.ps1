<#
.SYNOPSIS
    Compares two git refs (branches, commit SHAs, or tags) and generates a markdown diff summary.

.DESCRIPTION
    This script uses Beyond Compare 5 and git worktrees to compare two refs and produces a
    well-formatted markdown file containing a summary table of all changed files and per-file
    inline diffs with syntax highlighting. Beyond Compare's rules-based comparison is used with
    the "ignore unimportant" option to skip insignificant differences like whitespace and blank lines.

    Supports Windows and Linux. Beyond Compare 5 is installed automatically if not already present.

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

# Temp paths (set here so finally block can always clean up)
$worktree1 = $null
$worktree2 = $null
$bcScriptFile = $null
$bcReportFile = $null

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

function Ensure-BeyondCompareInstalled {
    <#
    .SYNOPSIS
        Ensures Beyond Compare 5 CLI is installed and returns its executable path.
    .DESCRIPTION
        Checks whether Beyond Compare 5 is installed on the current platform (Windows or Linux).
        If it is not found it will be installed automatically, then the path to the executable
        is returned.  Exits with code 1 if installation is not possible.
    .OUTPUTS
        [string] Absolute path to the Beyond Compare 5 executable.
    #>

    if ($IsWindows) {
        $bcPath = "C:\Program Files\Beyond Compare 5\BComp.com"
        if (Test-Path $bcPath) {
            Write-Host "  Beyond Compare 5 found at: $bcPath" -ForegroundColor Gray
            return $bcPath
        }

        Write-Host "Beyond Compare 5 not found. Attempting to install via Chocolatey..." -ForegroundColor Yellow
        $chocoCmd = Get-Command choco -ErrorAction SilentlyContinue
        if ($chocoCmd) {
            & choco install beyondcompare -y 2>&1 | Out-Null
        }
        else {
            Write-Error "Beyond Compare 5 is not installed and Chocolatey is not available. Please install Beyond Compare 5 from https://www.scootersoftware.com/ or install Chocolatey and re-run."
            exit 1
        }

        if (Test-Path $bcPath) {
            Write-Host "  Beyond Compare 5 installed at: $bcPath" -ForegroundColor Gray
            return $bcPath
        }

        Write-Error "Beyond Compare 5 installation failed. Please install it manually from https://www.scootersoftware.com/"
        exit 1
    }
    elseif ($IsLinux) {
        # Check common installation locations
        $linuxPaths = @("/usr/bin/bcompare", "/usr/lib/beyondcompare/bcompare")
        foreach ($path in $linuxPaths) {
            if (Test-Path $path) {
                Write-Host "  Beyond Compare 5 found at: $path" -ForegroundColor Gray
                return $path
            }
        }

        # Check PATH
        $bcInPath = Get-Command bcompare -ErrorAction SilentlyContinue
        if ($bcInPath) {
            Write-Host "  Beyond Compare 5 found at: $($bcInPath.Source)" -ForegroundColor Gray
            return $bcInPath.Source
        }

        Write-Host "Beyond Compare 5 not found. Installing via apt..." -ForegroundColor Yellow
        & bash -c "wget -qO - https://www.scootersoftware.com/RPM-GPG-KEY-scootersoftware | sudo gpg --dearmor -o /etc/apt/keyrings/scootersoftware.gpg" 2>&1 | Out-Null
        & bash -c "echo 'deb [signed-by=/etc/apt/keyrings/scootersoftware.gpg] https://www.scootersoftware.com/ bcompare5 non-free' | sudo tee /etc/apt/sources.list.d/bcompare.list" | Out-Null
        & sudo apt-get update -qq 2>&1 | Out-Null
        & sudo apt-get install -y bcompare 2>&1 | Out-Null

        foreach ($path in $linuxPaths) {
            if (Test-Path $path) {
                Write-Host "  Beyond Compare 5 installed at: $path" -ForegroundColor Gray
                return $path
            }
        }

        $bcInPath = Get-Command bcompare -ErrorAction SilentlyContinue
        if ($bcInPath) {
            Write-Host "  Beyond Compare 5 installed at: $($bcInPath.Source)" -ForegroundColor Gray
            return $bcInPath.Source
        }

        Write-Error "Beyond Compare 5 installation failed. Please install it manually from https://www.scootersoftware.com/"
        exit 1
    }
    else {
        Write-Error "Unsupported operating system. Beyond Compare 5 is available for Windows and Linux. Visit https://www.scootersoftware.com/ for more information."
        exit 1
    }
}

# Ensure Beyond Compare 5 is installed when the script is loaded
Write-Host "Checking Beyond Compare 5 installation..." -ForegroundColor Cyan
$BcPath = Ensure-BeyondCompareInstalled

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

    # Step 2: Create temporary git worktrees
    Write-Host "Creating temporary worktrees..." -ForegroundColor Cyan

    $tempBase = Join-Path ([System.IO.Path]::GetTempPath()) "diff-summary"
    New-Item -ItemType Directory -Path $tempBase -Force | Out-Null

    $worktree1 = Join-Path $tempBase "ref1-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"
    $worktree2 = Join-Path $tempBase "ref2-$([System.Guid]::NewGuid().ToString('N').Substring(0,8))"

    git worktree add $worktree1 $Ref1 --detach 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create worktree for Ref1 '$Ref1'."
        exit 1
    }

    git worktree add $worktree2 $Ref2 --detach 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to create worktree for Ref2 '$Ref2'."
        exit 1
    }

    Write-Host "  Worktree 1: $worktree1" -ForegroundColor Gray
    Write-Host "  Worktree 2: $worktree2" -ForegroundColor Gray

    # Step 3: Run Beyond Compare folder comparison
    Write-Host "Running Beyond Compare folder comparison..." -ForegroundColor Cyan

    $bcScriptFile = Join-Path $tempBase "bc-script-$([System.Guid]::NewGuid().ToString('N').Substring(0,8)).bcscript"
    $bcReportFile = Join-Path $tempBase "bc-report-$([System.Guid]::NewGuid().ToString('N').Substring(0,8)).txt"

    # BC script: load folders, expand all, select changed/orphan files, generate text report
    $bcScript = @"
criteria rules-based
load "%1" "%2"
expand all
select diff.files orphan.files
text-report layout:side-by-side options:display-mismatches output-to:"%3"
"@
    Set-Content -Path $bcScriptFile -Value $bcScript -Encoding ASCII

    # On Linux without a display, wrap with xvfb-run so Beyond Compare can initialize
    if ($IsLinux -and -not $env:DISPLAY) {
        $xvfbRun = Get-Command xvfb-run -ErrorAction SilentlyContinue
        if (-not $xvfbRun) {
            & sudo apt-get install -y xvfb 2>&1 | Out-Null
        }
        & xvfb-run $BcPath "@$bcScriptFile" $worktree1 $worktree2 $bcReportFile /silent /closescript /iu 2>&1 | Out-Null
    }
    else {
        & $BcPath "@$bcScriptFile" $worktree1 $worktree2 $bcReportFile /silent /closescript /iu 2>&1 | Out-Null
    }
    $bcExitCode = $LASTEXITCODE

    if ($bcExitCode -ge 100) {
        Write-Error "Beyond Compare exited with error code $bcExitCode."
        exit 1
    }

    # Step 4: Parse BC report to get list of changed files
    Write-Host "Parsing comparison results..." -ForegroundColor Cyan

    $changedFiles = @()
    if (Test-Path $bcReportFile) {
        $reportLines = Get-Content $bcReportFile
        foreach ($line in $reportLines) {
            if ($line -match '^File:\s+(.+?)\s*$') {
                $relativePath = $Matches[1].Trim()
                # Skip .git metadata
                if ($relativePath -eq '.git' -or $relativePath -like '.git\*' -or $relativePath -like '.git/*') {
                    continue
                }
                $changedFiles += $relativePath
            }
        }
    }

    # Determine file status and collect diffs
    $fileChanges = @()
    foreach ($filePath in ($changedFiles | Sort-Object)) {
        $leftFile = Join-Path $worktree1 $filePath
        $rightFile = Join-Path $worktree2 $filePath
        $leftExists = Test-Path $leftFile
        $rightExists = Test-Path $rightFile

        if ($leftExists -and $rightExists) {
            $status = "Modified"
        }
        elseif ($rightExists -and -not $leftExists) {
            $status = "Added"
        }
        elseif ($leftExists -and -not $rightExists) {
            $status = "Deleted"
        }
        else {
            continue
        }

        # Get unified diff using git diff --no-index
        $diffContent = ""
        if ($leftExists -and $rightExists) {
            $diffContent = git diff --no-index -- $leftFile $rightFile 2>$null
        }
        elseif ($rightExists) {
            $diffContent = git diff --no-index -- /dev/null $rightFile 2>$null
        }
        elseif ($leftExists) {
            $diffContent = git diff --no-index -- $leftFile /dev/null 2>$null
        }

        if ($null -eq $diffContent) { $diffContent = "" }
        if ($diffContent -is [array]) { $diffContent = $diffContent -join "`n" }

        # Clean up absolute paths in diff headers to show relative paths
        # git diff --no-index outputs c-style escaped paths with doubled backslashes
        $wt1Doubled = $worktree1 -replace '\\', '\\'
        $wt2Doubled = $worktree2 -replace '\\', '\\'
        # Also handle forward-slash variants
        $wt1Forward = $worktree1 -replace '\\', '/'
        $wt2Forward = $worktree2 -replace '\\', '/'
        # Replace all variants — worktree path followed by separator becomes empty
        # so that "a/<worktree>/<file>" becomes "a/<file>"
        foreach ($pathVariant in @("$wt1Doubled\\", "$wt2Doubled\\", "$wt1Forward/", "$wt2Forward/", "$worktree1\", "$worktree2\", "$worktree1/", "$worktree2/")) {
            $diffContent = $diffContent.Replace($pathVariant, '')
        }
        # Also handle case where worktree path appears without trailing separator
        foreach ($pathVariant in @($wt1Doubled, $wt2Doubled, $wt1Forward, $wt2Forward, $worktree1, $worktree2)) {
            $diffContent = $diffContent.Replace($pathVariant, '')
        }

        $counts = Get-FileLineCounts -DiffContent $diffContent

        $fileChanges += [PSCustomObject]@{
            FilePath    = $filePath
            Status      = $status
            DiffContent = $diffContent
            LinesAdded  = $counts.Added
            LinesRemoved = $counts.Removed
        }
    }

    if ($fileChanges.Count -eq 0) {
        Write-Host "No significant differences found between '$Ref1' and '$Ref2'." -ForegroundColor Yellow
    }
    else {
        Write-Host "  Found $($fileChanges.Count) changed file(s)" -ForegroundColor Gray
    }

    # Step 5: Generate markdown
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
    [void]$sb.AppendLine("> Insignificant differences (whitespace, blank lines, line endings) were ignored using Beyond Compare's rules-based comparison.")
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

    # Step 6: Write output
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
finally {
    # Always clean up worktrees and temp files
    if ($worktree1 -and (Test-Path $worktree1 -ErrorAction SilentlyContinue)) {
        Write-Host "Cleaning up worktree 1..." -ForegroundColor DarkGray
        git worktree remove $worktree1 --force 2>$null
    }
    if ($worktree2 -and (Test-Path $worktree2 -ErrorAction SilentlyContinue)) {
        Write-Host "Cleaning up worktree 2..." -ForegroundColor DarkGray
        git worktree remove $worktree2 --force 2>$null
    }
    if ($bcScriptFile -and (Test-Path $bcScriptFile -ErrorAction SilentlyContinue)) {
        Remove-Item $bcScriptFile -Force -ErrorAction SilentlyContinue
    }
    if ($bcReportFile -and (Test-Path $bcReportFile -ErrorAction SilentlyContinue)) {
        Remove-Item $bcReportFile -Force -ErrorAction SilentlyContinue
    }
}
