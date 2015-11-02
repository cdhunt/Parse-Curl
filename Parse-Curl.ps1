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
    
    $tokens = [System.Management.Automation.PSParser]::Tokenize($InputObject,[ref]$null) | Select-Object -ExpandProperty Content
    $index = 0

    while ($index -lt ($tokens.Count) )
    {   
        switch ($tokens[$index])
        {
            'curl' {}
            {$_ -like '*://*'} {
                $ParamList["Uri"] = $tokens[$index]
            }
            {$_ -eq '-D' -or $_ -eq '--data'} {
                $index++
                $ParamList["Body"] = Update-Body $ParamList["Body"] $tokens[$index]
                if (!$ParamList["Method"]) { $ParamList["Method"] = "Post"}
            }
            {$_ -eq '-H' -or $_ -eq '--header'} {
                $index++
                $ParamList["Headers"] = Update-Headers $ParamList["Headers"] $tokens[$index]
            }
            {$_ -eq '-A' -or $_ -eq '--user-agent'} {
                $index++
                if (!$ParamList["UserAgent"]) { $ParamList["UserAgent"] = $tokens[$index]}
            }
            {$_ -eq '-X' -or $_ -eq '--request '} {
                $index++
                if (!$ParamList["Method"]) { $ParamList["Method"] = $tokens[$index]}
            }
        }
        $index++        
    }   

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