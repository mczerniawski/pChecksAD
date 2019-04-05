function Get-pChecksTeamingConfiguration {
    [CmdletBinding()]
    [OutputType([System.Collections.Specialized.OrderedDictionary])]
    param (

        [Parameter(Mandatory,
            ParameterSetName = 'ComputerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ComputerName,

        [Parameter(Mandatory = $false,
            ParameterSetName = 'ComputerName')]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory,
            ParameterSetName = 'PSSession')]
        [System.Management.Automation.Runspaces.PSSession]
        $PSSession
    )
    process {
        #region Variables set
        if ($PSBoundParameters.ContainsKey('ComputerName')) {
            $sessionParams = @{
                ComputerName = $ComputerName
                SessionName  = "pChecks-$ComputerName"
            }
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $sessionParams.Credential = $Credential
            }
            $pChecksPSSession = New-PSSession @SessionParams
        }
        if ($PSBoundParameters.ContainsKey('PSSession')) {
            $pChecksPSSession = $PSSession
        }

        #endregion
        $hostTeams = @()
        $hostTeams = Invoke-Command $pChecksPSSession -ScriptBlock {
            Get-NetLbfoTeam | ForEach-Object {
                @{
                    Name                   = $PSItem.Name
                    TeamingMode            = $PSitem.TeamingMode.ToString()
                    LoadBalancingAlgorithm = $PSitem.LoadBalancingAlgorithm.ToString()
                    Members                = @($PSItem.Members)
                }
            }
        }
        #to Avoid issues with PSComputerName and RunspaceId added to each object from invoke-command - I'm reassigning each hashtable
        foreach ($hostTeam in $hostTeams) {
            [ordered]@{
                Name                   = $hostTeam.Name
                TeamingMode            = $hostTeam.TeamingMode
                LoadBalancingAlgorithm = $hostTeam.LoadBalancingAlgorithm
                Members                = @($hostTeam.Members)
            }
        }
        if(-not $PSBoundParameters.ContainsKey('PSSession')) {
            Remove-PSSession -Name $pChecksPSSession.Name -ErrorAction SilentlyContinue
        }
    }
}