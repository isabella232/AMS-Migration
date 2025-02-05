﻿function Update-ProviderTypeInput
{
    $Result = Read-Host -Prompt "You have not added specific provider tag. Are you sure you want to migrate all the supported providers?"
    Write-Host $Result;

    Write-Host "Your choice is $Result"

    $providerType = "All"
    if($Result -like "yes")
    {
        $logger.LogInfo("Migrating all supported provider types - [SapHana and SapNetWeaver (soap)]")
    }
    else
    {
        $providerType = Read-Host -Prompt 'Input your provider type to migrate'
        $logger.LogInfo("Migrating provider type - " + $providerType)
    }

    return $providerType
}

function Get-ProviderSapSid([string]$providerName, $logger)
{
    # Add-Type -AssemblyName PresentationCore,PresentationFramework
    # $MessageIcon = [System.Windows.MessageBoxImage]::Warning
    # [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
 
	[string]$sapSid = "";
	[string]$dialogContent = "SAP SID property not found for provider $providerName.";
	Write-Host $dialogContent;
	while ($sapSid.Length -lt 3) {
		$sapSid = Read-Host -Prompt "Please enter a 3 letter SAP SID ";
	}
	$sapSid = $sapSid.ToUpper();
	$sapSid = $sapSid.Substring(0,3);
    $logger.LogInfo("For provider $providerName, User entered SAP SID : $($sapSid)");
    return $sapSid;
}