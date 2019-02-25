# How to create initial AD Baseline

## Requirements

You will need to have this and [pChecksTools](https://github.com/mczerniawski/pChecksTools) installed/downloaded and imported into your session.

Also RSAT module for AD/DNS cmdlets. Grab it using
- [choco](https://chocolatey.org/install) : `choco install rsat`
- or PowerShell

```powershell
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
Update-Help
```

- Installation is quite easy:

```powershell
Install-Module pChecksTools -Scope User
Install-Module pChecksAD -Scope User
```

- Importing isn't rocket science either:

```powershell
Import-Module pChecksTools -Force
Import-Module pChecksAD -Force
```
## Run

To get all details you will need domain credentials and domain controller to query.

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
$Baseline = New-BaselineAD @queryParams
Export-BaselineAD -BaselineConfiguration $Baseline -BaselineConfigurationFolder $BaselineConfigurationFolder
```

## Output

This will create a folder structure:

```
├───AllNodes
│       DC1.CONTOSO.COM.Configuration.json
│       DC2.CONTOSO.COM.Configuration.json
└───NonNodeData
        CONTOSO.COM.Configuration.json
```

where:
- `AllNodes` will contain configuration of each node (Domain Controller)
- `NonNodeData` will contain service (Forest,Domain) configuration


# Full code

Below is just code to create the baseline

```powershell
Import-Module pChecksTools -Force
Import-Module pChecksAD -Force
$Credential = Get-Credential
$queryParams = @{
    ComputerName  = 'YourDomainController' # Get-ADDomainController -Discover -Service PrimaryDC | Select-Object -ExpandProperty HostName
    Credential = $Credential

}
$BaselineConfigurationFolder = 'C:\AdminTools\Tests\BaselineAD'
$Baseline = New-BaselineAD @queryParams
Export-BaselineAD -BaselineConfiguration $Baseline -BaselineConfigurationFolder $BaselineConfigurationFolder
```


