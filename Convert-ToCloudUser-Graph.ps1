# Convert-ToCloudUser-Graph.ps1
# PowerShell script to convert Entra ID hybrid users to cloud-only using ADSyncTools

# Import required modules
Import-Module Microsoft.Graph -ErrorAction Stop
Import-Module ADSyncTools -ErrorAction Stop

# Connect to Microsoft Graph
Connect-MgGraph -Scopes "User.ReadWrite.All", "Directory.AccessAsUser.All"

# Check Scope
(Get-MgContext).Scopes

# Load users from CSV (make sure users.csv is in the same folder and contains UserPrincipalName column)
$users = Import-Csv -Path "./users.csv"

# Output log file
$logFile = "./output-log.txt"
if (Test-Path $logFile) { Remove-Item $logFile }

foreach ($user in $users) {
    $upn = $user.UserPrincipalName
    Write-Host "\n🔍 Checking $upn..."

    try {
        $graphUser = Get-MgUser -UserId $upn -ErrorAction Stop

        if ($graphUser.onPremisesImmutableId) {
            Write-Host "🟡 $upn is a hybrid user (has ImmutableId)."
            $confirm = Read-Host "❓ Convert $upn to cloud-only? (y/n)"
            if ($confirm -eq 'y') {
                Clear-ADSyncToolsOnPremisesAttribute -Identity $upn -onPremisesImmutableId
                Add-Content -Path $logFile -Value "✅ $upn: Cleared onPremisesImmutableId"
                Write-Host "✅ Converted $upn to cloud-only." -ForegroundColor Green
            } else {
                Add-Content -Path $logFile -Value "⏩ $upn: Skipped by user choice"
            }
        } else {
            Write-Host "✔️ $upn is already cloud-only." -ForegroundColor Cyan
            Add-Content -Path $logFile -Value "✔️ $upn: Already cloud-only"
        }
    } catch {
        Write-Warning "⚠️ Error processing $upn: $_"
        Add-Content -Path $logFile -Value "❌ $upn: Error - $_"
    }
}

Write-Host "\n🎯 Completed. Check 'output-log.txt' for details." -ForegroundColor Yellow
