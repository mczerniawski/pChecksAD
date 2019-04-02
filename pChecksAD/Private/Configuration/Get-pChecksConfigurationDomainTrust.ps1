function Get-pChecksConfigurationDomainTrust {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory,
            ParameterSetName = 'ComputerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Server,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )
    process {
        $domainQueryParams = @{
            Server = $Server
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $domainQueryParams.Credential = $Credential
        }
        $currentTrusts = Get-ADTrust -filter * @queryParams
        foreach ($trust in $currentTrusts) {
            @{
                Name      = $trust.Name
                Direction = $trust.Direction.ToString()
            }
        }
    }
}