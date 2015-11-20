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
function ConvertFrom-CurlString
{
    [CmdletBinding()]
    [Alias('Parse-Curl')]
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
                $ParamList["Headers"] = Update-Header $ParamList["Headers"] $tokens[$index]
            }
            {$_ -eq '-A' -or $_ -eq '--user-agent'} {
                $index++
                if (!$ParamList["UserAgent"]) { $ParamList["UserAgent"] = $tokens[$index]}
            }
            {$_ -eq '-X' -or $_ -eq '--request '} {
                $index++
                if (!$ParamList["Method"]) { $ParamList["Method"] = $tokens[$index]}
            }
            { $_ -eq '--max-redirs' } {
                $index++
                if (!$ParamList["MaximumRedirection"]) { $ParamList["MaximumRedirection"] = $tokens[$index] }
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

    $body = @($body) + $data

    return $body
}

function Update-Header ($headers, [string]$data)
{
    if (!$headers)
    {
        $headers = @{}
    }

    $dataArray = $data.Split(':')

    $headers.Add($dataArray[0].Trim(), $dataArray[1].Trim())

    return $headers
}

Function Invoke-RestMethod
{
    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=217034')]
    param(
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        ${Method},
    
        [switch]
        ${UseBasicParsing},
    
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateNotNullOrEmpty()]
        [uri]
        ${Uri},
    
        [Microsoft.PowerShell.Commands.WebRequestSession]
        ${WebSession},
    
        [Alias('SV')]
        [string]
        ${SessionVariable},
    
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${Credential},
    
        [switch]
        ${UseDefaultCredentials},
    
        [ValidateNotNullOrEmpty()]
        [string]
        ${CertificateThumbprint},
    
        [ValidateNotNull()]
        [System.Security.Cryptography.X509Certificates.X509Certificate]
        ${Certificate},
    
        [string]
        ${UserAgent},
    
        [switch]
        ${DisableKeepAlive},
    
        [int]
        ${TimeoutSec},
    
        [System.Collections.IDictionary]
        ${Headers},
    
        [ValidateRange(0, 2147483647)]
        [int]
        ${MaximumRedirection},
    
        [uri]
        ${Proxy},
    
        [pscredential]
        [System.Management.Automation.CredentialAttribute()]
        ${ProxyCredential},
    
        [switch]
        ${ProxyUseDefaultCredentials},
    
        [Parameter(ValueFromPipeline=$true)]
        [System.Object]
        ${Body},
    
        [string]
        ${ContentType},
    
        [ValidateSet('chunked','compress','deflate','gzip','identity')]
        [string]
        ${TransferEncoding},
    
        [string]
        ${InFile},
    
        [string]
        ${OutFile},
    
        [switch]
        ${PassThru},
        
        [ValidateNotNullOrEmpty()] 
        [System.String] 
        ${CurlString}
    )
    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Invoke-RestMethod', [System.Management.Automation.CommandTypes]::Cmdlet)
            
            if ($PSBoundParameters['CurlString'])
            {
                $parameters = $CurlString | ConvertFrom-CurlString
                $scriptCmd = {& $wrappedCmd @parameters }
            }
            else
            {
                $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            }
            
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }
    
    process
    {
        try {
            $steppablePipeline.Process($_)
        } catch {
            throw
        }
    }
    
    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
    <#
    
    .ForwardHelpTargetName Microsoft.PowerShell.Utility\Invoke-RestMethod
    .ForwardHelpCategory Cmdlet
    
    #>

}