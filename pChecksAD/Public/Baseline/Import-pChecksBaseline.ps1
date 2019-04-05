function Import-pChecksBaseline {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript( {Test-Path -Path $PSItem -PathType Container})]
        [System.String]
        $BaselineConfigurationFolder
    )
    process {

        $BaselineConfiguration = @{
            Nodes    = @()
            General = @()
        }

        #region Get Service Configuration Data (i.e. your DHCP global configuration)
        $BaselineConfiguration.General = Get-pChecksConfigurationData -ConfigurationPath (Join-Path -Path $BaselineConfigurationFolder -ChildPath 'General') -OutputType HashTable
        #endregion

        #region Get Service Nodes Configuration Data (i.e. your DHCP servers specific configuration)
        $BaselineConfiguration.Nodes += Get-pChecksConfigurationData -ConfigurationPath (Join-Path -Path $BaselineConfigurationFolder -ChildPath 'Nodes') -OutputType HashTable
        #endregion

        $BaselineConfiguration

    }
}