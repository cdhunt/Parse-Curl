<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   Example of how to use this cmdlet
.EXAMPLE
   Another example of how to use this cmdlet
#>
function Parse-Curl
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([Hashtable])]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   ValueFromPipeline=$true,
                   Position=0)]
        [String]
        $InputObject
    )

    $ParamList = @{}

    $objectArray = $InputObject | ConvertFrom-String

    $index = 1

    while ($index -lt ($objectArray | Get-Member -MemberType NoteProperty).Count) 
    {

        $term = $objectArray."P$index"

        switch ($term)
        {
            'curl' {}
            {$_ -eq '-D' -or $_ -eq '--data'} {
                $index++
                $ParamList["Body"] = Update-Body $ParamList["Body"] $objectArray."P$index"
                if (!$ParamList["Method"]) { $ParamList["Method"] = "Post"}
            }
            {$_ -eq '-H' -or $_ -eq '--header'} {
                $index++
                $value = $objectArray."P$index".Trim('"')
                if ($value[-1] -eq ':')
                {
                    $index++
                    $value += $objectArray."P$index".Trim('"')
                }
                $ParamList["Headers"] = Update-Headers $ParamList["Headers"] $value
            }
            {$_ -eq '-A' -or $_ -eq '--user-agent'} {
                $index++
                if (!$ParamList["UserAgent"]) { $ParamList["UserAgent"] = $objectArray."P$index".Trim('"')}
            }
        }
        $index++
        
    }
    
    $ParamList["Uri"] = $objectArray."P$index"

    Write-Output $ParamList
}

function Update-Body ($body, [string]$data)
{
    if (!$body)
    {
        $body = @()
    }

    $body = @($body) + [System.Web.HttpUtility]::UrlEncode($data)

    return $body
}

function Update-Headers ($headers, [string]$data)
{
    if (!$headers)
    {
        $headers = @{}
    }

    $dataArray = $data.Split(':')

    $headers.Add($dataArray[0].Trim(), $dataArray[1].Trim())

    return $headers
}