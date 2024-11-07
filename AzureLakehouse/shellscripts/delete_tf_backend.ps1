# PowerShell script to delete a specific Azure resource group, its Key Vault, Service Principal, and associated App Registration

# Define the name of the resource group, key vault, and service principal you want to delete
$resourceGroupName = "rg-tfmgmt-dev"
$keyVaultName = "snimb-kv-tfstates-dev"
$location = "Germany West Central"
$servicePrincipalName = "sp-tfmgmt-dev"

# Attempt to log in to Azure
try {
    Write-Host "Logging in to Azure..."
    Connect-AzAccount -ErrorAction Stop
    Write-Host "Login successful." -ForegroundColor Green
}
catch {
    Write-Host "ERROR: Unable to login to Azure." -ForegroundColor Red
    throw $_
}

# Check if the resource group exists
$resourceGroupExists = $null
try {
    $resourceGroupExists = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction Stop
    Write-Host "Resource group '$resourceGroupName' found." -ForegroundColor Green
}
catch {
    Write-Host "Resource group '$resourceGroupName' does not exist or has already been deleted." -ForegroundColor Yellow
}

# Confirm deletion with the user if resource group exists
if ($resourceGroupExists) {
    $confirmation = Read-Host "Are you sure you want to delete the resource group '$resourceGroupName' and all its resources? (yes/no)"
    if ($confirmation -eq "yes") {
        try {
            # Deleting the resource group
            Write-Host "Deleting resource group '$resourceGroupName'..."
            Remove-AzResourceGroup -Name $resourceGroupName -Force -ErrorAction Stop
            Write-Host "Resource group '$resourceGroupName' has been deleted." -ForegroundColor Green
        }
        catch {
            Write-Host "ERROR: Unable to delete the resource group '$resourceGroupName'." -ForegroundColor Red
            throw $_
        }
    }
    else {
        Write-Host "Deletion cancelled by user." -ForegroundColor Yellow
    }
}

# Attempt to delete the key vault if resource group existed
if ($resourceGroupExists) {
    try {
        Write-Host "Attempting to delete the key vault '$keyVaultName' permanently..."
        Remove-AzKeyVault -VaultName $keyVaultName -Location $location -InRemovedState -Force -ErrorAction Stop
        Write-Host "Key vault '$keyVaultName' has been deleted permanently." -ForegroundColor Green
    }
    catch {
        Write-Host "ERROR: Unable to delete the key vault '$keyVaultName' or it does not exist." -ForegroundColor Yellow
    }
}

# Initialize variables
$servicePrincipalExists = $false
$appRegistrationExists = $false
$appRegistrationId = $null

# Attempt to find the Service Principal
try {
    Write-Host "Attempting to find the Service Principal '$servicePrincipalName'..."
    $servicePrincipal = Get-AzADServicePrincipal -DisplayName $servicePrincipalName -ErrorAction SilentlyContinue
    if ($servicePrincipal) {
        Write-Host "Service Principal '$servicePrincipalName' found." -ForegroundColor Green
        $servicePrincipalExists = $true
        $appRegistrationId = $servicePrincipal.ApplicationId
    } else {
        Write-Host "Service Principal '$servicePrincipalName' does not exist." -ForegroundColor Yellow
    }
}
catch {
    Write-Host "Error finding Service Principal '$servicePrincipalName'." -ForegroundColor Red
}

# Attempt to find the associated App Registration using fallback method
if (-not $appRegistrationId) {
    Write-Host "Attempting to find the App Registration by name '$servicePrincipalName' as fallback..."
    $appRegistration = Get-AzADApplication -DisplayName $servicePrincipalName -ErrorAction SilentlyContinue
    if ($appRegistration) {
        Write-Host "App Registration '$servicePrincipalName' found by name." -ForegroundColor Green
        $appRegistrationId = $appRegistration.ObjectId
        $appRegistrationExists = $true
    } else {
        Write-Host "No App Registration found by name '$servicePrincipalName'." -ForegroundColor Yellow
    }
} elseif ($appRegistrationId) {
    $appRegistrationExists = $true
}

# Attempt to find the associated App Registration using fallback method
if (-not $appRegistrationId) {
    Write-Host "Attempting to find the App Registration by name '$servicePrincipalName' as fallback..."
    $appRegistration = Get-AzADApplication -DisplayName $servicePrincipalName -ErrorAction SilentlyContinue
    if ($appRegistration) {
        Write-Host "App Registration '$servicePrincipalName' found by name with Object ID: $($appRegistration.Id)." -ForegroundColor Green
        $appRegistrationId = $appRegistration.Id
        $appRegistrationExists = $true
    } else {
        Write-Host "No App Registration found by name '$servicePrincipalName'." -ForegroundColor Yellow
    }
}

# Deleting associated App Registration if it exists
if ($appRegistrationExists -and $appRegistrationId) {
    $confirmationApp = Read-Host "Are you sure you want to delete the App Registration associated with Service Principal '$servicePrincipalName'? (yes/no)"
    if ($confirmationApp -eq "yes") {
        try {
            Write-Host "Deleting associated App Registration with Object ID: $appRegistrationId..."
            Remove-AzADApplication -ObjectId $appRegistrationId -ErrorAction Stop
            Write-Host "Associated App Registration '$servicePrincipalName' has been deleted." -ForegroundColor Green
        }
        catch {
            Write-Host "ERROR: Unable to delete the associated App Registration with Object ID: $appRegistrationId. Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Deletion of App Registration cancelled by user." -ForegroundColor Yellow
    }
} elseif (-not $appRegistrationExists) {
    Write-Host "No associated App Registration exists for deletion." -ForegroundColor Yellow
}


# Deleting Service Principal if it exists
if ($servicePrincipalExists) {
    $confirmationSp = Read-Host "Are you sure you want to delete the Service Principal '$servicePrincipalName'? (yes/no)"
    if ($confirmationSp -eq "yes") {
        try {
            $spToDelete = Get-AzADServicePrincipal -ObjectId $servicePrincipal.Id -ErrorAction SilentlyContinue
            if ($spToDelete) {
                Write-Host "Deleting Service Principal '$servicePrincipalName'..."
                Remove-AzADServicePrincipal -ObjectId $servicePrincipal.Id -ErrorAction Stop
                Write-Host "Service Principal '$servicePrincipalName' has been deleted." -ForegroundColor Green
            } else {
                Write-Host "Service Principal '$servicePrincipalName' not found or already deleted." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "ERROR: Unable to delete the Service Principal '$servicePrincipalName'. Error: $_" -ForegroundColor Red
        }
    }
    else {
        Write-Host "Deletion of Service Principal cancelled by user." -ForegroundColor Yellow
    }
}

