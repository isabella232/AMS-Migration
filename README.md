# README (for migration)

> Older version of product will be referred to as Azure Monitor for SAP Solutions (classic) or AMS (classic). AMS (classic) is currently in public preview.

> **The newer** version of the product will be referred to as Azure Monitor for SAP solutions or AMS. AMS is currently in private preview and is subjected to allow-listing of subscription.

Below are steps to migrate AMS (classic) to AMS monitor resource.

## Pre-requisite

- **Deploy new AMS resource:** Please follow [AMS onboarding wiki](https://github.com/Azure/Azure-Monitor-for-SAP-solutions-preview/wiki) to deploy new AMS resource manually.<br> <span style="color:blue"><i>Please note</i></span>: While following onboarding wiki, please deploy only the AMS resource (without providers). Providers will be migrated automatically using the automation script (instructions below). <br><span style="color:blue"><i>Please note:</i></span>: To retain previously collected telemetry data please select checkbox for &quot;Use existing log analytics workspace&quot; while creating new AMS resource. Instructions can be found in On-boarding wiki. This selection will ensure that log analytics workspace associated with your current AMS (classic) resource is used with new AMS resource. Therefore, you will be able to retain previously collected telemetry.

- **(Optional) Hosts file entries:** This pre-requisite is applicable for you if you have one or more active SAP NetWeaver provider in AMS (classic) and you have custom DNS for name host-name resolution which was unable to resolve names of SAP systems during SAP NetWeaver provider creation. This pre-requisite entails that you keep hosts.json file handy or have contents of hosts.json file handy. One way to get to contents of hosts.json file by logging into collector VM in AMS (classic) managed resource group. You can follow below steps to log in collector VM:

	1. Log into Azure portal and navigate to your AMS (classic resource). In overview page, navigate to managed reosurce group -> virtual machine (collector VM). Within 	            overview page of collector VM, there is search box in table of content (left panel). In search box, type 'serial' and select 'Boot Diagnostics'.
	
	   ![Azure Cloud Shell](./src/assets/VmBootDiag.png "Boot Diagnostics")
	
	2. In boot diagnostic, click on 'Settings' in top navigation bar and select the 'enable with custom storage account'. From drop down select the storage account which is deployed as part of a AMS (classic) managed resource group.
	   ![Azure Cloud Shell](./src/assets/SABootDiag.png "Configure Boot Diagnostics with Storage Account")
	
	3. (Optional) Configure/upate password for collector VM.Type password in the search text and click on Reset Password. The password can be reset using any of the three modes available. The easiest mode is the Reset Password mode.
	![Azure Cloud Shell](./src/assets/collectorVmPsswd.png "Configure VM Password")
	4. Type serial in the search box and open Serial Console. If not prompted to login, press enter and provide the credentials set in step 3 to login.
	![Azure Cloud Shell](./src/assets/SerialConsole.png "Serial Console")
	5. Finally, navigate to /etc/hosts file to find host name information. Run the following command from within the Collector VM to get to hosts file.

		> sudo nano /etc/hosts
	6. Copy contents of hosts file and paste them in **hosts.txt** file in the /src folder for migration of SAP NetWeaver providers. Please ensure that you are copying into hosts.txt in /src folder within the repository that you have previously cloned. 

## Migration steps
> Continue running AMS (Azure Monitor for SAP Solutions) 1.0 as is.<br/>Assuming you have completed the pre-requisite you should have a successfully deployed AMS, follow the cmds below to automatically migrate all your SAP HANA &amp; SAP NetWeaver providers.
	
1. Log into [Azure Portal](https://ms.portal.azure.com) and open PowerShell. Alternatively, you can use your local PowerShell.<br/> 
![Azure Cloud Shell](./src/assets/CloudShell.png "Azure Cloud Shell")
2. Clone migration GitHub repository <br> <pre><code>git clone <a href="https://github.com/Azure/AMS-Migration.git">https://github.com/Azure/AMS-Migration.git</a></code></pre>
3. Set context of migration by providing your subscription ID and Tenant ID.
	<pre><code>
	[string]$subscriptionId = &quot;&lt;subscription ID&gt;&quot;
	[string]$tenantId = &quot;&lt;Tenant ID&gt;&quot; 
	Set-AzContext -Subscription $subscriptionId -Tenant $tenantId;
	</code></pre>
	You can find your subscription ID by navigating to your AMS (classic) resource -> overview page.
	![Find SubcriptionId](./src/assets/FindSubscriptionId.png "Find SubcriptionId")

	You can find tenant ID by navigating to Azure Active Directory in Azure portal -> overview page.
	![Find TenantId](./src/assets/FindTenantId.png "Find TenantId")

4. Select which providers you want to migrate. You can choose between 3 options **(We recommend Option 1)**
    - Option 1: All providers - Migrates all SAP HANA &amp; SAP NetWeaver providers
    - Option 2: &quot;saphana&quot; providers – Migrates all SAP HANA providers
    - Option 3: &quot;sapnetweaver&quot; providers – Migrates all SAP NetWeaver providers

5. Set the providerType variable accordingly:
	<pre><code>
	[string]$providerType = &quot;all&quot;
	OR 
	[string]$providerType = &quot;saphana&quot;
	OR
	[string]$providerType = &quot;sapnetweaver&quot;
	</code></pre>

6. Provider the AMS (classic) resource ARM ID and new AMS resource ARM ID. You can find those by navigating to AMS resource properties and selecting Resource ID. Then, execute the following cmds:
	<pre><code>
	[string]$amsv1ArmId = &quot;&lt;AMS (classic) ARM ID&gt;&quot;
	[string]$amsv2ArmId = &quot;&lt;AMS ARM ID&gt;&quot;
	</code></pre>
	Find resource ID for AMS (classic) resource: <br/>
	![ResourceId for AMS Classic](./src/assets/ResourceIdAmsClassic.png "ResourceId for AMS Classic")
	<br/><br/>
	Find resource ID for AMS resource: <br/>
	![ResourceId for AMS V2](./src/assets/ResourceIdAmsV2.png "ResourceId for AMS V2")

7. (Optional) If you are migrate SAP NetWeaver providers, you need to update the host file entries before executing migration script. You can do so by copying entries from hosts file under a new hosts.txt file in /src folder within previously cloned repository. 
	<br/>![ResourceId for AMS V2](./src/assets/hostfile.png "ResourceId for AMS V2")

8. Final script should look like this:
	<pre><code>
	[string]$providerType = &quot;all&quot;
	[string]$amsv1ArmId = &quot;&lt;AMS (classic) ARM ID&gt;&quot;
	[string]$amsv2ArmId = &quot;&lt;AMS ARM ID&gt;&quot;	
	$command = ".\AMS-Migration\src\Migration.ps1 -providerType $providerType -amsv1ArmId $amsv1ArmId -amsv2ArmId $amsv2ArmId";
	Invoke-Expression $command</code></pre>
	After the script executes successfully, you will see the following output. <br/>
	![Provider Summary](./src/assets/Summary.png "Provider Summary")

## Alert Migration steps
> Continue running AMS Migration Script for Migrating Alerts as is.<br/>Assuming you have completed the provider-migration you should have successfully deployed AMS2.0 providers, follow the steps below to automatically migrate all your SAP HANA &amp; SAP NetWeaver alerts.

1. After the provider migration completes, the migration script will check if the Log Analytics workspace(LAWS) is same or different in AMS1.0 and AMS2.0.
	- If the LAWS is same then no Alert migration is required.
2. If the LAWS is different you would be presented with a choice to migrate the Alerts. You can type 'yes' if you wish to migrate the alerts or enter 'no' otherwise.
	![Alert Migration](./src/assets/AlertChoice.png "Alert Migration")
3. If your choice is 'yes' then all the alerts will be migrated from AMS1.0 LAWS to AMS2.0 LAWS.
4. Please note if your choice was to migrate only providers of type SapHana or SapNetWeaver then only the providerType specfic alerts will be migrated. If you chose to migrate 'all' providers then all the supported provider alerts would be migrated.
5. Below is an example of the ouput when user chooses to migrate only SapHana Alerts. Only SapHana specific alerts are migrated.
![Alert Migration Completed](./src/assets/FinalAlerts.png "Alert Migration Completed")
6. The Alert Migration is successfully completed now!

## Optional: 
You can also manually recreate all alert rules for SAP HANA &amp; SAP NetWeaver in new AMS resource incase you opted for not migrating them via the migration script.

## Optional but HIGHLY Recommended 

After successfully migrating all SAP HANA &amp; SAP NetWeaver providers, navigate back to AMS (classic) resource and manually delete all SAP HANA &amp; SAP NetWeaver providers. Since these providers have already migrated to AMS resource you will continue to receive monitoring telemetry in same Log Analytics workspace from these.

<span style="color:blue"><i>Please note</i></span>: You can choose to not delete these providers in AMS (classic) resource after successfully migrating these providers – AMS will work just fine. However, you will incur additional costs on log analytics workspace since duplicate data will get pumped into it (from both AMS (classic) and AMS). Therefore, we highly recommend that you delete all successfully migrated providers from AMS (classic) resource.

## Important:
> Please DO NOT DELETE AMS (classic) resource even after successfully migrating all providers.

> Please DO NOT DELETE AMS (classic) managed resource group even after successfully migrating all providers.

For data continuity purpose, if you are reusing the log analytics workspace from AMS (classic) for AMS, deleting either AMS (classic) resource or managed resource group will lead to deletion of log analytics workspace. Unfortunately, that would lead to losing all previously collected telemetry from AMS (classic) and halt new telemetry collection from AMS.

## Upcoming changes: 
If you have other providers besides SAP HANA &amp; SAP NetWeaver, please check this guide next month. AMS engineering team is planning to support other providers such as High-availability (pacemaker) cluster, SQL Server and OS in coming months.

## Support

Please use &#39;Issues&#39; in GitHub repository to open support cases for AMS engineering team.

![Support Ticket](./src/assets/SupportTicket.png "Support Ticket")

## Contributing

This project welcomes contributions and suggestions.  Most contributions require you to agree to a
Contributor License Agreement (CLA) declaring that you have the right to, and actually do, grant us
the rights to use your contribution. For details, visit https://cla.opensource.microsoft.com.

When you submit a pull request, a CLA bot will automatically determine whether you need to provide
a CLA and decorate the PR appropriately (e.g., status check, comment). Simply follow the instructions
provided by the bot. You will only need to do this once across all repos using our CLA.

This project has adopted the [Microsoft Open Source Code of Conduct](https://opensource.microsoft.com/codeofconduct/).
For more information see the [Code of Conduct FAQ](https://opensource.microsoft.com/codeofconduct/faq/) or
contact [opencode@microsoft.com](mailto:opencode@microsoft.com) with any additional questions or comments.

## Trademarks

This project may contain trademarks or logos for projects, products, or services. Authorized use of Microsoft 
trademarks or logos is subject to and must follow 
[Microsoft's Trademark & Brand Guidelines](https://www.microsoft.com/en-us/legal/intellectualproperty/trademarks/usage/general).
Use of Microsoft trademarks or logos in modified versions of this project must not cause confusion or imply Microsoft sponsorship.
Any use of third-party trademarks or logos are subject to those third-party's policies.
