function Get-ConfigurationForestDetailsDomain {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $ComputerName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $HighGroups = @('Enterprise Admins', 'Schema Admins')
    )
    process {
        $domainQueryParams = @{
            Server = $ComputerName
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $domainQueryParams.Credential = $Credential
        }
        $domainConfig = @{}
        $DomainConfig = Get-ConfigurationDomainGeneral @domainQueryParams
        $DomainConfig.DHCPServers = Get-ConfigurationDHCPAuthorizedInAD @domainQueryParams
        $DomainConfig.DomainDefaultPasswordPolicy = Get-ConfigurationDefaultDomainPasswordPolicy @domainQueryParams

        $DomainConfig.HighGroups = foreach ($group in $HighGroups) {
            $groupMembers = Get-ADGroupMember -Identity $group @domainQueryParams
            [ordered]@{
                Name    = $group
                Members = @($groupMembers.samaccountname)
            }
        }
        $DomainConfig

    }
}