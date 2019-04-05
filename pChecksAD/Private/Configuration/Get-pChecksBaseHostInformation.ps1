function Get-pChecksBaseHostInformation {
    [CmdletBinding()]
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
        $hostProperties = Invoke-Command -session $pChecksPSSession -scriptBlock {
            @{
                ComputerName = $ENV:ComputerName
                Domain       = $env:USERDNSDOMAIN
            }
        }
        $cluster = Invoke-Command -session $pChecksPSSession -scriptBlock {
            if (Get-Command Get-Cluster -ErrorAction SilentlyContinue) {
                Get-Cluster -ErrorAction SilentlyContinue
            }
            else {
                $null
            }
        }
        $result = [ordered]@{
            ComputerName = $hostProperties.ComputerName
            Domain       = $hostProperties.Domain
        }
        if ($cluster) {
            $result.Cluster = $cluster.Name
        }
        $result
        
        if(-not ($PSBoundParameters.ContainsKey('PSSession'))){
            Remove-PSSession -Name $pChecksPSSession.Name -ErrorAction SilentlyContinue
        }
    }
}