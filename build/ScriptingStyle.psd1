@{
    Severity = @('Error', 'Warning', 'Information')
    IncludeRules = @(   
                   'PSAvoidDefaultValueForMandatoryParameter',
                   'PSAvoidDefaultValueSwitchParameter',
                   'PSAvoidGlobalAliases',
                   'PSAvoidGlobalFunctions',
                   'PSAvoidGlobalVars',
                   'PSAvoidUsingPlainTextForPassword',
                   'PSAvoidTrapStatement',
                   'PSAvoidUninitializedVariable',
                   'PSAvoidUsingCmdletAliases',
                   'PSAvoidUsingComputerNameHardcoded',
                   'PSAvoidUsingConvertToSecureStringWithPlainText',
                   'PSAvoidUsingEmptyCatchBlock',
                   'PSAvoidUsingFilePath',
                   'PSAvoidUsingInvokeExpression',
                   'PSAvoidUsingPlainTextForPassword',
                   'PSAvoidUsingPositionalParameters',
                   'PSAvoidUsingUserNameAndPasswordParams',
                   'PSAvoidUsingWMICmdlet',
                   'PSAvoidUsingWriteHost',
                   'PSDSC*',
                   'PSMisleadingBacktick',
                   'PSMissingModuleManifestField',
                   'PSPlaceCloseBrace',
                   'PSPlaceOpenBrace',
                   'PSPossibleIncorrectComparisonWithNull',
                   'PSProvideCommentHelp'
                   'PSReservedCmdletChar',
                   'PSReservedParams',
                   'PSReturnCorrectTypesForDSCFunctions',
                   'PSShouldProcess',
                   'PSStandardDSCFunctionsInResource',
                   'PSUseApprovedVerbs',
                   'PsUseBOMForUnicodeEncodedFile',
                   'PSUseCmdletCorrectly',
                   'PSUseConsistentIndentation',
                   'PSUseConsistentWhitespace',
                   'PSUseIdenticalMandatoryParametersForDSC',
                   'PSUseIdenticalParametersForDSC',
                   'PSUseDeclaredVarsMoreThanAssignments',
                   'PSUseLiteralInitializerForHashtable',
                   'PSUseOutputTypeCorrectly',
                   'PSUsePSCredentialType',
                   'PSUseShouldProcessForStateChangingFunctions',
                   'PSUseSingularNouns',
                   'PSUseSupportsShouldProcess',
                   'PSUseVerboseMessageInDSCResource'
                   )

    Rules = @{
        PSPlaceCloseBrace = @{
            Enable = $true
            IgnoreOneLineBlock = $true
            NewLineAfter = $true
        }

        PSPlaceOpenBrace = @{
            Enable = $true
            OnSameLine = $true
            NewLineAfter = $true
            IgnoreOneLineBlock = $true
        }

        PSUseConsistentWhitespace = @{
            Enable = $true
            CheckOpenBrace = $true
            CheckOpenParen = $true
            CheckOperator = $true
            CheckSeparator = $true
        }
    }
}
