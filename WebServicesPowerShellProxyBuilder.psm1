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

function ConvertFrom-PSBoundParameters {
    param (
        [Parameter(ValueFromPipeline)]$ValueFromPipeline
    )
    process {
        [pscustomobject]([ordered]@{}+$ValueFromPipeline)
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
        $CertificatePolicy
    )
    [System.Net.ServicePointManager]::CertificatePolicy = $CertificatePolicy
}