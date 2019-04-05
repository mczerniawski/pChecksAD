function Convert-HashtableToString {
    <#
    .SYNOPSIS
    Converts hashtable or any other dictionary to a serializable string. It also supports nested hashtables.

    .EXAMPLE
    Convert-HashtableToString -Hashtable @{'key' = 'value'; 'keyNested' = @{'a' = 'b'}}

        @{'key'='value'; 'keyNested'=@{'a'='b'; }; }
    #>
    [CmdletBinding()]
    [OutputType([string])]
    param(
        # Hashtable to convert.
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [System.Collections.IDictionary]
        $Hashtable
    )
    process {
        $sb = New-Object -TypeName System.Text.StringBuilder
        [void]($sb.Append('@{'))
        foreach ($entry in $Hashtable.GetEnumerator()) {

            $key = $entry.Key -replace "'", "''"
            $key = "'$key'"
            $value = $entry.Value
            if ($value -is [System.Collections.IDictionary]) {
                $value = Convert-HashtableToString -Hashtable $value
            }
            else {
                $value = $value -replace "'", "''"
                $value = "'$value'"
            }

            [void]($sb.Append("$key=$value; "))
        }
        [void]($sb.Append('}'))
        return $sb.ToString()
    }
}