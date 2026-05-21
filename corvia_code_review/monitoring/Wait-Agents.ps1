# Wait for Phase 2 agents to complete
# Usage: .\Wait-Agents.ps1 -Timeout 600 -Agents "ad18b41a80c0d1de0","a842e402b5e13aa86","aee5e5ec6b0c44dcc"

param(
    [int]$Timeout = 600,  # Default 10 minutes
    [string[]]$Agents = @("ad18b41a80c0d1de0", "a842e402b5e13aa86", "aee5e5ec6b0c44dcc"),
    [int]$CheckInterval = 5
)

$tempDir = $env:CLAUDE_TEMP_DIR
if (-not $tempDir) {
    $tempDir = "C:\Users\KEVIN_~1\AppData\Local\Temp\claude\D--repo-skills-and-agent\8a256f4a-6262-4b86-8028-558f40627c84\tasks"
}

Write-Host "Waiting for Phase 2 agents to complete (timeout: ${Timeout}s)..." -ForegroundColor Cyan
Write-Host "Agents: $($Agents -join ', ')" -ForegroundColor Cyan
Write-Host ""

$startTime = Get-Date

while ($true) {
    $now = Get-Date
    $elapsed = [int]($now - $startTime).TotalSeconds

    # Check timeout
    if ($elapsed -gt $Timeout) {
        Write-Host "TIMEOUT: Agents did not complete within $Timeout seconds" -ForegroundColor Red
        exit 1
    }

    # Check each agent status
    $allDone = $true
    foreach ($agent in $Agents) {
        $outputFile = Join-Path $tempDir "$agent.output"

        if (Test-Path $outputFile) {
            $size = (Get-Item $outputFile).Length
            $sizeStr = "{0,6}" -f $size
            Write-Host "[$agent] $sizeStr bytes | Elapsed: ${elapsed}s" -ForegroundColor Green

            if ($size -eq 0) {
                $allDone = $false
            }
        } else {
            Write-Host "[$agent] Waiting to start... | Elapsed: ${elapsed}s" -ForegroundColor Yellow
            $allDone = $false
        }
    }

    if ($allDone) {
        Write-Host ""
        Write-Host "✅ All agents have completed!" -ForegroundColor Green
        exit 0
    }

    Write-Host "---"
    Start-Sleep -Seconds $CheckInterval
}
