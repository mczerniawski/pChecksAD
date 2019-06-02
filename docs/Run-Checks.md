# Run Examples of pChecksAD

A sample scripts that demonstrates a few options

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
#RUN from ARC-OVF server

#region Set variables
Import-Module pChecksAD -Force
Import-Module Pester -force

#$Password = ConvertTo-SecureString "LS1setup!" -AsPlainText -Force
#$Credential = New-Object System.Management.Automation.PSCredential('ARCONTEST\Administrator',$Password)
#$Credential | Export-Clixml -Path C:\admintools\Creds.xml

$Credential = Import-Clixml -Path C:\admintools\Creds.xml
$queryParams = @{
    #IF Provided will query only this computer!
    #ComputerName  = Get-ADDomainController -Discover -Service PrimaryDC | Select-Object -ExpandProperty HostName
    Credential = $Credential

}
#endregion
```

### Prepare folders

```powershell
#region prepare folders
$BaselineConfigurationFolder = 'C:\AdminTools\Tests\BaselineAD'
if(-not (Test-Path $BaselineConfigurationFolder)) {
    New-Item -Path $BaselineConfigurationFolder -force -ItemType Directory
}
$Baseline = New-pChecksBaselineAD @queryParams
Export-pChecksBaselineAD -BaselineConfiguration $Baseline -BaselineConfigurationFolder $BaselineConfigurationFolder

$ReportsFolder = 'C:\admintools\Tests\Reports'
if(-not (Test-Path $ReportsFolder)) {
    New-Item -Path $ReportsFolder -force -ItemType Directory
}
#endregion
```

### Run Operational Checks - simple

```powershell
#region Operational Checks - simple
Import-Module pChecksAD -Force
$invokepChecksSplat = @{
    Tag             = @('Operational')
    Verbose         = $true
    Credential      = $Credential
    Show            = 'All'
}
Invoke-pChecksAD @invokepChecksSplat
#endregion
```

### Run Operational Checks

```powershell
#region Operational Checks
Import-Module pChecksAD -Force
$invokepChecksSplat = @{
    Tag             = @('Operational')
    #TestTarget     = 'Nodes'
    #NodeName       = @('S1DC1','S1DC2')
    FilePrefix     = 'PSConf-ArconTest'
        IncludeDate    = $true
        OutputFolder   = $ReportsFolder
    Verbose         = $true
    Credential      = $Credential
    Show            = 'All'
    WriteToEventLog = $true
        EventSource     = 'pChecksAD'
        EventIDBase     = 1000

}
Invoke-pChecksAD @invokepChecksSplat
#endregion
```

### Run Configuration Checks

```powershell
#region Configuration Checks
$invokepChecksSplat = @{
    Tag             = @('Configuration')
    BaselineConfigurationFolderPath = $BaselineConfigurationFolder
    Verbose         = $true
    Credential      = $Credential
    Show            = 'All'

}
Invoke-pChecksAD @invokepChecksSplat
#endregion
```

### Run Operational Checks and save to Azure log

```powershell
#region Azure Log Checks - DEPLOY AZURE LOG ANALYTICS WORKSPACE FIRST
$invokepChecksSplat = @{
    Verbose         = $true
    Credential      = $Credential
    Show            = 'All'
    WriteToAzureLog = $true
       Identifier   = 'pChecksAD'
       CustomerId   = 'e2920363-xxxx-740e696ff801'
       SharedKey    = 'cGNQmJJ/OrJVLSCQYFIAdN00cjfR/PvDXABfxLf2ypcHlm5zq7A=='}
Invoke-pChecksAD @invokepChecksSplat
#endregion
```

### Run Checks with full options

```powershell
#region Full Splat
$invokepChecksSplat = @{
    pChecksIndexFilePath = 'C:\Repos\Private-GIT\pChecksAD\pChecksAD\Index\AD.Checks.Index.json'
    pChecksFolderPath = 'C:\Repos\Private-GIT\pChecksAD\pChecksAD\Checks\'
    Tag= @('Operational')
    TestType = 'Simple'
    TestTarget = 'Nodes'
    NodeName = @('S1DC1','S1DC2')
    FilePrefix = 'YourFileNamePrefix'
    IncludeDate = $true
    OutputFolder = $ReportsFolder
    Verbose = $true
    Credential      = $Credential
    BaselineConfigurationFolderPath = 'C:\AdminTools\Tests\BaselineAD_New' #Adding this means adding tag 'Configuration' $Tag +='Configuration'
    Show            = 'All'
    WriteToEventLog = $true
        EventSource     = 'pChecksAD'
        EventIDBase     = 1000
    WriteToAzureLog = $true
       Identifier          = 'pChecksAD'
       CustomerId          = 'e2920363-xxxx-740e696ff801'
       SharedKey           = 'cGNQmJJ/OrJVLSCQYFIAdN00cjfR/PvDXABfxLf2ypcHlm5zq7A=='
}
#endregion
```

### Generate html reports

```powershell
#region Generate html reports

Invoke-pChecksReportUnit -InputFolder $ReportsFolder

Start-Process msedge.exe -ArgumentList 'C:\admintools\Tests\Reports\Index.html'
#endregion
```