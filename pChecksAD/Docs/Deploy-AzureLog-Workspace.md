# Intro

This script will prepare Azure Subscription and Log Analytics workspace. This will be required if you want to send Pester Check results to Azure Log for Monitor and further Automation

## Configure your machine for TLS 1.2 to allow smooth communication with Azure

[Here](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/agent-windows) you can find more information about it.

```powershell
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -Force
New-Item 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -Force
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'Enabled' -value '0xffffffff' –PropertyType DWORD
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name 'DisabledByDefault' -value 0 –PropertyType DWORD
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'Enabled' -value 1 –PropertyType DWORD
New-ItemProperty -path 'HKLM:\SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name 'DisabledByDefault' -value 0 –PropertyType DWORD
```

## Create resource group and LA workspace

```powershell
Import-Module AzureRm
Connect-AzureRmAccount

#Select subscription where Log Analytics workspace should be created
Get-AzureRmSubscription | Out-GridView -PassThru | Select-AzureRmSubscription

$resourceGroupName = 'RG-LogAnalytics'
$Location = 'westeurope'
$workspaceSKU = 'standalone'
$workspaceName = 'LA-pChecks'

$newAzureRmResourceGroupSplat = @{
    Name = $resourceGroupName
    Location = $Location
}
New-AzureRmResourceGroup @newAzureRmResourceGroupSplat

$newWorkspaceSplat = @{
    ResourceGroupName = $resourceGroupName
    Location = $location
    Sku = $workspaceSKU
    Name = $workspaceName
}

New-AzureRmOperationalInsightsWorkspace @newWorkspaceSplat
```

## Set daily cap limit for 0,15GB a day < 5GB a month (free tier)

If this resource group is operating on a free tier it's best to set up daily cap limit for 0,15GB. This will allow to gather logs thorughout the month and not exceed the free tier (5GB) withing few first day by mistake.

- Select the Usage & Billing blade
- Select the Data volume management tab
- Turn the Daily Volume Cap ON
- Set a volume which keeps you within your 5GB/month limit (e.g. 0.15GB/day)
- Press OK to apply the settings

![AL daily CAP](\Images\SetDailyCap.png)

## Get Workspace Private Key

Both Priave Key and Customer ID will be required to send data to Azure Log Analytics

```powershell
$PrimarySharedKey = Get-AzureRmOperationalInsightsWorkspaceSharedKeys -ResourceGroupName $resourceGroupName -Name $workspaceName | Select-Object -ExpandProperty PrimarySharedKey

$PrimarySharedKey
```

# Get Customer ID

```powershell
$CustomerID = Get-AzureRmOperationalInsightsWorkspace -ResourceGroupName $resourceGroupName -Name $workspaceName | Select-Object -ExpandProperty CustomerId | Select-Object -ExpandProperty Guid
$CustomerID
```
