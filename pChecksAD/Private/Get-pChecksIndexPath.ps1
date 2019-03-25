function Get-pChecksIndexPath {

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $false)]
        [ValidateScript( {Test-Path -Path $_ -PathType Leaf})]
        [string]
        $pChecksIndexFilePath

    )
    process {
        if (-not $pChecksIndexFilePath) {
            $rootPath = Get-Item -Path "$PSScriptRoot\..\Index" | Select-Object -ExpandProperty FullName
            Get-ChildItem -Filter '*.json' -Path $rootPath | Select-Object -ExpandProperty FullName
        }
        else {
            Get-ChildItem -Filter '*.json' -Path $pChecksIndexFilePath | Select-Object -ExpandProperty FullName
        }
    }
}