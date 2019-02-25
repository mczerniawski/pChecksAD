#Get public and private function definition files.
    $Public  = @( Get-ChildItem -Recurse -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue)
    $Private = @( Get-ChildItem -Recurse -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue)

#Dot source the files
    Foreach($import in @($Public + $Private)) {
        Try {
            Write-Verbose -Message "  Importing $($import.BaseName)"
            . $import.fullname
        }
        Catch {
            Write-Error -Message "Failed to import function $($import.fullname): $_"
        }
    }

Export-ModuleMember -Function $Public.Basename
