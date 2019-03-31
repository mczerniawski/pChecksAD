function New-BaselineAD {
    <#
    .SYNOPSIS
    Short description

    .DESCRIPTION
    Long description

    .PARAMETER ComputerName
    Parameter description

    .PARAMETER Credential
    Parameter description

    .PARAMETER BaselineConfigurationFolder
    Parameter description

    .EXAMPLE
    An example

    .NOTES
    General notes
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [System.String]
        $ComputerName,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $Credential
    )

    process {
        #region Get Configuration from environment
        $Configuration = [ordered]@{
            General = @{}
            Nodes  = @()
        }
        $Configuration.General = Get-BaselineConfigurationAD @PSBoundParameters
        #endregion
        #region node configuration
        $counter = 1
        $nodesCount = ($Configuration.General.GlobalCatalogs.Name).Count
        $Configuration.Nodes = foreach ($node in $Configuration.General.GlobalCatalogs.Name) {
            Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Host {$node} Environment configuration" -PercentComplete (100 / $nodesCount * $counter)
            $sessionParams = @{
                ComputerName = $node
                Name  = "Baseline-$node"
            }
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $sessionParams.Credential = $Credential
            }
            $BaselinePSSessionNode = New-PSSession @SessionParams

            if ($PSBoundParameters.ContainsKey('PSSession')) {
                $BaselinePSSessionNode = $PSSession
            }

            Get-BaselineConfigurationADNode -PSSession $BaselinePSSessionNode
            [void](Remove-PSSession $BaselinePSSessionNode.Name -ErrorAction SilentlyContinue)
            $counter++
        }
        #endregion
        $Configuration

    }
}