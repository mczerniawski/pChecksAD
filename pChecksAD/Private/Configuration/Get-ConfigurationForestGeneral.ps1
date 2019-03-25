function Get-ConfigurationForestGeneral {
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
        $forestQueryParams = @{
            Server = $Server
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $forestQueryParams.Credential = $Credential
        }
        $currentADForest = Get-ADForest @forestQueryParams
        if ($currentADForest) {
            [ordered]@{
                Name       = $currentADForest.Name
                ForestMode = $currentADForest.ForestMode.ToString()
                RootDomain = $currentADForest.RootDomain
                FSMORoles  = @{
                    DomainNamingMaster = $currentADForest.DomainNamingMaster
                    SchemaMaster       = $currentADForest.SchemaMaster
                }
                Domains = $currentADForest.Domains
                Sites = $currentADForest.Sites
                Trusts = @()
            }
        }
        else {
            $null
        }
    }
}