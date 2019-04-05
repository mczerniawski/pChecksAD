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
$CurrentNodeConfiguration = $BaselineConfiguration.Nodes | Where-Object {$PSItem.ComputerName -match $ComputerName}
Describe "Verify Server {$($CurrentNodeConfiguration.ComputerName)} Roles Configuration Status" -Tags @('Configuration','Roles','Basic') {
  Context 'Verify Roles configuration' {
    $currentRoles = Get-pChecksRolesConfiguration -PSSession $pChecksSession
    if($CurrentNodeConfiguration.Roles.Present){
      it "Verify [host] role [Present] match configuration [baseline]" {
        $currentRoles.Present | Should -BeIn $CurrentNodeConfiguration.Roles.Present
      }
    }
    if($CurrentNodeConfiguration.Roles.Absent){
      it "Verify [host] role [Absent] match configuration [baseline]" {
        $currentRoles.Absent | Should -BeIn $CurrentNodeConfiguration.Roles.Absent
      }
    }
  }
}
$pChecksSession | Remove-PSSession -ErrorAction SilentlyContinue