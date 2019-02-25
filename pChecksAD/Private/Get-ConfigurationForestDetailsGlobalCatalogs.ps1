function Get-ConfigurationForestDetailsGlobalCatalogs {
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
        $globalCatalogs = Invoke-command @queryParams -ScriptBlock {
            $forestDetails = [System.DirectoryServices.ActiveDirectory.Forest]::GetCurrentForest()
            if ($forestDetails) {
                foreach ($gCatalog in $forestDetails.GlobalCatalogs) {
                    [pscustomobject]@{
                        Name = $gCatalog.Name
                        OSVersion = $gCatalog.OSVersion
                        CurrentTime = $gCatalog.CurrentTime.ToString()
                        IPAddress = $gCatalog.IPAddress.ToString()
                        SiteName = $gCatalog.SiteName
                        Partitions = $gCatalog.Partitions
                    }
                }
            }
        }
        $globalCatalogs | Select-Object Name,OSVersion,CurrentTime,IPAddress,SiteName,Partitions
    }
}