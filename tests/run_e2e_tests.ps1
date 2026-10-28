<#
.SYNOPSIS
    Comprehensive 4-Tier E2E Test Suite for adrielhs Profile Overhaul.
.DESCRIPTION
    Validates R1 (Corporate Banner SVG), R4 (Animated Network Map SVG),
    R3 (Four Browser-Based Minigames), R2 (Explorable README Interface),
    Boundary Values, Cross-Feature Consistency, and Real-World Scenarios.
.PARAMETER Tier
    Tier to run: "1", "2", "3", "4", or "All" (default: "All").
.PARAMETER Quiet
    Suppresses verbose progress output if set.
.EXAMPLE
    powershell -ExecutionPolicy Bypass -File tests/run_e2e_tests.ps1
    powershell -ExecutionPolicy Bypass -File tests/run_e2e_tests.ps1 -Tier 1
#>

[CmdletBinding()]
param(
    [ValidateSet("1", "2", "3", "4", "All")]
    [string]$Tier = "All",
    [switch]$Quiet
)

$ErrorActionPreference = "Continue"

# Resolve Project Root directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$ProjectRoot = (Resolve-Path "$ScriptDir\..").Path
Set-Location $ProjectRoot

# Authoritative Color Palette definitions
$PALETTE_OBSIDIAN = "#030305"
$PALETTE_PANEL    = "#0A0B10"
$PALETTE_AMBER    = "#D4AF37"
$PALETTE_IVORY    = "#F5F0E8"
$PALETTE_CRIMSON  = "#8C1D18"
$PALETTE_MUTED    = "#64748B"
$PALETTE_TEXT     = "#E0E7FF"
$PALETTE_BORDER   = "#1E293B"

# Test Runner State
$Script:TotalTests  = 0
$Script:PassedTests = 0
$Script:FailedTests = 0
$Script:SkippedTests = 0

$Script:TierStats = @{
    "1" = @{ Total = 0; Passed = 0; Failed = 0; Skipped = 0 }
    "2" = @{ Total = 0; Passed = 0; Failed = 0; Skipped = 0 }
    "3" = @{ Total = 0; Passed = 0; Failed = 0; Skipped = 0 }
    "4" = @{ Total = 0; Passed = 0; Failed = 0; Skipped = 0 }
}

$Script:Failures = [System.Collections.Generic.List[PSCustomObject]]::new()

function Run-Test {
    param(
        [string]$TierNum,
        [string]$TestId,
        [string]$Description,
        [scriptblock]$Assertion
    )

    $Script:TotalTests++
    $Script:TierStats[$TierNum].Total++

    if ($Tier -ne "All" -and $Tier -ne $TierNum) {
        $Script:SkippedTests++
        $Script:TierStats[$TierNum].Skipped++
        return
    }

    try {
        $result = & $Assertion
        if ($result -eq $false) {
            throw "Assertion returned false"
        }
        $Script:PassedTests++
        $Script:TierStats[$TierNum].Passed++
        if (-not $Quiet) {
            Write-Host "  [PASS] " -ForegroundColor Green -NoNewline
            Write-Host "$TestId : $Description" -ForegroundColor Gray
        }
    }
    catch {
        $Script:FailedTests++
        $Script:TierStats[$TierNum].Failed++
        $errMsg = $_.Exception.Message
        $Script:Failures.Add([PSCustomObject]@{
            Tier        = $TierNum
            Id          = $TestId
            Description = $Description
            Error       = $errMsg
        })
        Write-Host "  [FAIL] " -ForegroundColor Red -NoNewline
        Write-Host "$TestId : $Description" -ForegroundColor White
        Write-Host "         Error: $errMsg" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " ADRIEL HIPOLITO // 4-TIER END-TO-END VERIFICATION HARNESS" -ForegroundColor Cyan
Write-Host " Project Root: $ProjectRoot" -ForegroundColor DarkGray
Write-Host " Target Tier : $Tier" -ForegroundColor DarkGray
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

# ==============================================================================
# TIER 1: FEATURE COVERAGE
# ==============================================================================
if ($Tier -eq "All" -or $Tier -eq "1") {
    Write-Host "--- TIER 1: FEATURE COVERAGE (R1, R4, R3, R2) ---" -ForegroundColor Yellow

    # R1 Banner SVG Tests
    $bannerPath = Join-Path $ProjectRoot "assets\corporate_grid.svg"

    Run-Test "1" "T1.01_BANNER_FILE_EXISTS" "corporate_grid.svg file exists in assets/" {
        Test-Path $bannerPath
    }

    Run-Test "1" "T1.02_BANNER_VALID_XML" "corporate_grid.svg parses as valid XML" {
        $content = Get-Content -Path $bannerPath -Raw
        $xml = [xml]$content
        $xml.DocumentElement.Name -eq "svg"
    }

    Run-Test "1" "T1.03_BANNER_DIMENSIONS" "corporate_grid.svg has viewBox 0 0 900 300 and 900x300 width/height" {
        $content = Get-Content -Path $bannerPath -Raw
        $xml = [xml]$content
        $viewBox = $xml.svg.viewBox
        $width = $xml.svg.width
        $height = $xml.svg.height
        ($viewBox -match "0\s+0\s+900\s+300") -and ($width -eq "900") -and ($height -eq "300")
    }

    Run-Test "1" "T1.04_BANNER_SIGIL_GEOMETRY" "corporate_grid.svg contains geometric corporate sigil in center-left" {
        $content = Get-Content -Path $bannerPath -Raw
        ($content -match "sigil-ring|sigil") -or ($content -match "polygon.*points=.*200,70")
    }

    Run-Test "1" "T1.05_BANNER_ROUTING_LINES" "corporate_grid.svg contains amber & crimson network pulse paths" {
        $content = Get-Content -Path $bannerPath -Raw
        ($content -match '#D4AF37') -and ($content -match '#8C1D18') -and ($content -match "path.*route-primary|path.*stroke")
    }

    Run-Test "1" "T1.06_BANNER_ANIMATION_KEYFRAMES" "corporate_grid.svg has slow non-flashing keyframes/animation" {
        $content = Get-Content -Path $bannerPath -Raw
        ($content -match "@keyframes\s+drawLine") -or ($content -match "<animate")
    }

    Run-Test "1" "T1.07_BANNER_TYPOGRAPHY_BLOCK" "corporate_grid.svg contains Space Mono typography with FULL-STACK DEVELOPMENT" {
        $content = Get-Content -Path $bannerPath -Raw
        ($content -match "FULL-STACK") -and ($content -match "DEVELOPMENT") -and
        ($content -match "SYSTEMS\s+&(amp;)?\s+APPLICATIONS GRID") -and ($content -match "Space Mono")
    }

    Run-Test "1" "T1.08_BANNER_VERSION_STAMP" "corporate_grid.svg contains explicit muted date/version stamp" {
        $content = Get-Content -Path $bannerPath -Raw
        ($content -match "2026\.Q4|v3\.0|INFRASTRUCTURE V3") -and ($content -match "#64748B|label-dim")
    }

    Run-Test "1" "T1.09_BANNER_SCANLINE_OVERLAY" "corporate_grid.svg contains subtle scanline pattern" {
        $content = Get-Content -Path $bannerPath -Raw
        ($content -match '<pattern\s+id="scanlines"') -and ($content -match 'fill="url\(#scanlines\)"')
    }

    Run-Test "1" "T1.10_BANNER_FORBIDDEN_COLORS" "corporate_grid.svg has ZERO forbidden colors (cyan, neon, rainbow, #00E5FF)" {
        $content = Get-Content -Path $bannerPath -Raw
        $forbidden = [regex]::Matches($content, "(?i)#00E5FF|#00ff66|cyan|neon|rainbow|#FF003C|purple")
        if ($forbidden.Count -gt 0) {
            throw "Found $($forbidden.Count) forbidden color occurrences: $($forbidden[0].Value)"
        }
        $true
    }

    # R4 Network Map SVG Tests
    $networkMapPath = Join-Path $ProjectRoot "assets\network_map.svg"

    Run-Test "1" "T1.11_NETWORK_MAP_FILE_EXISTS" "network_map.svg exists in assets/" {
        Test-Path $networkMapPath
    }

    Run-Test "1" "T1.12_NETWORK_MAP_VALID_XML" "network_map.svg parses as valid XML" {
        $content = Get-Content -Path $networkMapPath -Raw
        $xml = [xml]$content
        $xml.DocumentElement.Name -eq "svg"
    }

    Run-Test "1" "T1.13_NETWORK_MAP_VIEWBOX" "network_map.svg has viewBox spanning at least 900px wide" {
        $content = Get-Content -Path $networkMapPath -Raw
        $xml = [xml]$content
        $viewBox = $xml.svg.viewBox
        $parts = $viewBox -split '\s+'
        if ($parts.Length -ge 3 -and [double]$parts[2] -ge 900) { $true } else { $false }
    }

    Run-Test "1" "T1.14_NETWORK_MAP_FOUR_NODES" "network_map.svg contains all 4 project node labels" {
        $content = Get-Content -Path $networkMapPath -Raw
        $nodes = @("Projetos Iniciais", "Template Fastify", "Humidity Sensor", "Cassino Reverso")
        foreach ($node in $nodes) {
            if (-not ($content -match [regex]::Escape($node))) {
                throw "Missing node label: $node"
            }
        }
        $true
    }

    Run-Test "1" "T1.15_NETWORK_MAP_ANIMATEMOTION" "network_map.svg uses SMIL animateMotion for signal dots" {
        $content = Get-Content -Path $networkMapPath -Raw
        $matches = [regex]::Matches($content, "<animateMotion")
        if ($matches.Count -lt 1) {
            throw "No <animateMotion> elements found in network_map.svg"
        }
        $true
    }

    Run-Test "1" "T1.16_NETWORK_MAP_FORBIDDEN_COLORS" "network_map.svg has ZERO forbidden colors (cyan, #00e5ff, #00ff)" {
        $content = Get-Content -Path $networkMapPath -Raw
        $forbidden = [regex]::Matches($content, "(?i)cyan|#00e5ff|#00ff")
        if ($forbidden.Count -gt 0) {
            throw "Found $($forbidden.Count) forbidden color occurrences: $($forbidden[0].Value)"
        }
        $true
    }

    # R3 Minigames Existence and HTML Structure
    $minigames = @("signal-route", "task-triage", "color-protocol", "audio-breach")

    Run-Test "1" "T1.17_MINIGAMES_ALL_EXIST" "All 4 standalone minigame index.html files exist" {
        foreach ($mg in $minigames) {
            $mgFile = Join-Path $ProjectRoot "minigame\$mg\index.html"
            if (-not (Test-Path $mgFile)) {
                throw "Missing minigame file: minigame/$mg/index.html"
            }
        }
        $true
    }

    Run-Test "1" "T1.18_MINIGAMES_HTML_STRUCTURE" "All 4 minigames contain valid HTML structure with head, body, script" {
        foreach ($mg in $minigames) {
            $mgFile = Join-Path $ProjectRoot "minigame\$mg\index.html"
            $html = Get-Content -Path $mgFile -Raw
            if (-not ($html -match "(?i)<!DOCTYPE html>" -and $html -match "(?i)<html" -and $html -match "(?i)<head" -and $html -match "(?i)<body" -and $html -match "(?i)<script")) {
                throw "Incomplete HTML structure in minigame/$mg/index.html"
            }
        }
        $true
    }

    Run-Test "1" "T1.19_MINIGAMES_SCREEN_STATES" "All 4 minigames implement Title and End/Win screens with replay action" {
        foreach ($mg in $minigames) {
            $mgFile = Join-Path $ProjectRoot "minigame\$mg\index.html"
            $html = Get-Content -Path $mgFile -Raw
            $hasTitle = ($html -match "(?i)title|instructions|screen|briefing")
            $hasReplay = ($html -match "(?i)Play Again|Run Again|Again|Restart|history\.back|startSimulation|startSession|startGame")
            if (-not ($hasTitle -and $hasReplay)) {
                throw "Missing title or replay screen structure in minigame/$mg/index.html"
            }
        }
        $true
    }

    # R2 README Structure
    $readmePath = Join-Path $ProjectRoot "README.md"

    Run-Test "1" "T1.20_README_FILE_EXISTS" "README.md exists in repository root" {
        Test-Path $readmePath
    }

    Run-Test "1" "T1.21_README_STARTS_WITH_BANNER_DIV" "README.md starts with centered div wrapping banner SVG" {
        $firstLine = (Get-Content -Path $readmePath -TotalCount 1).Trim()
        if ($firstLine -ne '<div align="center">') {
            throw "README.md first line is '$firstLine', expected '<div align=`"center`">'"
        }
        $content = Get-Content -Path $readmePath -Raw
        if (-not ($content -match 'assets/corporate_grid\.svg')) {
            throw "README.md does not embed assets/corporate_grid.svg"
        }
        $true
    }

    Run-Test "1" "T1.22_README_TYPING_ANIMATION" "README.md includes typing animation with color=D4AF37" {
        $content = Get-Content -Path $readmePath -Raw
        ($content -match 'readme-typing-svg\.demolab\.com') -and ($content -match 'color=D4AF37')
    }

    Run-Test "1" "T1.23_README_FOUR_MINIGAME_LINKS" "README.md links to all 4 browser minigames relative paths" {
        $content = Get-Content -Path $readmePath -Raw
        $expectedLinks = @(
            '\./minigame/signal-route/index\.html',
            '\./minigame/task-triage/index\.html',
            '\./minigame/color-protocol/index\.html',
            '\./minigame/audio-breach/index\.html'
        )
        foreach ($link in $expectedLinks) {
            if (-not ($content -match $link)) {
                throw "Missing minigame link matching pattern: $link"
            }
        }
        $true
    }

    Run-Test "1" "T1.24_README_FORBIDDEN_CLAIMS_BAN" "README.md contains ZERO forbidden fake-tech phrases" {
        $content = Get-Content -Path $readmePath -Raw
        $forbidden = [regex]::Matches($content, "(?i)rsa-2048|latency:\s*1ms|level_5|air-gapped|netrunner|rainbow|overclock|neural_orch")
        if ($forbidden.Count -gt 0) {
            throw "Found $($forbidden.Count) forbidden claim occurrences in README: '$($forbidden[0].Value)'"
        }
        $true
    }
}

# ==============================================================================
# TIER 2: BOUNDARY & CORNER CASES
# ==============================================================================
if ($Tier -eq "All" -or $Tier -eq "2") {
    Write-Host "`n--- TIER 2: BOUNDARY & CORNER CASES ---" -ForegroundColor Yellow

    # Banner SVG Boundaries
    $bannerPath = Join-Path $ProjectRoot "assets\corporate_grid.svg"

    Run-Test "2" "T2.01_BANNER_900PX_MINIMUM_WIDTH" "Banner SVG viewBox width is at least 900px" {
        $content = Get-Content -Path $bannerPath -Raw
        $xml = [xml]$content
        $viewBox = $xml.svg.viewBox
        $parts = $viewBox -split '\s+'
        [double]$parts[2] -ge 900
    }

    Run-Test "2" "T2.02_BANNER_3_TO_1_ASPECT_RATIO" "Banner SVG aspect ratio is exactly 3:1 (width/height = 3.0)" {
        $content = Get-Content -Path $bannerPath -Raw
        $xml = [xml]$content
        $viewBox = $xml.svg.viewBox
        $parts = $viewBox -split '\s+'
        $w = [double]$parts[2]
        $h = [double]$parts[3]
        $ratio = [Math]::Round($w / $h, 2)
        if ($ratio -ne 3.0) {
            throw "Aspect ratio is $ratio ($w x $h), expected 3.0"
        }
        $true
    }

    Run-Test "2" "T2.03_BANNER_SCANLINE_OPACITY_LIMIT" "Banner scanline pattern opacity is <= 0.04 (4% maximum)" {
        $content = Get-Content -Path $bannerPath -Raw
        $match = [regex]::Match($content, 'id="scanlines"[\s\S]*?opacity="([0-9.]+)"')
        if (-not $match.Success) {
            # Try matching rect opacity inside scanlines pattern
            $match = [regex]::Match($content, '<pattern[^>]*id="scanlines"[^>]*>[\s\S]*?<rect[^>]*opacity="([0-9.]+)"')
        }
        if (-not $match.Success) {
            throw "Could not extract scanlines opacity from corporate_grid.svg"
        }
        $opacity = [double]$match.Groups[1].Value
        if ($opacity -gt 0.04) {
            throw "Scanline opacity $opacity exceeds maximum allowed 0.04 (4%)"
        }
        $true
    }

    Run-Test "2" "T2.04_BANNER_PALETTE_HEX_LIMITS" "All explicit color hex codes in corporate_grid.svg adhere to corporate palette" {
        $content = Get-Content -Path $bannerPath -Raw
        $hexMatches = [regex]::Matches($content, "#[0-9a-fA-F]{6}")
        $allowed = @("#030305", "#0A0B10", "#D4AF37", "#F5F0E8", "#8C1D18", "#64748B", "#E0E7FF", "#1E293B", "#11131B")
        $disallowed = @()
        foreach ($m in $hexMatches) {
            $hex = $m.Value.ToUpper()
            $isAllowed = $false
            foreach ($a in $allowed) {
                if ($hex -eq $a.ToUpper()) { $isAllowed = $true; break }
            }
            if (-not $isAllowed) {
                $disallowed += $hex
            }
        }
        if ($disallowed.Count -gt 0) {
            $unique = $disallowed | Select-Object -Unique
            throw "Disallowed hex colors in banner: $($unique -join ', ')"
        }
        $true
    }

    # Network Map Boundaries
    $networkMapPath = Join-Path $ProjectRoot "assets\network_map.svg"

    Run-Test "2" "T2.05_NETWORK_MAP_DIMENSIONS_RANGE" "Network map viewBox width is >= 900 and height between 150 and 180" {
        $content = Get-Content -Path $networkMapPath -Raw
        $xml = [xml]$content
        $parts = $xml.svg.viewBox -split '\s+'
        $w = [double]$parts[2]
        $h = [double]$parts[3]
        ($w -ge 900) -and ($h -ge 150) -and ($h -le 180)
    }

    Run-Test "2" "T2.06_NETWORK_MAP_NODE4_BORDER_AMBER" "Network map Node 4 (Cassino Reverso) has amber (#D4AF37) border stroke" {
        $content = Get-Content -Path $networkMapPath -Raw
        # Find Node 4 rect (x >= 600)
        $match = [regex]::Match($content, '<rect[^>]*x="6[0-9]{2}"[^>]*stroke="([^"]+)"')
        if (-not $match.Success) {
            throw "Could not locate Node 4 rect in network_map.svg"
        }
        $stroke = $match.Groups[1].Value.ToUpper()
        if ($stroke -ne "#D4AF37") {
            throw "Node 4 border stroke is '$stroke', expected '#D4AF37'"
        }
        $true
    }

    # Minigame Viewport Boundaries
    Run-Test "2" "T2.07_MINIGAMES_VIEWPORT_META" "All 4 minigames contain standard responsive viewport meta tag" {
        $minigames = @("signal-route", "task-triage", "color-protocol", "audio-breach")
        foreach ($mg in $minigames) {
            $mgFile = Join-Path $ProjectRoot "minigame\$mg\index.html"
            $html = Get-Content -Path $mgFile -Raw
            if (-not ($html -match '<meta\s+name="viewport"\s+content="[^"]*width=device-width')) {
                throw "minigame/$mg/index.html is missing width=device-width viewport meta tag"
            }
        }
        $true
    }

    # Color Protocol Boundaries (0-255 Sliders & Target Hex)
    $colorProtocolPath = Join-Path $ProjectRoot "minigame\color-protocol\index.html"

    Run-Test "2" "T2.08_COLOR_PROTOCOL_SLIDER_RANGE" "Color Protocol RGB sliders have min=0 and max=255" {
        $content = Get-Content -Path $colorProtocolPath -Raw
        $minZero = [regex]::Matches($content, 'min="0"')
        $max255  = [regex]::Matches($content, 'max="255"')
        if ($minZero.Count -lt 3 -or $max255.Count -lt 3) {
            throw "Sliders in Color Protocol do not explicitly define min=0 and max=255 for all 3 channels"
        }
        $true
    }

    Run-Test "2" "T2.09_COLOR_PROTOCOL_FIVE_ROUNDS" "Color Protocol specifies exactly 5 target color rounds within 0-255" {
        $content = Get-Content -Path $colorProtocolPath -Raw
        # Verify 5 targets defined in JS
        $match = [regex]::Match($content, 'TARGETS\s*=\s*\[([\s\S]*?)\];')
        if (-not $match.Success) {
            throw "Could not find TARGETS array in Color Protocol"
        }
        $targetsBlock = $match.Groups[1].Value
        $targetItems = [regex]::Matches($targetsBlock, '\{[^}]*r\s*:\s*([0-9]+)[^}]*g\s*:\s*([0-9]+)[^}]*b\s*:\s*([0-9]+)[^}]*\}')
        if ($targetItems.Count -ne 5) {
            throw "TARGETS array contains $($targetItems.Count) rounds, expected exactly 5"
        }
        foreach ($t in $targetItems) {
            $r = [int]$t.Groups[1].Value
            $g = [int]$t.Groups[2].Value
            $b = [int]$t.Groups[3].Value
            if ($r -lt 0 -or $r -gt 255 -or $g -lt 0 -or $g -gt 255 -or $b -lt 0 -or $b -gt 255) {
                throw "Target color channel out of bounds [0, 255]: ($r, $g, $b)"
            }
        }
        $true
    }

    # Task Triage Boundaries (30s Timers & 3 Rounds)
    $taskTriagePath = Join-Path $ProjectRoot "minigame\task-triage\index.html"

    Run-Test "2" "T2.10_TASK_TRIAGE_TIMER_30S_AND_3_ROUNDS" "Task Triage defines 30s timers and 3 rounds total" {
        $content = Get-Content -Path $taskTriagePath -Raw
        $has30s = ($content -match 'timer\s*=\s*30') -or ($content -match '30\s*seconds')
        $has3Rounds = ($content -match 'round\s*<\s*3') -or ($content -match '3\s*rounds') -or ($content -match 'ROUND_DURATION\s*=\s*30')
        if (-not ($has30s -and $has3Rounds)) {
            throw "Task Triage does not configure 30s timer and 3 rounds"
        }
        $true
    }

    Run-Test "2" "T2.11_TASK_TRIAGE_FOUR_PRIORITY_COLUMNS" "Task Triage defines all 4 priority columns (CRITICAL, HIGH, MEDIUM, LOW)" {
        $content = Get-Content -Path $taskTriagePath -Raw
        $pris = @("critical", "high", "medium", "low")
        foreach ($p in $pris) {
            if (-not ($content -match "(?i)$p")) {
                throw "Missing priority level: $p"
            }
        }
        $true
    }

    # Signal Route Grid Boundaries (3x3 to 7x7)
    $signalRoutePath = Join-Path $ProjectRoot "minigame\signal-route\index.html"

    Run-Test "2" "T2.12_SIGNAL_ROUTE_FIVE_LEVELS_RANGE" "Signal Route defines 5 levels progressing from 3x3 to 7x7" {
        $content = Get-Content -Path $signalRoutePath -Raw
        $match = [regex]::Match($content, 'LEVELS\s*=\s*(\[[\s\S]*?\]);')
        if (-not $match.Success) {
            throw "Could not extract LEVELS array from Signal Route"
        }
        # Check that sizes 3, 4, 5, 6, 7 are present in sequence
        $sizes = [regex]::Matches($match.Groups[1].Value, 'size\s*:\s*([3-7])')
        if ($sizes.Count -ne 5) {
            throw "Found $($sizes.Count) level sizes, expected 5"
        }
        $sizeVals = $sizes | ForEach-Object { [int]$_.Groups[1].Value }
        for ($i = 0; $i -lt 5; $i++) {
            if ($sizeVals[$i] -ne ($i + 3)) {
                throw "Level $($i+1) size is $($sizeVals[$i]), expected $($i+3)"
            }
        }
        $true
    }

    # Audio Breach Sequences (3 to 7 tones)
    $audioBreachPath = Join-Path $ProjectRoot "minigame\audio-breach\index.html"

    Run-Test "2" "T2.13_AUDIO_BREACH_SEQUENCE_GROWTH" "Audio Breach sequences grow from 3 to 7 tones over 5 rounds" {
        $content = Get-Content -Path $audioBreachPath -Raw
        $hasSeqFormula = ($content -match 'ROUND_LENGTHS\s*=\s*\[\s*3\s*,\s*4\s*,\s*5\s*,\s*6\s*,\s*7\s*\]') -or ($content -match '3\s*\+\s*round') -or ($content -match 'seqLen\s*=\s*3')
        $has5Rounds = ($content -match 'TOTAL_ROUNDS\s*=\s*5') -or ($content -match 'round\s*<\s*5') -or ($content -match '5\s*rounds')
        if (-not ($hasSeqFormula -and $has5Rounds)) {
            throw "Audio Breach does not specify 5 rounds with 3 to 7 tones sequence progression"
        }
        $true
    }
}

# ==============================================================================
# TIER 3: CROSS-FEATURE COMBINATIONS
# ==============================================================================
if ($Tier -eq "All" -or $Tier -eq "3") {
    Write-Host "`n--- TIER 3: CROSS-FEATURE COMBINATIONS ---" -ForegroundColor Yellow

    $readmePath = Join-Path $ProjectRoot "README.md"
    $readmeContent = Get-Content -Path $readmePath -Raw

    Run-Test "3" "T3.01_MINIGAME_PROJECT_MAPPING_README" "README Interactive Systems table pairs each minigame with its featured project" {
        $pairs = @(
            @{ Game = "Signal Route"; Project = "Projetos Iniciais" },
            @{ Game = "Task Triage"; Project = "ADM-SI" },
            @{ Game = "Color Protocol"; Project = "Computer Vision Detector" },
            @{ Game = "Audio Breach"; Project = "Cassino Reverso" }
        )
        foreach ($p in $pairs) {
            $pattern = "$($p.Game)[\s\S]*?$($p.Project)"
            if (-not ($readmeContent -match $pattern)) {
                throw "README does not pair '$($p.Game)' with '$($p.Project)'"
            }
        }
        $true
    }

    Run-Test "3" "T3.02_MINIGAME_IN_GAME_BRANDING" "Each minigame internally displays its corresponding project identity" {
        $gameBranding = @(
            @{ Path = "minigame\signal-route\index.html"; Project = "PROJETOS INICIAIS" },
            @{ Path = "minigame\task-triage\index.html"; Project = "ADM-SI" },
            @{ Path = "minigame\color-protocol\index.html"; Project = "COMPUTER VISION" },
            @{ Path = "minigame\audio-breach\index.html"; Project = "CASSINO REVERSO" }
        )
        foreach ($gb in $gameBranding) {
            $file = Join-Path $ProjectRoot $gb.Path
            $html = Get-Content -Path $file -Raw
            if (-not ($html -match [regex]::Escape($gb.Project))) {
                throw "$($gb.Path) does not reference linked project '$($gb.Project)'"
            }
        }
        $true
    }

    Run-Test "3" "T3.03_EVOLUTION_LINE_PROJECT_SEQUENCE" "README Evolution line follows exact progression sequence" {
        $match = [regex]::Match($readmeContent, 'Projetos Iniciais[\s\S]*?Template Fastify[\s\S]*?Humidity Sensor[\s\S]*?Cassino Reverso')
        if (-not $match.Success) {
            throw "README Evolution line is missing or out of sequence: Projetos Iniciais -> Template Fastify -> Humidity Sensor -> Cassino Reverso"
        }
        $true
    }

    Run-Test "3" "T3.04_NETWORK_MAP_SEQUENCE_ALIGNMENT" "Network map node x-coordinates match evolution line sequence" {
        $networkMapPath = Join-Path $ProjectRoot "assets\network_map.svg"
        $mapContent = Get-Content -Path $networkMapPath -Raw

        # Extract x coordinate of text or rect for each node
        $idx1 = $mapContent.IndexOf("Projetos Iniciais")
        $idx2 = $mapContent.IndexOf("Template Fastify")
        $idx3 = $mapContent.IndexOf("Humidity Sensor")
        $idx4 = $mapContent.IndexOf("Cassino Reverso")

        if ($idx1 -eq -1 -or $idx2 -eq -1 -or $idx3 -eq -1 -or $idx4 -eq -1) {
            throw "One or more project nodes missing from network_map.svg"
        }
        if (-not ($idx1 -lt $idx2 -and $idx2 -lt $idx3 -and $idx3 -lt $idx4)) {
            throw "Network map nodes are out of chronological order in SVG document"
        }
        $true
    }

    Run-Test "3" "T3.05_MINIGAMES_ZERO_EXTERNAL_DEPENDENCIES" "Zero CDN / unpkg / jsdelivr / googleapis / cloudflare across minigame directory" {
        $minigameDir = Join-Path $ProjectRoot "minigame"
        $files = Get-ChildItem -Path $minigameDir -Recurse -File
        $violations = @()

        foreach ($f in $files) {
            $content = Get-Content -Path $f.FullName -Raw
            $matches = [regex]::Matches($content, "(?i)cdn\.|unpkg\.com|jsdelivr\.net|googleapis\.com|cloudflare\.com|cdnjs\.cloudflare\.com")
            if ($matches.Count -gt 0) {
                $violations += "$($f.Name) (matches: $($matches.Count))"
            }
        }

        if ($violations.Count -gt 0) {
            throw "External dependencies detected in minigame files: $($violations -join ', ')"
        }
        $true
    }

    Run-Test "3" "T3.06_MINIGAMES_OFFLINE_FILE_PROTOCOL" "Minigames have no external script/link tags and operate via file:// protocol" {
        $minigameDir = Join-Path $ProjectRoot "minigame"
        $htmlFiles = Get-ChildItem -Path $minigameDir -Recurse -Filter "*.html"
        $violations = @()

        foreach ($hf in $htmlFiles) {
            $content = Get-Content -Path $hf.FullName -Raw
            $externalTags = [regex]::Matches($content, '<(?:script|link)[^>]+(?:src|href)=["'']https?://')
            if ($externalTags.Count -gt 0) {
                $violations += "$($hf.Name) has $($externalTags.Count) remote script/link tags"
            }
        }

        if ($violations.Count -gt 0) {
            throw "Minigames contain remote URL links: $($violations -join ', ')"
        }
        $true
    }

    Run-Test "3" "T3.07_PALETTE_COHERENCE_CSS_VARS" "All 4 minigames declare matching corporate CSS variables" {
        $minigames = @("signal-route", "task-triage", "color-protocol", "audio-breach")
        foreach ($mg in $minigames) {
            $file = Join-Path $ProjectRoot "minigame\$mg\index.html"
            $html = Get-Content -Path $file -Raw
            $hasObsidian = ($html -match '#030305|#030305')
            $hasAmber    = ($html -match '#D4AF37')
            $hasCrimson  = ($html -match '#8C1D18')
            if (-not ($hasObsidian -and $hasAmber -and $hasCrimson)) {
                throw "minigame/$mg/index.html is missing core palette variables (#030305, #D4AF37, #8C1D18)"
            }
        }
        $true
    }

    Run-Test "3" "T3.08_README_BADGES_CORPORATE_PALETTE" "Shields.io badges in README use obsidian background 030305" {
        $badgeMatches = [regex]::Matches($readmeContent, 'img\.shields\.io/badge/[^"]+')
        if ($badgeMatches.Count -eq 0) {
            throw "No shields.io badges found in README.md"
        }
        $nonCorporate = @()
        foreach ($b in $badgeMatches) {
            # Each badge should specify -030305
            if (-not ($b.Value -match '-030305\?')) {
                $nonCorporate += $b.Value
            }
        }
        if ($nonCorporate.Count -gt 0) {
            throw "Badges not using obsidian 030305 background: $($nonCorporate[0])"
        }
        $true
    }

    Run-Test "3" "T3.09_README_TELEMETRY_THEME" "GitHub Stats & Streak widgets use obsidian bg and corporate colors" {
        $hasStatsObsidian = ($readmeContent -match 'github-readme-stats\.vercel\.app[\s\S]*?bg_color=030305')
        $hasStatsAmber    = ($readmeContent -match 'github-readme-stats\.vercel\.app[\s\S]*?title_color=D4AF37')
        $hasStreakObsidian = ($readmeContent -match 'streak-stats\.demolab\.com[\s\S]*?background=030305')
        if (-not ($hasStatsObsidian -and $hasStatsAmber -and $hasStreakObsidian)) {
            throw "Telemetry widgets do not use unified obsidian/amber corporate palette"
        }
        $true
    }
}

# ==============================================================================
# TIER 4: REAL-WORLD WORKLOADS & SCENARIOS
# ==============================================================================
if ($Tier -eq "All" -or $Tier -eq "4") {
    Write-Host "`n--- TIER 4: REAL-WORLD WORKLOADS & SCENARIOS ---" -ForegroundColor Yellow

    $readmePath = Join-Path $ProjectRoot "README.md"
    $readmeContent = Get-Content -Path $readmePath -Raw

    # Scenario 1: Exact 10-Section Hierarchy
    Run-Test "4" "T4.01_SCENARIO_README_10_SECTION_ORDER" "README follows strict sequential order of all 10 required sections" {
        $sections = @(
            @{ Name = "1. Banner"; Pattern = 'assets/corporate_grid\.svg' },
            @{ Name = "2. Typing Animation"; Pattern = 'readme-typing-svg\.demolab\.com' },
            @{ Name = "3. Identity"; Pattern = '(?m)^##[^#\n]*(IDENTITY|ENGENHARIA|MINDSET)' },
            @{ Name = "4. Evolution Line"; Pattern = '(?m)^##[^#\n]*(EVOLUTION LINE|LINHA DE EVOLUÇÃO)' },
            @{ Name = "5. Systems Architecture Table"; Pattern = '(?m)^##[^#\n]*(SYSTEMS ARCHITECTURE|SISTEMAS EM DESTAQUE)' },
            @{ Name = "6. Network Map Inline"; Pattern = 'assets/network_map\.svg' },
            @{ Name = "7. Interactive Systems Table"; Pattern = '(?m)^##[^#\n]*(INTERACTIVE SYSTEMS)' },
            @{ Name = "8. Technical Arsenal Badges"; Pattern = '(?m)^##[^#\n]*(TECHNICAL ARSENAL|ARSENAL TECNOLÓGICO)' },
            @{ Name = "9. System Telemetry"; Pattern = '(?m)^##[^#\n]*(SYSTEM TELEMETRY|TELEMETRIA)' },
            @{ Name = "10. Footer Wave"; Pattern = 'capsule-render\.vercel\.app[^"]*section=footer' }
        )

        $lastPos = -1
        $prevName = ""

        foreach ($s in $sections) {
            $m = [regex]::Match($readmeContent, $s.Pattern)
            if (-not $m.Success) {
                throw "Section '$($s.Name)' matching pattern '$($s.Pattern)' is missing from README.md"
            }
            if ($m.Index -le $lastPos) {
                throw "Section '$($s.Name)' (index $($m.Index)) appears before previous section '$prevName' (index $lastPos)"
            }
            $lastPos = $m.Index
            $prevName = $s.Name
        }
        $true
    }

    Run-Test "4" "T4.02_SCENARIO_INTERACTIVE_SYSTEMS_PRECEDES_STATS" "Interactive Systems minigame table appears BEFORE telemetry & stats" {
        $interactiveIdx = $readmeContent.IndexOf("INTERACTIVE SYSTEMS")
        $statsIdx = $readmeContent.IndexOf("github-readme-stats")
        if ($interactiveIdx -eq -1) {
            throw "INTERACTIVE SYSTEMS section not found"
        }
        if ($statsIdx -eq -1) {
            throw "github-readme-stats not found"
        }
        if ($interactiveIdx -ge $statsIdx) {
            throw "INTERACTIVE SYSTEMS (index $interactiveIdx) appears after stats (index $statsIdx)"
        }
        $true
    }

    # Scenario 2: Algorithmic Verification of Signal Route Levels
    Run-Test "4" "T4.03_SCENARIO_SIGNAL_ROUTE_LEVEL3_SOLVABILITY" "Signal Route levels (including Level 3) are mathematically solvable" {
        $signalRoutePath = Join-Path $ProjectRoot "minigame\signal-route\index.html"
        $code = Get-Content -Path $signalRoutePath -Raw
        $match = [regex]::Match($code, 'LEVELS\s*=\s*(\[[\s\S]*?\]);')
        if (-not $match.Success) {
            throw "Could not extract LEVELS array"
        }

        # Run node verification script for planar BFS/DFS solvability
        $nodeScript = @"
const LEVELS = $($match.Groups[1].Value);

function solve(level) {
  const size = level.size;
  const pairs = level.pairs;
  const grid = Array.from({length: size}, () => Array(size).fill(-1));
  pairs.forEach((p, idx) => {
    const a = p.a || p[0];
    const b = p.b || p[1];
    grid[a[0]][a[1]] = idx;
    grid[b[0]][b[1]] = idx;
  });

  function search(pairIdx, r, c) {
    if (pairIdx === pairs.length) return true;
    const target = pairs[pairIdx].b || pairs[pairIdx][1];
    const dirs = [[0,1],[1,0],[0,-1],[-1,0]];
    for (const [dr, dc] of dirs) {
      const nr = r + dr, nc = c + dc;
      if (nr < 0 || nr >= size || nc < 0 || nc >= size) continue;
      if (nr === target[0] && nc === target[1]) {
        if (pairIdx + 1 === pairs.length) return true;
        const nextStart = pairs[pairIdx + 1].a || pairs[pairIdx + 1][0];
        if (search(pairIdx + 1, nextStart[0], nextStart[1])) return true;
      } else if (grid[nr][nc] === -1) {
        grid[nr][nc] = pairIdx;
        if (search(pairIdx, nr, nc)) return true;
        grid[nr][nc] = -1;
      }
    }
    return false;
  }

  const start = pairs[0].a || pairs[0][0];
  return search(0, start[0], start[1]);
}

let allSolvable = true;
LEVELS.forEach((lvl, i) => {
  const solvable = solve(lvl);
  if (!solvable) {
    allSolvable = false;
    process.stderr.write('Level ' + (i+1) + ' is unsolvable\n');
  }
});
if (!allSolvable) process.exit(1);
process.exit(0);
"@

        $tempScript = [System.IO.Path]::GetTempFileName() + ".js"
        Set-Content -Path $tempScript -Value $nodeScript -Encoding utf8
        try {
            $nodeResult = Start-Process -FilePath "node" -ArgumentList "`"$tempScript`"" -NoNewWindow -Wait -PassThru
            if ($nodeResult.ExitCode -ne 0) {
                throw "Signal Route puzzle solvability verification failed for one or more levels"
            }
        }
        finally {
            if (Test-Path $tempScript) { Remove-Item $tempScript -Force }
        }
        $true
    }

    # Scenario 3: Color Protocol Scoring Calculation
    Run-Test "4" "T4.04_SCENARIO_COLOR_PROTOCOL_SCORING_LOGIC" "Color Protocol score formula calculates: 100 - avgChannelDistance bounded at 0" {
        $colorProtocolPath = Join-Path $ProjectRoot "minigame\color-protocol\index.html"
        $content = Get-Content -Path $colorProtocolPath -Raw
        $hasDist = ($content -match 'Math\.abs\([^)]+\)\s*\+\s*Math\.abs\([^)]+\)\s*\+\s*Math\.abs\([^)]+\)') -or ($content -match 'calcScore|avgChannelDistance')
        $has100Minus = ($content -match '100\s*-\s*dist') -or ($content -match '100\s*-\s*avg')
        $hasMaxZero = ($content -match 'Math\.max\(\s*0\s*,') -or ($content -match 'sc\s*<\s*0\s*\?\s*0')
        if (-not ($hasDist -and $has100Minus -and $hasMaxZero)) {
            throw "Color Protocol does not implement standard scoring formula 100 - avgChannelDistance with lower bound 0"
        }
        $true
    }

    # Scenario 4: Web Audio API Tone Synthesis
    Run-Test "4" "T4.05_SCENARIO_AUDIO_BREACH_SYNTHESIS" "Audio Breach instantiates Web Audio API with oscillators and gain envelopes" {
        $audioBreachPath = Join-Path $ProjectRoot "minigame\audio-breach\index.html"
        $content = Get-Content -Path $audioBreachPath -Raw
        $hasContext = ($content -match 'AudioContext|webkitAudioContext')
        $hasOscillator = ($content -match 'createOscillator\(\)')
        $hasGain = ($content -match 'createGain\(\)')
        $hasEnvelope = ($content -match 'linearRampToValueAtTime|setValueAtTime')
        if (-not ($hasContext -and $hasOscillator -and $hasGain -and $hasEnvelope)) {
            throw "Audio Breach is missing core Web Audio API synthesis components"
        }
        $true
    }

    # Scenario 5: Task Triage Animation & Gameplay Loop
    Run-Test "4" "T4.06_SCENARIO_TASK_TRIAGE_GAMEPLAY_LOOP" "Task Triage implements requestAnimationFrame game loop and placement scoring" {
        $taskTriagePath = Join-Path $ProjectRoot "minigame\task-triage\index.html"
        $content = Get-Content -Path $taskTriagePath -Raw
        $hasLoop = ($content -match 'requestAnimationFrame')
        $hasScoreInc = ($content -match 'score\s*\+=\s*10|score\s*\+=\s*correct')
        $hasScoreDec = ($content -match 'score\s*-=\s*5|score\s*=\s*Math\.max\([^)]*score\s*-\s*5|score\s*\+=\s*-5|penalty')
        if (-not ($hasLoop -and $hasScoreInc -and $hasScoreDec)) {
            throw "Task Triage is missing game loop or +10/-5 scoring logic"
        }
        $true
    }

    # Scenario 6: Git Tree & Remote Health
    Run-Test "4" "T4.07_SCENARIO_GIT_STATUS_AND_REMOTE" "Git remote origin is configured and repository is ready for publish" {
        $remotes = git remote -v
        if (-not ($remotes -match 'adrielhs/adrielhs')) {
            throw "Git remote origin is not pointing to adrielhs/adrielhs"
        }
        $true
    }
}

# ==============================================================================
# TEST SUMMARY REPORT
# ==============================================================================
Write-Host ""
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host " E2E TEST EXECUTION SUMMARY" -ForegroundColor Cyan
Write-Host "================================================================================" -ForegroundColor Cyan
Write-Host ""

$tiers = @("1", "2", "3", "4")
foreach ($t in $tiers) {
    $stat = $Script:TierStats[$t]
    $color = if ($stat.Failed -gt 0) { "Red" } elseif ($stat.Passed -gt 0) { "Green" } else { "DarkGray" }
    $title = switch ($t) {
        "1" { "Tier 1: Feature Coverage (R1, R4, R3, R2)" }
        "2" { "Tier 2: Boundary & Corner Cases" }
        "3" { "Tier 3: Cross-Feature Combinations" }
        "4" { "Tier 4: Real-World Workloads & Scenarios" }
    }
    Write-Host ("  {0,-42} : {1,2} Total | {2,2} Passed | {3,2} Failed | {4,2} Skipped" -f $title, $stat.Total, $stat.Passed, $stat.Failed, $stat.Skipped) -ForegroundColor $color
}

Write-Host "  ------------------------------------------------------------------------------" -ForegroundColor DarkGray
$overallColor = if ($Script:FailedTests -gt 0) { "Red" } else { "Green" }
Write-Host ("  {0,-42} : {1,2} Total | {2,2} Passed | {3,2} Failed | {4,2} Skipped" -f "OVERALL SUITE STATUS", $Script:TotalTests, $Script:PassedTests, $Script:FailedTests, $Script:SkippedTests) -ForegroundColor $overallColor
Write-Host ""

if ($Script:Failures.Count -gt 0) {
    Write-Host "--- FAILED ASSERTIONS SUMMARY ---" -ForegroundColor Red
    foreach ($fail in $Script:Failures) {
        Write-Host "  [Tier $($fail.Tier)] $($fail.Id) - $($fail.Description)" -ForegroundColor White
        Write-Host "           $($fail.Error)" -ForegroundColor Yellow
    }
    Write-Host ""
    Write-Host "SUITE RESULT: FAILED ($($Script:FailedTests) failed assertions)" -ForegroundColor Red
    exit $Script:FailedTests
} else {
    Write-Host "SUITE RESULT: 100% PASS (All $($Script:PassedTests) executed tests passed)" -ForegroundColor Green
    exit 0
}
