
```powershell
Import-Module pChecksTools -Force
Import-Module pChecksAD -Force


#$Credential = Get-Credential
$queryParams = @{
    ComputerName  = 'objplpdc0'
    Credential = $Credential

}
$BaselineConfigurationFolder = 'C:\AdminTools\Tests\BaselineAD_New'
Import-Module C:\Repos\Private-GIT\pChecksTools\pChecksTools -Force
Import-Module C:\Repos\Private-GIT\pChecksAD\pChecksAD -Force

$Baseline = New-BaselineAD @queryParams

Export-BaselineAD -BaselineConfiguration $Baseline -BaselineConfigurationFolder $BaselineConfigurationFolder

$invokepCheckSplat = @{
        #pChecksIndexFilePath = 'C:\Repos\Private-GIT\pChecksAD\pChecksAD\Index\AD.Checks.Index.json'
        #pChecksFolderPath = 'C:\Repos\Private-GIT\pChecksAD\pChecksAD\Checks\'
        #Tag= @('Domain','General')
        #TestType = 'Simple'
        #TestTarget = 'Nodes'
        #NodeName = @('OBJPLSDC0','OBJPLPDC0')
        #pCheckParameters = @{
        #    ComputerName = ' OBJPLPDC0'
        #    Credential = $creds
        #}
        #FilePrefix = 'SomePrefix'
        #IncludeDate = $true
        #NodeName = @('OBJPLPDC0','OBJPLSDC0')
        #OutputFolder = 'C:\AdminTools\Tests'
        #Verbose = $true
        #Credential = $Credential
        #CurrentConfigurationFolderPath = 'C:\AdminTools\Tests\BaselineAD_New'
        #POdanie sciezki oznacza Tag +='Configuration'
    }

Invoke-pCheckAD @invokepCheckSplat


#ToDo:
# pcheckParameters
# obsluga nodow dla Parameters
#write Log
# write Azure
# Pester xml output
# Invoke-pChecksReportUnit



```