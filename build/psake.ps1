# Properties passed from command line
Properties {
}

# Common variables
$ProjectRoot = $ENV:BHProjectPath
if (-not $ProjectRoot) {
    $ProjectRoot = Split-Path -Parent $PSScriptRoot
}

$Timestamp = Get-date -uformat "%Y%m%d-%H%M%S"
$TestFile = "TestResults_PS$PSVersion`_$TimeStamp.xml"
$lines = '----------------------------------------------------------------------'

# Tasks

Task Default -Depends Build

Task Init {
    $lines
    Set-Location $ProjectRoot
    "Build System Details:"
    Get-Item ENV:BH*
    "`n"
}

Task Test -Depends Init {
    $lines

    if (!(Test-Path -Path $ProjectRoot\Tests)) {
      return
    }

    $PSVersion = $PSVersionTable.PSVersion.Major
    "Running Pester tests with PowerShell $PSVersion"

    $TestResults = Invoke-Pester -Path $ProjectRoot\Tests -PassThru -OutputFormat NUnitXml -OutputFile "$ProjectRoot\$TestFile"

    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
        (New-Object 'System.Net.WebClient').UploadFile(
            "https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)",
            "$ProjectRoot\$TestFile" )
    }

    Remove-Item "$ProjectRoot\$TestFile" -Force -ErrorAction SilentlyContinue

    if ($TestResults.FailedCount -gt 0) {
        Write-Error "Failed '$($TestResults.FailedCount)' tests, build failed"
    }
    "`n"
}

Task Build -Depends Test, StaticCodeAnalysis, RegenerateWiki {
    $lines

    # Import-Module to check everything's ok
    Import-Module -Name $env:BHPSModuleManifest -Force

    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
      "Updating module psd1 - FunctionsToExport"
      Set-ModuleFunction

      # Bump the module version
      if ($ENV:PackageVersion) {
        "Updating module psd1 version to $($ENV:PackageVersion)"
        Update-Metadata -Path $env:BHPSModuleManifest -Value $ENV:PackageVersion
      }
      else {
        "Not updating module psd1 version - no env:PackageVersion set"
      }
    }
}

Task StaticCodeAnalysis {
    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
        Add-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Running
    }
    $scriptStylePath = "$ProjectRoot\ScriptingStyle.psd1"
    if (!(Test-Path -Path $scriptStylePath)) {
        $scriptStylePath = "$PSScriptRoot\ScriptingStyle.psd1"
    }
    "Running PSScriptAnalyzer using file '$scriptStylePath'"
    $Results = Invoke-ScriptAnalyzer -Path $ENV:BHModulePath -Recurse -Settings $scriptStylePath
    if ($Results) {
        $ResultString = $Results | Out-String
        Write-Warning $ResultString
        if ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Add-AppveyorMessage -Message "PSScriptAnalyzer output contained one or more result(s) with 'Error' severity.`
            Check the 'Tests' tab of this build for more details." -Category Error
            Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Failed -ErrorMessage $ResultString
        }

        throw "Build failed"
    }
    else {
        If ($ENV:BHBuildSystem -eq 'AppVeyor') {
            Update-AppveyorTest -Name "PsScriptAnalyzer" -Outcome Passed
        }
    }
}

Task RegenerateWiki {
    # this is only for local runs
    if ($ENV:BHBuildSystem -eq 'AppVeyor') {
        return
    }

    $wikiPath = "$ProjectRoot\..\$($env:BHProjectName).wiki"
    if (!(Test-Path -Path $wikiPath)) {
        "Directory '$wikiPath' does not exist - if you clone it, it will be regenerated automatically during local build"
        return
    }

    # make sure you're in folder with propert casing (e.g. you've run 'cd c:\work\PPoshTools' instead of 'cd c:\work\pposhtools',
    # otherwise git links might break
    New-MarkdownDoc -ModulePath $env:BHModulePath `
        -OutputPath "$wikiPath\api" `
        -GitBaseUrl "https://github.com/PPOSHGROUP/$($env:BHProjectName)/blob/master/$($env:BHProjectName)"
}
