function Get-BaselineConfigurationADNode {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory,
            ParameterSetName = 'ComputerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ComputerName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )
    process {
        if ($PSBoundParameters.ContainsKey('ComputerName')) {
            $sessionParams = @{
                ComputerName = $ComputerName
                Name         = "Baseline-$ComputerName"
            }
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $sessionParams.Credential = $Credential
            }
            $BaselinePSSession = New-PSSession @SessionParams
        }
        if ($PSBoundParameters.ContainsKey('PSSession')) {
            $BaselinePSSession = $PSSession
        }
        $NodeConfiguration = @{}
        Write-Verbose -Message "Reading configuration from host {$($BaselinePSSession.ComputerName)}"

        $hostEnvironment = Get-pChecksBaseHostInformation -PSSession $BaselinePSSession
        $NodeConfiguration.ComputerName = ('{0}.{1}' -f $hostEnvironment.ComputerName, $hostEnvironment.Domain)
        $NodeConfiguration.Domain = $hostEnvironment.Domain

        $NodeConfiguration
        if (-not ($PSBoundParameters.ContainsKey('PSSession'))) {
            Remove-PSSession -Name $BaselinePSSession.Name -ErrorAction SilentlyContinue
        }
    }
}