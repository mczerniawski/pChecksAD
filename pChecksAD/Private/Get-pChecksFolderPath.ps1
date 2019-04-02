function Get-pChecksFolderPath {

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateScript( {Test-Path -Path $_ -PathType Container})]
        [string]
        $pChecksFolderPath

    )
    process {

            Get-Item -Path $pChecksFolderPath | Select-Object -ExpandProperty FullName

    }
}