param(
    [string]$AppPath = "C:\inetpub\helloworld",
    [string]$SiteName = "HelloWorldSite",
    [string]$AppPool = "HelloWorldAppPool",
    [string]$Port = "8080"
)

Import-Module WebAdministration

Write-Host "=== Deploying IIS site ==="

Remove-Website -Name $SiteName -ErrorAction SilentlyContinue
Remove-WebAppPool -Name $AppPool -ErrorAction SilentlyContinue
Remove-Item -Path $AppPath -Recurse -Force -ErrorAction SilentlyContinue

New-Item -ItemType Directory -Force -Path $AppPath | Out-Null
Copy-Item "..\..\publish\*" $AppPath -Recurse -Force

icacls $AppPath /grant "IIS_IUSRS:(OI)(CI)(M)" /T
icacls $AppPath /grant "IUSR:(OI)(CI)(RX)" /T

New-WebAppPool -Name $AppPool
Set-ItemProperty IIS:\AppPools\$AppPool -Name managedRuntimeVersion -Value ""

New-Website -Name $SiteName -Port $Port -PhysicalPath $AppPath -ApplicationPool $AppPool -Force

Write-Host "Deployment done. Access http://localhost:$Port"
