param(
    [System.Management.Automation.PSCredential]$Credential
)

$newpChecksBaselineADSplat = @{
    TestTarget = 'General'
}
if ($PSBoundParameters.ContainsKey('Credential')) {
    $newpChecksBaselineADSplat.Credential = $Credential
}
$CurrentConfiguration = New-pChecksBaselineAD @newpChecksBaselineADSplat

Describe "Verify Active Directory services from domain controller {$($CurrentConfiguration.General.Name)}" -Tags @('Operational', 'General') {
    @($CurrentConfiguration.General.GlobalCatalogs.Name).Foreach{
        $queryCheckParams = @{
            Server = $PSitem
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $queryCheckParams.Credential = $Credential
        }
        Context "Verify {$PSitem} connectivity in forest {$($CurrentConfiguration.General.Name)}" {
            It "Verify Domain Controller {$PSItem} is [online]" {
                Test-Connection $PSItem -Count 1 -ErrorAction SilentlyContinue |
                Should -Be $true
            }
            It "Verify DNS on Domain Controller {$PSItem} resolves current host name" {
                Resolve-DnsName -Name $($env:computername) -Server $PSItem  |
                Should -Not -BeNullOrEmpty
            }
            It "Verify Domain Controller {$PSItem} responds to PowerShell Queries" {
                Get-ADDomainController @queryCheckParams |
                Should -Not -BeNullOrEmpty
            }
            It "Verify Domain Controller {$PSItem} has no replication failures" {
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
        $queryCheckParams = @{
            Server = $PSitem.FSMORoles.PDCEmulator
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $queryCheckParams.Credential = $Credential
        }
        Context "Verify Crucial Groups membership" {
            @($PSItem.HighGroups).Foreach{
                It "Verify [$($PSItem.Name)] group should only contain [Administrator] account" {
                    Get-ADGroupMember -Identity $PSItem.Name @queryCheckParams | Where-Object { $PSItem.samaccountname -ne 'Administrator' } |
                    Should -BeNullOrEmpty
                }
            }
        }
        Context "Verify DHCP servers configured" {
            It "Verify at least one DHCP authorized in domain" {
                $PSItem.DHCPservers |
                Should -Not -BeNullOrEmpty -Because 'It is good to have at least one DHCP authorized'
            }
            @($PSItem.DHCPServers).Foreach{
                It "Verify dhcp server {$($PSItem)} is reachable" {
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
Describe "Verify backup status in forest {$($CurrentConfiguration.General.Name)}" -Tags @('Operational', 'Backup') {
    @($CurrentConfiguration.General.Backup).Foreach{
        It  "Verify Global Catalog {$($PSItem.DomainController)} last backup time should be less than [7] days ago" {
            [datetime]$PSItem.LastOriginatingChangeTime |
            Should -BeGreaterOrEqual ((Get-Date).AddDays(-7))
        }

    }
}
Describe "Verify domains configuration in forest {$($CurrentConfiguration.General.Name)}" -Tags @('Operational', 'Password') {
    @($CurrentConfiguration.General.Domains).Foreach{
        $DomainDefaultPasswordPolicy = $PSItem.DomainDefaultPasswordPolicy
        Context "Verify default Password Policy for domain {$($PSItem.DNSRoot)}" {
            It "Password complexity should be [Enabled]" {
                $DomainDefaultPasswordPolicy.ComplexityEnabled |
                Should -Be $true -Because 'It is recommended to have strong passwords'
            }
            It "Minimum Password Length should be greater than [7]" {
                $DomainDefaultPasswordPolicy.MinPasswordLength |
                Should -BeGreaterThan 7 -Because 'It is not good to have short passwords'
            }
            It "Lockout Treshold should be greater than [5]" {
                $DomainDefaultPasswordPolicy.LockoutThreshold |
                Should -BeGreaterThan 5 -Because 'It delays brute force attempts'
            }
            It "Lockout Duration should be greater than [10] minutes" {
                ([timespan]($DomainDefaultPasswordPolicy.LockoutDuration)).TotalMinutes |
                Should -BeGreaterThan 10 -Because 'It delays brute force attempts'
            }
            It "Lockout Observation Window should be greater than [10] minutes" {
                ([timespan]($DomainDefaultPasswordPolicy.LockoutObservationWindow)).TotalMinutes |
                Should -BeGreaterThan 10 -Because 'It delays brute force attempts'
            }
            It "Minimum Password Age should be greater than [0]" {
                $DomainDefaultPasswordPolicy.MinPasswordAge |
                Should -BeGreaterThan 0 -Because 'It is not good to allow changing passwords more than once a day'
            }
            It "Password History Count should be greater than [0]" {
                $DomainDefaultPasswordPolicy.PasswordHistoryCount |
                Should -BeGreaterThan 0 -Because "It is not safe not to remember previous passwords"
            }
            It "Reversible Encryption should be [Disabled]" {
                $DomainDefaultPasswordPolicy.ReversibleEncryptionEnabled |
                Should -Be $false -Because "It's not good to store password with reversible encryption"

            }
        }
    }
}
Describe "Verify Optional Feature in forest {$($CurrentConfiguration.General.Name)}" -Tags @('Operational', 'OptionalFeature') {
    if ($CurrentConfiguration.General.ForestMode -match 'Windows2008R2' -OR $CurrentConfiguration.General.ForestMode -match 'Windows2016'){
        Context "Verify [Recycle Bin Feature] status" {
            IT "Should be [Enabled]" {
                (Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"' | Select-Object EnabledScopes) |
                Should -Not -BeNullOrEmpty
            }
        }
    }
}
#Describe "Verify configuration for DFSR" -Tags @('Operational', 'DFSR') {
   <#  $domainLevel =
    Get- DFSR state = Should Exist AD:\CN=Topology,CN=Domain System Volume,CN=DFSR-GlobalSettings,CN=System,DC=objectivity,DC=co,DC=uk>
    Get replication issues

   #>
#}

<#
Describe "Verify proper settings" {
    #if functional level 2008
    it "DFS Replication is set up" {

    }
    #if functional level 2008r2
    it "Recycle bin enabled" {
        Get-ADOptionalFeature -Filter 'name -like "Recycle Bin Feature"' | Select-Object EnabledScopes | Should -Not -BeNullOrEmpty
    }
    #if 2016
    it "DCs can support rolling of NTLM "


}
#>