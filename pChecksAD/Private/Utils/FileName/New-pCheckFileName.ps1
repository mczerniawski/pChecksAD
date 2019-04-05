function New-pCheckFileName {
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    
    param
    (
        [Parameter(Mandatory = $True, HelpMessage = 'File name',
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $pCheckFile,

        [Parameter(Mandatory = $true, HelpMessage = 'Folder with Pester test results',
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

        [Parameter(Mandatory = $false, HelpMessage = 'Node to test')]
        [ValidateNotNullOrEmpty()]
        [string]
        $NodeName
    )
    process {

        if (-not (Test-Path -Path $OutputFolder -PathType Container -ErrorAction SilentlyContinue)) {
            Write-Verbose "Creating output folder {$OutputFolder}"
            [void](New-Item -Path $OutputFolder -ItemType Directory)
        }
        $finalFileName = (split-Path $pCheckFile -Leaf).replace('.ps1', '.xml')
        if ($PSBoundParameters.ContainsKey('NodeName')) {
            $finalFileName = '{0}_{1}' -f $NodeName, $finalFileName
        }
        if ($PSBoundParameters.ContainsKey('IncludeDate')) {
            $timestamp = Get-Date -Format 'yyyyMMdd_HHmm'
            $finalFileName = '{0}_{1}' -f $timestamp, $finalFileName
        }
        if ($PSBoundParameters.ContainsKey('FilePrefix')) {
            $finalFileName = '{0}_{1}' -f $FilePrefix, $finalFileName
        }
        $fileName = Join-Path -Path $OutputFolder -ChildPath $finalFileName
        if ($fileName) {
            $fileName
        }
        else {
            Write-Error "Unable to generate file name {$fileName}"
        }
    }
}