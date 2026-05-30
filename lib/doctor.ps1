function Invoke-Doctor {
    $missing = 0
    foreach ($tool in @('git','python','claude')) {
        if (Get-Command $tool -ErrorAction SilentlyContinue) { Write-Host "  OK   $tool" }
        else { Write-Host "  FAIL $tool not found"; $missing++ }
    }
    return $missing
}
