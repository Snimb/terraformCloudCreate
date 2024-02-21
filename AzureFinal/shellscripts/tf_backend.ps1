<#

.SYNOPSIS
    Configures Azure for secure Terraform access.
.DESCRIPTION
    Configures Azure for secure Terraform access using Azure Key Vault.
    The following steps are automated:
    - Creates an Azure Service Principle for Terraform.
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
.EXAMPLE
    Connect-AzAccount -UseDeviceAuthentication
    .\scripts\TerraformManagement.ps1 -adminUserDisplayName 'AnjKeesari@gmail.com'
    Displays device login link, then configures secure Terraform access for admin user 'AnjKeesari@gmail.com'
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
Write-Host "SUCCESS!" -ForegroundColor 'Green'az
if (-not $terraformSP) {
    Write-Host "Creating a Terraform Service Principle: [$servicePrincipalName] ..."
    try {
        $terraformSP = New-AzADServicePrincipal -DisplayName $servicePrincipalName -Role 'Contributor' -ErrorAction 'Stop'
        $servicePrinciplePassword = $newSpCredential.secretText
    }
    catch {
        Write-Host "ERROR!" -ForegroundColor 'Red'
        throw $_
    }
    Write-Host "SUCCESS!" -ForegroundColor 'Green'

}
else {
    # Service Principle exists so renew password (as cannot retrieve current one-off password)
    $newSpCredential = $terraformSP | New-AzADSpCredential
    $servicePrinciplePassword = $newSpCredential.secretText
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
    Write-Host -ForegroundColor Magenta $resourceGroupName "- Terraform Management Resource Group already exists."  
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
    Write-Host -ForegroundColor Magenta $storageAccountName "- Storage Account for terraform states already exists."     
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
    Write-Host -ForegroundColor Magenta $vaultName "- Key Vault already exists."  
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
Write-Host "`nCreating Storage Container: [$storageContainerName] in the Storage Account: [$storageAccountName]..."
try {
    $storageContext = New-AzStorageContext -StorageAccountName $storageAccountName -StorageAccountKey $storageAccessKey
    New-AzStorageContainer -Name $storageContainerName -Context $storageContext -ErrorAction Stop | Out-String | Write-Verbose
    Write-Host "SUCCESS!" -ForegroundColor 'Green'
}
catch {
    Write-Host "ERROR creating storage container:" -ForegroundColor 'Red'
    throw $_
}
