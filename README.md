# Parse-Curl
Parse a Curl command to get a paramerter hashtable for Invoke-RestMethod

## Example

```powershell
PS > $params = 'curl --data 1 --header "header:value" --user-agent "Mozilla/4.0" http://somedomain/folder' | Parse-Curl
PS > Invoke-RestMethod @params