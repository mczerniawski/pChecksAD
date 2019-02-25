param(
  $POVFConfiguration,
  [System.Management.Automation.PSCredential]$POVFCredential
)
$queryParams = @{
  ComputerName = $POVFConfiguration.FSMORoles.SchemaMaster 
  Credential = $POVFCredential
}
$currentForestConfig = Get-POVFConfigurationAD @queryParams
Describe 'Verify [environment] Active Directory Forest configuration status' -Tags @('Forest','Configuration'){
  Context "Verify Forest {$($POVFConfiguration.Name)} Configuration" {
    it "Verify [host] Forest Name {$($POVFConfiguration.Name)} should match [baseline]" {
      $currentForestConfig.Name | Should -be $POVFConfiguration.Name
    }
    it "Verify [host] Forest Mode {$($POVFConfiguration.ForestMode)} should match [baseline]" {
      $currentForestConfig.ForestMode |
      Should -be $POVFConfiguration.ForestMode
    }
    it "Forest Root Domain {$($POVFConfiguration.RootDomain)}" {
      $currentForestConfig.RootDomain |
      Should -be $POVFConfiguration.RootDomain
    }
    it "Global Catalogs should match [baseline]" {
      $currentForestConfig.GlobalCatalogs | Should -BeIn $POVFConfiguration.GlobalCatalogs
    }
    it "DomainNaming Master - {$($POVFConfiguration.DomainNamingMaster)} should match [baseline]" {
      $currentForestConfig.FSMORoles.DomainNamingMaster | Should -Be $POVFConfiguration.FSMORoles.DomainNamingMaster
    }
    it "Schema Master - {$($POVFConfiguration.SchemaMaster)} should match [baseline]" {
      $currentForestConfig.FSMORoles.SchemaMaster | Should -Be $POVFConfiguration.FSMORoles.SchemaMaster
    }
  }
  Context 'Verify Sites Configuration' {
    it "Sites should match configuration" {
      $currentForestConfig.Sites | Should -BeIn $POVFConfiguration.Sites
    }
  }
  Context 'Verify Trusts Configuration' {
    if ($POVFConfiguration.Trusts) {
      foreach ($trust in $currentForestConfig.Trusts ){
        it "Trust with {$($trust.Name)} should match [baseline]" {
          $trust.Name | Should -BeIn $POVFConfiguration.Trusts.Name
        }
        it "Trust {$($trust.Name)} should be {$($POVFConfiguration.Trusts)} and match [baseline]" {
          $trust.Direction | Should -Be ($POVFConfiguration.Trusts | Where-Object {$PSItem.Name -eq $trust.Name}).Direction
        }
      }
    }
    else {
      it "There are no Trusts with this domain" {
        $true | should be $true
      }
    }
  }
}
Describe "Verify Domain Configuration" -Tags @('Domain','Configuration') { 
  foreach ($currentADdomain in $currentForestConfig.Domains) {
    $configADDomain = $POVFConfiguration.Domains | Where-Object {$PSItem.DNSRoot -eq $currentADdomain.DNSRoot }
    Context "Verify Domain {$($currentADDomain.DNSRoot)} Configuration" {
      it "Verify [DNSRoot] for Domain {$($currentADDomain.DNSRoot)} match [baseline]" {
        $currentADDomain.DNSRoot | Should -Be $configADDomain.DNSRoot
      }
      if($currentADDomain.ChildDomains){ 
        it "Verify [ChildDomains] for Domain {$($currentADDomain.DNSRoot)} match [baseline]" {
          $currentADDomain.ChildDomains | Should -BeIn $configADDomain.ChildDomains
        }
      }
      it "Verify [DomainMode] for Domain {$($currentADDomain.DNSRoot)} match [baseline]" {
        $currentADDomain.DomainMode | Should -Be $configADDomain.DomainMode
      }
      it "Verify FSMO Roles [InfrastructureMaster] for Domain {$($currentADDomain.DNSRoot)} match [baseline]" {
        $currentADDomain.FSMORoles.InfrastructureMaster | Should -Be $configADDomain.FSMORoles.InfrastructureMaster
      }
      it "Verify FSMO Roles [RIDMaster] for Domain {$($currentADDomain.DNSRoot)} match [baseline]" {
        $currentADDomain.FSMORoles.RIDMaster | Should -Be $configADDomain.FSMORoles.RIDMaster
      }
      it "Verify FSMO Roles [PDCEmulator] for Domain {$($currentADDomain.DNSRoot)} match [baseline]" {
        $currentADDomain.FSMORoles.PDCEmulator | Should -Be $configADDomain.FSMORoles.PDCEmulator
      }
      if($currentADDomain.ReadOnlyReplicaDirectoryServers){ 
        it "Verify [ReadOnlyReplicaDirectoryServers] for Domain {$($currentADDomain.DNSRoot)} match [baseline]"{
          $currentADDomain.ReadOnlyReplicaDirectoryServers | Should -BeIn $configADDomain.ReadOnlyReplicaDirectoryServers
        }
      }
      it "Verify [DHCPServers] for Domain {$($currentADDomain.DNSRoot)} match [baseline]" {
        $currentADDomain.DHCPServers | Should -BeIn $configADDomain.DHCPServers
      }
    }
    Context "Verify default Password Policy for domain {$($currentADDomain.DNSRoot)}" {
      it "Password [complexity] - {$($configADDomain.DomainDefaultPasswordPolicy.ComplexityEnabled)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.ComplexityEnabled | Should -Be $configADDomain.DomainDefaultPasswordPolicy.ComplexityEnabled
      }
      it "Password [LockoutDuration] - {$($configADDomain.DomainDefaultPasswordPolicy.LockoutDuration)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.LockoutDuration | Should -Be $configADDomain.DomainDefaultPasswordPolicy.LockoutDuration
      }
      it "Password [LockoutObservationWindow] - {$($configADDomain.DomainDefaultPasswordPolicy.LockoutObservationWindow)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.LockoutObservationWindow |Should -Be $configADDomain.DomainDefaultPasswordPolicy.LockoutObservationWindow
      }
      it "Password [LockoutThreshold] - {$($configADDomain.DomainDefaultPasswordPolicy.LockoutThreshold)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.LockoutThreshold | Should -Be $configADDomain.DomainDefaultPasswordPolicy.LockoutThreshold
      }
      it "Password [Minimum Age] - {$($configADDomain.DomainDefaultPasswordPolicy.MinPasswordAge)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.MinPasswordAge | Should -Be $configADDomain.DomainDefaultPasswordPolicy.MinPasswordAge
      }
      it "Password [Maxmimum Age] - {$($configADDomain.DomainDefaultPasswordPolicy.MaxPasswordAge)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.MaxPasswordAge | Should -Be $configADDomain.DomainDefaultPasswordPolicy.MaxPasswordAge
      }
      it "Password [Minimum Length] - {$($configADDomain.DomainDefaultPasswordPolicy.MinPasswordLength)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.MinPasswordLength | Should -Be $configADDomain.DomainDefaultPasswordPolicy.MinPasswordLength
      }
      it "Password [History Count] - {$($configADDomain.DomainDefaultPasswordPolicy.PasswordHistoryCount)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.PasswordHistoryCount | Should -Be $configADDomain.DomainDefaultPasswordPolicy.PasswordHistoryCount
      }
      it "Password [Reversible Encryption] - {$($configADDomain.DomainDefaultPasswordPolicy.ReversibleEncryptionEnabled)} should match [baseline]" {
        $currentADDomain.DomainDefaultPasswordPolicy.ReversibleEncryptionEnabled | Should -Be $configADDomain.DomainDefaultPasswordPolicy.ReversibleEncryptionEnabled 
      }
    }
    Context "Verify Crucial Groups membership for domain {$($currentADDomain.DNSRoot)}" {
      #foreach group from config
      foreach ($group in $currentADDomain.HighGroups) { 
        it "Verify {$($group.Name)} group [members] should match [baseline]" {
          $group.members | Should -BeIn ($configADDomain.HighGroups | Where-Object {$PSItem.Name -eq $group.Name}).Members
        }
      }
    }
  }
}