# Parse-Curl
Parse a Curl command to get a paramerter hashtable for Invoke-RestMethod

[![Build status](https://ci.appveyor.com/api/projects/status/231l3j4r8mcxcyeo?svg=true)](https://ci.appveyor.com/project/cdhunt/parse-curl)

## Example

```powershell
PS > $params = 'curl --data 1 --header "header:value" --user-agent "Mozilla/4.0" http://somedomain/folder' | Parse-Curl
PS C:\Script> $params

Name                           Value                                                                                                                                                                                  
----                           -----                                                                                                                                                                                  
UserAgent                      Mozilla/4.0                                                                                                                                                                            
Method                         Post                                                                                                                                                                                   
Body                           1                                                                                                                                                                                      
Headers                        {header}                                                                                                                                                                               
Uri                            http://somedomain/folder 

PS > Invoke-RestMethod @params
```