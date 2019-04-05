function Get-pCheckToProcess {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $pCheckObject,

        [Parameter(Mandatory, HelpMessage = 'Folder with Pester tests')]
        [ValidateScript( {Test-Path -Path $_ -PathType Container})]
        [System.String[]]
        $pChecksFolderPath
    )
    process {
        foreach ($check in $pCheckObject) {
            Get-ChildItem -Path $pChecksFolderPath -Filter $check.DiagnosticFile -Recurse | Select-Object -ExpandProperty FullName
        }
    }
}