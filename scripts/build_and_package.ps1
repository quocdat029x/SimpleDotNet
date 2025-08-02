param(
    [string]$SolutionRoot = "D:\SimpleDotNet",
    [string]$PublishRoot = "D:\SimpleDotNet\publish",
    [string]$DockerImage = "helloworldapp:local",
    [switch]$BuildDocker
)

Write-Host "=== [1/6] Cleaning old publish folders ==="
Remove-Item "$PublishRoot" -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Path "$PublishRoot" | Out-Null

Write-Host "=== [2/6] Building HelloWorldApp (Windows) ==="
dotnet publish "$SolutionRoot\src\HelloWorldApp" `
    -c Release -r win-x64 --self-contained true `
    -o "$PublishRoot\HelloWorldApp"

if (!(Test-Path "$PublishRoot\HelloWorldApp\HelloWorldApp.dll")) {
    Write-Error "❌ Build failed for HelloWorldApp (Windows)"
    exit 1
}

Write-Host "=== [3/6] Building HelloWorldApp (Linux) ==="
dotnet publish "$SolutionRoot\src\HelloWorldApp" `
    -c Release -r linux-x64 --self-contained true `
    -o "$PublishRoot\HelloWorldAppDocker"

if (!(Test-Path "$PublishRoot\HelloWorldAppDocker\HelloWorldApp")) {
    Write-Error "❌ Build failed for HelloWorldApp (Linux)"
    exit 1
}

Write-Host "=== [4/6] Building WebMonitorService ==="
dotnet publish "$SolutionRoot\src\WebMonitorService" `
    -c Release -r win-x64 --self-contained true `
    -o "$PublishRoot\WebMonitorService"

if (!(Test-Path "$PublishRoot\WebMonitorService\WebMonitorService.exe")) {
    Write-Error "❌ Build failed for WebMonitorService"
    exit 1
}

if ($BuildDocker) {
    Write-Host "=== [5/6] Building Docker image from Linux build ==="
    docker build -t $DockerImage -f "$SolutionRoot\Dockerfile" "$SolutionRoot"
}

Write-Host "=== [6/6] Packaging artifacts ==="
$zipFile = "$SolutionRoot\artifacts.zip"
if (Test-Path $zipFile) { Remove-Item $zipFile -Force }
Compress-Archive -Path "$PublishRoot\*" -DestinationPath $zipFile

Write-Host "`n✅ Build and packaging completed successfully."
Write-Host "Artifacts: $zipFile"
if ($BuildDocker) { Write-Host "Docker image: $DockerImage" }
