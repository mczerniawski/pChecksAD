function Get-pCheckByType {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [psobject]
        $pCheckObject,

        [Parameter(Mandatory = $false, HelpMessage = 'test type for Pester')]
        [ValidateSet('Simple', 'Comprehensive')]
        [string[]]
        $TestType = @('Simple', 'Comprehensive')
    )
    process {
        $pCheckObject | Where-Object {$PSItem.TestType -in @($TestType)}
    }
}