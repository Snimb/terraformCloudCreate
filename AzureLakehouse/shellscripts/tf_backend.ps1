<#

.SYNOPSIS
    Configures Azure for secure Terraform access.
.DESCRIPTION
    Configures Azure for secure Terraform access using Azure Key Vault.
    The following steps are automated:
    - Creates an Azure Service Principal for Terraform.
    - Creates a new Resource Group.
    - Creates a new Storage Account.
    - Creates a new Storage Container.
    - Creates a new Key Vault.
    - Configures Key Vault Access Policies.
    - Creates Key Vault Secrets for these sensitive Terraform login details:
       - 'tf-subscription-id'
       - 'tf-client-id'
       - 'tf-client-secret'
       - 'tf-tenant-id'   
       - 'tf-access-key' 
    - Creates a SAS token for the uploaded script and stores it in the Key Vault.
    - Gives the Service Principal the Microsoft Graph permission Group.ReadWrite.All.
.NOTES
    Assumptions:
    - Azure PowerShell module is installed: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
    - You are already logged into Azure before running this script (eg. Connect-AzAccount)
    - Use "Connect-AzAccount -UseDeviceAuthentication" if browser prompts don't work.
    - select-AzSubscription -SubscriptionName 'Dev'
#>

[CmdletBinding()]
param (    
    $adminUserDisplayName = "simonwilliams_outlook.dk#EXT#@simonwilliamsoutlook.onmicrosoft.com", # This is used to assign yourself access to KeyVault
    $servicePrincipalName = "sp-tfmgmt-dev",
    $resourceGroupName = "rg-tfmgmt-dev",
    $location = "Germany West Central",
    $storageAccountSku = "Standard_LRS",
    $storageContainerName = "tfmgmtstates",
    $vaultName = "snimb-kv-tfstates-dev",
    $storageAccountName = "storageacctfstatesdev",
    $subscriptionID = "f4b675f5-226f-4256-b60c-f23c471e6386"
    
)

# Azure login
Write-Host "Checking for an active Azure login..."

$azContext = Get-AzContext

if (-not $azContext) {
    Write-Host "ERROR!" -ForegroundColor 'Red'
    throw "There is no active login for Azure. Please login first using 'Connect-AzAccount'"
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'


# Service Principle
Write-Host "Checking for an active Service Principle: [$servicePrincipalName]..."

# Get current context
$terraformSP = Get-AzADServicePrincipal -DisplayName $servicePrincipalName
if (-not $terraformSP) {
    Write-Host "Creating a Terraform Service Principal: [$servicePrincipalName] ..."
    try {
        $terraformSP = New-AzADServicePrincipal -DisplayName $servicePrincipalName -ErrorAction 'Stop'
        $newSpCredential = New-AzADSpCredential -ObjectId $terraformSP.Id
        $servicePrinciplePassword = $newSpCredential.SecretText
        # Assign Owner role to the Service Principal
        $scope = "/subscriptions/$subscriptionID" # Adjust the scope as needed
        # Assign Owner role to the Service Principal
New-AzRoleAssignment -ObjectId $terraformSP.Id -RoleDefinitionName 'Owner' -Scope $scope

# Add a delay to allow Azure to recognize the new role assignment
Start-Sleep -Seconds 30

# Check if the role assignment has been recognized by Azure
$attempts = 0
while ($attempts -lt 5 -and (-not(Get-AzRoleAssignment -ObjectId $terraformSP.Id -RoleDefinitionName 'Owner' -Scope $scope))) {
    Write-Host "Waiting for role assignment to propagate..."
    Start-Sleep -Seconds 30
    $attempts++
}

if ($attempts -eq 5) {
    throw "Role assignment has not propagated after several attempts."
}

    }
    catch {
        Write-Host "ERROR!" -ForegroundColor 'Red'
        throw $_
    }
    Write-Host "SUCCESS!" -ForegroundColor 'Green'
} else {
    # Service Principle exists so renew password (as cannot retrieve current one-off password)
    Write-Host "Renewing password for existing Service Principal: [$servicePrincipalName] ..."
    try {
        $newSpCredential = New-AzADSpCredential -ObjectId $terraformSP.Id
        $servicePrinciplePassword = $newSpCredential.SecretText
        Write-Host "SUCCESS! New password generated for Service Principal." -ForegroundColor 'Green'
    }
    catch {
        Write-Host "ERROR!" -ForegroundColor 'Red'
        throw $_
    }
}

# Get Subscription
Write-Host "`nFinding Subscription and Tenant details..."
try {
    $subscription = Get-AzSubscription -SubscriptionID $subscriptionID -ErrorAction 'Stop'
}
catch {
    Write-Host "ERROR!" -ForegroundColor 'Red'
    throw $_
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'

# New Resource Group
if (Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue) {  
    Write-Host -ForegroundColor 'Magenta' $resourceGroupName "- Terraform Management Resource Group already exists."  
}  
else {  
    Write-Host "`nCreating Terraform Management Resource Group: [$resourceGroupName]..."
    try {
        $azResourceGroupParams = @{
            Name        = $resourceGroupName
            Location    = $location
            Tag         = @{ keep = "true" }
            Force       = $true
            ErrorAction = 'Stop'
            Verbose     = $VerbosePreference
        }
        New-AzResourceGroup @azResourceGroupParams | Out-String | Write-Verbose
    }
    catch {
        Write-Host "ERROR!" -ForegroundColor 'Red'
        throw $_
    }
    Write-Host "SUCCESS!" -ForegroundColor 'Green'
}


# New storage account
if (Get-AzStorageAccount -ResourceGroupName $resourceGroupName -Name $storageAccountName -ErrorAction SilentlyContinue) {  
    Write-Host -ForegroundColor 'Magenta' $storageAccountName "- Storage Account for terraform states already exists."     
}  
else {  
    Write-Host "`nCreating Storage Account for terraform states: [$storageAccountName]..."
    try {
        $azStorageAccountParams = @{
            ResourceGroupName = $resourceGroupName
            Location          = $location
            Name              = $storageAccountName
            SkuName           = $storageAccountSku
            Kind              = 'StorageV2'
            ErrorAction       = 'Stop'
            Verbose           = $VerbosePreference
        }
        New-AzStorageAccount @azStorageAccountParams | Out-String | Write-Verbose
    }
    catch {
        Write-Host "ERROR!" -ForegroundColor 'Red'
        throw $_
    }
    Write-Host "SUCCESS!" -ForegroundColor 'Green'    
}

# Select Storage Container
Write-Host "`nSelecting Default Storage Account..."
try {
    $azCurrentStorageAccountParams = @{
        ResourceGroupName = $resourceGroupName
        AccountName       = $storageAccountName
        ErrorAction       = 'Stop'
        Verbose           = $VerbosePreference
    }
    Set-AzCurrentStorageAccount @azCurrentStorageAccountParams | Out-String | Write-Verbose
}
catch {
    Write-Host "ERROR!" -ForegroundColor 'Red'
    throw $_
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'

Write-Host "`nCreating Key Vault for terraform secrets: [$vaultName]..."
if (Get-AzKeyVault -Name $vaultName -ErrorAction SilentlyContinue) {  
    Write-Host -ForegroundColor 'Magenta' $vaultName "- Key Vault already exists."  
}  
else {
    try {

        Register-AzResourceProvider -ProviderNamespace "Microsoft.KeyVault"
        $azKeyVaultParams = @{
            VaultName         = $vaultName
            ResourceGroupName = $resourceGroupName
            Location          = $location
            ErrorAction       = 'Stop'
            Verbose           = $VerbosePreference
        }
        New-AzKeyVault @azKeyVaultParams | Out-String | Write-Verbose
    }
    catch {
        Write-Host "ERROR!" -ForegroundColor 'Red'
        throw $_
    }
    Write-Host "SUCCESS!" -ForegroundColor 'Green'
}

# Set KeyVault Access Policy
Write-Host "`nSetting KeyVault Access Policy for Admin User: [$adminUserDisplayName]..."
$adminADUser = Get-AzADUser -DisplayName $adminUserDisplayName
Write-Host "adminADUser = ${adminADUser}" -ForegroundColor 'Green'
try {
    $azKeyVaultAccessPolicyParams = @{
        VaultName                 = $vaultName
        ResourceGroupName         = $resourceGroupName
        UserPrincipalName         = $adminUserDisplayName
        PermissionsToKeys         = @('Get', 'List')
        PermissionsToSecrets      = @('Get', 'List', 'Set')
        PermissionsToCertificates = @('Get', 'List')
        ErrorAction               = 'Stop'
        Verbose                   = $VerbosePreference
    }
    Set-AzKeyVaultAccessPolicy @azKeyVaultAccessPolicyParams -PassThru | Out-String | Write-Verbose
}
catch {
    Write-Host "ERROR!" -ForegroundColor 'Red'
    throw $_
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'

Write-Host "`nSetting KeyVault Access Policy for Terraform SP: [$servicePrincipalName]..."
try {
    $azKeyVaultAccessPolicyParams = @{
        VaultName                 = $vaultName
        ResourceGroupName         = $resourceGroupName
        ObjectId                  = $terraformSP.Id
        PermissionsToKeys         = @('Get', 'List')
        PermissionsToSecrets      = @('Get', 'List', 'Set')
        PermissionsToCertificates = @('Get', 'List')
        ErrorAction               = 'Stop'
        Verbose                   = $VerbosePreference
    }
    Set-AzKeyVaultAccessPolicy @azKeyVaultAccessPolicyParams | Out-String | Write-Verbose
}
catch {
    Write-Host "ERROR!" -ForegroundColor 'Red'
    throw $_
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'


# Terraform login variables
# Get Storage Access Key
$storageAccessKeys = Get-AzStorageAccountKey -ResourceGroupName $resourceGroupName -Name $storageAccountName
$storageAccessKey = $storageAccessKeys[0].Value # only need one of the keys

$terraformLoginVars = @{
    'tf-subscription-id' = $subscription.Id
    'tf-client-id'       = $terraformSP.appId
    'tf-client-secret'   = $servicePrinciplePassword
    'tf-tenant-id'       = $subscription.TenantId
    'tf-access-key'      = $storageAccessKey
}
Write-Host "`nTerraform login details:"
$terraformLoginVars | Out-String | Write-Host

# Create KeyVault Secrets
Write-Host "`nCreating KeyVault Secrets for Terraform..."
try {
    foreach ($terraformLoginVar in $terraformLoginVars.GetEnumerator()) {
        $AzKeyVaultSecretParams = @{
            VaultName   = $vaultName
            Name        = $terraformLoginVar.Key
            SecretValue = (ConvertTo-SecureString -String $terraformLoginVar.Value -AsPlainText -Force)
            ErrorAction = 'Stop'
            Verbose     = $VerbosePreference
        }
        Set-AzKeyVaultSecret @AzKeyVaultSecretParams | Out-String | Write-Verbose
    }
}
catch {
    Write-Host "ERROR!" -ForegroundColor 'Red'
    throw $_
}
Write-Host "SUCCESS!" -ForegroundColor 'Green'

# Create Storage Container
# Check if the storage container already exists, create if it doesn't, and then upload a script file to it.
Write-Host "`nChecking for the Storage Container: [$storageContainerName] in the Storage Account: [$storageAccountName]..."

$storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccessKey
$container = Get-AzStorageContainer -Name $storageContainerName -Context $storageContext -ErrorAction SilentlyContinue

if ($container) {
    Write-Host "The container '$storageContainerName' already exists." -ForegroundColor 'Magenta'
} else {
    try {
        New-AzStorageContainer -Name $storageContainerName -Context $storageContext -ErrorAction Stop | Out-String | Write-Verbose
        Write-Host "SUCCESS! Storage container '$storageContainerName' created." -ForegroundColor 'Green'
    }
    catch {
        Write-Host "ERROR creating storage container:" -ForegroundColor 'Red'
        throw $_
    }
}

# Define the path to your script file you want to upload
$scriptFilePath = "C:\Users\sinwi\Documents\terraformCloudCreate\AzureFinal\modules\virtualmachines\init-vm-script.sh"
$scriptBlobName = "init-vm-script.sh"

# Upload the script to the storage container
Write-Host "`nUploading script to the Storage Container: [$storageContainerName]..."
try {
    Set-AzStorageBlobContent -File $scriptFilePath -Container $storageContainerName -Blob $scriptBlobName -Context $storageContext -ErrorAction Stop | Out-String | Write-Verbose
    Write-Host "SUCCESS! Script '$scriptBlobName' uploaded." -ForegroundColor 'Green'
}
catch {
    Write-Host "ERROR uploading script:" -ForegroundColor 'Red'
    throw $_
}

# Generate a SAS token for the uploaded script
Write-Host "`nGenerating SAS token for the script: [$scriptBlobName]..."
try {
    $expiryTimeString = (Get-Date).AddYears(1).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
    $expiryTime = [datetime]::ParseExact($expiryTimeString, "yyyy-MM-ddTHH:mm:ssZ", $null)

    $permission = "r"  # Read access
    $sasToken = New-AzStorageBlobSASToken -Container $storageContainerName -Blob $scriptBlobName -Permission $permission -ExpiryTime $expiryTime -Context $storageContext -FullUri

    Write-Host "SAS Token for script access generated successfully." -ForegroundColor 'Green'
    Write-Host $sasToken -ForegroundColor Cyan

    # Set the SAS token as an environment variable
    Write-Host "`nSetting environment variable 'TF_VAR_sas_token' for Terraform..."
    [System.Environment]::SetEnvironmentVariable("TF_VAR_sas_token", $sasToken, [System.EnvironmentVariableTarget]::Process)
    Write-Host "Environment variable 'TF_VAR_sas_token' is set successfully." -ForegroundColor 'Green'
}
catch {
    Write-Host "ERROR generating SAS token or setting environment variable:" -ForegroundColor 'Red'
    throw $_
}

# Store sas token in key vault
$sasTokenName = "sasTokenForScript"
try {
    Write-Host "`nStoring SAS token in Azure Key Vault: [$vaultName]..."
    Set-AzKeyVaultSecret -VaultName $vaultName -Name $sasTokenName -SecretValue (ConvertTo-SecureString -String $sasToken -AsPlainText -Force)
    Write-Host "SAS token stored successfully." -ForegroundColor Green
}
catch {
    Write-Host "ERROR storing SAS token in Azure Key Vault:" -ForegroundColor Red
    throw $_
}

# Variables
$appId = $terraformSP.AppId
$graphAppId = "00000003-0000-0000-c000-000000000000" # Microsoft Graph's well-known App ID
$graphPermissionId = "62a82d76-70ea-41e2-9197-370581804d09" # Permission ID for Group.ReadWrite.All

# Check if Azure CLI is available
if (Get-Command "az" -ErrorAction SilentlyContinue) {
    try {
        # Query the current permissions
        $permissions = az ad app permission list --id $appId | ConvertFrom-Json
        $existingPermissions = $permissions | Where-Object { $_.resourceAppId -eq $graphAppId -and ($_.resourceAccess | Where-Object { $_.id -eq $graphPermissionId }).Count -gt 0 }

        if ($existingPermissions) {
            Write-Host "Group.ReadWrite.All permission already exists. Checking for admin consent."
            # Check for admin consent
            $adminConsent = $permissions | Where-Object { $_.resourceAppId -eq $graphAppId -and $_.isGranted -eq $true }
            if (-not $adminConsent) {
                Write-Host "Admin consent for Group.ReadWrite.All permission has not been granted. Attempting to grant..."
                az ad app permission admin-consent --id $appId | Out-Null
                Write-Host "Admin consent for Group.ReadWrite.All permission granted successfully." -ForegroundColor Green
            } else {
                Write-Host "Admin consent for Group.ReadWrite.All permission already granted." -ForegroundColor Green
            }
        } else {
            Write-Host "Adding Group.ReadWrite.All permission to the application..."
            # Add the permission to the application
        # Add the permission to the application
az ad app permission add --id $appId --api $graphAppId --api-permissions "$graphPermissionId=Role"

# Wait for the permission to propagate
Start-Sleep -Seconds 30

# Grant the permissions
az ad app permission grant --id $appId --api $graphAppId --scope ".default"

# Add a delay to ensure the permission grant has been processed
Start-Sleep -Seconds 30

# Check for existing permissions and admin consent
$permissions = az ad app permission list --id $appId | ConvertFrom-Json
$existingPermissions = $permissions | Where-Object { $_.resourceAppId -eq $graphAppId -and ($_.resourceAccess | Where-Object { $_.id -eq $graphPermissionId }).Count -gt 0 }

if ($existingPermissions) {
    $adminConsent = $permissions | Where-Object { $_.resourceAppId -eq $graphAppId -and $_.isGranted -eq $true }
    if (-not $adminConsent) {
        Write-Host "Attempting to grant admin consent..."
        az ad app permission admin-consent --id $appId
    }
} else {
    throw "Permission to the application has not propagated properly."
}

            Write-Host "Group.ReadWrite.All permission added and admin consent attempted. Please check Azure portal for confirmation." -ForegroundColor Green
        }
    } catch {
        Write-Host "An error occurred: $_" -ForegroundColor Red
    }
} else {
    Write-Host "Azure CLI is not installed or not accessible. Please install Azure CLI to proceed." -ForegroundColor Red
}


Write-Host "`nScript execution completed." -ForegroundColor 'Green'

