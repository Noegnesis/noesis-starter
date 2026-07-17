function Invoke-Doctor {
    $missing = 0
    foreach ($tool in @('git','python','claude')) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) { Write-Host "  OK   $tool" }
        else { Write-Host "  FAIL $tool not found"; $missing++ }
    }
    # Advisory, never counted: absent just means Obsidian has not launched yet.
    # 'py' (the Windows launcher) is included for the same reason setup.ps1's
    # Get-NoesisPython includes it: this installer's own pip step already falls
    # back to `py -m pip`, so a py-only machine is a supported configuration.
    $ovPy = $null
    foreach ($c in @('python3', 'python', 'py')) {
        $ovPy = Get-Command $c -ErrorAction SilentlyContinue
        if ($ovPy) { break }
    }
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
