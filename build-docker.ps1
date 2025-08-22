# PowerShell script to build and run MSSQL MCP Server with Docker

Write-Host "MSSQL MCP Server Docker Build Script" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Green

# Check if Docker is running
Write-Host "`nChecking Docker status..." -ForegroundColor Yellow
$dockerStatus = docker version 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker is not running!" -ForegroundColor Red
    Write-Host "`nPlease start Docker Desktop:" -ForegroundColor Yellow
    Write-Host "1. Open Docker Desktop from Start Menu" -ForegroundColor Cyan
    Write-Host "2. Wait for Docker to fully start (whale icon in system tray)" -ForegroundColor Cyan
    Write-Host "3. Run this script again" -ForegroundColor Cyan
    
    # Try to start Docker Desktop
    Write-Host "`nAttempting to start Docker Desktop..." -ForegroundColor Yellow
    $dockerDesktopPath = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    
    if (Test-Path $dockerDesktopPath) {
        Start-Process "$dockerDesktopPath"
        Write-Host "Docker Desktop starting... Please wait 30-60 seconds and run this script again." -ForegroundColor Green
    } else {
        Write-Host "Docker Desktop not found at default location." -ForegroundColor Red
        Write-Host "Please start Docker Desktop manually." -ForegroundColor Yellow
    }
    
    exit 1
}

Write-Host "Docker is running!" -ForegroundColor Green

# Check if .env file exists
if (!(Test-Path ".env")) {
    Write-Host "`nNo .env file found. Creating from .env.production template..." -ForegroundColor Yellow
    
    if (Test-Path ".env.production") {
        Copy-Item ".env.production" ".env"
        Write-Host ".env file created. Please edit it with your database credentials." -ForegroundColor Yellow
        Write-Host "Edit .env file and set your DB_PASSWORD, then run this script again." -ForegroundColor Red
        
        # Open .env in notepad
        notepad.exe .env
        exit 1
    } else {
        Write-Host ".env.production template not found!" -ForegroundColor Red
        exit 1
    }
}

# Check if DB_PASSWORD is set in .env
$envContent = Get-Content ".env" -Raw
if ($envContent -match "DB_PASSWORD=your_secure_password" -or $envContent -match "DB_PASSWORD=$") {
    Write-Host "`nWarning: DB_PASSWORD is not set in .env file!" -ForegroundColor Red
    Write-Host "Please edit .env and set your database password." -ForegroundColor Yellow
    notepad.exe .env
    exit 1
}

# Build Docker image
Write-Host "`nBuilding Docker image..." -ForegroundColor Yellow
docker-compose build

if ($LASTEXITCODE -ne 0) {
    Write-Host "Docker build failed!" -ForegroundColor Red
    exit 1
}

Write-Host "`nDocker image built successfully!" -ForegroundColor Green

# Ask if user wants to run the container
$response = Read-Host "`nDo you want to start the container now? (y/n)"

if ($response -eq 'y' -or $response -eq 'Y') {
    Write-Host "`nStarting MSSQL MCP Server..." -ForegroundColor Yellow
    docker-compose up -d
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`nMSSQL MCP Server is running!" -ForegroundColor Green
        Write-Host "`nAccess points:" -ForegroundColor Cyan
        Write-Host "  - Status: http://localhost:8585/" -ForegroundColor White
        Write-Host "  - SSE Endpoint: http://localhost:8585/sse" -ForegroundColor White
        Write-Host "  - Diagnostic: http://localhost:8585/diagnostic" -ForegroundColor White
        Write-Host "  - Tools List: http://localhost:8585/tools" -ForegroundColor White
        
        Write-Host "`nUseful commands:" -ForegroundColor Cyan
        Write-Host "  - View logs: docker-compose logs -f" -ForegroundColor White
        Write-Host "  - Stop server: docker-compose down" -ForegroundColor White
        Write-Host "  - Restart server: docker-compose restart" -ForegroundColor White
    } else {
        Write-Host "Failed to start container!" -ForegroundColor Red
    }
} else {
    Write-Host "`nTo start the server later, run:" -ForegroundColor Yellow
    Write-Host "  docker-compose up -d" -ForegroundColor White
}

Write-Host "`nDone!" -ForegroundColor Green