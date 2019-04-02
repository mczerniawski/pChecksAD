function Get-pChecksConfigurationForestDetailsDomain {
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
        $DomainConfig = Get-pChecksConfigurationDomainGeneral @domainQueryParams
        $DomainConfig.DHCPServers = Get-pChecksConfigurationDHCPAuthorizedInAD @domainQueryParams
        $DomainConfig.DomainDefaultPasswordPolicy = Get-pChecksConfigurationDefaultDomainPasswordPolicy @domainQueryParams

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