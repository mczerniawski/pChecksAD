function Get-pChecksBaselineConfigurationADNode {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ComputerName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential

    )
    process {
        $sessionParams = @{
                ComputerName = $ComputerName
                Name         = "Baseline-$ComputerName"
            }
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $sessionParams.Credential = $Credential
            }
            $BaselinePSSession = New-PSSession @SessionParams

        $NodeConfiguration = @{}
        Write-Verbose -Message "Reading configuration from host {$($BaselinePSSession.ComputerName)}"

        $hostEnvironment = Get-pChecksBaseHostInformation -PSSession $BaselinePSSession
        $NodeConfiguration.ComputerName = ('{0}.{1}' -f $hostEnvironment.ComputerName, $hostEnvironment.Domain)
        $NodeConfiguration.Domain = $hostEnvironment.Domain
        $NodeConfiguration.Roles = Get-pChecksRolesConfiguration -PSSession $BaselinePSSession
        $NodeConfiguration.NIC = Get-pChecksNetAdapterConfiguration -PSSession $BaselinePSSession
        $NodeConfiguration.Team = Get-pChecksTeamingConfiguration -PSSession $BaselinePSSession
        $NodeConfiguration

        Remove-PSSession -Name $BaselinePSSession.Name -ErrorAction SilentlyContinue

    }
}