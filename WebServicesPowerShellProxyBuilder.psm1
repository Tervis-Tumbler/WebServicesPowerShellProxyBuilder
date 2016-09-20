Function Get-WSRootAPIURL {
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

Function Set-WSRootAPIHostName {
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

function Invoke-WSAPIFunction {
    param (
        $HttpMethod

    )
    
}

Function ConvertTo-URLEncodedQueryStringParameterString {
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

Function ConvertFrom-URLEncodedQueryStringParameterString {
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




Function New-XMLElement {
    [cmdletbinding(DefaultParameterSetName='InnerElements')]
    Param (
        $Name,
        $Attributes,
        [Parameter(ParameterSetName="InnerElements")]$InnerElements,
        [Parameter(ParameterSetName="InnerText")]$InnerText
    )
    
    [xml]$xml=""
    $Element = $xml.CreateElement($Name)
    foreach ($Key in $Attributes.Keys) {
        $Element.SetAttribute($Key,$Attributes[$Key]) | Out-Null
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
    $Element
}

Function New-XMLDocument {
    Param (
        [Parameter(Mandatory)]$Version,
        [Parameter(Mandatory)]$Encoding,
        $InnerElements
    )
    
    [xml]$xml=""
    $xml.Insertbefore($xml.CreateXmlDeclaration("1.0","UTF-8",""), $xml.DocumentElement ) | Out-Null
    if ($InnerElements) { 
        ForEach ($InnerElement in $InnerElements) {
            $xml.AppendChild($xml.ImportNode($InnerElement, $true)) | Out-Null
        }
    }

    Write-Verbose $xml.OuterXml
    $xml
}