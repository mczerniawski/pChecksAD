Function Export-LogAnalytics {
    [cmdletbinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    Param(

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $CustomerID,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string]
        $SharedKey,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        [psobject[]]
        $pChecksResults,

        [Parameter(Mandatory = $true,
            ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        $LogType,

        [Parameter(Mandatory = $true,
        ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [ValidateNotNullOrEmpty()]
        $TimeStampField
    )
    process {
        $bodyAsJson = ConvertTo-Json $pChecksResults
        $body = [System.Text.Encoding]::UTF8.GetBytes($bodyAsJson)
        $method = 'POST'
        $resource = '/api/logs'
        $rfc1123date = [DateTime]::UtcNow.ToString("r")
        $contentType = 'application/json'

        $getLogAnalyticsSignatureSplat = @{
            CustomerID    = $CustomerID
            SharedKey     = $SharedKey
            Date          = $rfc1123date
            ContentLength = $body.Length
            Method        = $method
            ContentType   = $contentType
            Resource      = $resource
        }
        $signature = Get-LogAnalyticsSignature @getLogAnalyticsSignatureSplat

        $uri = "https://{0}.ods.opinsights.azure.com{1}?api-version=2016-04-01" -f $CustomerID, $resource

        $headers = @{
            "Authorization"        = $signature;
            "Log-Type"             = $LogType;
            "x-ms-date"            = $rfc1123date;
            "time-generated-field" = $TimeStampField;
        }

        $invokeWebRequestSplat = @{
            ContentType = $contentType
            Method = $method
            UseBasicParsing = $true
            Uri = $uri
            Headers = $headers
            Body = $body
        }
        $response = Invoke-WebRequest @invokeWebRequestSplat
        $response.StatusCode
    }
}