param(
    [System.Management.Automation.PSCredential]$Credential
)

$newpChecksBaselineADSplat = @{
    TestTarget = 'General'
}
if ($PSBoundParameters.ContainsKey('Credential')) {
    $newpChecksBaselineADSplat.Credential = $Credential
}
#$CurrentConfiguration = New-pChecksBaselineAD @newpChecksBaselineADSplat



