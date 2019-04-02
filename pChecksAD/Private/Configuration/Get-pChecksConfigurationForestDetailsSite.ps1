function Get-pChecksConfigurationForestDetailsSite {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER ComputerName
    Parameter description

    .PARAMETER Credential
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

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
        $Credential
    )
    process {
        $queryParams = @{
            ComputerName = $ComputerName
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $queryParams.Credential = $Credential
        }
        $sites = Invoke-command @queryParams -ScriptBlock {
            $forestDetails = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
            if ($forestDetails) {
                foreach ($site in $forestDetails.sites){
                    [pscustomobject]@{
                        Name = $site.Name
                        Subnets = @($site.Subnets.Name)
                        Domains = $site.Domains | Select-Object -ExpandProperty Name
                        Servers = $site.Servers | Select-Object -ExpandProperty Name
                        Location = $site.Location
                        AdjacentSites = $site.AdjacentSites | Select-Object -ExpandProperty Name
                        BridgeheadServers = $site.BridgeheadServers | Select-Object -ExpandProperty Name
                    }
                }
            }
        }
        $sites | Select-Object Name,Subnets,Domains,Servers,Location,AdjacentSites,BridgeheadServers
    }
}

