$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.ps1", ".psd1")
Import-Module "$here\$sut" -Force

Describe "Curl Parsing" {
    Context "Get URI" {
        $params = 'curl http://www.telize.com/geoip' | Parse-Curl

        It "Uri should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
    }

    Context "Get URI when not last" {
        $params = "curl -X GET 'http://www.telize.com/geoip' -H 'X-Api-Key:abc123'" | Parse-Curl

        It "Uri should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
    }

    Context "User agent" {
        $params = 'curl --user-agent "Mozilla/4.0" http://www.telize.com/geoip' | Parse-Curl

        It "Uri should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
        It "UserAgent should be 'Mozilla/4.0'" {
            $params["UserAgent"] | Should Be 'Mozilla/4.0'
        }
    }

    Context "Headers" {
        $params = 'curl -H "X-First-Name: Joe" http://www.telize.com/geoip' | Parse-Curl

        It "Uri should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
        It "Headers should be @{X-First-Name='Joe'}" {
            $params["Headers"]["X-First-Name"] | Should Be 'Joe'
        }
    }

    Context "Multiple headers" {
        $params = 'curl -H "X-First-Name: Joe" --header "header:value" http://www.telize.com/geoip' | Parse-Curl

        It "Uri should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
        It "Headers should be @{X-First-Name='Joe'}" {
            $params["Headers"]["X-First-Name"] | Should Be 'Joe'
        }
        It "Headers should be @{header='value'}" {
            $params["Headers"]["header"] | Should Be 'value'
        }
    }

    Context "With -d" {
        $params = 'curl -d 1 http://www.telize.com/geoip' | Parse-Curl

        It "Uri should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
        It "Body should be '1'" {
            $params["Body"] | Should Be "1"
        }
        It "Method should be 'Post'" {
            $params["Method"] | Should Be "Post"
        }
    }

    Context "With --data" {
        $params = 'curl --data 1 http://www.telize.com/geoip' | Parse-Curl

        It "Uri should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
        It "Body should be '1'" {
            $params["Body"] | Should Be "1"
        }
        It "Method should be 'Post'" {
            $params["Method"] | Should Be "Post"
        }
    }

    Context "With --data 1 --data text" {
        $params = 'curl --data 1 --data text http://www.telize.com/geoip' | Parse-Curl

        It "Should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
        It "Body[0] should be '1'" {
            $params["Body"][0] | Should Be "1"
        }
        It "Body[1] should be 'text'" {
            $params["Body"][1] | Should Be "text"
        }
        It "Method should be 'Post'" {
            $params["Method"] | Should Be "Post"
        }
    }

    Context "Custom Request" {
        $params = "curl -X GET 'http://www.telize.com/geoip' -H 'X-Api-Key:abc123'" | Parse-Curl

        It "Uri should be 'http://www.telize.com/geoip'" {
            $params["Uri"] | Should Be 'http://www.telize.com/geoip'
        }
        It "Verb should be 'GET'" {
            $params["Method"] | Should Be 'GET'
        }
    }

    Context "Max Redirection" {
        $params = 'curl --max-redirs 2 http://www.telize.com/ip' | Parse-Curl

        It "Should allow two redirections" {
            $params['MaximumRedirection'] | Should be 2
        }
    }
}

Describe 'Invoke-RestMethod Proxy Function' {
    Context "CurlString Parameter" {     
        
        It "Should not thow and error" {
            {Invoke-RestMethod -CurlString 'curl "http://www.google.com"'} | Should Not Throw
        }        
    }
}