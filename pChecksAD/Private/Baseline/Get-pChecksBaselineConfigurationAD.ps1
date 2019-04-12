function Get-pChecksBaselineConfigurationAD {
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
        $Credential,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $HighGroups = @('Enterprise Admins', 'Schema Admins')
    )
    process {
        $queryParams = @{
            Server = $ComputerName
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $queryParams.Credential = $Credential
        }
        $ForestConfig = @{}

        #region Forest properties
        Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Forest configuration" -PercentComplete 5
        $ForestConfig = Get-pChecksConfigurationForestGeneral @queryParams

        $netQueryParams = @{
            ComputerName = $ComputerName
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $netQueryParams.Credential = $Credential
        }
        Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Forest {$($ForestConfig.Name)} Environment configuration - Global Catalogs" -PercentComplete 20
        $ForestConfig.GlobalCatalogs = Get-pChecksConfigurationForestDetailsGlobalCatalog @netQueryParams
        Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Forest {$($ForestConfig.Name)} Environment configuration - Sites" -PercentComplete 40

        $ForestConfig.Sites = Get-pChecksConfigurationForestDetailsSite @netQueryParams
        #endregion
        #region domain properties
        Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Forest {$($ForestConfig.Name)} AD Domains configuration" -PercentComplete 50

        $currentForestDomains = $ForestConfig.Domains
        #replace simple strings with more rich objects!
        $ForestConfig.Domains = @{}
        $ForestConfig.Domains = foreach ($forestDomain in $currentForestDomains) {
            Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Forest {$($ForestConfig.Name)} AD Domains configuration" -PercentComplete 50 -CurrentOperation "Processing domain {$forestDomain}"
            $currentADDomainController = Get-ADDomainController -DomainName $forestDomain -Discover
            $domainQueryParams = @{
                ComputerName = $currentADDomainController.HostName[0]
            }
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $domainQueryParams.Credential = $Credential
            }
            Get-pChecksConfigurationForestDetailsDomain @domainQueryParams
        }
        #endregion
        #region Trust properties
        Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Forest {$($ForestConfig.Name)} Trust configuration" -PercentComplete 80
        $ForestConfig.Trusts = Get-pChecksConfigurationDomainTrust  @queryParams
        #endregion
        Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Forest {$($ForestConfig.Name)} Backup information" -PercentComplete 90
        $lastBackupQuery = @{
            ComputerName = $ForestConfig.GlobalCatalogs.Name
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $lastBackupQuery.Credential = $Credential
        }
        $ForestConfig.Backup = Get-pChecksConfigurationDomainLastBackup @lastBackupQuery

        $ForestConfig
    }
}