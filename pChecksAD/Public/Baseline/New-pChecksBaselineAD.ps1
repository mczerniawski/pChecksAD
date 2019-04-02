function New-pChecksBaselineAD {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(

        [Parameter(Mandatory=$false, HelpMessage = 'Target Type to test')]
        [ValidateSet('Nodes', 'General')]
        [string[]]
        $TestTarget,

        [Parameter(Mandatory = $false)]
        [System.String[]]
        $ComputerName,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.PSCredential]
        $Credential,

        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [System.String[]]
        $HighGroups
    )

    process {
        #region Get Configuration from environment
        $Configuration = [ordered]@{
            General = @{ }
            Nodes   = @( )
        }

        if (-not $PSBoundParameters.ContainsKey('ComputerName')) {
            #Get All GlobalCatalogs
            Write-Verbose "No Node provided. Querying AD for all Global Catalogs"
            try {
                $allGlobalCatalogs = Get-ADForest -ErrorAction Stop | Select-Object -ExpandProperty GlobalCatalogs
            }
            catch {
                Write-Error -Message "$($_.Exception.Message).. Aborting all checks!"
                Break
            }
            Write-Verbose "Will process with Nodes {$($allGlobalCatalogs -join (','))}"
            $NodesToProcess = @($allGlobalCatalogs)
        }
        else {
            $NodesToProcess = $NodeName
        }

        if(-not $PSBoundParameters.ContainsKey('TestTarget')){
            $FinalTestTarget = @('Nodes', 'General')
        }
        else {
            $FinalTestTarget = $TestTarget
        }

        if($FinalTestTarget -match 'General') {
            $getpChecksBaselineConfigurationADSplat =@{
                ComputerName = $NodesToProcess[0]
            }
            if ($PSBoundParameters.ContainsKey('Credential')) {
                $getpChecksBaselineConfigurationADSplat.Credential = $Credential
            }
            if (-not $PSBoundParameters.ContainsKey('HighGroups')) {
                $getpChecksBaselineConfigurationADSplat.HighGroups = @('Enterprise Admins', 'Schema Admins')
            }
            else {
                $getpChecksBaselineConfigurationADSplat.HighGroups = $HighGroups
            }
            $Configuration.General = Get-pChecksBaselineConfigurationAD @getpChecksBaselineConfigurationADSplat
        }
        #endregion
        #region node configuration
        if($FinalTestTarget -match 'Nodes') {
            $counter = 1
            $nodesCount = ($NodesToProcess).Count
            $Configuration.Nodes += foreach ($node in $NodesToProcess) {
                Write-Progress -Activity 'Gathering AD Forest configuration' -Status "Get Host {$node} Environment configuration" -PercentComplete (100 / $nodesCount * $counter)
                $sessionParams = @{
                    ComputerName = $node
                }
                if ($PSBoundParameters.ContainsKey('Credential')) {
                    $sessionParams.Credential = $Credential
                }
                Get-pChecksBaselineConfigurationADNode @sessionParams
                $counter++
            }
        }
        #endregion
        $Configuration

    }
}