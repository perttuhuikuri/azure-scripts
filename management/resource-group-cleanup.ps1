param(
    [string]$TagKey = "Cleanup",
    [string]$TagValue = "true",
    [switch]$DryRun,
    [switch]$Force # If specified, deletes without confirmation
)

# Connect to Azure using Managed Identity
Connect-AzAccount -Identity

# Get all resource groups in the subscription
Write-Output "Fetching all resource groups..."
$resourceGroups = Get-AzResourceGroup

if (-not $resourceGroups) {
    Write-Output "No resource groups found in this subscription."
    return
}

# Initialize arrays for unused and tagged resource groups
$unusedResourceGroups = @()
$taggedForCleanup = @()

foreach ($rg in $resourceGroups) {
    Write-Output "Checking resource group: $($rg.ResourceGroupName)..."

    # Get all resources in the resource group
    $resources = Get-AzResource -ResourceGroupName $rg.ResourceGroupName

    if ($resources.Count -eq 0) {
        Write-Output "Resource group $($rg.ResourceGroupName) has no resources."
        $unusedResourceGroups += $rg
    }

    # Check for tags if not null
    if ($rg.Tags -ne $null -and $rg.Tags[$TagKey] -eq $TagValue) {
        Write-Output "Resource group $($rg.ResourceGroupName) is tagged for cleanup."
        $taggedForCleanup += $rg
    }
}

# Combine unused and tagged resource groups
$cleanupCandidates = $unusedResourceGroups + $taggedForCleanup | Select-Object -Unique

if ($cleanupCandidates.Count -eq 0) {
    Write-Output "No resource groups found for cleanup."
    return
}

# Display cleanup candidates
Write-Output "The following resource groups are candidates for cleanup:"
$cleanupCandidates | ForEach-Object {
    Write-Output " - $($_.ResourceGroupName)"
}

if (-not $DryRun) {
    if (-not $Force) {
        Write-Output "Deletion is not performed because the -Force parameter was not provided."
        return
    }

    foreach ($rg in $cleanupCandidates) {
        Write-Output "Deleting resource group: $($rg.ResourceGroupName)..."
        Remove-AzResourceGroup -Name $rg.ResourceGroupName -Force -AsJob
    }

    Write-Output "Cleanup completed. Resource groups are being deleted."
} else {
    Write-Output "Dry run mode: No resource groups were deleted."
}
