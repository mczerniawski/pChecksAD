function Export-pChecksBaselineAD {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [hashTable]
        [ValidateNotNullOrEmpty()]
        $BaselineConfiguration,

        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateScript( {Test-Path -Path (Split-Path -Path $PSItem -Parent) -PathType Container})]
        $BaselineConfigurationFolder
    )
    process {
        Export-pChecksBaselineConfiguration @PSBoundParameters
    }
}