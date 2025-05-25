Describe "Darbot.NLWeb module" -Tags "CI" {
    It "Get-NLWebContent function is available" {
        Get-Command Get-NLWebContent | Should -Not -BeNullOrEmpty
    }

    It "Test-NLWebConnection returns false for invalid URI" {
        Test-NLWebConnection -Uri 'http://invalid.invalid' | Should -BeFalse
    }
}
