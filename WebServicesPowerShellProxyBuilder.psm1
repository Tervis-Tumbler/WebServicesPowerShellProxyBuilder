function Get-WSRootAPIURL {
    param (
        [Parameter(Mandatory)]$DefaultWSRootAPIURL,
        [Parameter(Mandatory)]$PSModuleName
    )
    $RootAPIHostName = Get-WSRootAPIHostName -PSModuleName $PSModuleName

    if ($RootAPIHostName) {
        $URIBuilder = [uribuilder]$DefaultWSRootAPIURL
        $URIBuilder.Host = $RootAPIHostName
        $URIBuilder.URI | select -ExpandProperty AbsoluteURI
    } else {
        $DefaultWSRootAPIURL
    }
}

function Set-WSRootAPIHostName {
    param (
        $RootAPIHostName
    )
    [Environment]::SetEnvironmentVariable( "$($PSModuleName)RootAPIHostName", $RootAPIURL, "User" )
}

function Get-WSRootAPIHostName {
    param (
        [Parameter(Mandatory)]$PSModuleName
    )
    Invoke-Expression "`$env:$($PSModuleName)RootAPIHostName"
}

function Invoke-WSAPIfunction {
    param (
        $HttpMethod

    )
    
}

function ConvertTo-URLEncodedQueryStringParameterString {
    param (
        [Parameter(ValueFromPipeline)]$PipelineInput,
        [Switch]$MakeParameterNamesLowerCase
    )
    process {
        if ($PipelineInput.keys) {
            
            foreach ($Key in $PipelineInput.Keys) {
                if ($URLEncodedQueryStringParameterString) {
                    $URLEncodedQueryStringParameterString += "&"
                }
                
                $ParameterName = if ($MakeParameterNamesLowerCase) {
                    $Key.ToLower()
                } else {
                    $Key
                }

                $URLEncodedQueryStringParameterString += "$([Uri]::EscapeDataString($ParameterName))=$([Uri]::EscapeDataString($PipelineInput[$Key]))"
            }
        }
    }
    end {
        $URLEncodedQueryStringParameterString
    }
}

function ConvertFrom-URLEncodedQueryStringParameterString {
    param (
        [Parameter(ValueFromPipeline)]$PipelineInput
    )
    process {
        $KeyValuePairs = $PipelineInput -split "&"
        $HashTable = [Ordered]@{}
        ForEach ($KeyValuePair in $KeyValuePairs) {
            $KeyAndValue = $KeyValuePair -split "="
            $HashTable.add(
                [Uri]::UnescapeDataString($KeyAndValue[0]) , [Uri]::UnescapeDataString($KeyAndValue[1])
            )
        }

        [PSCustomObject]$HashTable
    }
}

function New-XMLElement {
    [cmdletbinding(DefaultParameterSetName='InnerElements')]
    Param (
        $Name,
        $Attributes,
        [Parameter(ParameterSetName="InnerElements")]$InnerElements,
        [Parameter(ParameterSetName="InnerText")]$InnerText,
        [Switch]$AsString
    )
    
    [xml]$xml=""
    $Element = $xml.CreateElement($Name)

    $Attributes = [PSCustomObject]$Attributes
    foreach ($Property in $Attributes.psobject.Properties) {
        $Element.SetAttribute($Property.Name,$Property.Value) | Out-Null
    }

    if ($InnerText) {
        $Element.InnerText = $InnerText
    }

    if ($InnerElements) { 
        ForEach ($InnerElement in $InnerElements) {
            $Element.AppendChild($xml.ImportNode($InnerElement, $true)) | Out-Null
        }
    }

    Write-Verbose $Element.OuterXml
    if ($AsString) {
        $Element.OuterXml
    } else {
        $Element
    }
}

function New-XMLDocument {
    Param (
        [Parameter(Mandatory)][String]$Version,
        [Parameter(Mandatory)][String]$Encoding,
        $InnerElements,
        [Switch]$AsString

    )
    
    [xml]$xml=""
    $xml.Insertbefore($xml.CreateXmlDeclaration($Version,$Encoding,""), $xml.DocumentElement ) | Out-Null
    if ($InnerElements) { 
        ForEach ($InnerElement in $InnerElements) {
            $xml.AppendChild($xml.ImportNode($InnerElement, $true)) | Out-Null
        }
    }

    Write-Verbose $xml.OuterXml
    if ($AsString) {
        $xml.OuterXml
    } else {
        $xml
    }
}

function Get-CurrentSecurityProtocol{
    [System.Net.SecurityProtocolType]$SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol
    $SecurityProtocol
}

function Set-SecurityProtocol {
    param (
        [System.Net.SecurityProtocolType]$SecurityProtocol
    )
    [System.Net.ServicePointManager]::SecurityProtocol = $SecurityProtocol
}

function Get-CurrentCertificatePolicy {
    [System.Net.ServicePointManager]::CertificatePolicy
}

function Set-CertificatePolicy {
    param (
        [Parameter(Mandatory,ParameterSetName="CertificatePolicy")]$CertificatePolicy,
        [Parameter(Mandatory,ParameterSetName="TrustAllCerts")][switch]$TrustAllCerts
    )    

    if ($TrustAllCerts) {
        add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
        $CertificatePolicy = New-Object TrustAllCertsPolicy
    }

    [System.Net.ServicePointManager]::CertificatePolicy = $CertificatePolicy
}

function ConvertFrom-HTTPLinkHeader {
    param(
        [Parameter(ValueFromPipeline)]$Link
    )
    process {
        $Links = $Link | Split-String ", "

        foreach ($HTTPLink in $Links) {
            $LinkParts = $HTTPLink -split "; "
        
            [PSCustomObject]@{
                Name = (Invoke-Expression "@{$($LinkParts[1])}")["rel"]
                URL = $LinkParts[0].Trim("<>")
            }
        }
    }
}

function ConvertTo-HttpBasicAuthorizationHeaderValue {
    [CmdletBinding(DefaultParameterSetName="OAuthAccessToken")]  
    param (
        [Parameter(Mandatory,ValueFromPipeline,ParameterSetName="Credential")]
        [PSCredential]
        $Credential,
        
        [Parameter(ParameterSetName="Credential")]
        $Type,
        
        [Parameter(Mandatory,ValueFromPipelineByPropertyName,ParameterSetName="OAuthAccessToken")]
        $Access_Token,
        
        [Parameter(ValueFromPipelineByPropertyName,ParameterSetName="OAuthAccessToken")]
        $Token_Type
    )
    process {
        $Value = if ($Credential) {
            [System.Convert]::ToBase64String(
                [System.Text.Encoding]::UTF8.GetBytes(
                    $Credential.UserName + ":" + $Credential.GetNetworkCredential().password
                )
            )
        } elseif ($Access_Token) {
            $Access_Token
        }

        if ($Token_Type) { $Type = $Token_Type }

        "$(if($Type){"$Type "})$Value"
    }
}