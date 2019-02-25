function Export-BaselineAD {
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
        Export-BaselineConfiguration -BaselineConfiguration $BaselineConfiguration -BaselineConfigurationFolder $BaselineConfigurationFolder
    }
}