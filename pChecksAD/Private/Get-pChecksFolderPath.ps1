function Get-pChecksFolderPath {

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateScript( {Test-Path -Path $_ -PathType Container})]
        [string]
        $pChecksFolderPath

    )
    process {
        if (-not $pChecksFolderPath) {
            $rootPath = Get-Item -Path (Join-Path -Path $PSScriptRoot -ChildPath '\..\Checks')
            Get-Item -Path $rootPath | Select-Object -ExpandProperty FullName
        }
        else {
            Get-Item -Path $pChecksFolderPath | Select-Object -ExpandProperty FullName
        }
    }
}