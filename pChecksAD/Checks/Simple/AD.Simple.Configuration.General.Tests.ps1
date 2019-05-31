param(
    [System.Management.Automation.PSCredential]$Credential,
    [System.Collections.Hashtable]$BaselineConfiguration
)

$newpChecksBaselineADSplat = @{
    TestTarget = 'General'
}
if ($PSBoundParameters.ContainsKey('Credential')) {
    $newpChecksBaselineADSplat.Credential = $Credential
}
$CurrentConfiguration = (New-pChecksBaselineAD @newpChecksBaselineADSplat).General
$BaselineGeneralConfiguration = $BaselineConfiguration.General


Describe "Verify Active Directory Forest [Current General] configuration match [Baseline]" -Tags @('Configuration','Configuration-General','Configuration-Forest') {
    Context "Verify Forest {$($CurrentConfiguration.Name)} basic settings match baseline" {
        It "Current Forest Mode {$($CurrentConfiguration.ForestMode)} match Baseline" {
            $CurrentConfiguration.ForestMode | Should -Be $BaselineGeneralConfiguration.ForestMode
        }
        @($CurrentConfiguration.FSMORoles).ForEach{
            It "Current Forest FSMO Role [SchemaMaster] match baseline" {
                $PSItem.SchemaMaster | Should -Be $BaselineGeneralConfiguration.FSMORoles.SchemaMaster
            }
            It "Current Forest FSMO Role [DomainNamingMaster] match baseline" {
                $PSItem.DomainNamingMaster | Should -Be $BaselineGeneralConfiguration.FSMORoles.DomainNamingMaster
            }
        }
    }
}
Describe "Verify Active Directory Forest [Current Domains] configuration match [Baseline]" -Tags @('Configuration','Configuration-Domains','Configuration-Forest') {
    Context "Verify Current Domains in Forest {$($CurrentConfiguration.Name)} match baseline" {
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [ChildDomains] match baseline" {
            Compare-Object -ReferenceObject $CurrentConfiguration.Domains.ChildDomains -DifferenceObject $BaselineGeneralConfiguration.Domains.ChildDomains |
                Should -BeNullOrEmpty
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainMode] match baseline" {
            $CurrentConfiguration.Domains.DomainMode | Should -Be $BaselineGeneralConfiguration.Domains.DomainMode
        }
        @($CurrentConfiguration.Domains.FSMORoles).ForEach{
            It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} FSMO Role [PDCEmulator] match baseline" {
                $PSItem.PDCEmulator | Should -Be $BaselineGeneralConfiguration.Domains.FSMORoles.PDCEmulator
            }
            It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} FSMO Role [InfrastructureMaster] match baseline" {
                $PSItem.InfrastructureMaster | Should -Be $BaselineGeneralConfiguration.Domains.FSMORoles.InfrastructureMaster
            }
            It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} FSMO Role [RIDMaster] match baseline" {
                $PSItem.RIDMaster | Should -Be $BaselineGeneralConfiguration.Domains.FSMORoles.RIDMaster
            }
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [ReadOnlyReplicaDirectoryServers] match baseline" {
            Compare-Object -ReferenceObject $CurrentConfiguration.Domains.ReadOnlyReplicaDirectoryServers -DifferenceObject $BaselineGeneralConfiguration.Domains.ReadOnlyReplicaDirectoryServers |
                Should -BeNullOrEmpty
        }
        @($CurrentConfiguration.Domains.DHCPServers).Foreach{
            It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DHCP Server] {$PSItem} should match baseline" {
                $PSItem | Should -BeIn $BaselineGeneralConfiguration.Domains.DHCPServers
            }
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - LockoutObservationWindow] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.LockoutObservationWindow | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.LockoutObservationWindow
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - MinPasswordLength] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.MinPasswordLength | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.MinPasswordLength
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - ComplexityEnabled] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.ComplexityEnabled | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.ComplexityEnabled
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - LockoutDuration] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.LockoutDuration | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.LockoutDuration
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - MinPasswordAge] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.MinPasswordAge | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.MinPasswordAge
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - PasswordHistoryCount] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.PasswordHistoryCount | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.PasswordHistoryCount
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - LockoutThreshold] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.LockoutThreshold | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.LockoutThreshold
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - MaxPasswordAge] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.MaxPasswordAge | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.MaxPasswordAge
        }
        It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} [DomainDefaultPasswordPolicy - ReversibleEncryptionEnabled] match baseline" {
            $CurrentConfiguration.Domains.DomainDefaultPasswordPolicy.ReversibleEncryptionEnabled | Should -Be $BaselineGeneralConfiguration.Domains.DomainDefaultPasswordPolicy.ReversibleEncryptionEnabled
        }
        @($CurrentConfiguration.Domains.HighGroups).ForEach{
            $currentHighGroup = $PSItem
            $BaselineHighGroup = $BaselineGeneralConfiguration.Domains.HighGroups | Where-Object {$PSItem.Name -eq $currentHighGroup.Name}
            It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} HighGroup {$($currentHighGroup.Name)} [Name] match baseline" {
                $currentHighGroup.Name | Should -Be $BaselineHighGroup.Name
            }
            It "Current Domain {$($CurrentConfiguration.Domains.DNSRoot)} HighGroup {$($currentHighGroup.Name)} [Members] match baseline" {
                $currentHighGroup.Members | Should -BeIn $BaselineHighGroup.Members
            }
        }
    }
}
Describe "Verify Active Directory Forest [Current Sites] configuration match [Baseline]" -Tags @('Configuration','Configuration-Sites','Configuration-Forest') {
    Context "Verify Sites in Forest {$($CurrentConfiguration.Name)} match baseline" {
        foreach ($site in  $CurrentConfiguration.Sites) {
            $baselineSite = $BaselineGeneralConfiguration.Sites | Where-Object {$PSItem.Name -eq $site.Name}
            It "Site {$($site.Name)} [Name] match baseline" {
                $site.Name | Should -Be $baselineSite.Name
            }
            It "Site {$($site.Name)} [Subnets] match baseline" {
                Compare-Object -ReferenceObject $site.Subnets -DifferenceObject $baselineSite.Subnets |
                    Should -BeNullOrEmpty
            }
            It "Site {$($site.Name)} [Servers] match baseline" {
                Compare-Object -ReferenceObject $site.Servers -DifferenceObject $baselineSite.Servers |
                    Should -BeNullOrEmpty
            }
            It "Site {$($site.Name)} [Location] match baseline" {
                $site.Location | Should -Be $baselineSite.Location
            }
            It "Site {$($site.Name)} [AdjacentSites] match baseline" {
                Compare-Object -ReferenceObject $site.AdjacentSites -DifferenceObject $baselineSite.AdjacentSites |
                    Should -BeNullOrEmpty
            }
            It "Site {$($site.Name)} [BridgeheadServers] match baseline" {
                Compare-Object -ReferenceObject $site.BridgeheadServers -DifferenceObject $baselineSite.BridgeheadServers |
                    Should -BeNullOrEmpty
            }
        }
    }
}
Describe "Verify Active Directory Forest [Current Trusts] configuration match [Baseline]" -Tags @('Configuration','Configuration-Trusts','Configuration-Forest') {
    Context "Verify Trusts in Forest {$($CurrentConfiguration.Name)} match baseline" {
        foreach ($trust in  $CurrentConfiguration.Trusts) {
            $baselineTrust = $BaselineGeneralConfiguration.Trusts | Where-Object {$PSItem.Name -eq $trust.Name}
            It "Trust {$($trust.Name)} [Name] match baseline" {
                $trust.Name | Should -Be $baselineTrust.Name
            }
            It "Trust {$($trust.Name)} [Direction] match baseline" {
                $trust.Direction | Should -Be $baselineTrust.Direction
            }
        }
    }
}
Describe "Verify Active Directory Forest [Current Global Catalogs] configuration match [Baseline]" -Tags @('Configuration','Configuration-GlobalCatalogs','Configuration-Forest') {
    Context "Verify Global Catalogs in Forest {$($CurrentConfiguration.Name)} match baseline" {
        foreach ($gc in  $CurrentConfiguration.GlobalCatalogs) {
            $baselineGC = $BaselineGeneralConfiguration.GlobalCatalogs | Where-Object {$PSItem.Name -eq $gc.Name}
            It "GlobalCatalog {$($gc.Name)} [Name] match baseline" {
                $gc.Name | Should -Be $baselineGC.Name
            }
            It "GlobalCatalog {$($gc.Name)} [OSVersion] match baseline" {
                $gc.OSVersion | Should -Be $baselinegc.OSVersion
            }
            It "GlobalCatalog {$($gc.Name)} [IPAddress] match baseline" {
                $gc.IPAddress | Should -Be $baselinegc.IPAddress
            }
            It "GlobalCatalog {$($gc.Name)} [SiteName] match baseline" {
                $gc.SiteName | Should -Be $baselinegc.SiteName
            }
            It "GlobalCatalog {$($gc.Name)} [Partitions] match baseline" {
                Compare-Object -ReferenceObject $gc.Partitions -DifferenceObject $baselineGC.Partitions |
                    Should -BeNullOrEmpty
            }
        }
    }
}