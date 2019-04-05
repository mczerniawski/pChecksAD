function Get-pCheckByNode {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [psobject]
        $Configuration,

        [Parameter(Mandatory, HelpMessage = 'Tag for Pester')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $NodeName
    )
    process {
        $NodesToProcess = foreach ( $nodeToCheck in $NodeName ){
            $Configuration.Nodes | Where-Object {(($PSItem.ComputerName).Split('.') | Select-Object -First 1 ) -match $nodeToCheck }
        }
        $NodesToProcess.GetEnumerator() | Where-Object { $PSItem.ComputerName -in @( $NodeName ) }
    }
}


