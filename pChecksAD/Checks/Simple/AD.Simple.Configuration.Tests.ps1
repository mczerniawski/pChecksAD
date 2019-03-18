param(
    $ComputerName,
    [System.Management.Automation.PSCredential]$Credential
)
$queryCheckParams = @{
    Server     = $ComputerName
    Credential = $Credential
}
$CurrentConfiguration = New-BaselineAD @PSBoundParameters
