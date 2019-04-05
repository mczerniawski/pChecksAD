function Get-pCheckFiltered {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [psobject]
        $pCheckObject,

        [Parameter(Mandatory = $false, HelpMessage = 'test type for Pester')]
        [ValidateSet('Simple', 'Comprehensive')]
        [string[]]
        $TestType = @('Simple', 'Comprehensive'),

        [Parameter(Mandatory = $false, HelpMessage = 'Tag for Pester')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Tag,

        [Parameter(Mandatory, HelpMessage = 'Node to test')]
        [ValidateSet('Nodes', 'General')]
        [string[]]
        $TestTarget
    )
    process {
        $pCheckObject | Where-Object { $PSItem.TestTarget -in $TestTarget } | ForEach-Object {
            $pChecksTypeFiltered = Get-pCheckByType -pCheckObject $PSItem -TestType $TestType
            if ($pChecksTypeFiltered) {
                if ($PSBoundParameters.ContainsKey('Tag')) {
                    Get-pCheckByTag -pCheckObject $pChecksTypeFiltered -Tag $Tag
                }
                else {
                    $pChecksTypeFiltered
                }
            }
        }
    }
}