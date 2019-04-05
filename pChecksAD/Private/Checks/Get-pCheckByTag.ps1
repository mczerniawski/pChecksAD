function Get-pCheckByTag {
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory)]
        [psobject[]]
        $pCheckObject,

        [Parameter(Mandatory = $false, HelpMessage = 'Tag for Pester')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Tag
    )
    process {
        foreach ($checkByTag in $pCheckObject) {
            $testIfInTags = Compare-Object -ReferenceObject $checkByTag.Tag -DifferenceObject @($Tag) -IncludeEqual
            if ($testIfInTags.SideIndicator -eq '==') {
                $checkByTag
            }
        }
    }
}