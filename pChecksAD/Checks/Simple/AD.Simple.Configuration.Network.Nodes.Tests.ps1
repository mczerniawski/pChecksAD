param(
    [string]$ComputerName,
    [System.Management.Automation.PSCredential]$Credential,
    [System.Collections.Hashtable]$BaselineConfiguration
)

$pChecksSessionSplat = @{
    ComputerName = $ComputerName
    Name = "pChecks-$ComputerName"
}
if($PSBoundParameters.ContainsKey('Credential')){
    $pChecksSessionSplat.Credential = $Credential
}

$pChecksSession = New-PSSession @pChecksSessionSplat
$BaselineNodeConfiguration = $BaselineConfiguration.Nodes | Where-Object {$PSItem.ComputerName -match $ComputerName}
Describe "Verify [host] Server {$($BaselineNodeConfiguration.ComputerName)} Full Network Adapters (Physical) Configuration Status" -Tags @('Configuration','Network') {
  Context "Verify Network Adapter Properties"{
    $hostNICConfiguration = Get-pChecksNetAdapterConfiguration -Physical -PSSession $pChecksSession
    foreach ($NIC in $BaselineNodeConfiguration.NIC) {
      $currentNIC = $hostNICConfiguration | Where-Object {$PSItem.Name -eq $NIC.Name}
      if($NIC.MACAddress) {
        it "Verify [host] NIC {$($NIC.Name)} MACAddress match [baseline]" {
          $currentNIC.MACAddress  | Should -Be $NIC.MACAddress
        }
      }
      if($null -ne $NIC.IPConfiguration.IPAddress) {
        it "Verify [host] NIC {$($NIC.Name)} IP Configuration: IPAddress match [baseline]" {
          $currentNIC.IPConfiguration.IPAddress | Should -Be $NIC.IPConfiguration.IPAddress
        }
        it "Verify [host] NIC {$($NIC.Name)} IP Configuration: DefaultGateway match [baseline]" {
          $currentNIC.IPConfiguration.DefaultGateway | Should -Be $NIC.IPConfiguration.DefaultGateway
        }
        it "Verify [host] NIC {$($NIC.Name)} IP Configuration: Prefix match [baseline]" {
          $currentNIC.IPConfiguration.PrefixLength | Should Be $NIC.IPConfiguration.PrefixLength
        }
        it "Verify [host] NIC {$($NIC.Name)} IP Configuration: DNSClientServerAddress match [baseline]" {
          $currentNIC.IPConfiguration.DNSClientServerAddress | Should -BeIn $NIC.IPConfiguration.DNSClientServerAddress
        }
      }
      if($NIC.NetLBFOTeam) {
        it "Verify [host] NIC {$($NIC.Name)} Teaming status match [baseline]" {
          $currentNIC.Name   | Should -BeIn $NIC.Name
        }
      }
      if($NIC.NetAdapterVMQ.Enabled) {
        $propertyKeys = $NIC.NetAdapterVMQ.Keys
        foreach ($key in $propertyKeys) {
          IT "Verify [host] NIC {$($NIC.Name)} NetAdapterVMQ Property {$key} - {$($NIC.NetAdapterVMQ[$Key])} match [baseline]" {
            $currentNIC.NetAdapterVMQ.$key | Should Be $NIC.NetAdapterVMQ[$Key]
          }
        }
      }
      if($NIC.NetAdapterQoS.Enabled) {
        $propertyKeys = $NIC.NetAdapterQoS.Keys
        foreach ($key in $propertyKeys) {
          IT "Verify [host] NIC {$($NIC.Name)} NetAdapterQoS Property {$key} - {$($NIC.NetAdapterQoS[$Key])} match [baseline]" {
            $currentNIC.NetAdapterQoS.$key | Should Be $NIC.NetAdapterQoS[$Key]
          }
        }
      }
      if($NIC.NetAdapterRSS.Enabled) {
        $propertyKeys = $NIC.NetAdapterRSS.Keys
        foreach ($key in $propertyKeys) {
          IT "Verify [host] NIC {$($NIC.Name)} NetAdapterRSS Property {$key} - {$($NIC.NetAdapterRSS[$Key])} match [baseline]" {
            $currentNIC.NetAdapterRSS.$key | Should Be $NIC.NetAdapterRSS[$Key]
          }
        }
      }
      if($NIC.NetAdapterRDMA.Enabled) {
        $propertyKeys = $NIC.NetAdapterRDMA.Keys
        foreach ($key in $propertyKeys) {
          IT "Verify [host] NIC {$($NIC.Name)} NetAdapterRDMA Property {$key} - {$($NIC.NetAdapterRDMA[$Key])} match [baseline]" {
            $currentNIC.NetAdapterRSS.$key | Should Be $NIC.NetAdapterRDMA[$Key]
          }
        }
      }
      if($NIC.NetAdapterAdvancedProperty){
        foreach ($property in $NIC.NetAdapterAdvancedProperty){
          IT "Verify [host] NIC {$($NIC.Name)} Advanced Property {$($property.RegistryKeyword)} match [baseline]" {
            $property.RegistryValue | Should -Be ($currentNIC.NetAdapterAdvancedProperty | Where-Object {$PSItem.RegistryKeyword -eq $property.RegistryKeyword}).RegistryValue
          }
        }
      }
    }
  }
}
Describe "Verify Server {$($BaselineNodeConfiguration.ComputerName)} Teaming Configuration Status" -Tags @('Configuration','Teaming','Network') {
  if($BaselineNodeConfiguration.Team){
    Context "Verify Network Team Configuration" {
      $hostTeamConfiguration = Get-pChecksTeamingConfiguration -PSSession $pChecksSession
      foreach ($cTeam in $BaselineNodeConfiguration.Team) {
        $currentTeam = $hostTeamConfiguration | Where-Object {$PSItem.Name -eq $cTeam.Name}
        it "Verify [host] Team {$($cTeam.Name)} exists" {
          $currentTeam | Should -Not -BeNullOrEmpty
        }
        it "Verify [host] Team {$($cTeam.Name)} name matches [baseline]" {
          $currentTeam | Should -Not -BeNullOrEmpty
        }
        it "Verify [host] Team {$($cTeam.Name)} TeamingMode match [baseline]" {
          $currentTeam.TeamingMode  | Should Be $cTeam.TeamingMode
        }
        it "Verify [host] Team {$($cTeam.Name)} LoadBalancingAlgorithm match [baseline]" {
          $currentTeam.LoadBalancingAlgorithm  | Should Be $cTeam.LoadBalancingAlgorithm
        }
        it "Verify [host] Team {$($cTeam.Name)} TeamMembers match [baseline]" {
          $currentTeam.Members | Should -BeIn $cTeam.Members
        }
      }
    }
  }
}
$pChecksSession | Remove-PSSession -ErrorAction SilentlyContinue