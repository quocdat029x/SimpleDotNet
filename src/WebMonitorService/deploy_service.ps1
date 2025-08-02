param(
    [string]$ServiceName = "WebMonitorService",
    [string]$ProjectPath = "D:\SimpleDotNet\src\WebMonitorService",
    [string]$PublishPath = "D:\SimpleDotNet\publish_service"
)

$ExePath = Join-Path $PublishPath "WebMonitorService.exe"

Write-Host "=== [1/5] Building and publishing service ==="
dotnet publish $ProjectPath -c Release -r win-x64 --self-contained true -o $PublishPath

if (!(Test-Path $ExePath)) {
    Write-Error "❌ Build failed: EXE not found at $ExePath"
    exit 1
}

Write-Host "=== [2/5] Removing old service if exists ==="
sc.exe stop $ServiceName 2>$null
sc.exe delete $ServiceName 2>$null
Start-Sleep -Seconds 2

Write-Host "=== [3/5] Creating new Windows Service ==="
$createResult = sc.exe create $ServiceName binPath= "`"$ExePath`"" start= auto
Write-Host $createResult

$service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
if ($null -eq $service) {
    Write-Error "❌ Failed to create Windows Service. Run PowerShell as Administrator and check path."
    exit 1
}

Write-Host "=== [4/5] Configuring failure recovery ==="
sc.exe failure $ServiceName reset= 300 actions= restart/3000

Write-Host "=== [5/5] Starting service ==="
Start-Service $ServiceName
Start-Sleep -Seconds 2
Get-Service $ServiceName

Write-Host "`n✅ Deployment completed. Logs will be written to:"
Write-Host "$PublishPath\status_log.txt"
