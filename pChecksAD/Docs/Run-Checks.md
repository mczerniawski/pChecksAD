# how to run this

A sample script that demonstrates a few options

## Import modules and Create Baseline

```powershell
$creds = Get-Credential

$queryParams = @{
    ComputerName = 'Server-DC1'
    Credential   = $creds

}
$BaselineConfigurationFolder = 'C:\AdminTools\Tests\BaselineAD_New'
Import-Module C:\Repos\pChecksAD\pChecksAD -Force

$Baseline = New-pChecksBaselineAD @queryParams
Export-pChecksBaselineAD -BaselineConfiguration $Baseline -BaselineConfigurationFolder $BaselineConfigurationFolder
```

## Verify proper file by importing configuration

If you'd like to verify if you stored configuration is correct you can easily compare it to `live` (loaded in previous step)

```powershell
$BaselineTest = Import-pChecksBaseline -BaselineConfigurationFolder $BaselineConfigurationFolder

foreach ($hashtable in $Baseline.General.GetEnumerator()) {
    Compare-Object -ReferenceObject $hashtable -DifferenceObject ($BaselineTest.General.GetEnumerator() | Where-Object {$_.Name -eq $hashtable.name} )
}
```

## Run checks

An example how to run checks

```powershell
$creds = Get-Credential
Import-Module C:\Repos\Private-GIT\pChecksAD\pChecksAD -Force

$invokepChecksSplat = @{
    #pChecksIndexFilePath = 'C:\Repos\Private-GIT\pChecksAD\pChecksAD\Index\AD.Checks.Index.json'
    #pChecksFolderPath = 'C:\Repos\Private-GIT\pChecksAD\pChecksAD\Checks\'
    #Tag= @('Domains')
    #TestType = 'Simple'
    #TestTarget = 'Nodes'
    #NodeName = @('Node1','Node2')
    #FilePrefix = 'YourFileNamePrefix'
    #IncludeDate = $true
    #OutputFolder = 'C:\AdminTools\Tests'
    Verbose = $true
    Credential      = $creds
    #CurrentConfigurationFolderPath = 'C:\AdminTools\Tests\BaselineAD_New' #Adding this means adding tag 'Configuration' $Tag +='Configuration'
    Show            = 'All'
    #WriteToEventLog = $true
    #    EventSource     = 'pChecksAD'
    #    EventIDBase     = 1000
    #WriteToAzureLog = $true
    #   Identifier          = 'pChecksAD' #Name of checks like pChecksAD
    #   CustomerId          = 'your Customer ID in Azure Log Analytics'
    #   SharedKey           = 'your shared key in Azure Log Analytics'
}

Invoke-pChecksAD @invokepChecksSplat
```

## Create ReportUnit reports

An example how to create report with ReportUnit

```powershell
Invoke-pChecksReportUnit -InputFolder $invokepChecksSplat.OutputFolder
```