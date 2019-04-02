function Get-pChecksConfigurationDHCPAuthorizedInAD {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER Server
    Parameter description

    .PARAMETER Credential
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    [OutputType([System.Array])]
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
        $searchBase = 'cn=configuration,{0}' -f $currentADDomain.DistinguishedName
        $result = (Get-ADObject @domainQueryParams -SearchBase $searchBase -Filter "objectclass -eq 'dhcpclass' -AND Name -ne 'dhcproot'" )
        if ($result) {
            @( $result.Name)
        }
        else {
            $null
        }
    }
}