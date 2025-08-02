---

# 📜 README.md

## DevOps Engineer Take-Home Assignment

This project demonstrates a basic `.NET 9` application (`HelloWorldApp`) deployed on IIS, monitored by a Windows Service (`WebMonitorService`), and packaged in a Docker container. Deployment scripts are included to automate setup locally.

---

## 📂 Project Structure

```
SimpleDotNet/
 ├─ .github/workflows/ci-pipeline.yml      # CI pipeline (GitHub Actions)
 ├─ publish/                               # Build output for HelloWorldApp
 ├─ scripts/
 │   ├─ build_and_package.ps1              # Build solution, publish artifacts, build Docker image, run container
 │   ├─ deploy_iis.ps1                     # Deploy HelloWorldApp to IIS
 │   ├─ deploy_service.ps1                 # Deploy WebMonitorService as Windows Service
 │
 ├─ src/
 │   ├─ HelloWorldApp/                     # ASP.NET Razor Pages app
 │   │   ├─ Pages/                         # Razor pages
 │   │   ├─ Properties/                    # Launch settings
 │   │   ├─ Program.cs                     # Entry point
 │   │   ├─ appsettings.json
 │   │   └─ HelloWorldApp.csproj
 │   │
 │   └─ WebMonitorService/                 # Windows Service that monitors HelloWorldApp
 │       ├─ Worker.cs                      # Background worker checking website availability
 │       ├─ Program.cs                     # Entry point
 │       ├─ appsettings.json
 │       └─ deploy_service.ps1             # Script to install/start service (simple version)
 │
 ├─ Dockerfile                             # Docker build for HelloWorldApp
 ├─ artifacts.zip                          # Zipped build artifacts
 └─ README.md
```

---

## 🚀 1. Prerequisites

* **Windows 10/11** with Admin rights
* **IIS installed** (with `IIS Management Scripts and Tools`)
* **Docker Desktop** installed and running
* **.NET 9 SDK** installed
* **PowerShell 5+**

---

## 🔧 2. Build and Package

Run:

```powershell
cd .\scripts
.\build_and_package.ps1
```

This script:

* Builds `HelloWorldApp` and `WebMonitorService`
* Publishes files to `..\publish` and `..\publish_service`
* Builds Docker image `helloworldapp:local`
* Deploys Docker container `helloworld` on port `8080`

---

## 🌐 3. Deploy IIS Website

Run:

```powershell
cd .\scripts
.\deploy_iis.ps1
```

* Creates an IIS site `HelloWorldSite` on port `8080`.
* Copies latest build to `C:\inetpub\helloworld`.
* Accessible at: [http://localhost:8080](http://localhost:8080)

---

## 🖥️ 4. Deploy Monitoring Service

Run:

```powershell
cd .\scripts
.\deploy_service.ps1
```

* Installs `WebMonitorService` as a Windows Service.
* Runs under `LocalSystem`.
* Monitors `http://localhost:8080` every 60 seconds.
* Writes health status to:

  ```
  D:\SimpleDotNet\publish_service\status_log.txt
  ```

---

## 🐳 5. Docker Deployment (Optional)

Manual redeploy of Docker container:

```powershell
docker stop helloworld 2>$null
docker rm helloworld 2>$null
docker build -t helloworldapp:local -f Dockerfile .
docker run -d --name helloworld -p 8080:8080 helloworldapp:local
```

---

## ✅ Verification

* **Website**: [http://localhost:8080](http://localhost:8080)
* **Service Status**:

```powershell
Get-Service WebMonitorService
```

* **Monitoring Log**:

```powershell
Get-Content "D:\SimpleDotNet\publish_service\status_log.txt" -Tail 10
```

---

This README summarizes how to build, deploy, and test the entire solution locally according to the assignment requirements.

---