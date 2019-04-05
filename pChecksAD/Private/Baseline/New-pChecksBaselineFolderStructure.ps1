function New-pChecksBaselineFolderStructure {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        [ValidateScript( {Test-Path -Path (Split-Path -Path $PSItem -Parent) -PathType Container})]
        $BaselineConfigurationFolder
    )

    if (-not (Test-Path $BaselineConfigurationFolder)) {
        [void](New-Item -Path $BaselineConfigurationFolder -ItemType Directory)
    }
    $GeneralPath = (Join-Path -Path $BaselineConfigurationFolder -childPath 'General')
    $NodesDataPath = (Join-Path -Path $BaselineConfigurationFolder -childPath 'Nodes')

    if (-not (Test-Path $GeneralPath)) {
        [void](New-Item -Path $GeneralPath -ItemType Directory)
    }
    if (-not (Test-Path $NodesDataPath)) {
        [void](New-Item -Path $NodesDataPath -ItemType Directory)
    }
}