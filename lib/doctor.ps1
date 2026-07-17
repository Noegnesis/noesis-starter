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
        # -CommandType Application excludes aliases/functions from a user profile,
        # whose .Source is empty -- `& '' -c ...` never launches, so it raises a
        # non-terminating error and leaves $LASTEXITCODE untouched, letting an
        # earlier winget/pip call's 0 pass a bogus candidate.
        # -CommandType Application excludes aliases/functions (whose .Source is
        # empty, so the probe below would never launch) -- but it also flips
        # Get-Command from first-match to ALL matches, making .Source an ARRAY
        # whenever two pythons are on PATH (the Store alias + a real install is
        # the default Windows layout). Select-Object -First 1 restores single
        # -object semantics so the probe can actually run.
        $cand = Get-Command $c -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
        if ($cand) {
            # Probe the module's real contract (secrets, Python 3.6+), not
            # merely that the interpreter starts -- obsidian_vault.py imports it.
            # If the & throws, $LASTEXITCODE keeps its previous value -- and
            # winget/pip seeded 0 earlier in this process, so a throw would read
            # as success. Poison it first: only a real run can clear it. Must be
            # $global: -- this is inside a function, and a bare `$LASTEXITCODE =`
            # creates a LOCAL variable that shadows the automatic one. The native
            # call below still updates the real (global) $LASTEXITCODE, but a
            # plain read here would see the shadowed local instead, so a working
            # python would read back as the poisoned failure value forever.
            $global:LASTEXITCODE = 1
            & $cand.Source -c "import secrets" 2>$null | Out-Null
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
