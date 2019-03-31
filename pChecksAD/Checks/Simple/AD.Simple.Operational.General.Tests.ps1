param(
    $ComputerName,
    [System.Management.Automation.PSCredential]$Credential
)
$queryCheckParams = @{
    Server     = $ComputerName
    Credential = $Credential
}
$CurrentConfiguration = New-BaselineAD @PSBoundParameters
Describe "Verify Active Directory services from domain controller {$($CurrentConfiguration.General.Name)}" -Tags @('Operational', 'General') {
    @($CurrentConfiguration.General.GlobalCatalogs.Name).Foreach{
        Context "Verify {$PSitem} connectivity in forest {$($CurrentConfiguration.General.Name)}" {
            it "Verify Domain Controller {$PSItem} is [online]" {
                Test-Connection $PSItem -Count 1 -ErrorAction SilentlyContinue |
                    Should -Be $true
            }
            it "Verify DNS on Domain Controller {$PSItem} resolves current host name" {
                Resolve-DnsName -Name $($env:computername) -Server $PSItem |
                    Should -Not -BeNullOrEmpty
            }
            it "Verify Domain Controller {$PSItem} responds to PowerShell Queries" {
                Get-ADDomainController @queryCheckParams |
                    Should -Not -BeNullOrEmpty
            }
            it "Verify Domain Controller {$PSItem} has no replication failures" {
                (Get-ADReplicationFailure -Target $PSItem -Credential $Credential) | ForEach-Object {
                    $PSItem.FailureCount |
                        Should -Be 0
                }
            }
        }
    }
}
Describe "Verify domains configuration in forest {$($CurrentConfiguration.General.Name)}" -Tags @('Operational', 'Domains') {
    @($CurrentConfiguration.General.Domains).Foreach{
        Context "Verify Crucial Groups membership" {
            @($PSItem.HighGroups).Foreach{

                it "Verify [$($PSItem.Name)] group should only contain [Administrator] account" {
                    Get-ADGroupMember -Identity $PSItem.Name @queryCheckParams | Where-Object { $PSItem.samaccountname -ne 'Administrator' } |
                        Should -BeNullOrEmpty
                }
            }
        }
        Context "Verify DHCP servers configured" {
            it "Verify at least one DHCP authorized in domain" {
                $PSItem.DHCPservers |
                    Should -Not -BeNullOrEmpty -Because 'It is good to have at least one DHCP authorized'
            }
            @($PSItem.DHCPServers).Foreach{
                it "Verify dhcp server {$($PSItem)} is reachable" {
                    Test-Connection $PSItem -Count 1 -ErrorAction SilentlyContinue |
                        Should -Be $true -Because 'It is good to have at least one DHCP reacheable'
                }
            }
        }
    }
}
Describe "Verify sites configuration in forest {$($CurrentConfiguration.General.Name)}" -Tags @('Operational', 'Sites') {
    @($CurrentConfiguration.General.Sites).Foreach{
        Context "Verify site {$($PSItem.Name)} configuration" {
            It "Should have at least one subnet configured" {
                $PSItem.Subnets |
                    Should -not -BeNullOrEmpty
            }
        }
    }
}
<#
Describe "Verify backup status in forest {$($CurrentConfiguration.General.Name)}" -Tags @('Operational', 'Backup') {
    @($CurrentConfiguration.General.Backup).Foreach{
        It  "Verify Global Catalog {$($PSItem.DomainController)} last backup time should be less than [7] days ago" {
            [datetime]$PSItem.LastOriginatingChangeTime |
                Should -BeGreaterOrEqual ((Get-Date).AddDays(-7))
        }

    }
}
#>
Describe "Verify domains configuration in forest {$($CurrentConfiguration.General.Name)}" -Tags @('Configuration', 'Domains') {
    @($CurrentConfiguration.General.Domains).Foreach{
        $DomainDefaultPasswordPolicy = $PSItem.DomainDefaultPasswordPolicy
        Context "Verify default Password Policy for domain {$($PSItem.DNSRoot)}" {
            it "Password complexity should be [Enabled]" {
                $DomainDefaultPasswordPolicy.ComplexityEnabled |
                    Should -Be $true -Because 'It is recommended to have strong passwords'
            }
            it "Minimum Password Length should be greater than [7]" {
                $DomainDefaultPasswordPolicy.MinPasswordLength |
                    Should -BeGreaterThan 7 -Because 'It is not good to have short passwords'
            }
            it "Lockout Treshold should be greater than [5]" {
                $DomainDefaultPasswordPolicy.LockoutThreshold |
                    Should -BeGreaterThan 5 -Because 'It delays brute force attempts'
            }
            it "Lockout Duration should be greater than [10] minutes" {
                ([timespan]($DomainDefaultPasswordPolicy.LockoutDuration)).TotalMinutes |
                    Should -BeGreaterThan 10 -Because 'It delays brute force attempts'
            }
            it "Lockout Observation Window should be greater than [10] minutes" {
                ([timespan]($DomainDefaultPasswordPolicy.LockoutObservationWindow)).TotalMinutes |
                    Should -BeGreaterThan 10 -Because 'It delays brute force attempts'
            }
            it "Minimum Password Age should be greater than [0]" {
                $DomainDefaultPasswordPolicy.MinPasswordAge |
                    Should -BeGreaterThan 0 -Because 'It is not good to allow changing passwords more than once a day'
            }
            it "Password History Count should be greater than [0]" {
                $DomainDefaultPasswordPolicy.PasswordHistoryCount |
                    Should -BeGreaterThan 0 -Because "It is not safe not to remember previous passwords"
            }
            it "Reversible Encryption should be [Disabled]" {
                $DomainDefaultPasswordPolicy.ReversibleEncryptionEnabled |
                    Should -Be $false -Because "It's not good to store password with reversible encryption"
            }
        }
    }
}