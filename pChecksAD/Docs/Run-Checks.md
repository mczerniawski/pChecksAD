# how to run this

A sample script that demonstrated a few options

## Import modules and Create Baseline

```powershell
$creds = Get-Credential

$queryParams = @{
    ComputerName = 'objplpdc0'
    Credential   = $creds

}
$BaselineConfigurationFolder = 'C:\AdminTools\Tests\BaselineAD_New'
Import-Module C:\Repos\pChecksTools\pChecksTools -Force
Import-Module C:\Repos\pChecksAD\pChecksAD -Force

$Baseline = New-pChecksBaselineAD @queryParams
Export-pChecksBaselineAD -BaselineConfiguration $Baseline -BaselineConfigurationFolder $BaselineConfigurationFolder
```

## Verify proper file by importing configuration

```powershell
$BaselineTest = Import-pChecksBaseline -BaselineConfigurationFolder $BaselineConfigurationFolder

Compare-Object -ReferenceObject $Baseline.Nodes -DifferenceObject $BaselineTest.Nodes
foreach ($hashtable in $Baseline.General.GetEnumerator()) {
    Compare-Object -ReferenceObject $hashtable -DifferenceObject ($BaselineTest.General.GetEnumerator() | Where-Object {$_.Name -eq $hashtable.name} )
}
```

## Run checks

```powershell
$creds = Get-Credential
Import-Module C:\Repos\Private-GIT\pChecksTools\pChecksTools -Force
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
    #   Identifier          = $Identifier #Name of checks like pChecksAD
    #   CustomerId          = 'your Customer ID in Azure Log Analytics'
    #   SharedKey           = 'your shared key in Azure Log Analytics'
}

Invoke-pChecksAD @invokepChecksSplat
```

## Create ReportUnit reports

```powershell
Invoke-pChecksReportUnit -InputFolder $invokepChecksSplat.OutputFolder
```