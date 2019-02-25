function Get-ConfigurationDomainGeneral {
    [CmdletBinding()]
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
        $currentADdomain = Get-ADDomain @domainQueryParams
        if ($currentADdomain) {
            [ordered]@{
                ChildDomains             = @($currentADdomain.ChildDomains)
                DNSRoot                  = $currentADdomain.DNSRoot
                DomainMode               = $currentADdomain.DomainMode.ToString()
                FSMORoles                = @{
                    InfrastructureMaster = $currentADdomain.InfrastructureMaster
                    RIDMaster            = $currentADdomain.RIDMaster
                    PDCEmulator          = $currentADdomain.PDCEmulator
                }
                ReadOnlyReplicaDirectoryServers = @($currentADdomain.ReadOnlyReplicaDirectoryServers)
            }
        }
        else {
            $null
        }

    }
}