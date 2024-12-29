param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("Start", "Stop")]
    [string]$Action
)

# Connect to Azure
Connect-AzAccount -Identity

# Resource Variables
$resourceGroupName = "<YourResourceGroupName>"
$appName = "<YourAppName>"

# Action Execution
if ($Action -eq "Start") {
    Start-AzWebApp -ResourceGroupName $resourceGroupName -Name $appName
    Write-Output "Started Web App: $appName"
} elseif ($Action -eq "Stop") {
    Stop-AzWebApp -ResourceGroupName $resourceGroupName -Name $appName
    Write-Output "Stopped Web App: $appName"
}