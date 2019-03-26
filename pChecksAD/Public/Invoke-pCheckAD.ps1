function Invoke-pCheckAD {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, HelpMessage = 'Path to Checks Index File')]
        [ValidateScript( {Test-Path -Path $_ -PathType Leaf})]
        [System.String]
        $pChecksIndexFilePath,

        [Parameter(Mandatory = $false, HelpMessage = 'Folder with Pester tests')]
        [ValidateScript( {Test-Path -Path $_ -PathType Container})]
        [System.String]
        $pChecksFolderPath,


        [Parameter(Mandatory = $false, HelpMessage = 'Folder with current configuration (baseline)')]
        [ValidateScript( {Test-Path -Path $_ -PathType Container})]
        [System.String]
        $CurrentConfiguration,

        [Parameter(Mandatory = $false, HelpMessage = 'test type for Pester')]
        [ValidateSet('Simple', 'Comprehensive')]
        [string[]]
        $TestType,

        [Parameter(Mandatory = $false, HelpMessage = 'Node to test')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $NodeName,

        [Parameter(Mandatory = $false, HelpMessage = 'hashtable with pester Configuration',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [hashtable]
        $pCheckParameters,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [switch]
        $WriteToEventLog,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $EventSource,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [int32]
        $EventIDBase,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [switch]
        $WriteToAzureLog,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $CustomerId,

        [Parameter(Mandatory = $false,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $SharedKey,

        [Parameter(Mandatory = $false, HelpMessage = 'Folder with Pester test results',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateScript( {Test-Path $_ -Type Container -IsValid})]
        [String]
        $OutputFolder,

        [Parameter(Mandatory = $false, HelpMessage = 'FileName for Pester test results',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [String]
        $FilePrefix,

        [Parameter(Mandatory = $false, HelpMessage = 'Include Date in File Name',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [switch]
        $IncludeDate,

        [Parameter(Mandatory = $false, HelpMessage = 'Show Pester Tests on console',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [String]
        $Show,

        [Parameter(Mandatory = $false, HelpMessage = 'Tag for Pester',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]
        $Tag,

        [Parameter(Mandatory = $false, HelpMessage = 'Target Type to test')]
        [ValidateSet('Nodes', 'General')]
        [string[]]
        $TestTarget
    )
    process {

        if (-not ($PSBoundParameters.ContainsKey('pChecksIndexFilePath'))) {
            $pChecksIndexPathFinal = Get-pChecksIndexPath
            $PSBoundParameters.Add('pChecksIndexFilePath', $pChecksIndexPathFinal)
        }
        else {
            $pChecksIndexPathFinal = Get-pChecksIndexPath -pChecksIndexFilePath $pChecksIndexFilePath
            $PSBoundParameters.pChecksIndexFilePath = $pChecksIndexPathFinal
        }

        if (-not ($PSBoundParameters.ContainsKey('pChecksFolderPath'))) {
            $pChecksFolderPathFinal = Get-pChecksFolderPath
            $PSBoundParameters.Add('pChecksFolderPath', $pChecksFolderPathFinal)
        }
        else {
            $pChecksFolderPathFinal = Get-pChecksFolderPath -pChecksFolderPath $pChecksFolderPath
            $PSBoundParameters.pChecksFolderPath = $pChecksFolderPathFinal
        }
        if (-not $PSBoundParameters.ContainsKey('TestType')) {
            $PSBoundParameters.TestType = @('Simple', 'Comprehensive')
        }
        if (-not $PSBoundParameters.ContainsKey('TestTarget')) {
            $PSBoundParameters.TestTarget = @('Nodes', 'General')
        }

        #jezeli NodeName podane to sprawdz czy w ogole jest sens sprawdzac konrketne nody?

        #jezeli current configuration to co z $checkparameters?
        Invoke-pCheck @PSBoundParameters
    }
}