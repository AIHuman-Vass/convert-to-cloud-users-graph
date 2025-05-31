# Convert Hybrid Entra ID Users to Cloud-Only

PowerShell script that uses `ADSyncTools` and `Microsoft.Graph` to convert synchronized (hybrid) users in Microsoft Entra ID to cloud-only by clearing their `onPremisesImmutableId`.

## 🔧 Requirements

```powershell
Install-Module Microsoft.Graph -Scope CurrentUser -Force
Install-Module ADSyncTools -Scope CurrentUser -Force
Connect-MgGraph -Scopes "User.ReadWrite.All"
