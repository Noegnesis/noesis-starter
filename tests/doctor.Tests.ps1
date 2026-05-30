. "$PSScriptRoot/../lib/doctor.ps1"

Describe "Invoke-Doctor" {
    It "returns 0 when all required tools resolve" {
        Mock Get-Command { [pscustomobject]@{ Name = 'x' } }
        Invoke-Doctor | Should -Be 0
    }
}

Describe "setup.ps1 hardening" {
    $raw = Get-Content "$PSScriptRoot/../setup.ps1" -Raw
    It "passes --accept-source-agreements on winget list checks" {
        ($raw | Select-String 'winget list[^\r\n]*--accept-source-agreements') | Should -Not -BeNullOrEmpty
    }
    It "exposes a -Check switch" {
        $raw | Should -Match '\[switch\]\s*\$Check'
    }
}
