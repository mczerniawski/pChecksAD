function Get-pCheckFromIndex {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory, HelpMessage = 'Path to Checks Index File')]
        [System.String]
        $pChecksIndexFilePath
    )
    process {
        Get-pChecksConfigurationData -ConfigurationPath $pChecksIndexFilePath -OutputType PSObject | Select-Object -ExpandProperty Checks
    }
}