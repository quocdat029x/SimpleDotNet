param(
    [string]$PublishService = "D:\SimpleDotNet\publish\WebMonitorService",
    [string]$ServiceName = "WebMonitorService"
)

$ExePath = Join-Path $PublishService "WebMonitorService.exe"

if (!(Test-Path $ExePath)) {
    Write-Error "❌ Executable not found at $ExePath. Please build first."
    exit 1
}

Write-Host "=== Deploying Windows Service [$ServiceName] ==="

sc.exe stop $ServiceName 2>$null
sc.exe delete $ServiceName 2>$null
Start-Sleep -Seconds 2

icacls "$PublishService" /grant "SYSTEM:(OI)(CI)(F)" /T > $null

Write-Host "Creating Windows Service..."
sc.exe create $ServiceName binPath= "`"$ExePath`"" start= auto

sc.exe failure $ServiceName reset= 300 actions= restart/3000

Write-Host "Starting service..."
Start-Service $ServiceName -ErrorAction SilentlyContinue
Start-Sleep -Seconds 3

$svc = Get-Service $ServiceName -ErrorAction SilentlyContinue
if ($svc.Status -eq 'Running') {
    Write-Host "`n✅ Service '$ServiceName' deployed and running successfully (LocalSystem)."
    Write-Host "Log file: $PublishService\status_log.txt"
} else {
    Write-Warning "`n⚠ Service created but not running. Please check Event Viewer logs for details."
}
