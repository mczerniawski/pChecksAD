# Build Status

|Build Status|Branch|
|---|---|
|[![Build status](https://ci.appveyor.com/api/projects/status/6a46jkfnc6f0svmd?svg=true)](https://ci.appveyor.com/project/mczerniawski/pchecksad)|master|
|[![Build status](https://ci.appveyor.com/api/projects/status/6a46jkfnc6f0svmd/branch/master?svg=true)](https://ci.appveyor.com/project/mczerniawski/pchecksad/branch/dev)|dev|


---
## Index
<!-- TOC -->
- [What is pChecksAD](#What-is-pChecksAD)
- [Install required modules](#Install-requirements)
- [How to Create initial AD baseline](https://github.com/mczerniawski/pChecksAD/blob/master/docs/Create-AD-Baseline.md)
- [How to Create Azure Log Worksapce](https://github.com/mczerniawski/pChecksAD/blob/master/docs/Create-AzureLog-Workspace.md)
- [Run Examples](https://github.com/mczerniawski/pChecksAD/blob/master/docs/Run-Checks.md)
<!-- /TOC -->

# What is pChecksAD

This module will help manage and run your Pester tests for Active Directory on-premises and let Azure work for you! This will help set up an OVF Server with Pester checks .

---
Using Pester tests for Operation Validation is not a new concept. But adding a bit of Azure adds a new flavor. Log Analytics makes storing , viewing and navigating through the results in time a bit easier. Azure Monitor helps with alerting and Azure Automation with remediation, while PowerBI shines like a star!

# Install requirements

```powershell
Install-Module pChecksAD -Force
Import-Module  pChecksAD -Force
```

You will need RSAT module for AD and DNS cmdlets. Grab it using:

- [choco](https://chocolatey.org/install) : `choco install rsat`
- or PowerShell

```powershell
Get-WindowsCapability -Name RSAT* -Online | Add-WindowsCapability -Online
Update-Help
```

