function Get-pChecksConfigurationData {
  <#
      .SYNOPSIS
      Get-pChecksConfigurationData will retrieve configuratin depending on the input

      .DESCRIPTION
      Currently JSON (.json) and PowerShell Data (.psd1) are supported.
      For JSON files possible output is Hashtable (default) and PSObject.
      For PSD1 files only Hashtable is currently supported.
      Using helpers function will return an object data from given configuration file

      .PARAMETER ConfigurationPath
      Path to JSON or psd1 file

      .EXAMPLE
      Get-pChecksConfigurationData -ConfigurationPath C:\SomePath\Config.json -OutputType Hashtable
      Will read content of Config.json file and convert it to a HashTable.

      .EXAMPLE
      Get-pChecksConfigurationData -ConfigurationPath C:\SomePath\Config.json -OutputType PSObject
      Will read content of Config.json file and convert it to a PS Object.

      .EXAMPLE
      Get-pChecksConfigurationData -ConfigurationPath C:\SomePath\Config.psd1
      Will read content of Config.psd1 file and return it as a HashTable.

      .INPUTS
      Accepts string as paths to JSON or PSD1 files or folders with files

      .OUTPUTS
      Outputs a hashtable of key/value pair or PSObject.
  #>
  [CmdletBinding()]
  param (
    [Parameter(Mandatory, HelpMessage = 'Provide path for configuration file to read', Position = 0 )]
    [ValidateScript({Test-Path -Path $_})]
    [System.String[]]
    $ConfigurationPath,

    [Parameter(Mandatory = $false, HelpMessage = 'Select output type',Position = 1)]
    [ValidateSet('PSObject','HashTable')]
    [string]
    $OutputType='HashTable',

    [Parameter(Mandatory = $false, HelpMessage = 'Search recursively',Position = 2)]
    [switch]
    $Recurse

  )
  begin {
    $queryParams = @{
      Include =  '*.psd1','*.json'
    }
    if($PSBoundParameters.ContainsKey('Recurse')){
      $queryParams.Recurse = $true
    }

  }
  process{
    foreach ($path in $ConfigurationPath) {
      #-include only supported if -path to folder includes \* at the end
      #check if given $ConfigurationPath is a directory
      $pathType = Get-Item -Path $path
      $configurationFile=@()
      switch($pathType.PSIsContainer) {
        $true {
          $configurationFile += Get-ChildItem -Path "$($path)\*" @queryParams | Select-Object -ExpandProperty FullName
        }
        $false {
          $configurationFile = Get-ChildItem -path $ConfigurationPath -Include $queryParams.Include | Select-Object -ExpandProperty FullName
        }
      }
      foreach ($file in $configurationFile) {
        #switch for different files supported
        switch ($file) {
          {$PSItem -match '.json'} {
            #switch for different file output
            switch($OutputType){
              'HashTable' {
                ConvertTo-HashtableFromJSON -Path $file
               }
              'PSObject' {
                ConvertTo-PSObjectFromJSON -Path $file
               }
            }
          }
          {$PSItem -match '.psd1'} {
            Import-LocalizedData -BaseDirectory (Split-Path $file -Parent) -FileName (Split-Path $file -Leaf)
          }
        }
      }
    }
  }
}