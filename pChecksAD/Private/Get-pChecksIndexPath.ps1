function Get-pChecksIndexPath {

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path -Path $_ -PathType Leaf})]
        [string]
        $pChecksIndexFilePath

    )
    process {
            Get-ChildItem -Filter '*.json' -Path $pChecksIndexFilePath | Select-Object -ExpandProperty FullName
    }
}