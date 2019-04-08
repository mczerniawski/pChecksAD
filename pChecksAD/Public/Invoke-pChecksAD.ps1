function Invoke-pChecksAD {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory = $false, HelpMessage = 'Path to Checks Index File')]
        [ValidateScript( { Test-Path -Path $_ -PathType Leaf })]
        [System.String]
        $pChecksIndexFilePath,

        [Parameter(Mandatory = $false, HelpMessage = 'Folder with Pester tests')]
        [ValidateScript( { Test-Path -Path $_ -PathType Container })]
        [System.String]
        $pChecksFolderPath,

        [Parameter(Mandatory = $false, HelpMessage = 'Folder with current configuration (baseline)')]
        [ValidateScript( { Test-Path -Path $_ -PathType Container })]
        [System.String]
        $BaselineConfigurationFolderPath,

        [Parameter(Mandatory = $false, HelpMessage = 'test type for Pester')]
        [ValidateSet('Simple', 'Comprehensive')]
        [string[]]
        $TestType,

        [Parameter(Mandatory = $false, HelpMessage = 'Tag for Pester',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string[]]
        $Tag,

        [Parameter(Mandatory = $false, HelpMessage = 'Target Type to test')]
        [ValidateSet('Nodes', 'General')]
        [string[]]
        $TestTarget,

        [Parameter(Mandatory = $false, HelpMessage = 'Node to test')]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $NodeName,

        [Parameter(Mandatory = $false, HelpMessage = 'Provide Credential',
            ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [System.Management.Automation.Credential()][System.Management.Automation.PSCredential]
        $Credential = [System.Management.Automation.PSCredential]::Empty,

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

        [Parameter(Mandatory = $false, HelpMessage = 'Name for checks to store in Azure Log Analytics',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $Identifier,

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
        [ValidateScript( { Test-Path $_ -Type Container -IsValid })]
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
        [ValidateSet('All','Context','Default','Describe','Failed','Fails','Header','Inconclusive','None','Passed','Pending','Skipped','Summary')]
        [String]
        $Show
    )
    begin {
        $pesterParams = @{
            PassThru = $true
        }
        if ($PSBoundParameters.ContainsKey('Show')) {
            $pesterParams.Show = $Show
        }
        else {
            $pesterParams.Show = 'None'
        }

        #region get output file pester parameters
        if ($PSBoundParameters.ContainsKey('OutputFolder')) {
            $newpCheckFileNameSplat =@{
                OutputFolder = $OutputFolder
            }
            if ($PSBoundParameters.ContainsKey('FilePrefix')) {
                $newpCheckFileNameSplat.FilePrefix = $FilePrefix
            }
            if ($PSBoundParameters.ContainsKey('IncludeDate')) {
                $newpCheckFileNameSplat.IncludeDate = $true
            }
            $pesterParams.OutputFormat = 'NUnitXml'
        }
        #endregion
    }
    process {
        #region Get index file
        if ($PSBoundParameters.ContainsKey('pChecksIndexFilePath')) {
            $pChecksIndexFilePathFinal = $pChecksIndexFilePath
        }
        else {
            $pChecksIndexFilePathFinal = Get-Item -Path "$PSScriptRoot\..\Index" | Select-Object -ExpandProperty FullName
        }

        $pCheckFromIndex = Get-pCheckFromIndex -pChecksIndexFilePath $pChecksIndexFilePathFinal
        if (-not $pCheckFromIndex) {
            Write-Error -Message "Couldn't load index for Checks. Aborting"
            break
        }
        $getpCheckFilteredSplat = @{ }
        #endregion

        #region filter index first
        if ($PSBoundParameters.ContainsKey('TestType')) {
            $getpCheckFilteredSplat.TestType = $TestType
        }
        else {
            $getpCheckFilteredSplat.TestType = @('Simple', 'Comprehensive')
        }
        if ($PSBoundParameters.ContainsKey('TestTarget')) {
            $getpCheckFilteredSplat.TestTarget = $TestTarget
        }
        else {
            $getpCheckFilteredSplat.TestTarget = @('Nodes', 'General')
        }
        if ($PSBoundParameters.ContainsKey('Tag')) {
            $getpCheckFilteredSplat.Tag = $Tag
        }
        #region if Configuration path provided - read configuration and add tag Configuration
        if ($PSBoundParameters.ContainsKey('BaselineConfigurationFolderPath')) {
            $BaselineConfiguration = Import-pChecksBaseline -BaselineConfigurationFolder $BaselineConfigurationFolderPath
        }
        #endregion
        #region if Tag ='Configuration' is present, import configuration
        if ($PSBoundParameters['Tag'] -match 'Configuration') {
            if ($PSBoundParameters.ContainsKey('BaselineConfigurationFolderPath')) {
                $BaselineConfiguration = Import-pChecksBaseline -BaselineConfigurationFolder $BaselineConfigurationFolderPath
            }
            else {
                Write-Error -Message "Please provide CurrentConfigurationFolderPath for checks"

            }
        }
        #endregion

        #endregion

        #region get all actual checks folder path
        if ($PSBoundParameters.ContainsKey('pChecksFolderPath')) {
            $pChecksFolderPathFinal = $pChecksFolderPath
        }
        else {
            $pChecksFolderPathFinal = Get-Item -Path "$PSScriptRoot\..\Checks" | Select-Object -ExpandProperty FullName
        }
        #endregion

        #region filter index checks based provided criteria
        $pCheckAllFiltered = ForEach ($pCheck in $pCheckFromIndex) {
            $getpCheckFilteredSplat.pCheckObject = $pCheck
            Get-pCheckFiltered @getpCheckFilteredSplat
        }
        if (-not $pCheckAllFiltered) {
            Write-Error -Message "Couldn't filter checks with given parameters. Aborting"
            break
        }
        #endregion

        #region appl filtered index checks on actual file checks
        foreach ($pCheckFiltered in $pCheckAllFiltered) {
            $checkToProcess = Get-pCheckToProcess -pCheckObject $pCheckFiltered -pChecksFolderPath $pChecksFolderPathFinal
            if (-not $checkToProcess) {
                Write-Error -Message "Couldn't get any checks matching provided criteria. Aborting"
                break
            }
            $pesterParams.Script = @{
                Path       = $checkToProcess
                Parameters = @{ }
            }
            if ($pCheckFiltered.Tag) {
                $pesterParams.Tag = $getpCheckFilteredSplat.Tag
            }

            #region check what paramaters are required by check and provide
            if ($pCheckFiltered.Parameters -contains 'BaselineConfiguration') {
                if ($BaselineConfiguration) {
                    $pesterParams.Script.Parameters.Add('BaselineConfiguration', $BaselineConfiguration)
                }
                else {
                    Write-Error -Message "Please provide Baseline Configuration for test {$checkToProcess}"
                }
            }
            if ($pCheckFiltered.Parameters -contains 'Credential') {
                if ($PSBoundParameters.ContainsKey('Credential')) {
                    $pesterParams.Script.Parameters.Add('Credential', $Credential)
                }
            }
            #region no NodeName provided and TestTarget set for Nodes - 'query for all Global Catalogs'
            if ($pCheckFiltered.TestTarget -match 'Nodes') {
                if (-not $PSBoundParameters.ContainsKey('NodeName')) {
                    #Get All GlobalCatalogs
                    Write-Verbose "No Node provided. Querying AD for all Global Catalogs"
                    try {
                        $allGlobalCatalogs = Get-ADForest -ErrorAction Stop | Select-Object -ExpandProperty GlobalCatalogs
                    }
                    catch {
                        Write-Error -Message "$($_.Exception.Message).. Aborting all checks!"
                        Break
                    }
                    Write-Verbose "Will process with Nodes {$($allGlobalCatalogs -join (','))}"
                    $NodesToProcess = @($allGlobalCatalogs)
                }
                else {
                    $NodesToProcess = $NodeName
                }

                foreach ($node in $NodesToProcess) {
                    Write-Verbose "Processing testTarget {Node} - {$node} with file - {$checkToProcess}"
                    if ($PSBoundParameters.ContainsKey('OutputFolder')) {
                        $newpCheckFileNameSplat.pCheckFile = $checkToProcess
                        $newpCheckFileNameSplat.NodeName = $node
                        $pesterParams.OutputFile = New-pCheckFileName @newpCheckFileNameSplat
                        Write-Verbose -Message "Results for Pester file {$checkToProcess} will be written to {$($pesterParams.OutputFile)}"

                    }
                    if ($pCheckFiltered.Parameters -contains 'ComputerName') {
                        $pesterParams.Script.Parameters.ComputerName = $node
                    }

                    <# if ($pCheckFiltered.Parameters -contains 'CurrentConfiguration') {
                        #Create baseline configuration for given TestTarget
                        $newpChecksBaselineADSplat = @{
                            ComputerName = $node
                            TestTarget = 'Nodes'
                        }
                        if($PSBoundParameters.ContainsKey('Credential')){
                            $newpChecksBaselineADSplat.Credential = $Credential
                        }
                        $CurrentConfiguration = New-pChecksBaselineAD @newpChecksBaselineADSplat
                        $pesterParams.Script.Parameters.CurrentConfiguration = $CurrentConfiguration
                    }
                    #>

                    if ($pCheckFiltered.Parameters -contains 'BaselineConfiguration') {
                        if ($BaselineConfiguration) {
                            $pesterParams.Script.Parameters.BaselineConfiguration = $BaselineConfiguration
                        }
                        else {
                            Write-Error -Message "Please provide baseline configuration for this check {$checkToProcess}"
                            continue
                        }
                    }

                    #region Perform Tests
                    $invocationStartTime = [DateTime]::UtcNow
                    $pChecksResults = Invoke-Pester @pesterParams
                    $invocationEndTime = [DateTime]::UtcNow
                    #endregion


                    #region Where to store results
                    #region EventLog
                    if ($PSBoundParameters.ContainsKey('WriteToEventLog')) {
                        $pesterEventParams = @{
                            PesterTestsResults = $pChecksResults
                            EventSource        = $EventSource
                            EventIDBase        = $EventIDBase
                        }
                        Write-Verbose -Message "Writing test results to Event Log {Application} with Event Source {$EventSource} and EventIDBase {$EventIDBase}"
                        Write-pChecksToEventLog @pesterEventParams
                    }
                    #endregion

                    #region Azure Log Analytics
                    if ($PSBoundParameters.ContainsKey('WriteToAzureLog')) {
                        $batchId = [System.Guid]::NewGuid()
                        $pesterALParams = @{
                            PesterTestsResults  = $pChecksResults
                            invocationStartTime = $invocationStartTime
                            invocationEndTime   = $invocationEndTime
                            Identifier          = $Identifier
                            BatchId             = $BatchId
                            CustomerId          = $CustomerId
                            SharedKey           = $SharedKey
                            Target              = $node
                        }
                        Write-Verbose -Message "Writing test results to Azure Log CustomerID {$CustomerId} with BatchID {$BatchId} and Identifier {$Identifier}"
                        Write-pChecksToLogAnalytics @pesterALParams
                    }
                    #endregion
                    #endregion
                }
            }
            #endregion


            if ($pCheckFiltered.TestTarget -eq 'General') {
                Write-Verbose "Processing testTarget {General} with file - {$checkToProcess}"
                if ($PSBoundParameters.ContainsKey('OutputFolder')) {
                    $newpCheckFileNameSplat.pCheckFile = $checkToProcess
                    $newpCheckFileNameSplat.NodeName = 'General'
                    $pesterParams.OutputFile = New-pCheckFileName @newpCheckFileNameSplat
                    Write-Verbose -Message "Results for Pester file {$checkToProcess} will be written to {$($pesterParams.OutputFile)}"
                }

                if ($pCheckFiltered.Parameters -contains 'BaselineConfiguration') {
                    if ($BaselineConfiguration) {
                        $pesterParams.Script.Parameters.BaselineConfiguration = $BaselineConfiguration
                    }
                    else {
                        Write-Error -Message "Please provide baseline configuration for this check {$checkToProcess}"
                        continue
                    }
                }
                #region Perform Tests
                $invocationStartTime = [DateTime]::UtcNow
                $pChecksResults = Invoke-Pester @pesterParams
                $invocationEndTime = [DateTime]::UtcNow
                #endregion

                #region Where to store results
                #region EventLog
                if ($PSBoundParameters.ContainsKey('WriteToEventLog')) {
                    $pesterEventParams = @{
                        PesterTestsResults = $pChecksResults
                        EventSource        = $EventSource
                        EventIDBase        = $EventIDBase
                    }
                    Write-Verbose -Message "Writing test results to Event Log {Application} with Event Source {$EventSource} and EventIDBase {$EventIDBase}"
                    Write-pChecksToEventLog @pesterEventParams
                }
                #endregion

                #region Azure Log Analytics
                if ($PSBoundParameters.ContainsKey('WriteToAzureLog')) {
                    $batchId = [System.Guid]::NewGuid()
                    $pesterALParams = @{
                        PesterTestsResults  = $pChecksResults
                        invocationStartTime = $invocationStartTime
                        invocationEndTime   = $invocationEndTime
                        Identifier          = $Identifier
                        BatchId             = $BatchId
                        CustomerId          = $CustomerId
                        SharedKey           = $SharedKey
                        Target              = 'General'
                    }
                    Write-Verbose -Message "Writing test results - Count {$($pesterALParams.PesterTestsResults.TotalCount)} to Azure Log CustomerID {$CustomerId} with BatchID {$BatchId} and Identifier {$Identifier}"
                    Write-pChecksToLogAnalytics @pesterALParams
                }
                #endregion
                #endregion
            }
            Write-Verbose -Message "Pester File {$checkToProcess} Processed type $($pCheckFiltered.TestTarget)"
        }
    }
}