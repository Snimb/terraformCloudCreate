# PowerShell script to delete a specific Azure resource group

# Define the name of the resource group you want to delete
$resourceGroupName = "<your-resource-group-name>"

# Login to Azure
Write-Host "Logging in to Azure..."
Connect-AzAccount

# Optional: Set the Azure subscription context if you have multiple subscriptions
# $subscriptionId = "your-subscription-id-here"
# Set-AzContext -SubscriptionId $subscriptionId

# Check if the resource group exists
$resourceGroupExists = Get-AzResourceGroup -Name $resourceGroupName -ErrorAction SilentlyContinue

if ($resourceGroupExists) {
    # Confirm deletion with the user
    $confirmation = Read-Host "Are you sure you want to delete the resource group '$resourceGroupName' and all its resources? (yes/no)"
    if ($confirmation -eq "yes") {
        # Deleting the resource group
        Write-Host "Deleting resource group '$resourceGroupName'..."
        Remove-AzResourceGroup -Name $resourceGroupName -Force
        
        Write-Host "Resource group '$resourceGroupName' has been deleted." -ForegroundColor Green
    }
    else {
        Write-Host "Deletion cancelled by user." -ForegroundColor Yellow
    }
}
else {
    Write-Host "Resource group '$resourceGroupName' not found." -ForegroundColor Red
}

# Deleting the key vault permanently
Write-Host "Deleting the key vault permanently"
Remove-AzKeyVault -VaultName "<your-vault-name>" -Location "<your-location>" -InRemovedState -Force
