# How to create initial AD Baseline

- To get all details you will need domain credentials and domain controller to query.

```powershell
$Credential = Get-Credential
$queryParams = @{
    ComputerName  = 'YourDomainController' # Get-ADDomainController -Discover -Service PrimaryDC | Select-Object -ExpandProperty HostName
    Credential = $Credential

}
```

- Then provide destination path where baseline configuration should be created:

```powershell
$BaselineConfigurationFolder = 'C:\AdminTools\Tests\BaselineAD'
```

- and finally export:

```powershell
Import-Module  pChecksAD -Force
$Baseline = New-pChecksBaselineAD @queryParams
Export-pChecksBaselineAD -BaselineConfiguration $Baseline -BaselineConfigurationFolder $BaselineConfigurationFolder
```

## Output

This will create a folder structure:

```
├───Nodes
│       DC1.CONTOSO.COM.Configuration.json
│       DC2.CONTOSO.COM.Configuration.json
└───General
        CONTOSO.COM.Configuration.json
```

where:

- `Nodes` will contain configuration of each node (Domain Controller)
- `General` will contain service (Forest,Domain) configuration

## Full code

Below is just code to create the baseline

```powershell
Import-Module pChecksAD -Force
$Credential = Get-Credential
$queryParams = @{
    ComputerName  = 'YourDomainController' # Get-ADDomainController -Discover -Service PrimaryDC | Select-Object -ExpandProperty HostName
    Credential = $Credential

}
$BaselineConfigurationFolder = 'C:\AdminTools\Tests\BaselineAD'
$Baseline = New-pChecksBaselineAD @queryParams
Export-pChecksBaselineAD -BaselineConfiguration $Baseline -BaselineConfigurationFolder $BaselineConfigurationFolder
```

