function Get-ConfigurationDefaultDomainPasswordPolicy {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param(
        [Parameter(Mandatory,
            ParameterSetName = 'ComputerName')]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $Server,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    process {
        $domainQueryParams = @{
            Server = $Server
        }
        if ($PSBoundParameters.ContainsKey('Credential')) {
            $domainQueryParams.Credential = $Credential
        }

        $currentDomainDefaultPasswordPolicy = Get-ADDefaultDomainPasswordPolicy @domainQueryParams
        if ($currentDomainDefaultPasswordPolicy) {
            @{
                ComplexityEnabled           = $currentDomainDefaultPasswordPolicy.ComplexityEnabled
                LockoutDuration             = $currentDomainDefaultPasswordPolicy.LockoutDuration.ToString()
                LockoutObservationWindow    = $currentDomainDefaultPasswordPolicy.LockoutObservationWindow.ToString()
                LockoutThreshold            = $currentDomainDefaultPasswordPolicy.LockoutThreshold
                MinPasswordAge              = $currentDomainDefaultPasswordPolicy.MinPasswordAge.ToString()
                MaxPasswordAge              = $currentDomainDefaultPasswordPolicy.MaxPasswordAge.ToString()
                MinPasswordLength           = $currentDomainDefaultPasswordPolicy.MinPasswordLength
                PasswordHistoryCount        = $currentDomainDefaultPasswordPolicy.PasswordHistoryCount
                ReversibleEncryptionEnabled = $currentDomainDefaultPasswordPolicy.ReversibleEncryptionEnabled
            }
        }
        else {
            $Null
        }
    }
}