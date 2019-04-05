function Get-pChecksRolesConfiguration {
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param (

      [Parameter(Mandatory,
      ParameterSetName='ComputerName')]
      [ValidateNotNullOrEmpty()]
      [System.String]
      $ComputerName,

      [Parameter(Mandatory=$false,
      ParameterSetName='ComputerName')]
      [System.Management.Automation.PSCredential]
      $Credential,

      [Parameter(Mandatory,
      ParameterSetName='PSSession')]
      [System.Management.Automation.Runspaces.PSSession]
      $PSSession


    )
    process{
      #region Variables set
      if($PSBoundParameters.ContainsKey('ComputerName')) {
        $sessionParams = @{
          ComputerName = $ComputerName
          SessionName = "pChecks-$ComputerName"
        }
        if($PSBoundParameters.ContainsKey('Credential')){
          $sessionParams.Credential = $Credential
        }
        $pChecksPSSession = New-PSSession @SessionParams
      }
      if($PSBoundParameters.ContainsKey('PSSession')){
        $pChecksPSSession = $PSSession
      }

      #endregion
      $hostRolesConfiguration = Invoke-Command -session $pChecksPSSession -scriptBlock {
        Get-WindowsFeature
      }
      @{
        Present =@($hostRolesConfiguration | Where-Object {$PSItem.InstallState -eq 'Installed'} | Select-Object -ExpandProperty Name)
        Absent = @($hostRolesConfiguration | Where-Object {$PSItem.InstallState -eq 'Removed'} | Select-Object -ExpandProperty Name)
      }

      if(-not ($PSBoundParameters.ContainsKey('PSSession'))){
        Remove-PSSession -Name $pChecksPSSession.Name -ErrorAction SilentlyContinue
      }
    }
  }