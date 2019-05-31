param(
    [string]$ComputerName,
    [System.Management.Automation.PSCredential]$Credential
)

$pChecksSession = New-PSSession @PSBoundParameters

Describe "Verify Active Directory services on domain controller {$ComputerName)}" -Tags @('Operational', 'Nodes','Services') {
    Context "Verify necessary Services are running on DC - {$ComputerName}" {
        $Services = @('Active Directory Domain Services','Active Directory Web Services'
        'DFS Replication',
        'DNS Client', 'DNS server',
        'Group Policy Client',
        'Intersite Messaging',
        'Kerberos Key Distribution Center',
        'NetLogon',
        'Windows Time',
        'Workstation')
        $currentServices = Invoke-Command @pChecksSession -ScriptBlock {
            Get-Service -DisplayName $USING:Services | ForEach-Object {
                [pscustomobject]@{
                    Name = $PSItem.Name
                    Status = $PSItem.Status.ToString()
                    DisplayName = $PSItem.DisplayName
                    StartType = $PSItem.StartType.ToString()
                }
            }
        }
        @($currentServices).ForEach{
            IT "Service {$($PSItem.DisplayName)} should be running" {
                $PSItem.Status | Should -Be 'Running' -Because "This is a required service for a DC to operate properly"
            }
            IT "Service {$($PSItem.DisplayName)} should be set to automatic startup" {
                $PSItem.StartType | Should -Be 'Automatic' -Because "This service should start automaticaly"
            }
        }
    }
    Context "Verify Time Configuration on DC {$ComputerName}"{
        #All DCs should sync time with PDC emulator. PDC emulator should be set to external source
        $DomainInfo = Invoke-Command @pChecksSession -ScriptBlock { Get-ADDomain | Select-Object DNSRoot,PDCEmulator }
        if($ComputerName -match ($DomainInfo.PDCEmulator.Split('.') | Select-Object -First 1)){
            IT "PDC Emulator {$($DomainInfo.PDCEmulator)} should sync to external source"{
                $SourceNTPServer = Invoke-Command @pChecksSession -ScriptBlock { w32tm /query /source }
                $SourceNTPServer | Should -Not -Match $DomainInfo.DNSRoot
            }
        }
        else{
            IT "Non-PDC Emulator should sync to PDC Emulator - {$($DomainInfo.PDCEmulator)}" {
                $SourceNTPServer = Invoke-Command @pChecksSession -ScriptBlock { w32tm /query /source }
                $SourceNTPServer | Should -Match $DomainInfo.PDCEmulator
            }
        }
        #If virtual it should allow time sync with integration services only on startup
        $ComputerSystem = Invoke-Command @pChecksSession -ScriptBlock { Get-CimInstance -Class win32_computersystem }
        if($ComputerSystem.Model -match 'Virtual') {
            IT "Time Sync with build in provider should occur only on startup" {
                $VMICTimeProvider = Invoke-Command @pChecksSession -ScriptBlock {
                    Get-ItemProperty -Path HKLM:\SYSTEM\CurrentControlSet\Services\W32Time\TimeProviders\VMICTimeProvider
                }
                $VMICTimeProvider.Enabled | Should -Be 0
            }
        }
    }
}