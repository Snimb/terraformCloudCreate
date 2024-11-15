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
    - Configures Key Vault Access Policies using RBAC.
    - Creates Key Vault Secrets for these sensitive Terraform login details:
       - 'tf-subscription-id'
       - 'tf-client-id'
       - 'tf-client-secret'
       - 'tf-tenant-id'   
       - 'tf-access-key' 
.NOTES
    Assumptions:
    - Azure PowerShell module is installed: https://docs.microsoft.com/en-us/powershell/azure/install-az-ps
    - You are already logged into Azure before running this script (eg. Connect-AzAccount)
    - Use "Connect-AzAccount -UseDeviceAuthentication" if browser prompts don't work.
    - select-AzSubscription -SubscriptionName 'Dev'
#>

[CmdletBinding()]
param (    
    $servicePrincipalName = "sp-tfmgmt-dev",
    $resourceGroupName = "rg-tfmgmt-dev",
    $location = "West Europe",
    $storageAccountSku = "Standard_LRS",
    $storageContainerName = "tfmgmtstates",
    $vaultName = "dt-kv-tfstates-dev",
    $storageAccountName = "storageacctfstatesdev",
    $subscriptionID = "cc27e964-dfe5-4136-a68b-80e2f93306ad",
    $adminUserObjectId = "f0096abe-ae88-47f1-bbf6-81521d8e6dde"
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

# Assigning RBAC roles to Key Vault for Admin User using the ObjectId
#Write-Host "`nAssigning RBAC roles to Key Vault for Admin User: [$adminUserObjectId]..."
#try {
#    New-AzRoleAssignment -ObjectId $adminUserObjectId -RoleDefinitionName 'Key Vault Administrator' -Scope (Get-AzKeyVault -VaultName $vaultName).ResourceId
#    Write-Host "SUCCESS! Admin User RBAC role assigned." -ForegroundColor 'Green'
#}
#catch {
#    Write-Host "ERROR!" -ForegroundColor 'Red'
#    throw $_
#}

#Write-Host "`nAssigning RBAC roles to Key Vault for Terraform SP: [$servicePrincipalName]..."
#try {
#    New-AzRoleAssignment -ObjectId $terraformSP.Id -RoleDefinitionName 'Key Vault Secrets User' -Scope (Get-AzKeyVault -VaultName $vaultName).ResourceId
#    Write-Host "SUCCESS! Terraform Service Principal RBAC role assigned." -ForegroundColor 'Green'
#}
#catch {
#    Write-Host "ERROR!" -ForegroundColor 'Red'
#    throw $_
#}

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

Write-Host "`nScript execution completed." -ForegroundColor 'Green'
