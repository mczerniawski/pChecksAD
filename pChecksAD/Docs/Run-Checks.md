
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


$pesterParams = @{
    Script = @{
        Path       = 'C:\Repos\Private-GIT\pChecksAD\pChecksAD\Checks\Simple\AD.Simple.Operational.Tests.ps1'
        Parameters = $queryParams
    }
}
$results = Invoke-Pester @pesterParams -PassThru -Show All

```