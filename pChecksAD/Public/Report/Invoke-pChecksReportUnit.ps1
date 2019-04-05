function Invoke-pChecksReportUnit {
    <#
    .SYNOPSIS
    Will generate html report based on NUnit XML files.

    .DESCRIPTION
    Will use ReportUnit executable to generate html report based on NUnit xml files

    .PARAMETER ReportUnitPath
    Optional path to ReportUnit.exe. If not provided - will use the one provided within this module.

    .PARAMETER InputFolder
    Location where all NUnit xml files are located. No spaces in folder names.

    .PARAMETER OutputFolder
    Optional. Location where output html files should be written. If not provided will use InputFolder as output folder. No spaces in folder names.

    .EXAMPLE
    Invoke-pChecksReportUnit -ReportUnitPath c:\Tools\ReportUnit.exe -InputFolder c:\PesterTests -OutputFolder c:\PesterReports

    #>
   [CmdletBinding()]
   param
   (

    [Parameter(Mandatory=$false,HelpMessage='Path to ReportUnit executable')]
    [ValidateScript({Test-Path $_ -Type Leaf -Filter {Name -eq 'ReportUnit.exe'}})]
    [System.String]
    $ReportUnitPath,

    [Parameter(Mandatory=$true,HelpMessage='Path to folder with NUnit reports')]
    [ValidateScript({Test-Path $_ -Type Container})]
    [System.String]
    $InputFolder,

    [Parameter(Mandatory=$false,HelpMessage='Path to output directory for reports')]
    [ValidateScript({Test-Path $_ -Type Container})]
    [System.String]
    $OutputFolder
   )

   if($PSBoundParameters.ContainsKey('ReportUnitPath')){
       $reportUnitExecutable = $ReportUnitPath
       Write-Verbose -Message "ReportUnit executable found in path {$ReportUnitPath}"
   }
   else {
       $reportUnitExecutable = "$PSScriptRoot\..\..\bin\ReportUnit\ReportUnit.exe"
       Write-Verbose -Message "ReportUnit executable found in module path {$reportUnitExecutable}"
   }
   if(-not($PSBoundParameters.ContainsKey('OutputFolder'))){
       $OutputFolder = $InputFolder
   }
   Write-Verbose -Message "Generating reports from NUnit files from {$InputFolder} saved to {$OutputFolder}"
   Start-Process $reportUnitExecutable -ArgumentList "$InputFolder $OutputFolder" -NoNewWindow -Wait
}