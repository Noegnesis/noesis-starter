function Invoke-Doctor {
    $missing = 0
    foreach ($tool in @('git', 'claude')) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) { Write-Host "  OK   $tool" }
        else { Write-Host "  FAIL $tool not found"; $missing++ }
    }
    # Resolve Python once: python3, python, or the py launcher. setup.ps1's pip
    # step already falls back to `py -m pip`, so a py-only machine is fully
    # supported -- reporting it missing would send a user to install Python they
    # already have. The registry check below reuses this same resolution.
    #
    # Presence is not proof it runs: Windows' App Execution Alias stubs for
    # python3/python resolve on PATH, open the Microsoft Store, and exit 9009.
    # Probe each candidate before trusting it -- otherwise this would print a
    # false "OK python (python3.exe)" on a Python-less Windows box.
    $ovPy = $null
    foreach ($c in @('python3', 'python', 'py')) {
        $cand = Get-Command $c -ErrorAction SilentlyContinue
        if ($cand) {
            & $cand.Source -c "pass" 2>$null | Out-Null
            if ($LASTEXITCODE -eq 0) { $ovPy = $cand; break }
        }
    }
    if ($ovPy) { Write-Host "  OK   python ($($ovPy.Name))" }
    else { Write-Host "  FAIL python not found"; $missing++ }
    # Advisory, never counted: absent just means Obsidian has not launched yet.
    $ov = Join-Path $PSScriptRoot "..\scripts\obsidian_vault.py"
    if ($ovPy -and (Test-Path $ov)) {
        $reg = $null
        try { $reg = & $ovPy.Source $ov --registry-path 2>$null } catch { $reg = $null }
        if ($reg -and (Test-Path $reg)) {
            Write-Host "  OK   Obsidian vault registry ($reg)"
        } else {
            Write-Host "  WARN No obsidian.json yet -- setup will create it (normal before Obsidian's first launch)"
        }
    }
    return $missing
}
