function Write-pChecksToEventLog {
  <#
      .SYNOPSIS
      Custom formating of Pester test results written to EventLog Application

      .DESCRIPTION
      Accepts PesterResults from Invoke-Pester -passThru as input. Will parse through results and write events to EventLog Application with provided EventSource.
      EventIDBase will be used to calculate Information (+1) and Error (+2) EventIDs.

      .PARAMETER PesterTestsResults
      PSCustomObject from Invoke-Pester -PassThru option

      .PARAMETER EventSource
      EventSource used to write events to EventLog

      .PARAMETER EventIDBase
      Base ID to pass to Write-pChecksToEventLog.
      Success tests will be written to EventLog Application with MySource as source and EventIDBase +1.
      Errors tests will be written to EventLog Application with MySource as source and EventIDBase +2.

      .EXAMPLE
      $tests = Invoke-Pester -Script c:\adminTools\tests.ps1 -PassThru
      Write-pChecksToEventLog. -PesterTestsResults $tests -EventSource MySource -EventIDBase 1000

      Will parse through all results in $tests.
      Passed tests will be written as Information events with EventID 1001 to 'Application' Log with source $EventSource
      Failed tests will be written as Error events with EventID 1002 to 'Application' Log with source $EventSource

      .INPUTS
      Accepts PesterResults from Invoke-Pester -passThru
  #>
  [CmdletBinding()]
  param
  (
    [Parameter(Mandatory=$false,
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [PSCustomObject]
    $PesterTestsResults,

    [Parameter(Mandatory=$false,
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [System.String]
    $EventSource,

    [Parameter(Mandatory=$false,
    ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
    [System.Int32]
    $EventIDBase = 1000
  )

  begin {
    $EventIDInfo = $EventIDBase + 1
    $EventIDError = $EventIDBase + 2
  }
  process{
    try {
      if (-not [system.diagnostics.eventlog]::SourceExists($EventSource)) {
        Write-Verbose -Message "EventSource {$EventSource} does not exists. Will attempt to create!"
        [system.diagnostics.EventLog]::CreateEventSource($EventSource, 'Application')
        Write-Verbose -Message "Created EventSource {$EventSource} in {Application} log. Information messages with EventID {$EventIDInfo}. Error messages with EventID {$EventIDError}"
      }
      foreach ($testResult in $PesterTestsResults.TestResult) {
        if ($testResult.Result -match 'Passed'){
          $writeEventLogSplat = @{
              Source = $EventSource
              EntryType = 'Information'
              Category = 0
              LogName = 'Application'
              Message = "{0} - {1}`n {2} Status: {3}" -f $testResult.Describe, $testResult.Context, $testResult.Name, $testResult.Passed
              EventId = $EventIDInfo
          }
          Write-EventLog @writeEventLogSplat
        }
        elseif ($testResult.Result -match 'Failed') {
          $writeEventLogSplat = @{
              Source = $EventSource
              EntryType = 'Error'
              Category = 0
              LogName = 'Application'
              Message = "{0} - {1}`n {2} Status: {3}`n Message: {4}" -f $testResult.Describe, $testResult.Context, $testResult.Name, $testResult.Passed, $testResult.FailureMessage
              EventId = $EventIDError
          }
          Write-EventLog @writeEventLogSplat
        }
      }
    }
    catch [System.Security.SecurityException],[Microsoft.PowerShell.Commands.WriteEventLogCommand]{
      Write-Log -Error -Message "You don't have permissions to create eventlogs sources. Unable to create EventSource {$EventSource}"
    }
    catch {
      $_
    }
  }
  end {
  }
}