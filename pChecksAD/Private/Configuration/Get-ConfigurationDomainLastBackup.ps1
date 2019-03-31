function Get-ConfigurationDomainLastBackup {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $ComputerName,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )
    process {
        $domainQueryParams = @{
            ComputerName = $ComputerName
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $domainQueryParams.Credential = $Credential
        }
        $lastBackup =Invoke-Command @domainQueryParams -ScriptBlock {
            $DistinguishedName = Get-ADDomain | Select-Object -ExpandProperty DistinguishedName
            $attributes = Get-ADReplicationAttributeMetadata $env:COMPUTERNAME -Object $DistinguishedName -Properties dSASignature
            [pscustomobject]@{
                DomainController = $env:COMPUTERNAME
                LastOriginatingChangeTime = $attributes.LastOriginatingChangeTime.ToString()
                Version = $attributes.Version
            }

        }
        $lastBackup | Select-Object DomainController,LastOriginatingChangeTime,Version
    }
}