param(
    $ComputerName,
    [System.Management.Automation.PSCredential]$Credential
)

Describe "Verify Active Directory Node Domain Controller {$ComputerName}" -Tags @('Operational', 'Nodes') {
    Context "tutaj cos bedzie}" {
        IT "tutaj tez"{
            $true | Should -Be True
        }
    }
}