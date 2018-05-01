Describe "ConvertFrom-PSBoundParameters" {
    function Test-Function {
        param (
            $Thing1,
            $Thing2,
            $Thing3,
            $ScriptBlock
        )
        & $ScriptBlock $PSBoundParameters
    }

    It "Shouldn't include properties with no value" {
        $ScriptBlock = { 
            param (
                [Parameter(Mandatory,ValueFromPipeline)]$ValueFromPipeline
            ) 
            $ValueFromPipeline | ConvertFrom-PSBoundParameters
        }

        $Result = Test-Function -Thing1 Value1 -ScriptBlock $ScriptBlock
    }
}